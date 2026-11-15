import '../../../core/time/day_clock.dart';

/// Consecutive days in [doneDays] ending today, or yesterday if today isn't
/// done yet (an unfinished today never breaks a streak).
int currentStreak(Set<String> doneDays, String today) {
  var k = doneDays.contains(today) ? today : DayKey.add(today, -1);
  var n = 0;
  while (doneDays.contains(k)) {
    n++;
    k = DayKey.add(k, -1);
  }
  return n;
}

/// Longest run of consecutive days anywhere in [doneDays].
int bestStreak(Set<String> doneDays) {
  if (doneDays.isEmpty) return 0;
  final sorted = doneDays.toList()..sort();
  var best = 1, run = 1;
  for (var i = 1; i < sorted.length; i++) {
    if (DayKey.diff(sorted[i - 1], sorted[i]) == 1) {
      run++;
      if (run > best) best = run;
    } else {
      run = 1;
    }
  }
  return best;
}
