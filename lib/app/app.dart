import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:quick_actions/quick_actions.dart';

import '../core/celebrate.dart';
import '../core/notifications/notification_service.dart';
import '../core/notifications/reminder_sync.dart';
import '../core/providers.dart';
import '../core/theme/nizam_theme.dart';
import '../features/focus/data/focus_controller.dart';
import '../features/google/data/drive_backup.dart';
import '../features/google/data/google_jobs.dart';
import '../features/money/ui/quick_log_sheet.dart';
import '../features/salah/data/salah_repo.dart';
import '../features/salah/domain/prayer_times.dart';
import '../features/sleep/data/sleep_repo.dart';
import '../features/sleep/ui/sleep_panel.dart';
import '../features/tasks/data/tasks_repo.dart';
import '../features/tasks/ui/task_widgets.dart';
import '../features/water/data/water_repo.dart';
import '../features/water/ui/water_section.dart';
import 'router.dart';

class NizamApp extends ConsumerStatefulWidget {
  const NizamApp({super.key, required this.initialLocation, this.launch, this.enablePlatform = true});
  final String initialLocation;
  final NotificationAppLaunchDetails? launch;

  /// False in widget tests (no plugins).
  final bool enablePlatform;

  @override
  ConsumerState<NizamApp> createState() => _NizamAppState();
}

class _NizamAppState extends ConsumerState<NizamApp> with WidgetsBindingObserver {
  late final GoRouter _router = buildRouter(widget.initialLocation);
  StreamSubscription? _taps;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    if (!widget.enablePlatform) return;
    _taps = NotificationService.instance.taps.listen(_onNotification);
    final l = widget.launch;
    if (l != null && l.didNotificationLaunchApp && l.notificationResponse != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _onNotification(l.notificationResponse!));
    }
    final qa = const QuickActions();
    qa.initialize((type) => WidgetsBinding.instance.addPostFrameCallback((_) => _onShortcut(type)));
    qa.setShortcutItems(const [
      ShortcutItem(type: 'money', localizedTitle: 'Log money', icon: 'ic_shortcut_money'),
      ShortcutItem(type: 'add_task', localizedTitle: 'Add task', icon: 'ic_shortcut_task'),
      ShortcutItem(type: 'water', localizedTitle: '+1 glass of water', icon: 'ic_shortcut_water'),
      ShortcutItem(type: 'sleep', localizedTitle: 'Good night / morning', icon: 'ic_shortcut_sleep'),
    ]);
    ref.read(reminderSyncProvider).schedule();
    ref.read(focusControllerProvider).resync();
    ref.read(googleJobsProvider).syncOnResume();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _taps?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && widget.enablePlatform) {
      ref.invalidate(tickerProvider);
      ref.read(reminderSyncProvider).schedule();
      ref.read(focusControllerProvider).resync();
      ref.read(googleJobsProvider).syncOnResume();
    }
  }

  BuildContext? get _ctx => rootNavKey.currentContext;

  Future<void> _onNotification(NotificationResponse r) async {
    final p = r.payload ?? '';
    final focus = ref.read(focusControllerProvider);
    switch (r.actionId) {
      case 'focus_pause':
        await focus.pause();
        return;
      case 'focus_resume':
        await focus.resume();
        return;
      case 'focus_stop':
        await focus.stop();
        _router.go('/today');
        return;
    }
    if (p.startsWith('salah:')) {
      if (r.actionId == 'salah_done') await _markPrayed(p);
      _router.go('/today');
      return;
    }
    if (p == 'focus') {
      _router.push('/focus');
      return;
    }
    if (p == 'backup') {
      _router.push('/google');
      try {
        await ref.read(driveBackupProvider).backupNow();
      } catch (_) {}
      return;
    }
    if (p == 'money') {
      _router.go('/money');
      return;
    }
    if (r.actionId == 'water_add' || (p == 'water' && r.actionId == null)) {
      if (r.actionId == 'water_add') {
        await addWater(ref, 1);
      }
      _router.go('/today');
    } else if (p.startsWith('task:')) {
      final id = int.tryParse(p.substring(5));
      if (r.actionId == 'task_done' && id != null) {
        final tasks = await ref.read(tasksRepoProvider).openWithTime();
        final t = tasks.where((x) => x.id == id).firstOrNull;
        if (t != null) await ref.read(tasksRepoProvider).toggle(t, ref.read(clockProvider));
        ref.read(reminderSyncProvider).schedule();
      }
      _router.go('/today');
    } else {
      _router.go('/today');
    }
  }

  /// "Prayed ✓" from a notification: marks that prayer if it isn't yet.
  Future<void> _markPrayed(String payload) async {
    final parts = payload.split(':');
    if (parts.length != 3) return;
    final prayer = Prayer.values.where((x) => x.name == parts[2]).firstOrNull;
    if (prayer == null) return;
    final day = ref.read(prayerCalculatorProvider).forDate(parts[1]);
    final logs = await ref.read(salahRepoProvider).watchDate(parts[1]).first;
    if (logs.containsKey(prayer)) return;
    await ref.read(salahRepoProvider).toggle(day, prayer, ref.read(clockProvider));
  }

  Future<void> _onShortcut(String type) async {
    final ctx = _ctx;
    switch (type) {
      case 'money':
        _router.go('/money');
        if (ctx != null && ctx.mounted) await showQuickLog(ctx);
      case 'add_task':
        _router.go('/today');
        if (ctx != null && ctx.mounted) await showAddTaskSheet(ctx);
      case 'water':
        await addWater(ref, 1);
        _router.go('/today');
      case 'sleep':
        _router.go('/today');
        final latest = await ref.read(sleepRepoProvider).latest();
        if (ctx == null || !ctx.mounted) return;
        if (latest != null && latest.asleep) {
          await goodMorning(ctx, ref);
        } else {
          await goodNight(ctx, ref);
        }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Re-plan reminders whenever the state they depend on changes.
    void resync(_, _) {
      if (widget.enablePlatform) ref.read(reminderSyncProvider).schedule();
    }

    ref.listen(waterCountProvider, resync);
    ref.listen(latestSleepProvider, resync);
    ref.listen(settingsStreamProvider, resync);
    ref.listen(todayProvider, resync);
    // Push task edits to Google Calendar a few seconds after they happen.
    void gsync(_, _) {
      if (widget.enablePlatform) ref.read(googleJobsProvider).syncSoon();
    }

    ref.listen(todayTasksProvider, gsync);
    ref.listen(upcomingTasksProvider, gsync);

    return MaterialApp.router(
      title: 'Solo Leveling',
      debugShowCheckedModeBanner: false,
      theme: nizamTheme(),
      darkTheme: nizamTheme(),
      themeMode: ThemeMode.dark,
      routerConfig: _router,
      builder: (context, child) => CelebrationLayer(child: child ?? const SizedBox.shrink()),
    );
  }
}
