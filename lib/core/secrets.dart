import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// API keys live only in Android's encrypted storage, never in the repo or
/// the database. Used from Phase 2 (Gemini key, Google tokens).
class Secrets {
  Secrets([FlutterSecureStorage? s]) : _s = s ?? const FlutterSecureStorage();
  final FlutterSecureStorage _s;

  static const geminiKey = 'gemini_api_key';

  Future<String?> read(String key) => _s.read(key: key);
  Future<void> write(String key, String value) => _s.write(key: key, value: value);
  Future<void> delete(String key) => _s.delete(key: key);
}

final secretsProvider = Provider((ref) => Secrets());
