import 'package:flutter_test/flutter_test.dart';
import 'package:nizam/features/gamification/domain/life_score.dart';
import 'package:nizam/features/gamification/domain/streaks.dart';

void main() {
  group('streaks', () {
    const today = '2026-11-15';

    test('counts back from today when today is done', () {
      expect(currentStreak({'2026-11-13', '2026-11-14', '2026-11-15'}, today), 3);
    });

    test('an unfinished today does not break the streak', () {
      expect(currentStreak({'2026-11-13', '2026-11-14'}, today), 2);
    });

    test('a gap breaks it', () {
      expect(currentStreak({'2026-11-11', '2026-11-12', '2026-11-14'}, today), 1);
      expect(currentStreak({'2026-11-12', '2026-11-13'}, today), 0);
    });

    test('works across months', () {
      expect(currentStreak({'2026-10-31', '2026-11-01'}, '2026-11-01'), 2);
    });

    test('best streak', () {
      expect(bestStreak({}), 0);
      expect(bestStreak({'2026-11-01', '2026-11-02', '2026-11-03', '2026-11-07', '2026-11-08'}), 3);
    });
  });

  group('life score', () {
    const all1 = LifeInputs(tasks: 1, habits: 1, targets: 1, salah: 1, sleep: 1, water: 1, build: 1, money: 1);
    const all0 = LifeInputs(tasks: 0, habits: 0, targets: 0, salah: 0, sleep: 0, water: 0, build: 0, money: 0);

    test('perfect day is 100, empty is 0', () {
      expect(lifeScore(all1), 100);
      expect(lifeScore(all0), 0);
      expect(lifeScore(const LifeInputs()), 0);
    });

    test('weights add up to 100', () {
      const w = [
        LifeWeights.tasks,
        LifeWeights.habits,
        LifeWeights.targets,
        LifeWeights.salah,
        LifeWeights.sleep,
        LifeWeights.water,
        LifeWeights.build,
        LifeWeights.money,
      ];
      expect(w.reduce((a, b) => a + b), 100);
      expect(
        lifeScore(const LifeInputs(tasks: 1, habits: 0, targets: 0, salah: 0, sleep: 0, water: 0, build: 0, money: 0)),
        15,
      );
      expect(
        lifeScore(const LifeInputs(tasks: 0, habits: 0, targets: 0, salah: 0, sleep: 0, water: 1, build: 0, money: 0)),
        10,
      );
      expect(
        lifeScore(
          const LifeInputs(tasks: .5, habits: .5, targets: .5, salah: .5, sleep: .5, water: .5, build: .5, money: .5),
        ),
        50,
      );
    });

    test('clamps out-of-range ratios', () {
      expect(
        lifeScore(const LifeInputs(tasks: 3, habits: 1, targets: 1, salah: 1, sleep: 1, water: 1, build: 1, money: 1)),
        100,
      );
      expect(lifeScore(const LifeInputs(tasks: -1)), 0);
    });

    test('disabled modules are left out and weights renormalised', () {
      expect(lifeScore(const LifeInputs(water: 1)), 100);
      // salah 15 done + tasks 15 not done → 50
      expect(lifeScore(const LifeInputs(salah: 1, tasks: 0)), 50);
    });

    test('ratio helper', () {
      expect(ratio(3, 0), 0);
      expect(ratio(9, 8), 1);
      expect(ratio(2, 8), .25);
    });
  });
}
