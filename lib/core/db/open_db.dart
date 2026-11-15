import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'app_db.dart';

Future<AppDb> openAppDb() async {
  final dir = await getApplicationDocumentsDirectory();
  final file = File(p.join(dir.path, 'nizam.sqlite'));
  return AppDb(NativeDatabase.createInBackground(file));
}

AppDb openMemoryDb() => AppDb(NativeDatabase.memory());

/// Used by tests to avoid "multiple databases" warnings.
void quietDriftWarnings() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
}
