import 'dart:async';
import 'dart:ui';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:workmanager/workmanager.dart';

import '../../features/game/data/game_engine.dart';
import '../../features/google/data/calendar_sync.dart';
import '../../features/mail/data/mail_sender.dart';
import '../../features/google/data/drive_backup.dart';
import '../../features/google/domain/backup_names.dart';
import '../db/open_db.dart';
import '../notifications/notification_service.dart';
import '../providers.dart';
import '../settings/app_settings.dart';

const taskSync = 'nizam.calendarSync';
const taskBackup = 'nizam.backup10am';
const taskBackupRetry = 'nizam.backupRetry';
const backupPromptId = 4200;

/// Runs in a background isolate started by Android's WorkManager.
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, input) async {
    WidgetsFlutterBinding.ensureInitialized();
    DartPluginRegistrant.ensureInitialized();
    tzdata.initializeTimeZones();
    final db = await openAppDb();
    final container = ProviderContainer(overrides: [dbProvider.overrideWithValue(db)]);
    try {
      await NotificationService.instance.init();
      // Load settings into the container before using them.
      await container.read(settingsStreamProvider.future);
      final s = container.read(settingsProvider);
      if (task == taskSync) {
        // Every ~2 h: shields, nudges and the home-screen widget, even offline.
        try {
          await container.read(gameEngineProvider).processShields();
          await container.read(gameEngineProvider).runNudges();
          await container.read(gameEngineProvider).pushWidgets();
        } catch (_) {}
      }
      if (s.googleEmail.isEmpty) return true;
      switch (task) {
        case taskSync:
          await container.read(calendarSyncProvider).sync();
        case taskMailQueue:
          try {
            await container.read(mailSenderProvider).run();
          } catch (_) {
            await NotificationService.instance.showNow(
              backupPromptId + 1,
              'Scheduled e-mails are ready',
              'Tap to start sending your mail-merge campaign.',
              payload: 'nudge:/mail',
            );
          }
        case taskBackup || taskBackupRetry:
          if (_backedUpRecently(s)) return true;
          try {
            await container.read(driveBackupProvider).backupNow();
          } catch (_) {
            // Google sign-in often needs the app in front: ask nicely instead.
            await NotificationService.instance.showNow(
              backupPromptId,
              'Back up Solo Leveling',
              'Tap to back up today\'s data to Google Drive.',
              payload: 'backup',
            );
          }
      }
      return true;
    } catch (_) {
      return true; // never make WorkManager retry-loop
    } finally {
      container.dispose();
      await db.close();
    }
  });
}

bool _backedUpRecently(AppSettings s) {
  final last = DateTime.tryParse(s.lastBackupUtc);
  return last != null && DateTime.now().toUtc().difference(last) < const Duration(hours: 12);
}

/// Registers the periodic jobs. Safe to call on every launch.
Future<void> registerBackgroundWork({required Duration utcOffset}) async {
  try {
    await Workmanager().initialize(callbackDispatcher);
    final net = Constraints(networkType: NetworkType.connected);
    await Workmanager().registerPeriodicTask(
      taskSync,
      taskSync,
      frequency: const Duration(hours: 2),
      constraints: net,
      existingWorkPolicy: ExistingPeriodicWorkPolicy.keep,
    );
    final now = DateTime.now().toUtc();
    await Workmanager().registerPeriodicTask(
      taskBackup,
      taskBackup,
      frequency: const Duration(hours: 24),
      initialDelay: nextLocalHour(now, utcOffset, 10).difference(now),
      constraints: net,
      existingWorkPolicy: ExistingPeriodicWorkPolicy.keep,
    );
  } catch (_) {
    /* not on Android (tests) */
  }
}

/// A one-off backup as soon as there's network (used if Good Night's fails).
Future<void> queueBackupRetry() async {
  try {
    await Workmanager().registerOneOffTask(
      taskBackupRetry,
      taskBackupRetry,
      constraints: Constraints(networkType: NetworkType.connected),
      existingWorkPolicy: ExistingWorkPolicy.replace,
      initialDelay: const Duration(minutes: 5),
    );
  } catch (_) {}
}
