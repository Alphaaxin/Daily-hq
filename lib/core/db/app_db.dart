import 'package:drift/drift.dart';

part 'app_db.g.dart';

/// Key/value settings stored as JSON-encoded strings.
class Settings extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();
  @override
  Set<Column> get primaryKey => {key};
}

class Profiles extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 40)();
  IntColumn get color => integer().withDefault(const Constant(0xFFD9B46A))();
  IntColumn get sort => integer().withDefault(const Constant(0))();
  BoolColumn get archived => boolean().withDefault(const Constant(false))();
}

class Tasks extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text().withLength(min: 1, max: 200)();
  TextColumn get notes => text().nullable()();

  /// Logical day the task is due (null = someday / no date).
  TextColumn get dueDay => text().nullable()();

  /// Due instant, only when a time was picked.
  DateTimeColumn get dueAtUtc => dateTime().nullable()();
  IntColumn get priority => integer().withDefault(const Constant(0))(); // 0 normal, 1 high
  TextColumn get tags => text().withDefault(const Constant(''))(); // comma-separated
  IntColumn get profileId => integer().nullable().references(Profiles, #id)();
  TextColumn get rrule => text().nullable()();
  DateTimeColumn get doneAtUtc => dateTime().nullable()();
  TextColumn get doneDay => text().nullable()();
  DateTimeColumn get createdAtUtc => dateTime()();

  /// Id of the next instance spawned when a recurring task was completed.
  IntColumn get nextId => integer().nullable()();

  /// Google Calendar event id (Phase 2).
  TextColumn get remoteId => text().nullable()();

  /// Google event etag / last-modified, for 2-way sync (v2).
  TextColumn get remoteEtag => text().nullable()();
  DateTimeColumn get remoteUpdated => dateTime().nullable()();

  /// Local last-modified, compared with [remoteUpdated] (newest wins).
  DateTimeColumn get updatedAtUtc => dateTime().nullable()();
}

class Habits extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 60)();
  IntColumn get sort => integer().withDefault(const Constant(0))();
  BoolColumn get archived => boolean().withDefault(const Constant(false))();
}

class HabitLogs extends Table {
  IntColumn get habitId => integer().references(Habits, #id)();
  TextColumn get day => text()();
  DateTimeColumn get atUtc => dateTime()();
  @override
  Set<Column> get primaryKey => {habitId, day};
}

class WaterLogs extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get day => text()();
  DateTimeColumn get atUtc => dateTime()();
}

class SalahLogs extends Table {
  /// Local calendar date of the prayer (prayer days start at Fajr).
  TextColumn get prayerDate => text()();
  IntColumn get prayer => integer()(); // Prayer.index
  IntColumn get status => integer()(); // SalahStatus.index (onTime / late)
  DateTimeColumn get atUtc => dateTime()();
  @override
  Set<Column> get primaryKey => {prayerDate, prayer};
}

class MoodLogs extends Table {
  TextColumn get day => text()();
  IntColumn get mood => integer()(); // 1..5
  DateTimeColumn get atUtc => dateTime()();
  @override
  Set<Column> get primaryKey => {day};
}

class SleepSessions extends Table {
  IntColumn get id => integer().autoIncrement()();
  DateTimeColumn get sleptAtUtc => dateTime()();
  DateTimeColumn get wokeAtUtc => dateTime().nullable()();

  /// Minutes awake before this sleep (since the previous wake-up).
  IntColumn get awakeMinutes => integer().nullable()();
  TextColumn get source => text().withDefault(const Constant('button'))(); // button | manual
}

class XpEntries extends Table {
  TextColumn get day => text()();
  TextColumn get source => text()();
  IntColumn get amount => integer()();
  DateTimeColumn get atUtc => dateTime()();
  @override
  Set<Column> get primaryKey => {day, source};
}

class Rewards extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 60)();
  IntColumn get cost => integer()();
  BoolColumn get archived => boolean().withDefault(const Constant(false))();
}

class Redemptions extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  IntColumn get cost => integer()();
  DateTimeColumn get atUtc => dateTime()();
}

// ---------------------------------------------------------------- v2 tables

/// Money categories, per type (spent / invested / received).
class Categories extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 40)();
  TextColumn get type => text()(); // spent | invested | received
  /// Monthly budget in paise, spent categories only.
  IntColumn get budgetPaise => integer().nullable()();
  IntColumn get sort => integer().withDefault(const Constant(0))();
  BoolColumn get archived => boolean().withDefault(const Constant(false))();
}

class MoneyEntries extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// Amount in paise (₹1 = 100) so sums never drift.
  IntColumn get amountPaise => integer()();
  TextColumn get type => text()(); // spent | invested | received
  IntColumn get categoryId => integer().references(Categories, #id)();
  TextColumn get note => text().withDefault(const Constant(''))();
  IntColumn get profileId => integer().nullable().references(Profiles, #id)();
  DateTimeColumn get atUtc => dateTime()();
  TextColumn get day => text()();
}

/// Daily quota goals, e.g. "Collect 20 leads".
class Targets extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 60)();
  IntColumn get goal => integer()();
  IntColumn get profileId => integer().nullable().references(Profiles, #id)();

  /// none | leads | emails: auto-counted from Phase 3 modules.
  TextColumn get autoSource => text().withDefault(const Constant('none'))();
  IntColumn get sort => integer().withDefault(const Constant(0))();
  BoolColumn get archived => boolean().withDefault(const Constant(false))();
}

class TargetLogs extends Table {
  IntColumn get targetId => integer().references(Targets, #id)();
  TextColumn get day => text()();
  IntColumn get count => integer()();
  @override
  Set<Column> get primaryKey => {targetId, day};
}

/// AI product ideas worked on during Build Hour (become notes in Phase 3).
class Ideas extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text().withLength(min: 1, max: 120)();
  TextColumn get note => text().withDefault(const Constant(''))();
  BoolColumn get archived => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAtUtc => dateTime()();
}

/// Build Hour, Pomodoro, retainer and manual time logs.
class FocusSessions extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get kind => text()(); // build | pomodoro | work | manual
  IntColumn get profileId => integer().nullable().references(Profiles, #id)();
  IntColumn get ideaId => integer().nullable().references(Ideas, #id)();
  DateTimeColumn get startUtc => dateTime()();

  /// Null while running.
  DateTimeColumn get endUtc => dateTime().nullable()();

  /// Minutes already banked before the last pause.
  IntColumn get bankedSeconds => integer().withDefault(const Constant(0))();

  /// Non-null while paused: the moment it was paused.
  DateTimeColumn get pausedAtUtc => dateTime().nullable()();
  IntColumn get seconds => integer().withDefault(const Constant(0))();
  TextColumn get note => text().withDefault(const Constant(''))();
  TextColumn get day => text()();
}

/// Morning / evening checklist items.
class RoutineItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get routine => text()(); // morning | evening
  TextColumn get name => text().withLength(min: 1, max: 60)();
  IntColumn get sort => integer().withDefault(const Constant(0))();
  BoolColumn get archived => boolean().withDefault(const Constant(false))();
}

class RoutineLogs extends Table {
  IntColumn get itemId => integer().references(RoutineItems, #id)();
  TextColumn get day => text()();
  @override
  Set<Column> get primaryKey => {itemId, day};
}

class Gratitude extends Table {
  TextColumn get day => text()();
  TextColumn get line => text()();
  @override
  Set<Column> get primaryKey => {day};
}

/// Local cache of Google Calendar events (primary + Nizam calendars).
class CalendarEvents extends Table {
  TextColumn get calendarId => text()();
  TextColumn get eventId => text()();
  TextColumn get title => text().withDefault(const Constant(''))();
  DateTimeColumn get startUtc => dateTime().nullable()();
  DateTimeColumn get endUtc => dateTime().nullable()();

  /// All-day events store their date (YYYY-MM-DD) instead of times.
  TextColumn get allDayDate => text().nullable()();
  TextColumn get location => text().nullable()();
  TextColumn get etag => text().nullable()();
  DateTimeColumn get updated => dateTime().nullable()();
  @override
  Set<Column> get primaryKey => {calendarId, eventId};
}

/// Per-calendar incremental sync token.
class SyncStates extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();
  @override
  Set<Column> get primaryKey => {key};
}

@DriftDatabase(
  tables: [
    Settings,
    Profiles,
    Tasks,
    Habits,
    HabitLogs,
    WaterLogs,
    SalahLogs,
    MoodLogs,
    SleepSessions,
    XpEntries,
    Rewards,
    Redemptions,
    Categories,
    MoneyEntries,
    Targets,
    TargetLogs,
    Ideas,
    FocusSessions,
    RoutineItems,
    RoutineLogs,
    Gratitude,
    CalendarEvents,
    SyncStates,
  ],
)
class AppDb extends _$AppDb {
  AppDb(super.e);

  @override
  int get schemaVersion => currentSchema;

  static const currentSchema = 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
      await _seed();
      await _seedV2();
    },
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await m.addColumn(tasks, tasks.remoteEtag);
        await m.addColumn(tasks, tasks.remoteUpdated);
        await m.addColumn(tasks, tasks.updatedAtUtc);
        for (final TableInfo t in [
          categories,
          moneyEntries,
          targets,
          targetLogs,
          ideas,
          focusSessions,
          routineItems,
          routineLogs,
          gratitude,
          calendarEvents,
          syncStates,
        ]) {
          await m.createTable(t);
        }
        await _seedV2();
      }
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );

  Future<void> _seed() async {
    await batch((b) {
      b.insertAll(profiles, [
        ProfilesCompanion.insert(name: 'Zillvox', color: const Value(0xFFD9B46A), sort: const Value(0)),
        ProfilesCompanion.insert(name: 'Triumphs of Talent', color: const Value(0xFF6CC4E6), sort: const Value(1)),
        ProfilesCompanion.insert(name: 'Personal', color: const Value(0xFF5FD39A), sort: const Value(2)),
      ]);
      b.insertAll(habits, [
        HabitsCompanion.insert(name: '10-minute walk', sort: const Value(0)),
        HabitsCompanion.insert(name: 'Read 10 pages', sort: const Value(1)),
        HabitsCompanion.insert(name: 'Gym', sort: const Value(2)),
      ]);
      b.insertAll(rewards, [
        RewardsCompanion.insert(name: 'Movie night', cost: 500),
        RewardsCompanion.insert(name: 'Order food', cost: 300),
        RewardsCompanion.insert(name: '1 hour of gaming', cost: 200),
      ]);
    });
  }

  static const spentCats = ['Food', 'Travel', 'Shopping', 'Bills', 'Health', 'Fun', 'Work', 'Other'];
  static const investedCats = ['SIP', 'Stocks', 'Crypto', 'Gold', 'FD', 'Other'];
  static const receivedCats = ['Salary', 'Retainer', 'Freelance', 'Gift', 'Refund', 'Other'];

  Future<void> _seedV2() async {
    await batch((b) {
      var i = 0;
      for (final (type, names) in [('spent', spentCats), ('invested', investedCats), ('received', receivedCats)]) {
        for (final n in names) {
          b.insert(categories, CategoriesCompanion.insert(name: n, type: type, sort: Value(i++)));
        }
      }
      b.insertAll(targets, [
        TargetsCompanion.insert(
          name: 'Collect leads',
          goal: 20,
          autoSource: const Value('leads'),
          sort: const Value(0),
        ),
        TargetsCompanion.insert(name: 'Research AI tools', goal: 3, sort: const Value(1)),
        TargetsCompanion.insert(
          name: 'Send outreach emails',
          goal: 10,
          autoSource: const Value('emails'),
          sort: const Value(2),
        ),
        TargetsCompanion.insert(name: 'Write a blog draft', goal: 1, sort: const Value(3)),
      ]);
      b.insertAll(routineItems, [
        RoutineItemsCompanion.insert(routine: 'morning', name: 'Drink a glass of water', sort: const Value(0)),
        RoutineItemsCompanion.insert(routine: 'morning', name: '5-minute plan', sort: const Value(1)),
        RoutineItemsCompanion.insert(routine: 'morning', name: 'Pick top 3 priorities', sort: const Value(2)),
        RoutineItemsCompanion.insert(routine: 'evening', name: 'Review today', sort: const Value(0)),
        RoutineItemsCompanion.insert(routine: 'evening', name: 'Plan tomorrow\'s top 3', sort: const Value(1)),
      ]);
    });
  }
}
