import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/db/app_db.dart';
import '../../../core/providers.dart';
import '../../gamification/data/xp_repo.dart';

enum Routine { morning, evening }

class RoutinesRepo {
  RoutinesRepo(this.db, this.xp);
  final AppDb db;
  final XpRepo xp;

  static const eveningKey = 'routine:evening';
  static const eveningXp = 10;
  static const morningKey = 'routine:morning';
  static const morningXp = 10;

  Stream<List<RoutineItem>> watchItems(Routine r) =>
      (db.select(db.routineItems)
            ..where((t) => t.routine.equals(r.name) & t.archived.equals(false))
            ..orderBy([(t) => OrderingTerm.asc(t.sort), (t) => OrderingTerm.asc(t.id)]))
          .watch();

  Stream<Set<int>> watchDone(String day) =>
      (db.select(db.routineLogs)..where((t) => t.day.equals(day))).watch().map((l) => {for (final x in l) x.itemId});

  /// Ticks an item. Returns true when this completed the morning routine.
  Future<bool> toggle(RoutineItem item, String day) async {
    final q = db.select(db.routineLogs)..where((t) => t.itemId.equals(item.id) & t.day.equals(day));
    final had = await q.getSingleOrNull() != null;
    if (had) {
      await (db.delete(db.routineLogs)..where((t) => t.itemId.equals(item.id) & t.day.equals(day))).go();
    } else {
      await db.into(db.routineLogs).insert(RoutineLogsCompanion.insert(itemId: item.id, day: day));
    }
    if (item.routine != Routine.morning.name) return false;
    final done = await xp.morningDone(day);
    await xp.set(day, morningKey, done ? morningXp : 0);
    await xp.refreshMultiplier(day);
    return done && !had;
  }

  Stream<String?> watchGratitude(String day) =>
      (db.select(db.gratitude)..where((t) => t.day.equals(day))).watchSingleOrNull().map((g) => g?.line);

  /// Finishes the evening shutdown: saves gratitude and awards XP.
  Future<void> finishEvening(String day, String gratitude) async {
    if (gratitude.trim().isNotEmpty) {
      await db.into(db.gratitude).insertOnConflictUpdate(GratitudeCompanion.insert(day: day, line: gratitude.trim()));
    }
    await xp.set(day, eveningKey, eveningXp);
  }

  Stream<bool> watchEveningDone(String day) => (db.select(
    db.xpEntries,
  )..where((t) => t.day.equals(day) & t.source.equals(eveningKey))).watchSingleOrNull().map((e) => e != null);

  Future<void> add(Routine r, String name) async {
    final n = await db.select(db.routineItems).get();
    await db
        .into(db.routineItems)
        .insert(RoutineItemsCompanion.insert(routine: r.name, name: name.trim(), sort: Value(n.length)));
  }

  Future<void> rename(int id, String name) => (db.update(
    db.routineItems,
  )..where((t) => t.id.equals(id))).write(RoutineItemsCompanion(name: Value(name.trim())));

  Future<void> archive(int id) => (db.update(
    db.routineItems,
  )..where((t) => t.id.equals(id))).write(const RoutineItemsCompanion(archived: Value(true)));
}

final routinesRepoProvider = Provider((ref) => RoutinesRepo(ref.watch(dbProvider), ref.watch(xpRepoProvider)));
final morningItemsProvider = StreamProvider((ref) => ref.watch(routinesRepoProvider).watchItems(Routine.morning));
final eveningItemsProvider = StreamProvider((ref) => ref.watch(routinesRepoProvider).watchItems(Routine.evening));
final routineDoneTodayProvider = StreamProvider<Set<int>>(
  (ref) => ref.watch(routinesRepoProvider).watchDone(ref.watch(todayProvider)),
);
final eveningDoneTodayProvider = StreamProvider<bool>(
  (ref) => ref.watch(routinesRepoProvider).watchEveningDone(ref.watch(todayProvider)),
);
final gratitudeTodayProvider = StreamProvider<String?>(
  (ref) => ref.watch(routinesRepoProvider).watchGratitude(ref.watch(todayProvider)),
);

final morningCompleteProvider = Provider<bool>((ref) {
  final items = ref.watch(morningItemsProvider).value ?? const <RoutineItem>[];
  final done = ref.watch(routineDoneTodayProvider).value ?? const <int>{};
  return items.isNotEmpty && items.every((i) => done.contains(i.id));
});
