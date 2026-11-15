import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/db/app_db.dart';
import '../../../core/providers.dart';
import '../../gamification/data/xp_repo.dart';

class TargetsRepo {
  TargetsRepo(this.db, this.xp);
  final AppDb db;
  final XpRepo xp;

  static const xpOnComplete = 20;
  static String xpKey(int id) => 'target:$id';

  Stream<List<Target>> watch() =>
      (db.select(db.targets)
            ..where((t) => t.archived.equals(false))
            ..orderBy([(t) => OrderingTerm.asc(t.sort), (t) => OrderingTerm.asc(t.id)]))
          .watch();

  Stream<Map<int, int>> watchDay(String day) => (db.select(
    db.targetLogs,
  )..where((t) => t.day.equals(day))).watch().map((l) => {for (final x in l) x.targetId: x.count});

  /// Adds [delta] to today's count. Returns true when this reached the goal.
  Future<bool> bump(Target t, String day, int delta) async {
    final cur = await (db.select(
      db.targetLogs,
    )..where((x) => x.targetId.equals(t.id) & x.day.equals(day))).getSingleOrNull();
    final before = cur?.count ?? 0;
    final after = (before + delta).clamp(0, 9999);
    await db
        .into(db.targetLogs)
        .insertOnConflictUpdate(TargetLogsCompanion.insert(targetId: t.id, day: day, count: after));
    await xp.set(day, xpKey(t.id), after >= t.goal ? xpOnComplete : 0);
    return before < t.goal && after >= t.goal;
  }

  /// Counts automatically for targets fed by other modules (leads, emails).
  Future<void> bumpAuto(String source, String day, int delta) async {
    final ts = await (db.select(
      db.targets,
    )..where((t) => t.autoSource.equals(source) & t.archived.equals(false))).get();
    for (final t in ts) {
      await bump(t, day, delta);
    }
  }

  Future<void> add(String name, int goal, {int? profileId}) async {
    final n = await db.select(db.targets).get();
    await db
        .into(db.targets)
        .insert(
          TargetsCompanion.insert(name: name.trim(), goal: goal, profileId: Value(profileId), sort: Value(n.length)),
        );
  }

  Future<void> update(int id, {String? name, int? goal, Value<int?> profileId = const Value.absent()}) =>
      (db.update(db.targets)..where((t) => t.id.equals(id))).write(
        TargetsCompanion(
          name: name == null ? const Value.absent() : Value(name.trim()),
          goal: goal == null ? const Value.absent() : Value(goal),
          profileId: profileId,
        ),
      );

  Future<void> archive(int id) =>
      (db.update(db.targets)..where((t) => t.id.equals(id))).write(const TargetsCompanion(archived: Value(true)));
}

final targetsRepoProvider = Provider((ref) => TargetsRepo(ref.watch(dbProvider), ref.watch(xpRepoProvider)));
final targetsProvider = StreamProvider<List<Target>>((ref) => ref.watch(targetsRepoProvider).watch());
final targetCountsProvider = StreamProvider<Map<int, int>>(
  (ref) => ref.watch(targetsRepoProvider).watchDay(ref.watch(todayProvider)),
);
