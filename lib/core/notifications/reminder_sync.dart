import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/people/data/contacts_repo.dart';
import '../../features/salah/data/salah_repo.dart';
import '../../features/salah/domain/azan_schedule.dart';
import '../../features/salah/domain/prayer_times.dart';
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
    await _azan(s, clock);
    await _followUps(s, clock);
  }

  Future<void> _followUps(AppSettings s, DayClock clock) async {
    final keep = <int>{};
    final contacts = ref.read(contactsRepoProvider);
    final now = clock.nowUtc();
    if (s.on(Module.people) || s.on(Module.leads)) {
      final people = {for (final p in await contacts.allPeople()) p.id: p};
      final leads = {for (final l in await contacts.allLeads()) l.id: l};
      for (final f in await contacts.openFollowUps()) {
        if (f.dueAtUtc.isAfter(now.add(const Duration(days: 14)))) continue;
        final p = people[f.personId];
        final l = leads[f.leadId];
        final who = p?.name ?? l?.name ?? 'Follow-up';
        final phone = (p?.phone ?? l?.phone ?? '').isNotEmpty;
        final email = (p?.email ?? l?.email ?? '').isNotEmpty;
        // Overdue ones already notified at their time; they wait in People.
        if (!f.dueAtUtc.isAfter(now)) continue;
        final at = f.dueAtUtc;
        keep.add(NotificationService.followUpBase + f.id);
        await _n.scheduleFollowUp(f.id, at, '${_icon(f.channel)} $who', f.note.isEmpty ? 'Time to follow up' : f.note,
            phone: phone, email: email);
      }
      if (s.on(Module.people)) {
        final today = clock.today();
        for (final p in people.values) {
          final next = nextBirthday(p.birthday, today);
          if (next == null || DayKey.diff(today, next) > 30) continue;
          final at = clock.localToUtc(next, 10, 0);
          if (!at.isAfter(now)) continue;
          keep.add(NotificationService.birthdayBase + p.id);
          await _n.scheduleBirthday(p.id, at, p.name);
        }
      }
    }
    await _n.cancelRangeExcept(NotificationService.followUpBase, 100000, keep);
    await _n.cancelRangeExcept(NotificationService.birthdayBase, 100000, keep);
  }

  String _icon(String channel) => switch (channel) {
        'call' => '📞',
        'whatsapp' => '💬',
        'email' => '✉️',
        _ => '⏰',
      };

  Future<void> _azan(AppSettings s, DayClock clock) async {
    if (!s.on(Module.salah) || !s.azan) {
      await _n.cancelAzan();
      return;
    }
    final alerts = azanSchedule(
      calc: ref.read(prayerCalculatorProvider),
      clock: clock,
      baseId: NotificationService.azanBase,
      off: {
        for (final p in Prayer.values)
          if (s.azanOff.contains(p.name)) p,
      },
      beforeMinutes: s.azanBefore ? 10 : null,
    );
    await _n.scheduleAzan([for (final a in alerts) (a.id, a.atUtc, a.title, a.body, a.payload)]);
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
    final pending = (await _n.pendingIds())
        .where((i) => i >= NotificationService.taskBase && i < NotificationService.followUpBase)
        .toSet();
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
