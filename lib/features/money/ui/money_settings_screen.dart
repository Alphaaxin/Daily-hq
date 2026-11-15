import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/db/app_db.dart';
import '../../../core/native/native_bridge.dart';
import '../../../core/providers.dart';
import '../../../core/theme/dialogs.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/theme/widgets.dart';
import '../data/money_repo.dart';
import '../domain/money_parser.dart';

class MoneySettingsScreen extends ConsumerWidget {
  const MoneySettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(settingsProvider);
    final repo = ref.read(moneyRepoProvider);
    final settings = ref.read(settingsRepoProvider);
    final cats = ref.watch(categoriesProvider).value ?? const <Category>[];

    Widget section(MoneyType type) {
      final l = cats.where((c) => c.type == type.name).toList();
      return GlassCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CardHeader(
              '${type.label} categories',
              trailing: GestureDetector(
                onTap: () async {
                  final v = await askText(context, 'New ${type.label.toLowerCase()} category', '');
                  if (v != null && v.trim().isNotEmpty) await repo.addCategory(v, type);
                },
                child: const Text(
                  '+ Add',
                  style: TextStyle(color: N.gold, fontWeight: FontWeight.w700),
                ),
              ),
            ),
            for (final c in l)
              Container(
                decoration: const BoxDecoration(
                  border: Border(top: BorderSide(color: N.line)),
                ),
                child: Row(
                  children: [
                    Expanded(child: Text(c.name, style: const TextStyle(fontSize: 15))),
                    if (type == MoneyType.spent)
                      TextButton(
                        onPressed: () async {
                          final v = await askText(
                            context,
                            'Monthly budget for ${c.name} (₹, empty = none)',
                            c.budgetPaise == null ? '' : '${c.budgetPaise! ~/ 100}',
                          );
                          if (v == null) return;
                          await repo.setBudget(c.id, v.trim().isEmpty ? null : parseMoney(v).paise);
                        },
                        child: Text(
                          c.budgetPaise == null ? 'Set budget' : formatInr(c.budgetPaise!),
                          style: TextStyle(
                            color: c.budgetPaise == null ? N.muted : N.gold,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    IconButton(
                      tooltip: 'Rename',
                      icon: const Icon(Icons.edit_outlined, size: 18, color: N.muted),
                      onPressed: () async {
                        final v = await askText(context, 'Rename', c.name);
                        if (v != null && v.trim().isNotEmpty) await repo.renameCategory(c.id, v);
                      },
                    ),
                    IconButton(
                      tooltip: 'Remove',
                      icon: const Icon(Icons.close_rounded, size: 18, color: N.muted),
                      onPressed: () => repo.archiveCategory(c.id),
                    ),
                  ],
                ),
              ),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: N.bg,
        surfaceTintColor: Colors.transparent,
        title: Text('Money settings', style: N.h2.copyWith(fontSize: 18)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 40),
        children: [
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const CardHeader('Quick Log'),
                _row('Monthly budget', s.monthlyBudgetPaise > 0 ? formatInr(s.monthlyBudgetPaise) : 'None', () async {
                  final v = await askText(
                    context,
                    'Monthly spending budget (₹, empty = none)',
                    s.monthlyBudgetPaise > 0 ? '${s.monthlyBudgetPaise ~/ 100}' : '',
                  );
                  if (v == null) return;
                  await settings.set('monthlyBudgetPaise', v.trim().isEmpty ? 0 : (parseMoney(v).paise ?? 0));
                }),
                _row('Taps on empty space to open', '${s.quickLogTaps} taps', () async {
                  final v = await askInt(
                    context,
                    'Quick taps to open Quick Log',
                    s.quickLogTaps,
                    3,
                    6,
                    fmt: (x) => '$x taps',
                  );
                  if (v != null) await settings.set('quickLogTaps', v);
                }),
                Container(
                  decoration: const BoxDecoration(
                    border: Border(top: BorderSide(color: N.line)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Floating ₹ bubble', style: TextStyle(fontSize: 15)),
                            Text(
                              'Draggable bubble over every app. Needs "display over other apps".',
                              style: N.small.copyWith(fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: s.bubble,
                        onChanged: (v) async {
                          if (v && !await NativeBridge.canDrawOverlays()) {
                            await NativeBridge.requestOverlay();
                            if (context.mounted) {
                              showSnack(context, 'Allow Solo Leveling, then switch the bubble on again.');
                            }
                            return;
                          }
                          await settings.set('bubble', v);
                          v ? await NativeBridge.startBubble() : await NativeBridge.stopBubble();
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Also: pull down Quick Settings → edit (pencil) → drag "₹ Log money" in. '
                  'Long-press your home screen → Widgets → Solo Leveling for the one-tap widget.',
                  style: N.small.copyWith(fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(height: N.gap),
          section(MoneyType.spent),
          const SizedBox(height: N.gap),
          section(MoneyType.invested),
          const SizedBox(height: N.gap),
          section(MoneyType.received),
        ],
      ),
    );
  }

  Widget _row(String title, String value, VoidCallback onTap) => InkWell(
    onTap: onTap,
    child: Container(
      constraints: const BoxConstraints(minHeight: 52),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: N.line)),
      ),
      child: Row(
        children: [
          Expanded(child: Text(title, style: const TextStyle(fontSize: 15))),
          Text(
            value,
            style: const TextStyle(color: N.gold, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    ),
  );
}
