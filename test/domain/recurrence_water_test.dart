import 'package:flutter_test/flutter_test.dart';
import 'package:nizam/core/time/day_clock.dart';
import 'package:nizam/features/tasks/domain/recurrence.dart';
import 'package:nizam/features/water/domain/water_schedule.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

void main() {
  tzdata.initializeTimeZones();

  group('recurrence', () {
    // 2026-11-13 is a Friday.
    test('daily', () {
      const r = Recurrence(RepeatFreq.daily);
      expect(r.nextAfter('2026-11-13'), '2026-11-14');
      expect(r.toRRule(), 'FREQ=DAILY');
    });

    test('weekdays skip the weekend', () {
      const r = Recurrence(RepeatFreq.weekdays);
      expect(r.nextAfter('2026-11-13'), '2026-11-16');
      expect(r.occursOn('2026-11-14'), isFalse);
      expect(Recurrence.fromRRule(r.toRRule()).freq, RepeatFreq.weekdays);
    });

    test('weekly on chosen days', () {
      const r = Recurrence(RepeatFreq.weekly, {2, 5}); // Tue, Fri
      expect(r.nextAfter('2026-11-13'), '2026-11-17');
      expect(r.nextAfter('2026-11-17'), '2026-11-20');
      expect(r.toRRule(), 'FREQ=WEEKLY;BYDAY=TU,FR');
      final back = Recurrence.fromRRule('FREQ=WEEKLY;BYDAY=TU,FR');
      expect(back.days, {2, 5});
      expect(back.label, 'Tue Fri');
    });

    test('none / invalid', () {
      expect(Recurrence.none.nextAfter('2026-11-13'), isNull);
      expect(const Recurrence(RepeatFreq.weekly).nextAfter('2026-11-13'), isNull);
      expect(Recurrence.fromRRule(null).repeats, isFalse);
      expect(Recurrence.fromRRule('FREQ=YEARLY').repeats, isFalse);
    });
  });

  group('water reminders', () {
    final loc = tz.getLocation('Asia/Kolkata');
    DateTime ist(int h, int m) => tz.TZDateTime(loc, 2026, 11, 15, h, m).toUtc();
    final clock = DayClock(location: loc, now: () => ist(13, 0));

    test('stop once the goal is reached', () {
      expect(
        waterReminderTimes(
          clock: clock,
          glasses: 8,
          goal: 8,
          interval: const Duration(minutes: 90),
          windowEndUtc: ist(23, 59),
        ),
        isEmpty,
      );
    });

    test('every interval after the last glass, within the window', () {
      final t = waterReminderTimes(
        clock: clock,
        glasses: 2,
        goal: 8,
        interval: const Duration(minutes: 90),
        lastDrinkUtc: ist(12, 30),
        windowEndUtc: ist(18, 0),
      );
      expect(t, [ist(14, 0), ist(15, 30), ist(17, 0)]);
    });

    test('skips quiet hours that wrap midnight', () {
      expect(inQuietHours(clock, ist(2, 0), 1, 10), isTrue);
      expect(inQuietHours(clock, ist(11, 0), 1, 10), isFalse);
      expect(inQuietHours(clock, ist(23, 30), 23, 7), isTrue);
      expect(inQuietHours(clock, ist(12, 0), 5, 5), isFalse);
    });
  });
}
