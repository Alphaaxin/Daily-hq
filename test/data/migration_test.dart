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
    await verifier.migrateAndValidate(db, 2);

    final tasks = await db.select(db.tasks).get();
    expect(tasks.single.title, 'Keep me');
    expect(tasks.single.remoteEtag, isNull);
    final cats = await db.select(db.categories).get();
    expect(cats.where((c) => c.type == 'spent').map((c) => c.name), contains('Food'));
    expect(cats.where((c) => c.type == 'invested').map((c) => c.name), contains('SIP'));
    expect(cats.where((c) => c.type == 'received').map((c) => c.name), contains('Retainer'));
    expect(await db.select(db.targets).get(), hasLength(4));
    expect((await db.select(db.routineItems).get()).where((r) => r.routine == 'morning'), hasLength(3));
    await db.close();
  });

  test('fresh install creates v2 directly', () async {
    final db = openMemoryDb();
    expect(await db.select(db.categories).get(), isNotEmpty);
    expect(await db.customSelect('PRAGMA user_version').map((r) => r.read<int>('user_version')).getSingle(), 2);
    await db.close();
  });
}
