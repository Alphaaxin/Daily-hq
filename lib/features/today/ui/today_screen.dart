import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers.dart';
import '../../../core/settings/app_settings.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/theme/widgets.dart';
import '../../../core/time/format.dart';
import '../../gamification/data/life_score_provider.dart';
import '../../game/data/game_repo.dart';
import '../../gamification/data/xp_repo.dart';
import '../../focus/ui/build_hour_row.dart';
import '../../google/ui/today_events.dart';
import '../../game/ui/quest_card.dart';
import '../../habits/ui/habits_section.dart';
import '../../money/data/money_repo.dart';
import '../../money/domain/money_parser.dart';
import '../../mood/ui/mood_section.dart';
import '../../salah/ui/salah_section.dart';
import '../../sleep/data/sleep_repo.dart';
import '../../sleep/domain/sleep_logic.dart';
import '../../routines/data/routines_repo.dart';
import '../../routines/ui/routine_cards.dart';
import '../../sleep/ui/sleep_panel.dart';
import '../../targets/ui/targets_section.dart';
import '../../tasks/ui/task_widgets.dart';
import '../../water/ui/water_section.dart';

class TodayScreen extends ConsumerWidget {
  const TodayScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(settingsProvider);
    // Optional cards (banner, routines) carry their own bottom gap and
    // collapse to nothing when hidden; the core cards get a gap here.
    Widget gap(Widget w) => Padding(
      padding: const EdgeInsets.only(bottom: N.gap),
      child: w,
    );
    final cards = <Widget>[
      const _SleepPromptBanner(),
      const MorningRoutineCard(),
      const EveningShutdownCard(),
      gap(const _HeroCard()),
      gap(const _FocusCard()),
      if (s.on(Module.quests)) gap(const QuestCard()),
      if (s.on(Module.tasks)) gap(const TasksCard()),
      if (s.on(Module.water) || s.on(Module.habits) || s.on(Module.salah) || s.on(Module.mood)) const _BodySoulCard(),
    ];
    return ListView(
      padding: EdgeInsets.fromLTRB(16, 12, 16, 120 + MediaQuery.of(context).padding.bottom),
      children: [
        for (var i = 0; i < cards.length; i++)
          cards[i]
              .animate()
              .fadeIn(duration: 260.ms, delay: (40 * i).ms)
              .slideY(begin: .04, end: 0, duration: 260.ms, delay: (40 * i).ms, curve: Curves.easeOut),
      ],
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
    final streak = ref.watch(shieldedStreakProvider);
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
                        if (ref.watch(morningCompleteProvider)) const Pill('×1.2 XP', hot: true),
                        if (s.on(Module.money)) Pill('${formatInr(ref.watch(todaySpentProvider))} spent', mono: true),
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
          if (s.on(Module.focus)) const SubSection(child: BuildHourRow()),
          if (s.on(Module.targets)) const SubSection(child: TargetsSection()),
          const TodayEventsSection(),
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
    return Padding(
      padding: const EdgeInsets.only(bottom: N.gap),
      child: GlassCard(
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
      ),
    );
  }
}
