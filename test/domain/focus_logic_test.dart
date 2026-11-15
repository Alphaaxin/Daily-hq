import 'package:flutter_test/flutter_test.dart';
import 'package:nizam/features/focus/domain/focus_logic.dart';

void main() {
  final t0 = DateTime.utc(2026, 11, 15, 10);

  group('elapsed', () {
    test('running, paused, finished', () {
      expect(elapsedSeconds(startUtc: t0, bankedSeconds: 0, nowUtc: t0.add(const Duration(minutes: 5))), 300);
      expect(
        elapsedSeconds(startUtc: t0, bankedSeconds: 120, pausedAtUtc: t0, nowUtc: t0.add(const Duration(hours: 3))),
        120,
      );
      expect(
        elapsedSeconds(startUtc: t0, bankedSeconds: 60, endUtc: t0.add(const Duration(seconds: 90)), nowUtc: t0),
        150,
      );
    });

    test('a clock skew never goes negative', () {
      expect(elapsedSeconds(startUtc: t0, bankedSeconds: 10, nowUtc: t0.subtract(const Duration(minutes: 1))), 10);
    });
  });

  group('Build Hour XP', () {
    test('+10 per 15 min, full hour = 50, capped', () {
      expect(buildHourXp(0), 0);
      expect(buildHourXp(14), 0);
      expect(buildHourXp(15), 10);
      expect(buildHourXp(44), 20);
      expect(buildHourXp(59), 30);
      expect(buildHourXp(60), 50);
      expect(buildHourXp(180), 50);
    });

    test('streak counts days with 60+ minutes', () {
      final m = {'2026-11-13': 60, '2026-11-14': 75, '2026-11-15': 30};
      expect(buildStreak(m, '2026-11-15'), 2); // today unfinished doesn't break it
      expect(buildStreak({...m, '2026-11-15': 61}, '2026-11-15'), 3);
      expect(buildStreak({'2026-11-12': 90, '2026-11-14': 90}, '2026-11-15'), 1);
    });
  });

  test('pomodoro XP only for a finished block', () {
    expect(pomodoroXp(24 * 60, 25), 0);
    expect(pomodoroXp(25 * 60, 25), 10);
  });

  group('time tracking', () {
    const logs = [
      TimeLog(day: '2026-11-09', seconds: 3600, profileId: 1, kind: FocusKind.work),
      TimeLog(day: '2026-11-10', seconds: 5400, profileId: 2, kind: FocusKind.work, note: 'Retainer "deck"'),
      TimeLog(day: '2026-11-15', seconds: 1800, profileId: 2, kind: FocusKind.pomodoro),
      TimeLog(day: '2026-11-16', seconds: 900, kind: FocusKind.build),
    ];

    test('week starts Monday', () {
      expect(weekStart('2026-11-15'), '2026-11-09'); // Sunday → Monday before
      expect(weekStart('2026-11-16'), '2026-11-16');
    });

    test('totals by profile within a range', () {
      final t = totalsByProfile(logs, '2026-11-09', '2026-11-15');
      expect(t, {1: 3600, 2: 7200});
      expect(totalsByProfile(logs, '2026-11-16', '2026-11-22'), {null: 900});
    });

    test('CSV export escapes quotes and rounds hours', () {
      final csv = timeLogCsv(logs.take(2), {1: 'Zillvox', 2: 'Triumphs of Talent'});
      final lines = csv.trim().split('\n');
      expect(lines.first, 'Date,Profile,Type,Hours,Minutes,Note');
      expect(lines[1], '2026-11-09,"Zillvox","Work timer",1.00,60,""');
      expect(lines[2], '2026-11-10,"Triumphs of Talent","Work timer",1.50,90,"Retainer ""deck"""');
    });

    test('hours format', () {
      expect(fmtHours(5400), '1h 30m');
      expect(fmtHours(600), '10m');
    });
  });
}
