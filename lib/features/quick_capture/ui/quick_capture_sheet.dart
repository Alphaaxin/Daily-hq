import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers.dart';
import '../../../core/settings/app_settings.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/theme/widgets.dart';
import '../../mood/data/mood_repo.dart';
import '../../mood/ui/mood_section.dart';
import '../../sleep/data/sleep_repo.dart';
import '../../sleep/ui/sleep_panel.dart';
import '../../tasks/ui/task_widgets.dart';
import '../../water/data/water_repo.dart';
import '../../water/ui/water_section.dart';

Future<void> showQuickCapture(BuildContext context) => showNSheet(context, (_) => const QuickCaptureSheet());

/// Everything common in at most 2 taps.
class QuickCaptureSheet extends ConsumerWidget {
  const QuickCaptureSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(settingsProvider);
    final latest = ref.watch(latestSleepProvider).value;
    final asleep = latest != null && latest.asleep;
    final water = ref.watch(waterCountProvider);
    final mood = ref.watch(moodTodayProvider).value?.mood;

    void close() => Navigator.of(context).pop();

    final tiles = <Widget>[
      if (s.on(Module.tasks))
        _Tile(Icons.check_circle_outline_rounded, 'Task', N.gold, () {
          close();
          showAddTaskSheet(context);
        }),
      if (s.on(Module.water))
        _Tile(Icons.water_drop_outlined, '+1 water · $water', N.water, () async {
          await addWater(ref, 1);
          Haptic.light();
        }),
      if (s.on(Module.sleep))
        asleep
            ? _Tile(Icons.wb_sunny_outlined, 'Good Morning', N.goldHi, () {
                close();
                goodMorning(context, ref);
              })
            : _Tile(Icons.nightlight_outlined, 'Good Night', N.night, () {
                close();
                goodNight(context, ref);
              }),
      if (s.on(Module.sleep))
        _Tile(Icons.edit_calendar_outlined, 'Log sleep', N.night, () {
          close();
          showLogSleepSheet(context);
        }),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Quick capture', style: N.h2.copyWith(fontSize: 18)),
        const SizedBox(height: 14),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 2.3,
          children: tiles,
        ),
        if (s.on(Module.mood)) ...[
          const SizedBox(height: 16),
          const Eyebrow('How are you feeling?'),
          const SizedBox(height: 8),
          MoodRow(selected: mood, onPick: (v) => ref.read(moodRepoProvider).set(ref.read(todayProvider), v)),
        ],
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: N.line),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const Text(
                '₹',
                style: TextStyle(fontFamily: N.display, fontWeight: FontWeight.w700, color: N.gold, fontSize: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Money quick-log, notes, leads and meeting recording arrive in Phases 2–3.',
                  style: N.small,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile(this.icon, this.label, this.color, this.onTap);
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
    color: N.raise,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
      side: const BorderSide(color: N.line),
    ),
    child: InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        Haptic.light();
        onTap();
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Row(
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
