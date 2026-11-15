import 'dart:async';

import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/db/app_db.dart';
import '../../../core/providers.dart';
import '../domain/levels.dart';
import '../domain/streaks.dart';

class XpEvent {
  const XpEvent(this.delta, {this.levelUp});
  final int delta;
  final LevelInfo? levelUp;
}

class XpRepo {
  XpRepo(this.db);
  final AppDb db;
  final _events = StreamController<XpEvent>.broadcast();

  Stream<XpEvent> get events => _events.stream;

  Future<int> _total() async {
    final s = db.xpEntries.amount.sum();
    final r = await (db.selectOnly(db.xpEntries)..addColumns([s])).getSingle();
    return r.read(s) ?? 0;
  }

  /// Idempotently sets the XP for (day, source). 0 removes the entry.
  Future<int> set(String day, String source, int amount) async {
    final before = await _total();
    final existing = await (db.select(
      db.xpEntries,
    )..where((t) => t.day.equals(day) & t.source.equals(source))).getSingleOrNull();
    final old = existing?.amount ?? 0;
    if (amount <= 0) {
      if (existing != null) {
        await (db.delete(db.xpEntries)..where((t) => t.day.equals(day) & t.source.equals(source))).go();
      }
    } else if (old != amount) {
      await db
          .into(db.xpEntries)
          .insertOnConflictUpdate(
            XpEntriesCompanion.insert(day: day, source: source, amount: amount, atUtc: DateTime.now().toUtc()),
          );
    }
    final delta = (amount <= 0 ? 0 : amount) - old;
    if (delta != 0) {
      final a = levelFor(before), b = levelFor(before + delta);
      _events.add(XpEvent(delta, levelUp: b.level > a.level ? b : null));
    }
    if (source != multiplierKey && delta != 0) await refreshMultiplier(day);
    return delta;
  }

  /// The morning-routine bonus: once every morning item is ticked, the day's
  /// XP is worth ×1.2. Stored as one entry worth 20% of the day's other XP,
  /// recalculated on every change, so it can never double-count.
  static const multiplierKey = 'routine:multiplier';

  Future<bool> morningDone(String day) async {
    final items = await (db.select(
      db.routineItems,
    )..where((t) => t.routine.equals('morning') & t.archived.equals(false))).get();
    if (items.isEmpty) return false;
    final ids = {for (final i in items) i.id};
    final logs = await (db.select(db.routineLogs)..where((t) => t.day.equals(day) & t.itemId.isIn(ids))).get();
    return logs.length >= ids.length;
  }

  Future<void> refreshMultiplier(String day) async {
    var bonus = 0;
    if (await morningDone(day)) {
      final s = db.xpEntries.amount.sum();
      final r =
          await (db.selectOnly(db.xpEntries)
                ..addColumns([s])
                ..where(db.xpEntries.day.equals(day) & db.xpEntries.source.equals(multiplierKey).not()))
              .getSingle();
      bonus = ((r.read(s) ?? 0) * 0.2).round();
    }
    await set(day, multiplierKey, bonus);
  }

  Stream<int> watchTotal() {
    final s = db.xpEntries.amount.sum();
    return (db.selectOnly(db.xpEntries)..addColumns([s])).map((r) => r.read(s) ?? 0).watchSingle();
  }

  Stream<int> watchSpent() {
    final s = db.redemptions.cost.sum();
    return (db.selectOnly(db.redemptions)..addColumns([s])).map((r) => r.read(s) ?? 0).watchSingle();
  }

  Stream<int> watchDay(String day) {
    final s = db.xpEntries.amount.sum();
    return (db.selectOnly(db.xpEntries)
          ..addColumns([s])
          ..where(db.xpEntries.day.equals(day)))
        .map((r) => r.read(s) ?? 0)
        .watchSingle();
  }

  Stream<Set<String>> watchActiveDays() {
    final s = db.xpEntries.amount.sum();
    final q = db.selectOnly(db.xpEntries)
      ..addColumns([db.xpEntries.day, s])
      ..groupBy([db.xpEntries.day]);
    return q.watch().map(
      (rows) => {
        for (final r in rows)
          if ((r.read(s) ?? 0) > 0) r.read(db.xpEntries.day)!,
      },
    );
  }

  void dispose() => _events.close();
}

final xpRepoProvider = Provider((ref) {
  final r = XpRepo(ref.watch(dbProvider));
  ref.onDispose(r.dispose);
  return r;
});

final xpTotalProvider = StreamProvider<int>((ref) => ref.watch(xpRepoProvider).watchTotal());
final xpSpentProvider = StreamProvider<int>((ref) => ref.watch(xpRepoProvider).watchSpent());
final xpTodayProvider = StreamProvider<int>((ref) => ref.watch(xpRepoProvider).watchDay(ref.watch(todayProvider)));

final levelProvider = Provider<LevelInfo>((ref) => levelFor(ref.watch(xpTotalProvider).value ?? 0));

final xpBalanceProvider = Provider<int>(
  (ref) => (ref.watch(xpTotalProvider).value ?? 0) - (ref.watch(xpSpentProvider).value ?? 0),
);

final activeDaysProvider = StreamProvider<Set<String>>((ref) => ref.watch(xpRepoProvider).watchActiveDays());

final overallStreakProvider = Provider<int>(
  (ref) => currentStreak(ref.watch(activeDaysProvider).value ?? const {}, ref.watch(todayProvider)),
);
