import '../../../core/time/day_clock.dart';

class SleepSpan {
  const SleepSpan({required this.sleptAt, this.wokeAt});
  final DateTime sleptAt; // UTC
  final DateTime? wokeAt; // UTC, null while asleep

  Duration? get duration => wokeAt?.difference(sleptAt);
}

/// Sleep is credited to the logical day you wake up into.
String sleepCreditDay(DayClock clock, SleepSpan s) => clock.dayKeyFor(s.wokeAt ?? s.sleptAt);

enum SleepPrompt { none, askWake, askSleepAndWake }

/// Decides whether to ask "What time did you sleep / wake?".
///
/// * Still marked asleep after [maxAsleep] → you forgot Good Morning.
/// * Marked awake, but your last wake-up was before today began → you forgot
///   both taps last night.
SleepPrompt sleepPrompt({
  required DayClock clock,
  required SleepSpan? latest,
  Duration maxAsleep = const Duration(hours: 14),
  String? dismissedFor,
}) {
  final now = clock.nowUtc();
  final today = clock.today();
  if (dismissedFor == today) return SleepPrompt.none;
  if (latest == null) return SleepPrompt.none; // brand-new install
  if (latest.wokeAt == null) {
    return now.difference(latest.sleptAt) > maxAsleep ? SleepPrompt.askWake : SleepPrompt.none;
  }
  return latest.wokeAt!.isBefore(clock.dayStartUtc(today)) ? SleepPrompt.askSleepAndWake : SleepPrompt.none;
}

/// Minutes after local noon, so that 23:30 and 01:30 average sensibly.
int _minutesAfterNoon(DayClock c, DateTime utc) {
  final l = c.toLocal(utc);
  return ((l.hour * 60 + l.minute) - 720 + 1440) % 1440;
}

class BedtimeSuggestion {
  const BedtimeSuggestion(this.averageBedtimeMin, this.suggestedMin, this.averageSleep);

  /// Local minutes-of-day (0..1439).
  final int averageBedtimeMin;
  final int suggestedMin;
  final Duration averageSleep;
}

/// If the recent average sleep is below target, suggest going to bed 15 min
/// earlier than your recent average bedtime.
BedtimeSuggestion? bedtimeSuggestion({
  required DayClock clock,
  required List<SleepSpan> recent,
  required double targetHours,
  int stepMinutes = 15,
}) {
  final done = recent.where((s) => s.wokeAt != null).toList();
  if (done.length < 3) return null;
  final avgMin = done.map((s) => s.duration!.inMinutes).reduce((a, b) => a + b) / done.length;
  if (avgMin >= targetHours * 60) return null;
  final avgBed = done.map((s) => _minutesAfterNoon(clock, s.sleptAt)).reduce((a, b) => a + b) / done.length;
  final bed = (avgBed.round() + 720) % 1440;
  final suggested = (bed - stepMinutes + 1440) % 1440;
  return BedtimeSuggestion(bed, suggested, Duration(minutes: avgMin.round()));
}

/// Builds the UTC instants for a manual "I slept at X, woke at Y" entry, where
/// both are local wall-clock times and the wake time is the most recent
/// occurrence before now.
SleepSpan manualSpan(DayClock clock, int sleepH, int sleepM, int wakeH, int wakeM) {
  final now = clock.nowUtc();
  final todayCal = clock.calendarDateFor(now);
  var woke = clock.localToUtc(todayCal, wakeH, wakeM);
  if (woke.isAfter(now)) woke = clock.localToUtc(DayKey.add(todayCal, -1), wakeH, wakeM);
  final wokeCal = clock.calendarDateFor(woke);
  var slept = clock.localToUtc(wokeCal, sleepH, sleepM);
  if (!slept.isBefore(woke)) slept = clock.localToUtc(DayKey.add(wokeCal, -1), sleepH, sleepM);
  return SleepSpan(sleptAt: slept, wokeAt: woke);
}

String fmtDuration(Duration d) {
  final m = d.inMinutes.abs();
  final h = m ~/ 60, r = m % 60;
  return h > 0 ? '${h}h ${r.toString().padLeft(2, '0')}m' : '${r}m';
}

String fmtClock(int minutesOfDay) {
  var h = minutesOfDay ~/ 60;
  final m = minutesOfDay % 60;
  final ap = h >= 12 ? 'PM' : 'AM';
  h = h % 12 == 0 ? 12 : h % 12;
  return '$h:${m.toString().padLeft(2, '0')} $ap';
}
