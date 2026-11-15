import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/db/app_db.dart';
import '../../../core/notifications/reminder_sync.dart';
import '../../../core/providers.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/theme/widgets.dart';
import '../../../core/time/day_clock.dart';
import '../../../core/time/format.dart';
import '../../profiles/data/profiles_repo.dart';
import '../data/tasks_repo.dart';
import '../domain/recurrence.dart';

/// Tasks card on Today: profile filter, quick add, list.
class TasksCard extends ConsumerStatefulWidget {
  const TasksCard({super.key});

  @override
  ConsumerState<TasksCard> createState() => _TasksCardState();
}

class _TasksCardState extends ConsumerState<TasksCard> {
  final _c = TextEditingController();
  final _focus = FocusNode();

  @override
  void dispose() {
    _c.dispose();
    _focus.dispose();
    super.dispose();
  }

  Future<void> _add() async {
    final t = _c.text.trim();
    if (t.isEmpty) return;
    final today = ref.read(todayProvider);
    await ref.read(tasksRepoProvider).add(title: t, dueDay: today, profileId: ref.read(profileFilterProvider));
    _c.clear();
    _focus.requestFocus();
    Haptic.light();
  }

  @override
  Widget build(BuildContext context) {
    final all = ref.watch(todayTasksProvider).value ?? const <Task>[];
    final list = ref.watch(filteredTodayTasksProvider);
    final profiles = ref.watch(profilesProvider).value ?? const <Profile>[];
    final filter = ref.watch(profileFilterProvider);
    final doneToday = all.where((t) => t.doneAtUtc != null).length;

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CardHeader(
            'Tasks',
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('$doneToday done', style: N.num(12, color: N.muted)),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: () => context.push('/tasks'),
                  child: const Text(
                    'All tasks',
                    style: TextStyle(color: N.gold, fontWeight: FontWeight.w600, fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
          ProfileFilterChips(profiles: profiles, selected: filter),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _c,
                  focusNode: _focus,
                  maxLength: 200,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _add(),
                  decoration: const InputDecoration(hintText: 'Add a task, press Enter', counterText: ''),
                ),
              ),
              const SizedBox(width: 8),
              IconBtn(
                Icons.tune_rounded,
                label: 'Add with details',
                onTap: () => showAddTaskSheet(context, title: _c.text),
              ),
            ],
          ),
          const SizedBox(height: 6),
          if (list.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: EmptyNote(
                filter == null ? 'No open tasks. Add your top 3 for today.' : 'Nothing here for this profile.',
              ),
            )
          else
            ...list.map((t) => TaskTile(task: t, profiles: profiles)),
        ],
      ),
    );
  }
}

class ProfileFilterChips extends ConsumerWidget {
  const ProfileFilterChips({super.key, required this.profiles, required this.selected});
  final List<Profile> profiles;
  final int? selected;

  @override
  Widget build(BuildContext context, WidgetRef ref) => SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    child: Row(
      children: [
        NChip('All', on: selected == null, onTap: () => ref.read(profileFilterProvider.notifier).select(null)),
        for (final p in profiles) ...[
          const SizedBox(width: 6),
          NChip(p.name, on: selected == p.id, onTap: () => ref.read(profileFilterProvider.notifier).select(p.id)),
        ],
      ],
    ),
  );
}

class TaskTile extends ConsumerWidget {
  const TaskTile({super.key, required this.task, required this.profiles, this.showDay = false});
  final Task task;
  final List<Profile> profiles;
  final bool showDay;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final clock = ref.watch(clockProvider);
    final today = ref.watch(todayProvider);
    final done = task.doneAtUtc != null;
    final prof = profiles.where((p) => p.id == task.profileId).firstOrNull;
    final overdue = !done && task.dueDay != null && task.dueDay!.compareTo(today) < 0;
    final rule = Recurrence.fromRRule(task.rrule);
    final meta = <String>[
      if (showDay && task.dueDay != null) relDay(task.dueDay!, today),
      if (overdue && !showDay) 'Overdue · ${relDay(task.dueDay!, today)}',
      if (task.dueAtUtc != null) fmtTime(clock, task.dueAtUtc!),
      if (rule.repeats) '↻ ${rule.label}',
      if (task.tags.isNotEmpty) task.tags.split(',').map((e) => '#${e.trim()}').join(' '),
    ];

    return Dismissible(
      key: ValueKey('task-${task.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        color: N.badSoft,
        child: const Icon(Icons.delete_outline_rounded, color: N.bad),
      ),
      onDismissed: (_) async {
        await ref.read(tasksRepoProvider).delete(task);
        ref.read(reminderSyncProvider).schedule();
      },
      child: InkWell(
        onLongPress: () => showAddTaskSheet(context, editing: task),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: const BoxDecoration(
            border: Border(top: BorderSide(color: N.line)),
          ),
          child: Row(
            children: [
              _Check(
                on: done,
                onTap: () async {
                  await ref.read(tasksRepoProvider).toggle(task, clock);
                  ref.read(reminderSyncProvider).schedule();
                },
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text.rich(
                      TextSpan(
                        children: [
                          if (task.priority > 0)
                            const TextSpan(
                              text: '! ',
                              style: TextStyle(color: N.gold, fontWeight: FontWeight.w800),
                            ),
                          TextSpan(text: task.title),
                        ],
                      ),
                      style: TextStyle(
                        fontSize: 15,
                        color: done ? N.muted : N.ink,
                        decoration: done ? TextDecoration.lineThrough : null,
                        decorationColor: N.muted,
                      ),
                    ),
                    if (meta.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          meta.join(' · '),
                          style: N.small.copyWith(fontSize: 12, color: overdue ? N.warn : N.muted),
                        ),
                      ),
                  ],
                ),
              ),
              if (prof != null && prof.name != 'Personal') ...[
                const SizedBox(width: 6),
                Pill(
                  prof.name.length > 10 ? prof.name.split(' ').map((w) => w[0]).join() : prof.name,
                  color: Color(prof.color),
                ),
              ],
              IconButton(
                tooltip: 'Priority',
                visualDensity: VisualDensity.compact,
                onPressed: () {
                  Haptic.tap();
                  ref.read(tasksRepoProvider).togglePriority(task);
                },
                icon: Icon(
                  Icons.flag_rounded,
                  size: 18,
                  color: task.priority > 0 ? N.gold : N.muted.withValues(alpha: .5),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Check extends StatelessWidget {
  const _Check({required this.on, required this.onTap});
  final bool on;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
    checked: on,
    button: true,
    label: 'Complete task',
    child: GestureDetector(
      onTap: () {
        Haptic.light();
        onTap();
      },
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: 26,
          height: 26,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            gradient: on ? N.goldGradient : null,
            border: on ? null : Border.all(color: N.muted.withValues(alpha: .5), width: 2),
          ),
          child: on ? const Icon(Icons.check_rounded, size: 18, color: N.goldInk) : null,
        ),
      ),
    ),
  );
}

Future<void> showAddTaskSheet(BuildContext context, {String title = '', Task? editing}) =>
    showNSheet(context, (_) => AddTaskSheet(initialTitle: title, editing: editing));

class AddTaskSheet extends ConsumerStatefulWidget {
  const AddTaskSheet({super.key, this.initialTitle = '', this.editing});
  final String initialTitle;
  final Task? editing;

  @override
  ConsumerState<AddTaskSheet> createState() => _AddTaskSheetState();
}

class _AddTaskSheetState extends ConsumerState<AddTaskSheet> {
  late final TextEditingController _title;
  late final TextEditingController _tags;
  String? _day;
  TimeOfDay? _time;
  int _priority = 0;
  int? _profile;
  Recurrence _repeat = Recurrence.none;

  @override
  void initState() {
    super.initState();
    final e = widget.editing;
    final clock = ref.read(clockProvider);
    _title = TextEditingController(text: e?.title ?? widget.initialTitle);
    _tags = TextEditingController(text: e?.tags ?? '');
    _day = e?.dueDay ?? (e == null ? ref.read(todayProvider) : null);
    if (e?.dueAtUtc != null) {
      final l = clock.toLocal(e!.dueAtUtc!);
      _time = TimeOfDay(hour: l.hour, minute: l.minute);
    }
    _priority = e?.priority ?? 0;
    _profile = e?.profileId ?? ref.read(profileFilterProvider);
    _repeat = Recurrence.fromRRule(e?.rrule);
  }

  @override
  void dispose() {
    _title.dispose();
    _tags.dispose();
    super.dispose();
  }

  DateTime? _dueAt(DayClock clock) {
    if (_time == null || _day == null) return null;
    // A time before the rollover hour (e.g. 2 AM) on logical day D is the next calendar date.
    final cal = _time!.hour < clock.rolloverHour ? DayKey.add(_day!, 1) : _day!;
    return clock.localToUtc(cal, _time!.hour, _time!.minute);
  }

  Future<void> _save() async {
    final t = _title.text.trim();
    if (t.isEmpty) return;
    final clock = ref.read(clockProvider);
    final repo = ref.read(tasksRepoProvider);
    var day = _day;
    if (_repeat.repeats && day == null) {
      final today = ref.read(todayProvider);
      day = _repeat.occursOn(today) ? today : _repeat.nextAfter(today);
      _day = day;
    }
    final tags = _tags.text.split(',').map((e) => e.trim().replaceAll('#', '')).where((e) => e.isNotEmpty).join(',');
    final e = widget.editing;
    if (e == null) {
      await repo.add(
        title: t,
        dueDay: day,
        dueAtUtc: _dueAt(clock),
        priority: _priority,
        tags: tags,
        profileId: _profile,
        repeat: _repeat,
      );
    } else {
      await repo.update(
        e.copyWith(
          title: t,
          dueDay: Value(day),
          dueAtUtc: Value(_dueAt(clock)),
          priority: _priority,
          tags: tags,
          profileId: Value(_profile),
          rrule: Value(_repeat.toRRule()),
        ),
      );
    }
    ref.read(reminderSyncProvider).schedule();
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final today = ref.watch(todayProvider);
    final profiles = ref.watch(profilesProvider).value ?? const <Profile>[];
    final tomorrow = DayKey.add(today, 1);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(widget.editing == null ? 'New task' : 'Edit task', style: N.h2.copyWith(fontSize: 18)),
        const SizedBox(height: 14),
        TextField(
          controller: _title,
          autofocus: widget.editing == null,
          maxLength: 200,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _save(),
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
          decoration: const InputDecoration(hintText: 'What needs doing?', counterText: ''),
        ),
        const SizedBox(height: 14),
        const Eyebrow('When'),
        const SizedBox(height: 8),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            NChip('Today', on: _day == today, onTap: () => setState(() => _day = today)),
            NChip('Tomorrow', on: _day == tomorrow, onTap: () => setState(() => _day = tomorrow)),
            NChip(
              _day != null && _day != today && _day != tomorrow ? fmtDayKey(_day!) : 'Pick date',
              on: _day != null && _day != today && _day != tomorrow,
              onTap: () async {
                final now = DayKey.toDate(today);
                final d = await showDatePicker(
                  context: context,
                  initialDate: _day == null ? now : DayKey.toDate(_day!),
                  firstDate: now.subtract(const Duration(days: 365)),
                  lastDate: now.add(const Duration(days: 365 * 3)),
                );
                if (d != null) setState(() => _day = DayKey.fromDate(d));
              },
            ),
            NChip(
              'Someday',
              on: _day == null,
              onTap: () => setState(() {
                _day = null;
                _time = null;
              }),
            ),
            NChip(
              _time == null ? '+ Time' : fmtTimeOfDay(_time!),
              on: _time != null,
              onTap: () async {
                final t = await showTimePicker(context: context, initialTime: _time ?? TimeOfDay.now());
                setState(() {
                  _time = t;
                  _day ??= today;
                });
              },
            ),
          ],
        ),
        const SizedBox(height: 14),
        const Eyebrow('Repeat'),
        const SizedBox(height: 8),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            for (final f in RepeatFreq.values)
              NChip(
                switch (f) {
                  RepeatFreq.none => 'Once',
                  RepeatFreq.daily => 'Daily',
                  RepeatFreq.weekdays => 'Weekdays',
                  RepeatFreq.weekly => 'Weekly',
                },
                on: _repeat.freq == f,
                onTap: () => setState(
                  () => _repeat = Recurrence(
                    f,
                    f == RepeatFreq.weekly
                        ? (_repeat.days.isEmpty ? {DayKey.weekday(_day ?? today)} : _repeat.days)
                        : const {},
                  ),
                ),
              ),
          ],
        ),
        if (_repeat.freq == RepeatFreq.weekly) ...[
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            children: [
              for (var d = 1; d <= 7; d++)
                NChip(
                  dowShort[d - 1].substring(0, 2),
                  on: _repeat.days.contains(d),
                  onTap: () {
                    final s = {..._repeat.days};
                    s.contains(d) ? s.remove(d) : s.add(d);
                    if (s.isNotEmpty) setState(() => _repeat = Recurrence(RepeatFreq.weekly, s));
                  },
                ),
            ],
          ),
        ],
        const SizedBox(height: 14),
        const Eyebrow('Work profile'),
        const SizedBox(height: 8),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            NChip('None', on: _profile == null, onTap: () => setState(() => _profile = null)),
            for (final p in profiles)
              NChip(p.name, on: _profile == p.id, color: Color(p.color), onTap: () => setState(() => _profile = p.id)),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _tags,
                decoration: const InputDecoration(hintText: 'Tags, comma separated'),
              ),
            ),
            const SizedBox(width: 8),
            NChip(
              _priority > 0 ? '! High' : 'Normal',
              on: _priority > 0,
              onTap: () => setState(() => _priority = _priority > 0 ? 0 : 1),
            ),
          ],
        ),
        const SizedBox(height: 18),
        NButton(widget.editing == null ? 'Add task' : 'Save', expand: true, onTap: _save),
      ],
    );
  }
}

String fmtTimeOfDay(TimeOfDay t) {
  final h = t.hour % 12 == 0 ? 12 : t.hour % 12;
  return '$h:${t.minute.toString().padLeft(2, '0')} ${t.hour >= 12 ? 'PM' : 'AM'}';
}
