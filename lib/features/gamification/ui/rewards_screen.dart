import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/celebrate.dart';
import '../../../core/db/app_db.dart';
import '../../../core/providers.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/theme/widgets.dart';
import '../../../core/time/format.dart';
import '../data/rewards_repo.dart';
import '../data/xp_repo.dart';
import '../domain/xp_rules.dart';

final _n = NumberFormat.decimalPattern('en_IN');

class RewardsScreen extends ConsumerStatefulWidget {
  const RewardsScreen({super.key});

  @override
  ConsumerState<RewardsScreen> createState() => _RewardsScreenState();
}

class _RewardsScreenState extends ConsumerState<RewardsScreen> {
  final _name = TextEditingController();
  final _cost = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    _cost.dispose();
    super.dispose();
  }

  Future<void> _add() async {
    final n = _name.text.trim();
    final c = int.tryParse(_cost.text.trim()) ?? 0;
    if (n.isEmpty || c <= 0) {
      showSnack(context, 'Give the reward a name and an XP price');
      return;
    }
    await ref.read(rewardsRepoProvider).add(n, c);
    _name.clear();
    _cost.clear();
    if (mounted) FocusScope.of(context).unfocus();
  }

  Future<void> _redeem(Reward r, int bal) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Redeem ${r.name}?', style: N.h2.copyWith(fontSize: 18)),
        content: Text('This spends ${r.cost} XP. Your level stays the same.', style: N.small),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Not yet', style: TextStyle(color: N.muted)),
          ),
          NButton('Enjoy it', onTap: () => Navigator.pop(ctx, true)),
        ],
      ),
    );
    if (ok != true) return;
    if (await ref.read(rewardsRepoProvider).redeem(r, bal)) {
      ref.read(celebratorProvider).celebrate('Enjoy: ${r.name} 🎉');
    }
  }

  @override
  Widget build(BuildContext context) {
    final bal = ref.watch(xpBalanceProvider);
    final total = ref.watch(xpTotalProvider).value ?? 0;
    final lvl = ref.watch(levelProvider);
    final rewards = ref.watch(rewardsProvider).value ?? const <Reward>[];
    final redeemed = ref.watch(redemptionsProvider).value ?? const <Redemption>[];
    final clock = ref.watch(clockProvider);

    return ListView(
      padding: EdgeInsets.fromLTRB(16, 12, 16, 120 + MediaQuery.of(context).padding.bottom),
      children: [
        GlassCard(
          hero: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Eyebrow('XP to spend'),
              const SizedBox(height: 6),
              GoldText(_n.format(bal), style: N.num(46)),
              const SizedBox(height: 6),
              Text('Level ${lvl.level} ${lvl.name} · ${_n.format(total)} XP earned in total', style: N.small),
            ],
          ),
        ),
        const SizedBox(height: N.gap),
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const CardHeader('Rewards shop'),
              if (rewards.isEmpty) const EmptyNote('Add a reward you actually want.'),
              for (final r in rewards)
                Container(
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
                            Text(r.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                            const SizedBox(height: 2),
                            Text(
                              '${_n.format(r.cost)} XP${bal >= r.cost ? '' : ' · need ${_n.format(r.cost - bal)} more'}',
                              style: N.num(12, color: N.muted, weight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ),
                      NButton(
                        'Redeem',
                        kind: bal >= r.cost ? BtnKind.primary : BtnKind.raise,
                        onTap: bal >= r.cost ? () => _redeem(r, bal) : null,
                      ),
                      IconButton(
                        tooltip: 'Remove reward',
                        onPressed: () => ref.read(rewardsRepoProvider).archive(r.id),
                        icon: const Icon(Icons.close_rounded, color: N.muted, size: 20),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _name,
                      maxLength: 60,
                      decoration: const InputDecoration(hintText: 'New reward, e.g. Movie night', counterText: ''),
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 84,
                    child: TextField(
                      controller: _cost,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(6)],
                      style: N.num(15),
                      onSubmitted: (_) => _add(),
                      decoration: const InputDecoration(hintText: 'XP'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  NButton('Add', kind: BtnKind.raise, onTap: _add),
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
              const CardHeader('How you earn XP'),
              for (final (label, xp) in Xp.table)
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 9),
                  decoration: const BoxDecoration(
                    border: Border(top: BorderSide(color: N.line)),
                  ),
                  child: Row(
                    children: [
                      Expanded(child: Text(label, style: const TextStyle(fontSize: 14))),
                      Text('+$xp', style: N.num(14, color: N.gold)),
                    ],
                  ),
                ),
              const SizedBox(height: 6),
              Text(
                'Build Hour, targets, money and notes add more XP in later phases.',
                style: N.small.copyWith(fontSize: 12),
              ),
            ],
          ),
        ),
        if (redeemed.isNotEmpty) ...[
          const SizedBox(height: N.gap),
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const CardHeader('Redeemed'),
                for (final r in redeemed)
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 9),
                    decoration: const BoxDecoration(
                      border: Border(top: BorderSide(color: N.line)),
                    ),
                    child: Row(
                      children: [
                        Expanded(child: Text(r.name)),
                        Text(fmtDayKey(clock.calendarDateFor(r.atUtc)), style: N.small),
                        const SizedBox(width: 12),
                        Text('−${r.cost}', style: N.num(13, color: N.muted)),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
