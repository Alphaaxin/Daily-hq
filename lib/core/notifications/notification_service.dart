import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

/// Thin wrapper around flutter_local_notifications with Nizam's channels and
/// id ranges. Exact alarms are used when allowed so Vivo doesn't delay them.
class NotificationService {
  NotificationService._();
  static final instance = NotificationService._();

  final _plugin = FlutterLocalNotificationsPlugin();
  final _taps = StreamController<NotificationResponse>.broadcast();
  bool _ready = false;

  /// Notification taps and action-button presses (payload / actionId).
  Stream<NotificationResponse> get taps => _taps.stream;

  static const waterBase = 1000; // 1000..1019
  static const focusOngoingId = 5000;
  static const focusDoneId = 5001;
  static const eyeBase = 5010; // 5010..5019
  static const azanBase = 6000; // 6000..6029 (3 days × 5 prayers × 2)
  static const followUpBase = 200000; // + follow-up id
  static const birthdayBase = 300000; // + person id
  static const nudgeBase = 7000; // 7000..7099
  static const bedtimeId = 3000;
  static const taskBase = 100000; // + task id

  static const _water = AndroidNotificationDetails(
    'water',
    'Water reminders',
    channelDescription: 'Every 1–2 hours until you hit your goal',
    importance: Importance.high,
    priority: Priority.high,
    category: AndroidNotificationCategory.reminder,
    actions: [AndroidNotificationAction('water_add', '+1 glass', showsUserInterface: true)],
  );
  static const _tasks = AndroidNotificationDetails(
    'tasks',
    'Task reminders',
    channelDescription: 'When a task with a time is due',
    importance: Importance.max,
    priority: Priority.max,
    category: AndroidNotificationCategory.reminder,
    actions: [AndroidNotificationAction('task_done', 'Mark done', showsUserInterface: true)],
  );
  static const _sleep = AndroidNotificationDetails(
    'sleep',
    'Bedtime nudges',
    channelDescription: 'A gentle nudge to wind down',
    importance: Importance.defaultImportance,
    category: AndroidNotificationCategory.reminder,
  );

  static const _general = AndroidNotificationDetails(
    'general',
    'Nudges & alerts',
    channelDescription: 'Budget alerts, backups and other one-off nudges',
    importance: Importance.high,
    priority: Priority.high,
  );

  static const _focusDone = AndroidNotificationDetails(
    'focus',
    'Focus timer',
    channelDescription: 'Pomodoro and Build Hour alerts',
    importance: Importance.max,
    priority: Priority.max,
    category: AndroidNotificationCategory.alarm,
  );
  static const _eye = AndroidNotificationDetails(
    'eyes',
    '20-20-20 breaks',
    channelDescription: 'Look 20 feet away for 20 seconds every 20 minutes of focus',
    importance: Importance.defaultImportance,
  );

  /// Ongoing "timer running" notification with a live chronometer.
  Future<void> showFocusOngoing({required String title, required int startMs, required bool paused}) async {
    if (!_ready) return;
    await _plugin.show(
      id: focusOngoingId,
      title: title,
      body: paused ? 'Paused · tap to resume' : 'Running · tap to open',
      payload: 'focus',
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          'focus_ongoing',
          'Running timer',
          channelDescription: 'Shows the Build Hour / Pomodoro / work timer while it runs',
          importance: Importance.low,
          priority: Priority.low,
          ongoing: true,
          autoCancel: false,
          onlyAlertOnce: true,
          showWhen: !paused,
          usesChronometer: !paused,
          when: startMs,
          category: AndroidNotificationCategory.stopwatch,
          actions: [
            AndroidNotificationAction(
              paused ? 'focus_resume' : 'focus_pause',
              paused ? 'Resume' : 'Pause',
              showsUserInterface: true,
            ),
            const AndroidNotificationAction('focus_stop', 'Stop', showsUserInterface: true),
          ],
        ),
      ),
    );
  }

  Future<void> cancelFocus() async {
    if (!_ready) return;
    await _plugin.cancel(id: focusOngoingId);
    await _plugin.cancel(id: focusDoneId);
    for (var i = 0; i < 10; i++) {
      await _plugin.cancel(id: eyeBase + i);
    }
  }

  Future<void> scheduleFocusDone(DateTime utc, String title, String body) =>
      _at(focusDoneId, utc, title, body, _focusDone, payload: 'focus');

  Future<void> scheduleEyeBreaks(List<DateTime> times) async {
    for (var i = 0; i < times.length && i < 10; i++) {
      await _at(
        eyeBase + i,
        times[i],
        '20-20-20 👀',
        'Look at something 20 feet away for 20 seconds. Roll your shoulders.',
        _eye,
        payload: 'focus',
      );
    }
  }

  static const _azan = AndroidNotificationDetails(
    'azan',
    'Prayer times',
    channelDescription: 'A chime at each prayer time',
    importance: Importance.max,
    priority: Priority.high,
    category: AndroidNotificationCategory.reminder,
    actions: [AndroidNotificationAction('salah_done', 'Prayed ✓', showsUserInterface: true)],
  );

  Future<void> scheduleAzan(List<(int, DateTime, String, String, String)> alerts) async {
    await cancelAzan();
    for (final (id, at, title, body, payload) in alerts) {
      await _at(id, at, title, body, _azan, payload: payload);
    }
  }

  Future<void> cancelAzan() async {
    if (!_ready) return;
    for (var i = 0; i < 30; i++) {
      await _plugin.cancel(id: azanBase + i);
    }
  }

  Future<void> scheduleFollowUp(int id, DateTime at, String title, String body, {bool phone = false, bool email = false}) =>
      _at(
        followUpBase + id,
        at,
        title,
        body,
        AndroidNotificationDetails(
          'followups',
          'Follow-ups',
          channelDescription: 'Calls, messages and e-mails you planned',
          importance: Importance.max,
          priority: Priority.high,
          category: AndroidNotificationCategory.reminder,
          actions: [
            if (phone) const AndroidNotificationAction('fu_call', 'Call', showsUserInterface: true),
            if (phone) const AndroidNotificationAction('fu_wa', 'WhatsApp', showsUserInterface: true),
            if (email) const AndroidNotificationAction('fu_mail', 'Email', showsUserInterface: true),
            const AndroidNotificationAction('fu_done', 'Done', showsUserInterface: true),
          ],
        ),
        payload: 'fu:$id',
      );

  Future<void> scheduleBirthday(int personId, DateTime at, String name) => _at(
        birthdayBase + personId,
        at,
        '🎂 $name\'s birthday today',
        'Tap to send a wish (AI can write it for you).',
        const AndroidNotificationDetails('birthdays', 'Birthdays', importance: Importance.high, priority: Priority.high),
        payload: 'bday:$personId',
      );

  /// Cancels scheduled notifications in [base, base+span) not in [keep].
  Future<void> cancelRangeExcept(int base, int span, Set<int> keep) async {
    for (final id in await pendingIds()) {
      if (id >= base && id < base + span && !keep.contains(id)) await _plugin.cancel(id: id);
    }
  }

  Future<void> showNudge(int slot, String title, String body, {String? payload}) async {
    if (!_ready) return;
    await _plugin.show(
      id: nudgeBase + slot,
      title: title,
      body: body,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails('nudges', 'Smart nudges', channelDescription: 'Context-aware suggestions',
            importance: Importance.defaultImportance),
      ),
      payload: payload,
    );
  }

  /// Shows a notification right away (budget alerts, backup prompts…).
  Future<void> showNow(int id, String title, String body, {String? payload}) async {
    if (!_ready) return;
    await _plugin.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: const NotificationDetails(android: _general),
      payload: payload,
    );
  }

  Future<NotificationAppLaunchDetails?> init() async {
    if (_ready || kIsWeb) return null;
    const settings = InitializationSettings(android: AndroidInitializationSettings('ic_stat_nizam'));
    await _plugin.initialize(settings: settings, onDidReceiveNotificationResponse: _taps.add);
    _ready = true;
    return _plugin.getNotificationAppLaunchDetails();
  }

  AndroidFlutterLocalNotificationsPlugin? get _android =>
      _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

  Future<bool> notificationsAllowed() async => await _android?.areNotificationsEnabled() ?? false;
  Future<bool> exactAllowed() async => await _android?.canScheduleExactNotifications() ?? false;
  Future<bool> requestNotifications() async => await _android?.requestNotificationsPermission() ?? false;
  Future<bool> requestExact() async => await _android?.requestExactAlarmsPermission() ?? false;

  Future<AndroidScheduleMode> _mode() async =>
      await exactAllowed() ? AndroidScheduleMode.exactAllowWhileIdle : AndroidScheduleMode.inexactAllowWhileIdle;

  Future<void> _at(
    int id,
    DateTime utc,
    String title,
    String body,
    AndroidNotificationDetails d, {
    String? payload,
  }) async {
    if (!_ready || utc.isBefore(DateTime.now().toUtc())) return;
    await _plugin.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: tz.TZDateTime.from(utc, tz.UTC),
      notificationDetails: NotificationDetails(android: d),
      androidScheduleMode: await _mode(),
      payload: payload,
    );
  }

  Future<void> scheduleWater(List<DateTime> times, int glasses, int goal) async {
    await cancelWater();
    for (var i = 0; i < times.length && i < 20; i++) {
      final left = goal - glasses;
      await _at(
        waterBase + i,
        times[i],
        'Water break 💧',
        '$glasses/$goal glasses · $left to go. One tap to log.',
        _water,
        payload: 'water',
      );
    }
  }

  Future<void> cancelWater() async {
    if (!_ready) return;
    for (var i = 0; i < 20; i++) {
      await _plugin.cancel(id: waterBase + i);
    }
  }

  Future<void> scheduleTask(int taskId, String title, DateTime dueUtc) =>
      _at(taskBase + taskId, dueUtc, 'Due now', title, _tasks, payload: 'task:$taskId');

  Future<void> cancelTask(int taskId) async {
    if (_ready) await _plugin.cancel(id: taskBase + taskId);
  }

  Future<void> scheduleBedtime(DateTime utc, String body) =>
      _at(bedtimeId, utc, 'Wind down 🌙', body, _sleep, payload: 'sleep');

  Future<void> cancelBedtime() async {
    if (_ready) await _plugin.cancel(id: bedtimeId);
  }

  Future<List<int>> pendingIds() async =>
      _ready ? (await _plugin.pendingNotificationRequests()).map((e) => e.id).toList() : const [];
}
