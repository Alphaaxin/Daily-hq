import 'package:timezone/timezone.dart' as tz;

/// A logical day key such as `2026-11-15`.
///
/// Nizam's "day" does not end at midnight: it rolls over at a configurable
/// hour (default 6 AM), so a Good Night tapped at 05:45 still belongs to the
/// previous day. All instants are stored in UTC; [DayClock] converts them.
class DayKey {
  DayKey._();

  static String format(int y, int m, int d) =>
      '${y.toString().padLeft(4, '0')}-${m.toString().padLeft(2, '0')}-${d.toString().padLeft(2, '0')}';

  /// Parses a key into a UTC-midnight [DateTime] used only for date maths.
  static DateTime toDate(String key) {
    final p = key.split('-').map(int.parse).toList();
    return DateTime.utc(p[0], p[1], p[2]);
  }

  static String fromDate(DateTime d) => format(d.year, d.month, d.day);

  static String add(String key, int days) => fromDate(toDate(key).add(Duration(days: days)));

  /// Whole days from [a] to [b] (positive when b is later).
  static int diff(String a, String b) => toDate(b).difference(toDate(a)).inDays;

  /// Monday = 1 … Sunday = 7.
  static int weekday(String key) => toDate(key).weekday;
}

class DayClock {
  DayClock({required this.location, this.rolloverHour = 6, DateTime Function()? now}) : _now = now ?? DateTime.now;

  final tz.Location location;
  final int rolloverHour;
  final DateTime Function() _now;

  DateTime nowUtc() => _now().toUtc();

  tz.TZDateTime toLocal(DateTime utc) => tz.TZDateTime.from(utc, location);

  /// The logical day an instant belongs to.
  String dayKeyFor(DateTime utc) {
    final l = toLocal(utc);
    var date = DateTime.utc(l.year, l.month, l.day);
    if (l.hour < rolloverHour) date = date.subtract(const Duration(days: 1));
    return DayKey.fromDate(date);
  }

  String today() => dayKeyFor(nowUtc());

  /// Calendar date (local) of an instant, ignoring rollover.
  String calendarDateFor(DateTime utc) {
    final l = toLocal(utc);
    return DayKey.format(l.year, l.month, l.day);
  }

  /// First instant (UTC) of a logical day.
  DateTime dayStartUtc(String key) {
    final d = DayKey.toDate(key);
    return tz.TZDateTime(location, d.year, d.month, d.day, rolloverHour).toUtc();
  }

  /// First instant (UTC) of the following logical day.
  DateTime dayEndUtc(String key) => dayStartUtc(DayKey.add(key, 1));

  /// A local wall-clock time on a given calendar date, as UTC.
  DateTime localToUtc(String calendarDate, int hour, int minute) {
    final d = DayKey.toDate(calendarDate);
    return tz.TZDateTime(location, d.year, d.month, d.day, hour, minute).toUtc();
  }
}
