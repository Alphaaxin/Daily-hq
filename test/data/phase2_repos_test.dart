import 'package:flutter_test/flutter_test.dart';
import 'package:nizam/core/db/app_db.dart';
import 'package:nizam/core/db/open_db.dart';
import 'package:nizam/core/time/day_clock.dart';
import 'package:nizam/features/focus/data/focus_repo.dart';
import 'package:nizam/features/focus/domain/focus_logic.dart';
import 'package:nizam/features/gamification/data/xp_repo.dart';
import 'package:nizam/features/money/data/money_repo.dart';
import 'package:nizam/features/money/domain/money_parser.dart';
import 'package:nizam/features/routines/data/routines_repo.dart';
import 'package:nizam/features/targets/data/targets_repo.dart';
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
  const day = '2026-11-15';

  setUp(() {
    db = openMemoryDb();
    xp = XpRepo(db);
    now = ist(15, 14, 0);
  });
  tearDown(() => db.close());

  group('money', () {
    test('add awards XP once a day and alerts on budget thresholds', () async {
      final repo = MoneyRepo(db, xp);
      final food = (await repo.categories()).firstWhere((c) => c.name == 'Food' && c.type == 'spent');
      await repo.setBudget(food.id, 100000); // ₹1,000
      var alerts = await repo.add(
        paise: 70000,
        type: MoneyType.spent,
        categoryId: food.id,
        note: 'biryani',
        clock: clock(),
      );
      expect(alerts, isEmpty);
      alerts = await repo.add(paise: 15000, type: MoneyType.spent, categoryId: food.id, clock: clock());
      expect(alerts.single.level, BudgetLevel.near);
      expect(alerts.single.message, '₹150 left for Food this month');
      alerts = await repo.add(paise: 1000, type: MoneyType.spent, categoryId: food.id, clock: clock());
      expect(alerts, isEmpty, reason: 'already near, no repeat alert');
      alerts = await repo.add(
        paise: 50000,
        type: MoneyType.spent,
        categoryId: food.id,
        clock: clock(),
        monthlyBudgetPaise: 120000,
      );
      expect(alerts.map((a) => a.level), [BudgetLevel.over, BudgetLevel.over]);
      expect(await xp.watchDay(day).first, 5);
      final month = await repo.watchMonth('2026-11').first;
      expect(month, hasLength(4));
      expect(month.map((e) => e.day).toSet(), {day});
    });

    test('deleting the last entry of a day removes the XP', () async {
      final repo = MoneyRepo(db, xp);
      final sip = (await repo.categories()).firstWhere((c) => c.name == 'SIP');
      await repo.add(paise: 500000, type: MoneyType.invested, categoryId: sip.id, clock: clock());
      final e = (await repo.watchMonth('2026-11').first).single;
      await repo.delete(e);
      expect(await xp.watchDay(day).first, 0);
    });
  });

  group('focus', () {
    test('build hour: pause/resume banks time, stop awards scaled XP', () async {
      final repo = FocusRepo(db, xp);
      await repo.start(clock(), FocusKind.build);
      now = now.add(const Duration(minutes: 20));
      await repo.pause(clock(), (await repo.running())!);
      now = now.add(const Duration(hours: 2)); // paused time doesn't count
      await repo.resume(clock(), (await repo.running())!);
      now = now.add(const Duration(minutes: 40));
      final done = await repo.stop(clock(), (await repo.running())!, note: 'Shipped the landing page');
      expect(done.seconds, 3600);
      expect(await repo.buildMinutes(day), 60);
      expect(await xp.watchDay(day).first, 50);
      expect(await repo.running(), isNull);
    });

    test('pomodoro XP only for a full block; starting another stops the first', () async {
      final repo = FocusRepo(db, xp);
      await repo.start(clock(), FocusKind.pomodoro);
      now = now.add(const Duration(minutes: 10));
      await repo.start(clock(), FocusKind.work, profileId: 2); // auto-stops the pomodoro (10 min)
      expect(await xp.watchDay(day).first, 0);
      now = now.add(const Duration(minutes: 90));
      await repo.stop(clock(), (await repo.running())!);
      final sessions = await repo.watchRange(day, day).first;
      expect(sessions.map((s) => s.seconds).toSet(), {600, 5400});
      expect(totalsByProfile(sessions.map((s) => s.log), day, day), {null: 600, 2: 5400});
    });
  });

  test('targets: +20 XP at the goal, removed if it drops below', () async {
    final repo = TargetsRepo(db, xp);
    final t = (await repo.watch().first).firstWhere((t) => t.name == 'Research AI tools'); // goal 3
    expect(await repo.bump(t, day, 2), isFalse);
    expect(await repo.bump(t, day, 1), isTrue);
    expect(await xp.watchDay(day).first, 20);
    await repo.bump(t, day, -1);
    expect(await xp.watchDay(day).first, 0);
    expect((await repo.watchDay(day).first)[t.id], 2);
  });

  test('morning routine: ×1.2 multiplier stays exact as XP changes', () async {
    final routines = RoutinesRepo(db, xp);
    await xp.set(day, 'task:1', 100);
    final items = await routines.watchItems(Routine.morning).first;
    for (final i in items.take(items.length - 1)) {
      expect(await routines.toggle(i, day), isFalse);
    }
    expect(await routines.toggle(items.last, day), isTrue);
    // 100 task + 10 morning routine = 110 → bonus 22
    expect(await xp.watchDay(day).first, 110 + 22);
    await xp.set(day, 'task:2', 50); // 160 → bonus 32
    expect(await xp.watchDay(day).first, 160 + 32);
    await xp.set(day, 'task:2', 50); // idempotent
    expect(await xp.watchDay(day).first, 192);
    await routines.toggle(items.first, day); // un-tick → multiplier and routine XP gone
    expect(await xp.watchDay(day).first, 150);
  });

  test('evening shutdown saves gratitude and XP once', () async {
    final routines = RoutinesRepo(db, xp);
    await routines.finishEvening(day, 'Closed the Zillvox deal');
    await routines.finishEvening(day, 'Closed the Zillvox deal');
    expect(await xp.watchDay(day).first, 10);
    expect(await routines.watchGratitude(day).first, 'Closed the Zillvox deal');
    expect(await routines.watchEveningDone(day).first, isTrue);
  });
}
