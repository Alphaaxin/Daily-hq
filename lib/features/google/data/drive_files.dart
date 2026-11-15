import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:googleapis/drive/v3.dart' as gdrive;

import 'google_auth.dart';

/// Visible Drive files (drive.file scope: only files this app created).
class DriveFiles {
  DriveFiles(this.ref);
  final Ref ref;

  static const rootName = 'Solo Leveling';

  Future<gdrive.DriveApi?> _api() async {
    final c = await ref.read(googleAuthProvider).client();
    return c == null ? null : gdrive.DriveApi(c);
  }

  Future<String> _folder(gdrive.DriveApi api, String name, String? parent) async {
    final q = "mimeType='application/vnd.google-apps.folder' and name='${name.replaceAll("'", "\\'")}' and trashed=false"
        "${parent == null ? '' : " and '$parent' in parents"}";
    final found = await api.files.list(q: q, spaces: 'drive', $fields: 'files(id)');
    if (found.files?.isNotEmpty ?? false) return found.files!.first.id!;
    final f = await api.files.create(gdrive.File(
      name: name,
      mimeType: 'application/vnd.google-apps.folder',
      parents: parent == null ? null : [parent],
    ));
    return f.id!;
  }

  /// Uploads files to "Solo Leveling/Meetings/<subfolder>". Returns Drive ids,
  /// or null when not signed in.
  Future<List<String>?> uploadMeeting(String subfolder, List<File> files) async {
    final api = await _api();
    if (api == null) return null;
    final root = await _folder(api, rootName, null);
    final meetings = await _folder(api, 'Meetings', root);
    final dir = await _folder(api, subfolder, meetings);
    final ids = <String>[];
    for (final f in files) {
      final len = await f.length();
      final name = f.uri.pathSegments.last;
      final mime = name.endsWith('.txt') ? 'text/plain' : 'audio/mp4';
      final up = await api.files.create(
        gdrive.File(name: name, parents: [dir]),
        uploadMedia: gdrive.Media(f.openRead(), len, contentType: mime),
      );
      ids.add(up.id!);
    }
    return ids;
  }
}

final driveFilesProvider = Provider((ref) => DriveFiles(ref));
