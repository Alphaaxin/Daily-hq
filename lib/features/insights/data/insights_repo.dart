import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/db/app_db.dart';
import '../../../core/providers.dart';
import '../../../core/time/day_clock.dart';
import '../../focus/domain/focus_logic.dart';
import '../../gamification/data/xp_repo.dart';
import '../../sleep/data/sleep_repo.dart';
import '../../sleep/domain/sleep_logic.dart';

/// Totals over a date range, used by the weekly review and monthly report.
class PeriodStats {
  PeriodStats(this.from, this.to);
  final String from;
  final String to;
  int xp = 0;
  int activeDays = 0;
  int tasksDone = 0;
  int buildDays = 0;
  int buildMinutes = 0;
  int leads = 0;
  int closed = 0;
  int emails = 0;
  int meetings = 0;
  int callsDone = 0;
  int spentPaise = 0;
  int investedPaise = 0;
  int receivedPaise = 0;
  int waterGoalDays = 0;
  int salahFullDays = 0;
  int pomodoros = 0;
  double? avgSleepMin;
  double? avgMood;
  int? avgScore;
  final Map<int?, int> workSecondsByProfile = {};
  final Map<int?, (int leads, int closed, int emails)> salesByProfile = {};
  final Map<String, int> scoreByDay = {};
  final Map<String, int> moodByDay = {};
  final Map<String, int> sleepByDay = {};
  final Map<String, int> spentByDay = {};
  final Map<String, int> habitDays = {};
}

class InsightsRepo {
  InsightsRepo(this.ref);
  final Ref ref;
  AppDb get db => ref.read(dbProvider);

  Future<PeriodStats> stats(String from, String to) async {
    final s = PeriodStats(from, to);
    final clock = ref.read(clockProvider);
    final fromUtc = clock.dayStartUtc(from), toUtc = clock.dayEndUtc(to);
    final xp = await (db.select(db.xpEntries)..where((x) => x.day.isBetweenValues(from, to))).get();
    final perDay = <String, int>{};
    for (final e in xp) {
      perDay[e.day] = (perDay[e.day] ?? 0) + e.amount;
      if (e.source == 'water:goal') s.waterGoalDays++;
    }
    s.xp = perDay.values.fold(0, (a, b) => a + b);
    s.activeDays = perDay.values.where((v) => v > 0).length;
    s.tasksDone = (await (db.select(db.tasks)..where((t) => t.doneDay.isBetweenValues(from, to))).get()).length;
    final focus = await (db.select(
      db.focusSessions,
    )..where((f) => f.day.isBetweenValues(from, to) & f.endUtc.isNotNull())).get();
    final build = <String, int>{};
    for (final f in focus) {
      final k = FocusKindX.parse(f.kind);
      if (k == FocusKind.build) build[f.day] = (build[f.day] ?? 0) + f.seconds;
      if (k == FocusKind.pomodoro && f.seconds >= 20 * 60) s.pomodoros++;
      if (k == FocusKind.work || k == FocusKind.manual || k == FocusKind.pomodoro) {
        s.workSecondsByProfile[f.profileId] = (s.workSecondsByProfile[f.profileId] ?? 0) + f.seconds;
      }
    }
    s.buildDays = build.values.where((v) => v >= 3600).length;
    s.buildMinutes = build.values.fold(0, (a, b) => a + b) ~/ 60;
    final leads = await (db.select(db.leads)..where((l) => l.day.isBetweenValues(from, to))).get();
    s.leads = leads.length;
    final closed = await (db.select(
      db.leads,
    )..where((l) => l.stage.equals('closed') & l.updatedAtUtc.isBetweenValues(fromUtc, toUtc))).get();
    s.closed = closed.length;
    final sent = await (db.select(
      db.mailSends,
    )..where((m) => m.status.equals('sent') & m.sentAtUtc.isBetweenValues(fromUtc, toUtc))).get();
    s.emails = sent.length;
    final leadProfile = {for (final l in await db.select(db.leads).get()) l.id: l.profileId};
    void sales(int? p, {int l = 0, int c = 0, int e = 0}) {
      final cur = s.salesByProfile[p] ?? (0, 0, 0);
      s.salesByProfile[p] = (cur.$1 + l, cur.$2 + c, cur.$3 + e);
    }

    for (final l in leads) {
      sales(l.profileId, l: 1);
    }
    for (final l in closed) {
      sales(l.profileId, c: 1);
    }
    for (final m in sent) {
      sales(m.leadId == null ? null : leadProfile[m.leadId], e: 1);
    }
    s.meetings = (await (db.select(
      db.meetings,
    )..where((m) => m.startedAtUtc.isBetweenValues(fromUtc, toUtc))).get()).length;
    s.callsDone = (await (db.select(
      db.followUps,
    )..where((f) => f.channel.equals('call') & f.doneAtUtc.isBetweenValues(fromUtc, toUtc))).get()).length;
    for (final m in await (db.select(db.moneyEntries)..where((m) => m.day.isBetweenValues(from, to))).get()) {
      switch (m.type) {
        case 'spent':
          s.spentPaise += m.amountPaise;
          s.spentByDay[m.day] = (s.spentByDay[m.day] ?? 0) + m.amountPaise;
        case 'invested':
          s.investedPaise += m.amountPaise;
        default:
          s.receivedPaise += m.amountPaise;
      }
    }
    final salah = await (db.select(db.salahLogs)..where((x) => x.prayerDate.isBetweenValues(from, to))).get();
    final sd = <String, int>{};
    for (final x in salah) {
      sd[x.prayerDate] = (sd[x.prayerDate] ?? 0) + 1;
    }
    s.salahFullDays = sd.values.where((v) => v >= 5).length;
    final moods = await (db.select(db.moodLogs)..where((m) => m.day.isBetweenValues(from, to))).get();
    for (final m in moods) {
      s.moodByDay[m.day] = m.mood;
    }
    if (moods.isNotEmpty) s.avgMood = moods.map((m) => m.mood).reduce((a, b) => a + b) / moods.length;
    final sleeps = await (db.select(db.sleepSessions)..where((x) => x.wokeAtUtc.isBetweenValues(fromUtc, toUtc))).get();
    for (final x in sleeps) {
      s.sleepByDay[sleepCreditDay(clock, x.span)] = x.span.duration!.inMinutes;
    }
    if (s.sleepByDay.isNotEmpty) s.avgSleepMin = s.sleepByDay.values.reduce((a, b) => a + b) / s.sleepByDay.length;
    for (final d in await (db.select(db.dayScores)..where((x) => x.day.isBetweenValues(from, to))).get()) {
      s.scoreByDay[d.day] = d.score;
    }
    if (s.scoreByDay.isNotEmpty) {
      s.avgScore = (s.scoreByDay.values.reduce((a, b) => a + b) / s.scoreByDay.length).round();
    }
    final habits = {for (final h in await db.select(db.habits).get()) h.id: h.name};
    for (final h in await (db.select(db.habitLogs)..where((x) => x.day.isBetweenValues(from, to))).get()) {
      final n = habits[h.habitId] ?? '?';
      s.habitDays[n] = (s.habitDays[n] ?? 0) + 1;
    }
    return s;
  }

  // Reviews ------------------------------------------------------------------
  Future<Review?> review(String kind, String period) =>
      (db.select(db.reviews)..where((r) => r.kind.equals(kind) & r.period.equals(period))).getSingleOrNull();

  Future<void> saveReview(String kind, String period, String worked, String didnt, String focus, String day) async {
    final cur = await review(kind, period);
    final c = ReviewsCompanion(
      kind: Value(kind),
      period: Value(period),
      worked: Value(worked),
      didnt: Value(didnt),
      focus: Value(focus),
      createdAtUtc: Value(DateTime.now().toUtc()),
    );
    if (cur == null) {
      await db.into(db.reviews).insert(c);
    } else {
      await (db.update(db.reviews)..where((r) => r.id.equals(cur.id))).write(c);
    }
    await ref.read(xpRepoProvider).set(day, 'review:$kind:$period', kind == 'weekly' ? 30 : 50);
  }

  // Learning -----------------------------------------------------------------
  Stream<List<LearningItem>> watchLearning() =>
      (db.select(db.learningItems)
            ..where((l) => l.archived.equals(false))
            ..orderBy([(l) => OrderingTerm.asc(l.id)]))
          .watch();

  Future<void> saveLearning({
    int? id,
    required String title,
    required String kind,
    required int total,
    required String unit,
  }) async {
    final c = LearningItemsCompanion(
      title: Value(title.trim()),
      kind: Value(kind),
      total: Value(total),
      unit: Value(unit),
    );
    if (id == null) {
      await db.into(db.learningItems).insert(c);
    } else {
      await (db.update(db.learningItems)..where((l) => l.id.equals(id))).write(c);
    }
  }

  Future<void> stepLearning(LearningItem l, int delta, String day) async {
    final done = (l.done + delta).clamp(0, l.total);
    await (db.update(
      db.learningItems,
    )..where((x) => x.id.equals(l.id))).write(LearningItemsCompanion(done: Value(done)));
    if (delta > 0) await ref.read(xpRepoProvider).set(day, 'learn:${l.id}', 5);
  }

  Future<void> archiveLearning(int id) => (db.update(
    db.learningItems,
  )..where((l) => l.id.equals(id))).write(const LearningItemsCompanion(archived: Value(true)));

  /// Focus seconds logged against each learning item.
  Stream<Map<int, int>> watchLearningTime() =>
      (db.select(db.focusSessions)..where((f) => f.learningId.isNotNull())).watch().map((l) {
        final m = <int, int>{};
        for (final f in l) {
          m[f.learningId!] = (m[f.learningId!] ?? 0) + f.seconds;
        }
        return m;
      });

  // Screen-time limits ---------------------------------------------------------
  Stream<List<AppLimit>> watchLimits() => db.select(db.appLimits).watch();
  Future<List<AppLimit>> limits() => db.select(db.appLimits).get();

  Future<void> setLimit(String pkg, String label, int? minutes) async {
    if (minutes == null) {
      await (db.delete(db.appLimits)..where((a) => a.packageName.equals(pkg))).go();
    } else {
      await db
          .into(db.appLimits)
          .insertOnConflictUpdate(AppLimitsCompanion.insert(packageName: pkg, label: label, minutes: minutes));
    }
  }

  // Nudge log ------------------------------------------------------------------
  Future<Set<String>> sentNudges() async => {for (final n in await db.select(db.nudgeLog).get()) n.key};
  Future<void> markNudge(String key) =>
      db.into(db.nudgeLog).insertOnConflictUpdate(NudgeLogCompanion.insert(key: key, atUtc: DateTime.now().toUtc()));
}

final insightsRepoProvider = Provider((ref) => InsightsRepo(ref));

final periodStatsProvider = FutureProvider.family<PeriodStats, (String, String)>((ref, r) {
  ref.watch(xpTotalProvider);
  return ref.read(insightsRepoProvider).stats(r.$1, r.$2);
});

final learningProvider = StreamProvider<List<LearningItem>>((ref) => ref.watch(insightsRepoProvider).watchLearning());
final learningTimeProvider = StreamProvider<Map<int, int>>(
  (ref) => ref.watch(insightsRepoProvider).watchLearningTime(),
);
final appLimitsProvider = StreamProvider<List<AppLimit>>((ref) => ref.watch(insightsRepoProvider).watchLimits());

String monthStart(String day) => '${day.substring(0, 7)}-01';
String monthEnd(String day) {
  final d = DayKey.toDate(day);
  return DayKey.fromDate(DateTime.utc(d.year, d.month + 1, 0));
}
