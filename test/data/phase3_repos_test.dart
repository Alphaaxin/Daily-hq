import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nizam/core/db/app_db.dart';
import 'package:nizam/core/db/open_db.dart';
import 'package:nizam/core/providers.dart';
import 'package:nizam/core/time/day_clock.dart';
import 'package:nizam/features/gamification/data/xp_repo.dart';
import 'package:nizam/features/mail/data/mail_sender.dart';
import 'package:nizam/features/notes/data/notes_repo.dart';
import 'package:nizam/features/people/data/contacts_repo.dart';
import 'package:nizam/features/targets/data/targets_repo.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

void main() {
  tzdata.initializeTimeZones();
  quietDriftWarnings();
  final loc = tz.getLocation('Asia/Kolkata');
  DateTime ist(int d, int h, int m) =>
      DateTime.fromMillisecondsSinceEpoch(tz.TZDateTime(loc, 2026, 11, d, h, m).millisecondsSinceEpoch, isUtc: true);
  final now = ist(15, 14, 0);
  DayClock clock() => DayClock(location: loc, now: () => now);
  const day = '2026-11-15';

  late AppDb db;
  late XpRepo xp;
  setUp(() {
    db = openMemoryDb();
    xp = XpRepo(db);
  });
  tearDown(() => db.close());

  group('notes', () {
    test('product ideas mirror into Build Hour ideas; search; +5 XP once', () async {
      final repo = NotesRepo(db, xp);
      final id = await repo.save(
        title: 'AI cold-email writer',
        body: 'Problem: SMBs…',
        template: 'Product idea',
        tags: '#ai, smb',
        day: day,
      );
      final n = (await repo.byId(id))!;
      expect(n.tags, 'ai,smb');
      expect(n.ideaId, isNotNull);
      final ideas = await db.select(db.ideas).get();
      expect(ideas.single.title, 'AI cold-email writer');
      await repo.save(id: id, title: 'AI cold-email bot', body: n.body, template: 'Product idea', day: day);
      expect((await db.select(db.ideas).get()).single.title, 'AI cold-email bot', reason: 'renamed, not duplicated');
      await repo.save(title: 'Chai stall research', body: 'Footfall near Charminar', template: 'Research', day: day);
      expect((await repo.watch(query: 'charminar').first).single.title, 'Chai stall research');
      expect((await repo.watch(query: 'SMB').first), hasLength(1), reason: 'tags and body are searched');
      expect(await xp.watchDay(day).first, 5);
    });
  });

  group('leads & follow-ups', () {
    test('new lead: +5 XP and counts towards the leads target; archive undoes both', () async {
      final targets = TargetsRepo(db, xp);
      final repo = ContactsRepo(db, xp, targets);
      final id = await repo.saveLead(name: 'Chai Point', business: 'Chai Point', clock: clock());
      final leadTarget = (await targets.watch().first).firstWhere((t) => t.autoSource == 'leads');
      expect((await targets.watchDay(day).first)[leadTarget.id], 1);
      expect(await xp.watchDay(day).first, 5);
      final l = (await repo.lead(id))!;
      await repo.archiveLead(l);
      expect((await targets.watchDay(day).first)[leadTarget.id], 0);
      expect(await xp.watchDay(day).first, 0);
    });

    test('a reply closes "no reply" reminders; closing a deal gives +50', () async {
      final repo = ContactsRepo(db, xp, TargetsRepo(db, xp));
      final id = await repo.saveLead(name: 'Glow Salon', clock: clock());
      await repo.addFollowUp(leadId: id, dueAtUtc: ist(18, 17, 0), note: 'No reply?', origin: 'mail');
      await repo.addFollowUp(leadId: id, dueAtUtc: ist(19, 17, 0), note: 'Call about pricing');
      var l = (await repo.lead(id))!;
      await repo.setStage(l, 'replied', clock());
      final open = await repo.openFollowUps();
      expect(open.single.note, 'Call about pricing');
      l = (await repo.lead(id))!;
      await repo.setStage(l, 'closed', clock());
      expect(await xp.watchDay(day).first, 5 + 50);
    });

    test('next birthday handles year wrap and 29 Feb', () {
      expect(nextBirthday('03-21', '2026-11-15'), '2027-03-21');
      expect(nextBirthday('1999-12-01', '2026-11-15'), '2026-12-01');
      expect(nextBirthday('11-15', '2026-11-15'), '2026-11-15');
      expect(nextBirthday('02-29', '2026-11-15'), '2027-02-28');
      expect(nextBirthday('02-29', '2027-11-15'), '2028-02-29');
      expect(nextBirthday(null, '2026-11-15'), isNull);
    });
  });

  test('mail merge: queue renders each e-mail, skips bad addresses, cancel works', () async {
    final c = ProviderContainer(
      overrides: [dbProvider.overrideWithValue(db), nowFnProvider.overrideWithValue(() => now)],
    );
    addTearDown(c.dispose);
    final sender = c.read(mailSenderProvider);
    final n = await sender.queue(
      campaign: 'Intro',
      subject: 'Quick idea for {{business}}',
      body: 'Hi {{name|there}},',
      to: const [
        Recipient(email: 'rahul@chai.in', name: 'Rahul Sharma', vars: {'business': 'Chai Point'}),
        Recipient(email: 'bad-address', name: 'Nope'),
        Recipient(email: 'hi@glow.in', vars: {'business': 'Glow'}),
      ],
      atUtc: now.add(const Duration(days: 1)),
    );
    expect(n, 2);
    final rows = await db.select(db.mailSends).get();
    expect(rows.map((r) => r.subject), ['Quick idea for Chai Point', 'Quick idea for Glow']);
    expect(rows.map((r) => r.body), ['Hi Rahul,', 'Hi there,']);
    await sender.cancel('Intro');
    expect((await db.select(db.mailSends).get()).every((r) => r.status == 'cancelled'), isTrue);
  });
}
