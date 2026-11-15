import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/db/app_db.dart';
import '../../../core/providers.dart';
import '../../gamification/data/xp_repo.dart';

const noteTemplates = <String, String>{
  'Research': 'Topic:\nSources:\nKey findings:\n- \nWhat it means for me:',
  'Blog draft': 'Title:\nHook:\nPoints:\n1. \n2. \nCall to action:',
  'Product idea': 'Problem:\nWho has it:\nIdea:\nWhy now:\nFirst step this week:',
  'Thought dump': '',
  'Meetings': 'With:\nProfile:\nAgenda:\nNotes:\nAction items:\n- ',
};

class NotesRepo {
  NotesRepo(this.db, this.xp);
  final AppDb db;
  final XpRepo xp;

  static const xpKey = 'note:write';

  /// Notes matching a search (title, body or tags) and optional template.
  Stream<List<Note>> watch({String query = '', String? template, int? profileId}) {
    final q = db.select(db.notes)..where((n) => n.archived.equals(false));
    final s = query.trim().toLowerCase();
    if (s.isNotEmpty) {
      final like = '%$s%';
      q.where((n) => n.title.lower().like(like) | n.body.lower().like(like) | n.tags.lower().like(like));
    }
    if (template != null) q.where((n) => n.template.equals(template));
    if (profileId != null) q.where((n) => n.profileId.equals(profileId));
    q.orderBy([(n) => OrderingTerm.desc(n.pinned), (n) => OrderingTerm.desc(n.updatedAtUtc)]);
    return q.watch();
  }

  Future<Note?> byId(int id) => (db.select(db.notes)..where((n) => n.id.equals(id))).getSingleOrNull();

  /// Creates or updates a note. Product ideas are mirrored into Build Hour's
  /// idea list. Writing a note gives +5 XP once a day.
  Future<int> save({
    int? id,
    required String title,
    required String body,
    required String template,
    String tags = '',
    int? profileId,
    int? meetingId,
    required String day,
  }) async {
    final now = DateTime.now().toUtc();
    final cleanTags = tags.split(',').map((e) => e.trim().replaceAll('#', '')).where((e) => e.isNotEmpty).join(',');
    int noteId;
    if (id == null) {
      noteId = await db
          .into(db.notes)
          .insert(
            NotesCompanion.insert(
              title: Value(title.trim()),
              body: Value(body),
              template: Value(template),
              tags: Value(cleanTags),
              profileId: Value(profileId),
              meetingId: Value(meetingId),
              createdAtUtc: now,
              updatedAtUtc: now,
            ),
          );
    } else {
      noteId = id;
      await (db.update(db.notes)..where((n) => n.id.equals(id))).write(
        NotesCompanion(
          title: Value(title.trim()),
          body: Value(body),
          template: Value(template),
          tags: Value(cleanTags),
          profileId: Value(profileId),
          updatedAtUtc: Value(now),
        ),
      );
    }
    if (template == 'Product idea' && title.trim().isNotEmpty) await _syncIdea(noteId, title.trim());
    if (title.trim().isNotEmpty || body.trim().length > 20) await xp.set(day, xpKey, 5);
    return noteId;
  }

  Future<void> _syncIdea(int noteId, String title) async {
    final n = (await byId(noteId))!;
    if (n.ideaId == null) {
      final ideaId = await db
          .into(db.ideas)
          .insert(IdeasCompanion.insert(title: title, createdAtUtc: DateTime.now().toUtc()));
      await (db.update(db.notes)..where((x) => x.id.equals(noteId))).write(NotesCompanion(ideaId: Value(ideaId)));
    } else {
      await (db.update(db.ideas)..where((x) => x.id.equals(n.ideaId!))).write(IdeasCompanion(title: Value(title)));
    }
  }

  Future<Note?> forIdea(int ideaId) =>
      (db.select(db.notes)
            ..where((n) => n.ideaId.equals(ideaId))
            ..limit(1))
          .getSingleOrNull();

  Future<void> togglePin(Note n) =>
      (db.update(db.notes)..where((x) => x.id.equals(n.id))).write(NotesCompanion(pinned: Value(!n.pinned)));

  Future<void> archive(int id) =>
      (db.update(db.notes)..where((n) => n.id.equals(id))).write(const NotesCompanion(archived: Value(true)));
}

final notesRepoProvider = Provider((ref) => NotesRepo(ref.watch(dbProvider), ref.watch(xpRepoProvider)));

class NoteQuery extends Notifier<(String, String?)> {
  @override
  (String, String?) build() => ('', null);
  void search(String q) => state = (q, state.$2);
  void template(String? t) => state = (state.$1, t);
}

final noteQueryProvider = NotifierProvider<NoteQuery, (String, String?)>(NoteQuery.new);
final notesProvider = StreamProvider<List<Note>>((ref) {
  final (q, t) = ref.watch(noteQueryProvider);
  return ref.watch(notesRepoProvider).watch(query: q, template: t);
});
