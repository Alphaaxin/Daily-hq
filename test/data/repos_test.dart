import 'package:flutter_test/flutter_test.dart';
import 'package:nizam/core/db/app_db.dart';
import 'package:nizam/core/db/open_db.dart';
import 'package:nizam/core/settings/app_settings.dart';
import 'package:nizam/core/time/day_clock.dart';
import 'package:nizam/features/gamification/data/rewards_repo.dart';
import 'package:nizam/features/gamification/data/xp_repo.dart';
import 'package:nizam/features/habits/data/habits_repo.dart';
import 'package:nizam/features/salah/data/salah_repo.dart';
import 'package:nizam/features/salah/domain/prayer_times.dart';
import 'package:nizam/features/sleep/data/sleep_repo.dart';
import 'package:nizam/features/sleep/domain/sleep_logic.dart';
import 'package:nizam/features/tasks/data/tasks_repo.dart';
import 'package:nizam/features/tasks/domain/recurrence.dart';
import 'package:nizam/features/water/data/water_repo.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

void main() {
  tzdata.initializeTimeZones();
  quietDriftWarnings();
  final loc = tz.getLocation('Asia/Kolkata');
  DateTime ist(int d, int h, int m) =>
      DateTime.fromMillisecondsSinceEpoch(tz.TZDateTime(loc, 2026, 11, d, h, m).millisecondsSinceEpoch, isUtc: true);

  late AppDb db;
  late XpRepo xp;
  var now = ist(15, 14, 0);
  DayClock clock() => DayClock(location: loc, now: () => now);

  setUp(() {
    db = openMemoryDb();
    xp = XpRepo(db);
    now = ist(15, 14, 0);
  });
  tearDown(() => db.close());

  test('seeds profiles, habits and rewards on first open', () async {
    expect((await db.select(db.profiles).get()).map((p) => p.name), ['Zillvox', 'Triumphs of Talent', 'Personal']);
    expect(await db.select(db.habits).get(), hasLength(3));
    expect(await db.select(db.rewards).get(), hasLength(3));
  });

  test('settings round-trip and module toggles', () async {
    final r = SettingsRepo(db);
    expect((await r.load()).rolloverHour, 6);
    await r.set('rolloverHour', 7);
    await r.set('sleepTargetHours', 7.5);
    var s = await r.load();
    expect(s.rolloverHour, 7);
    expect(s.sleepTargetHours, 7.5);
    await r.setModule(s, Module.water, false);
    s = await r.load();
    expect(s.on(Module.water), isFalse);
    expect(s.on(Module.tasks), isTrue);
  });

  group('xp ledger', () {
    test('idempotent per day + source, removable, levels up', () async {
      final events = <XpEvent>[];
      final sub = xp.events.listen(events.add);
      expect(await xp.set('2026-11-15', 'a', 60), 60);
      expect(await xp.set('2026-11-15', 'a', 60), 0);
      expect(await xp.set('2026-11-15', 'b', 50), 50); // 110 → level 2
      expect(await xp.watchTotal().first, 110);
      expect(await xp.set('2026-11-15', 'a', 0), -60);
      expect(await xp.watchTotal().first, 50);
      await Future<void>.delayed(Duration.zero);
      expect(events.where((e) => e.levelUp != null).single.levelUp!.level, 2);
      await sub.cancel();
    });

    test('active days only count days with XP', () async {
      await xp.set('2026-11-14', 'a', 5);
      await xp.set('2026-11-15', 'a', 5);
      await xp.set('2026-11-15', 'a', 0);
      expect(await xp.watchActiveDays().first, {'2026-11-14'});
    });

    test('redeeming spends balance, not total', () async {
      await xp.set('d', 'big', 600);
      final rewards = RewardsRepo(db);
      final r = (await db.select(db.rewards).get()).firstWhere((x) => x.cost == 500);
      expect(await rewards.redeem(r, 600), isTrue);
      expect(await xp.watchSpent().first, 500);
      expect(await xp.watchTotal().first, 600);
      expect(await rewards.redeem(r, 100), isFalse);
    });
  });

  group('tasks', () {
    test('completing awards XP and undo removes it', () async {
      final repo = TasksRepo(db, xp);
      final id = await repo.add(title: 'Call Rahul', dueDay: '2026-11-15');
      var t = (await repo.watchToday('2026-11-15').first).single;
      await repo.toggle(t, clock());
      expect(await xp.watchDay('2026-11-15').first, 10);
      t = (await repo.watchToday('2026-11-15').first).single;
      expect(t.doneDay, '2026-11-15');
      await repo.toggle(t, clock());
      expect(await xp.watchDay('2026-11-15').first, 0);
      expect((await repo.watchToday('2026-11-15').first).single.id, id);
    });

    test('recurring task spawns the next occurrence; undo removes it', () async {
      final repo = TasksRepo(db, xp);
      await repo.add(
        title: 'Post on LinkedIn',
        dueDay: '2026-11-15', // Sunday
        dueAtUtc: ist(15, 18, 0),
        repeat: const Recurrence(RepeatFreq.weekdays),
      );
      final t = (await repo.watchToday('2026-11-15').first).single;
      await repo.toggle(t, clock());
      final up = await repo.watchUpcoming('2026-11-15').first;
      expect(up.single.dueDay, '2026-11-16');
      expect(up.single.dueAtUtc!.toUtc(), ist(16, 18, 0));
      final done = (await repo.watchToday('2026-11-15').first).single;
      await repo.toggle(done, clock());
      expect(await repo.watchUpcoming('2026-11-15').first, isEmpty);
    });

    test('roll unfinished to tomorrow keeps the time of day', () async {
      final repo = TasksRepo(db, xp);
      await repo.add(title: 'A', dueDay: '2026-11-14', dueAtUtc: ist(14, 20, 0));
      await repo.add(title: 'B', dueDay: '2026-11-15');
      await repo.add(title: 'Someday');
      expect(await repo.rollToTomorrow(clock()), 2);
      final up = await repo.watchUpcoming('2026-11-15').first;
      expect(up.map((t) => t.dueDay).toSet(), {'2026-11-16'});
      expect(up.firstWhere((t) => t.title == 'A').dueAtUtc!.toUtc(), ist(16, 20, 0));
      expect((await repo.watchToday('2026-11-15').first).single.title, 'Someday');
    });
  });

  test('habits: all-done bonus is awarded and withdrawn', () async {
    final repo = HabitsRepo(db, xp);
    final hs = await db.select(db.habits).get();
    expect(await repo.toggle(hs[0].id, 'd'), isFalse);
    expect(await repo.toggle(hs[1].id, 'd'), isFalse);
    expect(await repo.toggle(hs[2].id, 'd'), isTrue);
    expect(await xp.watchDay('d').first, 5 * 3 + 10);
    await repo.toggle(hs[2].id, 'd');
    expect(await xp.watchDay('d').first, 10);
  });

  test('water: goal XP when reached, removed when undone', () async {
    final repo = WaterRepo(db, xp);
    expect(await repo.change('d', 7, 8), isFalse);
    expect(await repo.change('d', 1, 8), isTrue);
    expect(await xp.watchDay('d').first, 15);
    await repo.change('d', -1, 8);
    expect(await xp.watchDay('d').first, 0);
    expect(await repo.setCount('d', 8, 8), isTrue);
    expect((await repo.watchDay('d').first).length, 8);
  });

  test('sleep: good night / good morning credits the wake day', () async {
    final repo = SleepRepo(db, xp);
    now = ist(15, 5, 30);
    await repo.goodNight(clock());
    expect((await repo.latest())!.asleep, isTrue);
    now = ist(15, 12, 45);
    final s = await repo.goodMorning(clock(), 7);
    expect(s!.span.duration, const Duration(hours: 7, minutes: 15));
    expect(await xp.watchDay('2026-11-15').first, 15);
    // a manual log for an earlier night
    await repo.logManual(clock(), SleepSpan(sleptAt: ist(14, 4, 0), wokeAt: ist(14, 9, 0)), 7);
    expect(await xp.watchDay('2026-11-14').first, 10);
  });

  test('salah: on time vs late, toggling clears', () async {
    final repo = SalahRepo(db, xp);
    final day = PrayerCalculator(const PrayerConfig()).forDate('2026-11-15');
    now = day.start(Prayer.dhuhr).add(const Duration(minutes: 5));
    expect(await repo.toggle(day, Prayer.dhuhr, clock()), SalahStatus.onTime);
    now = day.start(Prayer.maghrib).add(const Duration(minutes: 5));
    expect(await repo.toggle(day, Prayer.asr, clock()), SalahStatus.late);
    expect(await xp.watchDay('2026-11-15').first, 5 + 3);
    expect(await repo.toggle(day, Prayer.asr, clock()), isNull);
    expect((await repo.watchDate('2026-11-15').first).keys, [Prayer.dhuhr]);
  });
}
