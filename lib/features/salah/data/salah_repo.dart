import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/db/app_db.dart';
import '../../../core/providers.dart';
import '../../../core/time/day_clock.dart';
import '../../gamification/data/xp_repo.dart';
import '../../gamification/domain/streaks.dart';
import '../../gamification/domain/xp_rules.dart';
import '../domain/prayer_times.dart';

class SalahRepo {
  SalahRepo(this.db, this.xp);
  final AppDb db;
  final XpRepo xp;

  Stream<Map<Prayer, SalahStatus>> watchDate(String prayerDate) =>
      (db.select(db.salahLogs)..where((t) => t.prayerDate.equals(prayerDate))).watch().map(
        (l) => {for (final x in l) Prayer.values[x.prayer]: SalahStatus.values[x.status]},
      );

  /// prayerDate -> number of prayers prayed.
  Stream<Map<String, int>> watchCounts() => db.select(db.salahLogs).watch().map((l) {
    final m = <String, int>{};
    for (final x in l) {
      m[x.prayerDate] = (m[x.prayerDate] ?? 0) + 1;
    }
    return m;
  });

  /// Tap cycle: unmarked → prayed (on time or late, by the clock) → cleared.
  Future<SalahStatus?> toggle(PrayerDay day, Prayer p, DayClock clock) async {
    final now = clock.nowUtc();
    final xpDay = clock.dayKeyFor(day.start(p));
    final key = Xp.salahKey(day.date, p.name);
    final q = db.select(db.salahLogs)..where((t) => t.prayerDate.equals(day.date) & t.prayer.equals(p.index));
    if (await q.getSingleOrNull() != null) {
      await (db.delete(db.salahLogs)..where((t) => t.prayerDate.equals(day.date) & t.prayer.equals(p.index))).go();
      await xp.set(xpDay, key, 0);
      return null;
    }
    final status = day.classifyMark(p, now);
    await db
        .into(db.salahLogs)
        .insertOnConflictUpdate(
          SalahLogsCompanion.insert(prayerDate: day.date, prayer: p.index, status: status.index, atUtc: now),
        );
    await xp.set(xpDay, key, status == SalahStatus.onTime ? Xp.salahOnTime : Xp.salahLate);
    return status;
  }
}

final salahRepoProvider = Provider((ref) => SalahRepo(ref.watch(dbProvider), ref.watch(xpRepoProvider)));

final prayerCalculatorProvider = Provider((ref) {
  final s = ref.watch(settingsProvider);
  return PrayerCalculator(
    PrayerConfig(latitude: s.latitude, longitude: s.longitude, method: s.prayerMethod, hanafiAsr: s.hanafiAsr),
  );
});

/// The prayer day currently shown (switches at Fajr). Recomputed on each tick.
final currentPrayerDayProvider = Provider<PrayerDay>((ref) {
  ref.watch(tickerProvider);
  return ref.watch(prayerCalculatorProvider).current(ref.watch(clockProvider));
});

final _currentPrayerDateProvider = Provider<String>((ref) => ref.watch(currentPrayerDayProvider).date);

final salahLogsProvider = StreamProvider<Map<Prayer, SalahStatus>>(
  (ref) => ref.watch(salahRepoProvider).watchDate(ref.watch(_currentPrayerDateProvider)),
);

final salahCountsProvider = StreamProvider<Map<String, int>>((ref) => ref.watch(salahRepoProvider).watchCounts());

/// Days on which all five prayers were prayed (on time or late), in a row.
final salahStreakProvider = Provider<int>((ref) {
  final counts = ref.watch(salahCountsProvider).value ?? const {};
  final full = {
    for (final e in counts.entries)
      if (e.value >= 5) e.key,
  };
  return currentStreak(full, ref.watch(_currentPrayerDateProvider));
});

/// Statuses for the row on Today, resolved against the clock.
final salahStatusesProvider = Provider<Map<Prayer, SalahStatus>>((ref) {
  final day = ref.watch(currentPrayerDayProvider);
  final logs = ref.watch(salahLogsProvider).value ?? const {};
  final now = ref.watch(clockProvider).nowUtc();
  return {for (final p in Prayer.values) p: day.statusAt(p, now, logs[p])};
});
