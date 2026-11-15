import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/db/app_db.dart';
import '../../../core/providers.dart';
import '../../../core/time/day_clock.dart';
import '../../gamification/data/xp_repo.dart';
import '../../gamification/domain/xp_rules.dart';
import '../../profiles/data/profiles_repo.dart';
import '../domain/recurrence.dart';

class TasksRepo {
  TasksRepo(this.db, this.xp);
  final AppDb db;
  final XpRepo xp;

  /// Open tasks due today or earlier (or undated), plus those finished today.
  Stream<List<Task>> watchToday(String today) =>
      (db.select(db.tasks)..where(
            (t) =>
                (t.doneAtUtc.isNull() & (t.dueDay.isNull() | t.dueDay.isSmallerOrEqualValue(today))) |
                t.doneDay.equals(today),
          ))
          .watch()
          .map(_sort);

  Stream<List<Task>> watchUpcoming(String today) =>
      (db.select(db.tasks)
            ..where((t) => t.doneAtUtc.isNull() & t.dueDay.isBiggerThanValue(today))
            ..orderBy([(t) => OrderingTerm.asc(t.dueDay), (t) => OrderingTerm.asc(t.dueAtUtc)]))
          .watch();

  Stream<List<Task>> watchDone({int limit = 50}) =>
      (db.select(db.tasks)
            ..where((t) => t.doneAtUtc.isNotNull())
            ..orderBy([(t) => OrderingTerm.desc(t.doneAtUtc)])
            ..limit(limit))
          .watch();

  Future<List<Task>> openWithTime() =>
      (db.select(db.tasks)..where((t) => t.doneAtUtc.isNull() & t.dueAtUtc.isNotNull())).get();

  static List<Task> _sort(List<Task> l) => l
    ..sort((a, b) {
      final d = (a.doneAtUtc != null ? 1 : 0) - (b.doneAtUtc != null ? 1 : 0);
      if (d != 0) return d;
      final p = b.priority - a.priority;
      if (p != 0) return p;
      final ad = a.dueAtUtc, bd = b.dueAtUtc;
      if (ad != null && bd != null) return ad.compareTo(bd);
      if (ad != null) return -1;
      if (bd != null) return 1;
      return a.createdAtUtc.compareTo(b.createdAtUtc);
    });

  Future<int> add({
    required String title,
    String? dueDay,
    DateTime? dueAtUtc,
    int priority = 0,
    String tags = '',
    int? profileId,
    Recurrence repeat = Recurrence.none,
  }) => db
      .into(db.tasks)
      .insert(
        TasksCompanion.insert(
          title: title.trim(),
          dueDay: Value(dueDay),
          dueAtUtc: Value(dueAtUtc),
          priority: Value(priority),
          tags: Value(tags),
          profileId: Value(profileId),
          rrule: Value(repeat.toRRule()),
          createdAtUtc: DateTime.now().toUtc(),
        ),
      );

  Future<void> update(Task t) => db.update(db.tasks).replace(t);

  Future<void> delete(Task t) async {
    if (t.doneDay != null) await xp.set(t.doneDay!, Xp.taskKey(t.id), 0);
    await (db.delete(db.tasks)..where((x) => x.id.equals(t.id))).go();
  }

  Future<void> togglePriority(Task t) => (db.update(
    db.tasks,
  )..where((x) => x.id.equals(t.id))).write(TasksCompanion(priority: Value(t.priority > 0 ? 0 : 1)));

  /// Completes or re-opens a task. Completing a recurring task spawns its next
  /// occurrence; re-opening it removes that spawned copy if still untouched.
  Future<void> toggle(Task t, DayClock clock) async {
    if (t.doneAtUtc == null) {
      final today = clock.today();
      int? nextId;
      final rule = Recurrence.fromRRule(t.rrule);
      if (rule.repeats) {
        final from = (t.dueDay != null && t.dueDay!.compareTo(today) > 0) ? t.dueDay! : today;
        final next = rule.nextAfter(from);
        if (next != null) {
          DateTime? nextAt;
          if (t.dueAtUtc != null) {
            final l = clock.toLocal(t.dueAtUtc!);
            nextAt = clock.localToUtc(next, l.hour, l.minute);
          }
          nextId = await db
              .into(db.tasks)
              .insert(
                TasksCompanion.insert(
                  title: t.title,
                  notes: Value(t.notes),
                  dueDay: Value(next),
                  dueAtUtc: Value(nextAt),
                  priority: Value(t.priority),
                  tags: Value(t.tags),
                  profileId: Value(t.profileId),
                  rrule: Value(t.rrule),
                  createdAtUtc: DateTime.now().toUtc(),
                ),
              );
        }
      }
      await (db.update(db.tasks)..where((x) => x.id.equals(t.id))).write(
        TasksCompanion(doneAtUtc: Value(clock.nowUtc()), doneDay: Value(today), nextId: Value(nextId)),
      );
      await xp.set(today, Xp.taskKey(t.id), Xp.task);
    } else {
      if (t.nextId != null) {
        await (db.delete(db.tasks)..where((x) => x.id.equals(t.nextId!) & x.doneAtUtc.isNull())).go();
      }
      if (t.doneDay != null) await xp.set(t.doneDay!, Xp.taskKey(t.id), 0);
      await (db.update(db.tasks)..where((x) => x.id.equals(t.id))).write(
        const TasksCompanion(doneAtUtc: Value(null), doneDay: Value(null), nextId: Value(null)),
      );
    }
  }

  /// Evening shutdown helper: move every open, dated task due today or
  /// earlier to tomorrow (keeping its time of day). Returns how many moved.
  Future<int> rollToTomorrow(DayClock clock) async {
    final today = clock.today();
    final tomorrow = DayKey.add(today, 1);
    final open = await (db.select(
      db.tasks,
    )..where((t) => t.doneAtUtc.isNull() & t.dueDay.isSmallerOrEqualValue(today))).get();
    await db.transaction(() async {
      for (final t in open) {
        DateTime? at;
        if (t.dueAtUtc != null) {
          final l = clock.toLocal(t.dueAtUtc!);
          at = clock.localToUtc(tomorrow, l.hour, l.minute);
        }
        await (db.update(
          db.tasks,
        )..where((x) => x.id.equals(t.id))).write(TasksCompanion(dueDay: Value(tomorrow), dueAtUtc: Value(at)));
      }
    });
    return open.length;
  }
}

final tasksRepoProvider = Provider((ref) => TasksRepo(ref.watch(dbProvider), ref.watch(xpRepoProvider)));

final todayTasksProvider = StreamProvider<List<Task>>(
  (ref) => ref.watch(tasksRepoProvider).watchToday(ref.watch(todayProvider)),
);

final upcomingTasksProvider = StreamProvider<List<Task>>(
  (ref) => ref.watch(tasksRepoProvider).watchUpcoming(ref.watch(todayProvider)),
);

final doneTasksProvider = StreamProvider<List<Task>>((ref) => ref.watch(tasksRepoProvider).watchDone());

/// Today's tasks after the work-profile filter.
final filteredTodayTasksProvider = Provider<List<Task>>((ref) {
  final f = ref.watch(profileFilterProvider);
  final l = ref.watch(todayTasksProvider).value ?? const [];
  return f == null ? l : l.where((t) => t.profileId == f).toList();
});
