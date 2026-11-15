import 'package:flutter_test/flutter_test.dart';
import 'package:nizam/features/money/domain/money_parser.dart';

void main() {
  group('parseMoney', () {
    void check(String input, int? paise, MoneyType? type, String? cat, [String? note]) {
      final p = parseMoney(input);
      expect(p.paise, paise, reason: 'amount for "$input"');
      expect(p.type, type, reason: 'type for "$input"');
      expect(p.category, cat, reason: 'category for "$input"');
      if (note != null) expect(p.note, note, reason: 'note for "$input"');
    }

    test('examples from the brief', () {
      check('250 chai', 25000, MoneyType.spent, 'Food', 'chai');
      check('5000 SIP', 500000, MoneyType.invested, 'SIP', 'SIP');
      check('+40000 retainer', 4000000, MoneyType.received, 'Retainer', 'retainer');
      check('1.5k uber', 150000, MoneyType.spent, 'Travel', 'uber');
    });

    test('suffixes, prefixes and commas', () {
      check('2L gold', 20000000, MoneyType.invested, 'Gold');
      check('2 lakh FD', 20000000, MoneyType.invested, 'FD');
      check('₹1,200 rent', 120000, MoneyType.spent, 'Bills', 'rent');
      check('rs 300 auto', 30000, MoneyType.spent, 'Travel', 'auto');
      check('Rs. 99.50 juice', 9950, MoneyType.spent, 'Food');
      check('₹1,23,456 stocks', 12345600, MoneyType.invested, 'Stocks');
      check('inr 500 netflix', 50000, MoneyType.spent, 'Fun');
    });

    test('amount can come after the words', () {
      check('irani chai 40', 4000, MoneyType.spent, 'Food', 'irani chai');
      check('biryani with team 1200', 120000, MoneyType.spent, 'Food');
    });

    test('a + forces Received even with a spending word', () {
      check('+500 food refund', 50000, MoneyType.received, 'Refund');
      check('+2000', 200000, MoneyType.received, null, '');
    });

    test('no keyword: type and category stay null', () {
      check('750', 75000, null, null, '');
      check('450 random thing', 45000, null, null, 'random thing');
    });

    test('words only (note field): category guessed, no amount', () {
      check('swiggy dinner', null, MoneyType.spent, 'Food');
      check('salary', null, MoneyType.received, 'Salary');
      check('', null, null, null, '');
    });

    test('numbers inside words are not amounts', () {
      check('B2B leads course 999', 99900, MoneyType.spent, 'Work');
    });
  });

  group('formatInr', () {
    test('Indian digit grouping', () {
      expect(formatInr(25000), '₹250');
      expect(formatInr(100000), '₹1,000');
      expect(formatInr(12345600), '₹1,23,456');
      expect(formatInr(1234567800), '₹1,23,45,678');
      expect(formatInr(9950), '₹99.50');
      expect(formatInr(-50000), '−₹500');
      expect(formatInr(50000, sign: true), '+₹500');
    });

    test('short form', () {
      expect(formatInrShort(95000), '₹950');
      expect(formatInrShort(1250000), '₹12.5k');
      expect(formatInrShort(12000000), '₹1.2L');
    });
  });

  group('budgets', () {
    test('levels at 80% and 100%', () {
      expect(budgetLevel(79900, 100000), BudgetLevel.ok);
      expect(budgetLevel(80000, 100000), BudgetLevel.near);
      expect(budgetLevel(100000, 100000), BudgetLevel.near);
      expect(budgetLevel(100001, 100000), BudgetLevel.over);
      expect(budgetLevel(999999, null), BudgetLevel.ok);
    });

    test('alerts fire only when a threshold is crossed', () {
      expect(crossedBudget(70000, 85000, 100000), BudgetLevel.near);
      expect(crossedBudget(85000, 90000, 100000), isNull);
      expect(crossedBudget(90000, 120000, 100000), BudgetLevel.over);
      expect(crossedBudget(10000, 120000, 100000), BudgetLevel.over);
      expect(crossedBudget(120000, 130000, 100000), isNull);
    });
  });
}
