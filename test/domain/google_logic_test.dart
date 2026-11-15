import 'package:flutter_test/flutter_test.dart';
import 'package:googleapis/calendar/v3.dart' as gcal;
import 'package:nizam/features/google/domain/backup_names.dart';
import 'package:nizam/features/google/domain/calendar_mapping.dart';

void main() {
  group('task ↔ event', () {
    final due = DateTime.utc(2026, 11, 15, 12, 30); // 6 PM IST

    test('task becomes a 30-minute event tagged with its id', () {
      final e = taskToEvent(
        TaskSnapshot(id: 42, title: 'Call Rahul', notes: 'Pricing', dueAtUtc: due),
        timeZone: 'Asia/Kolkata',
      );
      expect(e.summary, 'Call Rahul');
      expect(e.description, 'Pricing');
      expect(e.start!.dateTime, due);
      expect(e.end!.dateTime, due.add(const Duration(minutes: 30)));
      expect(e.start!.timeZone, 'Asia/Kolkata');
      expect(linkedTaskId(e), 42);
      expect(e.colorId, isNull);
    });

    test('done tasks get a ✓ and grey colour, and round-trip', () {
      final e = taskToEvent(
        TaskSnapshot(id: 1, title: 'Send deck', dueAtUtc: due, done: true),
        timeZone: 'UTC',
      );
      expect(e.summary, '✓ Send deck');
      expect(e.colorId, '8');
      final p = eventToPatch(e);
      expect(p.title, 'Send deck');
      expect(p.done, isTrue);
      expect(p.dueAtUtc, due);
    });

    test('moved / renamed / cancelled in Google', () {
      final moved = DateTime.utc(2026, 11, 16, 4);
      final p = eventToPatch(
        gcal.Event(
          summary: '  Call Rahul (moved) ',
          start: gcal.EventDateTime(dateTime: moved),
          status: 'confirmed',
        ),
      );
      expect(p.title, 'Call Rahul (moved)');
      expect(p.dueAtUtc, moved);
      expect(p.done, isFalse);
      expect(eventToPatch(gcal.Event(status: 'cancelled')).cancelled, isTrue);
      expect(eventToPatch(gcal.Event(summary: '')).title, '(no title)');
    });

    test('events without our tag are not linked', () {
      expect(linkedTaskId(gcal.Event(summary: 'Team sync')), isNull);
    });

    test('all-day vs timed events', () {
      final a = eventTimes(gcal.Event(start: gcal.EventDateTime(date: DateTime.utc(2026, 11, 20))));
      expect(a.allDay, '2026-11-20');
      expect(a.startUtc, isNull);
      final t = eventTimes(
        gcal.Event(
          start: gcal.EventDateTime(dateTime: due),
          end: gcal.EventDateTime(dateTime: due.add(const Duration(hours: 1))),
        ),
      );
      expect(t.allDay, isNull);
      expect(t.endUtc!.difference(t.startUtc!).inMinutes, 60);
    });
  });

  group('newest wins', () {
    final t = DateTime.utc(2026, 11, 15, 10);
    test('rules', () {
      expect(newestWins(t, t.add(const Duration(minutes: 5))), SyncWinner.remote);
      expect(newestWins(t.add(const Duration(minutes: 5)), t), SyncWinner.local);
      expect(newestWins(t, t.add(const Duration(seconds: 1))), SyncWinner.same, reason: 'echo of our own push');
      expect(newestWins(null, t), SyncWinner.remote);
      expect(newestWins(t, null), SyncWinner.local);
      expect(newestWins(null, null), SyncWinner.same);
    });
  });

  group('backups', () {
    test('naming round-trip', () {
      final n = backupName(DateTime.utc(2026, 11, 15, 4, 5));
      expect(n, 'nizam-backup-20261115-0405.db.gz');
      expect(backupTime(n), DateTime.utc(2026, 11, 15, 4, 5));
      expect(backupTime('notes.txt'), isNull);
    });

    test('keeps the newest 14, ignores other files', () {
      final names = [for (var d = 1; d <= 20; d++) backupName(DateTime.utc(2026, 11, d, 4)), 'something-else.json']
        ..shuffle();
      final prune = backupsToPrune(names);
      expect(prune, hasLength(6));
      expect(prune.map(backupTime).every((t) => t!.day <= 6), isTrue);
      expect(prune, isNot(contains('something-else.json')));
      expect(backupsToPrune(names.take(3)), isEmpty);
    });

    test('next 10 AM IST', () {
      const ist = Duration(hours: 5, minutes: 30);
      // 03:00 IST → 10:00 IST same day = 04:30 UTC
      expect(nextLocalHour(DateTime.utc(2026, 11, 14, 21, 30), ist, 10), DateTime.utc(2026, 11, 15, 4, 30));
      // 11:00 IST → tomorrow 10:00 IST
      expect(nextLocalHour(DateTime.utc(2026, 11, 15, 5, 30), ist, 10), DateTime.utc(2026, 11, 16, 4, 30));
    });
  });
}
