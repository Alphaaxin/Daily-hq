import 'dart:io';
import 'dart:ui' as ui;

import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nizam/app/app.dart';
import 'package:nizam/core/db/app_db.dart';
import 'package:nizam/core/db/open_db.dart';
import 'package:nizam/core/providers.dart';
import 'package:nizam/core/time/day_clock.dart';
import 'package:nizam/features/gamification/data/xp_repo.dart';
import 'package:nizam/features/habits/data/habits_repo.dart';
import 'package:nizam/features/mood/data/mood_repo.dart';
import 'package:nizam/features/salah/data/salah_repo.dart';
import 'package:nizam/features/salah/domain/prayer_times.dart';
import 'package:nizam/features/tasks/data/tasks_repo.dart';
import 'package:nizam/features/water/data/water_repo.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

/// Set NIZAM_SHOTS=/some/dir to also write phone-size screenshots there.
final shotsDir = Platform.environment['NIZAM_SHOTS'];
final _shotKey = GlobalKey();

Future<void> _loadFonts() async {
  Future<void> load(String family, List<String> files) async {
    final l = FontLoader(family);
    for (final f in files) {
      l.addFont(Future.value(ByteData.sublistView(File(f).readAsBytesSync())));
    }
    await l.load();
  }

  await load('Sora', ['Sora-500', 'Sora-600', 'Sora-700', 'Sora-800'].map((f) => 'assets/fonts/$f.ttf').toList());
  await load(
    'Figtree',
    ['Figtree-400', 'Figtree-500', 'Figtree-600', 'Figtree-700'].map((f) => 'assets/fonts/$f.ttf').toList(),
  );
  await load('IBMPlexMono', ['IBMPlexMono-500', 'IBMPlexMono-600'].map((f) => 'assets/fonts/$f.ttf').toList());
  final flutterRoot = Platform.environment['FLUTTER_ROOT'];
  final icons = File('$flutterRoot/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf');
  if (flutterRoot != null && icons.existsSync()) await load('MaterialIcons', [icons.path]);
}

void main() {
  tzdata.initializeTimeZones();
  quietDriftWarnings();
  final loc = tz.getLocation('Asia/Kolkata');
  // Sunday 15 Nov 2026, 4:10 PM IST: after Asr starts.
  final now = DateTime.fromMillisecondsSinceEpoch(
    tz.TZDateTime(loc, 2026, 11, 15, 16, 10).millisecondsSinceEpoch,
    isUtc: true,
  );
  DateTime ist(int d, int h, int m) =>
      DateTime.fromMillisecondsSinceEpoch(tz.TZDateTime(loc, 2026, 11, d, h, m).millisecondsSinceEpoch, isUtc: true);

  Future<AppDb> seeded() async {
    final db = openMemoryDb();
    final xp = XpRepo(db);
    final clock = DayClock(location: loc, now: () => now);
    const day = '2026-11-15';
    await db.batch((b) {
      b.insert(db.settings, SettingsCompanion.insert(key: 'onboarded', value: 'true'));
      b.insert(
        db.sleepSessions,
        SleepSessionsCompanion.insert(sleptAtUtc: ist(15, 5, 40), wokeAtUtc: Value(ist(15, 12, 10))),
      );
    });
    await xp.set('2026-11-14', 'seed', 640);
    await xp.set('2026-11-13', 'seed', 120);
    await xp.set(day, 'sleep:morning', 15);
    final tasks = TasksRepo(db, xp);
    await tasks.add(
      title: 'Send 10 outreach emails',
      dueDay: day,
      profileId: 1,
      priority: 1,
      dueAtUtc: ist(15, 18, 30),
    );
    await tasks.add(title: 'Retainer report for ToT', dueDay: day, profileId: 2);
    final done = await tasks.add(title: 'Revise DBMS unit 3', dueDay: day, profileId: 3);
    final t = await (db.select(db.tasks)..where((x) => x.id.equals(done))).getSingle();
    await tasks.toggle(t, clock);
    await WaterRepo(db, xp).change(day, 5, 8);
    final habits = HabitsRepo(db, xp);
    await habits.toggle(1, day);
    await habits.toggle(1, '2026-11-14');
    await habits.toggle(1, '2026-11-13');
    final pd = PrayerCalculator(const PrayerConfig()).forDate(day);
    final salah = SalahRepo(db, xp);
    await salah.toggle(
      pd,
      Prayer.fajr,
      DayClock(location: loc, now: () => pd.start(Prayer.fajr).add(const Duration(minutes: 10))),
    );
    await salah.toggle(
      pd,
      Prayer.dhuhr,
      DayClock(location: loc, now: () => pd.start(Prayer.dhuhr).add(const Duration(minutes: 20))),
    );
    await MoodRepo(db, xp).set(day, 4);
    return db;
  }

  Future<void> pumpApp(WidgetTester tester, AppDb db, String location) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [dbProvider.overrideWithValue(db), nowFnProvider.overrideWithValue(() => now)],
        child: RepaintBoundary(
          key: _shotKey,
          child: NizamApp(initialLocation: location, enablePlatform: false),
        ),
      ),
    );
    for (var i = 0; i < 10; i++) {
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 30)));
      await tester.pump(const Duration(milliseconds: 100));
    }
    await tester.pump(const Duration(seconds: 2));
  }

  Future<void> shot(WidgetTester tester, String name) async {
    if (shotsDir == null) return;
    final boundary = tester.renderObject<RenderRepaintBoundary>(find.byKey(_shotKey));
    final bytes = await tester.runAsync(() async {
      final img = await boundary.toImage(pixelRatio: 2);
      final data = await img.toByteData(format: ui.ImageByteFormat.png);
      return data!.buffer.asUint8List();
    });
    File('$shotsDir/$name.png').writeAsBytesSync(bytes!);
  }

  Future<void> run(WidgetTester tester, String loc, String name, {double height = 915}) async {
    if (shotsDir != null) await tester.runAsync(_loadFonts);
    tester.view.physicalSize = Size(412 * 2.0, height * 2.0);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.reset);
    final db = await tester.runAsync(seeded);
    await pumpApp(tester, db!, loc);
    await shot(tester, name);
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 1));
    await tester.runAsync(db.close);
  }

  testWidgets('Today renders all four cards with seeded data', (tester) async {
    await run(tester, '/today', 'today', height: shotsDir == null ? 915 : 2050);
  });

  testWidgets('Today content checks', (tester) async {
    tester.view.physicalSize = const Size(412 * 2.0, 3000 * 2.0);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.reset);
    final db = await tester.runAsync(seeded);
    await pumpApp(tester, db!, '/today');
    expect(find.text('Habeeb'), findsWidgets);
    expect(find.text('Focus'), findsOneWidget);
    expect(find.text('Tasks'), findsOneWidget);
    expect(find.text('Body & soul'), findsOneWidget);
    expect(find.text('! Send 10 outreach emails', findRichText: true), findsOneWidget);
    expect(find.text('Good Night'), findsOneWidget);
    expect(find.text('5/8'), findsOneWidget);
    expect(find.text('Next prayer'.toUpperCase()), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 1));
    await tester.runAsync(db.close);
  });

  testWidgets('Rewards renders', (tester) async {
    await run(tester, '/rewards', 'rewards', height: shotsDir == null ? 915 : 1500);
    expect(find.text('Rewards shop'), findsNothing); // tree disposed after run
  });

  testWidgets('Me renders', (tester) async {
    await run(tester, '/me', 'me', height: shotsDir == null ? 915 : 2600);
  });

  testWidgets('Phone setup renders', (tester) async {
    await run(tester, '/welcome', 'setup', height: shotsDir == null ? 915 : 1400);
  });
}
