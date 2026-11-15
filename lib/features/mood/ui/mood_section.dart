import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/theme/widgets.dart';
import '../data/mood_repo.dart';

class MoodSection extends ConsumerWidget {
  const MoodSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final m = ref.watch(moodTodayProvider).value?.mood;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Eyebrow(m == null ? 'Mood' : 'Mood · ${moods[m - 1].$2}'),
        const SizedBox(height: 10),
        MoodRow(selected: m, onPick: (v) => ref.read(moodRepoProvider).set(ref.read(todayProvider), v)),
      ],
    );
  }
}

class MoodRow extends StatelessWidget {
  const MoodRow({super.key, required this.selected, required this.onPick});
  final int? selected;
  final ValueChanged<int> onPick;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      for (var i = 0; i < moods.length; i++) ...[
        if (i > 0) const SizedBox(width: 6),
        Expanded(
          child: Semantics(
            button: true,
            selected: selected == i + 1,
            label: moods[i].$2,
            child: Material(
              color: selected == i + 1 ? N.goldSoft : N.raise,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: selected == i + 1 ? N.gold : N.line),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {
                  Haptic.light();
                  onPick(i + 1);
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Center(
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 180),
                      opacity: selected == null || selected == i + 1 ? 1 : .45,
                      child: Text(moods[i].$1, style: const TextStyle(fontSize: 24)),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    ],
  );
}
