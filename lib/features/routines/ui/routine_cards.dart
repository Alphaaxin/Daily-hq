import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/celebrate.dart';
import '../../../core/db/app_db.dart';
import '../../../core/notifications/reminder_sync.dart';
import '../../../core/providers.dart';
import '../../../core/settings/app_settings.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/theme/widgets.dart';
import '../../sleep/data/sleep_repo.dart';
import '../../tasks/data/tasks_repo.dart';
import '../data/routines_repo.dart';

class _Checklist extends ConsumerWidget {
  const _Checklist({required this.items, required this.done});
  final List<RoutineItem> items;
  final Set<int> done;

  @override
  Widget build(BuildContext context, WidgetRef ref) => Column(
    children: [
      for (final i in items)
        InkWell(
          onTap: () async {
            Haptic.light();
            final complete = await ref.read(routinesRepoProvider).toggle(i, ref.read(todayProvider));
            if (complete) ref.read(celebratorProvider).celebrate('Morning routine done: ×1.2 XP today ⚡');
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    gradient: done.contains(i.id) ? N.goldGradient : null,
                    border: done.contains(i.id) ? null : Border.all(color: N.muted.withValues(alpha: .5), width: 2),
                  ),
                  child: done.contains(i.id) ? const Icon(Icons.check_rounded, size: 16, color: N.goldInk) : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    i.name,
                    style: TextStyle(
                      fontSize: 15,
                      color: done.contains(i.id) ? N.muted : N.ink,
                      decoration: done.contains(i.id) ? TextDecoration.lineThrough : null,
                      decorationColor: N.muted,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
    ],
  );
}

/// Shown while you're awake and the morning routine isn't finished.
class MorningRoutineCard extends ConsumerWidget {
  const MorningRoutineCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(settingsProvider);
    if (!s.on(Module.routines) || ref.watch(morningCompleteProvider)) return const SizedBox.shrink();
    final latest = ref.watch(latestSleepProvider).value;
    if (latest != null && latest.asleep) return const SizedBox.shrink();
    final clock = ref.watch(clockProvider);
    ref.watch(tickerProvider);
    final h = clock.toLocal(clock.nowUtc()).hour;
    if (h >= s.eveningHour || h < s.rolloverHour) return const SizedBox.shrink();
    final items = ref.watch(morningItemsProvider).value ?? const <RoutineItem>[];
    if (items.isEmpty) return const SizedBox.shrink();
    final done = ref.watch(routineDoneTodayProvider).value ?? const <int>{};
    return Padding(
      padding: const EdgeInsets.only(bottom: N.gap),
      child: GlassCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CardHeader(
              'Morning routine',
              trailing: Pill(
                '${items.where((i) => done.contains(i.id)).length}/${items.length} · unlocks ×1.2 XP',
                hot: true,
              ),
            ),
            _Checklist(items: items, done: done),
          ],
        ),
      ),
    );
  }
}

/// Evening shutdown: from [AppSettings.eveningHour] until the day ends.
class EveningShutdownCard extends ConsumerStatefulWidget {
  const EveningShutdownCard({super.key, this.force = false});
  final bool force;

  @override
  ConsumerState<EveningShutdownCard> createState() => _EveningShutdownCardState();
}

class _EveningShutdownCardState extends ConsumerState<EveningShutdownCard> {
  final _grat = TextEditingController();

  @override
  void dispose() {
    _grat.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(settingsProvider);
    if (!s.on(Module.routines) || (ref.watch(eveningDoneTodayProvider).value ?? false)) return const SizedBox.shrink();
    final clock = ref.watch(clockProvider);
    ref.watch(tickerProvider);
    final h = clock.toLocal(clock.nowUtc()).hour;
    if (!widget.force && !(h >= s.eveningHour || h < s.rolloverHour)) return const SizedBox.shrink();
    final items = ref.watch(eveningItemsProvider).value ?? const <RoutineItem>[];
    final done = ref.watch(routineDoneTodayProvider).value ?? const <int>{};
    final open = (ref.watch(todayTasksProvider).value ?? const <Task>[])
        .where((t) => t.doneAtUtc == null && t.dueDay != null)
        .length;

    return Padding(
      padding: const EdgeInsets.only(bottom: N.gap),
      child: GlassCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const CardHeader('Evening shutdown', trailing: Pill('+10 XP', hot: true)),
            _Checklist(items: items, done: done),
            if (open > 0) ...[
              const SizedBox(height: 6),
              NButton(
                'Roll $open unfinished ${open == 1 ? 'task' : 'tasks'} to tomorrow',
                kind: BtnKind.raise,
                expand: true,
                onTap: () async {
                  await ref.read(tasksRepoProvider).rollToTomorrow(ref.read(clockProvider));
                  ref.read(reminderSyncProvider).schedule();
                },
              ),
            ],
            const SizedBox(height: 12),
            TextField(
              controller: _grat,
              maxLength: 140,
              decoration: const InputDecoration(hintText: 'One thing you\'re grateful for today', counterText: ''),
            ),
            const SizedBox(height: 12),
            NButton(
              'Finish the day',
              icon: Icons.nightlight_round,
              expand: true,
              onTap: () async {
                await ref.read(routinesRepoProvider).finishEvening(ref.read(todayProvider), _grat.text);
                if (context.mounted) showSnack(context, 'Day closed. Rest well 🌙');
              },
            ),
          ],
        ),
      ),
    );
  }
}
