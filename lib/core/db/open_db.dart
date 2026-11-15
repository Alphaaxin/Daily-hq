import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'app_db.dart';

Future<File> appDbFile() async {
  final dir = await getApplicationDocumentsDirectory();
  return File(p.join(dir.path, 'nizam.sqlite'));
}

Future<AppDb> openAppDb() async => AppDb(NativeDatabase.createInBackground(await appDbFile()));

AppDb openMemoryDb() => AppDb(NativeDatabase.memory());

/// Used by tests to avoid "multiple databases" warnings.
void quietDriftWarnings() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
}
