/// Life Score (0–100): tasks, habits, daily targets, Salah, sleep, water,
/// Build Hour and money discipline.
///
/// Each component is a ratio 0..1, or null when the module is off or there's
/// nothing to measure today (e.g. no tasks). Null components are left out
/// and the remaining weights are rescaled, so the score is always out of 100.
class LifeInputs {
  const LifeInputs({this.tasks, this.habits, this.targets, this.salah, this.sleep, this.water, this.build, this.money});

  final double? tasks;
  final double? habits;
  final double? targets;
  final double? salah;
  final double? sleep;
  final double? water;
  final double? build;
  final double? money;
}

class LifeWeights {
  static const tasks = 15.0;
  static const habits = 12.0;
  static const targets = 13.0;
  static const salah = 15.0;
  static const sleep = 13.0;
  static const water = 10.0;
  static const build = 12.0;
  static const money = 10.0;
}

int lifeScore(LifeInputs i) {
  final parts = <(double?, double)>[
    (i.tasks, LifeWeights.tasks),
    (i.habits, LifeWeights.habits),
    (i.targets, LifeWeights.targets),
    (i.salah, LifeWeights.salah),
    (i.sleep, LifeWeights.sleep),
    (i.water, LifeWeights.water),
    (i.build, LifeWeights.build),
    (i.money, LifeWeights.money),
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
