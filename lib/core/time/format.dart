import 'day_clock.dart';

const dowShort = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
const monShort = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

String fmtTime(DayClock c, DateTime utc) {
  final l = c.toLocal(utc);
  var h = l.hour % 12;
  if (h == 0) h = 12;
  return '$h:${l.minute.toString().padLeft(2, '0')} ${l.hour >= 12 ? 'PM' : 'AM'}';
}

/// "Sun, 15 Nov"
String fmtDayKey(String key) {
  final d = DayKey.toDate(key);
  return '${dowShort[d.weekday - 1]}, ${d.day} ${monShort[d.month - 1]}';
}

/// "Today", "Tomorrow", "Yesterday" or "Tue, 17 Nov".
String relDay(String key, String today) => switch (DayKey.diff(today, key)) {
  0 => 'Today',
  1 => 'Tomorrow',
  -1 => 'Yesterday',
  _ => fmtDayKey(key),
};

String fmtIn(Duration d) {
  final m = d.inMinutes;
  if (m < 1) return 'now';
  if (m < 60) return 'in ${m}m';
  return 'in ${m ~/ 60}h ${(m % 60).toString().padLeft(2, '0')}m';
}
