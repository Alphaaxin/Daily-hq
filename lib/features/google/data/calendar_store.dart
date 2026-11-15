import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/db/app_db.dart';
import '../../../core/providers.dart';
import '../../../core/time/day_clock.dart';

/// Local cache of Google Calendar events, readable offline.
class CalendarStore {
  CalendarStore(this.db);
  final AppDb db;

  /// Events overlapping [fromUtc, toUtc), plus all-day events on those dates.
  Stream<List<CalendarEvent>> watchRange(DateTime fromUtc, DateTime toUtc, String fromDate, String toDate) =>
      (db.select(db.calendarEvents)
            ..where(
              (e) =>
                  (e.startUtc.isSmallerThanValue(toUtc) & e.endUtc.isBiggerThanValue(fromUtc)) |
                  e.allDayDate.isBetweenValues(fromDate, toDate),
            )
            ..orderBy([(e) => OrderingTerm.asc(e.allDayDate), (e) => OrderingTerm.asc(e.startUtc)]))
          .watch();

  Future<void> upsert(CalendarEventsCompanion e) => db.into(db.calendarEvents).insertOnConflictUpdate(e);

  Future<void> remove(String calendarId, String eventId) =>
      (db.delete(db.calendarEvents)..where((e) => e.calendarId.equals(calendarId) & e.eventId.equals(eventId))).go();

  Future<void> clearCalendar(String calendarId) =>
      (db.delete(db.calendarEvents)..where((e) => e.calendarId.equals(calendarId))).go();

  Future<String?> token(String key) async =>
      (await (db.select(db.syncStates)..where((s) => s.key.equals(key))).getSingleOrNull())?.value;

  Future<void> setToken(String key, String? value) async {
    if (value == null) {
      await (db.delete(db.syncStates)..where((s) => s.key.equals(key))).go();
    } else {
      await db.into(db.syncStates).insertOnConflictUpdate(SyncStatesCompanion.insert(key: key, value: value));
    }
  }
}

final calendarStoreProvider = Provider((ref) => CalendarStore(ref.watch(dbProvider)));

/// Events in today's logical day (6 AM → 6 AM by default).
final todayEventsProvider = StreamProvider<List<CalendarEvent>>((ref) {
  final clock = ref.watch(clockProvider);
  final today = ref.watch(todayProvider);
  return ref.watch(calendarStoreProvider).watchRange(clock.dayStartUtc(today), clock.dayEndUtc(today), today, today);
});

/// Events between two logical days (inclusive), for the calendar views.
final eventsRangeProvider = StreamProvider.family<List<CalendarEvent>, (String, String)>((ref, r) {
  final clock = ref.watch(clockProvider);
  return ref
      .watch(calendarStoreProvider)
      .watchRange(clock.dayStartUtc(r.$1), clock.dayEndUtc(r.$2), r.$1, DayKey.add(r.$2, 0));
});
