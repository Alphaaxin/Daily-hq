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
import 'package:nizam/features/focus/data/focus_repo.dart';
import 'package:nizam/features/focus/domain/focus_logic.dart';
import 'package:nizam/features/gamification/data/xp_repo.dart';
import 'package:nizam/features/money/data/money_repo.dart';
import 'package:nizam/features/money/domain/money_parser.dart';
import 'package:nizam/features/money/ui/quick_log_sheet.dart';
import 'package:nizam/features/targets/data/targets_repo.dart';
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

    // Phase 2 data.
    final money = MoneyRepo(db, xp);
    final cats = await money.categories();
    int cat(String n, String type) => cats.firstWhere((c) => c.name == n && c.type == type).id;
    await money.setBudget(cat('Food', 'spent'), 400000);
    final earlier = DayClock(location: loc, now: () => ist(3, 13, 0));
    await money.add(
      paise: 4000000,
      type: MoneyType.received,
      categoryId: cat('Retainer', 'received'),
      note: 'ToT retainer',
      clock: earlier,
      profileId: 2,
    );
    await money.add(
      paise: 500000,
      type: MoneyType.invested,
      categoryId: cat('SIP', 'invested'),
      note: 'Index fund SIP',
      clock: earlier,
    );
    await money.add(
      paise: 1200000,
      type: MoneyType.spent,
      categoryId: cat('Bills', 'spent'),
      note: 'Rent share',
      clock: earlier,
    );
    for (final (d, p, n) in [(5, 32000, 'Biryani'), (8, 65000, 'Team lunch'), (11, 24000, 'Irani chai')]) {
      await money.add(
        paise: p,
        type: MoneyType.spent,
        categoryId: cat('Food', 'spent'),
        note: n,
        clock: DayClock(location: loc, now: () => ist(d, 14, 0)),
      );
    }
    await money.add(
      paise: 15000,
      type: MoneyType.spent,
      categoryId: cat('Travel', 'spent'),
      note: 'Rapido',
      clock: clock,
    );
    await money.add(
      paise: 25000,
      type: MoneyType.spent,
      categoryId: cat('Food', 'spent'),
      note: 'chai & snacks',
      clock: clock,
    );
    final focus = FocusRepo(db, xp);
    await focus.addIdea('AI cold-email writer for Hyderabad SMBs');
    await focus.addIdea('Voice-to-MoM meeting bot');
    await focus.addManual(day: day, minutes: 95, profileId: 2, note: 'ToT candidate shortlist', nowUtc: now);
    await focus.addManual(day: '2026-11-14', minutes: 120, profileId: 1, note: 'Zillvox lead research', nowUtc: now);
    final b = DayClock(location: loc, now: () => ist(15, 13, 0));
    await focus.start(b, FocusKind.build, ideaId: 1);
    await focus.stop(
      DayClock(location: loc, now: () => ist(15, 13, 40)),
      (await focus.running())!,
      note: 'Prompt chain v1',
    );
    final targets = TargetsRepo(db, xp);
    final ts = await targets.watch().first;
    await targets.bump(ts[0], day, 12);
    await targets.bump(ts[1], day, 3);
    await targets.bump(ts[2], day, 4);
    await db
        .into(db.calendarEvents)
        .insert(
          CalendarEventsCompanion.insert(
            calendarId: 'primary',
            eventId: 'e1',
            title: const Value('Zillvox weekly sync'),
            startUtc: Value(ist(15, 18, 0)),
            endUtc: Value(ist(15, 18, 45)),
          ),
        );
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

  testWidgets('Money renders', (tester) async {
    await run(tester, '/money', 'money', height: shotsDir == null ? 915 : 2300);
  });

  testWidgets('Focus renders', (tester) async {
    await run(tester, '/focus', 'focus', height: shotsDir == null ? 915 : 1500);
  });

  testWidgets('Time log renders', (tester) async {
    await run(tester, '/time', 'time', height: shotsDir == null ? 915 : 1300);
  });

  testWidgets('Calendar renders', (tester) async {
    await run(tester, '/calendar', 'calendar', height: shotsDir == null ? 915 : 1000);
  });

  testWidgets('Google screen renders', (tester) async {
    await run(tester, '/google', 'google', height: shotsDir == null ? 915 : 1000);
  });

  testWidgets('Money settings renders', (tester) async {
    await run(tester, '/money-settings', 'money_settings', height: shotsDir == null ? 915 : 2400);
  });

  testWidgets('Quick Log parses natural input and saves', (tester) async {
    if (shotsDir != null) await tester.runAsync(_loadFonts);
    tester.view.physicalSize = const Size(412 * 2.0, 915 * 2.0);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.reset);
    final db = await tester.runAsync(seeded);
    await pumpApp(tester, db!, '/money');
    await tester.tap(find.text('Log money').last);
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.byType(QuickLogForm), findsOneWidget);
    await tester.enterText(find.byType(TextField).at(1), '5000 SIP');
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('SIP'), findsWidgets);
    await shot(tester, 'quicklog');
    await tester.tap(find.text('Save'));
    for (var i = 0; i < 6; i++) {
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 30)));
      await tester.pump(const Duration(milliseconds: 200));
    }
    final entries = await tester.runAsync(() => db.select(db.moneyEntries).get());
    final sip = entries!.where((e) => e.note == 'SIP' && e.type == 'invested');
    expect(sip.single.amountPaise, 500000);
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 1));
    await tester.runAsync(db.close);
  });

  for (final (route, name, h) in [
    ('/notes', 'notes', 1400.0),
    ('/leads', 'leads', 1400.0),
    ('/people', 'people', 1400.0),
    ('/mail', 'mail', 1400.0),
    ('/review', 'review', 1900.0),
    ('/report', 'report', 2600.0),
    ('/pixels', 'pixels', 1500.0),
    ('/learning', 'learning', 1000.0),
    ('/nudges', 'nudges', 1800.0),
    ('/ai', 'ai', 1000.0),
  ]) {
    testWidgets('$route renders', (tester) async {
      await run(tester, route, name, height: shotsDir == null ? 915 : h);
    });
  }
}
