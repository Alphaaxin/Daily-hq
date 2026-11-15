import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/db/app_db.dart';
import '../../../core/providers.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/theme/widgets.dart';
import '../../../core/time/format.dart';
import '../../people/data/contacts_repo.dart';
import '../../people/ui/contact_actions.dart';
import '../../people/ui/people_screen.dart';
import '../../profiles/data/profiles_repo.dart';
import '../domain/share_parser.dart';

class _LeadFilter extends Notifier<(String?, int?, String)> {
  @override
  (String?, int?, String) build() => (null, null, '');
  void stage(String? s) => state = (s, state.$2, state.$3);
  void profile(int? p) => state = (state.$1, p, state.$3);
  void search(String q) => state = (state.$1, state.$2, q);
}

final _leadFilterProvider = NotifierProvider<_LeadFilter, (String?, int?, String)>(_LeadFilter.new);

class LeadsScreen extends ConsumerWidget {
  const LeadsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final all = ref.watch(leadsProvider).value ?? const <Lead>[];
    final (stage, profile, q) = ref.watch(_leadFilterProvider);
    final profiles = ref.watch(profilesProvider).value ?? const <Profile>[];
    final today = ref.watch(todayProvider);
    final s = q.trim().toLowerCase();
    final shown = all.where((l) {
      if (stage != null && l.stage != stage) return false;
      if (profile != null && l.profileId != profile) return false;
      if (s.isNotEmpty && !'${l.name} ${l.business} ${l.location} ${l.notes}'.toLowerCase().contains(s)) return false;
      return true;
    }).toList();
    final counts = {for (final st in leadStages) st: all.where((l) => l.stage == st).length};
    final addedToday = all.where((l) => l.day == today).length;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: N.bg,
        surfaceTintColor: Colors.transparent,
        title: Text('Leads', style: N.h2.copyWith(fontSize: 18)),
        actions: [
          TextButton(
            onPressed: () => context.push('/mail'),
            child: const Text('Mail merge', style: TextStyle(color: N.gold, fontWeight: FontWeight.w700)),
          ),
          IconButton(
            tooltip: 'Add lead',
            icon: const Icon(Icons.add_rounded, color: N.gold),
            onPressed: () => context.push('/leads/new'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 40),
        children: [
          GlassCard(
            hero: true,
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              Row(children: [
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Eyebrow('Pipeline'),
                    const SizedBox(height: 4),
                    Text('${all.length} leads · $addedToday today', style: N.h2),
                  ]),
                ),
                NButton('Add', icon: Icons.add_rounded, onTap: () => context.push('/leads/new')),
              ]),
              const SizedBox(height: 12),
              SizedBox(
                height: 64,
                child: Row(children: [
                  for (final st in leadStages.where((x) => x != 'lost'))
                    Expanded(
                      child: GestureDetector(
                        onTap: () => ref.read(_leadFilterProvider.notifier).stage(stage == st ? null : st),
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 2),
                          decoration: BoxDecoration(
                            color: stage == st ? N.goldSoft : N.raise,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: stage == st ? N.gold : N.line),
                          ),
                          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                            Text('${counts[st]}', style: N.num(18)),
                            Text(leadStageLabels[st]!, style: N.small.copyWith(fontSize: 10)),
                          ]),
                        ),
                      ),
                    ),
                ]),
              ),
              const SizedBox(height: 8),
              Text('Tip: in Google Maps, tap Share on a business → Solo Leveling to add it here.',
                  style: N.small.copyWith(fontSize: 12)),
            ]),
          ),
          const SizedBox(height: N.gap),
          TextField(
            decoration: const InputDecoration(hintText: 'Search leads', prefixIcon: Icon(Icons.search_rounded, color: N.muted)),
            onChanged: ref.read(_leadFilterProvider.notifier).search,
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(children: [
              NChip('All profiles', on: profile == null, onTap: () => ref.read(_leadFilterProvider.notifier).profile(null)),
              for (final p in profiles) ...[
                const SizedBox(width: 6),
                NChip(p.name, on: profile == p.id, onTap: () => ref.read(_leadFilterProvider.notifier).profile(p.id)),
              ],
            ]),
          ),
          const SizedBox(height: N.gap),
          if (shown.isEmpty) const EmptyNote('No leads here yet.'),
          for (final l in shown) _LeadTile(l),
        ],
      ),
    );
  }
}

class _LeadTile extends ConsumerWidget {
  const _LeadTile(this.l);
  final Lead l;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final clock = ref.watch(clockProvider);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: GlassCard(
        padding: const EdgeInsets.fromLTRB(14, 12, 8, 8),
        child: InkWell(
          onTap: () => context.push('/leads/${l.id}'),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Row(children: [
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(l.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                  Text(
                    [if (l.business.isNotEmpty) l.business, if (l.location.isNotEmpty) l.location].join(' · '),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: N.small.copyWith(fontSize: 12),
                  ),
                ]),
              ),
              PopupMenuButton<String>(
                color: N.solid,
                initialValue: l.stage,
                onSelected: (s) => ref.read(contactsRepoProvider).setStage(l, s, clock),
                itemBuilder: (_) => [for (final s in leadStages) PopupMenuItem(value: s, child: Text(leadStageLabels[s]!))],
                child: Pill(leadStageLabels[l.stage] ?? l.stage, hot: l.stage == 'interested' || l.stage == 'closed'),
              ),
            ]),
            Row(children: [
              if (l.phone.isNotEmpty) IconButton(icon: const Icon(Icons.call_outlined, size: 20, color: N.good), onPressed: () => callNumber(l.phone)),
              if (l.phone.isNotEmpty) IconButton(icon: const Icon(Icons.chat_outlined, size: 20, color: N.good), onPressed: () => whatsapp(l.phone)),
              if (l.email.isNotEmpty) IconButton(icon: const Icon(Icons.mail_outline_rounded, size: 20, color: N.water), onPressed: () => emailTo(l.email)),
              if (l.mapsUrl.isNotEmpty) IconButton(icon: const Icon(Icons.map_outlined, size: 20, color: N.muted), onPressed: () => openUrl(l.mapsUrl)),
              const Spacer(),
              Text(fmtDayKey(l.day), style: N.small.copyWith(fontSize: 11)),
              IconButton(
                tooltip: 'Remind me',
                icon: const Icon(Icons.alarm_add_outlined, size: 20, color: N.gold),
                onPressed: () => showFollowUpSheet(context, leadId: l.id, label: l.name),
              ),
            ]),
          ]),
        ),
      ),
    );
  }
}

/// Add / edit a lead. [shared] pre-fills from a Google Maps share.
class LeadEditor extends ConsumerStatefulWidget {
  const LeadEditor({super.key, this.id, this.shared});
  final int? id;
  final String? shared;

  @override
  ConsumerState<LeadEditor> createState() => _LeadEditorState();
}

class _LeadEditorState extends ConsumerState<LeadEditor> {
  final _name = TextEditingController();
  final _business = TextEditingController();
  final _phone = TextEditingController();
  final _email = TextEditingController();
  final _location = TextEditingController();
  final _maps = TextEditingController();
  final _source = TextEditingController();
  final _notes = TextEditingController();
  int? _profile;
  String _stage = 'new';
  Lead? _lead;

  @override
  void initState() {
    super.initState();
    if (widget.id != null) {
      ref.read(contactsRepoProvider).lead(widget.id!).then((l) {
        if (l == null || !mounted) return;
        setState(() {
          _lead = l;
          _name.text = l.name;
          _business.text = l.business;
          _phone.text = l.phone;
          _email.text = l.email;
          _location.text = l.location;
          _maps.text = l.mapsUrl;
          _source.text = l.source;
          _notes.text = l.notes;
          _profile = l.profileId;
          _stage = l.stage;
        });
      });
    } else if (widget.shared != null) {
      final p = parseSharedText(widget.shared!);
      _name.text = p.name;
      _business.text = p.name;
      _location.text = p.address;
      _maps.text = p.url;
      _phone.text = p.phone;
      _email.text = p.email;
      _source.text = p.isMaps ? 'Google Maps' : 'Shared';
    }
  }

  Future<void> _save() async {
    if (_name.text.trim().isEmpty) {
      showSnack(context, 'Give the lead a name');
      return;
    }
    await ref.read(contactsRepoProvider).saveLead(
          id: _lead?.id,
          name: _name.text,
          business: _business.text,
          phone: _phone.text,
          email: _email.text,
          location: _location.text,
          mapsUrl: _maps.text,
          source: _source.text,
          notes: _notes.text,
          profileId: _profile,
          stage: _stage,
          clock: ref.read(clockProvider),
        );
    if (mounted) {
      if (_lead == null) showSnack(context, 'Lead added · +5 XP');
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final profiles = ref.watch(profilesProvider).value ?? const <Profile>[];
    Widget f(TextEditingController c, String hint, {TextInputType? kb, int lines = 1}) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: TextField(controller: c, keyboardType: kb, maxLines: lines, decoration: InputDecoration(labelText: hint)),
        );
    return Scaffold(
      appBar: AppBar(
        backgroundColor: N.bg,
        surfaceTintColor: Colors.transparent,
        title: Text(_lead == null ? 'New lead' : 'Edit lead', style: N.h2.copyWith(fontSize: 18)),
        actions: [
          if (_lead != null)
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded, color: N.muted),
              onPressed: () async {
                await ref.read(contactsRepoProvider).archiveLead(_lead!);
                if (context.mounted) context.pop();
              },
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 40),
        children: [
          f(_name, 'Name'),
          f(_business, 'Business'),
          f(_phone, 'Phone', kb: TextInputType.phone),
          f(_email, 'E-mail', kb: TextInputType.emailAddress),
          f(_location, 'Location / address'),
          f(_maps, 'Google Maps link', kb: TextInputType.url),
          f(_source, 'Source (Maps, referral, event…)'),
          f(_notes, 'Notes', lines: 3),
          const SizedBox(height: 4),
          const Eyebrow('Stage'),
          const SizedBox(height: 6),
          Wrap(spacing: 6, runSpacing: 6, children: [
            for (final s in leadStages) NChip(leadStageLabels[s]!, on: _stage == s, onTap: () => setState(() => _stage = s)),
          ]),
          const SizedBox(height: 12),
          const Eyebrow('Work profile'),
          const SizedBox(height: 6),
          Wrap(spacing: 6, runSpacing: 6, children: [
            NChip('None', on: _profile == null, onTap: () => setState(() => _profile = null)),
            for (final p in profiles) NChip(p.name, on: _profile == p.id, onTap: () => setState(() => _profile = p.id)),
          ]),
          const SizedBox(height: 20),
          NButton(_lead == null ? 'Add lead' : 'Save', expand: true, onTap: _save),
        ],
      ),
    );
  }
}
