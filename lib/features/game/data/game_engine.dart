import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/native/native_bridge.dart';
import '../../../core/notifications/notification_service.dart';
import '../../../core/providers.dart';
import '../../../core/settings/app_settings.dart';
import '../../../core/time/day_clock.dart';
import '../../../core/time/format.dart';
import '../../focus/data/focus_repo.dart';
import '../../gamification/data/life_score_provider.dart';
import '../../gamification/data/xp_repo.dart';
import '../../insights/data/insights_repo.dart';
import '../../insights/ui/insights_screens.dart';
import '../../meetings/data/meetings_repo.dart';
import '../../money/data/money_repo.dart';
import '../../money/domain/money_parser.dart';
import '../../money/domain/money_summary.dart';
import '../../salah/data/salah_repo.dart';
import '../../salah/domain/prayer_times.dart';
import '../../targets/data/targets_repo.dart';
import '../../tasks/data/tasks_repo.dart';
import '../../water/data/water_repo.dart';
import '../../water/domain/water_schedule.dart';
import '../domain/nudges.dart';
import 'game_repo.dart';

/// Housekeeping that runs on app open / resume and from the 2-hourly worker:
/// streak shields, Life Score snapshots, smart nudges and widget data.
class GameEngine {
  GameEngine(this.ref);
  final Ref ref;
  Timer? _scoreDebounce;

  Future<void> onResume() async {
    await processShields();
    await runNudges();
    await pushWidgets();
  }

  Future<void> processShields() async {
    final active = await ref.read(xpRepoProvider).watchActiveDays().first;
    await ref.read(gameRepoProvider).processShields(active, ref.read(clockProvider).today());
  }

  /// Called whenever the Life Score changes (debounced).
  void scoreChanged(int score) {
    _scoreDebounce?.cancel();
    _scoreDebounce = Timer(const Duration(seconds: 2), () async {
      await ref.read(gameRepoProvider).saveScore(ref.read(todayProvider), score);
      await pushWidgets();
    });
  }

  Future<void> runNudges() async {
    final s = ref.read(settingsProvider);
    if (!s.on(Module.nudges)) return;
    final clock = ref.read(clockProvider);
    final now = clock.nowUtc();
    final today = clock.today();
    final hour = clock.toLocal(now).hour;
    final repo = ref.read(insightsRepoProvider);

    final targets = await ref.read(targetsRepoProvider).watch().first;
    final counts = await ref.read(targetsRepoProvider).watchDay(today).first;
    final left = targets.where((t) => (counts[t.id] ?? 0) < t.goal).length;
    final build = await ref.read(focusRepoProvider).buildMinutes(today);
    final meetings = await ref.read(meetingsRepoProvider).watchAll().first;
    final awaiting = meetings.where((m) => m.status == 'done' && !m.actionsCreated).length;
    final water = (await ref.read(waterRepoProvider).watchDay(today).first).length;
    final budget = <String>[];
    if (s.on(Module.money)) {
      final cats = await ref.read(moneyRepoProvider).categories();
      final month = await ref.read(moneyRepoProvider).watchMonth(monthKeyOf(today)).first;
      for (final c in cats.where((c) => c.budgetPaise != null)) {
        final spent = month
            .where((e) => e.categoryId == c.id && e.type == 'spent')
            .fold(0, (a, e) => a + e.amountPaise);
        if (budgetLevel(spent, c.budgetPaise) != BudgetLevel.ok) {
          budget.add(
            spent > c.budgetPaise!
                ? '${c.name} is over budget by ${formatInr(spent - c.budgetPaise!)}'
                : '${formatInr(c.budgetPaise! - spent)} left for ${c.name} this month',
          );
        }
      }
    }
    final review = await repo.review('weekly', weekStartOf(today));
    final ctx = NudgeContext(
      day: today,
      localHour: hour,
      quiet: inQuietHours(clock, now, s.quietStart, s.quietEnd),
      off: s.nudgesOff.toSet(),
      targetsLeft: s.on(Module.targets) ? left : 0,
      buildMinutesToday: build,
      buildModuleOn: s.on(Module.focus),
      meetingsAwaitingActions: awaiting,
      budgetWarnings: budget,
      overLimitApps: s.on(Module.screenTime) ? await overLimitApps(repo, clock.dayStartUtc(today)) : const [],
      isReviewDay: DayKey.weekday(today) == s.reviewDay,
      reviewDone: review != null,
      waterLeft: s.on(Module.water) ? (s.waterGoal - water).clamp(0, 99) : 0,
      eveningHour: s.eveningHour,
    );
    final sent = await repo.sentNudges();
    final list = evaluateNudges(ctx, alreadySent: sent);
    // At most one nudge per run, so it never feels spammy.
    if (list.isEmpty) return;
    final n = list.first;
    await NotificationService.instance.showNudge(
      nudgeTypes.keys.toList().indexOf(n.type),
      n.title,
      n.body,
      payload: 'nudge:${n.route}',
    );
    await repo.markNudge(n.key(today));
  }

  /// Sends fresh numbers to the home-screen "Today" widget.
  Future<void> pushWidgets() async {
    final s = ref.read(settingsProvider);
    final clock = ref.read(clockProvider);
    final today = clock.today();
    final water = (await ref.read(waterRepoProvider).watchDay(today).first).length;
    final tasks = (await ref.read(tasksRepoProvider).watchToday(today).first)
        .where((t) => t.doneAtUtc == null)
        .take(4)
        .toList();
    final day = ref.read(prayerCalculatorProvider).current(clock);
    final now = clock.nowUtc();
    final next = day.nextAfter(now);
    final (pName, pAt) = next == null ? ('Fajr', day.nextFajr) : (next.label, day.start(next));
    final streak = ref.read(shieldedStreakProvider);
    await NativeBridge.updateWidgets({
      'w_streak': '🔥 $streak',
      'w_water': '💧 $water/${s.waterGoal}',
      'w_prayer': '🕌 $pName ${fmtTime(clock, pAt)} · Life Score ${ref.read(lifeScoreProvider)}',
      'w_tasks': tasks.isEmpty ? 'No open tasks 🎉' : tasks.map((t) => '• ${t.title}').join('\n'),
    });
  }
}

String weekStartOf(String day) => DayKey.add(day, 1 - DayKey.weekday(day));

final gameEngineProvider = Provider((ref) => GameEngine(ref));
