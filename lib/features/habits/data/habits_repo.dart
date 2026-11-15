import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/db/app_db.dart';
import '../../../core/providers.dart';
import '../../gamification/data/xp_repo.dart';
import '../../gamification/domain/streaks.dart';
import '../../gamification/domain/xp_rules.dart';

class HabitsRepo {
  HabitsRepo(this.db, this.xp);
  final AppDb db;
  final XpRepo xp;

  Stream<List<Habit>> watch() =>
      (db.select(db.habits)
            ..where((t) => t.archived.equals(false))
            ..orderBy([(t) => OrderingTerm.asc(t.sort), (t) => OrderingTerm.asc(t.id)]))
          .watch();

  Stream<Set<int>> watchDone(String day) =>
      (db.select(db.habitLogs)..where((t) => t.day.equals(day))).watch().map((l) => {for (final x in l) x.habitId});

  /// habitId -> set of days it was done.
  Stream<Map<int, Set<String>>> watchHistory() => db.select(db.habitLogs).watch().map((l) {
    final m = <int, Set<String>>{};
    for (final x in l) {
      (m[x.habitId] ??= {}).add(x.day);
    }
    return m;
  });

  /// Returns true when this tick completed the whole set.
  Future<bool> toggle(int habitId, String day) async {
    final q = db.select(db.habitLogs)..where((t) => t.habitId.equals(habitId) & t.day.equals(day));
    final existing = await q.getSingleOrNull();
    if (existing != null) {
      await (db.delete(db.habitLogs)..where((t) => t.habitId.equals(habitId) & t.day.equals(day))).go();
      await xp.set(day, Xp.habitKey(habitId), 0);
    } else {
      await db
          .into(db.habitLogs)
          .insert(HabitLogsCompanion.insert(habitId: habitId, day: day, atUtc: DateTime.now().toUtc()));
      await xp.set(day, Xp.habitKey(habitId), Xp.habit);
    }
    final active = await (db.select(db.habits)..where((t) => t.archived.equals(false))).get();
    final done = await (db.select(db.habitLogs)..where((t) => t.day.equals(day))).get();
    final ids = {for (final d in done) d.habitId};
    final all = active.isNotEmpty && active.every((h) => ids.contains(h.id));
    await xp.set(day, Xp.allHabitsKey, all ? Xp.allHabitsBonus : 0);
    return all && existing == null;
  }

  Future<void> add(String name) async {
    final n = await db.select(db.habits).get();
    await db.into(db.habits).insert(HabitsCompanion.insert(name: name.trim(), sort: Value(n.length)));
  }

  Future<void> rename(int id, String name) =>
      (db.update(db.habits)..where((t) => t.id.equals(id))).write(HabitsCompanion(name: Value(name.trim())));

  Future<void> archive(int id) =>
      (db.update(db.habits)..where((t) => t.id.equals(id))).write(const HabitsCompanion(archived: Value(true)));
}

final habitsRepoProvider = Provider((ref) => HabitsRepo(ref.watch(dbProvider), ref.watch(xpRepoProvider)));
final habitsProvider = StreamProvider<List<Habit>>((ref) => ref.watch(habitsRepoProvider).watch());
final habitsDoneTodayProvider = StreamProvider<Set<int>>(
  (ref) => ref.watch(habitsRepoProvider).watchDone(ref.watch(todayProvider)),
);
final habitHistoryProvider = StreamProvider<Map<int, Set<String>>>(
  (ref) => ref.watch(habitsRepoProvider).watchHistory(),
);

final habitStreaksProvider = Provider<Map<int, int>>((ref) {
  final h = ref.watch(habitHistoryProvider).value ?? const {};
  final today = ref.watch(todayProvider);
  return {for (final e in h.entries) e.key: currentStreak(e.value, today)};
});
