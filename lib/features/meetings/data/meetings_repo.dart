import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;

import '../../../core/ai/ai_service.dart';
import '../../../core/ai/gemini_client.dart';
import '../../../core/db/app_db.dart';
import '../../../core/providers.dart';
import '../../../core/time/day_clock.dart';
import '../../gamification/data/xp_repo.dart';
import '../../google/data/drive_files.dart';
import '../../notes/data/notes_repo.dart';
import '../../people/data/contacts_repo.dart';
import '../../profiles/data/profiles_repo.dart';
import '../../tasks/data/tasks_repo.dart';
import '../domain/mom.dart';

extension MeetingX on Meeting {
  List<String> get paths => (jsonDecode(audioPaths) as List).cast<String>();
  List<String> get chunks => (jsonDecode(chunkTranscripts) as List).cast<String>();
  Mom? get mom => momJson == null ? null : Mom.fromJson(jsonDecode(momJson!) as Map<String, Object?>);
  bool get busy => status == 'transcribing' || status == 'summarizing';
}

class MeetingsRepo {
  MeetingsRepo(this.ref);
  final Ref ref;
  AppDb get db => ref.read(dbProvider);
  final _running = <int>{};

  Stream<List<Meeting>> watchAll() =>
      (db.select(db.meetings)..orderBy([(m) => OrderingTerm.desc(m.startedAtUtc)])).watch();

  Stream<Meeting?> watch(int id) => (db.select(db.meetings)..where((m) => m.id.equals(id))).watchSingleOrNull();

  Future<Meeting> get(int id) => (db.select(db.meetings)..where((m) => m.id.equals(id))).getSingle();

  Future<int> create({
    required String title,
    required List<String> paths,
    required DateTime startedAtUtc,
    int durationSec = 0,
  }) =>
      db.into(db.meetings).insert(MeetingsCompanion.insert(
            title: Value(title),
            startedAtUtc: startedAtUtc,
            durationSec: Value(durationSec),
            audioPaths: Value(jsonEncode(paths)),
          ));

  Future<void> _set(int id, MeetingsCompanion c) => (db.update(db.meetings)..where((m) => m.id.equals(id))).write(c);

  Future<void> rename(int id, String title) => _set(id, MeetingsCompanion(title: Value(title.trim())));

  Future<void> saveMom(int id, Mom mom) async {
    await _set(id, MeetingsCompanion(momJson: Value(jsonEncode(mom.toJson())), title: Value(mom.title)));
  }

  Future<void> saveDraft(int id, String draft) => _set(id, MeetingsCompanion(emailDraft: Value(draft)));

  Future<void> delete(Meeting m) async {
    for (final f in m.paths) {
      final file = File(f);
      if (file.existsSync()) file.deleteSync();
    }
    await (db.delete(db.meetings)..where((x) => x.id.equals(m.id))).go();
  }

  /// Transcribe every chunk (resuming where it stopped), then write the MoM.
  /// Audio stays on the phone until this succeeds; errors keep it for retry.
  Future<void> process(int id) async {
    if (!_running.add(id)) return;
    try {
      final ai = ref.read(aiProvider);
      var m = await get(id);
      final done = m.chunks.toList();
      final paths = m.paths;
      await _set(id, MeetingsCompanion(status: const Value('transcribing'), error: const Value(null), attempts: Value(m.attempts + 1)));
      for (var i = done.length; i < paths.length; i++) {
        final text = await ai.transcribe(File(paths[i]), prompt: transcribePrompt);
        done.add(text);
        await _set(id, MeetingsCompanion(chunkTranscripts: Value(jsonEncode(done))));
      }
      final transcript = done.join('\n\n');
      await _set(id, MeetingsCompanion(transcript: Value(transcript), status: const Value('summarizing')));
      final profiles = (ref.read(profilesProvider).value ?? const <Profile>[]).map((p) => p.name).toList();
      final clock = ref.read(clockProvider);
      final json = await ai.json(
        momPrompt(transcript: transcript, today: clock.calendarDateFor(clock.nowUtc()), profiles: profiles),
        momSchema(profiles: profiles),
        system: aiStyle,
      );
      final mom = Mom.fromJson(json);
      final profileId = (ref.read(profilesProvider).value ?? const <Profile>[])
          .where((p) => p.name == mom.workProfile)
          .firstOrNull
          ?.id;
      await _set(
        id,
        MeetingsCompanion(
          momJson: Value(jsonEncode(mom.toJson())),
          title: Value(mom.title),
          profileId: Value(profileId),
          status: const Value('done'),
        ),
      );
      m = await get(id);
      await _saveNote(m, mom, transcript);
      await ref.read(xpRepoProvider).set(clock.dayKeyFor(m.startedAtUtc), 'meeting:$id', 20);
      unawaited(_backupToDrive(m, transcript));
    } catch (e) {
      final msg = e is GeminiError ? e.message : e.toString().replaceFirst('Exception: ', '');
      await _set(id, MeetingsCompanion(status: const Value('error'), error: Value(msg)));
    } finally {
      _running.remove(id);
    }
  }

  Future<void> _saveNote(Meeting m, Mom mom, String transcript) async {
    final existing = await (db.select(db.notes)..where((n) => n.meetingId.equals(m.id))).getSingleOrNull();
    await ref.read(notesRepoProvider).save(
          id: existing?.id,
          title: mom.title,
          body: '${mom.toText()}\n\n— Transcript —\n$transcript',
          template: 'Meetings',
          tags: 'meeting',
          profileId: m.profileId,
          meetingId: m.id,
          day: ref.read(clockProvider).dayKeyFor(m.startedAtUtc),
        );
  }

  Future<void> _backupToDrive(Meeting m, String transcript) async {
    try {
      final dir = File(m.paths.first).parent;
      final t = File(p.join(dir.path, 'transcript.txt'))..writeAsStringSync('${m.mom?.toText() ?? ''}\n\n$transcript');
      final c = ref.read(clockProvider);
      final name = '${c.calendarDateFor(m.startedAtUtc)} ${m.title}'.replaceAll(RegExp(r'[/\\]'), '-');
      final ids = await ref.read(driveFilesProvider).uploadMeeting(name, [...m.paths.map(File.new), t]);
      if (ids != null) await _set(m.id, MeetingsCompanion(driveFileIds: Value(jsonEncode(ids))));
    } catch (_) {/* Drive is optional */}
  }

  /// Action items → tasks; follow-up date → reminder (linked to a person
  /// if an attendee's name matches someone in People).
  Future<(int, int)> createActions(Meeting m, DayClock clock) async {
    final mom = m.mom;
    if (mom == null) return (0, 0);
    var tasks = 0, follow = 0;
    for (final a in mom.actionItems) {
      await ref.read(tasksRepoProvider).add(
            title: a.owner.isEmpty ? a.task : '${a.task} (${a.owner})',
            dueDay: a.deadline,
            profileId: m.profileId,
            tags: 'meeting',
          );
      tasks++;
    }
    if (mom.followUpDate != null) {
      final contacts = ref.read(contactsRepoProvider);
      final people = await contacts.allPeople();
      final match = people.where((p) => mom.attendees.any((a) => a.toLowerCase().contains(p.name.toLowerCase().split(' ').first)));
      final due = clock.localToUtc(mom.followUpDate!, 11, 0);
      await contacts.addFollowUp(
        personId: match.firstOrNull?.id,
        dueAtUtc: due,
        note: 'Follow up: ${mom.title}',
        origin: 'meeting',
      );
      follow++;
    }
    await _set(m.id, const MeetingsCompanion(actionsCreated: Value(true)));
    return (tasks, follow);
  }

  /// Gemini drafts a follow-up e-mail containing the minutes.
  Future<String> draftEmail(Meeting m) async {
    final mom = m.mom;
    if (mom == null) throw Exception('Minutes aren\'t ready yet');
    final s = ref.read(settingsProvider);
    final draft = await ref.read(aiProvider).write(
          'Write a short, friendly follow-up e-mail after this meeting. Thank them, recap the decisions and the '
          'action items with owners and dates, and propose the next step. First line: "Subject: …". '
          'Sign off as ${s.mailSignature}.\n\nMINUTES:\n${mom.toText()}',
          system: aiStyle,
        );
    await saveDraft(m.id, draft);
    return draft;
  }
}

final meetingsRepoProvider = Provider((ref) => MeetingsRepo(ref));
final meetingsProvider = StreamProvider<List<Meeting>>((ref) => ref.watch(meetingsRepoProvider).watchAll());
final meetingProvider = StreamProvider.family<Meeting?, int>((ref, id) => ref.watch(meetingsRepoProvider).watch(id));
