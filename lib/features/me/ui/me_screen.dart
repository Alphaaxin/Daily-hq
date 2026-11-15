import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/db/app_db.dart';
import '../../../core/notifications/reminder_sync.dart';
import '../../../core/providers.dart';
import '../../../core/settings/app_settings.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/theme/widgets.dart';
import '../../../core/time/day_clock.dart';
import '../../gamification/data/xp_repo.dart';
import '../../gamification/domain/streaks.dart';
import '../../habits/data/habits_repo.dart';
import '../../profiles/data/profiles_repo.dart';
import '../../salah/data/salah_repo.dart';
import '../../salah/domain/prayer_times.dart';
import '../../sleep/data/sleep_repo.dart';
import '../../routines/data/routines_repo.dart';
import '../../sleep/domain/sleep_logic.dart';
import '../../../core/theme/dialogs.dart';
import 'sleep_chart.dart';

class MeScreen extends ConsumerWidget {
  const MeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView(
      padding: EdgeInsets.fromLTRB(16, 12, 16, 120 + MediaQuery.of(context).padding.bottom),
      children: const [
        _StatsCard(),
        SizedBox(height: N.gap),
        _LinksCard(),
        SizedBox(height: N.gap),
        _SleepStatsCard(),
        SizedBox(height: N.gap),
        _SettingsCard(),
        SizedBox(height: N.gap),
        _ProfilesCard(),
        SizedBox(height: N.gap),
        _HabitsCard(),
        SizedBox(height: N.gap),
        _RoutinesCard(),
        SizedBox(height: N.gap),
        _AzanCard(),
        SizedBox(height: N.gap),
        _ModulesCard(),
        SizedBox(height: N.gap),
        _SetupCard(),
      ],
    );
  }
}

class _StatsCard extends ConsumerWidget {
  const _StatsCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(settingsProvider);
    final lvl = ref.watch(levelProvider);
    final streak = ref.watch(overallStreakProvider);
    final best = bestStreak(ref.watch(activeDaysProvider).value ?? const {});
    final salah = ref.watch(salahStreakProvider);
    final hs = ref.watch(habitStreaksProvider).values;
    final habitBest = hs.isEmpty ? 0 : hs.reduce((a, b) => a > b ? a : b);
    Widget stat(String label, String v) => Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: N.raise,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: N.line),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Eyebrow(label),
            const SizedBox(height: 4),
            Text(v, style: N.num(19)),
          ],
        ),
      ),
    );
    return GlassCard(
      hero: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                alignment: Alignment.center,
                decoration: BoxDecoration(gradient: N.goldGradient, borderRadius: BorderRadius.circular(16)),
                child: Text(
                  s.name.isEmpty ? 'N' : s.name[0].toUpperCase(),
                  style: const TextStyle(
                    fontFamily: N.display,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: N.goldInk,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(s.name, style: N.h1.copyWith(fontSize: 22)),
                    const SizedBox(height: 2),
                    Text('Level ${lvl.level} · ${lvl.name} · ${lvl.xp} XP', style: N.small),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              stat('Streak', '$streak'),
              const SizedBox(width: 8),
              stat('Best', '$best'),
              const SizedBox(width: 8),
              stat('Salah', '$salah'),
              const SizedBox(width: 8),
              stat('Habit', '$habitBest'),
            ],
          ),
        ],
      ),
    );
  }
}

class _SleepStatsCard extends ConsumerWidget {
  const _SleepStatsCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(settingsProvider);
    if (!s.on(Module.sleep)) return const SizedBox.shrink();
    final clock = ref.watch(clockProvider);
    final recent = ref.watch(recentSleepProvider).value ?? const <SleepSession>[];
    String avg(int n) {
      final l = recent.take(n).toList();
      if (l.isEmpty) return '—';
      return fmtDuration(
        Duration(minutes: l.map((e) => e.span.duration!.inMinutes).reduce((a, b) => a + b) ~/ l.length),
      );
    }

    int localMin(DateTime utc) {
      final l = clock.toLocal(utc);
      return l.hour * 60 + l.minute;
    }

    final nights = recent.take(14).toList().reversed.map((e) {
      final d = DayKey.toDate(sleepCreditDay(clock, e.span));
      return NightBar(
        label: '${d.day}',
        bedMin: SleepChart.toChart(localMin(e.sleptAtUtc)),
        wakeMin: SleepChart.toChart(localMin(e.wokeAtUtc!)),
        onTarget: e.span.duration!.inMinutes >= s.sleepTargetHours * 60,
      );
    }).toList();

    final sug = ref.watch(bedtimeSuggestionProvider);
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const CardHeader('Sleep'),
          Row(
            children: [
              Expanded(child: _kv('7-night avg', avg(7))),
              Expanded(child: _kv('30-night avg', avg(30))),
              Expanded(child: _kv('Target', '${s.sleepTargetHours}h')),
            ],
          ),
          const SizedBox(height: 14),
          if (nights.isEmpty)
            const EmptyNote('Tap Good Night and Good Morning for a few days to see your pattern.')
          else
            SleepChart(nights: nights),
          if (sug != null) ...[
            const SizedBox(height: 10),
            Text(
              'Suggestion: move bedtime to ${fmtClock(sug.suggestedMin)} (15 min earlier than your ${fmtClock(sug.averageBedtimeMin)} average).',
              style: N.small,
            ),
          ],
          const SizedBox(height: 6),
          Text(
            'Mood, focus and Life Score correlations arrive with Phase 4 insights.',
            style: N.small.copyWith(fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _kv(String k, String v) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Eyebrow(k),
      const SizedBox(height: 4),
      Text(v, style: N.num(16)),
    ],
  );
}

class _SettingsCard extends ConsumerWidget {
  const _SettingsCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(settingsProvider);
    final repo = ref.read(settingsRepoProvider);
    Future<void> set(String k, Object v) async {
      await repo.set(k, v);
      ref.read(reminderSyncProvider).schedule();
    }

    String hr(int h) => fmtClock(h * 60);

    return GlassCard(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const CardHeader('Settings'),
          _Tile(
            'Your name',
            s.name,
            onTap: () async {
              final v = await askText(context, 'Your name', s.name);
              if (v != null && v.trim().isNotEmpty) set('name', v.trim());
            },
          ),
          _Tile(
            'Day starts at',
            hr(s.rolloverHour),
            sub: 'A Good Night before this counts for the previous day',
            onTap: () async {
              final v = await askInt(context, 'Day starts at (hour)', s.rolloverHour, 0, 12, fmt: hr);
              if (v != null) set('rolloverHour', v);
            },
          ),
          _Tile(
            'Time zone',
            s.timezone,
            onTap: () async {
              final v = await askText(context, 'IANA time zone', s.timezone);
              if (v != null && v.contains('/')) set('timezone', v.trim());
            },
          ),
          _Tile(
            'Sleep target',
            '${s.sleepTargetHours}h',
            onTap: () async {
              final v = await askInt(
                context,
                'Sleep target (×30 min)',
                (s.sleepTargetHours * 2).round(),
                8,
                20,
                fmt: (x) => '${x / 2}h',
              );
              if (v != null) set('sleepTargetHours', v / 2);
            },
          ),
          _Switch('Bedtime nudge', s.bedtimeNudge, (v) => set('bedtimeNudge', v)),
          _Tile(
            'Water goal',
            '${s.waterGoal} glasses',
            onTap: () async {
              final v = await askInt(context, 'Water goal (glasses)', s.waterGoal, 2, 20);
              if (v != null) set('waterGoal', v);
            },
          ),
          _Tile(
            'Water reminder every',
            '${s.waterIntervalMin} min',
            onTap: () async {
              final v = await askInt(
                context,
                'Remind every (min)',
                s.waterIntervalMin ~/ 15,
                4,
                8,
                fmt: (x) => '${x * 15} min',
              );
              if (v != null) set('waterIntervalMin', v * 15);
            },
          ),
          _Switch('Water reminders', s.waterReminders, (v) => set('waterReminders', v)),
          _Switch('Task due reminders', s.taskReminders, (v) => set('taskReminders', v)),
          _Tile(
            'Quiet hours',
            '${hr(s.quietStart)} → ${hr(s.quietEnd)}',
            onTap: () async {
              final a = await askInt(context, 'Quiet from', s.quietStart, 0, 23, fmt: hr);
              if (a == null || !context.mounted) return;
              final b = await askInt(context, 'Quiet until', s.quietEnd, 0, 23, fmt: hr);
              if (b == null) return;
              await repo.set('quietStart', a);
              set('quietEnd', b);
            },
          ),
          _Tile(
            'Prayer calculation',
            PrayerConfig.methods[s.prayerMethod] ?? s.prayerMethod,
            onTap: () async {
              final v = await showDialog<String>(
                context: context,
                builder: (ctx) => SimpleDialog(
                  title: Text('Calculation method', style: N.h2),
                  children: [
                    for (final e in PrayerConfig.methods.entries)
                      SimpleDialogOption(
                        onPressed: () => Navigator.pop(ctx, e.key),
                        child: Text(e.value, style: TextStyle(color: e.key == s.prayerMethod ? N.gold : N.ink)),
                      ),
                  ],
                ),
              );
              if (v != null) set('prayerMethod', v);
            },
          ),
          _Switch(
            'Hanafi Asr (later)',
            s.hanafiAsr,
            (v) => set('hanafiAsr', v),
            sub: s.hanafiAsr ? 'Shadow = 2× object length' : 'Shafi / standard: 1×',
          ),
          _Tile(
            'Location',
            '${s.latitude.toStringAsFixed(3)}, ${s.longitude.toStringAsFixed(3)}',
            sub: 'Hyderabad by default',
            onTap: () async {
              final v = await askText(context, 'Latitude, longitude', '${s.latitude}, ${s.longitude}');
              final p = v?.split(',').map((e) => double.tryParse(e.trim())).toList();
              if (p != null && p.length == 2 && p[0] != null && p[1] != null) {
                await repo.set('latitude', p[0]);
                set('longitude', p[1]!);
              }
            },
          ),
        ],
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile(this.title, this.value, {required this.onTap, this.sub});
  final String title;
  final String value;
  final String? sub;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    child: Container(
      constraints: const BoxConstraints(minHeight: 52),
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: N.line)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 15)),
                if (sub != null) Text(sub!, style: N.small.copyWith(fontSize: 12)),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: N.gold, fontWeight: FontWeight.w600, fontSize: 14),
            ),
          ),
        ],
      ),
    ),
  );
}

class _Switch extends StatelessWidget {
  const _Switch(this.title, this.value, this.onChanged, {this.sub});
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;
  final String? sub;

  @override
  Widget build(BuildContext context) => Container(
    decoration: const BoxDecoration(
      border: Border(top: BorderSide(color: N.line)),
    ),
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 15)),
              if (sub != null) Text(sub!, style: N.small.copyWith(fontSize: 12)),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: (v) {
            Haptic.tap();
            onChanged(v);
          },
        ),
      ],
    ),
  );
}

/// Shared list editor for profiles and habits.
class _ListEditor extends StatelessWidget {
  const _ListEditor({
    required this.title,
    required this.items,
    required this.onAdd,
    required this.onRename,
    required this.onArchive,
    required this.hint,
    this.leading,
  });
  final String title;
  final List<(int, String)> items;
  final ValueChanged<String> onAdd;
  final void Function(int, String) onRename;
  final ValueChanged<int> onArchive;
  final String hint;
  final Widget Function(int id)? leading;

  @override
  Widget build(BuildContext context) => GlassCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CardHeader(
          title,
          trailing: GestureDetector(
            onTap: () async {
              final v = await askText(context, hint, '');
              if (v != null && v.trim().isNotEmpty) onAdd(v.trim());
            },
            child: const Text(
              '+ Add',
              style: TextStyle(color: N.gold, fontWeight: FontWeight.w700),
            ),
          ),
        ),
        if (items.isEmpty) const EmptyNote('Nothing yet.'),
        for (final (id, name) in items)
          Container(
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: N.line)),
            ),
            child: Row(
              children: [
                if (leading != null) ...[leading!(id), const SizedBox(width: 10)],
                Expanded(child: Text(name, style: const TextStyle(fontSize: 15))),
                IconButton(
                  tooltip: 'Rename',
                  icon: const Icon(Icons.edit_outlined, size: 18, color: N.muted),
                  onPressed: () async {
                    final v = await askText(context, 'Rename', name);
                    if (v != null && v.trim().isNotEmpty) onRename(id, v.trim());
                  },
                ),
                IconButton(
                  tooltip: 'Remove',
                  icon: const Icon(Icons.close_rounded, size: 18, color: N.muted),
                  onPressed: () async {
                    final ok = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: Text('Remove "$name"?', style: N.h2),
                        content: Text('History is kept; it just stops showing.', style: N.small),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, false),
                            child: const Text('Cancel', style: TextStyle(color: N.muted)),
                          ),
                          NButton('Remove', kind: BtnKind.danger, onTap: () => Navigator.pop(ctx, true)),
                        ],
                      ),
                    );
                    if (ok == true) onArchive(id);
                  },
                ),
              ],
            ),
          ),
      ],
    ),
  );
}

class _ProfilesCard extends ConsumerWidget {
  const _ProfilesCard();
  static const _palette = [0xFFD9B46A, 0xFF6CC4E6, 0xFF5FD39A, 0xFFF07A6E, 0xFFB79CFF, 0xFFE9C062];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = ref.watch(profilesProvider).value ?? const <Profile>[];
    final repo = ref.read(profilesRepoProvider);
    final colors = {for (final p in l) p.id: p.color};
    return _ListEditor(
      title: 'Work profiles',
      hint: 'New profile name',
      items: [for (final p in l) (p.id, p.name)],
      leading: (id) => Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(color: Color(colors[id] ?? 0xFFD9B46A), shape: BoxShape.circle),
      ),
      onAdd: (n) => repo.add(n, _palette[l.length % _palette.length]),
      onRename: repo.rename,
      onArchive: repo.archive,
    );
  }
}

class _HabitsCard extends ConsumerWidget {
  const _HabitsCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!ref.watch(settingsProvider).on(Module.habits)) return const SizedBox.shrink();
    final l = ref.watch(habitsProvider).value ?? const <Habit>[];
    final repo = ref.read(habitsRepoProvider);
    return _ListEditor(
      title: 'Habits',
      hint: 'New habit, e.g. Gym',
      items: [for (final h in l) (h.id, h.name)],
      onAdd: repo.add,
      onRename: repo.rename,
      onArchive: repo.archive,
    );
  }
}

class _ModulesCard extends ConsumerWidget {
  const _ModulesCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(settingsProvider);
    return GlassCard(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const CardHeader('Modules'),
          Text(
            'Switch off anything you don\'t use. It disappears from Today and stops counting in your Life Score.',
            style: N.small,
          ),
          const SizedBox(height: 6),
          for (final m in Module.values)
            _Switch(m.label, s.on(m), (v) async {
              await ref.read(settingsRepoProvider).setModule(s, m, v);
              ref.read(reminderSyncProvider).schedule();
            }),
        ],
      ),
    );
  }
}

class _SetupCard extends StatelessWidget {
  const _SetupCard();

  @override
  Widget build(BuildContext context) => GlassCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const CardHeader('Phone setup'),
        Text(
          'Vivo\'s battery manager can stop reminders. Re-run the setup if notifications ever stop arriving.',
          style: N.small,
        ),
        const SizedBox(height: 12),
        NButton(
          'Run phone setup',
          kind: BtnKind.raise,
          icon: Icons.verified_user_outlined,
          onTap: () => context.push('/setup'),
        ),
        const SizedBox(height: 14),
        Center(child: Text('Solo Leveling · all data stays on this phone', style: N.small.copyWith(fontSize: 12))),
      ],
    ),
  );
}

class _LinksCard extends ConsumerWidget {
  const _LinksCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(settingsProvider);
    Widget link(IconData icon, String title, String sub, String route) => InkWell(
      onTap: () => context.push(route),
      child: Container(
        constraints: const BoxConstraints(minHeight: 56),
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: N.line)),
        ),
        child: Row(
          children: [
            Icon(icon, color: N.gold, size: 22),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                  Text(sub, style: N.small.copyWith(fontSize: 12)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: N.muted),
          ],
        ),
      ),
    );
    return GlassCard(
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 4),
      child: Column(
        children: [
          link(
            Icons.cloud_outlined,
            'Google account & backup',
            s.googleEmail.isEmpty ? 'Calendar sync and Drive backup are off' : s.googleEmail,
            '/google',
          ),
          if (s.on(Module.people))
            link(Icons.people_alt_outlined, 'People', 'Follow-ups, birthdays, contacts', '/people'),
          if (s.on(Module.leads)) link(Icons.storefront_outlined, 'Leads', 'Pipeline from New to Closed', '/leads'),
          if (s.on(Module.mail))
            link(Icons.mark_email_unread_outlined, 'Mail merge', 'Templates, CSV, scheduled sends via Gmail', '/mail'),
          link(Icons.insights_outlined, 'Weekly review', 'Stats, sales by profile, 3 questions', '/review'),
          link(Icons.bar_chart_rounded, 'Monthly report', 'Charts, best days, sleep vs mood', '/report'),
          link(Icons.grid_on_rounded, 'Year in Pixels', 'One square per day, coloured by Life Score', '/pixels'),
          if (s.on(Module.learning)) link(Icons.school_outlined, 'Learning', 'Courses, books, skills', '/learning'),
          if (s.on(Module.screenTime))
            link(Icons.phone_android_rounded, 'Screen time', 'Top apps and limits', '/screentime'),
          link(Icons.notifications_active_outlined, 'Nudges & quests', 'Which nudges you get; quest pool', '/nudges'),
          link(Icons.auto_awesome_outlined, 'AI (Gemini)', 'Key and model for minutes, voice notes, drafts', '/ai'),
          link(Icons.calendar_month_outlined, 'Calendar', 'Tasks and events by day, week or month', '/calendar'),
          if (s.on(Module.focus))
            link(Icons.timer_outlined, 'Focus & Build Hour', 'Pomodoro, work timer, ideas', '/focus'),
          if (s.on(Module.focus))
            link(Icons.schedule_rounded, 'Time log', 'Retainer hours per profile · CSV / PDF', '/time'),
          if (s.on(Module.targets))
            link(Icons.flag_outlined, 'Daily targets', 'Leads, emails, research quotas', '/targets'),
          if (s.on(Module.money))
            link(
              Icons.account_balance_wallet_outlined,
              'Money settings',
              'Categories, budgets, quick-log',
              '/money-settings',
            ),
        ],
      ),
    );
  }
}

class _RoutinesCard extends ConsumerWidget {
  const _RoutinesCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(settingsProvider);
    if (!s.on(Module.routines)) return const SizedBox.shrink();
    final repo = ref.read(routinesRepoProvider);
    final morning = ref.watch(morningItemsProvider).value ?? const <RoutineItem>[];
    final evening = ref.watch(eveningItemsProvider).value ?? const <RoutineItem>[];
    return Column(
      children: [
        _ListEditor(
          title: 'Morning routine',
          hint: 'New morning step',
          items: [for (final i in morning) (i.id, i.name)],
          onAdd: (n) => repo.add(Routine.morning, n),
          onRename: repo.rename,
          onArchive: repo.archive,
        ),
        const SizedBox(height: N.gap),
        _ListEditor(
          title: 'Evening shutdown',
          hint: 'New evening step',
          items: [for (final i in evening) (i.id, i.name)],
          onAdd: (n) => repo.add(Routine.evening, n),
          onRename: repo.rename,
          onArchive: repo.archive,
        ),
        const SizedBox(height: N.gap),
        GlassCard(
          padding: const EdgeInsets.fromLTRB(18, 6, 18, 6),
          child: _Tile(
            'Evening shutdown starts at',
            fmtClock(s.eveningHour * 60),
            onTap: () async {
              final v = await askInt(
                context,
                'Evening shutdown from',
                s.eveningHour,
                17,
                23,
                fmt: (h) => fmtClock(h * 60),
              );
              if (v != null) await ref.read(settingsRepoProvider).set('eveningHour', v);
            },
          ),
        ),
      ],
    );
  }
}

class _AzanCard extends ConsumerWidget {
  const _AzanCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(settingsProvider);
    if (!s.on(Module.salah)) return const SizedBox.shrink();
    final repo = ref.read(settingsRepoProvider);
    Future<void> set(String k, Object v) async {
      await repo.set(k, v);
      ref.read(reminderSyncProvider).schedule();
    }

    return GlassCard(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const CardHeader('Prayer notifications'),
          _Switch(
            'Chime at prayer times',
            s.azan,
            (v) => set('azan', v),
            sub: 'With a "Prayed ✓" button that marks it on time',
          ),
          if (s.azan) ...[
            _Switch('Reminder 10 min before', s.azanBefore, (v) => set('azanBefore', v)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final p in Prayer.values)
                  NChip(
                    p.label,
                    on: !s.azanOff.contains(p.name),
                    onTap: () {
                      final off = {...s.azanOff};
                      off.contains(p.name) ? off.remove(p.name) : off.add(p.name);
                      set('azanOff', off.toList());
                    },
                  ),
              ],
            ),
            const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }
}
