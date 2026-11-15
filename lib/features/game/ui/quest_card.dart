import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/celebrate.dart';
import '../../../core/db/app_db.dart';
import '../../../core/providers.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/theme/widgets.dart';
import '../data/game_repo.dart';
import 'plant.dart';

/// Today's quests, the weekly boss, your plant and streak shields.
class QuestCard extends ConsumerWidget {
  const QuestCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quests = ref.watch(todayQuestsProvider).value ?? const <(Quest, bool)>[];
    final boss = ref.watch(bossProvider).value;
    final plant = ref.watch(plantProvider);
    final shields = ref.watch(shieldBalanceProvider);
    final streak = ref.watch(shieldedStreakProvider);
    final repo = ref.read(gameRepoProvider);
    final day = ref.watch(todayProvider);

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Quests', style: N.h2),
                    const SizedBox(height: 4),
                    Text(plant.name, style: N.small.copyWith(color: plant.wilting ? N.warn : N.good)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        Pill('🔥 $streak-day streak', hot: true),
                        Pill('🛡️ $shields shield${shields == 1 ? '' : 's'}'),
                      ],
                    ),
                  ],
                ),
              ),
              PlantView(stage: plant.stage, wilting: plant.wilting, size: 84),
            ],
          ),
          const SizedBox(height: 6),
          for (final (q, done) in quests)
            Container(
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: N.line)),
              ),
              child: Row(
                children: [
                  Checkbox(
                    value: done,
                    activeColor: N.gold,
                    checkColor: N.goldInk,
                    side: const BorderSide(color: N.muted, width: 1.5),
                    onChanged: (v) async {
                      Haptic.light();
                      await repo.toggleQuest(day, q, v ?? false);
                      final all = (ref.read(todayQuestsProvider).value ?? const []).every(
                        (x) => x.$1.id == q.id ? (v ?? false) : x.$2,
                      );
                      if ((v ?? false) && all) ref.read(celebratorProvider).celebrate('All quests cleared ⚔️');
                    },
                  ),
                  Expanded(
                    child: Text(
                      q.title,
                      style: TextStyle(
                        fontSize: 14,
                        color: done ? N.muted : N.ink,
                        decoration: done ? TextDecoration.lineThrough : null,
                        decorationColor: N.muted,
                      ),
                    ),
                  ),
                  Text('+${q.xp}', style: N.num(12, color: N.gold)),
                  if (!done)
                    IconButton(
                      tooltip: 'Swap quest',
                      visualDensity: VisualDensity.compact,
                      icon: const Icon(Icons.shuffle_rounded, size: 18, color: N.muted),
                      onPressed: () => repo.reroll(day, q),
                    ),
                ],
              ),
            ),
          if (boss != null) ...[
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: boss.beaten ? N.goodSoft : N.badSoft,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: boss.beaten ? N.good : N.bad.withValues(alpha: .4)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Text(boss.beaten ? '🏆' : '👹', style: const TextStyle(fontSize: 20)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Eyebrow('Weekly boss'),
                            Text(boss.boss.title, style: const TextStyle(fontWeight: FontWeight.w700)),
                          ],
                        ),
                      ),
                      Text('${boss.progress}/${boss.boss.goal}', style: N.num(14)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  GoldBar(boss.progress / boss.boss.goal, color: boss.beaten ? N.good : N.bad, height: 5),
                  if (boss.beaten && !boss.claimed) ...[
                    const SizedBox(height: 10),
                    NButton(
                      'Claim +${boss.boss.xp} XP',
                      expand: true,
                      onTap: () async {
                        if (await repo.claimBoss(boss, day)) {
                          ref.invalidate(bossProvider);
                          ref.read(celebratorProvider).celebrate('Boss defeated! +${boss.boss.xp} XP');
                        }
                      },
                    ),
                  ],
                  if (boss.claimed)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text('Defeated ✓', style: N.small.copyWith(color: N.good)),
                    ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 8),
          Text(
            'Shields: earn one each week you\'re active 5+ days (max 3). One is used automatically to save your streak on a missed day.',
            style: N.small.copyWith(fontSize: 11),
          ),
        ],
      ),
    );
  }
}
