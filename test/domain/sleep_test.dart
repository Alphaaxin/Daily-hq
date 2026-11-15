import 'package:flutter_test/flutter_test.dart';
import 'package:nizam/core/time/day_clock.dart';
import 'package:nizam/features/sleep/domain/sleep_logic.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

void main() {
  setUpAll(tzdata.initializeTimeZones);

  DayClock clockAtIst(int y, int m, int d, int h, int min) {
    final loc = tz.getLocation('Asia/Kolkata');
    final utc = tz.TZDateTime(loc, y, m, d, h, min).toUtc();
    return DayClock(location: loc, now: () => utc);
  }

  DateTime ist(int d, int h, int m) => tz.TZDateTime(tz.getLocation('Asia/Kolkata'), 2026, 11, d, h, m).toUtc();

  test('duration across midnight and the credit day', () {
    final c = clockAtIst(2026, 11, 15, 13, 0);
    final s = SleepSpan(sleptAt: ist(15, 5, 30), wokeAt: ist(15, 12, 45));
    expect(s.duration, const Duration(hours: 7, minutes: 15));
    expect(c.dayKeyFor(s.sleptAt), '2026-11-14'); // Good Night at 05:30 = previous day
    expect(sleepCreditDay(c, s), '2026-11-15'); // credited to the day you woke into
    final early = SleepSpan(sleptAt: ist(14, 23, 30), wokeAt: ist(15, 7, 0));
    expect(early.duration, const Duration(hours: 7, minutes: 30));
  });

  group('forgot detection', () {
    test('asleep for more than 14h asks for wake time', () {
      final c = clockAtIst(2026, 11, 15, 22, 0);
      final s = SleepSpan(sleptAt: ist(15, 5, 0));
      expect(sleepPrompt(clock: c, latest: s), SleepPrompt.askWake);
      final c2 = clockAtIst(2026, 11, 15, 12, 0);
      expect(sleepPrompt(clock: c2, latest: s), SleepPrompt.none);
    });

    test('last wake before today began asks for both', () {
      final c = clockAtIst(2026, 11, 15, 14, 0);
      final s = SleepSpan(sleptAt: ist(13, 5, 0), wokeAt: ist(13, 12, 0));
      expect(sleepPrompt(clock: c, latest: s), SleepPrompt.askSleepAndWake);
    });

    test('woke today: no prompt; dismissed: no prompt; fresh install: no prompt', () {
      final c = clockAtIst(2026, 11, 15, 14, 0);
      final ok = SleepSpan(sleptAt: ist(15, 5, 0), wokeAt: ist(15, 12, 0));
      expect(sleepPrompt(clock: c, latest: ok), SleepPrompt.none);
      final old = SleepSpan(sleptAt: ist(13, 5, 0), wokeAt: ist(13, 12, 0));
      expect(sleepPrompt(clock: c, latest: old, dismissedFor: '2026-11-15'), SleepPrompt.none);
      expect(sleepPrompt(clock: c, latest: null), SleepPrompt.none);
    });

    test('at 3 AM, a wake-up from yesterday noon is still the same day', () {
      final c = clockAtIst(2026, 11, 16, 3, 0); // logical day 2026-11-15
      final s = SleepSpan(sleptAt: ist(15, 5, 0), wokeAt: ist(15, 12, 0));
      expect(sleepPrompt(clock: c, latest: s), SleepPrompt.none);
    });
  });

  group('bedtime suggestion', () {
    test('suggests 15 min before the average bedtime, handling midnight wrap', () {
      final c = clockAtIst(2026, 11, 15, 14, 0);
      final recent = [
        SleepSpan(sleptAt: ist(14, 23, 30), wokeAt: ist(15, 5, 30)), // 6h
        SleepSpan(sleptAt: ist(14, 0, 30), wokeAt: ist(14, 6, 30)), // 6h
        SleepSpan(sleptAt: ist(13, 0, 0), wokeAt: ist(13, 6, 0)), // 6h
      ];
      final s = bedtimeSuggestion(clock: c, recent: recent, targetHours: 7)!;
      expect(s.averageBedtimeMin, 0); // avg of 23:30, 00:30, 00:00 = 00:00
      expect(s.suggestedMin, 23 * 60 + 45);
      expect(s.averageSleep, const Duration(hours: 6));
    });

    test('no suggestion when on target or with too little data', () {
      final c = clockAtIst(2026, 11, 15, 14, 0);
      final good = List.generate(3, (i) => SleepSpan(sleptAt: ist(10 + i, 0, 0), wokeAt: ist(10 + i, 8, 0)));
      expect(bedtimeSuggestion(clock: c, recent: good, targetHours: 7), isNull);
      expect(bedtimeSuggestion(clock: c, recent: good.take(2).toList(), targetHours: 9), isNull);
    });
  });

  test('manual entry: slept 5:30, woke 12:45 today', () {
    final c = clockAtIst(2026, 11, 15, 14, 0);
    final s = manualSpan(c, 5, 30, 12, 45);
    expect(s.sleptAt, ist(15, 5, 30));
    expect(s.wokeAt, ist(15, 12, 45));
  });

  test('manual entry: slept 23:00, woke 07:00 (crosses midnight)', () {
    final c = clockAtIst(2026, 11, 15, 9, 0);
    final s = manualSpan(c, 23, 0, 7, 0);
    expect(s.sleptAt, ist(14, 23, 0));
    expect(s.wokeAt, ist(15, 7, 0));
  });

  test('manual entry: wake time later than now means yesterday', () {
    final c = clockAtIst(2026, 11, 15, 9, 0);
    final s = manualSpan(c, 5, 0, 12, 0);
    expect(s.wokeAt, ist(14, 12, 0));
    expect(s.sleptAt, ist(14, 5, 0));
  });

  test('formatting', () {
    expect(fmtDuration(const Duration(minutes: 425)), '7h 05m');
    expect(fmtDuration(const Duration(minutes: 42)), '42m');
    expect(fmtClock(0), '12:00 AM');
    expect(fmtClock(23 * 60 + 45), '11:45 PM');
  });
}
