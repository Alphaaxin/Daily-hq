import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/db/app_db.dart';
import '../../../core/providers.dart';
import '../../../core/time/day_clock.dart';
import '../../gamification/data/xp_repo.dart';
import '../../targets/data/targets_repo.dart';

const leadStages = ['new', 'contacted', 'replied', 'interested', 'closed', 'lost'];
const leadStageLabels = {
  'new': 'New',
  'contacted': 'Contacted',
  'replied': 'Replied',
  'interested': 'Interested',
  'closed': 'Closed',
  'lost': 'Lost',
};

/// Next birthday (local date) on or after [today] for "MM-DD" / "YYYY-MM-DD".
String? nextBirthday(String? birthday, String today) {
  if (birthday == null) return null;
  final m = RegExp(r'(\d{2})-(\d{2})$').firstMatch(birthday.trim());
  if (m == null) return null;
  final t = DayKey.toDate(today);
  var y = t.year;
  String key(int year) => DayKey.format(year, int.parse(m.group(1)!), int.parse(m.group(2)!));
  // 29 Feb in a non-leap year → 28 Feb.
  String safe(int year) {
    final mo = int.parse(m.group(1)!), d = int.parse(m.group(2)!);
    if (mo == 2 && d == 29 && DateTime.utc(year, 3, 1).subtract(const Duration(days: 1)).day == 28) {
      return DayKey.format(year, 2, 28);
    }
    return key(year);
  }

  var k = safe(y);
  if (k.compareTo(today) < 0) k = safe(++y);
  return k;
}

class ContactsRepo {
  ContactsRepo(this.db, this.xp, this.targets);
  final AppDb db;
  final XpRepo xp;
  final TargetsRepo targets;

  // People ------------------------------------------------------------------
  Stream<List<PeopleData>> watchPeople() => (db.select(db.people)
        ..where((p) => p.archived.equals(false))
        ..orderBy([(p) => OrderingTerm.asc(p.name)]))
      .watch();

  Future<PeopleData?> person(int id) => (db.select(db.people)..where((p) => p.id.equals(id))).getSingleOrNull();

  Future<List<PeopleData>> allPeople() => (db.select(db.people)..where((p) => p.archived.equals(false))).get();

  Future<int> savePerson({
    int? id,
    required String name,
    String phone = '',
    String email = '',
    String? birthday,
    String notes = '',
    int? profileId,
  }) async {
    final c = PeopleCompanion(
      name: Value(name.trim()),
      phone: Value(phone.trim()),
      email: Value(email.trim()),
      birthday: Value(birthday == null || birthday.trim().isEmpty ? null : birthday.trim()),
      notes: Value(notes),
      profileId: Value(profileId),
    );
    if (id == null) return db.into(db.people).insert(c.copyWith(createdAtUtc: Value(DateTime.now().toUtc())));
    await (db.update(db.people)..where((p) => p.id.equals(id))).write(c);
    return id;
  }

  Future<void> archivePerson(int id) =>
      (db.update(db.people)..where((p) => p.id.equals(id))).write(const PeopleCompanion(archived: Value(true)));

  // Leads -------------------------------------------------------------------
  Stream<List<Lead>> watchLeads() => (db.select(db.leads)
        ..where((l) => l.archived.equals(false))
        ..orderBy([(l) => OrderingTerm.desc(l.updatedAtUtc)]))
      .watch();

  Future<Lead?> lead(int id) => (db.select(db.leads)..where((l) => l.id.equals(id))).getSingleOrNull();

  Future<List<Lead>> allLeads() => (db.select(db.leads)..where((l) => l.archived.equals(false))).get();

  /// Adds or edits a lead. New leads give +5 XP and count towards lead targets.
  Future<int> saveLead({
    int? id,
    required String name,
    String business = '',
    String phone = '',
    String email = '',
    String location = '',
    String mapsUrl = '',
    String source = '',
    String notes = '',
    int? profileId,
    String? stage,
    required DayClock clock,
  }) async {
    final now = clock.nowUtc();
    final c = LeadsCompanion(
      name: Value(name.trim()),
      business: Value(business.trim()),
      phone: Value(phone.trim()),
      email: Value(email.trim()),
      location: Value(location.trim()),
      mapsUrl: Value(mapsUrl.trim()),
      source: Value(source.trim()),
      notes: Value(notes),
      profileId: Value(profileId),
      stage: stage == null ? const Value.absent() : Value(stage),
      updatedAtUtc: Value(now),
    );
    if (id != null) {
      await (db.update(db.leads)..where((l) => l.id.equals(id))).write(c);
      return id;
    }
    final day = clock.today();
    final newId = await db.into(db.leads).insert(c.copyWith(day: Value(day), createdAtUtc: Value(now)));
    await xp.set(day, 'lead:$newId', 5);
    await targets.bumpAuto('leads', day, 1);
    return newId;
  }

  Future<void> setStage(Lead l, String stage, DayClock clock) async {
    await (db.update(db.leads)..where((x) => x.id.equals(l.id)))
        .write(LeadsCompanion(stage: Value(stage), updatedAtUtc: Value(clock.nowUtc())));
    if (stage == 'closed' && l.stage != 'closed') await xp.set(clock.today(), 'lead:closed:${l.id}', 50);
    // A reply closes pending "no reply yet" reminders.
    if (stage != 'new' && stage != 'contacted') {
      await (db.update(db.followUps)..where((f) => f.leadId.equals(l.id) & f.origin.equals('mail') & f.doneAtUtc.isNull()))
          .write(FollowUpsCompanion(doneAtUtc: Value(clock.nowUtc())));
    }
  }

  Future<void> archiveLead(Lead l) async {
    await (db.update(db.leads)..where((x) => x.id.equals(l.id))).write(const LeadsCompanion(archived: Value(true)));
    await xp.set(l.day, 'lead:${l.id}', 0);
    await targets.bumpAuto('leads', l.day, -1);
  }

  // Follow-ups --------------------------------------------------------------
  Stream<List<FollowUp>> watchOpenFollowUps() => (db.select(db.followUps)
        ..where((f) => f.doneAtUtc.isNull())
        ..orderBy([(f) => OrderingTerm.asc(f.dueAtUtc)]))
      .watch();

  Future<List<FollowUp>> openFollowUps() => (db.select(db.followUps)..where((f) => f.doneAtUtc.isNull())).get();

  Future<int> addFollowUp({
    int? personId,
    int? leadId,
    required DateTime dueAtUtc,
    String note = '',
    String channel = 'any',
    String origin = 'manual',
  }) =>
      db.into(db.followUps).insert(FollowUpsCompanion.insert(
            personId: Value(personId),
            leadId: Value(leadId),
            dueAtUtc: dueAtUtc,
            note: Value(note),
            channel: Value(channel),
            origin: Value(origin),
          ));

  Future<void> completeFollowUp(int id, DayClock clock) async {
    await (db.update(db.followUps)..where((f) => f.id.equals(id))).write(FollowUpsCompanion(doneAtUtc: Value(clock.nowUtc())));
    await xp.set(clock.today(), 'followup:$id', 5);
  }

  Future<void> snoozeFollowUp(FollowUp f, Duration by) =>
      (db.update(db.followUps)..where((x) => x.id.equals(f.id))).write(FollowUpsCompanion(dueAtUtc: Value(f.dueAtUtc.add(by))));

  Future<void> deleteFollowUp(int id) => (db.delete(db.followUps)..where((f) => f.id.equals(id))).go();

  Future<FollowUp?> followUp(int id) => (db.select(db.followUps)..where((f) => f.id.equals(id))).getSingleOrNull();
}

final contactsRepoProvider = Provider(
  (ref) => ContactsRepo(ref.watch(dbProvider), ref.watch(xpRepoProvider), ref.watch(targetsRepoProvider)),
);
final peopleProvider = StreamProvider<List<PeopleData>>((ref) => ref.watch(contactsRepoProvider).watchPeople());
final leadsProvider = StreamProvider<List<Lead>>((ref) => ref.watch(contactsRepoProvider).watchLeads());
final followUpsProvider = StreamProvider<List<FollowUp>>((ref) => ref.watch(contactsRepoProvider).watchOpenFollowUps());

/// Upcoming birthdays within 30 days: (person, date, days away).
final upcomingBirthdaysProvider = Provider<List<(PeopleData, String, int)>>((ref) {
  final today = ref.watch(todayProvider);
  final out = <(PeopleData, String, int)>[];
  for (final p in ref.watch(peopleProvider).value ?? const <PeopleData>[]) {
    final n = nextBirthday(p.birthday, today);
    if (n == null) continue;
    final d = DayKey.diff(today, n);
    if (d <= 30) out.add((p, n, d));
  }
  out.sort((a, b) => a.$3.compareTo(b.$3));
  return out;
});
