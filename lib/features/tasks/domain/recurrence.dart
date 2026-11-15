import '../../../core/time/day_clock.dart';

enum RepeatFreq { none, daily, weekdays, weekly }

/// A small subset of RFC 5545 RRULE so Phase 2 can map it to Google Calendar.
class Recurrence {
  const Recurrence(this.freq, [this.days = const {}]);

  final RepeatFreq freq;

  /// For weekly: ISO weekdays (Mon = 1 … Sun = 7).
  final Set<int> days;

  static const none = Recurrence(RepeatFreq.none);

  bool get repeats => freq != RepeatFreq.none;

  bool occursOn(String dayKey) {
    final w = DayKey.weekday(dayKey);
    return switch (freq) {
      RepeatFreq.none => false,
      RepeatFreq.daily => true,
      RepeatFreq.weekdays => w <= 5,
      RepeatFreq.weekly => days.contains(w),
    };
  }

  /// The first occurrence strictly after [dayKey].
  String? nextAfter(String dayKey) {
    if (!repeats || (freq == RepeatFreq.weekly && days.isEmpty)) return null;
    var k = DayKey.add(dayKey, 1);
    for (var i = 0; i < 8; i++) {
      if (occursOn(k)) return k;
      k = DayKey.add(k, 1);
    }
    return null;
  }

  static const _byDay = ['MO', 'TU', 'WE', 'TH', 'FR', 'SA', 'SU'];

  String? toRRule() => switch (freq) {
    RepeatFreq.none => null,
    RepeatFreq.daily => 'FREQ=DAILY',
    RepeatFreq.weekdays => 'FREQ=WEEKLY;BYDAY=MO,TU,WE,TH,FR',
    RepeatFreq.weekly => 'FREQ=WEEKLY;BYDAY=${(days.toList()..sort()).map((d) => _byDay[d - 1]).join(',')}',
  };

  static Recurrence fromRRule(String? r) {
    if (r == null || r.isEmpty) return none;
    if (r == 'FREQ=DAILY') return const Recurrence(RepeatFreq.daily);
    final m = RegExp(r'BYDAY=([A-Z,]+)').firstMatch(r);
    if (r.startsWith('FREQ=WEEKLY') && m != null) {
      final d = m.group(1)!.split(',').map((x) => _byDay.indexOf(x) + 1).where((x) => x > 0).toSet();
      if (d.length == 5 && d.containsAll({1, 2, 3, 4, 5})) return const Recurrence(RepeatFreq.weekdays);
      return Recurrence(RepeatFreq.weekly, d);
    }
    return none;
  }

  String get label => switch (freq) {
    RepeatFreq.none => 'Once',
    RepeatFreq.daily => 'Daily',
    RepeatFreq.weekdays => 'Weekdays',
    RepeatFreq.weekly =>
      (days.toList()..sort()).map((d) => const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][d - 1]).join(' '),
  };
}
