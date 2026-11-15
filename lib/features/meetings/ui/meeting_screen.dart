import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/ai/ai_service.dart';
import '../../../core/db/app_db.dart';
import '../../../core/providers.dart';
import '../../../core/theme/dialogs.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/theme/widgets.dart';
import '../../../core/time/format.dart';
import '../../mail/data/gmail_service.dart';
import '../../mail/domain/mail_merge.dart';
import '../data/meetings_repo.dart';
import 'meetings_list.dart';

class MeetingScreen extends ConsumerStatefulWidget {
  const MeetingScreen({super.key, required this.id});
  final int id;

  @override
  ConsumerState<MeetingScreen> createState() => _MeetingScreenState();
}

class _MeetingScreenState extends ConsumerState<MeetingScreen> {
  bool _busy = false, _showTranscript = false;

  Future<void> _do(Future<void> Function() job) async {
    setState(() => _busy = true);
    try {
      await job();
    } catch (e) {
      if (mounted) showSnack(context, '$e'.replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final m = ref.watch(meetingProvider(widget.id)).value;
    if (m == null) return const Scaffold(backgroundColor: N.bg);
    final mom = m.mom;
    final repo = ref.read(meetingsRepoProvider);
    final clock = ref.watch(clockProvider);

    Widget section(String title, List<String> items) => items.isEmpty
        ? const SizedBox.shrink()
        : Padding(
            padding: const EdgeInsets.only(top: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Eyebrow(title),
                const SizedBox(height: 6),
                for (final i in items)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text('•  $i', style: const TextStyle(fontSize: 14, height: 1.4)),
                  ),
              ],
            ),
          );

    return Scaffold(
      appBar: AppBar(
        backgroundColor: N.bg,
        surfaceTintColor: Colors.transparent,
        title: Text('Meeting', style: N.h2.copyWith(fontSize: 18)),
        actions: [
          if (mom != null)
            IconButton(
              tooltip: 'Share minutes',
              icon: const Icon(Icons.ios_share_rounded, color: N.muted),
              onPressed: () => SharePlus.instance.share(ShareParams(text: mom.toText())),
            ),
          IconButton(
            tooltip: 'Delete',
            icon: const Icon(Icons.delete_outline_rounded, color: N.muted),
            onPressed: () async {
              final ok = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: Text('Delete this meeting?', style: N.h2),
                  content: Text(
                    'The audio on this phone is deleted. The note and any Drive copy stay.',
                    style: N.small,
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: const Text('Cancel', style: TextStyle(color: N.muted)),
                    ),
                    NButton('Delete', kind: BtnKind.danger, onTap: () => Navigator.pop(ctx, true)),
                  ],
                ),
              );
              if (ok == true) {
                await repo.delete(m);
                if (context.mounted) Navigator.pop(context);
              }
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 40),
        children: [
          GlassCard(
            hero: true,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () async {
                          final v = await askText(context, 'Meeting title', m.title);
                          if (v != null && v.trim().isNotEmpty) await repo.rename(m.id, v);
                        },
                        child: Text(m.title, style: N.h1.copyWith(fontSize: 22)),
                      ),
                    ),
                    MeetingStatusPill(m),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${fmtDayKey(clock.calendarDateFor(m.startedAtUtc))}, ${fmtTime(clock, m.startedAtUtc)}',
                  style: N.small,
                ),
                if (m.status == 'error') ...[
                  const SizedBox(height: 10),
                  Text(m.error ?? 'Something went wrong', style: N.small.copyWith(color: N.bad)),
                  const SizedBox(height: 10),
                  NButton('Retry', icon: Icons.refresh_rounded, onTap: () => repo.process(m.id)),
                  const SizedBox(height: 6),
                  Text('The audio is kept on your phone until this works.', style: N.small.copyWith(fontSize: 12)),
                ],
                if (m.status == 'pending') ...[
                  const SizedBox(height: 10),
                  Text('Add your Gemini key (Me → AI) to turn this into minutes.', style: N.small),
                  const SizedBox(height: 10),
                  NButton(
                    'Write minutes now',
                    icon: Icons.auto_awesome_outlined,
                    onTap: () async {
                      if (!await ref.read(aiProvider).hasKey) {
                        if (context.mounted) showSnack(context, AiNotReady().toString());
                        return;
                      }
                      await repo.process(m.id);
                    },
                  ),
                ],
                if (m.busy) ...[
                  const SizedBox(height: 12),
                  LinearProgressIndicator(
                    value: m.status == 'transcribing' && m.paths.isNotEmpty ? m.chunks.length / m.paths.length : null,
                    color: N.gold,
                    backgroundColor: N.raise,
                  ),
                  const SizedBox(height: 6),
                  Text('You can leave this screen. It keeps working.', style: N.small.copyWith(fontSize: 12)),
                ],
              ],
            ),
          ),
          if (mom != null) ...[
            const SizedBox(height: N.gap),
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  CardHeader(
                    'Minutes',
                    trailing: GestureDetector(
                      onTap: () async {
                        final v = await askText(context, 'Attendees (comma separated)', mom.attendees.join(', '));
                        if (v == null) return;
                        await repo.saveMom(
                          m.id,
                          mom.copyWith(
                            attendees: v.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList(),
                          ),
                        );
                      },
                      child: const Text(
                        'Edit attendees',
                        style: TextStyle(color: N.gold, fontWeight: FontWeight.w600, fontSize: 13),
                      ),
                    ),
                  ),
                  if (mom.attendees.isNotEmpty) Text('With ${mom.attendees.join(', ')}', style: N.small),
                  if (mom.summary.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Text(mom.summary, style: const TextStyle(fontSize: 15, height: 1.5)),
                  ],
                  section('Key points', mom.keyPoints),
                  section('Decisions', mom.decisions),
                  section('Action items', [
                    for (final a in mom.actionItems)
                      '${a.task}${a.owner.isEmpty ? '' : ' — ${a.owner}'}${a.deadline == null ? '' : ' · by ${fmtDayKey(a.deadline!)}'}',
                  ]),
                  if (mom.followUpDate != null) section('Follow-up', [fmtDayKey(mom.followUpDate!)]),
                  const SizedBox(height: 14),
                  NButton(
                    m.actionsCreated ? 'Tasks & reminders created ✓' : 'Turn action items into tasks',
                    icon: Icons.playlist_add_check_rounded,
                    expand: true,
                    onTap: m.actionsCreated || _busy
                        ? null
                        : () => _do(() async {
                            final (t, f) = await repo.createActions(m, ref.read(clockProvider));
                            if (context.mounted) {
                              showSnack(context, 'Added $t tasks${f > 0 ? ' and a follow-up reminder' : ''}');
                            }
                          }),
                  ),
                ],
              ),
            ),
            const SizedBox(height: N.gap),
            _EmailCard(m: m, busy: _busy, run: _do),
          ],
          if (m.transcript.isNotEmpty) ...[
            const SizedBox(height: N.gap),
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  CardHeader(
                    'Transcript',
                    trailing: GestureDetector(
                      onTap: () => setState(() => _showTranscript = !_showTranscript),
                      child: Text(
                        _showTranscript ? 'Hide' : 'Show',
                        style: const TextStyle(color: N.gold, fontWeight: FontWeight.w600, fontSize: 13),
                      ),
                    ),
                  ),
                  if (_showTranscript) SelectableText(m.transcript, style: const TextStyle(fontSize: 14, height: 1.5)),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _EmailCard extends ConsumerStatefulWidget {
  const _EmailCard({required this.m, required this.busy, required this.run});
  final Meeting m;
  final bool busy;
  final Future<void> Function(Future<void> Function()) run;

  @override
  ConsumerState<_EmailCard> createState() => _EmailCardState();
}

class _EmailCardState extends ConsumerState<_EmailCard> {
  final _to = TextEditingController();
  late final _body = TextEditingController(text: widget.m.emailDraft ?? '');

  @override
  void dispose() {
    _to.dispose();
    _body.dispose();
    super.dispose();
  }

  (String, String) _split(String draft) {
    final lines = draft.trim().split('\n');
    if (lines.isNotEmpty && lines.first.toLowerCase().startsWith('subject:')) {
      return (lines.first.substring(8).trim(), lines.skip(1).join('\n').trim());
    }
    return ('Follow-up: ${widget.m.title}', draft.trim());
  }

  @override
  Widget build(BuildContext context) {
    final repo = ref.read(meetingsRepoProvider);
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const CardHeader('Follow-up e-mail'),
          if (_body.text.isEmpty)
            NButton(
              'Draft with AI',
              kind: BtnKind.raise,
              icon: Icons.auto_awesome_outlined,
              expand: true,
              onTap: widget.busy
                  ? null
                  : () => widget.run(() async {
                      _body.text = await repo.draftEmail(widget.m);
                      setState(() {});
                    }),
            )
          else ...[
            TextField(
              controller: _to,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(hintText: 'To: name@company.com'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _body,
              minLines: 6,
              maxLines: null,
              style: const TextStyle(fontSize: 14, height: 1.45),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                IconBtn(
                  Icons.copy_rounded,
                  label: 'Copy',
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: _body.text));
                    showSnack(context, 'Copied');
                  },
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: NButton(
                    'Send via Gmail',
                    icon: Icons.send_rounded,
                    onTap: widget.busy
                        ? null
                        : () => widget.run(() async {
                            if (!isEmail(_to.text)) throw Exception('Enter a valid e-mail address');
                            await repo.saveDraft(widget.m.id, _body.text);
                            final (subject, body) = _split(_body.text);
                            await ref
                                .read(gmailServiceProvider)
                                .send(to: _to.text.trim(), subject: subject, body: body);
                            if (context.mounted) showSnack(context, 'Sent ✓');
                          }),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
