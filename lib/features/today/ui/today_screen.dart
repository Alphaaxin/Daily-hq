import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers.dart';
import '../../../core/settings/app_settings.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/theme/widgets.dart';
import '../../../core/time/format.dart';
import '../../gamification/data/life_score_provider.dart';
import '../../gamification/data/xp_repo.dart';
import '../../habits/ui/habits_section.dart';
import '../../mood/ui/mood_section.dart';
import '../../salah/ui/salah_section.dart';
import '../../sleep/data/sleep_repo.dart';
import '../../sleep/domain/sleep_logic.dart';
import '../../sleep/ui/sleep_panel.dart';
import '../../tasks/ui/task_widgets.dart';
import '../../water/ui/water_section.dart';

class TodayScreen extends ConsumerWidget {
  const TodayScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(settingsProvider);
    final cards = <Widget>[
      const _SleepPromptBanner(),
      const _HeroCard(),
      const _FocusCard(),
      if (s.on(Module.tasks)) const TasksCard(),
      if (s.on(Module.water) || s.on(Module.habits) || s.on(Module.salah) || s.on(Module.mood)) const _BodySoulCard(),
    ];
    return ListView.separated(
      padding: EdgeInsets.fromLTRB(16, 12, 16, 120 + MediaQuery.of(context).padding.bottom),
      itemCount: cards.length,
      separatorBuilder: (_, _) => const SizedBox(height: N.gap),
      itemBuilder: (_, i) => cards[i]
          .animate()
          .fadeIn(duration: 260.ms, delay: (40 * i).ms)
          .slideY(begin: .04, end: 0, duration: 260.ms, delay: (40 * i).ms, curve: Curves.easeOut),
    );
  }
}

class _HeroCard extends ConsumerWidget {
  const _HeroCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(tickerProvider);
    final s = ref.watch(settingsProvider);
    final clock = ref.watch(clockProvider);
    final today = ref.watch(todayProvider);
    final lvl = ref.watch(levelProvider);
    final streak = ref.watch(overallStreakProvider);
    final xpToday = ref.watch(xpTodayProvider).value ?? 0;
    final score = ref.watch(lifeScoreProvider);
    final hr = clock.toLocal(clock.nowUtc()).hour;
    final greet = hr < 5
        ? 'Still up'
        : hr < 12
        ? 'Good morning'
        : hr < 17
        ? 'Good afternoon'
        : hr < 21
        ? 'Good evening'
        : 'Good night';

    return GlassCard(
      hero: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Eyebrow(fmtDayKey(today)),
                    const SizedBox(height: 6),
                    Text('$greet,', style: N.h1),
                    GoldText(s.name, style: N.h1),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        Pill('Lv ${lvl.level} · ${lvl.name}', hot: true),
                        Pill(streak > 0 ? '🔥 $streak-day streak' : 'Start a streak'),
                        Pill('+$xpToday XP', mono: true),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              ScoreRing(score: score),
            ],
          ),
          const SizedBox(height: 14),
          GoldBar(lvl.progress),
          const SizedBox(height: 6),
          Text.rich(
            TextSpan(
              style: N.small,
              children: [
                TextSpan(
                  text: '${lvl.toNext}',
                  style: N.num(13, color: N.muted),
                ),
                TextSpan(text: ' XP to level ${lvl.level + 1}'),
              ],
            ),
          ),
          if (s.on(Module.sleep)) const SubSection(child: SleepPanel()),
        ],
      ),
    );
  }
}

class _FocusCard extends ConsumerWidget {
  const _FocusCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(settingsProvider);
    final sug = s.on(Module.sleep) ? ref.watch(bedtimeSuggestionProvider) : null;
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CardHeader('Focus'),
          if (s.on(Module.salah)) const NextPrayerLine(),
          if (sug != null) ...[
            if (s.on(Module.salah)) const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.bedtime_outlined, size: 20, color: N.night),
                const SizedBox(width: 10),
                Expanded(
                  child: Text.rich(
                    TextSpan(
                      style: N.small,
                      children: [
                        const TextSpan(text: 'Tonight, aim for bed by '),
                        TextSpan(
                          text: fmtClock(sug.suggestedMin),
                          style: N.num(13, color: N.ink),
                        ),
                        TextSpan(
                          text:
                              '. Avg ${fmtDuration(sug.averageSleep)} vs ${s.sleepTargetHours.toStringAsFixed(0)}h target.',
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
          SubSection(
            child: Row(
              children: [
                const Icon(Icons.rocket_launch_outlined, size: 20, color: N.muted),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Eyebrow('Build Hour · Daily targets'),
                      const SizedBox(height: 2),
                      Text('Timer, idea picker and lead/email quotas arrive in Phase 2.', style: N.small),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BodySoulCard extends ConsumerWidget {
  const _BodySoulCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(settingsProvider);
    final parts = <Widget>[
      if (s.on(Module.water)) const WaterSection(),
      if (s.on(Module.habits)) const HabitsSection(),
      if (s.on(Module.salah)) const SalahSection(),
      if (s.on(Module.mood)) const MoodSection(),
    ];
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const CardHeader('Body & soul'),
          for (var i = 0; i < parts.length; i++) i == 0 ? parts[i] : SubSection(child: parts[i]),
        ],
      ),
    );
  }
}

class _SleepPromptBanner extends ConsumerWidget {
  const _SleepPromptBanner();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(settingsProvider);
    if (!s.on(Module.sleep)) return const SizedBox.shrink();
    ref.watch(todayProvider);
    final latestAsync = ref.watch(latestSleepProvider);
    if (!latestAsync.hasValue) return const SizedBox.shrink();
    final latest = latestAsync.value;
    final prompt = sleepPrompt(
      clock: ref.watch(clockProvider),
      latest: latest?.span,
      dismissedFor: s.sleepPromptDismissed,
    );
    if (prompt == SleepPrompt.none) return const SizedBox.shrink();
    return GlassCard(
      child: Row(
        children: [
          const Icon(Icons.nights_stay_outlined, color: N.night),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(prompt == SleepPrompt.askWake ? 'Still asleep? 😄' : 'Forgot to log sleep?', style: N.h2),
                const SizedBox(height: 2),
                Text('What time did you sleep / wake?', style: N.small),
              ],
            ),
          ),
          TextButton(
            onPressed: () => ref.read(settingsRepoProvider).set('sleepPromptDismissed', ref.read(todayProvider)),
            child: const Text('Skip', style: TextStyle(color: N.muted)),
          ),
          NButton('Log', onTap: () => showLogSleepSheet(context)),
        ],
      ),
    );
  }
}
