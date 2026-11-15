import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/db/app_db.dart';
import '../../../core/providers.dart';
import 'xp_repo.dart';

class RewardsRepo {
  RewardsRepo(this.db);
  final AppDb db;

  Stream<List<Reward>> watch() =>
      (db.select(db.rewards)
            ..where((t) => t.archived.equals(false))
            ..orderBy([(t) => OrderingTerm.asc(t.cost)]))
          .watch();

  Stream<List<Redemption>> watchRedemptions() =>
      (db.select(db.redemptions)
            ..orderBy([(t) => OrderingTerm.desc(t.atUtc)])
            ..limit(30))
          .watch();

  Future<void> add(String name, int cost) =>
      db.into(db.rewards).insert(RewardsCompanion.insert(name: name.trim(), cost: cost));

  Future<void> archive(int id) =>
      (db.update(db.rewards)..where((t) => t.id.equals(id))).write(const RewardsCompanion(archived: Value(true)));

  /// Spends XP on a reward; false when the balance is too low.
  Future<bool> redeem(Reward r, int balance) async {
    if (r.cost > balance) return false;
    await db
        .into(db.redemptions)
        .insert(RedemptionsCompanion.insert(name: r.name, cost: r.cost, atUtc: DateTime.now().toUtc()));
    return true;
  }
}

final rewardsRepoProvider = Provider((ref) => RewardsRepo(ref.watch(dbProvider)));
final rewardsProvider = StreamProvider((ref) => ref.watch(rewardsRepoProvider).watch());
final redemptionsProvider = StreamProvider((ref) => ref.watch(rewardsRepoProvider).watchRedemptions());

/// Re-exported so the Rewards UI only imports this file.
final rewardBalanceProvider = xpBalanceProvider;
