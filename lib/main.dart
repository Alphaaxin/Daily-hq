import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import 'app/app.dart';
import 'app/quick_log_popup.dart';
import 'core/background/background.dart';
import 'core/db/open_db.dart';
import 'core/notifications/notification_service.dart';
import 'core/providers.dart';
import 'core/settings/app_settings.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
  tzdata.initializeTimeZones();

  final db = await openAppDb();
  final settings = await SettingsRepo(db).load();
  final launch = await NotificationService.instance.init();

  // Launched by the Quick Settings tile / widget / bubble: popup only.
  if (WidgetsBinding.instance.platformDispatcher.defaultRouteName == '/quicklog') {
    runApp(ProviderScope(overrides: [dbProvider.overrideWithValue(db)], child: const QuickLogPopupApp()));
    return;
  }

  final loc = tz.getLocation(settings.timezone);
  unawaited(registerBackgroundWork(utcOffset: Duration(milliseconds: loc.currentTimeZone.offset)));

  runApp(
    ProviderScope(
      overrides: [dbProvider.overrideWithValue(db)],
      child: NizamApp(initialLocation: settings.onboarded ? '/today' : '/welcome', launch: launch),
    ),
  );
}
