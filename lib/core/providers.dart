import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/timezone.dart' as tz;

import 'db/app_db.dart';
import 'settings/app_settings.dart';
import 'time/day_clock.dart';

/// Overridden in main() with the opened database.
final dbProvider = Provider<AppDb>((ref) => throw UnimplementedError('dbProvider not overridden'));

final settingsRepoProvider = Provider((ref) => SettingsRepo(ref.watch(dbProvider)));

final settingsStreamProvider = StreamProvider<AppSettings>((ref) => ref.watch(settingsRepoProvider).watch());

/// Current settings, falling back to defaults until the first read lands.
final settingsProvider = Provider<AppSettings>((ref) => ref.watch(settingsStreamProvider).value ?? const AppSettings());

/// "Now" source. Overridden in tests with a fixed clock.
final nowFnProvider = Provider<DateTime Function()>((ref) => DateTime.now);

/// Ticks every 20 s so day keys, timers and prayer statuses stay live.
final tickerProvider = StreamProvider<DateTime>((ref) {
  final now = ref.watch(nowFnProvider);
  final c = StreamController<DateTime>();
  c.add(now());
  final t = Timer.periodic(const Duration(seconds: 20), (_) => c.add(now()));
  ref.onDispose(() {
    t.cancel();
    c.close();
  });
  return c.stream;
});

final clockProvider = Provider<DayClock>((ref) {
  final s = ref.watch(settingsProvider);
  tz.Location loc;
  try {
    loc = tz.getLocation(s.timezone);
  } catch (_) {
    loc = tz.getLocation('Asia/Kolkata');
  }
  return DayClock(location: loc, rolloverHour: s.rolloverHour, now: ref.watch(nowFnProvider));
});

/// The current logical day key; only notifies when the day actually changes.
final todayProvider = Provider<String>((ref) {
  ref.watch(tickerProvider);
  return ref.watch(clockProvider).today();
});
