/// Life Score v1 (0–100) from the Phase 1 modules.
///
/// Each component is a ratio 0..1, or null when the module is disabled or has
/// nothing to measure today (e.g. no tasks). Null components are left out and
/// the remaining weights are renormalised.
class LifeInputs {
  const LifeInputs({this.tasks, this.habits, this.salah, this.water, this.sleep});

  final double? tasks;
  final double? habits;
  final double? salah;
  final double? water;
  final double? sleep;
}

class LifeWeights {
  static const tasks = 25.0;
  static const habits = 20.0;
  static const salah = 20.0;
  static const water = 15.0;
  static const sleep = 20.0;
}

int lifeScore(LifeInputs i) {
  final parts = <(double?, double)>[
    (i.tasks, LifeWeights.tasks),
    (i.habits, LifeWeights.habits),
    (i.salah, LifeWeights.salah),
    (i.water, LifeWeights.water),
    (i.sleep, LifeWeights.sleep),
  ];
  var sum = 0.0, weight = 0.0;
  for (final (v, w) in parts) {
    if (v == null) continue;
    sum += v.clamp(0.0, 1.0) * w;
    weight += w;
  }
  if (weight == 0) return 0;
  return (sum / weight * 100).round().clamp(0, 100);
}

double ratio(num done, num total) => total <= 0 ? 0 : (done / total).clamp(0, 1).toDouble();
