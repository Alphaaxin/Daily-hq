import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/celebrate.dart';
import '../../../core/notifications/reminder_sync.dart';
import '../../../core/providers.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/theme/widgets.dart';
import '../data/water_repo.dart';

Future<void> addWater(WidgetRef ref, int n) async {
  final goal = ref.read(settingsProvider).waterGoal;
  final hit = await ref.read(waterRepoProvider).change(ref.read(todayProvider), n, goal);
  if (hit) ref.read(celebratorProvider).celebrate('Water goal reached 💧');
  ref.read(reminderSyncProvider).schedule();
}

class WaterSection extends ConsumerWidget {
  const WaterSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(waterCountProvider);
    final goal = ref.watch(settingsProvider).waterGoal;
    final shown = math.max(goal, count);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Eyebrow('Water'),
            const SizedBox(width: 6),
            Text('$count/$goal', style: N.num(12, color: count >= goal ? N.water : N.muted)),
            const Spacer(),
            IconBtn(Icons.remove_rounded, label: 'Remove a glass', onTap: () => addWater(ref, -1)),
            const SizedBox(width: 8),
            IconBtn(Icons.add_rounded, label: 'Add a glass', color: N.water, onTap: () => addWater(ref, 1)),
          ],
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 7,
          runSpacing: 7,
          children: [
            for (var i = 0; i < shown; i++)
              _Glass(
                on: i < count,
                onTap: () async {
                  // Tapping the last full glass empties it; any other sets the count.
                  final target = (i < count && i == count - 1) ? i : i + 1;
                  final hit = await ref.read(waterRepoProvider).setCount(ref.read(todayProvider), target, goal);
                  Haptic.tap();
                  if (hit) ref.read(celebratorProvider).celebrate('Water goal reached 💧');
                  ref.read(reminderSyncProvider).schedule();
                },
              ),
          ],
        ),
      ],
    );
  }
}

class _Glass extends StatelessWidget {
  const _Glass({required this.on, required this.onTap});
  final bool on;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      width: 28,
      height: 36,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(5), bottom: Radius.circular(10)),
        border: on ? null : Border.all(color: N.water.withValues(alpha: .55), width: 1.5),
        gradient: on
            ? const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF9BDBF2), Color(0xFF4BA9CF)],
              )
            : null,
        boxShadow: on ? [BoxShadow(color: N.water.withValues(alpha: .35), blurRadius: 10)] : null,
      ),
    ),
  );
}
