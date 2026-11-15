import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/sleep/data/sleep_repo.dart';
import '../../features/sleep/domain/sleep_logic.dart';
import '../../features/tasks/data/tasks_repo.dart';
import '../../features/water/data/water_repo.dart';
import '../../features/water/domain/water_schedule.dart';
import '../providers.dart';
import '../settings/app_settings.dart';
import '../time/day_clock.dart';
import 'notification_service.dart';

/// Re-plans every scheduled reminder from current state. Cheap and
/// idempotent, so it runs after any relevant change and on app resume.
class ReminderSync {
  ReminderSync(this.ref);
  final Ref ref;
  final _n = NotificationService.instance;
  Timer? _debounce;

  void schedule() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 600), () => unawaited(run()));
  }

  Future<void> run() async {
    final s = ref.read(settingsProvider);
    final clock = ref.read(clockProvider);
    final latest = await ref.read(sleepRepoProvider).latest();
    final asleep = latest != null && latest.wokeAtUtc == null;
    await _water(s, clock, asleep, latest?.wokeAtUtc);
    await _tasks(s);
    await _bedtime(s, clock, asleep);
  }

  Future<void> _water(AppSettings s, DayClock clock, bool asleep, DateTime? lastWake) async {
    if (!s.on(Module.water) || !s.waterReminders || asleep) {
      await _n.cancelWater();
      return;
    }
    final today = clock.today();
    final logs = await ref.read(waterRepoProvider).watchDay(today).first;
    final now = clock.nowUtc();
    final windowEnd = (lastWake != null && now.difference(lastWake) < const Duration(hours: 18))
        ? lastWake.add(const Duration(hours: 17))
        : now.add(const Duration(hours: 12));
    final times = waterReminderTimes(
      clock: clock,
      glasses: logs.length,
      goal: s.waterGoal,
      interval: Duration(minutes: s.waterIntervalMin.clamp(30, 240)),
      lastDrinkUtc: logs.isEmpty ? null : logs.last.atUtc,
      windowEndUtc: windowEnd,
      quietStartHour: s.quietStart,
      quietEndHour: s.quietEnd,
    );
    if (times.isEmpty) {
      await _n.cancelWater();
    } else {
      await _n.scheduleWater(times, logs.length, s.waterGoal);
    }
  }

  Future<void> _tasks(AppSettings s) async {
    final pending = (await _n.pendingIds()).where((i) => i >= NotificationService.taskBase).toSet();
    final want = <int>{};
    if (s.on(Module.tasks) && s.taskReminders) {
      final now = DateTime.now().toUtc();
      for (final t in await ref.read(tasksRepoProvider).openWithTime()) {
        if (t.dueAtUtc!.isAfter(now)) {
          want.add(NotificationService.taskBase + t.id);
          await _n.scheduleTask(t.id, t.title, t.dueAtUtc!);
        }
      }
    }
    for (final id in pending.difference(want)) {
      await _n.cancelTask(id - NotificationService.taskBase);
    }
  }

  Future<void> _bedtime(AppSettings s, DayClock clock, bool asleep) async {
    final sug = ref.read(bedtimeSuggestionProvider);
    if (!s.on(Module.sleep) || !s.bedtimeNudge || asleep || sug == null) {
      await _n.cancelBedtime();
      return;
    }
    final now = clock.nowUtc();
    final nudgeMin = (sug.suggestedMin - 30 + 1440) % 1440;
    final cal = clock.calendarDateFor(now);
    var at = clock.localToUtc(cal, nudgeMin ~/ 60, nudgeMin % 60);
    if (!at.isAfter(now)) at = clock.localToUtc(DayKey.add(cal, 1), nudgeMin ~/ 60, nudgeMin % 60);
    await _n.scheduleBedtime(
      at,
      'Aim for bed by ${fmtClock(sug.suggestedMin)}: 15 min earlier than your recent average '
      '(${fmtDuration(sug.averageSleep)} a night vs ${s.sleepTargetHours.toStringAsFixed(s.sleepTargetHours % 1 == 0 ? 0 : 1)}h target).',
    );
  }
}

final reminderSyncProvider = Provider((ref) => ReminderSync(ref));
