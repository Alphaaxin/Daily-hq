import '../../../core/time/day_clock.dart';

/// When to remind you to drink. Reminders run every [interval] from your last
/// glass (or now) until the end of your waking window, skip quiet hours, and
/// stop entirely once the goal is reached.
List<DateTime> waterReminderTimes({
  required DayClock clock,
  required int glasses,
  required int goal,
  required Duration interval,
  DateTime? lastDrinkUtc,
  required DateTime windowEndUtc,
  int quietStartHour = 1,
  int quietEndHour = 10,
  int max = 10,
}) {
  if (glasses >= goal) return const [];
  final now = clock.nowUtc();
  var t = (lastDrinkUtc != null && lastDrinkUtc.isAfter(now.subtract(interval)))
      ? lastDrinkUtc.add(interval)
      : now.add(interval);
  final out = <DateTime>[];
  final remaining = goal - glasses;
  while (t.isBefore(windowEndUtc) && out.length < max && out.length < remaining + 2) {
    if (!inQuietHours(clock, t, quietStartHour, quietEndHour)) out.add(t);
    t = t.add(interval);
  }
  return out;
}

/// Quiet hours may wrap past midnight (e.g. 1 → 10 for a night owl).
bool inQuietHours(DayClock clock, DateTime utc, int start, int end) {
  if (start == end) return false;
  final h = clock.toLocal(utc).hour;
  return start < end ? (h >= start && h < end) : (h >= start || h < end);
}
