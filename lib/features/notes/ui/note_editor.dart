import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/ai/ai_service.dart';
import '../../../core/db/app_db.dart';
import '../../../core/providers.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/theme/widgets.dart';
import '../../profiles/data/profiles_repo.dart';
import '../data/notes_repo.dart';

class NoteEditor extends ConsumerStatefulWidget {
  const NoteEditor({super.key, this.id, this.template = 'Thought dump'});
  final int? id;
  final String template;

  @override
  ConsumerState<NoteEditor> createState() => _NoteEditorState();
}

class _NoteEditorState extends ConsumerState<NoteEditor> {
  final _title = TextEditingController();
  final _body = TextEditingController();
  final _tags = TextEditingController();
  late String _template = widget.template;
  int? _profile;
  int? _id;
  Note? _note;
  bool _loaded = false, _aiBusy = false, _dirty = false;

  @override
  void initState() {
    super.initState();
    _id = widget.id;
    _load();
  }

  Future<void> _load() async {
    if (_id != null) {
      final n = await ref.read(notesRepoProvider).byId(_id!);
      if (n != null) {
        _note = n;
        _title.text = n.title;
        _body.text = n.body;
        _tags.text = n.tags;
        _template = n.template;
        _profile = n.profileId;
      }
    } else {
      _body.text = noteTemplates[_template] ?? '';
    }
    for (final c in [_title, _body, _tags]) {
      c.addListener(() => _dirty = true);
    }
    if (mounted) setState(() => _loaded = true);
  }

  Future<void> _save({bool quiet = false}) async {
    if (_title.text.trim().isEmpty && _body.text.trim() == (noteTemplates[_template] ?? '').trim()) return;
    _id = await ref
        .read(notesRepoProvider)
        .save(
          id: _id,
          title: _title.text,
          body: _body.text,
          template: _template,
          tags: _tags.text,
          profileId: _profile,
          day: ref.read(todayProvider),
        );
    _dirty = false;
    if (!quiet && mounted) showSnack(context, 'Saved');
  }

  /// Gemini rewrites a messy note into the chosen template.
  Future<void> _tidy() async {
    setState(() => _aiBusy = true);
    try {
      final tpl = noteTemplates[_template] ?? '';
      final out = await ref
          .read(aiProvider)
          .write(
            'Rewrite this messy note into a clean "$_template" note. ${tpl.isEmpty ? '' : 'Use this structure:\n$tpl\n'}'
            'Keep every fact, fix grammar, use short bullet points, English only. Return only the note body.\n\n'
            'TITLE: ${_title.text}\nNOTE:\n${_body.text}',
            system: aiStyle,
          );
      final old = _body.text;
      _body.text = out;
      if (mounted) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: const Text('Tidied with AI', style: TextStyle(color: N.ink)),
              action: SnackBarAction(label: 'Undo', textColor: N.gold, onPressed: () => _body.text = old),
            ),
          );
      }
    } catch (e) {
      if (mounted) showSnack(context, '$e');
    } finally {
      if (mounted) setState(() => _aiBusy = false);
    }
  }

  @override
  void dispose() {
    if (_dirty) _save(quiet: true);
    _title.dispose();
    _body.dispose();
    _tags.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profiles = ref.watch(profilesProvider).value ?? const <Profile>[];
    if (!_loaded) return const Scaffold(backgroundColor: N.bg);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: N.bg,
        surfaceTintColor: Colors.transparent,
        title: Text(_template, style: N.h2.copyWith(fontSize: 16, color: N.gold)),
        actions: [
          if (_note != null)
            IconButton(
              tooltip: _note!.pinned ? 'Unpin' : 'Pin',
              icon: Icon(_note!.pinned ? Icons.push_pin : Icons.push_pin_outlined, color: N.gold),
              onPressed: () async {
                await ref.read(notesRepoProvider).togglePin(_note!);
                _note = await ref.read(notesRepoProvider).byId(_note!.id);
                setState(() {});
              },
            ),
          IconButton(
            tooltip: 'Share',
            icon: const Icon(Icons.ios_share_rounded, color: N.muted),
            onPressed: () => SharePlus.instance.share(ShareParams(text: '${_title.text}\n\n${_body.text}')),
          ),
          if (_id != null)
            IconButton(
              tooltip: 'Delete',
              icon: const Icon(Icons.delete_outline_rounded, color: N.muted),
              onPressed: () async {
                await ref.read(notesRepoProvider).archive(_id!);
                _dirty = false;
                if (context.mounted) Navigator.pop(context);
              },
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 40),
        children: [
          TextField(
            controller: _title,
            style: N.h1.copyWith(fontSize: 22),
            decoration: const InputDecoration(
              hintText: 'Title',
              filled: false,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
            ),
          ),
          TextField(
            controller: _body,
            minLines: 12,
            maxLines: null,
            keyboardType: TextInputType.multiline,
            style: const TextStyle(fontSize: 15, height: 1.5),
            decoration: const InputDecoration(hintText: 'Write anything…'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _tags,
            decoration: const InputDecoration(hintText: 'Tags, comma separated'),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final k in noteTemplates.keys)
                NChip(k, on: _template == k, onTap: () => setState(() => _template = k)),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              NChip('No profile', on: _profile == null, onTap: () => setState(() => _profile = null)),
              for (final p in profiles)
                NChip(
                  p.name,
                  on: _profile == p.id,
                  color: Color(p.color),
                  onTap: () => setState(() => _profile = p.id),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: NButton(
                  _aiBusy ? 'Tidying…' : 'Tidy with AI',
                  kind: BtnKind.raise,
                  icon: Icons.auto_awesome_outlined,
                  onTap: _aiBusy ? null : _tidy,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: NButton('Save', icon: Icons.check_rounded, onTap: _save),
              ),
            ],
          ),
          if (_template == 'Product idea') ...[
            const SizedBox(height: 10),
            Text('Product ideas also appear in Build Hour\'s idea list.', style: N.small.copyWith(fontSize: 12)),
          ],
        ],
      ),
    );
  }
}
