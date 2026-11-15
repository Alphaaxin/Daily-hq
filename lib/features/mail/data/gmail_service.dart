import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:googleapis/gmail/v1.dart' as gmail;

import '../../../core/providers.dart';
import '../../google/data/google_auth.dart';
import '../../targets/data/targets_repo.dart';
import '../domain/mail_merge.dart';

class GmailNotReady implements Exception {
  @override
  String toString() => 'Allow Gmail sending first (Mail merge → Connect Gmail).';
}

/// Sends e-mail through your own Gmail account (gmail.send scope only).
class GmailService {
  GmailService(this.ref);
  final Ref ref;

  Future<String> send({required String to, String toName = '', required String subject, required String body}) async {
    final c = await ref.read(googleAuthProvider).gmailClient();
    if (c == null) throw GmailNotReady();
    try {
      final msg = await gmail.GmailApi(c).users.messages.send(
        gmail.Message(
          raw: gmailRaw(to: to, toName: toName, subject: subject, body: body),
        ),
        'me',
      );
      final day = ref.read(todayProvider);
      await ref.read(targetsRepoProvider).bumpAuto('emails', day, 1);
      return msg.id ?? '';
    } finally {
      c.close();
    }
  }

  /// Number of mail-merge e-mails sent today (for the daily limit).
  Future<int> sentToday() async {
    final db = ref.read(dbProvider);
    final clock = ref.read(clockProvider);
    final start = clock.dayStartUtc(clock.today());
    final c = db.mailSends.id.count();
    final r =
        await (db.selectOnly(db.mailSends)
              ..addColumns([c])
              ..where(db.mailSends.status.equals('sent') & db.mailSends.sentAtUtc.isBiggerOrEqualValue(start)))
            .getSingle();
    return r.read(c) ?? 0;
  }
}

final gmailServiceProvider = Provider((ref) => GmailService(ref));
