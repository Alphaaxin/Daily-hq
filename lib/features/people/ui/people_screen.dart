import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/ai/ai_service.dart';
import '../../../core/db/app_db.dart';
import '../../../core/notifications/reminder_sync.dart';
import '../../../core/providers.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/theme/widgets.dart';
import '../../../core/time/day_clock.dart';
import '../../../core/time/format.dart';
import '../../profiles/data/profiles_repo.dart';
import '../../tasks/ui/task_widgets.dart' show fmtTimeOfDay;
import '../data/contacts_repo.dart';
import 'contact_actions.dart';

/// People: follow-ups due, birthdays, and your contacts.
class PeopleScreen extends ConsumerWidget {
  const PeopleScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final people = ref.watch(peopleProvider).value ?? const <PeopleData>[];
    final bdays = ref.watch(upcomingBirthdaysProvider);
    final today = ref.watch(todayProvider);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: N.bg,
        surfaceTintColor: Colors.transparent,
        title: Text('People', style: N.h2.copyWith(fontSize: 18)),
        actions: [
          IconButton(
            tooltip: 'Add person',
            icon: const Icon(Icons.person_add_alt_rounded, color: N.gold),
            onPressed: () => showPersonSheet(context),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 40),
        children: [
          const FollowUpsCard(),
          if (bdays.isNotEmpty) ...[
            const SizedBox(height: N.gap),
            GlassCard(
              child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                const CardHeader('Birthdays'),
                for (final (p, date, days) in bdays)
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: const BoxDecoration(border: Border(top: BorderSide(color: N.line))),
                    child: Row(children: [
                      const Text('🎂', style: TextStyle(fontSize: 20)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(p.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                          Text(days == 0 ? 'Today!' : '${relDay(date, today)} · in $days days', style: N.small.copyWith(fontSize: 12)),
                        ]),
                      ),
                      NButton('Wish', kind: days == 0 ? BtnKind.primary : BtnKind.raise, onTap: () => showWishSheet(context, p)),
                    ]),
                  ),
              ]),
            ),
          ],
          const SizedBox(height: N.gap),
          GlassCard(
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              CardHeader('Contacts', trailing: Text('${people.length}', style: N.num(12, color: N.muted))),
              if (people.isEmpty) const EmptyNote('Add people you follow up with: clients, mentors, friends.'),
              for (final p in people)
                InkWell(
                  onTap: () => showPersonSheet(context, person: p),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: const BoxDecoration(border: Border(top: BorderSide(color: N.line))),
                    child: Row(children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: N.goldSoft,
                        child: Text(p.name[0].toUpperCase(), style: const TextStyle(color: N.gold, fontWeight: FontWeight.w700)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(p.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                          if (p.phone.isNotEmpty || p.email.isNotEmpty)
                            Text([p.phone, p.email].where((e) => e.isNotEmpty).join(' · '), style: N.small.copyWith(fontSize: 12)),
                        ]),
                      ),
                      if (p.phone.isNotEmpty)
                        IconButton(icon: const Icon(Icons.call_outlined, color: N.good, size: 20), onPressed: () => callNumber(p.phone)),
                      if (p.phone.isNotEmpty)
                        IconButton(icon: const Icon(Icons.chat_outlined, color: N.good, size: 20), onPressed: () => whatsapp(p.phone)),
                      IconButton(
                        tooltip: 'Remind me',
                        icon: const Icon(Icons.alarm_add_outlined, color: N.gold, size: 20),
                        onPressed: () => showFollowUpSheet(context, personId: p.id, label: p.name),
                      ),
                    ]),
                  ),
                ),
            ]),
          ),
        ],
      ),
    );
  }
}

/// Follow-ups due (overdue first) with one-tap actions.
class FollowUpsCard extends ConsumerWidget {
  const FollowUpsCard({super.key, this.limit = 50});
  final int limit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fus = ref.watch(followUpsProvider).value ?? const <FollowUp>[];
    final people = {for (final p in ref.watch(peopleProvider).value ?? const <PeopleData>[]) p.id: p};
    final leads = {for (final l in ref.watch(leadsProvider).value ?? const <Lead>[]) l.id: l};
    final clock = ref.watch(clockProvider);
    final now = clock.nowUtc();
    final today = ref.watch(todayProvider);
    final repo = ref.read(contactsRepoProvider);
    return GlassCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        CardHeader('Follow-ups', trailing: Text('${fus.length}', style: N.num(12, color: N.muted))),
        if (fus.isEmpty) const EmptyNote('No follow-ups. Tap ⏰ on a person or lead to add one.'),
        for (final f in fus.take(limit))
          () {
            final p = people[f.personId];
            final l = leads[f.leadId];
            final who = p?.name ?? l?.name ?? 'Follow-up';
            final phone = p?.phone ?? l?.phone ?? '';
            final email = p?.email ?? l?.email ?? '';
            final overdue = f.dueAtUtc.isBefore(now);
            return Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: const BoxDecoration(border: Border(top: BorderSide(color: N.line))),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Expanded(child: Text(who, style: const TextStyle(fontWeight: FontWeight.w700))),
                  Text(
                    '${relDay(clock.dayKeyFor(f.dueAtUtc), today)}, ${fmtTime(clock, f.dueAtUtc)}',
                    style: N.small.copyWith(fontSize: 12, color: overdue ? N.warn : N.muted),
                  ),
                ]),
                if (f.note.isNotEmpty) Text(f.note, style: N.small),
                const SizedBox(height: 6),
                Wrap(spacing: 6, runSpacing: 6, children: [
                  if (phone.isNotEmpty) _act(Icons.call_outlined, 'Call', () => callNumber(phone)),
                  if (phone.isNotEmpty) _act(Icons.chat_outlined, 'WhatsApp', () => whatsapp(phone)),
                  if (email.isNotEmpty) _act(Icons.mail_outline_rounded, 'Email', () => emailTo(email)),
                  _act(Icons.snooze_rounded, '+1 day', () async {
                    await repo.snoozeFollowUp(f, const Duration(days: 1));
                    ref.read(reminderSyncProvider).schedule();
                  }),
                  _act(Icons.check_rounded, 'Done', () async {
                    await repo.completeFollowUp(f.id, clock);
                    ref.read(reminderSyncProvider).schedule();
                  }, gold: true),
                ]),
              ]),
            );
          }(),
      ]),
    );
  }

  Widget _act(IconData i, String label, VoidCallback onTap, {bool gold = false}) => Material(
        color: gold ? N.goldSoft : N.raise,
        shape: StadiumBorder(side: BorderSide(color: gold ? N.gold : N.line)),
        child: InkWell(
          customBorder: const StadiumBorder(),
          onTap: () {
            Haptic.tap();
            onTap();
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(i, size: 16, color: gold ? N.gold : N.ink),
              const SizedBox(width: 6),
              Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: gold ? N.goldHi : N.ink)),
            ]),
          ),
        ),
      );
}

Future<void> showFollowUpSheet(BuildContext context, {int? personId, int? leadId, required String label}) =>
    showNSheet(context, (_) => _FollowUpSheet(personId: personId, leadId: leadId, label: label));

class _FollowUpSheet extends ConsumerStatefulWidget {
  const _FollowUpSheet({this.personId, this.leadId, required this.label});
  final int? personId;
  final int? leadId;
  final String label;

  @override
  ConsumerState<_FollowUpSheet> createState() => _FollowUpSheetState();
}

class _FollowUpSheetState extends ConsumerState<_FollowUpSheet> {
  final _note = TextEditingController();
  late String _day = DayKey.add(ref.read(todayProvider), 1);
  TimeOfDay _time = const TimeOfDay(hour: 17, minute: 0);
  String _channel = 'call';

  @override
  Widget build(BuildContext context) {
    final today = ref.watch(todayProvider);
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Text('Remind me about ${widget.label}', style: N.h2.copyWith(fontSize: 18)),
      const SizedBox(height: 12),
      TextField(controller: _note, autofocus: true, decoration: const InputDecoration(hintText: 'e.g. Call about the proposal')),
      const SizedBox(height: 12),
      Wrap(spacing: 6, runSpacing: 6, children: [
        for (final (k, l) in [(0, 'Today'), (1, 'Tomorrow'), (3, 'In 3 days'), (7, 'Next week')])
          NChip(l, on: _day == DayKey.add(today, k), onTap: () => setState(() => _day = DayKey.add(today, k))),
        NChip(fmtTimeOfDay(_time), on: true, onTap: () async {
          final t = await showTimePicker(context: context, initialTime: _time);
          if (t != null) setState(() => _time = t);
        }),
      ]),
      const SizedBox(height: 10),
      Wrap(spacing: 6, children: [
        for (final c in ['call', 'whatsapp', 'email', 'any'])
          NChip(c[0].toUpperCase() + c.substring(1), on: _channel == c, onTap: () => setState(() => _channel = c)),
      ]),
      const SizedBox(height: 16),
      NButton('Save reminder', expand: true, onTap: () async {
        final clock = ref.read(clockProvider);
        final cal = _time.hour < clock.rolloverHour ? DayKey.add(_day, 1) : _day;
        await ref.read(contactsRepoProvider).addFollowUp(
              personId: widget.personId,
              leadId: widget.leadId,
              dueAtUtc: clock.localToUtc(cal, _time.hour, _time.minute),
              note: _note.text.trim(),
              channel: _channel,
            );
        ref.read(reminderSyncProvider).schedule();
        if (context.mounted) Navigator.pop(context);
      }),
    ]);
  }
}

Future<void> showPersonSheet(BuildContext context, {PeopleData? person}) =>
    showNSheet(context, (_) => _PersonSheet(person: person));

class _PersonSheet extends ConsumerStatefulWidget {
  const _PersonSheet({this.person});
  final PeopleData? person;

  @override
  ConsumerState<_PersonSheet> createState() => _PersonSheetState();
}

class _PersonSheetState extends ConsumerState<_PersonSheet> {
  late final _name = TextEditingController(text: widget.person?.name ?? '');
  late final _phone = TextEditingController(text: widget.person?.phone ?? '');
  late final _email = TextEditingController(text: widget.person?.email ?? '');
  late final _bday = TextEditingController(text: widget.person?.birthday ?? '');
  late final _notes = TextEditingController(text: widget.person?.notes ?? '');
  late int? _profile = widget.person?.profileId;

  @override
  Widget build(BuildContext context) {
    final profiles = ref.watch(profilesProvider).value ?? const <Profile>[];
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Text(widget.person == null ? 'New person' : 'Edit person', style: N.h2.copyWith(fontSize: 18)),
      const SizedBox(height: 12),
      TextField(controller: _name, autofocus: widget.person == null, decoration: const InputDecoration(hintText: 'Name')),
      const SizedBox(height: 8),
      TextField(controller: _phone, keyboardType: TextInputType.phone, decoration: const InputDecoration(hintText: 'Phone')),
      const SizedBox(height: 8),
      TextField(controller: _email, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(hintText: 'E-mail')),
      const SizedBox(height: 8),
      TextField(controller: _bday, decoration: const InputDecoration(hintText: 'Birthday: MM-DD (e.g. 03-21)')),
      const SizedBox(height: 8),
      TextField(controller: _notes, maxLines: 3, decoration: const InputDecoration(hintText: 'Notes')),
      const SizedBox(height: 10),
      Wrap(spacing: 6, runSpacing: 6, children: [
        NChip('No profile', on: _profile == null, onTap: () => setState(() => _profile = null)),
        for (final p in profiles) NChip(p.name, on: _profile == p.id, onTap: () => setState(() => _profile = p.id)),
      ]),
      const SizedBox(height: 16),
      Row(children: [
        if (widget.person != null)
          NButton('Remove', kind: BtnKind.danger, onTap: () async {
            await ref.read(contactsRepoProvider).archivePerson(widget.person!.id);
            if (context.mounted) Navigator.pop(context);
          }),
        if (widget.person != null) const SizedBox(width: 8),
        Expanded(
          child: NButton('Save', onTap: () async {
            if (_name.text.trim().isEmpty) return;
            await ref.read(contactsRepoProvider).savePerson(
                  id: widget.person?.id,
                  name: _name.text,
                  phone: _phone.text,
                  email: _email.text,
                  birthday: _bday.text,
                  notes: _notes.text,
                  profileId: _profile,
                );
            ref.read(reminderSyncProvider).schedule();
            if (context.mounted) Navigator.pop(context);
          }),
        ),
      ]),
    ]);
  }
}

Future<void> showWishSheet(BuildContext context, PeopleData p) => showNSheet(context, (_) => _WishSheet(p));

class _WishSheet extends ConsumerStatefulWidget {
  const _WishSheet(this.p);
  final PeopleData p;

  @override
  ConsumerState<_WishSheet> createState() => _WishSheetState();
}

class _WishSheetState extends ConsumerState<_WishSheet> {
  final _c = TextEditingController();
  bool _busy = false;

  Future<void> _draft() async {
    setState(() => _busy = true);
    try {
      _c.text = await ref.read(aiProvider).write(
            'Write a warm, short birthday wish (2-3 sentences) to ${widget.p.name} for WhatsApp. '
            '${widget.p.notes.isEmpty ? '' : 'Context about them: ${widget.p.notes}. '}'
            'Personal, not cheesy. One emoji at most. Sign as ${ref.read(settingsProvider).mailSignature}.',
            system: aiStyle,
          );
    } catch (e) {
      if (mounted) showSnack(context, '$e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  void initState() {
    super.initState();
    _c.text = 'Happy birthday ${widget.p.name.split(' ').first}! Wishing you a wonderful year ahead.';
  }

  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Text('Wish ${widget.p.name}', style: N.h2.copyWith(fontSize: 18)),
        const SizedBox(height: 12),
        TextField(controller: _c, maxLines: 5),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(
            child: NButton(_busy ? 'Writing…' : 'Write with AI', kind: BtnKind.raise, icon: Icons.auto_awesome_outlined,
                onTap: _busy ? null : _draft),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: NButton('Send', icon: Icons.send_rounded, onTap: () {
              if (widget.p.phone.isNotEmpty) {
                whatsapp(widget.p.phone, text: _c.text);
              } else if (widget.p.email.isNotEmpty) {
                emailTo(widget.p.email, subject: 'Happy birthday!', body: _c.text);
              } else {
                showSnack(context, 'Add a phone or e-mail for ${widget.p.name} first.');
              }
            }),
          ),
        ]),
      ]);
}

/// Link to People from elsewhere.
void openPeople(BuildContext context) => context.push('/people');
