import '../../../core/time/day_clock.dart';
import 'prayer_times.dart';

class AzanAlert {
  const AzanAlert({
    required this.id,
    required this.atUtc,
    required this.title,
    required this.body,
    required this.payload,
  });
  final int id;
  final DateTime atUtc;
  final String title;
  final String body;

  /// `salah:<prayerDate>:<prayer>`, used by the "Prayed ✓" action.
  final String payload;
}

/// Prayer-time chimes for the next [days] calendar days, skipping prayers you
/// switched off and anything already in the past. Optionally a reminder
/// [beforeMinutes] earlier. Ids are stable so re-planning replaces them.
List<AzanAlert> azanSchedule({
  required PrayerCalculator calc,
  required DayClock clock,
  required int baseId,
  int days = 3,
  Set<Prayer> off = const {},
  int? beforeMinutes,
}) {
  final now = clock.nowUtc();
  final today = clock.calendarDateFor(now);
  final out = <AzanAlert>[];
  for (var d = 0; d < days; d++) {
    final date = DayKey.add(today, d);
    final day = calc.forDate(date);
    for (final p in Prayer.values) {
      if (off.contains(p)) continue;
      final at = day.start(p);
      final id = baseId + d * 10 + p.index * 2;
      if (at.isAfter(now)) {
        out.add(
          AzanAlert(
            id: id,
            atUtc: at,
            title: '${p.label} 🕌',
            body: 'It\'s time for ${p.label}. Tap "Prayed ✓" once you\'ve prayed.',
            payload: 'salah:$date:${p.name}',
          ),
        );
      }
      if (beforeMinutes != null) {
        final pre = at.subtract(Duration(minutes: beforeMinutes));
        if (pre.isAfter(now)) {
          out.add(
            AzanAlert(
              id: id + 1,
              atUtc: pre,
              title: '${p.label} in $beforeMinutes min',
              body: 'Time to wrap up and make wudu.',
              payload: 'salah:$date:${p.name}',
            ),
          );
        }
      }
    }
  }
  return out;
}
