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
