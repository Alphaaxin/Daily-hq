import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class RecorderStatus {
  const RecorderStatus({this.recording = false, this.startedAt, this.parts = const []});
  final bool recording;
  final DateTime? startedAt;
  final List<String> parts;
}

/// Background audio recorder (Kotlin RecordingService), chunked every 10 min.
class Recorder {
  Recorder._();
  static const _ch = MethodChannel('nizam/native');

  static Future<Directory> newDir(String kind) async {
    final base = await getApplicationDocumentsDirectory();
    final d = Directory(p.join(base.path, kind, DateTime.now().millisecondsSinceEpoch.toString()));
    await d.create(recursive: true);
    return d;
  }

  /// Asks for the microphone (and notification) permission, then starts.
  static Future<bool> start(Directory dir, String title) async {
    if (!(await Permission.microphone.request()).isGranted) return false;
    try {
      return await _ch.invokeMethod<bool>('startRecording', {'dir': dir.path, 'title': title}) ?? false;
    } catch (_) {
      return false;
    }
  }

  static Future<List<String>> stop() async {
    try {
      final l = await _ch.invokeMethod<List<Object?>>('stopRecording') ?? const [];
      return l.whereType<String>().where((f) => File(f).existsSync() && File(f).lengthSync() > 0).toList();
    } catch (_) {
      return const [];
    }
  }

  static Future<RecorderStatus> status() async {
    try {
      final m = await _ch.invokeMapMethod<String, Object?>('recordingStatus') ?? const {};
      final started = (m['startedAt'] as num?)?.toInt() ?? 0;
      return RecorderStatus(
        recording: m['recording'] == true,
        startedAt: started == 0 ? null : DateTime.fromMillisecondsSinceEpoch(started, isUtc: true),
        parts: ((m['parts'] as List?) ?? const []).whereType<String>().toList(),
      );
    } catch (_) {
      return const RecorderStatus();
    }
  }
}
