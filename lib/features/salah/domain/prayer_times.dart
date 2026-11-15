import 'package:adhan/adhan.dart' as adhan;

import '../../../core/time/day_clock.dart';

enum Prayer { fajr, dhuhr, asr, maghrib, isha }

extension PrayerName on Prayer {
  String get label => const ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'][index];
}

enum SalahStatus { upcoming, open, onTime, late, missed }

class PrayerConfig {
  const PrayerConfig({
    this.latitude = 17.3850,
    this.longitude = 78.4867,
    this.method = 'karachi',
    this.hanafiAsr = true,
  });

  final double latitude;
  final double longitude;
  final String method;
  final bool hanafiAsr;

  static const methods = {
    'karachi': 'Univ. of Islamic Sciences, Karachi',
    'muslim_world_league': 'Muslim World League',
    'egyptian': 'Egyptian General Authority',
    'umm_al_qura': 'Umm al-Qura, Makkah',
    'dubai': 'Dubai',
    'moon_sighting_committee': 'Moonsighting Committee',
    'north_america': 'ISNA (North America)',
    'kuwait': 'Kuwait',
    'qatar': 'Qatar',
    'singapore': 'Singapore',
    'turkey': 'Diyanet (Turkey)',
    'tehran': 'Tehran',
  };

  adhan.CalculationParameters params() {
    final m = adhan.CalculationMethod.values.firstWhere(
      (e) => e.name == method,
      orElse: () => adhan.CalculationMethod.karachi,
    );
    final p = m.getParameters();
    p.madhab = hanafiAsr ? adhan.Madhab.hanafi : adhan.Madhab.shafi;
    return p;
  }
}

/// The five prayers of one calendar date, as UTC instants.
class PrayerDay {
  PrayerDay({required this.date, required this.times, required this.sunrise, required this.nextFajr});

  /// Local calendar date (YYYY-MM-DD) these prayers belong to.
  final String date;
  final Map<Prayer, DateTime> times;
  final DateTime sunrise;
  final DateTime nextFajr;

  DateTime start(Prayer p) => times[p]!;

  /// When a prayer stops being "on time".
  DateTime windowEnd(Prayer p) => switch (p) {
    Prayer.fajr => sunrise,
    Prayer.dhuhr => times[Prayer.asr]!,
    Prayer.asr => times[Prayer.maghrib]!,
    Prayer.maghrib => times[Prayer.isha]!,
    Prayer.isha => nextFajr,
  };

  SalahStatus classifyMark(Prayer p, DateTime atUtc) =>
      atUtc.isBefore(windowEnd(p)) ? SalahStatus.onTime : SalahStatus.late;

  SalahStatus statusAt(Prayer p, DateTime nowUtc, SalahStatus? logged) {
    if (logged != null) return logged;
    if (nowUtc.isBefore(start(p))) return SalahStatus.upcoming;
    if (nowUtc.isBefore(windowEnd(p))) return SalahStatus.open;
    return SalahStatus.missed;
  }

  /// The next prayer that hasn't started yet, or null after Isha.
  Prayer? nextAfter(DateTime nowUtc) {
    for (final p in Prayer.values) {
      if (nowUtc.isBefore(start(p))) return p;
    }
    return null;
  }
}

class PrayerCalculator {
  PrayerCalculator(this.config);
  final PrayerConfig config;

  PrayerDay forDate(String calendarDate) {
    final d = DayKey.toDate(calendarDate);
    final coords = adhan.Coordinates(config.latitude, config.longitude);
    final params = config.params();
    final pt = adhan.PrayerTimes.utc(coords, adhan.DateComponents(d.year, d.month, d.day), params);
    final n = d.add(const Duration(days: 1));
    final next = adhan.PrayerTimes.utc(coords, adhan.DateComponents(n.year, n.month, n.day), params);
    DateTime u(DateTime x) => DateTime.fromMillisecondsSinceEpoch(x.millisecondsSinceEpoch, isUtc: true);
    return PrayerDay(
      date: calendarDate,
      times: {
        Prayer.fajr: u(pt.fajr),
        Prayer.dhuhr: u(pt.dhuhr),
        Prayer.asr: u(pt.asr),
        Prayer.maghrib: u(pt.maghrib),
        Prayer.isha: u(pt.isha),
      },
      sunrise: u(pt.sunrise),
      nextFajr: u(next.fajr),
    );
  }

  /// The prayer day shown on Today: it starts at Fajr, so between midnight
  /// and Fajr you still see (and can mark) yesterday's Isha.
  PrayerDay current(DayClock clock) {
    final now = clock.nowUtc();
    final cal = clock.calendarDateFor(now);
    final today = forDate(cal);
    return now.isBefore(today.start(Prayer.fajr)) ? forDate(DayKey.add(cal, -1)) : today;
  }
}
