import 'package:flutter_test/flutter_test.dart';
import 'package:nizam/core/time/day_clock.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

void main() {
  setUpAll(tzdata.initializeTimeZones);

  DayClock at(DateTime utc, {int rollover = 6}) =>
      DayClock(location: tz.getLocation('Asia/Kolkata'), rolloverHour: rollover, now: () => utc);

  // IST = UTC+5:30, so 05:45 IST = 00:15 UTC.
  final ist0545 = DateTime.utc(2026, 11, 15, 0, 15);
  final ist0600 = DateTime.utc(2026, 11, 15, 0, 30);

  test('Good Night at 05:45 IST belongs to the previous day', () {
    expect(at(ist0545).today(), '2026-11-14');
  });

  test('06:00 IST starts the new day', () {
    expect(at(ist0600).today(), '2026-11-15');
  });

  test('custom rollover hour', () {
    expect(at(ist0600, rollover: 7).today(), '2026-11-14');
    expect(at(ist0545, rollover: 0).today(), '2026-11-15');
  });

  test('month and year boundaries', () {
    // 2027-01-01 03:00 IST -> still 2026-12-31.
    expect(at(DateTime.utc(2026, 12, 31, 21, 30)).today(), '2026-12-31');
    // 2026-03-01 05:59 IST -> Feb 28 (2026 is not a leap year).
    expect(at(DateTime.utc(2026, 3, 1, 0, 29)).today(), '2026-02-28');
    expect(DayKey.add('2028-02-28', 1), '2028-02-29');
    expect(DayKey.add('2026-12-31', 1), '2027-01-01');
  });

  test('day start/end are 06:00 IST in UTC', () {
    final c = at(ist0600);
    expect(c.dayStartUtc('2026-11-15'), DateTime.utc(2026, 11, 15, 0, 30));
    expect(c.dayEndUtc('2026-11-15'), DateTime.utc(2026, 11, 16, 0, 30));
  });

  test('UTC <-> IST round trip', () {
    final c = at(ist0600);
    final utc = c.localToUtc('2026-11-15', 23, 10);
    expect(utc, DateTime.utc(2026, 11, 15, 17, 40));
    final l = c.toLocal(utc);
    expect([l.hour, l.minute, l.day], [23, 10, 15]);
    expect(c.calendarDateFor(ist0545), '2026-11-15');
  });

  test('DayKey helpers', () {
    expect(DayKey.diff('2026-11-10', '2026-11-15'), 5);
    expect(DayKey.weekday('2026-11-15'), DateTime.sunday);
  });
}
