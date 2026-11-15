import 'package:drift_dev/api/migrations_native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nizam/core/db/app_db.dart';
import 'package:nizam/core/db/open_db.dart';

import '../generated_migrations/schema.dart';

void main() {
  quietDriftWarnings();
  late SchemaVerifier verifier;

  setUpAll(() => verifier = SchemaVerifier(GeneratedHelper()));

  test('upgrade v1 → v2 matches the v2 schema and seeds money data', () async {
    final schema = await verifier.schemaAt(1);
    // Some Phase 1 data that must survive.
    schema.rawDatabase.execute(
      "INSERT INTO tasks (title, created_at_utc, priority, tags) VALUES ('Keep me', 1763200000, 0, '')",
    );
    final db = AppDb(schema.newConnection());
    await verifier.migrateAndValidate(db, AppDb.currentSchema);

    final tasks = await db.select(db.tasks).get();
    expect(tasks.single.title, 'Keep me');
    expect(tasks.single.remoteEtag, isNull);
    final cats = await db.select(db.categories).get();
    expect(cats.where((c) => c.type == 'spent').map((c) => c.name), contains('Food'));
    expect(cats.where((c) => c.type == 'invested').map((c) => c.name), contains('SIP'));
    expect(cats.where((c) => c.type == 'received').map((c) => c.name), contains('Retainer'));
    expect(await db.select(db.targets).get(), hasLength(6)); // 4 daily + 2 sales (v3)
    expect((await db.select(db.routineItems).get()).where((r) => r.routine == 'morning'), hasLength(3));
    await db.close();
  });

  test('upgrade v2 → v3 keeps money data and seeds quests', () async {
    final schema = await verifier.schemaAt(2);
    schema.rawDatabase.execute("INSERT INTO categories (name, type, sort, archived) VALUES ('Food', 'spent', 0, 0)");
    schema.rawDatabase.execute(
      "INSERT INTO money_entries (amount_paise, type, category_id, note, at_utc, day) VALUES (25000, 'spent', 1, 'chai', 1763200000, '2026-11-15')",
    );
    final db = AppDb(schema.newConnection());
    await verifier.migrateAndValidate(db, 3);
    expect((await db.select(db.moneyEntries).get()).single.note, 'chai');
    expect(await db.select(db.quests).get(), hasLength(12));
    expect(await db.select(db.bosses).get(), isNotEmpty);
    expect(await db.select(db.mailTemplates).get(), hasLength(1));
    await db.close();
  });

  test('fresh install creates the latest schema directly', () async {
    final db = openMemoryDb();
    expect(await db.select(db.categories).get(), isNotEmpty);
    expect(
      await db.customSelect('PRAGMA user_version').map((r) => r.read<int>('user_version')).getSingle(),
      AppDb.currentSchema,
    );
    await db.close();
  });
}
