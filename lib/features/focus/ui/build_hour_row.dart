import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/theme/widgets.dart';
import '../data/focus_controller.dart';
import '../data/focus_repo.dart';
import '../domain/focus_logic.dart';
import 'focus_screen.dart';

/// Build Hour row on Today's Focus card. Also shows any other running timer.
class BuildHourRow extends ConsumerWidget {
  const BuildHourRow({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(tickerProvider);
    final running = ref.watch(runningFocusProvider).value;
    final build = ref.watch(buildSecondsTodayProvider);
    final streak = ref.watch(buildStreakProvider);
    final now = ref.watch(clockProvider).nowUtc();
    final other = running != null && running.focusKind != FocusKind.build;
    final buildRunning = running != null && running.focusKind == FocusKind.build;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => context.push('/focus'),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Eyebrow(
                      other
                          ? '${running.focusKind.label}${running.paused ? ' · paused' : ''}'
                          : 'Build Hour · AI products${streak > 0 ? ' · 🔥$streak' : ''}',
                    ),
                    const SizedBox(height: 2),
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(text: fmtClockSecs(other ? running.elapsed(now) : build), style: N.num(22)),
                          if (!other)
                            TextSpan(
                              text: '  / 60:00',
                              style: N.num(13, color: N.muted),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (running != null)
              NButton(
                running.paused ? 'Resume' : 'Open',
                kind: BtnKind.raise,
                onTap: () {
                  if (running.paused) {
                    ref.read(focusControllerProvider).resume();
                  } else {
                    context.push('/focus');
                  }
                },
              )
            else
              NButton(
                build >= 3600 ? 'Go again' : 'Start',
                icon: Icons.play_arrow_rounded,
                onTap: () async {
                  await ref.read(focusControllerProvider).start(FocusKind.build);
                  if (context.mounted) context.push('/focus');
                },
              ),
          ],
        ),
        const SizedBox(height: 10),
        GoldBar(build / 3600, color: buildRunning || build > 0 ? null : N.line),
      ],
    );
  }
}
