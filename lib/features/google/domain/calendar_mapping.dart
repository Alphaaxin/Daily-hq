import 'package:googleapis/calendar/v3.dart' as gcal;

/// Pure conversions between Nizam tasks and Google Calendar events, so the
/// sync rules are unit-testable without a network.
class TaskSnapshot {
  const TaskSnapshot({
    required this.id,
    required this.title,
    this.notes,
    required this.dueAtUtc,
    this.done = false,
    this.durationMinutes = 30,
  });
  final int id;
  final String title;
  final String? notes;
  final DateTime dueAtUtc;
  final bool done;
  final int durationMinutes;
}

const donePrefix = '✓ ';
const taskIdKey = 'nizamTaskId';

gcal.Event taskToEvent(TaskSnapshot t, {required String timeZone}) {
  final start = t.dueAtUtc.toUtc();
  return gcal.Event(
    summary: '${t.done ? donePrefix : ''}${t.title}',
    description: (t.notes == null || t.notes!.isEmpty) ? null : t.notes,
    start: gcal.EventDateTime(dateTime: start, timeZone: timeZone),
    end: gcal.EventDateTime(
      dateTime: start.add(Duration(minutes: t.durationMinutes)),
      timeZone: timeZone,
    ),
    extendedProperties: gcal.EventExtendedProperties(private: {taskIdKey: '${t.id}'}),
    // Greyed-out ("graphite") once done.
    colorId: t.done ? '8' : null,
  );
}

/// What an event in the Nizam calendar says about its task.
class EventPatch {
  const EventPatch({required this.title, required this.dueAtUtc, required this.done, this.cancelled = false});
  final String title;
  final DateTime? dueAtUtc;
  final bool done;
  final bool cancelled;
}

EventPatch eventToPatch(gcal.Event e) {
  var title = e.summary ?? '';
  final done = title.startsWith(donePrefix);
  if (done) title = title.substring(donePrefix.length);
  return EventPatch(
    title: title.trim().isEmpty ? '(no title)' : title.trim(),
    dueAtUtc: e.start?.dateTime?.toUtc(),
    done: done,
    cancelled: e.status == 'cancelled',
  );
}

int? linkedTaskId(gcal.Event e) => int.tryParse(e.extendedProperties?.private?[taskIdKey] ?? '');

enum SyncWinner { local, remote, same }

/// Newest change wins. A missing local timestamp means "never edited here".
SyncWinner newestWins(DateTime? localUpdated, DateTime? remoteUpdated) {
  if (localUpdated == null && remoteUpdated == null) return SyncWinner.same;
  if (localUpdated == null) return SyncWinner.remote;
  if (remoteUpdated == null) return SyncWinner.local;
  final d = localUpdated.toUtc().difference(remoteUpdated.toUtc()).inSeconds;
  // Within 2 s is the echo of our own push.
  if (d.abs() <= 2) return SyncWinner.same;
  return d > 0 ? SyncWinner.local : SyncWinner.remote;
}

/// All-day events come as a date; timed ones as instants.
({DateTime? startUtc, DateTime? endUtc, String? allDay}) eventTimes(gcal.Event e) {
  final d = e.start?.date;
  if (d != null) {
    final s =
        '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
    return (startUtc: null, endUtc: null, allDay: s);
  }
  return (startUtc: e.start?.dateTime?.toUtc(), endUtc: e.end?.dateTime?.toUtc(), allDay: null);
}
