import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/ai/ai_service.dart';
import '../../../core/db/app_db.dart';
import '../../../core/native/recorder.dart';
import '../../../core/providers.dart';
import '../../../core/settings/app_settings.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/theme/widgets.dart';
import '../../../core/time/format.dart';
import '../../meetings/ui/meetings_list.dart';
import '../data/notes_repo.dart';

/// Notes tab: Notes and Meetings.
class NotesHub extends ConsumerStatefulWidget {
  const NotesHub({super.key});

  @override
  ConsumerState<NotesHub> createState() => _NotesHubState();
}

class _NotesHubState extends ConsumerState<NotesHub> {
  bool _meetings = false;

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(settingsProvider);
    final showMeetings = s.on(Module.meetings);
    return ListView(
      padding: EdgeInsets.fromLTRB(16, 12, 16, 120 + MediaQuery.of(context).padding.bottom),
      children: [
        if (showMeetings)
          Padding(
            padding: const EdgeInsets.only(bottom: N.gap),
            child: Row(children: [
              Expanded(child: NChip('Notes', on: !_meetings, onTap: () => setState(() => _meetings = false))),
              const SizedBox(width: 6),
              Expanded(child: NChip('Meetings', on: _meetings, onTap: () => setState(() => _meetings = true))),
            ]),
          ),
        if (_meetings && showMeetings) const MeetingsList() else const _NotesList(),
      ],
    );
  }
}

class _NotesList extends ConsumerWidget {
  const _NotesList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notes = ref.watch(notesProvider).value ?? const <Note>[];
    final (q, t) = ref.watch(noteQueryProvider);
    final clock = ref.watch(clockProvider);
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      GlassCard(
        hero: true,
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          const CardHeader('New note'),
          Wrap(spacing: 6, runSpacing: 6, children: [
            for (final k in noteTemplates.keys) NChip('+ $k', on: false, onTap: () => context.push('/note/new?t=${Uri.encodeComponent(k)}')),
          ]),
          const SizedBox(height: 12),
          const VoiceNoteButton(),
        ]),
      ),
      const SizedBox(height: N.gap),
      TextField(
        decoration: const InputDecoration(hintText: 'Search notes, tags…', prefixIcon: Icon(Icons.search_rounded, color: N.muted)),
        onChanged: ref.read(noteQueryProvider.notifier).search,
      ),
      const SizedBox(height: 10),
      SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(children: [
          NChip('All', on: t == null, onTap: () => ref.read(noteQueryProvider.notifier).template(null)),
          for (final k in noteTemplates.keys) ...[
            const SizedBox(width: 6),
            NChip(k, on: t == k, onTap: () => ref.read(noteQueryProvider.notifier).template(k)),
          ],
        ]),
      ),
      const SizedBox(height: N.gap),
      if (notes.isEmpty)
        EmptyNote(q.isEmpty ? 'Pick a template above, or hold the mic to speak a note.' : 'No notes match "$q".'),
      for (final n in notes)
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: GlassCard(
            padding: const EdgeInsets.all(14),
            child: InkWell(
              onTap: () => context.push('/note/${n.id}'),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Text(n.template, style: N.small.copyWith(fontSize: 12, color: N.gold)),
                  if (n.pinned) const Padding(padding: EdgeInsets.only(left: 6), child: Icon(Icons.push_pin, size: 13, color: N.gold)),
                  const Spacer(),
                  Text(fmtDayKey(clock.calendarDateFor(n.updatedAtUtc)), style: N.small.copyWith(fontSize: 12)),
                ]),
                const SizedBox(height: 4),
                Text(n.title.isEmpty ? 'Untitled' : n.title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                if (n.body.trim().isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(n.body.trim(), maxLines: 2, overflow: TextOverflow.ellipsis, style: N.small),
                ],
                if (n.tags.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(n.tags.split(',').map((t) => '#$t').join(' '), style: N.small.copyWith(fontSize: 12, color: N.water)),
                ],
              ]),
            ),
          ),
        ),
    ]);
  }
}

/// Tap to start speaking, tap again to stop; Gemini turns it into a note.
class VoiceNoteButton extends ConsumerStatefulWidget {
  const VoiceNoteButton({super.key});

  @override
  ConsumerState<VoiceNoteButton> createState() => _VoiceNoteButtonState();
}

class _VoiceNoteButtonState extends ConsumerState<VoiceNoteButton> {
  bool _rec = false, _busy = false;

  Future<void> _toggle() async {
    if (_busy) return;
    if (!_rec) {
      if (!await ref.read(aiProvider).hasKey) {
        if (mounted) showSnack(context, 'Add your Gemini key in Me → AI (Gemini) to use voice notes.');
        return;
      }
      final dir = await Recorder.newDir('voice');
      final ok = await Recorder.start(dir, 'Voice note');
      if (!ok) {
        if (mounted) showSnack(context, 'Couldn\'t start the microphone. Allow it in app settings.');
        return;
      }
      Haptic.light();
      setState(() => _rec = true);
      return;
    }
    setState(() {
      _rec = false;
      _busy = true;
    });
    try {
      final parts = await Recorder.stop();
      if (parts.isEmpty) throw Exception('Nothing was recorded');
      final texts = <String>[];
      for (final f in parts) {
        texts.add(await ref.read(aiProvider).transcribe(File(f)));
      }
      final text = texts.join('\n\n');
      final first = text.split(RegExp(r'[.!?\n]')).first.trim();
      final id = await ref.read(notesRepoProvider).save(
            title: first.length > 60 ? '${first.substring(0, 57)}…' : first,
            body: text,
            template: 'Thought dump',
            tags: 'voice',
            day: ref.read(todayProvider),
          );
      for (final f in parts) {
        unawaited(File(f).delete().catchError((_) => File(f)));
      }
      if (mounted) context.push('/note/$id');
    } catch (e) {
      if (mounted) showSnack(context, 'Voice note failed: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => NButton(
        _busy ? 'Transcribing…' : (_rec ? 'Stop & save voice note' : 'Speak a note'),
        kind: _rec ? BtnKind.danger : BtnKind.raise,
        icon: _rec ? Icons.stop_rounded : Icons.mic_none_rounded,
        expand: true,
        onTap: _busy ? null : _toggle,
      );
}
