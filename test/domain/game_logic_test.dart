import 'package:flutter_test/flutter_test.dart';
import 'package:nizam/core/time/day_clock.dart';
import 'package:nizam/features/game/domain/game_logic.dart';
import 'package:nizam/features/game/domain/nudges.dart';

Set<String> days(String from, int n, {Set<int> skip = const {}}) => {
  for (var i = 0; i < n; i++)
    if (!skip.contains(i)) DayKey.add(from, i),
};

void main() {
  group('quests & boss', () {
    test('3 distinct quests, stable for the day, different on other days', () {
      final pool = List.generate(12, (i) => i + 1);
      final a = pickDailyQuests(pool, '2026-11-15');
      expect(a.toSet(), hasLength(3));
      expect(pickDailyQuests(pool.reversed.toList(), '2026-11-15'), a, reason: 'pool order does not matter');
      final week = {for (var d = 0; d < 7; d++) pickDailyQuests(pool, DayKey.add('2026-11-15', d)).join(',')};
      expect(week.length, greaterThan(4));
      expect(pickDailyQuests([5], '2026-11-15'), [5]);
      expect(pickDailyQuests([], '2026-11-15'), isEmpty);
    });

    test('weekly boss is stable within a week', () {
      final pool = [1, 2, 3, 4, 5, 6, 7];
      expect(pickBoss(pool, '2026-11-16'), pickBoss(pool, '2026-11-16'));
      expect(pickBoss(const [], '2026-11-16'), isNull);
    });
  });

  group('streak shields', () {
    test('a week with 5+ active days earns one', () {
      expect(weekEarnsShield(days('2026-11-09', 7, skip: {2, 5}), '2026-11-09'), isTrue);
      expect(weekEarnsShield(days('2026-11-09', 7, skip: {1, 2, 5}), '2026-11-09'), isFalse);
    });

    test('only a missed day right after an active day needs a shield', () {
      const today = '2026-11-15';
      final active = days('2026-11-10', 4); // 10..13 active, 14 missed
      expect(dayNeedingShield(active, {}, today), '2026-11-14');
      expect(dayNeedingShield(active, {'2026-11-14'}, today), isNull, reason: 'already covered');
      expect(dayNeedingShield(days('2026-11-10', 3), {}, today), isNull, reason: 'streak was already broken');
      expect(dayNeedingShield(days('2026-11-10', 5), {}, today), isNull, reason: 'yesterday was active');
    });

    test('shielded days keep the streak but do not add to it', () {
      final active = days('2026-11-10', 6, skip: {4}); // 10,11,12,13,15 — 14 missed
      expect(streakWithShields(active, {}, '2026-11-15'), 1);
      expect(streakWithShields(active, {'2026-11-14'}, '2026-11-15'), 5);
    });
  });

  group('plant', () {
    test('grows with consistency, wilts after 2 idle days', () {
      const today = '2026-11-15';
      expect(plantState({}, today).stage, 0);
      expect(plantState(days('2026-11-02', 14), today).stage, 5);
      expect(plantState(days('2026-11-02', 14), today).wilting, isFalse);
      final idle = days('2026-11-02', 11); // last active 11-12
      expect(plantState(idle, today).wilting, isTrue);
      expect(plantState(idle, today).name, contains('thirsty'));
    });
  });

  group('stats', () {
    test('pearson', () {
      expect(pearson([1, 2, 3, 4, 5], [2, 4, 6, 8, 10]), closeTo(1, 1e-9));
      expect(pearson([1, 2, 3, 4, 5], [5, 4, 3, 2, 1]), closeTo(-1, 1e-9));
      expect(pearson([1, 2, 3], [1, 2, 3]), isNull, reason: 'too few points');
      expect(pearson([1, 1, 1, 1, 1], [1, 2, 3, 4, 5]), isNull, reason: 'flat');
      expect(describeCorrelation(.7, 'sleep', 'mood'), contains('strongly'));
    });

    test('money discipline', () {
      expect(moneyDiscipline(spentTodayPaise: 50000, monthlyBudgetPaise: 3000000, daysInMonth: 30), 1);
      expect(moneyDiscipline(spentTodayPaise: 150000, monthlyBudgetPaise: 3000000, daysInMonth: 30), closeTo(.5, 1e-9));
      expect(moneyDiscipline(spentTodayPaise: 999999, monthlyBudgetPaise: 3000000, daysInMonth: 30), 0);
      expect(moneyDiscipline(spentTodayPaise: 999999, monthlyBudgetPaise: 0, daysInMonth: 30), 1);
    });

    test('badges', () {
      final b = earnedBadges(
        bestStreak: 8,
        level: 5,
        buildHours: 2,
        leads: 120,
        closed: 0,
        emails: 0,
        meetings: 0,
        salahFullDays: 0,
        waterDays: 0,
        monthUnderBudget: true,
      );
      expect(b, {'streak7', 'level5', 'leads100', 'saver'});
    });
  });

  group('nudges', () {
    const base = NudgeContext(day: '2026-11-15', localHour: 21, quiet: false, targetsLeft: 2);

    test('9 PM with targets open suggests a sprint', () {
      final n = evaluateNudges(base);
      expect(n.map((x) => x.type), contains('targets'));
    });

    test('quiet hours, switched-off types and already-sent ones are skipped', () {
      expect(
        evaluateNudges(const NudgeContext(day: '2026-11-15', localHour: 21, quiet: true, targetsLeft: 2)),
        isEmpty,
      );
      expect(
        evaluateNudges(
          const NudgeContext(day: '2026-11-15', localHour: 21, quiet: false, targetsLeft: 2, off: {'targets'}),
        ).map((x) => x.type),
        isNot(contains('targets')),
      );
      expect(evaluateNudges(base, alreadySent: {'targets:2026-11-15'}).map((x) => x.type), isNot(contains('targets')));
    });

    test('budget, meeting, screen-time and review rules', () {
      final n = evaluateNudges(
        const NudgeContext(
          day: '2026-11-15',
          localHour: 19,
          quiet: false,
          meetingsAwaitingActions: 1,
          budgetWarnings: ['₹500 left for Food this month'],
          overLimitApps: ['Instagram'],
          isReviewDay: true,
          buildMinutesToday: 60,
        ),
      );
      expect(n.map((x) => x.type).toSet(), {'meeting', 'budget', 'screen', 'review'});
      expect(n.firstWhere((x) => x.type == 'budget').body, '₹500 left for Food this month');
    });
  });
}
