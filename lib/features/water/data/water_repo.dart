import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/db/app_db.dart';
import '../../../core/providers.dart';
import '../../gamification/data/xp_repo.dart';
import '../../gamification/domain/xp_rules.dart';

class WaterRepo {
  WaterRepo(this.db, this.xp);
  final AppDb db;
  final XpRepo xp;

  Stream<List<WaterLog>> watchDay(String day) =>
      (db.select(db.waterLogs)
            ..where((t) => t.day.equals(day))
            ..orderBy([(t) => OrderingTerm.asc(t.atUtc)]))
          .watch();

  /// Adds (n > 0) or removes (n < 0) glasses. Returns true when this change
  /// reached the goal.
  Future<bool> change(String day, int n, int goal) async {
    final before = await (db.select(db.waterLogs)..where((t) => t.day.equals(day))).get();
    if (n > 0) {
      await db.batch((b) {
        for (var i = 0; i < n; i++) {
          b.insert(db.waterLogs, WaterLogsCompanion.insert(day: day, atUtc: DateTime.now().toUtc()));
        }
      });
    } else if (n < 0 && before.isNotEmpty) {
      final sorted = before.toList()..sort((a, b) => b.atUtc.compareTo(a.atUtc));
      final drop = sorted.take(-n).map((e) => e.id).toList();
      await (db.delete(db.waterLogs)..where((t) => t.id.isIn(drop))).go();
    }
    final count = (before.length + n).clamp(0, 1 << 20);
    await xp.set(day, Xp.waterKey, count >= goal ? Xp.waterGoal : 0);
    return before.length < goal && count >= goal;
  }

  /// Sets the count to exactly [n] (tapping a glass).
  Future<bool> setCount(String day, int n, int goal) async {
    final c = (await (db.select(db.waterLogs)..where((t) => t.day.equals(day))).get()).length;
    return change(day, n - c, goal);
  }
}

final waterRepoProvider = Provider((ref) => WaterRepo(ref.watch(dbProvider), ref.watch(xpRepoProvider)));
final waterTodayProvider = StreamProvider<List<WaterLog>>(
  (ref) => ref.watch(waterRepoProvider).watchDay(ref.watch(todayProvider)),
);
final waterCountProvider = Provider<int>((ref) => ref.watch(waterTodayProvider).value?.length ?? 0);
