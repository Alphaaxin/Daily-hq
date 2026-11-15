import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/db/app_db.dart';
import '../../../core/providers.dart';
import '../../../core/time/day_clock.dart';
import '../../gamification/data/xp_repo.dart';
import '../../gamification/domain/xp_rules.dart';
import '../domain/sleep_logic.dart';

extension SleepSessionX on SleepSession {
  SleepSpan get span => SleepSpan(sleptAt: sleptAtUtc, wokeAt: wokeAtUtc);
  bool get asleep => wokeAtUtc == null;
}

class SleepRepo {
  SleepRepo(this.db, this.xp);
  final AppDb db;
  final XpRepo xp;

  Stream<SleepSession?> watchLatest() =>
      (db.select(db.sleepSessions)
            ..orderBy([(t) => OrderingTerm.desc(t.sleptAtUtc)])
            ..limit(1))
          .watchSingleOrNull();

  Stream<List<SleepSession>> watchRecent(int n) =>
      (db.select(db.sleepSessions)
            ..where((t) => t.wokeAtUtc.isNotNull())
            ..orderBy([(t) => OrderingTerm.desc(t.sleptAtUtc)])
            ..limit(n))
          .watch();

  Future<SleepSession?> latest() =>
      (db.select(db.sleepSessions)
            ..orderBy([(t) => OrderingTerm.desc(t.sleptAtUtc)])
            ..limit(1))
          .getSingleOrNull();

  Future<void> goodNight(DayClock clock) async {
    final now = clock.nowUtc();
    final last = await latest();
    if (last != null && last.asleep) return; // already asleep
    final awake = last?.wokeAtUtc == null ? null : now.difference(last!.wokeAtUtc!).inMinutes;
    await db.into(db.sleepSessions).insert(SleepSessionsCompanion.insert(sleptAtUtc: now, awakeMinutes: Value(awake)));
  }

  /// Returns the completed session, or null when there was nothing to end.
  Future<SleepSession?> goodMorning(DayClock clock, double targetHours) async {
    final last = await latest();
    if (last == null || !last.asleep) return null;
    final now = clock.nowUtc();
    await (db.update(
      db.sleepSessions,
    )..where((t) => t.id.equals(last.id))).write(SleepSessionsCompanion(wokeAtUtc: Value(now)));
    final done = last.copyWith(wokeAtUtc: Value(now));
    await _award(clock, done, targetHours);
    return done;
  }

  /// "Forgot to tap?" entry. If you're still marked asleep, it closes that
  /// session; otherwise it inserts a completed one.
  Future<void> logManual(DayClock clock, SleepSpan span, double targetHours) async {
    final last = await latest();
    late SleepSession saved;
    if (last != null && last.asleep) {
      await (db.update(db.sleepSessions)..where((t) => t.id.equals(last.id))).write(
        SleepSessionsCompanion(
          sleptAtUtc: Value(span.sleptAt),
          wokeAtUtc: Value(span.wokeAt),
          source: const Value('manual'),
        ),
      );
      saved = last.copyWith(sleptAtUtc: span.sleptAt, wokeAtUtc: Value(span.wokeAt), source: 'manual');
    } else {
      final id = await db
          .into(db.sleepSessions)
          .insert(
            SleepSessionsCompanion.insert(
              sleptAtUtc: span.sleptAt,
              wokeAtUtc: Value(span.wokeAt),
              source: const Value('manual'),
            ),
          );
      saved = SleepSession(id: id, sleptAtUtc: span.sleptAt, wokeAtUtc: span.wokeAt, source: 'manual');
    }
    await _award(clock, saved, targetHours);
  }

  Future<void> delete(SleepSession s, DayClock clock) async {
    if (s.wokeAtUtc != null) await xp.set(clock.dayKeyFor(s.wokeAtUtc!), Xp.sleepKey, 0);
    await (db.delete(db.sleepSessions)..where((t) => t.id.equals(s.id))).go();
  }

  Future<void> _award(DayClock clock, SleepSession s, double targetHours) async {
    final d = s.span.duration;
    if (d == null) return;
    final day = sleepCreditDay(clock, s.span);
    await xp.set(day, Xp.sleepKey, d.inMinutes >= targetHours * 60 ? Xp.goodMorningOnTarget : Xp.goodMorning);
  }
}

final sleepRepoProvider = Provider((ref) => SleepRepo(ref.watch(dbProvider), ref.watch(xpRepoProvider)));
final latestSleepProvider = StreamProvider<SleepSession?>((ref) => ref.watch(sleepRepoProvider).watchLatest());
final recentSleepProvider = StreamProvider<List<SleepSession>>((ref) => ref.watch(sleepRepoProvider).watchRecent(30));

/// Sleep credited to today (the night you woke up from), if logged.
final todaySleepProvider = Provider<Duration?>((ref) {
  final clock = ref.watch(clockProvider);
  final today = ref.watch(todayProvider);
  final l = ref.watch(recentSleepProvider).value ?? const [];
  for (final s in l) {
    if (sleepCreditDay(clock, s.span) == today) return s.span.duration;
  }
  return null;
});

final bedtimeSuggestionProvider = Provider<BedtimeSuggestion?>((ref) {
  final l = ref.watch(recentSleepProvider).value ?? const [];
  return bedtimeSuggestion(
    clock: ref.watch(clockProvider),
    recent: l.take(7).map((e) => e.span).toList(),
    targetHours: ref.watch(settingsProvider).sleepTargetHours,
  );
});
