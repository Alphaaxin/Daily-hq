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
    return delta;
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
