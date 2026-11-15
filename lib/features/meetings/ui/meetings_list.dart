import 'dart:async';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:path/path.dart' as p;

import '../../../core/ai/ai_service.dart';
import '../../../core/db/app_db.dart';
import '../../../core/native/recorder.dart';
import '../../../core/providers.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/theme/widgets.dart';
import '../../../core/time/format.dart';
import '../../sleep/domain/sleep_logic.dart';
import '../data/meetings_repo.dart';

/// Live recorder state, refreshed every tick.
final recorderStatusProvider = FutureProvider<RecorderStatus>((ref) {
  ref.watch(tickerProvider);
  return Recorder.status();
});

/// Starts / stops a meeting recording and queues it for processing.
class MeetingRecorder {
  MeetingRecorder(this.ref);
  final Ref ref;

  Future<String?> start({String title = 'Meeting'}) async {
    final dir = await Recorder.newDir('meetings');
    final ok = await Recorder.start(dir, title);
    ref.invalidate(recorderStatusProvider);
    return ok ? null : 'Couldn\'t start the microphone. Allow it in Settings → Apps → Solo Leveling → Permissions.';
  }

  Future<int?> stop() async {
    final st = await Recorder.status();
    final parts = await Recorder.stop();
    ref.invalidate(recorderStatusProvider);
    if (parts.isEmpty) return null;
    final started = st.startedAt ?? DateTime.now().toUtc();
    final id = await ref
        .read(meetingsRepoProvider)
        .create(
          title: 'Meeting',
          paths: parts,
          startedAtUtc: started,
          durationSec: DateTime.now().toUtc().difference(started).inSeconds,
        );
    if (await ref.read(aiProvider).hasKey) unawaited(ref.read(meetingsRepoProvider).process(id));
    return id;
  }

  /// Import an existing recording (WhatsApp voice note, call recorder file…).
  Future<int?> upload() async {
    final res = await FilePicker.pickFiles(type: FileType.audio);
    final path = res?.files.single.path;
    if (path == null) return null;
    final dir = await Recorder.newDir('meetings');
    final copy = await File(path).copy(p.join(dir.path, p.basename(path)));
    final id = await ref
        .read(meetingsRepoProvider)
        .create(
          title: p.basenameWithoutExtension(path),
          paths: [copy.path],
          startedAtUtc: (await copy.lastModified()).toUtc(),
        );
    if (await ref.read(aiProvider).hasKey) unawaited(ref.read(meetingsRepoProvider).process(id));
    return id;
  }
}

final meetingRecorderProvider = Provider((ref) => MeetingRecorder(ref));

class MeetingsList extends ConsumerWidget {
  const MeetingsList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final meetings = ref.watch(meetingsProvider).value ?? const <Meeting>[];
    final clock = ref.watch(clockProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const RecordCard(),
        const SizedBox(height: N.gap),
        if (meetings.isEmpty) const EmptyNote('Recorded and uploaded meetings appear here with their minutes.'),
        for (final m in meetings)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: GlassCard(
              padding: const EdgeInsets.all(14),
              child: InkWell(
                onTap: () => context.push('/meeting/${m.id}'),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(m.title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                          const SizedBox(height: 2),
                          Text(
                            '${fmtDayKey(clock.calendarDateFor(m.startedAtUtc))}, ${fmtTime(clock, m.startedAtUtc)}'
                            '${m.durationSec > 0 ? ' · ${fmtDuration(Duration(seconds: m.durationSec))}' : ''}',
                            style: N.small.copyWith(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    MeetingStatusPill(m),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class MeetingStatusPill extends StatelessWidget {
  const MeetingStatusPill(this.m, {super.key});
  final Meeting m;

  @override
  Widget build(BuildContext context) => switch (m.status) {
    'done' => const Pill('Minutes ready', color: N.good),
    'error' => const Pill('Failed · retry', color: N.bad),
    'transcribing' => Pill('Transcribing ${m.chunks.length + 1}/${m.paths.length}', hot: true),
    'summarizing' => const Pill('Writing minutes…', hot: true),
    _ => const Pill('Waiting for AI'),
  };
}

class RecordCard extends ConsumerWidget {
  const RecordCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final st = ref.watch(recorderStatusProvider).value ?? const RecorderStatus();
    final now = DateTime.now().toUtc();
    final rec = ref.read(meetingRecorderProvider);
    return GlassCard(
      hero: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: st.recording ? N.bad : N.muted.withValues(alpha: .4),
                ),
              ),
              const SizedBox(width: 10),
              Text(st.recording ? 'Recording' : 'Meeting recorder', style: N.h2),
              const Spacer(),
              if (st.recording && st.startedAt != null)
                Text(fmtDuration(now.difference(st.startedAt!)), style: N.num(18, color: N.bad)),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            st.recording
                ? 'Keeps recording with the screen off. Tap stop when the meeting ends.'
                : 'Let everyone know you\'re recording before you start.',
            style: N.small,
          ),
          const SizedBox(height: 14),
          if (st.recording)
            NButton(
              'Stop & write minutes',
              kind: BtnKind.danger,
              icon: Icons.stop_rounded,
              expand: true,
              onTap: () async {
                final id = await rec.stop();
                if (id != null && context.mounted) context.push('/meeting/$id');
              },
            )
          else
            Row(
              children: [
                Expanded(
                  child: NButton(
                    'Record',
                    icon: Icons.fiber_manual_record_rounded,
                    onTap: () async {
                      final err = await rec.start();
                      if (err != null && context.mounted) showSnack(context, err);
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: NButton(
                    'Upload audio',
                    kind: BtnKind.raise,
                    icon: Icons.upload_file_rounded,
                    onTap: () async {
                      final id = await rec.upload();
                      if (id != null && context.mounted) context.push('/meeting/$id');
                    },
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
