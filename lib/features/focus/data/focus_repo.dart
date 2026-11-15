import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/db/app_db.dart';
import '../../../core/providers.dart';
import '../../../core/time/day_clock.dart';
import '../../gamification/data/xp_repo.dart';
import '../domain/focus_logic.dart';

extension FocusSessionX on FocusSession {
  FocusKind get focusKind => FocusKindX.parse(kind);
  bool get running => endUtc == null;
  bool get paused => endUtc == null && pausedAtUtc != null;
  int elapsed(DateTime nowUtc) => elapsedSeconds(
    startUtc: startUtc,
    bankedSeconds: bankedSeconds,
    pausedAtUtc: pausedAtUtc,
    endUtc: endUtc,
    nowUtc: nowUtc,
  );
  TimeLog get log => TimeLog(day: day, seconds: seconds, profileId: profileId, kind: focusKind, note: note);
}

class FocusRepo {
  FocusRepo(this.db, this.xp);
  final AppDb db;
  final XpRepo xp;

  static String buildXpKey = 'build:hour';
  static String pomoXpKey(int id) => 'focus:pomo:$id';

  Stream<FocusSession?> watchRunning() =>
      (db.select(db.focusSessions)
            ..where((t) => t.endUtc.isNull())
            ..orderBy([(t) => OrderingTerm.desc(t.id)])
            ..limit(1))
          .watchSingleOrNull();

  Future<FocusSession?> running() =>
      (db.select(db.focusSessions)
            ..where((t) => t.endUtc.isNull())
            ..orderBy([(t) => OrderingTerm.desc(t.id)])
            ..limit(1))
          .getSingleOrNull();

  Stream<List<FocusSession>> watchRange(String fromDay, String toDay) =>
      (db.select(db.focusSessions)
            ..where((t) => t.endUtc.isNotNull() & t.day.isBetweenValues(fromDay, toDay))
            ..orderBy([(t) => OrderingTerm.desc(t.startUtc)]))
          .watch();

  /// Starts a session; any running one is stopped first.
  Future<int> start(DayClock clock, FocusKind kind, {int? profileId, int? ideaId, int? learningId}) async {
    final cur = await running();
    if (cur != null) await stop(clock, cur);
    return db
        .into(db.focusSessions)
        .insert(
          FocusSessionsCompanion.insert(
            kind: kind.name,
            profileId: Value(profileId),
            ideaId: Value(ideaId),
            startUtc: clock.nowUtc(),
            day: clock.today(),
          ),
        );
  }

  Future<void> pause(DayClock clock, FocusSession s) async {
    if (s.paused || !s.running) return;
    final now = clock.nowUtc();
    await (db.update(db.focusSessions)..where((t) => t.id.equals(s.id))).write(
      FocusSessionsCompanion(bankedSeconds: Value(s.elapsed(now)), pausedAtUtc: Value(now)),
    );
  }

  Future<void> resume(DayClock clock, FocusSession s) async {
    if (!s.paused) return;
    await (db.update(db.focusSessions)..where((t) => t.id.equals(s.id))).write(
      FocusSessionsCompanion(startUtc: Value(clock.nowUtc()), pausedAtUtc: const Value(null)),
    );
  }

  /// Stops a session, banks its time and awards XP.
  Future<FocusSession> stop(DayClock clock, FocusSession s, {String? note, int? ideaId, int pomoMinutes = 25}) async {
    final now = clock.nowUtc();
    final secs = s.elapsed(now);
    // A paused session ends where it was paused.
    final start = s.paused ? s.pausedAtUtc! : s.startUtc;
    final end = s.paused ? s.pausedAtUtc! : now;
    final done = s.copyWith(
      startUtc: start,
      endUtc: Value(end),
      seconds: secs,
      bankedSeconds: 0,
      pausedAtUtc: const Value(null),
      note: note ?? s.note,
      ideaId: Value(ideaId ?? s.ideaId),
    );
    await db.update(db.focusSessions).replace(done);
    await _award(done, pomoMinutes);
    return done;
  }

  Future<void> addManual({
    required String day,
    required int minutes,
    int? profileId,
    String note = '',
    required DateTime nowUtc,
  }) async {
    await db
        .into(db.focusSessions)
        .insert(
          FocusSessionsCompanion.insert(
            kind: FocusKind.manual.name,
            profileId: Value(profileId),
            startUtc: nowUtc,
            endUtc: Value(nowUtc),
            seconds: Value(minutes * 60),
            note: Value(note),
            day: day,
          ),
        );
  }

  Future<void> delete(FocusSession s) async {
    await (db.delete(db.focusSessions)..where((t) => t.id.equals(s.id))).go();
    if (s.focusKind == FocusKind.build) await _refreshBuildXp(s.day);
    if (s.focusKind == FocusKind.pomodoro) await xp.set(s.day, pomoXpKey(s.id), 0);
  }

  Future<int> buildMinutes(String day) async {
    final l = await (db.select(
      db.focusSessions,
    )..where((t) => t.day.equals(day) & t.kind.equals('build') & t.endUtc.isNotNull())).get();
    return l.fold<int>(0, (a, s) => a + s.seconds) ~/ 60;
  }

  Future<void> _refreshBuildXp(String day) async => xp.set(day, buildXpKey, buildHourXp(await buildMinutes(day)));

  Future<void> _award(FocusSession s, int pomoMinutes) async {
    switch (s.focusKind) {
      case FocusKind.build:
        await _refreshBuildXp(s.day);
      case FocusKind.pomodoro:
        await xp.set(s.day, pomoXpKey(s.id), pomodoroXp(s.seconds, pomoMinutes));
      case FocusKind.work || FocusKind.manual:
        break;
    }
  }

  // Ideas ------------------------------------------------------------------
  Stream<List<Idea>> watchIdeas() =>
      (db.select(db.ideas)
            ..where((t) => t.archived.equals(false))
            ..orderBy([(t) => OrderingTerm.desc(t.createdAtUtc)]))
          .watch();

  Future<int> addIdea(String title, {String note = ''}) => db
      .into(db.ideas)
      .insert(IdeasCompanion.insert(title: title.trim(), note: Value(note), createdAtUtc: DateTime.now().toUtc()));

  Future<void> archiveIdea(int id) =>
      (db.update(db.ideas)..where((t) => t.id.equals(id))).write(const IdeasCompanion(archived: Value(true)));
}

final focusRepoProvider = Provider((ref) => FocusRepo(ref.watch(dbProvider), ref.watch(xpRepoProvider)));
final runningFocusProvider = StreamProvider<FocusSession?>((ref) => ref.watch(focusRepoProvider).watchRunning());
final ideasProvider = StreamProvider<List<Idea>>((ref) => ref.watch(focusRepoProvider).watchIdeas());

/// Finished sessions for the last ~62 days (covers this and last month).
final recentFocusProvider = StreamProvider<List<FocusSession>>((ref) {
  final today = ref.watch(todayProvider);
  return ref.watch(focusRepoProvider).watchRange(DayKey.add(today, -62), today);
});

/// Build Hour seconds today, including a running build session.
final buildSecondsTodayProvider = Provider<int>((ref) {
  ref.watch(tickerProvider);
  final today = ref.watch(todayProvider);
  final now = ref.watch(clockProvider).nowUtc();
  var s = (ref.watch(recentFocusProvider).value ?? const <FocusSession>[])
      .where((x) => x.day == today && x.focusKind == FocusKind.build)
      .fold<int>(0, (a, x) => a + x.seconds);
  final r = ref.watch(runningFocusProvider).value;
  if (r != null && r.focusKind == FocusKind.build && r.day == today) s += r.elapsed(now);
  return s;
});

final buildStreakProvider = Provider<int>((ref) {
  final m = <String, int>{};
  for (final s in ref.watch(recentFocusProvider).value ?? const <FocusSession>[]) {
    if (s.focusKind == FocusKind.build) m[s.day] = (m[s.day] ?? 0) + s.seconds ~/ 60;
  }
  return buildStreak(m, ref.watch(todayProvider));
});
