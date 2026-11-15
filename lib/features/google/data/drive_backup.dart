import 'dart:async';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:googleapis/drive/v3.dart' as gdrive;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3/sqlite3.dart' as sql;

import '../../../core/db/app_db.dart';
import '../../../core/db/open_db.dart';
import '../../../core/providers.dart';
import '../domain/backup_names.dart';
import 'google_auth.dart';

class BackupInfo {
  const BackupInfo(this.id, this.name, this.at, this.bytes);
  final String id;
  final String name;
  final DateTime at;
  final int bytes;
}

/// Gzipped copies of the database in Drive's hidden app-data folder.
class DriveBackup {
  DriveBackup(this.ref);
  final Ref ref;

  Future<gdrive.DriveApi> _api() async {
    final c = await ref.read(googleAuthProvider).client();
    if (c == null) throw Exception('Sign in to Google first (Me → Google account).');
    return gdrive.DriveApi(c);
  }

  /// Uploads a fresh backup and keeps the newest 14. Returns the file name.
  Future<String> backupNow() async {
    final api = await _api();
    final db = ref.read(dbProvider);
    final tmp = await getTemporaryDirectory();
    final raw = File(p.join(tmp.path, 'nizam-snapshot.db'));
    if (raw.existsSync()) raw.deleteSync();
    // A consistent copy even while the app keeps writing.
    await db.customStatement('VACUUM INTO ?', [raw.path]);
    final gz = gzip.encode(await raw.readAsBytes());
    raw.deleteSync();
    final name = backupName(DateTime.now().toUtc());
    await api.files.create(
      gdrive.File(name: name, parents: ['appDataFolder'], mimeType: 'application/gzip'),
      uploadMedia: gdrive.Media(Stream.value(gz), gz.length, contentType: 'application/gzip'),
    );
    final all = await list(api: api);
    for (final old in backupsToPrune(all.map((b) => b.name))) {
      final f = all.firstWhere((b) => b.name == old);
      await api.files.delete(f.id);
    }
    await ref.read(settingsRepoProvider).set('lastBackupUtc', DateTime.now().toUtc().toIso8601String());
    return name;
  }

  Future<List<BackupInfo>> list({gdrive.DriveApi? api}) async {
    api ??= await _api();
    final res = await api.files.list(
      spaces: 'appDataFolder',
      orderBy: 'createdTime desc',
      $fields: 'files(id,name,createdTime,size)',
      pageSize: 50,
    );
    return [
      for (final f in res.files ?? const <gdrive.File>[])
        if (backupTime(f.name ?? '') != null)
          BackupInfo(f.id!, f.name!, backupTime(f.name!)!, int.tryParse(f.size ?? '') ?? 0),
    ];
  }

  /// Downloads a backup, checks it, and swaps it in for the current database.
  /// The app must be restarted afterwards.
  Future<void> restore(BackupInfo b) async {
    final api = await _api();
    final media = await api.files.get(b.id, downloadOptions: gdrive.DownloadOptions.fullMedia) as gdrive.Media;
    final bytes = <int>[];
    await for (final chunk in media.stream) {
      bytes.addAll(chunk);
    }
    final tmp = await getTemporaryDirectory();
    final file = File(p.join(tmp.path, 'nizam-restore.db'))..writeAsBytesSync(gzip.decode(bytes));
    final check = sql.sqlite3.open(file.path);
    try {
      final v = check.select('PRAGMA user_version').first.values.first as int;
      final ok = check.select("SELECT name FROM sqlite_master WHERE type='table' AND name='tasks'").isNotEmpty;
      if (!ok) throw Exception('That file is not a Nizam backup.');
      if (v > AppDb.currentSchema) {
        throw Exception('Backup is from a newer Nizam (v$v). Update the app first.');
      }
    } finally {
      check.dispose();
    }
    await ref.read(dbProvider).close();
    final target = await appDbFile();
    for (final suffix in ['', '-wal', '-shm']) {
      final f = File('${target.path}$suffix');
      if (f.existsSync()) f.deleteSync();
    }
    file.copySync(target.path);
    file.deleteSync();
  }
}

final driveBackupProvider = Provider((ref) => DriveBackup(ref));
