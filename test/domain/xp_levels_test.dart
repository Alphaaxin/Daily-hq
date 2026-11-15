import 'package:flutter_test/flutter_test.dart';
import 'package:nizam/features/gamification/domain/levels.dart';
import 'package:nizam/features/gamification/domain/xp_rules.dart';

void main() {
  group('levels', () {
    test('thresholds follow 50·L·(L−1)', () {
      expect([1, 2, 3, 4, 5].map(xpForLevel).toList(), [0, 100, 300, 600, 1000]);
    });

    test('levelFor boundaries', () {
      expect(levelFor(0).level, 1);
      expect(levelFor(99).level, 1);
      expect(levelFor(100).level, 2);
      expect(levelFor(299).level, 2);
      expect(levelFor(300).level, 3);
      expect(levelFor(-50).level, 1);
    });

    test('progress and toNext', () {
      final l = levelFor(200); // level 2: 100 → 300
      expect(l.progress, closeTo(0.5, 1e-9));
      expect(l.toNext, 100);
      expect(l.name, 'Starter');
    });

    test('names, including beyond Legend', () {
      expect(levelName(1), 'Rookie');
      expect(levelName(10), 'Legend');
      expect(levelName(11), 'Legend II');
      expect(levelName(13), 'Legend IV');
      expect(levelFor(xpForLevel(10)).name, 'Legend');
    });
  });

  group('ledger', () {
    test('awarding the same source twice on a day is idempotent', () {
      final x = XpLedgerModel();
      expect(x.set('2026-11-15', 'habit:1', 5), 5);
      expect(x.set('2026-11-15', 'habit:1', 5), 0);
      expect(x.total, 5);
    });

    test('un-award removes the XP', () {
      final x = XpLedgerModel()..set('d', 'task:1', 10);
      expect(x.set('d', 'task:1', 0), -10);
      expect(x.total, 0);
    });

    test('changing the amount applies the difference', () {
      final x = XpLedgerModel()..set('d', Xp.sleepKey, Xp.goodMorning);
      expect(x.set('d', Xp.sleepKey, Xp.goodMorningOnTarget), 5);
      expect(x.total, 15);
    });

    test('same source on different days counts separately', () {
      final x = XpLedgerModel()
        ..set('a', Xp.moodKey, 2)
        ..set('b', Xp.moodKey, 2);
      expect(x.total, 4);
      expect(x.dayTotal('a'), 2);
    });

    test('redeeming reduces the balance, never the level', () {
      final x = XpLedgerModel()..set('d', 'big', 600);
      expect(x.redeem(500), isTrue);
      expect(x.balance, 100);
      expect(x.total, 600);
      expect(levelFor(x.total).level, 4);
      expect(x.redeem(200), isFalse);
      expect(x.redeem(0), isFalse);
    });
  });
}
