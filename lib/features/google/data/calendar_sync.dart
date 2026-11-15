import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:googleapis/calendar/v3.dart' as gcal;

import '../../../core/db/app_db.dart';
import '../../../core/providers.dart';
import '../../../core/time/day_clock.dart';
import '../../tasks/data/tasks_repo.dart';
import '../domain/calendar_mapping.dart';
import 'calendar_store.dart';
import 'google_auth.dart';

class SyncResult {
  const SyncResult({this.pushed = 0, this.pulled = 0, this.error});
  final int pushed;
  final int pulled;
  final String? error;
  bool get ok => error == null;
}

/// Two-way sync between Nizam tasks and a dedicated "Nizam" Google calendar,
/// plus a read/edit mirror of your primary calendar.
class CalendarSync {
  CalendarSync(this.ref);
  final Ref ref;
  bool _running = false;

  AppDb get _db => ref.read(dbProvider);
  TasksRepo get _tasks => ref.read(tasksRepoProvider);
  CalendarStore get _store => ref.read(calendarStoreProvider);

  Future<SyncResult> sync() async {
    if (_running) return const SyncResult();
    _running = true;
    try {
      final client = await ref.read(googleAuthProvider).client();
      if (client == null) return const SyncResult(error: 'Not signed in to Google');
      final api = gcal.CalendarApi(client);
      final calId = await _ensureNizamCalendar(api);
      final pushed = await _push(api, calId);
      var pulled = await _pull(api, calId, isNizam: true);
      pulled += await _pull(api, 'primary', isNizam: false);
      client.close();
      return SyncResult(pushed: pushed, pulled: pulled);
    } catch (e) {
      return SyncResult(error: '$e');
    } finally {
      _running = false;
    }
  }

  Future<String> _ensureNizamCalendar(gcal.CalendarApi api) async {
    final saved = ref.read(settingsProvider).nizamCalendarId;
    if (saved.isNotEmpty) {
      try {
        await api.calendars.get(saved);
        return saved;
      } catch (_) {
        /* deleted in Google: recreate below */
      }
    }
    final list = await api.calendarList.list();
    final existing = list.items?.where((c) => c.summary == 'Nizam' && c.accessRole == 'owner').firstOrNull;
    final id =
        existing?.id ??
        (await api.calendars.insert(
          gcal.Calendar(summary: 'Nizam', timeZone: ref.read(settingsProvider).timezone),
        )).id!;
    await ref.read(settingsRepoProvider).set('nizamCalendarId', id);
    await _store.setToken('sync:nizam', null);
    return id;
  }

  /// Local → Google: new / changed timed tasks, and deletions.
  Future<int> _push(gcal.CalendarApi api, String calId) async {
    var n = 0;
    final tz = ref.read(settingsProvider).timezone;
    // Deleted tasks.
    final tombs = await (_db.select(_db.syncStates)..where((s) => s.key.like('${TasksRepo.tombstonePrefix}%'))).get();
    for (final t in tombs) {
      final eventId = t.key.substring(TasksRepo.tombstonePrefix.length);
      try {
        await api.events.delete(calId, eventId);
      } catch (_) {
        /* already gone */
      }
      await _store.setToken(t.key, null);
      n++;
    }
    for (final t in await _tasks.syncCandidates()) {
      // Time removed → event goes away.
      if (t.dueAtUtc == null && t.remoteId != null) {
        try {
          await api.events.delete(calId, t.remoteId!);
        } catch (_) {}
        await _tasks.setRemote(t.id, remoteId: null);
        n++;
        continue;
      }
      if (t.dueAtUtc == null) continue;
      final changed = t.remoteId == null || newestWins(t.updatedAtUtc, t.remoteUpdated) == SyncWinner.local;
      if (!changed) continue;
      final ev = taskToEvent(
        TaskSnapshot(id: t.id, title: t.title, notes: t.notes, dueAtUtc: t.dueAtUtc!, done: t.doneAtUtc != null),
        timeZone: tz,
      );
      gcal.Event saved;
      if (t.remoteId == null) {
        saved = await api.events.insert(ev, calId);
      } else {
        try {
          saved = await api.events.patch(ev, calId, t.remoteId!);
        } catch (_) {
          saved = await api.events.insert(ev, calId); // was deleted in Google
        }
      }
      await _tasks.setRemote(t.id, remoteId: saved.id, etag: saved.etag, updated: saved.updated?.toUtc());
      await (_db.update(
        _db.tasks,
      )..where((x) => x.id.equals(t.id))).write(TasksCompanion(updatedAtUtc: Value(saved.updated?.toUtc())));
      n++;
    }
    return n;
  }

  /// Google → local, incrementally with a sync token.
  Future<int> _pull(gcal.CalendarApi api, String calId, {required bool isNizam}) async {
    final key = isNizam ? 'sync:nizam' : 'sync:$calId';
    var token = await _store.token(key);
    final clock = ref.read(clockProvider);
    var n = 0;
    String? page;
    if (token == null && !isNizam) await _store.clearCalendar(calId);
    do {
      gcal.Events res;
      try {
        res = await api.events.list(
          calId,
          syncToken: token,
          pageToken: page,
          singleEvents: true,
          showDeleted: true,
          maxResults: 250,
          timeMin: token == null ? clock.nowUtc().subtract(const Duration(days: 30)) : null,
        );
      } on gcal.DetailedApiRequestError catch (e) {
        if (e.status == 410) {
          // Token expired: start over with a full sync.
          await _store.setToken(key, null);
          token = null;
          page = null;
          if (!isNizam) await _store.clearCalendar(calId);
          continue;
        }
        rethrow;
      }
      for (final e in res.items ?? const <gcal.Event>[]) {
        n++;
        if (isNizam) {
          await _applyNizamEvent(e, clock);
        } else {
          await _cacheEvent(calId, e);
        }
      }
      page = res.nextPageToken;
      if (page == null && res.nextSyncToken != null) await _store.setToken(key, res.nextSyncToken);
    } while (page != null);
    return n;
  }

  Future<void> _cacheEvent(String calId, gcal.Event e) async {
    if (e.id == null) return;
    if (e.status == 'cancelled') {
      await _store.remove(calId, e.id!);
      return;
    }
    final t = eventTimes(e);
    await _store.upsert(
      CalendarEventsCompanion.insert(
        calendarId: calId,
        eventId: e.id!,
        title: Value(e.summary ?? ''),
        startUtc: Value(t.startUtc),
        endUtc: Value(t.endUtc),
        allDayDate: Value(t.allDay),
        location: Value(e.location),
        etag: Value(e.etag),
        updated: Value(e.updated?.toUtc()),
      ),
    );
  }

  /// An event in the Nizam calendar: update, complete or delete its task, or
  /// create a task if you added the event in Google directly.
  Future<void> _applyNizamEvent(gcal.Event e, DayClock clock) async {
    final patch = eventToPatch(e);
    final id = linkedTaskId(e);
    final task = id == null ? null : await _tasks.byId(id);
    if (patch.cancelled) {
      if (task != null && task.remoteId == e.id) await _tasks.delete(task.copyWith(remoteId: const Value(null)));
      return;
    }
    if (task == null) {
      if (patch.dueAtUtc == null || e.id == null) return;
      final newId = await _tasks.add(
        title: patch.title,
        dueDay: clock.dayKeyFor(patch.dueAtUtc!),
        dueAtUtc: patch.dueAtUtc,
      );
      await _tasks.setRemote(newId, remoteId: e.id, etag: e.etag, updated: e.updated?.toUtc());
      await (_db.update(
        _db.tasks,
      )..where((x) => x.id.equals(newId))).write(TasksCompanion(updatedAtUtc: Value(e.updated?.toUtc())));
      return;
    }
    if (newestWins(task.updatedAtUtc, e.updated) != SyncWinner.remote) return;
    final due = patch.dueAtUtc ?? task.dueAtUtc;
    await _tasks.applyRemote(
      task,
      title: patch.title,
      dueAtUtc: due,
      dueDay: due == null ? (task.dueDay ?? clock.today()) : clock.dayKeyFor(due),
      done: patch.done,
      remoteUpdated: e.updated!.toUtc(),
      etag: e.etag,
      clock: clock,
    );
  }

  /// Edit an event from your primary calendar (title and/or time).
  Future<void> editPrimary(CalendarEvent ev, {String? title, DateTime? startUtc, DateTime? endUtc}) async {
    final client = await ref.read(googleAuthProvider).client();
    if (client == null) throw Exception('Not signed in to Google');
    final api = gcal.CalendarApi(client);
    final tz = ref.read(settingsProvider).timezone;
    final saved = await api.events.patch(
      gcal.Event(
        summary: title,
        start: startUtc == null ? null : gcal.EventDateTime(dateTime: startUtc, timeZone: tz),
        end: endUtc == null ? null : gcal.EventDateTime(dateTime: endUtc, timeZone: tz),
      ),
      ev.calendarId,
      ev.eventId,
    );
    await _cacheEvent(ev.calendarId, saved);
    client.close();
  }
}

final calendarSyncProvider = Provider((ref) => CalendarSync(ref));
