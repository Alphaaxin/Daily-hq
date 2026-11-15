import '../../../core/time/day_clock.dart';
import '../../gamification/domain/streaks.dart';

enum FocusKind { build, pomodoro, work, manual }

extension FocusKindX on FocusKind {
  String get label => const ['Build Hour', 'Pomodoro', 'Work timer', 'Manual'][index];
  static FocusKind parse(String s) => FocusKind.values.firstWhere((k) => k.name == s, orElse: () => FocusKind.manual);
}

/// Seconds on the clock for a (possibly paused) session.
int elapsedSeconds({
  required DateTime startUtc,
  required int bankedSeconds,
  DateTime? pausedAtUtc,
  DateTime? endUtc,
  required DateTime nowUtc,
}) {
  if (endUtc != null) return bankedSeconds + endUtc.difference(startUtc).inSeconds.clamp(0, 1 << 30);
  if (pausedAtUtc != null) return bankedSeconds;
  return bankedSeconds + nowUtc.difference(startUtc).inSeconds.clamp(0, 1 << 30);
}

/// Build Hour XP for a day's total minutes: +10 per full 15 minutes, plus a
/// +10 bonus at 60 minutes (so a full hour = 50). Never more than 50.
int buildHourXp(int minutes) {
  if (minutes <= 0) return 0;
  final blocks = (minutes ~/ 15).clamp(0, 4);
  return blocks * 10 + (minutes >= 60 ? 10 : 0);
}

/// Days where Build Hour reached 60 minutes, in a row.
int buildStreak(Map<String, int> minutesByDay, String today) => currentStreak({
  for (final e in minutesByDay.entries)
    if (e.value >= 60) e.key,
}, today);

/// +10 XP for each finished Pomodoro work block.
int pomodoroXp(int seconds, int workMinutes) => seconds >= workMinutes * 60 ? 10 : 0;

class TimeLog {
  const TimeLog({required this.day, required this.seconds, this.profileId, required this.kind, this.note = ''});
  final String day;
  final int seconds;
  final int? profileId;
  final FocusKind kind;
  final String note;
}

/// Seconds per profile (null = untagged) within [fromDay, toDay] inclusive.
Map<int?, int> totalsByProfile(Iterable<TimeLog> logs, String fromDay, String toDay) {
  final m = <int?, int>{};
  for (final l in logs) {
    if (l.day.compareTo(fromDay) < 0 || l.day.compareTo(toDay) > 0) continue;
    m[l.profileId] = (m[l.profileId] ?? 0) + l.seconds;
  }
  return m;
}

/// Monday of the week containing [day].
String weekStart(String day) => DayKey.add(day, 1 - DayKey.weekday(day));

String fmtHours(int seconds) {
  final m = (seconds / 60).round();
  final h = m ~/ 60, r = m % 60;
  return h == 0 ? '${r}m' : '${h}h ${r.toString().padLeft(2, '0')}m';
}

/// CSV for retainer reports. Quotes every text cell and escapes quotes.
String timeLogCsv(Iterable<TimeLog> logs, Map<int?, String> profileNames) {
  String q(String s) => '"${s.replaceAll('"', '""')}"';
  final b = StringBuffer('Date,Profile,Type,Hours,Minutes,Note\n');
  final sorted = logs.toList()..sort((a, b) => a.day.compareTo(b.day));
  for (final l in sorted) {
    final mins = (l.seconds / 60).round();
    b.writeln(
      [
        l.day,
        q(profileNames[l.profileId] ?? 'Untagged'),
        q(l.kind.label),
        (mins / 60).toStringAsFixed(2),
        mins,
        q(l.note),
      ].join(','),
    );
  }
  return b.toString();
}
