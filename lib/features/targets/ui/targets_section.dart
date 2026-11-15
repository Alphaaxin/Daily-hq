import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/celebrate.dart';
import '../../../core/db/app_db.dart';
import '../../../core/providers.dart';
import '../../../core/theme/dialogs.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/theme/widgets.dart';
import '../../profiles/data/profiles_repo.dart';
import '../data/targets_repo.dart';

/// Daily quota counters on Today: tap + / −.
class TargetsSection extends ConsumerWidget {
  const TargetsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final targets = ref.watch(targetsProvider).value ?? const <Target>[];
    final counts = ref.watch(targetCountsProvider).value ?? const <int, int>{};
    final filter = ref.watch(profileFilterProvider);
    final shown = targets.where((t) => filter == null || t.profileId == null || t.profileId == filter).toList();
    final done = shown.where((t) => (counts[t.id] ?? 0) >= t.goal).length;

    Future<void> bump(Target t, int d) async {
      final hit = await ref.read(targetsRepoProvider).bump(t, ref.read(todayProvider), d);
      if (hit) ref.read(celebratorProvider).celebrate('${t.name}: done 🎯');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Eyebrow('Daily targets · $done/${shown.length}'),
            const Spacer(),
            GestureDetector(
              onTap: () => context.push('/targets'),
              child: const Text(
                'Edit',
                style: TextStyle(color: N.gold, fontWeight: FontWeight.w600, fontSize: 13),
              ),
            ),
          ],
        ),
        if (shown.isEmpty)
          const Padding(padding: EdgeInsets.only(top: 8), child: EmptyNote('Add targets like "Collect 20 leads".')),
        for (final t in shown)
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(child: Text(t.name, style: const TextStyle(fontSize: 14))),
                    IconBtn(Icons.remove_rounded, label: 'Minus one', onTap: () => bump(t, -1)),
                    SizedBox(
                      width: 66,
                      child: Text(
                        '${counts[t.id] ?? 0} / ${t.goal}',
                        textAlign: TextAlign.center,
                        style: N.num(14, color: (counts[t.id] ?? 0) >= t.goal ? N.good : N.ink),
                      ),
                    ),
                    IconBtn(Icons.add_rounded, label: 'Plus one', color: N.gold, onTap: () => bump(t, 1)),
                  ],
                ),
                const SizedBox(height: 6),
                GoldBar((counts[t.id] ?? 0) / t.goal, color: (counts[t.id] ?? 0) >= t.goal ? N.good : null, height: 5),
              ],
            ),
          ),
      ],
    );
  }
}

/// Edit targets: name, goal, profile.
class TargetsScreen extends ConsumerWidget {
  const TargetsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final targets = ref.watch(targetsProvider).value ?? const <Target>[];
    final profiles = {for (final p in ref.watch(profilesProvider).value ?? const <Profile>[]) p.id: p};
    final repo = ref.read(targetsRepoProvider);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: N.bg,
        surfaceTintColor: Colors.transparent,
        title: Text('Daily targets', style: N.h2.copyWith(fontSize: 18)),
        actions: [
          IconButton(
            tooltip: 'Add target',
            icon: const Icon(Icons.add_rounded, color: N.gold),
            onPressed: () async {
              final name = await askText(context, 'Target, e.g. Collect leads', '');
              if (name == null || name.trim().isEmpty || !context.mounted) return;
              final goal = await askInt(context, 'Daily goal', 10, 1, 500);
              if (goal != null) await repo.add(name, goal);
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 40),
        children: [
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final t in targets)
                  Container(
                    decoration: const BoxDecoration(
                      border: Border(top: BorderSide(color: N.line)),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(t.name, style: const TextStyle(fontSize: 15)),
                              Text(
                                [
                                  'Goal ${t.goal}/day',
                                  if (t.profileId != null) profiles[t.profileId]?.name ?? '',
                                  if (t.autoSource != 'none') 'auto-counts ${t.autoSource} (Phase 3)',
                                ].join(' · '),
                                style: N.small.copyWith(fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          tooltip: 'Edit',
                          icon: const Icon(Icons.edit_outlined, size: 18, color: N.muted),
                          onPressed: () async {
                            final name = await askText(context, 'Name', t.name);
                            if (name == null || !context.mounted) return;
                            final goal = await askInt(context, 'Daily goal', t.goal, 1, 500);
                            if (!context.mounted) return;
                            final prof = await showDialog<int>(
                              context: context,
                              builder: (ctx) => SimpleDialog(
                                title: Text('Work profile', style: N.h2),
                                children: [
                                  SimpleDialogOption(
                                    onPressed: () => Navigator.pop(ctx, -1),
                                    child: const Text('Any / none'),
                                  ),
                                  for (final p in profiles.values)
                                    SimpleDialogOption(onPressed: () => Navigator.pop(ctx, p.id), child: Text(p.name)),
                                ],
                              ),
                            );
                            await repo.update(
                              t.id,
                              name: name.trim().isEmpty ? null : name,
                              goal: goal,
                              profileId: prof == null ? const Value.absent() : Value(prof == -1 ? null : prof),
                            );
                          },
                        ),
                        IconButton(
                          tooltip: 'Remove',
                          icon: const Icon(Icons.close_rounded, size: 18, color: N.muted),
                          onPressed: () => repo.archive(t.id),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 8),
                Text(
                  'Completing a target gives +20 XP. Lead and email targets will count themselves once '
                  'Leads and Mail Merge arrive in Phase 3.',
                  style: N.small.copyWith(fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
