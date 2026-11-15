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
  ],
)
class AppDb extends _$AppDb {
  AppDb(super.e);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
      await _seed();
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
}
