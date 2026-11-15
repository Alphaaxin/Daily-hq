import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/notifications/reminder_sync.dart';
import '../../../core/providers.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/theme/widgets.dart';
import '../../../core/time/format.dart';
import '../../google/data/google_jobs.dart';
import '../data/sleep_repo.dart';
import '../domain/sleep_logic.dart';

/// Good Night / Good Morning row inside the hero card.
class SleepPanel extends ConsumerWidget {
  const SleepPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(tickerProvider);
    final latest = ref.watch(latestSleepProvider).value;
    final clock = ref.watch(clockProvider);
    final s = ref.watch(settingsProvider);
    final now = clock.nowUtc();
    final slept = ref.watch(todaySleepProvider);
    final asleep = latest != null && latest.asleep;
    final since = asleep ? latest.sleptAtUtc : latest?.wokeAtUtc;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Eyebrow(
                    asleep
                        ? 'Asleep since ${fmtTime(clock, since!)}'
                        : since != null
                        ? 'Awake since ${fmtTime(clock, since)}'
                        : 'Sleep not logged yet',
                  ),
                  const SizedBox(height: 2),
                  Text(since == null ? '—' : fmtDuration(now.difference(since)), style: N.num(22)),
                ],
              ),
            ),
            asleep
                ? NButton('Good Morning', icon: Icons.wb_sunny_rounded, onTap: () => goodMorning(context, ref))
                : NButton(
                    'Good Night',
                    kind: BtnKind.night,
                    icon: Icons.nightlight_round,
                    onTap: () => goodNight(context, ref),
                  ),
          ],
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            if (slept != null)
              Pill(
                'Slept ${fmtDuration(slept)} / ${_h(s.sleepTargetHours)}',
                color: slept.inMinutes >= s.sleepTargetHours * 60 ? N.good : N.warn,
              ),
            if (!asleep)
              GestureDetector(
                onTap: () => showLogSleepSheet(context),
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 6),
                  child: Text(
                    'Forgot to tap? Log sleep',
                    style: TextStyle(color: N.gold, fontWeight: FontWeight.w600, fontSize: 13),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  static String _h(double h) => '${h % 1 == 0 ? h.toInt() : h}h';
}

Future<void> goodNight(BuildContext context, WidgetRef ref) async {
  await ref.read(sleepRepoProvider).goodNight(ref.read(clockProvider));
  ref.read(reminderSyncProvider).schedule();
  unawaited(ref.read(googleJobsProvider).backupAfterGoodNight());
  if (context.mounted) showSnack(context, 'Good night 🌙 Reminders are paused until you wake.');
}

Future<void> goodMorning(BuildContext context, WidgetRef ref) async {
  final s = ref.read(settingsProvider);
  final done = await ref.read(sleepRepoProvider).goodMorning(ref.read(clockProvider), s.sleepTargetHours);
  ref.read(reminderSyncProvider).schedule();
  if (done != null && context.mounted) {
    final d = done.span.duration!;
    final ok = d.inMinutes >= s.sleepTargetHours * 60;
    showSnack(context, 'Good morning ☀️ You slept ${fmtDuration(d)}${ok ? ': target hit!' : ''}');
  }
}

/// "What time did you sleep / wake?"
Future<void> showLogSleepSheet(BuildContext context, {bool wakeOnly = false}) =>
    showNSheet(context, (ctx) => _LogSleepSheet(wakeOnly: wakeOnly));

class _LogSleepSheet extends ConsumerStatefulWidget {
  const _LogSleepSheet({required this.wakeOnly});
  final bool wakeOnly;

  @override
  ConsumerState<_LogSleepSheet> createState() => _LogSleepSheetState();
}

class _LogSleepSheetState extends ConsumerState<_LogSleepSheet> {
  late TimeOfDay _sleep;
  late TimeOfDay _wake;

  @override
  void initState() {
    super.initState();
    final clock = ref.read(clockProvider);
    final latest = ref.read(latestSleepProvider).value;
    if (latest != null && latest.asleep) {
      final l = clock.toLocal(latest.sleptAtUtc);
      _sleep = TimeOfDay(hour: l.hour, minute: l.minute);
    } else {
      _sleep = const TimeOfDay(hour: 5, minute: 30);
    }
    final n = clock.toLocal(clock.nowUtc());
    _wake = TimeOfDay(hour: n.hour, minute: n.minute);
  }

  Future<void> _pick(bool sleep) async {
    final t = await showTimePicker(context: context, initialTime: sleep ? _sleep : _wake);
    if (t != null) setState(() => sleep ? _sleep = t : _wake = t);
  }

  @override
  Widget build(BuildContext context) {
    final clock = ref.watch(clockProvider);
    final span = manualSpan(clock, _sleep.hour, _sleep.minute, _wake.hour, _wake.minute);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('What time did you sleep / wake?', style: N.h2.copyWith(fontSize: 18)),
        const SizedBox(height: 4),
        Text('No stress. Log it now and keep your streak honest.', style: N.small),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _TimeBox(label: 'Slept at', t: _sleep, onTap: () => _pick(true)),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _TimeBox(label: 'Woke at', t: _wake, onTap: () => _pick(false)),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Center(
          child: Text('= ${fmtDuration(span.duration!)} of sleep', style: N.num(15, color: N.muted)),
        ),
        const SizedBox(height: 16),
        NButton(
          'Save sleep',
          expand: true,
          onTap: () async {
            await ref.read(sleepRepoProvider).logManual(clock, span, ref.read(settingsProvider).sleepTargetHours);
            ref.read(reminderSyncProvider).schedule();
            if (context.mounted) Navigator.pop(context);
          },
        ),
      ],
    );
  }
}

class _TimeBox extends StatelessWidget {
  const _TimeBox({required this.label, required this.t, required this.onTap});
  final String label;
  final TimeOfDay t;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
    color: N.raise,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(14),
      side: const BorderSide(color: N.line),
    ),
    child: InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Eyebrow(label),
            const SizedBox(height: 4),
            Text(fmtClock(t.hour * 60 + t.minute), style: N.num(20)),
          ],
        ),
      ),
    ),
  );
}
