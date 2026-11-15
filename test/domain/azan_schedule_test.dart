import 'package:flutter_test/flutter_test.dart';
import 'package:nizam/core/time/day_clock.dart';
import 'package:nizam/features/salah/domain/azan_schedule.dart';
import 'package:nizam/features/salah/domain/prayer_times.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

void main() {
  tzdata.initializeTimeZones();
  final loc = tz.getLocation('Asia/Kolkata');
  final calc = PrayerCalculator(const PrayerConfig());
  final day15 = calc.forDate('2026-11-15');

  DayClock at(DateTime utc) => DayClock(location: loc, now: () => utc);

  test('3 days ahead, past prayers skipped', () {
    // Just after Dhuhr on the 15th: Fajr and Dhuhr today are past.
    final c = at(day15.start(Prayer.dhuhr).add(const Duration(minutes: 1)));
    final l = azanSchedule(calc: calc, clock: c, baseId: 6000);
    expect(l.length, 3 + 5 + 5);
    expect(l.first.payload, 'salah:2026-11-15:asr');
    expect(l.first.atUtc, day15.start(Prayer.asr));
    expect(l.map((a) => a.id).toSet().length, l.length, reason: 'ids are unique');
    expect(l.every((a) => a.atUtc.isAfter(c.nowUtc())), isTrue);
  });

  test('switched-off prayers and the 10-minute reminder', () {
    final c = at(day15.start(Prayer.fajr).subtract(const Duration(hours: 1)));
    final l = azanSchedule(calc: calc, clock: c, baseId: 6000, days: 1, off: {Prayer.isha}, beforeMinutes: 10);
    expect(l.where((a) => a.payload.endsWith(':isha')), isEmpty);
    expect(l.length, 8); // 4 prayers × (chime + reminder)
    final asr = l.where((a) => a.payload.endsWith(':asr')).toList();
    expect(asr.map((a) => a.atUtc.difference(day15.start(Prayer.asr)).inMinutes).toSet(), {0, -10});
  });

  test('ids are stable across re-plans on the same day', () {
    final a = azanSchedule(calc: calc, clock: at(day15.start(Prayer.fajr)), baseId: 6000);
    final b = azanSchedule(
      calc: calc,
      clock: at(day15.start(Prayer.fajr).add(const Duration(seconds: 1))),
      baseId: 6000,
    );
    expect(b.first.id, a.firstWhere((x) => x.payload == b.first.payload).id);
  });
}
