import '../../../core/time/day_clock.dart';
import 'money_parser.dart';

/// Minimal view of an entry, so summaries are testable without the database.
class MoneyItem {
  const MoneyItem({
    required this.id,
    required this.paise,
    required this.type,
    required this.categoryId,
    required this.day,
    this.note = '',
    this.profileId,
  });
  final int id;
  final int paise;
  final MoneyType type;
  final int categoryId;
  final String day;
  final String note;
  final int? profileId;
}

class MonthSummary {
  MonthSummary(this.items, {required this.monthKey});

  final List<MoneyItem> items;
  final String monthKey; // YYYY-MM

  int _sum(MoneyType t) => items.where((e) => e.type == t).fold(0, (a, e) => a + e.paise);
  late final int spent = _sum(MoneyType.spent);
  late final int invested = _sum(MoneyType.invested);
  late final int received = _sum(MoneyType.received);
  int get leftOver => received - spent - invested;

  Map<int, int> byCategory(MoneyType t) {
    final m = <int, int>{};
    for (final e in items.where((e) => e.type == t)) {
      m[e.categoryId] = (m[e.categoryId] ?? 0) + e.paise;
    }
    return Map.fromEntries(m.entries.toList()..sort((a, b) => b.value.compareTo(a.value)));
  }

  /// Spending per day of the month, index 0 = day 1.
  List<int> dailySpent() {
    final d = DayKey.toDate('$monthKey-01');
    final days = DateTime.utc(d.year, d.month + 1, 1).difference(d).inDays;
    final out = List.filled(days, 0);
    for (final e in items.where((e) => e.type == MoneyType.spent)) {
      if (!e.day.startsWith(monthKey)) continue;
      final i = int.parse(e.day.substring(8)) - 1;
      if (i >= 0 && i < days) out[i] += e.paise;
    }
    return out;
  }

  List<MoneyItem> topExpenses([int n = 5]) =>
      (items.where((e) => e.type == MoneyType.spent).toList()..sort((a, b) => b.paise.compareTo(a.paise)))
          .take(n)
          .toList();

  int spentOnDay(String day) =>
      items.where((e) => e.type == MoneyType.spent && e.day == day).fold(0, (a, e) => a + e.paise);
}

String monthKeyOf(String dayKey) => dayKey.substring(0, 7);

String addMonths(String monthKey, int n) {
  final y = int.parse(monthKey.substring(0, 4)), m = int.parse(monthKey.substring(5, 7));
  final idx = y * 12 + (m - 1) + n;
  return '${(idx ~/ 12).toString().padLeft(4, '0')}-${(idx % 12 + 1).toString().padLeft(2, '0')}';
}

/// Invested per month for the last [n] months ending at [monthKey].
List<(String, int)> investTrend(List<MoneyItem> items, String monthKey, {int n = 6}) => [
  for (var i = n - 1; i >= 0; i--)
    (
      addMonths(monthKey, -i),
      items
          .where((e) => e.type == MoneyType.invested && e.day.startsWith(addMonths(monthKey, -i)))
          .fold(0, (a, e) => a + e.paise),
    ),
];
