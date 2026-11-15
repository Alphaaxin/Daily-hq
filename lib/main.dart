import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/data/latest.dart' as tzdata;

import 'app/app.dart';
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

  runApp(
    ProviderScope(
      overrides: [dbProvider.overrideWithValue(db)],
      child: NizamApp(initialLocation: settings.onboarded ? '/today' : '/welcome', launch: launch),
    ),
  );
}
