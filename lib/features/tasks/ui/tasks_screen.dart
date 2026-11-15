import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/db/app_db.dart';
import '../../../core/notifications/reminder_sync.dart';
import '../../../core/providers.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/theme/widgets.dart';
import '../../profiles/data/profiles_repo.dart';
import '../data/tasks_repo.dart';
import 'task_widgets.dart';

class TasksScreen extends ConsumerWidget {
  const TasksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profiles = ref.watch(profilesProvider).value ?? const <Profile>[];
    final filter = ref.watch(profileFilterProvider);
    bool keep(Task t) => filter == null || t.profileId == filter;
    final today = ref.watch(filteredTodayTasksProvider);
    final upcoming = (ref.watch(upcomingTasksProvider).value ?? const <Task>[]).where(keep).toList();
    final done = (ref.watch(doneTasksProvider).value ?? const <Task>[]).where(keep).toList();
    final openToday = today.where((t) => t.doneAtUtc == null && t.dueDay != null).length;

    Widget section(
      String title,
      List<Task> l, {
      bool showDay = false,
      Widget? trailing,
      String empty = 'Nothing here.',
    }) => GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CardHeader(title, trailing: trailing),
          if (l.isEmpty) EmptyNote(empty) else ...l.map((t) => TaskTile(task: t, profiles: profiles, showDay: showDay)),
        ],
      ),
    );

    return Scaffold(
      appBar: AppBar(
        backgroundColor: N.bg,
        surfaceTintColor: Colors.transparent,
        title: Text('Tasks', style: N.h2.copyWith(fontSize: 18)),
        actions: [
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
          ProfileFilterChips(profiles: profiles, selected: filter),
          const SizedBox(height: N.gap),
          section(
            'Today',
            today,
            empty: 'All clear for today.',
            trailing: openToday == 0
                ? null
                : GestureDetector(
                    onTap: () async {
                      final n = await ref.read(tasksRepoProvider).rollToTomorrow(ref.read(clockProvider));
                      ref.read(reminderSyncProvider).schedule();
                      if (context.mounted) {
                        showSnack(context, 'Moved $n unfinished ${n == 1 ? 'task' : 'tasks'} to tomorrow');
                      }
                    },
                    child: const Text(
                      'Roll unfinished → tomorrow',
                      style: TextStyle(color: N.gold, fontWeight: FontWeight.w600, fontSize: 13),
                    ),
                  ),
          ),
          const SizedBox(height: N.gap),
          section('Upcoming', upcoming, showDay: true, empty: 'Nothing scheduled ahead.'),
          const SizedBox(height: N.gap),
          section('Recently done', done.take(20).toList(), showDay: true, empty: 'Finished tasks show up here.'),
          const SizedBox(height: 10),
          Text('Swipe left to delete · long-press to edit', textAlign: TextAlign.center, style: N.small),
        ],
      ),
    );
  }
}
