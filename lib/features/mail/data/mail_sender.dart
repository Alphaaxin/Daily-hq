import 'dart:async';

import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workmanager/workmanager.dart';

import '../../../core/db/app_db.dart';
import '../../../core/providers.dart';
import '../../../core/time/day_clock.dart';
import '../../people/data/contacts_repo.dart';
import '../domain/mail_merge.dart';
import 'gmail_service.dart';

/// One person to e-mail, with the values for their placeholders.
class Recipient {
  const Recipient({required this.email, this.name = '', this.vars = const {}, this.leadId, this.personId});
  final String email;
  final String name;
  final Map<String, String> vars;
  final int? leadId;
  final int? personId;

  Map<String, String> get values => {
    'name': name.isEmpty ? '' : firstName(name),
    'full_name': name,
    'email': email,
    ...vars,
  };
}

const taskMailQueue = 'nizam.mailQueue';

class MailSender {
  MailSender(this.ref);
  final Ref ref;
  bool _running = false;
  bool get running => _running;

  AppDb get _db => ref.read(dbProvider);

  /// Renders and queues a campaign. Returns how many were queued.
  Future<int> queue({
    required String campaign,
    required String subject,
    required String body,
    required List<Recipient> to,
    DateTime? atUtc,
  }) async {
    final when = atUtc ?? DateTime.now().toUtc();
    var n = 0;
    await _db.batch((b) {
      for (final r in to) {
        if (!isEmail(r.email)) continue;
        b.insert(
          _db.mailSends,
          MailSendsCompanion.insert(
            campaign: campaign,
            toEmail: r.email.trim(),
            toName: Value(r.name),
            subject: render(subject, r.values).text,
            body: render(body, r.values).text,
            leadId: Value(r.leadId),
            personId: Value(r.personId),
            scheduledAtUtc: when,
          ),
        );
        n++;
      }
    });
    final delay = when.difference(DateTime.now().toUtc());
    if (delay > const Duration(minutes: 1)) {
      try {
        await Workmanager().registerOneOffTask(
          '$taskMailQueue.${when.millisecondsSinceEpoch}',
          taskMailQueue,
          initialDelay: delay,
          constraints: Constraints(networkType: NetworkType.connected),
        );
      } catch (_) {}
    } else {
      unawaited(run());
    }
    return n;
  }

  /// Sends due e-mails one by one with human-like gaps until the queue is
  /// empty or today's limit is reached.
  Future<int> run() async {
    if (_running) return 0;
    _running = true;
    var sent = 0;
    try {
      final gmail = ref.read(gmailServiceProvider);
      final limit = ref.read(settingsProvider).mailDailyLimit;
      while (true) {
        final now = DateTime.now().toUtc();
        final next =
            await (_db.select(_db.mailSends)
                  ..where((m) => m.status.equals('queued') & m.scheduledAtUtc.isSmallerOrEqualValue(now))
                  ..orderBy([(m) => OrderingTerm.asc(m.scheduledAtUtc), (m) => OrderingTerm.asc(m.id)])
                  ..limit(1))
                .getSingleOrNull();
        if (next == null) break;
        if (remainingToday(sentToday: await gmail.sentToday(), dailyLimit: limit) == 0) break;
        try {
          final id = await gmail.send(to: next.toEmail, toName: next.toName, subject: next.subject, body: next.body);
          await (_db.update(_db.mailSends)..where((m) => m.id.equals(next.id))).write(
            MailSendsCompanion(
              status: const Value('sent'),
              sentAtUtc: Value(DateTime.now().toUtc()),
              gmailId: Value(id),
            ),
          );
          await _afterSend(next);
          sent++;
        } on GmailNotReady {
          rethrow;
        } catch (e) {
          await (_db.update(_db.mailSends)..where((m) => m.id.equals(next.id))).write(
            MailSendsCompanion(status: const Value('failed'), error: Value('$e')),
          );
        }
        await Future<void>.delayed(sendGap(sent));
      }
    } finally {
      _running = false;
    }
    return sent;
  }

  /// Lead → Contacted, and a "no reply yet?" reminder in 3 days.
  Future<void> _afterSend(MailSend m) async {
    final contacts = ref.read(contactsRepoProvider);
    final clock = ref.read(clockProvider);
    if (m.leadId != null) {
      final l = await contacts.lead(m.leadId!);
      if (l != null && l.stage == 'new') await contacts.setStage(l, 'contacted', clock);
    }
    final dueDay = DayKey.add(clock.today(), 3);
    await contacts.addFollowUp(
      leadId: m.leadId,
      personId: m.personId,
      dueAtUtc: clock.localToUtc(dueDay, 17, 0),
      note: 'No reply to "${m.subject}"? Follow up.',
      channel: 'email',
      origin: 'mail',
    );
  }

  Future<void> cancel(String campaign) =>
      (_db.update(_db.mailSends)..where((m) => m.campaign.equals(campaign) & m.status.equals('queued'))).write(
        const MailSendsCompanion(status: Value('cancelled')),
      );

  Future<void> retryFailed(String campaign) =>
      (_db.update(_db.mailSends)..where((m) => m.campaign.equals(campaign) & m.status.equals('failed'))).write(
        MailSendsCompanion(status: const Value('queued'), scheduledAtUtc: Value(DateTime.now().toUtc())),
      );
}

final mailSenderProvider = Provider((ref) => MailSender(ref));

class CampaignStats {
  CampaignStats(this.name);
  final String name;
  int queued = 0, sent = 0, failed = 0, cancelled = 0;
  DateTime? next;
  int get total => queued + sent + failed + cancelled;
}

final campaignsProvider = StreamProvider<List<CampaignStats>>((ref) {
  final db = ref.watch(dbProvider);
  return (db.select(db.mailSends)..orderBy([(m) => OrderingTerm.desc(m.id)])).watch().map((rows) {
    final m = <String, CampaignStats>{};
    for (final r in rows) {
      final c = m.putIfAbsent(r.campaign, () => CampaignStats(r.campaign));
      switch (r.status) {
        case 'queued':
          c.queued++;
          if (c.next == null || r.scheduledAtUtc.isBefore(c.next!)) c.next = r.scheduledAtUtc;
        case 'sent':
          c.sent++;
        case 'failed':
          c.failed++;
        default:
          c.cancelled++;
      }
    }
    return m.values.toList();
  });
});

final templatesProvider = StreamProvider<List<MailTemplate>>((ref) {
  final db = ref.watch(dbProvider);
  return (db.select(db.mailTemplates)..orderBy([(t) => OrderingTerm.desc(t.updatedAtUtc)])).watch();
});
