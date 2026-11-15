import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/celebrate.dart';
import '../../../core/db/app_db.dart';
import '../../../core/native/native_bridge.dart';
import '../../../core/providers.dart';
import '../../../core/theme/dialogs.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/theme/widgets.dart';
import '../../profiles/data/profiles_repo.dart';
import '../data/focus_controller.dart';
import '../data/focus_repo.dart';
import '../domain/focus_logic.dart';

String fmtClockSecs(int s) {
  final h = s ~/ 3600, m = (s % 3600) ~/ 60, x = s % 60;
  final mm = m.toString().padLeft(2, '0'), ss = x.toString().padLeft(2, '0');
  return h > 0 ? '$h:$mm:$ss' : '$mm:$ss';
}

/// Build Hour, Pomodoro and work timer in one place.
class FocusScreen extends ConsumerStatefulWidget {
  const FocusScreen({super.key, this.initial = FocusKind.build});
  final FocusKind initial;

  @override
  ConsumerState<FocusScreen> createState() => _FocusScreenState();
}

class _FocusScreenState extends ConsumerState<FocusScreen> {
  late FocusKind _mode = widget.initial;
  int? _profile;
  int? _idea;

  @override
  Widget build(BuildContext context) {
    ref.watch(tickerProvider);
    final running = ref.watch(runningFocusProvider).value;
    final s = ref.watch(settingsProvider);
    final now = ref.watch(clockProvider).nowUtc();
    final mode = running?.focusKind ?? _mode;
    final elapsed = running?.elapsed(now) ?? 0;
    final profiles = ref.watch(profilesProvider).value ?? const <Profile>[];
    final ideas = ref.watch(ideasProvider).value ?? const <Idea>[];
    final buildToday = ref.watch(buildSecondsTodayProvider);
    final ctl = ref.read(focusControllerProvider);

    final (int goal, String sub) = switch (mode) {
      FocusKind.build => (
        3600,
        '${fmtHours(buildToday)} of 1h today${ref.watch(buildStreakProvider) > 0 ? ' · ${ref.watch(buildStreakProvider)}-day streak' : ''}',
      ),
      FocusKind.pomodoro => (s.pomoWork * 60, '${s.pomoWork} min focus · ${s.pomoBreak} min break'),
      _ => (0, 'Counts towards retainer hours for the profile'),
    };
    final shown = mode == FocusKind.build && running == null ? buildToday : elapsed;
    final progress = goal == 0 ? null : (mode == FocusKind.build ? buildToday / goal : elapsed / goal);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: N.bg,
        surfaceTintColor: Colors.transparent,
        title: Text('Focus', style: N.h2.copyWith(fontSize: 18)),
        actions: [
          TextButton(
            onPressed: () => context.push('/time'),
            child: const Text(
              'Time log',
              style: TextStyle(color: N.gold, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 40),
        children: [
          if (running == null)
            Row(
              children: [
                for (final k in [FocusKind.build, FocusKind.pomodoro, FocusKind.work]) ...[
                  if (k != FocusKind.build) const SizedBox(width: 6),
                  Expanded(
                    child: NChip(k.label, on: _mode == k, onTap: () => setState(() => _mode = k)),
                  ),
                ],
              ],
            ),
          const SizedBox(height: 18),
          GlassCard(
            hero: true,
            child: Column(
              children: [
                Eyebrow(running == null ? mode.label : (running.paused ? '${mode.label} · paused' : mode.label)),
                const SizedBox(height: 16),
                SizedBox(
                  width: 220,
                  height: 220,
                  child: CustomPaint(
                    painter: _TimerRing(progress?.clamp(0.0, 1.0)),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(fmtClockSecs(shown), style: N.num(40)),
                          if (mode == FocusKind.pomodoro && running != null)
                            Text('${fmtClockSecs(math.max(0, goal - elapsed))} left', style: N.small),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Text(sub, textAlign: TextAlign.center, style: N.small),
                const SizedBox(height: 18),
                if (running == null)
                  NButton(
                    'Start ${mode.label}',
                    icon: Icons.play_arrow_rounded,
                    expand: true,
                    onTap: () async {
                      await ctl.start(mode, profileId: mode == FocusKind.build ? null : _profile, ideaId: _idea);
                    },
                  )
                else
                  Row(
                    children: [
                      Expanded(
                        child: NButton(
                          running.paused ? 'Resume' : 'Pause',
                          kind: BtnKind.raise,
                          icon: running.paused ? Icons.play_arrow_rounded : Icons.pause_rounded,
                          onTap: () => running.paused ? ctl.resume() : ctl.pause(),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: NButton('Stop & log', icon: Icons.stop_rounded, onTap: () => _stop(context, running)),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          const SizedBox(height: N.gap),
          if (mode == FocusKind.build)
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  CardHeader(
                    'Ideas',
                    trailing: GestureDetector(
                      onTap: () async {
                        final v = await askText(context, 'New AI product idea', '');
                        if (v != null && v.trim().isNotEmpty) await ref.read(focusRepoProvider).addIdea(v);
                      },
                      child: const Text(
                        '+ Add',
                        style: TextStyle(color: N.gold, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                  if (ideas.isEmpty) const EmptyNote('Add the AI product ideas you want to build.'),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      for (final i in ideas)
                        GestureDetector(
                          onLongPress: () => ref.read(focusRepoProvider).archiveIdea(i.id),
                          child: NChip(
                            i.title,
                            on: (running?.ideaId ?? _idea) == i.id,
                            onTap: () => setState(() => _idea = _idea == i.id ? null : i.id),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Pick what you\'re working on. Long-press an idea to archive it.',
                    style: N.small.copyWith(fontSize: 12),
                  ),
                ],
              ),
            )
          else
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const CardHeader('Work profile'),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      NChip(
                        'None',
                        on: (running?.profileId ?? _profile) == null,
                        onTap: () => setState(() => _profile = null),
                      ),
                      for (final p in profiles)
                        NChip(
                          p.name,
                          on: (running?.profileId ?? _profile) == p.id,
                          color: Color(p.color),
                          onTap: () => setState(() => _profile = p.id),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          const SizedBox(height: N.gap),
          GlassCard(
            padding: const EdgeInsets.fromLTRB(18, 10, 18, 10),
            child: Column(
              children: [
                _toggle(
                  '20-20-20 eye breaks',
                  'A nudge every 20 minutes of focus',
                  s.eyeBreaks,
                  (v) => ref.read(settingsRepoProvider).set('eyeBreaks', v),
                ),
                _toggle(
                  'Do Not Disturb during Pomodoro',
                  'Silences calls & notifications while a Pomodoro runs',
                  s.focusDnd,
                  (v) async {
                    if (v && !await NativeBridge.hasDndAccess()) {
                      await NativeBridge.requestDndAccess();
                      if (context.mounted) {
                        showSnack(context, 'Allow Solo Leveling under Do Not Disturb access, then switch this on.');
                      }
                      return;
                    }
                    await ref.read(settingsRepoProvider).set('focusDnd', v);
                  },
                ),
                InkWell(
                  onTap: () async {
                    final w = await askInt(context, 'Pomodoro focus minutes', s.pomoWork, 10, 90);
                    if (w == null || !context.mounted) return;
                    final b = await askInt(context, 'Break minutes', s.pomoBreak, 1, 30);
                    await ref.read(settingsRepoProvider).set('pomoWork', w);
                    if (b != null) await ref.read(settingsRepoProvider).set('pomoBreak', b);
                  },
                  child: SizedBox(
                    height: 52,
                    child: Row(
                      children: [
                        const Expanded(child: Text('Pomodoro length', style: TextStyle(fontSize: 15))),
                        Text(
                          '${s.pomoWork} / ${s.pomoBreak} min',
                          style: const TextStyle(color: N.gold, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _toggle(String title, String sub, bool v, ValueChanged<bool> on) => Row(
    children: [
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 15)),
            Text(sub, style: N.small.copyWith(fontSize: 12)),
          ],
        ),
      ),
      Switch(value: v, onChanged: on),
    ],
  );

  Future<void> _stop(BuildContext context, FocusSession running) async {
    final note = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          running.focusKind == FocusKind.build ? 'What did you build?' : 'What did you work on?',
          style: N.h2,
        ),
        content: TextField(
          controller: note,
          autofocus: true,
          maxLines: 3,
          decoration: const InputDecoration(hintText: 'One line is enough'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Keep going', style: TextStyle(color: N.muted)),
          ),
          NButton('Stop & log', onTap: () => Navigator.pop(ctx, true)),
        ],
      ),
    );
    if (ok != true) return;
    final before = ref.read(buildSecondsTodayProvider);
    final done = await ref.read(focusControllerProvider).stop(note: note.text.trim());
    if (done == null || !context.mounted) return;
    if (done.focusKind == FocusKind.build && before >= 3600 && before - done.seconds < 3600) {
      ref.read(celebratorProvider).celebrate('Build Hour done 🚀');
    } else {
      showSnack(context, 'Logged ${fmtHours(done.seconds)} of ${done.focusKind.label}');
    }
  }
}

class _TimerRing extends CustomPainter {
  _TimerRing(this.v);
  final double? v;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final r = rect.deflate(6);
    canvas.drawArc(
      r,
      0,
      math.pi * 2,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 10
        ..color = const Color(0x12FFFFFF),
    );
    if (v == null || v! <= 0) return;
    canvas.drawArc(
      r,
      -math.pi / 2,
      math.pi * 2 * v!,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 10
        ..strokeCap = StrokeCap.round
        ..shader = const SweepGradient(
          colors: [N.goldLo, N.gold, N.goldHi],
          transform: GradientRotation(-math.pi / 2),
        ).createShader(rect),
    );
  }

  @override
  bool shouldRepaint(_TimerRing o) => o.v != v;
}
