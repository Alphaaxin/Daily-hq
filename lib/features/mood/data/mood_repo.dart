import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/db/app_db.dart';
import '../../../core/providers.dart';
import '../../gamification/data/xp_repo.dart';
import '../../gamification/domain/xp_rules.dart';

const moods = [('😞', 'Low'), ('😕', 'Meh'), ('🙂', 'Okay'), ('😄', 'Good'), ('🔥', 'On fire')];

class MoodRepo {
  MoodRepo(this.db, this.xp);
  final AppDb db;
  final XpRepo xp;

  Stream<MoodLog?> watchDay(String day) =>
      (db.select(db.moodLogs)..where((t) => t.day.equals(day))).watchSingleOrNull();

  Stream<List<MoodLog>> watchRecent(int days) =>
      (db.select(db.moodLogs)
            ..orderBy([(t) => OrderingTerm.desc(t.day)])
            ..limit(days))
          .watch();

  /// Tapping the selected mood again clears it.
  Future<void> set(String day, int mood) async {
    final cur = await (db.select(db.moodLogs)..where((t) => t.day.equals(day))).getSingleOrNull();
    if (cur?.mood == mood) {
      await (db.delete(db.moodLogs)..where((t) => t.day.equals(day))).go();
      await xp.set(day, Xp.moodKey, 0);
      return;
    }
    await db
        .into(db.moodLogs)
        .insertOnConflictUpdate(MoodLogsCompanion.insert(day: day, mood: mood, atUtc: DateTime.now().toUtc()));
    await xp.set(day, Xp.moodKey, Xp.mood);
  }
}

final moodRepoProvider = Provider((ref) => MoodRepo(ref.watch(dbProvider), ref.watch(xpRepoProvider)));
final moodTodayProvider = StreamProvider<MoodLog?>(
  (ref) => ref.watch(moodRepoProvider).watchDay(ref.watch(todayProvider)),
);
