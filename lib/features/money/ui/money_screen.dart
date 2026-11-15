import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/db/app_db.dart';
import '../../../core/providers.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/theme/widgets.dart';
import '../../../core/time/format.dart';
import '../../profiles/data/profiles_repo.dart';
import '../data/money_repo.dart';
import '../domain/money_parser.dart';
import '../domain/money_summary.dart';
import 'quick_log_sheet.dart';

String _monthLabel(String mk) => '${monShort[int.parse(mk.substring(5)) - 1]} ${mk.substring(0, 4)}';

class MoneyScreen extends ConsumerWidget {
  const MoneyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mk = ref.watch(shownMonthProvider);
    final current = monthKeyOf(ref.watch(todayProvider));
    final sum = ref.watch(monthSummaryProvider);
    final s = ref.watch(settingsProvider);
    final cats = ref.watch(categoryByIdProvider);
    final profiles = ref.watch(profilesProvider).value ?? const <Profile>[];
    final pf = ref.watch(moneyProfileFilterProvider);
    final bud = s.monthlyBudgetPaise;

    Widget stat(String label, int v, Color c) => Expanded(
      child: Container(
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: N.raise,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: N.line),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Eyebrow(label),
            const SizedBox(height: 4),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(formatInr(v), style: N.num(19, color: c)),
            ),
          ],
        ),
      ),
    );

    final byCat = sum.byCategory(MoneyType.spent);
    final maxCat = byCat.values.fold(1, math.max);
    final inv = sum.byCategory(MoneyType.invested);
    final trend = investTrend(
      (ref.watch(trendEntriesProvider).value ?? const <MoneyEntry>[]).map((e) => e.item).toList(),
      current,
    );

    return ListView(
      padding: EdgeInsets.fromLTRB(16, 12, 16, 120 + MediaQuery.of(context).padding.bottom),
      children: [
        GlassCard(
          hero: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  IconBtn(
                    Icons.chevron_left_rounded,
                    label: 'Previous month',
                    onTap: () => ref.read(selectedMonthProvider.notifier).set(addMonths(mk, -1)),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        Eyebrow(mk == current ? 'This month' : 'Month'),
                        const SizedBox(height: 2),
                        Text(_monthLabel(mk), style: N.h2.copyWith(fontSize: 18)),
                      ],
                    ),
                  ),
                  IconBtn(
                    Icons.chevron_right_rounded,
                    label: 'Next month',
                    onTap: mk == current ? () {} : () => ref.read(selectedMonthProvider.notifier).set(addMonths(mk, 1)),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    NChip(
                      'All',
                      on: pf == null,
                      onTap: () => ref.read(moneyProfileFilterProvider.notifier).select(null),
                    ),
                    for (final p in profiles) ...[
                      const SizedBox(width: 6),
                      NChip(
                        p.name,
                        on: pf == p.id,
                        onTap: () => ref.read(moneyProfileFilterProvider.notifier).select(p.id),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  stat('Spent', sum.spent, N.bad),
                  const SizedBox(width: 8),
                  stat('Invested', sum.invested, N.water),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  stat('Received', sum.received, N.good),
                  const SizedBox(width: 8),
                  stat('Left over', sum.leftOver, N.ink),
                ],
              ),
              if (bud > 0 && pf == null) ...[
                const SizedBox(height: 14),
                Row(
                  children: [
                    Text('Budget', style: N.small.copyWith(color: N.ink)),
                    const Spacer(),
                    Text('${formatInr(sum.spent)} of ${formatInr(bud)}', style: N.num(12, color: N.muted)),
                  ],
                ),
                const SizedBox(height: 6),
                GoldBar(sum.spent / bud, color: sum.spent > bud ? N.bad : null),
                const SizedBox(height: 6),
                Text(
                  sum.spent > bud
                      ? 'Over budget by ${formatInr(sum.spent - bud)}'
                      : '${formatInr(bud - sum.spent)} left this month',
                  style: N.small.copyWith(color: sum.spent > bud ? N.bad : N.muted),
                ),
              ],
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: NButton(
                      'Log money',
                      icon: Icons.add_rounded,
                      expand: true,
                      onTap: () => showQuickLog(context),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconBtn(
                    Icons.tune_rounded,
                    label: 'Categories and budgets',
                    onTap: () => context.push('/money-settings'),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: N.gap),
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const CardHeader('Daily spending'),
              _DailyChart(
                values: sum.dailySpent(),
                todayIndex: mk == current ? int.parse(ref.watch(todayProvider).substring(8)) - 1 : -1,
              ),
            ],
          ),
        ),
        const SizedBox(height: N.gap),
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const CardHeader('Where it went'),
              if (byCat.isEmpty) const EmptyNote('No spending logged this month.'),
              for (final e in byCat.entries)
                _CatRow(
                  name: cats[e.key]?.name ?? '?',
                  paise: e.value,
                  barValue: cats[e.key]?.budgetPaise != null ? e.value / cats[e.key]!.budgetPaise! : e.value / maxCat,
                  budget: cats[e.key]?.budgetPaise,
                ),
            ],
          ),
        ),
        const SizedBox(height: N.gap),
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CardHeader(
                'Investments',
                trailing: Text(formatInr(sum.invested), style: N.num(13, color: N.water)),
              ),
              for (final e in inv.entries)
                _CatRow(
                  name: cats[e.key]?.name ?? '?',
                  paise: e.value,
                  barValue: e.value / math.max(1, sum.invested),
                  color: N.water,
                ),
              if (inv.isEmpty) const EmptyNote('No investments this month. Log a SIP with "5000 SIP".'),
              const SizedBox(height: 12),
              const Eyebrow('Last 6 months'),
              const SizedBox(height: 8),
              _TrendBars(trend: trend),
            ],
          ),
        ),
        const SizedBox(height: N.gap),
        _EntriesCard(entries: ref.watch(filteredMonthEntriesProvider), top: sum.topExpenses().map((e) => e.id).toSet()),
      ],
    );
  }
}

class _CatRow extends StatelessWidget {
  const _CatRow({required this.name, required this.paise, required this.barValue, this.budget, this.color});
  final String name;
  final int paise;
  final double barValue;
  final int? budget;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final level = budgetLevel(paise, budget);
    final c =
        color ??
        (level == BudgetLevel.over
            ? N.bad
            : level == BudgetLevel.near
            ? N.warn
            : N.bad.withValues(alpha: .8));
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(child: Text(name, style: const TextStyle(fontSize: 14))),
              Text(formatInr(paise), style: N.num(13)),
              if (budget != null) Text(' / ${formatInrShort(budget!)}', style: N.num(12, color: N.muted)),
            ],
          ),
          const SizedBox(height: 5),
          GoldBar(barValue, color: c, height: 5),
        ],
      ),
    );
  }
}

class _DailyChart extends StatelessWidget {
  const _DailyChart({required this.values, required this.todayIndex});
  final List<int> values;
  final int todayIndex;

  @override
  Widget build(BuildContext context) {
    final max = values.fold(0, math.max);
    if (max == 0) return const EmptyNote('Nothing spent yet this month.');
    return SizedBox(
      height: 130,
      child: CustomPaint(painter: _BarsPainter(values, max, todayIndex), size: Size.infinite),
    );
  }
}

class _BarsPainter extends CustomPainter {
  _BarsPainter(this.v, this.max, this.today);
  final List<int> v;
  final int max;
  final int today;

  @override
  void paint(Canvas canvas, Size size) {
    const bottom = 16.0;
    final h = size.height - bottom - 14;
    final slot = size.width / v.length;
    final bw = math.max(3.0, slot * .6);
    final tp = TextPainter(textDirection: TextDirection.ltr);
    tp.text = TextSpan(
      text: formatInrShort(max),
      style: const TextStyle(fontFamily: N.mono, fontSize: 10, color: N.muted),
    );
    tp.layout();
    tp.paint(canvas, Offset(size.width - tp.width, 0));
    for (var i = 0; i < v.length; i++) {
      final bh = v[i] == 0 ? 2.0 : math.max(3.0, v[i] / max * h);
      final x = slot * i + (slot - bw) / 2;
      final r = RRect.fromRectAndRadius(Rect.fromLTWH(x, 14 + h - bh, bw, bh), const Radius.circular(3));
      canvas.drawRRect(r, Paint()..color = i == today ? N.gold : (v[i] == 0 ? N.line : N.bad.withValues(alpha: .75)));
      if ((i + 1) % 5 == 0 || i == 0) {
        tp.text = TextSpan(
          text: '${i + 1}',
          style: const TextStyle(fontFamily: N.mono, fontSize: 9, color: N.muted),
        );
        tp.layout();
        tp.paint(canvas, Offset(x + bw / 2 - tp.width / 2, size.height - bottom + 3));
      }
    }
  }

  @override
  bool shouldRepaint(_BarsPainter o) => o.v != v || o.today != today;
}

class _TrendBars extends StatelessWidget {
  const _TrendBars({required this.trend});
  final List<(String, int)> trend;

  @override
  Widget build(BuildContext context) {
    final max = trend.map((e) => e.$2).fold(1, math.max);
    return SizedBox(
      height: 96,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (final (mk, v) in trend)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (v > 0)
                      Text(
                        formatInrShort(v),
                        style: N.num(9, color: N.muted, weight: FontWeight.w500),
                      ),
                    const SizedBox(height: 3),
                    Container(
                      height: v == 0 ? 2 : math.max(4, v / max * 56),
                      decoration: BoxDecoration(
                        color: v == 0 ? N.line : N.water,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      monShort[int.parse(mk.substring(5)) - 1],
                      style: N.num(10, color: N.muted, weight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _EntriesCard extends ConsumerWidget {
  const _EntriesCard({required this.entries, required this.top});
  final List<MoneyEntry> entries;
  final Set<int> top;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cats = ref.watch(categoryByIdProvider);
    final clock = ref.watch(clockProvider);
    final profiles = {for (final p in ref.watch(profilesProvider).value ?? const <Profile>[]) p.id: p.name};
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CardHeader(
            'Entries',
            trailing: Text('${entries.length}', style: N.num(12, color: N.muted)),
          ),
          if (entries.isEmpty) const EmptyNote('Tap ₹ or tap empty space 4 times to log your first entry.'),
          for (final e in entries.take(100))
            Dismissible(
              key: ValueKey('m-${e.id}'),
              direction: DismissDirection.endToStart,
              background: Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 16),
                color: N.badSoft,
                child: const Icon(Icons.delete_outline_rounded, color: N.bad),
              ),
              onDismissed: (_) => ref.read(moneyRepoProvider).delete(e),
              child: InkWell(
                onTap: () => _edit(context, ref, e),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: const BoxDecoration(
                    border: Border(top: BorderSide(color: N.line)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text.rich(
                              TextSpan(
                                children: [
                                  if (top.contains(e.id))
                                    const TextSpan(
                                      text: '▲ ',
                                      style: TextStyle(color: N.gold, fontSize: 11),
                                    ),
                                  TextSpan(text: e.note.isEmpty ? (cats[e.categoryId]?.name ?? '') : e.note),
                                ],
                              ),
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              [
                                cats[e.categoryId]?.name ?? '',
                                '${fmtDayKey(e.day)}, ${fmtTime(clock, e.atUtc)}',
                                if (e.profileId != null) profiles[e.profileId] ?? '',
                              ].join(' · '),
                              style: N.small.copyWith(fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        (e.type == 'spent'
                                ? '−'
                                : e.type == 'received'
                                ? '+'
                                : '') +
                            formatInr(e.amountPaise),
                        style: N.num(
                          14,
                          color: e.type == 'spent'
                              ? N.bad
                              : e.type == 'received'
                              ? N.good
                              : N.water,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          if (entries.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'Tap to edit · swipe left to delete · ▲ top expenses',
                textAlign: TextAlign.center,
                style: N.small.copyWith(fontSize: 12),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _edit(BuildContext context, WidgetRef ref, MoneyEntry e) async {
    final amount = TextEditingController(text: (e.amountPaise / 100).toStringAsFixed(e.amountPaise % 100 == 0 ? 0 : 2));
    final note = TextEditingController(text: e.note);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Edit entry', style: N.h2),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: amount,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: N.num(20),
              decoration: const InputDecoration(prefixText: '₹ '),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: note,
              decoration: const InputDecoration(hintText: 'Note'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel', style: TextStyle(color: N.muted)),
          ),
          NButton('Save', onTap: () => Navigator.pop(ctx, true)),
        ],
      ),
    );
    if (ok != true) return;
    final p = parseMoney(amount.text).paise;
    if (p == null || p <= 0) return;
    await ref.read(moneyRepoProvider).update(e.copyWith(amountPaise: p, note: note.text.trim()));
  }
}
