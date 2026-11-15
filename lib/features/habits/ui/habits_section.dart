import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/celebrate.dart';
import '../../../core/providers.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/theme/widgets.dart';
import '../data/habits_repo.dart';

class HabitsSection extends ConsumerWidget {
  const HabitsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habits = ref.watch(habitsProvider).value ?? const [];
    final done = ref.watch(habitsDoneTodayProvider).value ?? const <int>{};
    final streaks = ref.watch(habitStreaksProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Eyebrow('Habits · +5 XP each'),
            const Spacer(),
            Text(
              '${habits.where((h) => done.contains(h.id)).length}/${habits.length}',
              style: N.num(12, color: N.muted),
            ),
          ],
        ),
        const SizedBox(height: 10),
        if (habits.isEmpty)
          const EmptyNote('No habits yet. Add some in Me → Habits.')
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final h in habits)
                _HabitChip(
                  name: h.name,
                  on: done.contains(h.id),
                  streak: streaks[h.id] ?? 0,
                  onTap: () async {
                    final all = await ref.read(habitsRepoProvider).toggle(h.id, ref.read(todayProvider));
                    if (all) ref.read(celebratorProvider).celebrate('All habits done 🎯');
                  },
                ),
            ],
          ),
      ],
    );
  }
}

class _HabitChip extends StatelessWidget {
  const _HabitChip({required this.name, required this.on, required this.streak, required this.onTap});
  final String name;
  final bool on;
  final int streak;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    checked: on,
    child: Material(
      color: on ? N.goldSoft : N.raise,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: on ? N.gold.withValues(alpha: .5) : N.line),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Haptic.light();
          onTap();
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  gradient: on ? N.goldGradient : null,
                  border: on ? null : Border.all(color: N.muted, width: 1.5),
                ),
                child: on ? const Icon(Icons.check_rounded, size: 12, color: N.goldInk) : null,
              ),
              const SizedBox(width: 8),
              Text(
                name,
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: on ? N.ink : N.muted),
              ),
              if (streak > 1) ...[const SizedBox(width: 6), Text('🔥$streak', style: N.num(11, color: N.gold))],
            ],
          ),
        ),
      ),
    ),
  );
}
