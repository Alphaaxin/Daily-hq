import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/db/app_db.dart';
import '../../../core/providers.dart';
import '../../../core/time/day_clock.dart';
import '../../gamification/data/xp_repo.dart';
import '../domain/money_parser.dart';
import '../domain/money_summary.dart';

class BudgetAlert {
  const BudgetAlert(this.label, this.level, this.spentPaise, this.budgetPaise);
  final String label; // category name, or "This month"
  final BudgetLevel level;
  final int spentPaise;
  final int budgetPaise;

  String get message => level == BudgetLevel.over
      ? '$label is over budget by ${formatInr(spentPaise - budgetPaise)}'
      : '${formatInr(budgetPaise - spentPaise)} left for $label this month';
}

extension MoneyEntryX on MoneyEntry {
  MoneyItem get item => MoneyItem(
    id: id,
    paise: amountPaise,
    type: MoneyTypeX.parse(type),
    categoryId: categoryId,
    day: day,
    note: note,
    profileId: profileId,
  );
}

class MoneyRepo {
  MoneyRepo(this.db, this.xp);
  final AppDb db;
  final XpRepo xp;

  static const xpKey = 'money:log';
  static const xpAmount = 5;

  Stream<List<Category>> watchCategories() =>
      (db.select(db.categories)
            ..where((t) => t.archived.equals(false))
            ..orderBy([(t) => OrderingTerm.asc(t.sort), (t) => OrderingTerm.asc(t.id)]))
          .watch();

  Future<List<Category>> categories() => (db.select(db.categories)..where((t) => t.archived.equals(false))).get();

  Stream<List<MoneyEntry>> watchMonth(String monthKey) =>
      (db.select(db.moneyEntries)
            ..where((t) => t.day.like('$monthKey-%'))
            ..orderBy([(t) => OrderingTerm.desc(t.atUtc)]))
          .watch();

  Stream<List<MoneyEntry>> watchSince(String day) =>
      (db.select(db.moneyEntries)..where((t) => t.day.isBiggerOrEqualValue(day))).watch();

  Future<int> _monthSpent(String monthKey, {int? categoryId}) async {
    final s = db.moneyEntries.amountPaise.sum();
    final q = db.selectOnly(db.moneyEntries)
      ..addColumns([s])
      ..where(db.moneyEntries.day.like('$monthKey-%') & db.moneyEntries.type.equals('spent'));
    if (categoryId != null) q.where(db.moneyEntries.categoryId.equals(categoryId));
    return (await q.getSingle()).read(s) ?? 0;
  }

  /// Saves an entry and returns any budget thresholds it crossed.
  Future<List<BudgetAlert>> add({
    required int paise,
    required MoneyType type,
    required int categoryId,
    String note = '',
    int? profileId,
    required DayClock clock,
    int? monthlyBudgetPaise,
  }) async {
    final day = clock.today();
    final mk = monthKeyOf(day);
    final cat = await (db.select(db.categories)..where((t) => t.id.equals(categoryId))).getSingle();
    final beforeCat = await _monthSpent(mk, categoryId: categoryId);
    final beforeAll = await _monthSpent(mk);
    await db
        .into(db.moneyEntries)
        .insert(
          MoneyEntriesCompanion.insert(
            amountPaise: paise,
            type: type.name,
            categoryId: categoryId,
            note: Value(note.trim()),
            profileId: Value(profileId),
            atUtc: clock.nowUtc(),
            day: day,
          ),
        );
    await xp.set(day, xpKey, xpAmount);
    if (type != MoneyType.spent) return const [];
    final alerts = <BudgetAlert>[];
    final c = crossedBudget(beforeCat, beforeCat + paise, cat.budgetPaise);
    if (c != null) alerts.add(BudgetAlert(cat.name, c, beforeCat + paise, cat.budgetPaise!));
    final a = crossedBudget(beforeAll, beforeAll + paise, monthlyBudgetPaise);
    if (a != null) alerts.add(BudgetAlert('your monthly budget', a, beforeAll + paise, monthlyBudgetPaise!));
    return alerts;
  }

  Future<void> update(MoneyEntry e) => db.update(db.moneyEntries).replace(e);

  Future<void> delete(MoneyEntry e) async {
    await (db.delete(db.moneyEntries)..where((t) => t.id.equals(e.id))).go();
    final left = await (db.select(db.moneyEntries)..where((t) => t.day.equals(e.day))).get();
    if (left.isEmpty) await xp.set(e.day, xpKey, 0);
  }

  Future<void> addCategory(String name, MoneyType type) async {
    final n = await db.select(db.categories).get();
    await db
        .into(db.categories)
        .insert(CategoriesCompanion.insert(name: name.trim(), type: type.name, sort: Value(n.length)));
  }

  Future<void> renameCategory(int id, String name) =>
      (db.update(db.categories)..where((t) => t.id.equals(id))).write(CategoriesCompanion(name: Value(name.trim())));

  Future<void> setBudget(int id, int? paise) =>
      (db.update(db.categories)..where((t) => t.id.equals(id))).write(CategoriesCompanion(budgetPaise: Value(paise)));

  Future<void> archiveCategory(int id) =>
      (db.update(db.categories)..where((t) => t.id.equals(id))).write(const CategoriesCompanion(archived: Value(true)));
}

final moneyRepoProvider = Provider((ref) => MoneyRepo(ref.watch(dbProvider), ref.watch(xpRepoProvider)));
final categoriesProvider = StreamProvider<List<Category>>((ref) => ref.watch(moneyRepoProvider).watchCategories());

/// Month shown on the Money tab (YYYY-MM); defaults to the current month.
class SelectedMonth extends Notifier<String?> {
  @override
  String? build() => null;
  void set(String? m) => state = m;
}

final selectedMonthProvider = NotifierProvider<SelectedMonth, String?>(SelectedMonth.new);
final shownMonthProvider = Provider<String>(
  (ref) => ref.watch(selectedMonthProvider) ?? monthKeyOf(ref.watch(todayProvider)),
);

/// Work-profile filter on the Money tab (null = all).
class MoneyProfileFilter extends Notifier<int?> {
  @override
  int? build() => null;
  void select(int? id) => state = id;
}

final moneyProfileFilterProvider = NotifierProvider<MoneyProfileFilter, int?>(MoneyProfileFilter.new);

final monthEntriesProvider = StreamProvider<List<MoneyEntry>>(
  (ref) => ref.watch(moneyRepoProvider).watchMonth(ref.watch(shownMonthProvider)),
);

final filteredMonthEntriesProvider = Provider<List<MoneyEntry>>((ref) {
  final p = ref.watch(moneyProfileFilterProvider);
  final l = ref.watch(monthEntriesProvider).value ?? const <MoneyEntry>[];
  return p == null ? l : l.where((e) => e.profileId == p).toList();
});

final monthSummaryProvider = Provider<MonthSummary>(
  (ref) => MonthSummary(
    ref.watch(filteredMonthEntriesProvider).map((e) => e.item).toList(),
    monthKey: ref.watch(shownMonthProvider),
  ),
);

/// Last 6 months of entries for the investment trend.
final trendEntriesProvider = StreamProvider<List<MoneyEntry>>((ref) {
  final mk = monthKeyOf(ref.watch(todayProvider));
  return ref.watch(moneyRepoProvider).watchSince('${addMonths(mk, -5)}-01');
});

final todaySpentProvider = Provider<int>((ref) {
  final today = ref.watch(todayProvider);
  final l = ref.watch(trendEntriesProvider).value ?? const <MoneyEntry>[];
  return l.where((e) => e.day == today && e.type == 'spent').fold(0, (a, e) => a + e.amountPaise);
});

final categoryByIdProvider = Provider<Map<int, Category>>(
  (ref) => {for (final c in ref.watch(categoriesProvider).value ?? const <Category>[]) c.id: c},
);
