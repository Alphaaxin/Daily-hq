import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart' show Value;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/ai/ai_service.dart';
import '../../../core/db/app_db.dart';
import '../../../core/providers.dart';
import '../../../core/theme/dialogs.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/theme/widgets.dart';
import '../../../core/time/day_clock.dart';
import '../../../core/time/format.dart';
import '../../google/data/google_auth.dart';
import '../../people/data/contacts_repo.dart';
import '../../tasks/ui/task_widgets.dart' show fmtTimeOfDay;
import '../data/mail_sender.dart';
import '../domain/mail_merge.dart';

class MailScreen extends ConsumerWidget {
  const MailScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(settingsProvider);
    final templates = ref.watch(templatesProvider).value ?? const <MailTemplate>[];
    final campaigns = ref.watch(campaignsProvider).value ?? const <CampaignStats>[];
    final clock = ref.watch(clockProvider);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: N.bg,
        surfaceTintColor: Colors.transparent,
        title: Text('Mail merge', style: N.h2.copyWith(fontSize: 18)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 40),
        children: [
          if (s.googleEmail.isEmpty || !s.gmailGranted)
            Padding(
              padding: const EdgeInsets.only(bottom: N.gap),
              child: GlassCard(
                hero: true,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const CardHeader('Connect Gmail'),
                    Text(
                      s.googleEmail.isEmpty
                          ? 'Sign in to Google first (Me → Google account & backup).'
                          : 'Allow sending from ${s.googleEmail}. Solo Leveling can only send, never read your mail.',
                      style: N.small,
                    ),
                    if (s.googleEmail.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      NButton(
                        'Allow Gmail sending',
                        icon: Icons.mark_email_read_outlined,
                        expand: true,
                        onTap: () async {
                          try {
                            await ref.read(googleAuthProvider).authorizeGmail();
                          } catch (e) {
                            if (context.mounted) showSnack(context, 'Gmail: $e');
                          }
                        },
                      ),
                    ],
                  ],
                ),
              ),
            ),
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                CardHeader(
                  'Templates',
                  trailing: GestureDetector(
                    onTap: () => showNSheet(context, (_) => const _TemplateSheet()),
                    child: const Text(
                      '+ New',
                      style: TextStyle(color: N.gold, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
                if (templates.isEmpty) const EmptyNote('Create a template with {{name}}, {{business}}… placeholders.'),
                for (final t in templates)
                  InkWell(
                    onTap: () => showNSheet(context, (_) => _TemplateSheet(t: t)),
                    child: Container(
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
                                Text(t.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                                Text(
                                  t.subject,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: N.small.copyWith(fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                          NButton(
                            'Use',
                            kind: BtnKind.raise,
                            onTap: () => Navigator.of(
                              context,
                            ).push(MaterialPageRoute<void>(builder: (_) => ComposeScreen(template: t))),
                          ),
                        ],
                      ),
                    ),
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
                  'Campaigns',
                  trailing: Text('Limit ${s.mailDailyLimit}/day', style: N.small.copyWith(fontSize: 12)),
                ),
                if (campaigns.isEmpty) const EmptyNote('Nothing sent yet.'),
                for (final c in campaigns)
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: const BoxDecoration(
                      border: Border(top: BorderSide(color: N.line)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(c.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                            ),
                            Text('${c.sent}/${c.total} sent', style: N.num(12, color: N.muted)),
                          ],
                        ),
                        const SizedBox(height: 6),
                        GoldBar(c.total == 0 ? 0 : c.sent / c.total, height: 5),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                [
                                  if (c.queued > 0)
                                    '${c.queued} queued${c.next != null && c.next!.isAfter(DateTime.now().toUtc()) ? ' · starts ${fmtDayKey(clock.calendarDateFor(c.next!))} ${fmtTime(clock, c.next!)}' : ''}',
                                  if (c.failed > 0) '${c.failed} failed',
                                  if (c.cancelled > 0) '${c.cancelled} cancelled',
                                ].join(' · '),
                                style: N.small.copyWith(fontSize: 12, color: c.failed > 0 ? N.warn : N.muted),
                              ),
                            ),
                            if (c.queued > 0)
                              TextButton(
                                onPressed: () => ref.read(mailSenderProvider).run(),
                                child: const Text('Send now', style: TextStyle(color: N.gold)),
                              ),
                            if (c.queued > 0)
                              TextButton(
                                onPressed: () => ref.read(mailSenderProvider).cancel(c.name),
                                child: const Text('Cancel', style: TextStyle(color: N.muted)),
                              ),
                            if (c.failed > 0)
                              TextButton(
                                onPressed: () => ref.read(mailSenderProvider).retryFailed(c.name),
                                child: const Text('Retry', style: TextStyle(color: N.gold)),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 6),
                Text(
                  'E-mails go out one at a time, 25–45 s apart, from your own Gmail. Leads become "Contacted" and '
                  'you get a reminder 3 days later if they haven\'t replied.',
                  style: N.small.copyWith(fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TemplateSheet extends ConsumerStatefulWidget {
  const _TemplateSheet({this.t});
  final MailTemplate? t;

  @override
  ConsumerState<_TemplateSheet> createState() => _TemplateSheetState();
}

class _TemplateSheetState extends ConsumerState<_TemplateSheet> {
  late final _name = TextEditingController(text: widget.t?.name ?? '');
  late final _subject = TextEditingController(text: widget.t?.subject ?? '');
  late final _body = TextEditingController(text: widget.t?.body ?? 'Hi {{name|there}},\n\n');
  bool _busy = false;

  Future<void> _ai() async {
    final goal = await askText(context, 'What is this e-mail for? (e.g. offer SEO to dental clinics)', '');
    if (goal == null || goal.trim().isEmpty) return;
    setState(() => _busy = true);
    try {
      final j = await ref.read(aiProvider).json(
        'Write a short cold outreach e-mail template for: $goal. Use placeholders {{name|there}} and {{business}} '
        'where natural. Friendly, specific, under 120 words, one clear call to action. '
        'Sign as ${ref.read(settingsProvider).mailSignature}.',
        {
          'type': 'OBJECT',
          'properties': {
            'subject': {'type': 'STRING'},
            'body': {'type': 'STRING'},
          },
          'required': ['subject', 'body'],
        },
        system: aiStyle,
      );
      _subject.text = '${j['subject']}';
      _body.text = '${j['body']}';
      if (_name.text.trim().isEmpty) _name.text = goal.length > 40 ? goal.substring(0, 40) : goal;
    } catch (e) {
      if (mounted) showSnack(context, '$e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ph = placeholders('${_subject.text} ${_body.text}');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(widget.t == null ? 'New template' : 'Edit template', style: N.h2.copyWith(fontSize: 18)),
        const SizedBox(height: 12),
        TextField(
          controller: _name,
          decoration: const InputDecoration(labelText: 'Template name'),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _subject,
          decoration: const InputDecoration(labelText: 'Subject'),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 8),
        TextField(controller: _body, minLines: 8, maxLines: null, onChanged: (_) => setState(() {})),
        const SizedBox(height: 6),
        Text(
          ph.isEmpty
              ? 'Tip: {{name}}, {{business}}, {{college}}… are filled per person. {{name|there}} has a fallback.'
              : 'Placeholders: ${ph.map((p) => '{{$p}}').join(' ')}',
          style: N.small.copyWith(fontSize: 12),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: NButton(
                _busy ? 'Writing…' : 'Draft with AI',
                kind: BtnKind.raise,
                icon: Icons.auto_awesome_outlined,
                onTap: _busy ? null : _ai,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: NButton(
                'Save',
                onTap: () async {
                  if (_name.text.trim().isEmpty) return;
                  final db = ref.read(dbProvider);
                  final c = MailTemplatesCompanion(
                    name: Value(_name.text.trim()),
                    subject: Value(_subject.text),
                    body: Value(_body.text),
                    updatedAtUtc: Value(DateTime.now().toUtc()),
                  );
                  if (widget.t == null) {
                    await db.into(db.mailTemplates).insert(c);
                  } else {
                    await (db.update(db.mailTemplates)..where((x) => x.id.equals(widget.t!.id))).write(c);
                  }
                  if (context.mounted) Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Pick recipients, preview every e-mail, then send now or schedule.
class ComposeScreen extends ConsumerStatefulWidget {
  const ComposeScreen({super.key, required this.template});
  final MailTemplate template;

  @override
  ConsumerState<ComposeScreen> createState() => _ComposeScreenState();
}

class _ComposeScreenState extends ConsumerState<ComposeScreen> {
  String _source = 'leads';
  String _stage = 'new';
  List<Recipient> _csv = const [];
  final _excluded = <String>{};
  DateTime? _at;

  List<Recipient> _recipients() {
    switch (_source) {
      case 'people':
        return [
          for (final p in ref.watch(peopleProvider).value ?? const <PeopleData>[])
            if (isEmail(p.email)) Recipient(email: p.email, name: p.name, personId: p.id),
        ];
      case 'csv':
        return _csv;
      default:
        return [
          for (final l in ref.watch(leadsProvider).value ?? const <Lead>[])
            if (isEmail(l.email) && (_stage == 'all' || l.stage == _stage))
              Recipient(
                email: l.email,
                name: l.name,
                leadId: l.id,
                vars: {'business': l.business.isEmpty ? l.name : l.business, 'location': l.location},
              ),
        ];
    }
  }

  Future<void> _importCsv() async {
    final res = await FilePicker.pickFiles(type: FileType.custom, allowedExtensions: ['csv']);
    final path = res?.files.single.path;
    if (path == null) return;
    final rows = parseCsv(utf8.decode(await File(path).readAsBytes(), allowMalformed: true));
    setState(() {
      _csv = [
        for (final r in rows)
          if (isEmail(r['email'] ?? ''))
            Recipient(email: r['email']!, name: r['name'] ?? '', vars: Map.of(r)..remove('email')),
      ];
      _source = 'csv';
    });
    if (mounted) showSnack(context, '${_csv.length} recipients with valid e-mails');
  }

  Future<void> _send() async {
    final to = _recipients().where((r) => !_excluded.contains(r.email)).toList();
    if (to.isEmpty) return;
    final s = ref.read(settingsProvider);
    if (!s.gmailGranted) {
      showSnack(context, 'Allow Gmail sending first (top of Mail merge).');
      return;
    }
    final name = '${widget.template.name} · ${fmtDayKey(ref.read(todayProvider))}';
    final n = await ref
        .read(mailSenderProvider)
        .queue(campaign: name, subject: widget.template.subject, body: widget.template.body, to: to, atUtc: _at);
    if (mounted) {
      showSnack(context, _at == null ? 'Sending $n e-mails, one every ~35 s' : 'Scheduled $n e-mails');
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final all = _recipients();
    final to = all.where((r) => !_excluded.contains(r.email)).toList();
    final clock = ref.watch(clockProvider);
    final s = ref.watch(settingsProvider);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: N.bg,
        surfaceTintColor: Colors.transparent,
        title: Text(widget.template.name, style: N.h2.copyWith(fontSize: 16)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 40),
        children: [
          const Eyebrow('Recipients'),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              NChip('Leads', on: _source == 'leads', onTap: () => setState(() => _source = 'leads')),
              NChip('People', on: _source == 'people', onTap: () => setState(() => _source = 'people')),
              NChip(_csv.isEmpty ? 'Import CSV' : 'CSV (${_csv.length})', on: _source == 'csv', onTap: _importCsv),
            ],
          ),
          if (_source == 'leads') ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final st in ['new', 'contacted', 'replied', 'interested', 'all'])
                  NChip(
                    st == 'all' ? 'All stages' : leadStageLabels[st]!,
                    on: _stage == st,
                    onTap: () => setState(() => _stage = st),
                  ),
              ],
            ),
          ],
          if (_source == 'csv')
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'CSV needs an "email" column; "name" and any other columns become {{placeholders}}.',
                style: N.small.copyWith(fontSize: 12),
              ),
            ),
          const SizedBox(height: N.gap),
          Text('${to.length} e-mails · tap one to skip it', style: N.h2),
          if (to.length > s.mailDailyLimit)
            Text(
              'Over today\'s limit of ${s.mailDailyLimit}: the rest go out tomorrow.',
              style: N.small.copyWith(color: N.warn),
            ),
          const SizedBox(height: 8),
          if (all.isEmpty) const EmptyNote('No recipients with a valid e-mail here.'),
          for (final r in all.take(200))
            () {
              final subj = render(widget.template.subject, r.values);
              final body = render(widget.template.body, r.values);
              final missing = {...subj.missing, ...body.missing};
              final skip = _excluded.contains(r.email);
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Opacity(
                  opacity: skip ? .4 : 1,
                  child: GlassCard(
                    padding: const EdgeInsets.all(12),
                    child: InkWell(
                      onTap: () => setState(() => skip ? _excluded.remove(r.email) : _excluded.add(r.email)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  '${r.name.isEmpty ? r.email : r.name} · ${r.email}',
                                  style: N.small.copyWith(fontSize: 12),
                                ),
                              ),
                              if (skip) const Pill('skipped'),
                              if (missing.isNotEmpty && !skip) Pill('missing ${missing.join(', ')}', color: N.warn),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(subj.text, style: const TextStyle(fontWeight: FontWeight.w700)),
                          const SizedBox(height: 4),
                          Text(body.text, maxLines: 4, overflow: TextOverflow.ellipsis, style: N.small),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }(),
          const SizedBox(height: N.gap),
          Row(
            children: [
              Expanded(
                child: NButton(
                  _at == null ? 'Schedule…' : '${fmtDayKey(clock.calendarDateFor(_at!))} ${fmtTime(clock, _at!)}',
                  kind: BtnKind.raise,
                  icon: Icons.schedule_rounded,
                  onTap: () async {
                    final today = ref.read(todayProvider);
                    final d = await showDatePicker(
                      context: context,
                      initialDate: DayKey.toDate(today),
                      firstDate: DayKey.toDate(today),
                      lastDate: DayKey.toDate(today).add(const Duration(days: 60)),
                    );
                    if (d == null || !context.mounted) return;
                    final t = await showTimePicker(
                      context: context,
                      initialTime: const TimeOfDay(hour: 10, minute: 30),
                    );
                    if (t == null) return;
                    setState(() => _at = clock.localToUtc(DayKey.fromDate(d), t.hour, t.minute));
                    if (context.mounted) showSnack(context, 'Will start ${fmtTimeOfDay(t)}');
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: NButton(
                  _at == null ? 'Send now' : 'Schedule',
                  icon: Icons.send_rounded,
                  onTap: to.isEmpty ? null : _send,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
