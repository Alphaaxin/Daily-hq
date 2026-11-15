import 'dart:math' as math;

import '../../../core/time/day_clock.dart';
import '../../gamification/domain/streaks.dart';

/// Stable per-day randomness (same picks all day, different tomorrow).
int daySeed(String key) {
  var h = 0x811C9DC5;
  for (final c in key.codeUnits) {
    h = ((h ^ c) * 0x01000193) & 0x7FFFFFFF;
  }
  return h;
}

/// Picks [n] quest ids for [day] from the pool, without repeats.
List<int> pickDailyQuests(List<int> pool, String day, {int n = 3}) {
  if (pool.isEmpty) return const [];
  final ids = pool.toList()..sort();
  ids.shuffle(math.Random(daySeed('quests:$day')));
  return ids.take(n).toList();
}

/// Picks the weekly boss for the week starting [weekStart] (Monday).
int? pickBoss(List<int> pool, String weekStart) {
  if (pool.isEmpty) return null;
  final ids = pool.toList()..sort();
  return ids[daySeed('boss:$weekStart') % ids.length];
}

// ---------------------------------------------------------------- shields

const maxShields = 3;

/// A week (Monday [weekStart]) earns a shield with 5+ active days.
bool weekEarnsShield(Set<String> activeDays, String weekStart) =>
    [for (var i = 0; i < 7; i++) DayKey.add(weekStart, i)].where(activeDays.contains).length >= 5;

/// Which day (if any) a shield should cover now: the most recent fully
/// finished day that was missed, when the day before it was active (so a
/// streak is actually at stake) and it isn't covered yet.
String? dayNeedingShield(Set<String> activeDays, Set<String> shielded, String today) {
  final y = DayKey.add(today, -1);
  if (activeDays.contains(y) || shielded.contains(y)) return null;
  final before = DayKey.add(y, -1);
  if (!activeDays.contains(before) && !shielded.contains(before)) return null;
  return y;
}

/// Streak counting shielded days as kept (but not as earned days).
int streakWithShields(Set<String> activeDays, Set<String> shielded, String today) {
  final kept = {...activeDays, ...shielded};
  var k = kept.contains(today) ? today : DayKey.add(today, -1);
  var n = 0;
  while (kept.contains(k)) {
    if (activeDays.contains(k)) n++;
    k = DayKey.add(k, -1);
  }
  return n;
}

// ---------------------------------------------------------------- plant

class PlantState {
  const PlantState(this.stage, this.wilting, this.activeLast14);

  /// 0 seed … 5 blooming.
  final int stage;
  final bool wilting;
  final int activeLast14;

  static const names = ['Seed', 'Sprout', 'Seedling', 'Young plant', 'Leafy', 'Blooming'];
  String get name => wilting ? '${names[stage]} (thirsty)' : names[stage];
}

/// Grows with consistency over the last 14 days; wilts after 2 idle days.
PlantState plantState(Set<String> activeDays, String today) {
  final last14 = [for (var i = 0; i < 14; i++) DayKey.add(today, -i)].where(activeDays.contains).length;
  final stage = switch (last14) {
    >= 13 => 5,
    >= 10 => 4,
    >= 7 => 3,
    >= 4 => 2,
    >= 1 => 1,
    _ => 0,
  };
  final idle2 = !activeDays.contains(DayKey.add(today, -1)) && !activeDays.contains(DayKey.add(today, -2));
  return PlantState(stage, idle2 && stage > 0, last14);
}

// ---------------------------------------------------------------- stats

/// Pearson correlation, null when there's too little or flat data.
double? pearson(List<double> x, List<double> y) {
  final n = math.min(x.length, y.length);
  if (n < 5) return null;
  final mx = x.take(n).reduce((a, b) => a + b) / n, my = y.take(n).reduce((a, b) => a + b) / n;
  var sxy = 0.0, sxx = 0.0, syy = 0.0;
  for (var i = 0; i < n; i++) {
    final dx = x[i] - mx, dy = y[i] - my;
    sxy += dx * dy;
    sxx += dx * dx;
    syy += dy * dy;
  }
  if (sxx == 0 || syy == 0) return null;
  return sxy / math.sqrt(sxx * syy);
}

String describeCorrelation(double? r, String a, String b) {
  if (r == null) return 'Not enough data yet to compare $a and $b.';
  final strength = r.abs() >= .6
      ? 'strongly'
      : r.abs() >= .3
      ? 'somewhat'
      : 'barely';
  if (r.abs() < .15) return '$a and $b don\'t seem linked yet.';
  return 'More $a ${r > 0 ? 'goes with' : 'goes with less'} $b ($strength, r = ${r.toStringAsFixed(2)}).';
}

/// Daily spending allowance from a monthly budget, for "money discipline".
double moneyDiscipline({required int spentTodayPaise, required int monthlyBudgetPaise, required int daysInMonth}) {
  if (monthlyBudgetPaise <= 0) return 1;
  final allowance = monthlyBudgetPaise / daysInMonth;
  if (spentTodayPaise <= allowance) return 1;
  // 2× the allowance → 0.
  return (2 - spentTodayPaise / allowance).clamp(0.0, 1.0);
}

/// Badge ids earned from lifetime stats.
class BadgeDef {
  const BadgeDef(this.id, this.icon, this.title, this.hint);
  final String id;
  final String icon;
  final String title;
  final String hint;
}

const badgeDefs = [
  BadgeDef('streak7', '🔥', 'On fire', '7-day streak'),
  BadgeDef('streak30', '🌋', 'Unstoppable', '30-day streak'),
  BadgeDef('level5', '⭐', 'Operator', 'Reach level 5'),
  BadgeDef('level10', '👑', 'Legend', 'Reach level 10'),
  BadgeDef('build10', '🚀', 'Builder', '10 full Build Hours'),
  BadgeDef('leads100', '🎯', 'Prospector', '100 leads collected'),
  BadgeDef('closed1', '🤝', 'Closer', 'Close a deal'),
  BadgeDef('emails100', '✉️', 'Outreach', '100 e-mails sent'),
  BadgeDef('meetings10', '🎙️', 'Note taker', '10 meetings with minutes'),
  BadgeDef('salah30', '🕌', 'Steadfast', '30 days of all five prayers'),
  BadgeDef('water30', '💧', 'Hydrated', 'Water goal on 30 days'),
  BadgeDef('saver', '💰', 'Saver', 'A month under budget'),
];

Set<String> earnedBadges({
  required int bestStreak,
  required int level,
  required int buildHours,
  required int leads,
  required int closed,
  required int emails,
  required int meetings,
  required int salahFullDays,
  required int waterDays,
  required bool monthUnderBudget,
}) => {
  if (bestStreak >= 7) 'streak7',
  if (bestStreak >= 30) 'streak30',
  if (level >= 5) 'level5',
  if (level >= 10) 'level10',
  if (buildHours >= 10) 'build10',
  if (leads >= 100) 'leads100',
  if (closed >= 1) 'closed1',
  if (emails >= 100) 'emails100',
  if (meetings >= 10) 'meetings10',
  if (salahFullDays >= 30) 'salah30',
  if (waterDays >= 30) 'water30',
  if (monthUnderBudget) 'saver',
};

/// Plain streak re-export so game code has one import.
int plainStreak(Set<String> days, String today) => currentStreak(days, today);
