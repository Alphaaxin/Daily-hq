import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/db/app_db.dart';
import '../../../core/providers.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/theme/widgets.dart';
import '../../../core/time/day_clock.dart';
import '../../../core/time/format.dart';
import '../../tasks/data/tasks_repo.dart';
import '../../tasks/ui/task_widgets.dart';
import '../data/calendar_store.dart';
import '../data/calendar_sync.dart';
import '../data/google_jobs.dart';

enum CalView { day, week, month }

final _tasksRangeProvider = StreamProvider.family<List<Task>, (String, String)>(
  (ref, r) => ref.watch(tasksRepoProvider).watchRange(r.$1, r.$2),
);

/// One item on the calendar: a task or a Google event.
class _Item {
  _Item.task(this.task) : event = null, day = task!.dueDay!, at = task.dueAtUtc, title = task.title;
  _Item.event(this.event, this.day)
    : task = null,
      at = event!.startUtc,
      title = event.title.isEmpty ? '(no title)' : event.title;
  final Task? task;
  final CalendarEvent? event;
  final String day;
  final DateTime? at;
  final String title;
}

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  CalView _view = CalView.day;
  String? _anchor;

  (String, String) _range(String a) => switch (_view) {
    CalView.day => (a, a),
    CalView.week => (DayKey.add(a, 1 - DayKey.weekday(a)), DayKey.add(a, 7 - DayKey.weekday(a))),
    CalView.month => () {
      final d = DayKey.toDate(a);
      final first = DateTime.utc(d.year, d.month, 1);
      final last = DateTime.utc(d.year, d.month + 1, 0);
      return (DayKey.fromDate(first), DayKey.fromDate(last));
    }(),
  };

  String _step(String a, int dir) => switch (_view) {
    CalView.day => DayKey.add(a, dir),
    CalView.week => DayKey.add(a, 7 * dir),
    CalView.month => () {
      final d = DayKey.toDate(a);
      return DayKey.fromDate(DateTime.utc(d.year, d.month + dir, 1));
    }(),
  };

  @override
  Widget build(BuildContext context) {
    final today = ref.watch(todayProvider);
    final a = _anchor ?? today;
    final (from, to) = _range(a);
    final clock = ref.watch(clockProvider);
    final tasks = ref.watch(_tasksRangeProvider((from, to))).value ?? const <Task>[];
    final events = ref.watch(eventsRangeProvider((from, to))).value ?? const <CalendarEvent>[];
    final items = <_Item>[
      ...tasks.map(_Item.task),
      for (final e in events) _Item.event(e, e.allDayDate ?? clock.dayKeyFor(e.startUtc!)),
    ];
    final byDay = <String, List<_Item>>{};
    for (final i in items) {
      (byDay[i.day] ??= []).add(i);
    }
    for (final l in byDay.values) {
      l.sort((x, y) => (x.at ?? DateTime(0)).compareTo(y.at ?? DateTime(0)));
    }
    final signedIn = ref.watch(settingsProvider).googleEmail.isNotEmpty;

    final title = switch (_view) {
      CalView.day => relDay(a, today),
      CalView.week => '${fmtDayKey(from)} – ${fmtDayKey(to)}',
      CalView.month => '${monShort[DayKey.toDate(a).month - 1]} ${DayKey.toDate(a).year}',
    };

    return Scaffold(
      appBar: AppBar(
        backgroundColor: N.bg,
        surfaceTintColor: Colors.transparent,
        title: Text('Calendar', style: N.h2.copyWith(fontSize: 18)),
        actions: [
          if (signedIn)
            IconButton(
              tooltip: 'Sync with Google',
              icon: const Icon(Icons.sync_rounded, color: N.gold),
              onPressed: () async {
                final r = await ref.read(googleJobsProvider).syncNow();
                if (context.mounted) showSnack(context, r.ok ? 'Calendar synced' : 'Sync failed: ${r.error}');
              },
            ),
          IconButton(
            tooltip: 'New task',
            icon: const Icon(Icons.add_rounded, color: N.gold),
            onPressed: () => showAddTaskSheet(context),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 40),
        children: [
          Row(
            children: [
              for (final v in CalView.values) ...[
                if (v.index > 0) const SizedBox(width: 6),
                Expanded(
                  child: NChip(
                    const ['Day', 'Week', 'Month'][v.index],
                    on: _view == v,
                    onTap: () => setState(() => _view = v),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              IconBtn(
                Icons.chevron_left_rounded,
                label: 'Previous',
                onTap: () => setState(() => _anchor = _step(a, -1)),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _anchor = null),
                  child: Text(title, textAlign: TextAlign.center, style: N.h2),
                ),
              ),
              IconBtn(Icons.chevron_right_rounded, label: 'Next', onTap: () => setState(() => _anchor = _step(a, 1))),
            ],
          ),
          if (!signedIn) ...[
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () => context.push('/google'),
              child: const EmptyNote('Connect Google (Me → Google account) to see your calendar events here.'),
            ),
          ],
          const SizedBox(height: N.gap),
          switch (_view) {
            CalView.day => _DayList(items: byDay[a] ?? const [], onTap: _open),
            CalView.week => Column(
              children: [
                for (var d = from; d.compareTo(to) <= 0; d = DayKey.add(d, 1))
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: GlassCard(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          GestureDetector(
                            onTap: () => setState(() {
                              _view = CalView.day;
                              _anchor = d;
                            }),
                            child: Text(
                              relDay(d, today),
                              style: N.h2.copyWith(fontSize: 14, color: d == today ? N.gold : N.ink),
                            ),
                          ),
                          if ((byDay[d] ?? const []).isEmpty)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              child: Text('Free', style: N.small),
                            ),
                          for (final i in byDay[d] ?? const <_Item>[]) _ItemRow(item: i, onTap: () => _open(i)),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
            CalView.month => _MonthGrid(
              anchor: a,
              today: today,
              counts: {for (final e in byDay.entries) e.key: e.value.length},
              onPick: (d) => setState(() {
                _view = CalView.day;
                _anchor = d;
              }),
            ),
          },
        ],
      ),
    );
  }

  Future<void> _open(_Item i) async {
    if (i.task != null) {
      await showAddTaskSheet(context, editing: i.task);
      return;
    }
    final e = i.event!;
    if (e.allDayDate != null) return;
    final c = TextEditingController(text: e.title);
    final clock = ref.read(clockProvider);
    final l = clock.toLocal(e.startUtc!);
    var time = TimeOfDay(hour: l.hour, minute: l.minute);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, set) => AlertDialog(
          title: Text('Edit event', style: N.h2),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: c,
                decoration: const InputDecoration(hintText: 'Title'),
              ),
              const SizedBox(height: 12),
              NButton(
                'Starts ${fmtTimeOfDay(time)}',
                kind: BtnKind.raise,
                expand: true,
                onTap: () async {
                  final t = await showTimePicker(context: ctx, initialTime: time);
                  if (t != null) set(() => time = t);
                },
              ),
              const SizedBox(height: 6),
              Text('Changes are saved to your Google Calendar.', style: N.small.copyWith(fontSize: 12)),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel', style: TextStyle(color: N.muted)),
            ),
            NButton('Save', onTap: () => Navigator.pop(ctx, true)),
          ],
        ),
      ),
    );
    if (ok != true) return;
    final start = clock.localToUtc(clock.calendarDateFor(e.startUtc!), time.hour, time.minute);
    final len = e.endUtc == null ? const Duration(hours: 1) : e.endUtc!.difference(e.startUtc!);
    try {
      await ref
          .read(calendarSyncProvider)
          .editPrimary(e, title: c.text.trim(), startUtc: start, endUtc: start.add(len));
      if (mounted) showSnack(context, 'Event updated');
    } catch (err) {
      if (mounted) showSnack(context, 'Couldn\'t update: $err');
    }
  }
}

class _DayList extends StatelessWidget {
  const _DayList({required this.items, required this.onTap});
  final List<_Item> items;
  final void Function(_Item) onTap;

  @override
  Widget build(BuildContext context) => GlassCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (items.isEmpty) const EmptyNote('Nothing scheduled. Enjoy the space.'),
        for (final i in items) _ItemRow(item: i, onTap: () => onTap(i)),
      ],
    ),
  );
}

class _ItemRow extends ConsumerWidget {
  const _ItemRow({required this.item, required this.onTap});
  final _Item item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final clock = ref.watch(clockProvider);
    final isTask = item.task != null;
    final done = item.task?.doneAtUtc != null;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Container(
              width: 4,
              height: 30,
              decoration: BoxDecoration(color: isTask ? N.gold : N.water, borderRadius: BorderRadius.circular(4)),
            ),
            const SizedBox(width: 10),
            SizedBox(
              width: 66,
              child: Text(
                item.event?.allDayDate != null
                    ? 'All day'
                    : item.at == null
                    ? 'Anytime'
                    : fmtTime(clock, item.at!),
                style: N.num(12, color: N.muted),
              ),
            ),
            Expanded(
              child: Text(
                item.title,
                style: TextStyle(
                  fontSize: 14,
                  color: done ? N.muted : N.ink,
                  decoration: done ? TextDecoration.lineThrough : null,
                  decorationColor: N.muted,
                ),
              ),
            ),
            Icon(isTask ? Icons.check_circle_outline_rounded : Icons.event_outlined, size: 16, color: N.muted),
          ],
        ),
      ),
    );
  }
}

class _MonthGrid extends StatelessWidget {
  const _MonthGrid({required this.anchor, required this.today, required this.counts, required this.onPick});
  final String anchor;
  final String today;
  final Map<String, int> counts;
  final ValueChanged<String> onPick;

  @override
  Widget build(BuildContext context) {
    final d = DayKey.toDate(anchor);
    final first = DayKey.fromDate(DateTime.utc(d.year, d.month, 1));
    final days = DateTime.utc(d.year, d.month + 1, 0).day;
    final lead = DayKey.weekday(first) - 1;
    return GlassCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Row(
            children: [
              for (final w in dowShort)
                Expanded(
                  child: Center(child: Text(w.substring(0, 2), style: N.eyebrow)),
                ),
            ],
          ),
          const SizedBox(height: 8),
          GridView.count(
            crossAxisCount: 7,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 4,
            crossAxisSpacing: 4,
            children: [
              for (var i = 0; i < lead; i++) const SizedBox(),
              for (var day = 1; day <= days; day++)
                () {
                  final k = DayKey.add(first, day - 1);
                  final n = counts[k] ?? 0;
                  return Material(
                    color: k == today ? N.goldSoft : (n > 0 ? N.raise : Colors.transparent),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(color: k == today ? N.gold : Colors.transparent),
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(10),
                      onTap: () => onPick(k),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('$day', style: N.num(13, color: k == today ? N.goldHi : N.ink)),
                          const SizedBox(height: 3),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              for (var j = 0; j < n.clamp(0, 3); j++)
                                Container(
                                  width: 4,
                                  height: 4,
                                  margin: const EdgeInsets.symmetric(horizontal: 1),
                                  decoration: const BoxDecoration(color: N.gold, shape: BoxShape.circle),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                }(),
            ],
          ),
        ],
      ),
    );
  }
}
