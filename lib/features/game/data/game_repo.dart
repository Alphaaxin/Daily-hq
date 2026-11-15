import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/db/app_db.dart';
import '../../../core/providers.dart';
import '../../../core/time/day_clock.dart';
import '../../focus/domain/focus_logic.dart';
import '../../gamification/data/xp_repo.dart';
import '../../gamification/domain/levels.dart';
import '../../gamification/domain/streaks.dart';
import '../domain/game_logic.dart';

class BossView {
  const BossView(this.boss, this.progress, this.claimed, this.weekStart);
  final BossesData boss;
  final int progress;
  final bool claimed;
  final String weekStart;
  bool get beaten => progress >= boss.goal;
}

class GameRepo {
  GameRepo(this.db, this.xp);
  final AppDb db;
  final XpRepo xp;

  // Quests -------------------------------------------------------------------
  Stream<List<Quest>> watchPool() =>
      (db.select(db.quests)
            ..where((q) => q.archived.equals(false))
            ..orderBy([(q) => OrderingTerm.asc(q.id)]))
          .watch();

  /// Makes sure today's 3 quests exist, then returns them with done flags.
  Future<void> ensureToday(String day) async {
    final have = await (db.select(db.dailyQuests)..where((d) => d.day.equals(day))).get();
    if (have.isNotEmpty) return;
    final pool = await (db.select(db.quests)..where((q) => q.archived.equals(false))).get();
    final pick = pickDailyQuests(pool.map((q) => q.id).toList(), day);
    await db.batch((b) {
      for (final id in pick) {
        b.insert(
          db.dailyQuests,
          DailyQuestsCompanion.insert(day: day, questId: id),
          mode: InsertMode.insertOrIgnore,
        );
      }
    });
  }

  Stream<List<(Quest, bool)>> watchToday(String day) {
    final q = db.select(db.dailyQuests).join([innerJoin(db.quests, db.quests.id.equalsExp(db.dailyQuests.questId))])
      ..where(db.dailyQuests.day.equals(day));
    return q.watch().map((rows) => [for (final r in rows) (r.readTable(db.quests), r.readTable(db.dailyQuests).done)]);
  }

  Future<void> toggleQuest(String day, Quest q, bool done) async {
    await (db.update(
      db.dailyQuests,
    )..where((d) => d.day.equals(day) & d.questId.equals(q.id))).write(DailyQuestsCompanion(done: Value(done)));
    await xp.set(day, 'quest:${q.id}', done ? q.xp : 0);
  }

  /// Swap one of today's quests for another from the pool (once per quest).
  Future<void> reroll(String day, Quest q) async {
    final today = await (db.select(db.dailyQuests)..where((d) => d.day.equals(day))).get();
    final used = {for (final t in today) t.questId};
    final pool = (await (db.select(
      db.quests,
    )..where((x) => x.archived.equals(false))).get()).where((x) => !used.contains(x.id)).toList();
    if (pool.isEmpty) return;
    final next = pool[daySeed('reroll:$day:${q.id}') % pool.length];
    await (db.delete(db.dailyQuests)..where((d) => d.day.equals(day) & d.questId.equals(q.id))).go();
    await db.into(db.dailyQuests).insert(DailyQuestsCompanion.insert(day: day, questId: next.id));
  }

  Future<void> addQuest(String title, int xpAmount) =>
      db.into(db.quests).insert(QuestsCompanion.insert(title: title.trim(), xp: Value(xpAmount)));

  Future<void> archiveQuest(int id) =>
      (db.update(db.quests)..where((q) => q.id.equals(id))).write(const QuestsCompanion(archived: Value(true)));

  // Weekly boss ---------------------------------------------------------------
  Future<BossesData?> bossFor(String weekStart) async {
    final cur = await (db.select(db.weekBosses)..where((w) => w.weekStart.equals(weekStart))).getSingleOrNull();
    if (cur != null) return (db.select(db.bosses)..where((b) => b.id.equals(cur.bossId))).getSingleOrNull();
    final pool = await (db.select(db.bosses)..where((b) => b.archived.equals(false))).get();
    final id = pickBoss(pool.map((b) => b.id).toList(), weekStart);
    if (id == null) return null;
    await db
        .into(db.weekBosses)
        .insert(
          WeekBossesCompanion.insert(weekStart: weekStart, bossId: id),
          mode: InsertMode.insertOrIgnore,
        );
    return pool.firstWhere((b) => b.id == id);
  }

  /// Live progress for a boss metric during [weekStart]…+6.
  Future<int> bossProgress(BossesData b, String weekStart, int waterGoal) async {
    final end = DayKey.add(weekStart, 6);
    switch (b.metric) {
      case 'buildHours':
        final s = await (db.select(
          db.focusSessions,
        )..where((f) => f.kind.equals('build') & f.day.isBetweenValues(weekStart, end) & f.endUtc.isNotNull())).get();
        final perDay = <String, int>{};
        for (final x in s) {
          perDay[x.day] = (perDay[x.day] ?? 0) + x.seconds;
        }
        return perDay.values.where((v) => v >= 3600).length;
      case 'leads':
        return (await (db.select(db.leads)..where((l) => l.day.isBetweenValues(weekStart, end))).get()).length;
      case 'emails':
        final from = DayKey.toDate(weekStart), to = DayKey.toDate(DayKey.add(weekStart, 7));
        return (await (db.select(
          db.mailSends,
        )..where((m) => m.status.equals('sent') & m.sentAtUtc.isBetweenValues(from, to))).get()).length;
      case 'pomodoros':
        final s = await (db.select(
          db.focusSessions,
        )..where((f) => f.kind.equals(FocusKind.pomodoro.name) & f.day.isBetweenValues(weekStart, end))).get();
        return s.where((x) => x.seconds >= 20 * 60).length;
      case 'waterDays':
        final logs = await (db.select(db.waterLogs)..where((w) => w.day.isBetweenValues(weekStart, end))).get();
        final perDay = <String, int>{};
        for (final w in logs) {
          perDay[w.day] = (perDay[w.day] ?? 0) + 1;
        }
        return perDay.values.where((v) => v >= waterGoal).length;
      case 'salahDays':
        final logs = await (db.select(db.salahLogs)..where((s) => s.prayerDate.isBetweenValues(weekStart, end))).get();
        final perDay = <String, int>{};
        for (final s in logs) {
          perDay[s.prayerDate] = (perDay[s.prayerDate] ?? 0) + 1;
        }
        return perDay.values.where((v) => v >= 5).length;
      case 'tasks':
        return (await (db.select(db.tasks)..where((t) => t.doneDay.isBetweenValues(weekStart, end))).get()).length;
    }
    return 0;
  }

  Future<bool> claimBoss(BossView v, String day) async {
    if (!v.beaten || v.claimed) return false;
    await (db.update(
      db.weekBosses,
    )..where((w) => w.weekStart.equals(v.weekStart))).write(const WeekBossesCompanion(claimed: Value(true)));
    await xp.set(day, 'boss:${v.weekStart}', v.boss.xp);
    return true;
  }

  Future<bool> isClaimed(String weekStart) async =>
      (await (db.select(db.weekBosses)..where((w) => w.weekStart.equals(weekStart))).getSingleOrNull())?.claimed ??
      false;

  // Shields -------------------------------------------------------------------
  Stream<List<ShieldEvent>> watchShields() => db.select(db.shieldEvents).watch();

  /// Earns last week's shield and spends one on yesterday if needed.
  /// Safe to run any number of times (each event is recorded once).
  Future<String?> processShields(Set<String> activeDays, String today) async {
    final events = await db.select(db.shieldEvents).get();
    final earned = {
      for (final e in events)
        if (e.kind == 'earn') e.day,
    };
    final used = {
      for (final e in events)
        if (e.kind == 'use') e.day,
    };
    var balance = earned.length - used.length;
    // Check the last 4 finished weeks.
    final thisWeek = weekStart(today);
    for (var w = 1; w <= 4; w++) {
      final ws = DayKey.add(thisWeek, -7 * w);
      if (!earned.contains(ws) && balance < maxShields && weekEarnsShield(activeDays, ws)) {
        await db.into(db.shieldEvents).insert(ShieldEventsCompanion.insert(kind: 'earn', day: ws));
        earned.add(ws);
        balance++;
      }
    }
    final need = dayNeedingShield(activeDays, used, today);
    if (need != null && balance > 0) {
      await db.into(db.shieldEvents).insert(ShieldEventsCompanion.insert(kind: 'use', day: need));
      return need;
    }
    return null;
  }

  // Day scores ----------------------------------------------------------------
  Future<void> saveScore(String day, int score) =>
      db.into(db.dayScores).insertOnConflictUpdate(DayScoresCompanion.insert(day: day, score: score));

  Stream<Map<String, int>> watchScores(String from, String to) => (db.select(
    db.dayScores,
  )..where((d) => d.day.isBetweenValues(from, to))).watch().map((l) => {for (final d in l) d.day: d.score});

  // Badges --------------------------------------------------------------------
  Future<Set<String>> badges({required Set<String> activeDays, required int totalXp}) async {
    final build = await db.select(db.focusSessions).get();
    final perDay = <String, int>{};
    for (final f in build.where((f) => f.kind == 'build')) {
      perDay[f.day] = (perDay[f.day] ?? 0) + f.seconds;
    }
    final salah = await db.select(db.salahLogs).get();
    final sd = <String, int>{};
    for (final s in salah) {
      sd[s.prayerDate] = (sd[s.prayerDate] ?? 0) + 1;
    }
    final water = await db.select(db.xpEntries).get();
    return earnedBadges(
      bestStreak: bestStreak(activeDays),
      level: levelFor(totalXp).level,
      buildHours: perDay.values.where((v) => v >= 3600).length,
      leads: (await db.select(db.leads).get()).length,
      closed: (await (db.select(db.leads)..where((l) => l.stage.equals('closed'))).get()).length,
      emails: (await (db.select(db.mailSends)..where((m) => m.status.equals('sent'))).get()).length,
      meetings: (await (db.select(db.meetings)..where((m) => m.status.equals('done'))).get()).length,
      salahFullDays: sd.values.where((v) => v >= 5).length,
      waterDays: water.where((x) => x.source == 'water:goal').length,
      monthUnderBudget: false,
    );
  }
}

final gameRepoProvider = Provider((ref) => GameRepo(ref.watch(dbProvider), ref.watch(xpRepoProvider)));

final todayQuestsProvider = StreamProvider<List<(Quest, bool)>>((ref) {
  final day = ref.watch(todayProvider);
  final repo = ref.watch(gameRepoProvider);
  return Stream.fromFuture(repo.ensureToday(day)).asyncExpand((_) => repo.watchToday(day));
});

final questPoolProvider = StreamProvider<List<Quest>>((ref) => ref.watch(gameRepoProvider).watchPool());

final bossProvider = FutureProvider<BossView?>((ref) async {
  final today = ref.watch(todayProvider);
  ref.watch(xpTodayProvider); // refresh as you make progress
  final repo = ref.watch(gameRepoProvider);
  final ws = weekStart(today);
  final b = await repo.bossFor(ws);
  if (b == null) return null;
  return BossView(
    b,
    await repo.bossProgress(b, ws, ref.read(settingsProvider).waterGoal),
    await repo.isClaimed(ws),
    ws,
  );
});

final shieldEventsProvider = StreamProvider<List<ShieldEvent>>((ref) => ref.watch(gameRepoProvider).watchShields());

final shieldBalanceProvider = Provider<int>((ref) {
  final e = ref.watch(shieldEventsProvider).value ?? const <ShieldEvent>[];
  return e.where((x) => x.kind == 'earn').length - e.where((x) => x.kind == 'use').length;
});

final shieldedDaysProvider = Provider<Set<String>>(
  (ref) => {
    for (final e in ref.watch(shieldEventsProvider).value ?? const <ShieldEvent>[])
      if (e.kind == 'use') e.day,
  },
);

/// Overall streak including shielded days.
final shieldedStreakProvider = Provider<int>(
  (ref) => streakWithShields(
    ref.watch(activeDaysProvider).value ?? const {},
    ref.watch(shieldedDaysProvider),
    ref.watch(todayProvider),
  ),
);

final plantProvider = Provider<PlantState>(
  (ref) => plantState(ref.watch(activeDaysProvider).value ?? const {}, ref.watch(todayProvider)),
);
