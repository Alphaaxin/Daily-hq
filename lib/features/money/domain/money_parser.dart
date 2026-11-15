/// Natural-language money input: "250 chai", "5000 SIP", "+40000 retainer",
/// "1.5k uber", "2L gold", "₹1,200 rent", "rs 300 auto".
enum MoneyType { spent, invested, received }

extension MoneyTypeX on MoneyType {
  String get label => const ['Spent', 'Invested', 'Received'][index];
  static MoneyType parse(String s) => MoneyType.values.firstWhere((t) => t.name == s, orElse: () => MoneyType.spent);
}

class ParsedMoney {
  const ParsedMoney({this.paise, this.type, this.category, this.note = ''});

  /// Amount in paise (₹1 = 100), null if no number was found.
  final int? paise;
  final MoneyType? type;
  final String? category;

  /// What's left of the input once the amount is removed, in its original case.
  final String note;

  @override
  String toString() => 'ParsedMoney($paise, $type, $category, "$note")';
}

/// Keyword → (type, category). Earlier rules win, so investment and income
/// words are checked before everyday spending words.
final _rules = <(RegExp, MoneyType, String)>[
  (RegExp(r'\b(sip|mutual ?funds?|mf|elss|index ?fund)\b'), MoneyType.invested, 'SIP'),
  (RegExp(r'\b(stocks?|shares?|equity|zerodha|groww|ipo)\b'), MoneyType.invested, 'Stocks'),
  (RegExp(r'\b(crypto|btc|bitcoin|eth|usdt)\b'), MoneyType.invested, 'Crypto'),
  (RegExp(r'\b(gold|sgb|digital gold)\b'), MoneyType.invested, 'Gold'),
  (RegExp(r'\b(fd|rd|fixed deposit|deposit|ppf)\b'), MoneyType.invested, 'FD'),
  (RegExp(r'\binvest'), MoneyType.invested, 'Other'),
  (RegExp(r'\b(salary|stipend|payroll)\b'), MoneyType.received, 'Salary'),
  (RegExp(r'\b(retainer|tot|triumphs)\b'), MoneyType.received, 'Retainer'),
  (RegExp(r'\b(freelance|client|project|invoice)\b'), MoneyType.received, 'Freelance'),
  (RegExp(r'\b(gift|eidi)\b'), MoneyType.received, 'Gift'),
  (RegExp(r'\b(refund|cashback|reimburse\w*)\b'), MoneyType.received, 'Refund'),
  (RegExp(r'\b(received|got|income|credited)\b'), MoneyType.received, 'Other'),
  (
    RegExp(
      r'\b(chai|tea|coffee|food|lunch|dinner|breakfast|biryani|haleem|irani|osmania|zomato|swiggy|snacks?|'
      r'juice|shawarma|mandi|pizza|burger|groceries|grocery|zepto|blinkit|bigbasket|dmart|fruits?|milk|bakery)\b',
    ),
    MoneyType.spent,
    'Food',
  ),
  (
    RegExp(r'\b(uber|ola|rapido|auto|metro|bus|petrol|fuel|diesel|cab|train|flight|irctc|toll|parking|bike)\b'),
    MoneyType.spent,
    'Travel',
  ),
  (RegExp(r'\b(amazon|flipkart|myntra|ajio|meesho|shopping|clothes|shoes|nykaa)\b'), MoneyType.spent, 'Shopping'),
  (
    RegExp(r'\b(recharge|bills?|electricity|current|wifi|internet|broadband|rent|emi|gas|water bill|dth)\b'),
    MoneyType.spent,
    'Bills',
  ),
  (RegExp(r'\b(medicines?|doctor|pharmacy|hospital|gym|health|clinic|tests?)\b'), MoneyType.spent, 'Health'),
  (RegExp(r'\b(movie|netflix|prime|spotify|game|gaming|party|outing|pvr)\b'), MoneyType.spent, 'Fun'),
  (
    RegExp(r'\b(domain|hosting|software|subscription|ads|course|udemy|chatgpt|claude|canva|notion|books?)\b'),
    MoneyType.spent,
    'Work',
  ),
];

final _amount = RegExp(
  r'(^|\s)([+-]?)\s*(?:₹|rs\.?|inr)?\s*(\d{1,3}(?:,\d{2,3})+|\d+(?:\.\d+)?)\s*(k|l|lac|lakh|lakhs|cr)?(?=\s|$)',
  caseSensitive: false,
);

ParsedMoney parseMoney(String input) {
  final raw = input.trim();
  if (raw.isEmpty) return const ParsedMoney();
  int? paise;
  MoneyType? type;
  var rest = raw;
  final m = _amount.firstMatch(raw);
  if (m != null) {
    var v = double.parse(m.group(3)!.replaceAll(',', ''));
    switch (m.group(4)?.toLowerCase()) {
      case 'k':
        v *= 1000;
      case 'l' || 'lac' || 'lakh' || 'lakhs':
        v *= 100000;
      case 'cr':
        v *= 10000000;
    }
    paise = (v * 100).round();
    if (m.group(2) == '+') type = MoneyType.received;
    rest = (raw.substring(0, m.start) + raw.substring(m.end)).trim();
  }
  final low = rest.toLowerCase();
  String? cat;
  for (final (re, ty, c) in _rules) {
    if (!re.hasMatch(low)) continue;
    if (type == null) {
      type = ty;
      cat = c;
      break;
    }
    if (ty == type) {
      cat = c;
      break;
    }
  }
  return ParsedMoney(paise: paise, type: type, category: cat, note: rest.replaceAll(RegExp(r'\s+'), ' '));
}

/// "₹1,23,456" (Indian grouping) or "₹250.50"; paise shown only when non-zero.
String formatInr(int paise, {bool sign = false}) {
  final neg = paise < 0;
  final abs = paise.abs();
  final rupees = abs ~/ 100, p = abs % 100;
  final s = rupees.toString();
  String grouped;
  if (s.length <= 3) {
    grouped = s;
  } else {
    final last3 = s.substring(s.length - 3);
    var head = s.substring(0, s.length - 3);
    final parts = <String>[];
    while (head.length > 2) {
      parts.insert(0, head.substring(head.length - 2));
      head = head.substring(0, head.length - 2);
    }
    if (head.isNotEmpty) parts.insert(0, head);
    grouped = '${parts.join(',')},$last3';
  }
  final body = '₹$grouped${p == 0 ? '' : '.${p.toString().padLeft(2, '0')}'}';
  return neg ? '−$body' : (sign ? '+$body' : body);
}

/// Compact form for charts: ₹950, ₹12.5k, ₹1.2L.
String formatInrShort(int paise) {
  final r = paise / 100;
  if (r.abs() >= 100000) return '₹${_trim(r / 100000)}L';
  if (r.abs() >= 1000) return '₹${_trim(r / 1000)}k';
  return '₹${r.round()}';
}

String _trim(double v) => v.toStringAsFixed(v >= 100 ? 0 : 1).replaceAll(RegExp(r'\.0$'), '');

enum BudgetLevel { ok, near, over }

/// Near = 80% or more of the budget, over = more than 100%.
BudgetLevel budgetLevel(int spentPaise, int? budgetPaise) {
  if (budgetPaise == null || budgetPaise <= 0) return BudgetLevel.ok;
  if (spentPaise > budgetPaise) return BudgetLevel.over;
  if (spentPaise * 100 >= budgetPaise * 80) return BudgetLevel.near;
  return BudgetLevel.ok;
}

/// A budget alert is due only when a new entry pushes spending across a
/// threshold (so it fires once, not on every later entry).
BudgetLevel? crossedBudget(int beforePaise, int afterPaise, int? budgetPaise) {
  final a = budgetLevel(beforePaise, budgetPaise), b = budgetLevel(afterPaise, budgetPaise);
  return b.index > a.index ? b : null;
}
