import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/db/app_db.dart';
import '../../../core/native/native_bridge.dart';
import '../../../core/providers.dart';
import '../../../core/theme/dialogs.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/theme/widgets.dart';
import '../../../core/time/day_clock.dart';
import '../../../core/time/format.dart';
import '../../focus/data/focus_controller.dart';
import '../../focus/domain/focus_logic.dart';
import '../../game/data/game_repo.dart';
import '../../game/domain/game_logic.dart';
import '../../game/domain/nudges.dart';
import '../../gamification/data/xp_repo.dart';
import '../../money/domain/money_parser.dart';
import '../../profiles/data/profiles_repo.dart';
import '../../sleep/domain/sleep_logic.dart';
import '../data/insights_repo.dart';

AppBar _bar(String t) => AppBar(
  backgroundColor: N.bg,
  surfaceTintColor: Colors.transparent,
  title: Text(t, style: N.h2.copyWith(fontSize: 18)),
);

Color scoreColor(int? s) {
  if (s == null) return N.raise;
  if (s >= 80) return N.gold;
  if (s >= 60) return const Color(0xFFB8975A);
  if (s >= 40) return const Color(0xFF7A6A45);
  if (s >= 20) return const Color(0xFF4A4232);
  return const Color(0xFF2A2721);
}

// ---------------------------------------------------------------- Year in Pixels

class YearInPixelsScreen extends ConsumerWidget {
  const YearInPixelsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final today = ref.watch(todayProvider);
    final year = today.substring(0, 4);
    final scores = ref.watch(_scoresProvider(year)).value ?? const <String, int>{};
    final avg = scores.isEmpty ? null : (scores.values.reduce((a, b) => a + b) / scores.length).round();
    return Scaffold(
      appBar: _bar('Year in Pixels'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 40),
        children: [
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                CardHeader(
                  year,
                  trailing: Text(avg == null ? '' : 'avg $avg', style: N.num(13, color: N.gold)),
                ),
                Row(
                  children: [
                    const SizedBox(width: 22),
                    for (final m in monShort)
                      Expanded(
                        child: Center(child: Text(m[0], style: N.eyebrow.copyWith(fontSize: 10))),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                for (var d = 1; d <= 31; d++)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 2),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 22,
                          child: Text(
                            '$d',
                            style: N.num(9, color: N.muted, weight: FontWeight.w500),
                          ),
                        ),
                        for (var m = 1; m <= 12; m++)
                          Expanded(
                            child: () {
                              final valid = d <= DateTime.utc(int.parse(year), m + 1, 0).day;
                              final key = DayKey.format(int.parse(year), m, d);
                              return Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 1),
                                child: AspectRatio(
                                  aspectRatio: 1.6,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: !valid ? Colors.transparent : scoreColor(scores[key]),
                                      borderRadius: BorderRadius.circular(2),
                                      border: key == today ? Border.all(color: N.goldHi) : null,
                                    ),
                                  ),
                                ),
                              );
                            }(),
                          ),
                      ],
                    ),
                  ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Text('Life Score  ', style: N.small.copyWith(fontSize: 11)),
                    for (final s in [10, 30, 50, 70, 90])
                      Container(width: 18, height: 10, margin: const EdgeInsets.only(right: 3), color: scoreColor(s)),
                    Text('  0 → 100', style: N.small.copyWith(fontSize: 11)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

final _scoresProvider = StreamProvider.family<Map<String, int>, String>(
  (ref, year) => ref.watch(gameRepoProvider).watchScores('$year-01-01', '$year-12-31'),
);

// ---------------------------------------------------------------- Learning

class LearningScreen extends ConsumerWidget {
  const LearningScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(learningProvider).value ?? const <LearningItem>[];
    final time = ref.watch(learningTimeProvider).value ?? const <int, int>{};
    final repo = ref.read(insightsRepoProvider);
    Future<void> edit([LearningItem? l]) async {
      final title = await askText(context, 'Course, book or skill', l?.title ?? '');
      if (title == null || title.trim().isEmpty || !context.mounted) return;
      final total = await askInt(context, 'How many units in total?', l?.total ?? 10, 1, 999);
      if (total == null || !context.mounted) return;
      final unit = await askText(context, 'Unit (lessons, chapters, pages, topics)', l?.unit ?? 'lessons');
      await repo.saveLearning(
        id: l?.id,
        title: title,
        kind: l?.kind ?? 'course',
        total: total,
        unit: (unit ?? 'lessons').trim(),
      );
    }

    return Scaffold(
      appBar: _bar('Learning'),
      floatingActionButton: FloatingActionButton(
        backgroundColor: N.gold,
        foregroundColor: N.goldInk,
        onPressed: edit,
        child: const Icon(Icons.add_rounded),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
        children: [
          if (items.isEmpty) const EmptyNote('Add a course, book or skill to track.'),
          for (final l in items)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => edit(l),
                            child: Text(l.title, style: N.h2),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close_rounded, size: 18, color: N.muted),
                          onPressed: () => repo.archiveLearning(l.id),
                        ),
                      ],
                    ),
                    Text('${l.done}/${l.total} ${l.unit} · ${fmtHours(time[l.id] ?? 0)} studied', style: N.small),
                    const SizedBox(height: 8),
                    GoldBar(l.total == 0 ? 0 : l.done / l.total),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        IconBtn(Icons.remove_rounded, onTap: () => repo.stepLearning(l, -1, ref.read(todayProvider))),
                        const SizedBox(width: 8),
                        IconBtn(
                          Icons.add_rounded,
                          color: N.gold,
                          onTap: () => repo.stepLearning(l, 1, ref.read(todayProvider)),
                        ),
                        const Spacer(),
                        NButton(
                          'Study 25 min',
                          kind: BtnKind.raise,
                          icon: Icons.timer_outlined,
                          onTap: () async {
                            await ref.read(focusControllerProvider).start(FocusKind.pomodoro, learningId: l.id);
                            if (context.mounted) showSnack(context, 'Pomodoro started for ${l.title}');
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------- Screen time

final _usageProvider = FutureProvider.autoDispose<(bool, List<(String, String, int)>)>((ref) async {
  ref.watch(tickerProvider);
  final ok = await NativeBridge.hasUsageAccess();
  if (!ok) return (false, const <(String, String, int)>[]);
  final clock = ref.read(clockProvider);
  return (true, await NativeBridge.usageSince(clock.dayStartUtc(clock.today())));
});

class ScreenTimeScreen extends ConsumerWidget {
  const ScreenTimeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usage = ref.watch(_usageProvider).value;
    final limits = {for (final l in ref.watch(appLimitsProvider).value ?? const <AppLimit>[]) l.packageName: l};
    final apps = usage?.$2 ?? const <(String, String, int)>[];
    final total = apps.fold(0, (a, e) => a + e.$3);
    return Scaffold(
      appBar: _bar('Screen time'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 40),
        children: [
          if (usage != null && !usage.$1)
            GlassCard(
              hero: true,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const CardHeader('Allow usage access'),
                  Text(
                    'Android needs your OK to share how long you use each app. It stays on this phone.',
                    style: N.small,
                  ),
                  const SizedBox(height: 12),
                  NButton('Open settings', expand: true, onTap: NativeBridge.requestUsageAccess),
                ],
              ),
            )
          else ...[
            GlassCard(
              hero: true,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Eyebrow('Today'),
                  const SizedBox(height: 4),
                  GoldText(fmtHours(total * 60), style: N.num(34)),
                  const SizedBox(height: 4),
                  Text('Set a limit on an app and you\'ll get a nudge to swap it for a quest.', style: N.small),
                ],
              ),
            ),
            const SizedBox(height: N.gap),
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const CardHeader('Top apps'),
                  if (apps.isEmpty) const EmptyNote('No app has been used for more than a minute today.'),
                  for (final (pkg, label, mins) in apps)
                    InkWell(
                      onTap: () async {
                        final v = await askInt(
                          context,
                          'Daily limit for $label (×15 min, 0 = none)',
                          (limits[pkg]?.minutes ?? 60) ~/ 15,
                          0,
                          32,
                          fmt: (x) => x == 0 ? 'No limit' : fmtHours(x * 15 * 60),
                        );
                        if (v != null) {
                          await ref.read(insightsRepoProvider).setLimit(pkg, label, v == 0 ? null : v * 15);
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 7),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              children: [
                                Expanded(child: Text(label, style: const TextStyle(fontSize: 14))),
                                Text(
                                  fmtHours(mins * 60),
                                  style: N.num(
                                    13,
                                    color: limits[pkg] != null && mins >= limits[pkg]!.minutes ? N.bad : N.ink,
                                  ),
                                ),
                                if (limits[pkg] != null)
                                  Text(' / ${fmtHours(limits[pkg]!.minutes * 60)}', style: N.num(12, color: N.muted)),
                              ],
                            ),
                            const SizedBox(height: 4),
                            GoldBar(
                              limits[pkg] != null ? mins / limits[pkg]!.minutes : (total == 0 ? 0 : mins / total),
                              color: limits[pkg] != null && mins >= limits[pkg]!.minutes ? N.bad : null,
                              height: 4,
                            ),
                          ],
                        ),
                      ),
                    ),
                  const SizedBox(height: 6),
                  Text('Tap an app to set its daily limit.', style: N.small.copyWith(fontSize: 12)),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Apps over their limit today (labels), for nudges.
Future<List<String>> overLimitApps(InsightsRepo repo, DateTime dayStartUtc) async {
  final limits = await repo.limits();
  if (limits.isEmpty || !await NativeBridge.hasUsageAccess()) return const [];
  final usage = {for (final (pkg, _, mins) in await NativeBridge.usageSince(dayStartUtc)) pkg: mins};
  return [
    for (final l in limits)
      if ((usage[l.packageName] ?? 0) >= l.minutes) l.label,
  ];
}

// ---------------------------------------------------------------- Reviews & report

class _Stat extends StatelessWidget {
  const _Stat(this.label, this.value);
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: N.raise,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: N.line),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Eyebrow(label),
        const SizedBox(height: 4),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(value, style: N.num(18)),
        ),
      ],
    ),
  );
}

Widget _grid(List<_Stat> s) => GridView.count(
  crossAxisCount: 3,
  shrinkWrap: true,
  physics: const NeverScrollableScrollPhysics(),
  mainAxisSpacing: 8,
  crossAxisSpacing: 8,
  childAspectRatio: 1.25,
  children: s,
);

List<_Stat> _coreStats(PeriodStats s) => [
  _Stat('XP', '${s.xp}'),
  _Stat('Active days', '${s.activeDays}'),
  _Stat('Life score', s.avgScore == null ? '—' : '${s.avgScore}'),
  _Stat('Tasks done', '${s.tasksDone}'),
  _Stat('Build Hours', '${s.buildDays}'),
  _Stat('Pomodoros', '${s.pomodoros}'),
  _Stat('Leads', '${s.leads}'),
  _Stat('E-mails', '${s.emails}'),
  _Stat('Meetings', '${s.meetings}'),
  _Stat('Spent', formatInrShort(s.spentPaise)),
  _Stat('Invested', formatInrShort(s.investedPaise)),
  _Stat('Received', formatInrShort(s.receivedPaise)),
  _Stat('Water days', '${s.waterGoalDays}'),
  _Stat('5/5 Salah', '${s.salahFullDays}'),
  _Stat('Avg sleep', s.avgSleepMin == null ? '—' : fmtDuration(Duration(minutes: s.avgSleepMin!.round()))),
];

Widget _profileTable(WidgetRef ref, PeriodStats s) {
  final names = <int?, String>{
    null: 'Untagged',
    for (final p in ref.watch(profilesProvider).value ?? const <Profile>[]) p.id: p.name,
  };
  final keys = {...s.salesByProfile.keys, ...s.workSecondsByProfile.keys}.toList();
  if (keys.isEmpty) return const EmptyNote('No sales or retainer activity in this period.');
  return Column(
    children: [
      Row(
        children: [
          const Expanded(flex: 3, child: SizedBox()),
          for (final h in ['Leads', 'Closed', 'Mails', 'Hours'])
            Expanded(
              flex: 2,
              child: Text(h, textAlign: TextAlign.right, style: N.eyebrow),
            ),
        ],
      ),
      for (final k in keys)
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            children: [
              Expanded(flex: 3, child: Text(names[k] ?? '?', style: const TextStyle(fontSize: 13))),
              for (final v in [
                '${s.salesByProfile[k]?.$1 ?? 0}',
                '${s.salesByProfile[k]?.$2 ?? 0}',
                '${s.salesByProfile[k]?.$3 ?? 0}',
                ((s.workSecondsByProfile[k] ?? 0) / 3600).toStringAsFixed(1),
              ])
                Expanded(
                  flex: 2,
                  child: Text(v, textAlign: TextAlign.right, style: N.num(13)),
                ),
            ],
          ),
        ),
    ],
  );
}

class ReviewScreen extends ConsumerStatefulWidget {
  const ReviewScreen({super.key});

  @override
  ConsumerState<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends ConsumerState<ReviewScreen> {
  final _worked = TextEditingController(), _didnt = TextEditingController(), _focus = TextEditingController();
  int _offset = 0;
  bool _loaded = false;

  String get _ws => DayKey.add(weekStart(ref.read(todayProvider)), -7 * _offset);

  Future<void> _load() async {
    final r = await ref.read(insightsRepoProvider).review('weekly', _ws);
    _worked.text = r?.worked ?? '';
    _didnt.text = r?.didnt ?? '';
    _focus.text = r?.focus ?? '';
    if (mounted) setState(() => _loaded = true);
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  Widget build(BuildContext context) {
    final ws = DayKey.add(weekStart(ref.watch(todayProvider)), -7 * _offset);
    final stats = ref.watch(periodStatsProvider((ws, DayKey.add(ws, 6)))).value;
    return Scaffold(
      appBar: _bar('Weekly review'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 40),
        children: [
          Row(
            children: [
              IconBtn(
                Icons.chevron_left_rounded,
                onTap: () {
                  setState(() => _offset++);
                  _load();
                },
              ),
              Expanded(
                child: Text(
                  '${fmtDayKey(ws)} – ${fmtDayKey(DayKey.add(ws, 6))}',
                  textAlign: TextAlign.center,
                  style: N.h2,
                ),
              ),
              IconBtn(
                Icons.chevron_right_rounded,
                onTap: () {
                  if (_offset == 0) return;
                  setState(() => _offset--);
                  _load();
                },
              ),
            ],
          ),
          const SizedBox(height: N.gap),
          if (stats != null) ...[
            _grid(_coreStats(stats)),
            const SizedBox(height: N.gap),
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const CardHeader('Sales & retainer by profile'),
                  _profileTable(ref, stats),
                  const SizedBox(height: 6),
                  Text('${stats.callsDone} calls done from follow-ups', style: N.small.copyWith(fontSize: 12)),
                ],
              ),
            ),
          ],
          const SizedBox(height: N.gap),
          if (_loaded)
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const CardHeader('Reflect', trailing: Pill('+30 XP', hot: true)),
                  TextField(
                    controller: _worked,
                    maxLines: 3,
                    decoration: const InputDecoration(labelText: 'What worked?'),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _didnt,
                    maxLines: 3,
                    decoration: const InputDecoration(labelText: 'What didn\'t?'),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _focus,
                    maxLines: 2,
                    decoration: const InputDecoration(labelText: 'Focus for next week'),
                  ),
                  const SizedBox(height: 12),
                  NButton(
                    'Save review',
                    expand: true,
                    onTap: () async {
                      await ref
                          .read(insightsRepoProvider)
                          .saveReview('weekly', ws, _worked.text, _didnt.text, _focus.text, ref.read(todayProvider));
                      if (context.mounted) showSnack(context, 'Review saved');
                    },
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class ReportScreen extends ConsumerStatefulWidget {
  const ReportScreen({super.key});

  @override
  ConsumerState<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends ConsumerState<ReportScreen> {
  int _offset = 0;

  @override
  Widget build(BuildContext context) {
    final t = DayKey.toDate(ref.watch(todayProvider));
    final first = DateTime.utc(t.year, t.month - _offset, 1);
    final from = DayKey.fromDate(first), to = monthEnd(from);
    final s = ref.watch(periodStatsProvider((from, to))).value;
    final days = [for (var d = from; d.compareTo(to) <= 0; d = DayKey.add(d, 1)) d];

    List<double> series(Map<String, int> m, List<String> keys) => [for (final k in keys) m[k]!.toDouble()];
    String corr(Map<String, int> a, Map<String, int> b, String na, String nb) {
      final keys = a.keys.where(b.containsKey).toList();
      return describeCorrelation(pearson(series(a, keys), series(b, keys)), na, nb);
    }

    final best = s == null
        ? const <MapEntry<String, int>>[]
        : (s.scoreByDay.entries.toList()..sort((a, b) => b.value.compareTo(a.value))).take(3);

    return Scaffold(
      appBar: _bar('Monthly report'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 40),
        children: [
          Row(
            children: [
              IconBtn(Icons.chevron_left_rounded, onTap: () => setState(() => _offset++)),
              Expanded(
                child: Text('${monShort[first.month - 1]} ${first.year}', textAlign: TextAlign.center, style: N.h2),
              ),
              IconBtn(Icons.chevron_right_rounded, onTap: () => setState(() => _offset = math.max(0, _offset - 1))),
            ],
          ),
          const SizedBox(height: N.gap),
          if (s != null) ...[
            _grid(_coreStats(s)),
            const SizedBox(height: N.gap),
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const CardHeader('Life Score by day'),
                  _Bars(values: [for (final d in days) (s.scoreByDay[d] ?? 0).toDouble()], max: 100, color: N.gold),
                  const SizedBox(height: 8),
                  if (best.isNotEmpty)
                    Text(
                      'Best days: ${best.map((e) => '${fmtDayKey(e.key)} (${e.value})').join(', ')}',
                      style: N.small,
                    ),
                ],
              ),
            ),
            const SizedBox(height: N.gap),
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const CardHeader('Spending by day'),
                  _Bars(values: [for (final d in days) (s.spentByDay[d] ?? 0) / 100], color: N.bad),
                ],
              ),
            ),
            const SizedBox(height: N.gap),
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const CardHeader('Sleep, mood & focus'),
                  _Bars(values: [for (final d in days) (s.sleepByDay[d] ?? 0) / 60], color: N.night, max: 10),
                  const SizedBox(height: 6),
                  Text('Hours slept per night', style: N.small.copyWith(fontSize: 12)),
                  const SizedBox(height: 12),
                  Text(corr(s.sleepByDay, s.moodByDay, 'sleep', 'a better mood'), style: N.small),
                  const SizedBox(height: 4),
                  Text(corr(s.sleepByDay, s.scoreByDay, 'sleep', 'a higher Life Score'), style: N.small),
                  if (s.avgMood != null) ...[
                    const SizedBox(height: 4),
                    Text('Average mood ${s.avgMood!.toStringAsFixed(1)} / 5', style: N.small),
                  ],
                ],
              ),
            ),
            const SizedBox(height: N.gap),
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const CardHeader('Habits'),
                  if (s.habitDays.isEmpty) const EmptyNote('No habits ticked this month.'),
                  for (final e in s.habitDays.entries)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              Expanded(child: Text(e.key)),
                              Text('${e.value}/${days.length}', style: N.num(12)),
                            ],
                          ),
                          const SizedBox(height: 4),
                          GoldBar(e.value / days.length, height: 4),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: N.gap),
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [const CardHeader('By profile'), _profileTable(ref, s)],
              ),
            ),
          ] else
            const Center(
              child: Padding(
                padding: EdgeInsets.all(40),
                child: CircularProgressIndicator(color: N.gold, strokeWidth: 2),
              ),
            ),
        ],
      ),
    );
  }
}

class _Bars extends StatelessWidget {
  const _Bars({required this.values, this.max, required this.color});
  final List<double> values;
  final double? max;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final m = max ?? values.fold<double>(0, math.max);
    return SizedBox(
      height: 90,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (final v in values)
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 1),
                height: m <= 0 ? 2 : math.max(2, 86 * (v / m).clamp(0, 1)),
                decoration: BoxDecoration(color: v == 0 ? N.line : color, borderRadius: BorderRadius.circular(2)),
              ),
            ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------- settings

class NudgeSettingsScreen extends ConsumerWidget {
  const NudgeSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(settingsProvider);
    final pool = ref.watch(questPoolProvider).value ?? const <Quest>[];
    final game = ref.read(gameRepoProvider);
    return Scaffold(
      appBar: _bar('Nudges & quests'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 40),
        children: [
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const CardHeader('Smart nudges'),
                Text('Each fires at most once a day and never during quiet hours (Me → Settings).', style: N.small),
                for (final e in nudgeTypes.entries)
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(e.value, style: const TextStyle(fontSize: 15)),
                    value: !s.nudgesOff.contains(e.key),
                    onChanged: (v) {
                      final off = {...s.nudgesOff};
                      v ? off.remove(e.key) : off.add(e.key);
                      ref.read(settingsRepoProvider).set('nudgesOff', off.toList());
                    },
                  ),
              ],
            ),
          ),
          const SizedBox(height: N.gap),
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                CardHeader(
                  'Quest pool',
                  trailing: GestureDetector(
                    onTap: () async {
                      final t = await askText(context, 'New quest', '');
                      if (t == null || t.trim().isEmpty || !context.mounted) return;
                      final xp = await askInt(context, 'XP (×5)', 3, 1, 10, fmt: (x) => '${x * 5} XP');
                      await game.addQuest(t, (xp ?? 3) * 5);
                    },
                    child: const Text(
                      '+ Add',
                      style: TextStyle(color: N.gold, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
                Text('3 are picked at random each day.', style: N.small),
                for (final q in pool)
                  Row(
                    children: [
                      Expanded(child: Text(q.title, style: const TextStyle(fontSize: 14))),
                      Text('+${q.xp}', style: N.num(12, color: N.gold)),
                      IconButton(
                        icon: const Icon(Icons.close_rounded, size: 18, color: N.muted),
                        onPressed: () => game.archiveQuest(q.id),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------- badges

final badgesProvider = FutureProvider<Set<String>>((ref) {
  final active = ref.watch(activeDaysProvider).value ?? const <String>{};
  final xp = ref.watch(xpTotalProvider).value ?? 0;
  return ref.read(gameRepoProvider).badges(activeDays: active, totalXp: xp);
});

class BadgesCard extends ConsumerWidget {
  const BadgesCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final got = ref.watch(badgesProvider).value ?? const <String>{};
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CardHeader(
            'Badges',
            trailing: Text('${got.length}/${badgeDefs.length}', style: N.num(12, color: N.muted)),
          ),
          GridView.count(
            crossAxisCount: 4,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: .8,
            children: [
              for (final b in badgeDefs)
                Tooltip(
                  message: b.hint,
                  child: Opacity(
                    opacity: got.contains(b.id) ? 1 : .3,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 46,
                          height: 46,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: got.contains(b.id) ? N.goldGradient : null,
                            color: got.contains(b.id) ? null : N.raise,
                          ),
                          child: Text(b.icon, style: const TextStyle(fontSize: 22)),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          b.title,
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: N.small.copyWith(fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
