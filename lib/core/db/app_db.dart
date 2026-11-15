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
  IntColumn get learningId => integer().nullable()();
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

// ---------------------------------------------------------------- v3 tables

/// Brain: notes with templates, tags and an optional work profile.
class Notes extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text().withDefault(const Constant(''))();
  TextColumn get body => text().withDefault(const Constant(''))();
  TextColumn get template => text().withDefault(const Constant('Thought dump'))();
  TextColumn get tags => text().withDefault(const Constant(''))();
  IntColumn get profileId => integer().nullable().references(Profiles, #id)();
  IntColumn get ideaId => integer().nullable().references(Ideas, #id)();
  IntColumn get meetingId => integer().nullable()();
  BoolColumn get pinned => boolean().withDefault(const Constant(false))();
  BoolColumn get archived => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAtUtc => dateTime()();
  DateTimeColumn get updatedAtUtc => dateTime()();
}

/// A recorded or uploaded meeting and its processing state.
class Meetings extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text().withDefault(const Constant('Meeting'))();
  DateTimeColumn get startedAtUtc => dateTime()();
  IntColumn get durationSec => integer().withDefault(const Constant(0))();

  /// recording | pending | transcribing | summarizing | done | error
  TextColumn get status => text().withDefault(const Constant('pending'))();

  /// JSON list of local audio file paths (chunks, in order).
  TextColumn get audioPaths => text().withDefault(const Constant('[]'))();

  /// JSON list of chunk transcripts already done (for resume / retry).
  TextColumn get chunkTranscripts => text().withDefault(const Constant('[]'))();
  TextColumn get transcript => text().withDefault(const Constant(''))();
  TextColumn get momJson => text().nullable()();
  TextColumn get emailDraft => text().nullable()();
  IntColumn get profileId => integer().nullable().references(Profiles, #id)();
  TextColumn get error => text().nullable()();
  IntColumn get attempts => integer().withDefault(const Constant(0))();
  TextColumn get driveFileIds => text().withDefault(const Constant('[]'))();
  BoolColumn get actionsCreated => boolean().withDefault(const Constant(false))();
}

class People extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 80)();
  TextColumn get phone => text().withDefault(const Constant(''))();
  TextColumn get email => text().withDefault(const Constant(''))();

  /// MM-DD or YYYY-MM-DD.
  TextColumn get birthday => text().nullable()();
  TextColumn get notes => text().withDefault(const Constant(''))();
  IntColumn get profileId => integer().nullable().references(Profiles, #id)();
  BoolColumn get archived => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAtUtc => dateTime()();
}

class Leads extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 120)();
  TextColumn get business => text().withDefault(const Constant(''))();
  TextColumn get phone => text().withDefault(const Constant(''))();
  TextColumn get email => text().withDefault(const Constant(''))();
  TextColumn get location => text().withDefault(const Constant(''))();
  TextColumn get mapsUrl => text().withDefault(const Constant(''))();
  TextColumn get source => text().withDefault(const Constant(''))();
  TextColumn get notes => text().withDefault(const Constant(''))();
  IntColumn get profileId => integer().nullable().references(Profiles, #id)();

  /// new | contacted | replied | interested | closed | lost
  TextColumn get stage => text().withDefault(const Constant('new'))();
  TextColumn get day => text()();
  DateTimeColumn get createdAtUtc => dateTime()();
  DateTimeColumn get updatedAtUtc => dateTime()();
  BoolColumn get archived => boolean().withDefault(const Constant(false))();
}

/// Call / message / email reminders for people and leads.
class FollowUps extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get personId => integer().nullable().references(People, #id)();
  IntColumn get leadId => integer().nullable().references(Leads, #id)();
  DateTimeColumn get dueAtUtc => dateTime()();
  TextColumn get note => text().withDefault(const Constant(''))();

  /// call | whatsapp | email | any
  TextColumn get channel => text().withDefault(const Constant('any'))();
  DateTimeColumn get doneAtUtc => dateTime().nullable()();
  TextColumn get origin => text().withDefault(const Constant('manual'))(); // manual | mail | meeting
}

class MailTemplates extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 80)();
  TextColumn get subject => text().withDefault(const Constant(''))();
  TextColumn get body => text().withDefault(const Constant(''))();
  DateTimeColumn get updatedAtUtc => dateTime()();
}

class MailSends extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get campaign => text()();
  TextColumn get toEmail => text()();
  TextColumn get toName => text().withDefault(const Constant(''))();
  TextColumn get subject => text()();
  TextColumn get body => text()();
  IntColumn get leadId => integer().nullable()();
  IntColumn get personId => integer().nullable()();

  /// queued | sent | failed | cancelled
  TextColumn get status => text().withDefault(const Constant('queued'))();
  DateTimeColumn get scheduledAtUtc => dateTime()();
  DateTimeColumn get sentAtUtc => dateTime().nullable()();
  TextColumn get error => text().nullable()();
  TextColumn get gmailId => text().nullable()();
}

/// Daily quest pool and the 3 picked each day.
class Quests extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text().withLength(min: 1, max: 100)();
  IntColumn get xp => integer().withDefault(const Constant(15))();
  BoolColumn get archived => boolean().withDefault(const Constant(false))();
}

class DailyQuests extends Table {
  TextColumn get day => text()();
  IntColumn get questId => integer().references(Quests, #id)();
  BoolColumn get done => boolean().withDefault(const Constant(false))();
  @override
  Set<Column> get primaryKey => {day, questId};
}

/// Weekly boss challenges (pool) and which one is active each week.
class Bosses extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text()();

  /// buildHours | leads | emails | pomodoros | waterDays | salahDays | tasks
  TextColumn get metric => text()();
  IntColumn get goal => integer()();
  IntColumn get xp => integer().withDefault(const Constant(150))();
  BoolColumn get archived => boolean().withDefault(const Constant(false))();
}

class WeekBosses extends Table {
  TextColumn get weekStart => text()();
  IntColumn get bossId => integer().references(Bosses, #id)();
  BoolColumn get claimed => boolean().withDefault(const Constant(false))();
  @override
  Set<Column> get primaryKey => {weekStart};
}

/// Streak shields: earned weekly, spent automatically on a missed day.
class ShieldEvents extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get kind => text()(); // earn | use
  TextColumn get day => text()();
}

/// Life Score snapshot per day (Year in Pixels, reports).
class DayScores extends Table {
  TextColumn get day => text()();
  IntColumn get score => integer()();
  @override
  Set<Column> get primaryKey => {day};
}

class LearningItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text().withLength(min: 1, max: 120)();
  TextColumn get kind => text().withDefault(const Constant('course'))(); // course | book | skill
  IntColumn get total => integer().withDefault(const Constant(10))();
  IntColumn get done => integer().withDefault(const Constant(0))();
  TextColumn get unit => text().withDefault(const Constant('lessons'))();
  BoolColumn get archived => boolean().withDefault(const Constant(false))();
}

class AppLimits extends Table {
  TextColumn get packageName => text()();
  TextColumn get label => text()();
  IntColumn get minutes => integer()();
  @override
  Set<Column> get primaryKey => {packageName};
}

class Reviews extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get kind => text()(); // weekly | monthly
  TextColumn get period => text()(); // week start or YYYY-MM
  TextColumn get worked => text().withDefault(const Constant(''))();
  TextColumn get didnt => text().withDefault(const Constant(''))();
  TextColumn get focus => text().withDefault(const Constant(''))();
  DateTimeColumn get createdAtUtc => dateTime()();
}

/// Remembers which smart nudges fired, so none repeats the same day.
class NudgeLog extends Table {
  TextColumn get key => text()();
  DateTimeColumn get atUtc => dateTime()();
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
    Notes,
    Meetings,
    People,
    Leads,
    FollowUps,
    MailTemplates,
    MailSends,
    Quests,
    DailyQuests,
    Bosses,
    WeekBosses,
    ShieldEvents,
    DayScores,
    LearningItems,
    AppLimits,
    Reviews,
    NudgeLog,
  ],
)
class AppDb extends _$AppDb {
  AppDb(super.e);

  @override
  int get schemaVersion => currentSchema;

  static const currentSchema = 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
      await _seed();
      await _seedV2();
      await _seedV3();
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
      if (from < 3) {
        // From v1 the table was just created with the latest columns above.
        if (from >= 2) await m.addColumn(focusSessions, focusSessions.learningId);
        for (final TableInfo t in [
          notes,
          meetings,
          people,
          leads,
          followUps,
          mailTemplates,
          mailSends,
          quests,
          dailyQuests,
          bosses,
          weekBosses,
          shieldEvents,
          dayScores,
          learningItems,
          appLimits,
          reviews,
          nudgeLog,
        ]) {
          await m.createTable(t);
        }
        await _seedV3();
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

  Future<void> _seedV3() async {
    final now = DateTime.now().toUtc();
    final zillvox = await (select(profiles)..where((p) => p.name.equals('Zillvox'))).getSingleOrNull();
    final n = (await select(targets).get()).length;
    await batch((b) {
      b.insertAll(targets, [
        TargetsCompanion.insert(
          name: 'Sales calls',
          goal: 10,
          profileId: Value(zillvox?.id),
          autoSource: const Value('calls'),
          sort: Value(n),
        ),
        TargetsCompanion.insert(name: 'Meetings booked', goal: 1, profileId: Value(zillvox?.id), sort: Value(n + 1)),
      ]);
    });
    await batch((b) {
      b.insertAll(quests, [
        for (final (q, xp) in [
          ('Message 3 old clients or contacts', 20),
          ('Learn one new AI tool for 15 minutes', 15),
          ('Inbox zero before Asr', 15),
          ('Walk 4,000 steps', 15),
          ('Read 10 pages', 10),
          ('Write a LinkedIn post', 20),
          ('No Instagram until Build Hour is done', 20),
          ('Plan tomorrow before Isha', 10),
          ('Drink 3 glasses before noon', 10),
          ('Call one lead you haven\'t called yet', 20),
          ('Tidy your desk for 5 minutes', 10),
          ('Revise one CS topic for 20 minutes', 15),
        ])
          QuestsCompanion.insert(title: q, xp: Value(xp)),
      ]);
      b.insertAll(bosses, [
        BossesCompanion.insert(title: '5 Build Hours this week', metric: 'buildHours', goal: 5),
        BossesCompanion.insert(title: 'Collect 100 leads', metric: 'leads', goal: 100),
        BossesCompanion.insert(title: 'Send 50 outreach emails', metric: 'emails', goal: 50),
        BossesCompanion.insert(title: '15 Pomodoros', metric: 'pomodoros', goal: 15),
        BossesCompanion.insert(title: 'Hit your water goal 6 days', metric: 'waterDays', goal: 6),
        BossesCompanion.insert(title: 'All 5 prayers on 6 days', metric: 'salahDays', goal: 6),
        BossesCompanion.insert(title: 'Finish 25 tasks', metric: 'tasks', goal: 25),
      ]);
      b.insertAll(mailTemplates, [
        MailTemplatesCompanion.insert(
          name: 'Intro: AI marketing help',
          subject: const Value('Quick idea for {{business}}'),
          body: const Value(
            'Hi {{name}},\n\nI came across {{business}} and had a quick idea to bring you more '
            'customers using simple AI tools and better follow-ups.\n\nWould a 15-minute call this week work?\n\n'
            'Best,\nHabeeb',
          ),
          updatedAtUtc: now,
        ),
      ]);
      b.insertAll(learningItems, [
        LearningItemsCompanion.insert(
          title: 'CS semester subjects',
          kind: const Value('course'),
          total: const Value(40),
          unit: const Value('topics'),
        ),
      ]);
    });
  }
}
