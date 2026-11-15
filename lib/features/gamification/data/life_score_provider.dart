import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers.dart';
import '../../../core/settings/app_settings.dart';
import '../../habits/data/habits_repo.dart';
import '../../salah/data/salah_repo.dart';
import '../../salah/domain/prayer_times.dart';
import '../../sleep/data/sleep_repo.dart';
import '../../tasks/data/tasks_repo.dart';
import '../../water/data/water_repo.dart';
import '../../../core/db/app_db.dart';
import '../../../core/time/day_clock.dart';
import '../../focus/data/focus_repo.dart';
import '../../game/domain/game_logic.dart';
import '../../money/data/money_repo.dart';
import '../../targets/data/targets_repo.dart';
import '../domain/life_score.dart';

final lifeInputsProvider = Provider<LifeInputs>((ref) {
  final s = ref.watch(settingsProvider);
  double? tasks, habits, salah, water, sleep, targets, build, money;

  if (s.on(Module.tasks)) {
    final l = ref.watch(todayTasksProvider).value ?? const [];
    tasks = l.isEmpty ? null : ratio(l.where((t) => t.doneAtUtc != null).length, l.length);
  }
  if (s.on(Module.habits)) {
    final h = ref.watch(habitsProvider).value ?? const [];
    final done = ref.watch(habitsDoneTodayProvider).value ?? const {};
    habits = h.isEmpty ? null : ratio(h.where((x) => done.contains(x.id)).length, h.length);
  }
  if (s.on(Module.salah)) {
    final st = ref.watch(salahStatusesProvider);
    salah = ratio(st.values.where((v) => v == SalahStatus.onTime || v == SalahStatus.late).length, 5);
  }
  if (s.on(Module.water)) {
    water = ratio(ref.watch(waterCountProvider), s.waterGoal);
  }
  if (s.on(Module.sleep)) {
    final d = ref.watch(todaySleepProvider);
    sleep = ratio(d?.inMinutes ?? 0, s.sleepTargetHours * 60);
  }
  if (s.on(Module.targets)) {
    final ts = ref.watch(targetsProvider).value ?? const <Target>[];
    final counts = ref.watch(targetCountsProvider).value ?? const <int, int>{};
    targets = ts.isEmpty ? null : ts.map((t) => ratio(counts[t.id] ?? 0, t.goal)).reduce((a, b) => a + b) / ts.length;
  }
  if (s.on(Module.focus)) {
    build = ratio(ref.watch(buildSecondsTodayProvider), 3600);
  }
  if (s.on(Module.money) && s.monthlyBudgetPaise > 0) {
    final d = DayKey.toDate(ref.watch(todayProvider));
    money = moneyDiscipline(
      spentTodayPaise: ref.watch(todaySpentProvider),
      monthlyBudgetPaise: s.monthlyBudgetPaise,
      daysInMonth: DateTime.utc(d.year, d.month + 1, 0).day,
    );
  }
  return LifeInputs(
    tasks: tasks,
    habits: habits,
    targets: targets,
    salah: salah,
    sleep: sleep,
    water: water,
    build: build,
    money: money,
  );
});

final lifeScoreProvider = Provider<int>((ref) => lifeScore(ref.watch(lifeInputsProvider)));
