import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:nizam/core/time/day_clock.dart';
import 'package:nizam/features/salah/domain/prayer_times.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

/// Independent reference implementation of the standard solar prayer-time
/// formulas (as used by PrayTimes.org), to cross-check the adhan package.
class _Ref {
  _Ref(this.lat, this.lng);
  final double lat, lng;

  static double _d2r(double d) => d * math.pi / 180;
  static double _r2d(double r) => r * 180 / math.pi;
  static double _fix(double a, double b) {
    a = a - b * (a / b).floorToDouble();
    return a < 0 ? a + b : a;
  }

  (double decl, double eqt) _sun(double jd) {
    final d = jd - 2451545.0;
    final g = _fix(357.529 + 0.98560028 * d, 360);
    final q = _fix(280.459 + 0.98564736 * d, 360);
    final l = _fix(q + 1.915 * math.sin(_d2r(g)) + 0.020 * math.sin(_d2r(2 * g)), 360);
    final e = 23.439 - 0.00000036 * d;
    final ra = _r2d(math.atan2(math.cos(_d2r(e)) * math.sin(_d2r(l)), math.cos(_d2r(l)))) / 15;
    final eqt = q / 15 - _fix(ra, 24);
    final decl = _r2d(math.asin(math.sin(_d2r(e)) * math.sin(_d2r(l))));
    return (decl, eqt);
  }

  double _julian(int y, int m, int d) {
    if (m <= 2) {
      y -= 1;
      m += 12;
    }
    final a = (y / 100).floor();
    final b = 2 - a + (a / 4).floor();
    return (365.25 * (y + 4716)).floor() + (30.6001 * (m + 1)).floor() + d + b - 1524.5;
  }

  /// Returns UTC hours for the day.
  Map<String, double> times(int y, int m, int d, {required double fajr, required double isha, required int asrFactor}) {
    final jd = _julian(y, m, d) - lng / (15 * 24);
    double noon(double t) => _fix(12 - _sun(jd + t).$2, 24);
    double angleTime(double angle, double t, {bool ccw = false}) {
      final decl = _sun(jd + t).$1;
      final n = noon(t);
      final x =
          (-math.sin(_d2r(angle)) - math.sin(_d2r(decl)) * math.sin(_d2r(lat))) /
          (math.cos(_d2r(decl)) * math.cos(_d2r(lat)));
      final tt = _r2d(math.acos(x)) / 15;
      return n + (ccw ? -tt : tt);
    }

    double asr(double t) {
      final decl = _sun(jd + t).$1;
      final a = -_r2d(math.atan(1 / (asrFactor + math.tan(_d2r((lat - decl).abs())))));
      return angleTime(a, t);
    }

    // two passes for accuracy
    var r = {'fajr': 5.0, 'sunrise': 6.0, 'dhuhr': 12.0, 'asr': 13.0, 'maghrib': 18.0, 'isha': 18.0};
    for (var i = 0; i < 2; i++) {
      final t = r.map((k, v) => MapEntry(k, v / 24));
      r = {
        'fajr': angleTime(fajr, t['fajr']!, ccw: true),
        'sunrise': angleTime(0.833, t['sunrise']!, ccw: true),
        'dhuhr': noon(t['dhuhr']!),
        'asr': asr(t['asr']!),
        'maghrib': angleTime(0.833, t['maghrib']!),
        'isha': angleTime(isha, t['isha']!),
      };
    }
    return r.map((k, v) => MapEntry(k, v - lng / 15));
  }
}

void main() {
  setUpAll(tzdata.initializeTimeZones);
  const hyd = PrayerConfig(); // Hyderabad, Karachi method, Hanafi Asr
  final calc = PrayerCalculator(hyd);
  final ref = _Ref(hyd.latitude, hyd.longitude);

  for (final date in ['2026-01-01', '2026-03-20', '2026-06-21', '2026-09-15', '2026-11-15']) {
    test('Hyderabad $date matches the reference within 2 min', () {
      final p = calc.forDate(date);
      final d = DayKey.toDate(date);
      final r = ref.times(d.year, d.month, d.day, fajr: 18, isha: 18, asrFactor: 2);
      DateTime at(double h) => DateTime.utc(d.year, d.month, d.day).add(Duration(seconds: (h * 3600).round()));
      void near(DateTime got, double h, String what) {
        final diff = got.difference(at(h)).inSeconds.abs();
        expect(diff, lessThanOrEqualTo(150), reason: '$what off by ${diff}s (got $got, want ${at(h)})');
      }

      near(p.start(Prayer.fajr), r['fajr']!, 'fajr');
      near(p.sunrise, r['sunrise']!, 'sunrise');
      near(p.start(Prayer.dhuhr), r['dhuhr']!, 'dhuhr');
      near(p.start(Prayer.asr), r['asr']!, 'asr');
      near(p.start(Prayer.maghrib), r['maghrib']!, 'maghrib');
      near(p.start(Prayer.isha), r['isha']!, 'isha');
    });
  }

  test('times are in a sane IST range and ordered', () {
    final loc = tz.getLocation('Asia/Kolkata');
    final p = calc.forDate('2026-11-15');
    final l = Prayer.values.map((x) => tz.TZDateTime.from(p.start(x), loc)).toList();
    expect(l[0].hour, inInclusiveRange(4, 5)); // Fajr
    expect(l[1].hour, 12); // Dhuhr
    expect(l[2].hour, inInclusiveRange(15, 16)); // Asr (Hanafi)
    expect(l[3].hour, 17); // Maghrib
    expect(l[4].hour, inInclusiveRange(18, 19)); // Isha
    for (var i = 1; i < l.length; i++) {
      expect(l[i].isAfter(l[i - 1]), isTrue);
    }
    expect(p.nextFajr.isAfter(p.start(Prayer.isha)), isTrue);
  });

  test('Hanafi Asr is later than Shafi', () {
    final h = calc.forDate('2026-11-15').start(Prayer.asr);
    final s = PrayerCalculator(const PrayerConfig(hanafiAsr: false)).forDate('2026-11-15').start(Prayer.asr);
    expect(h.isAfter(s.add(const Duration(minutes: 30))), isTrue);
  });

  group('status', () {
    final p = calc.forDate('2026-11-15');
    final dhuhr = p.start(Prayer.dhuhr), asr = p.start(Prayer.asr);

    test('on time inside the window, late after', () {
      expect(p.classifyMark(Prayer.dhuhr, dhuhr.add(const Duration(minutes: 10))), SalahStatus.onTime);
      expect(p.classifyMark(Prayer.dhuhr, asr.add(const Duration(minutes: 1))), SalahStatus.late);
      expect(p.classifyMark(Prayer.fajr, p.sunrise.add(const Duration(minutes: 1))), SalahStatus.late);
    });

    test('upcoming → open → missed when unmarked', () {
      expect(p.statusAt(Prayer.dhuhr, dhuhr.subtract(const Duration(minutes: 1)), null), SalahStatus.upcoming);
      expect(p.statusAt(Prayer.dhuhr, dhuhr.add(const Duration(minutes: 1)), null), SalahStatus.open);
      expect(p.statusAt(Prayer.dhuhr, asr.add(const Duration(minutes: 1)), null), SalahStatus.missed);
      expect(p.statusAt(Prayer.dhuhr, asr.add(const Duration(hours: 1)), SalahStatus.late), SalahStatus.late);
    });

    test('Isha stays open until next Fajr', () {
      expect(p.windowEnd(Prayer.isha), p.nextFajr);
      expect(p.nextAfter(p.start(Prayer.isha).add(const Duration(minutes: 1))), isNull);
      expect(p.nextAfter(dhuhr.add(const Duration(minutes: 1))), Prayer.asr);
    });

    test('the shown prayer day switches at Fajr, not midnight', () {
      final loc = tz.getLocation('Asia/Kolkata');
      final p16 = calc.forDate('2026-11-16');
      final beforeFajr = p16.start(Prayer.fajr).subtract(const Duration(minutes: 5));
      final afterFajr = p16.start(Prayer.fajr).add(const Duration(minutes: 5));
      expect(calc.current(DayClock(location: loc, now: () => beforeFajr)).date, '2026-11-15');
      expect(calc.current(DayClock(location: loc, now: () => afterFajr)).date, '2026-11-16');
    });
  });
}
