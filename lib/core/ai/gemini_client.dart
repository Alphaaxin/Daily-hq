import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

class GeminiError implements Exception {
  GeminiError(this.message, {this.status, this.retryable = false});
  final String message;
  final int? status;
  final bool retryable;
  @override
  String toString() => 'Gemini: $message';
}

/// Minimal Gemini REST client: text / JSON generation, inline audio, and the
/// Files API for longer recordings. The key is passed in; it is stored in
/// Android secure storage and never written to the database or repo.
class GeminiClient {
  GeminiClient({required this.apiKey, required this.model, http.Client? httpClient})
      : _http = httpClient ?? http.Client();

  final String apiKey;
  final String model;
  final http.Client _http;

  static const _base = 'https://generativelanguage.googleapis.com';
  static const inlineLimitBytes = 14 * 1024 * 1024; // keep request under ~20 MB after base64

  Map<String, String> get _headers => {'x-goog-api-key': apiKey, 'content-type': 'application/json'};

  /// Generates text, or JSON matching [schema] when given.
  Future<String> generate(
    List<Map<String, Object?>> parts, {
    String? system,
    Map<String, Object?>? schema,
    double temperature = 0.4,
  }) async {
    final body = <String, Object?>{
      'contents': [
        {'role': 'user', 'parts': parts},
      ],
      if (system != null)
        'systemInstruction': {
          'parts': [
            {'text': system},
          ],
        },
      'generationConfig': {
        'temperature': temperature,
        if (schema != null) 'responseMimeType': 'application/json',
        if (schema != null) 'responseSchema': schema,
      },
    };
    final res = await _http
        .post(Uri.parse('$_base/v1beta/models/$model:generateContent'), headers: _headers, body: jsonEncode(body))
        .timeout(const Duration(minutes: 5));
    if (res.statusCode != 200) throw _error(res);
    final j = jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, Object?>;
    final cands = (j['candidates'] as List?) ?? const [];
    if (cands.isEmpty) {
      final block = (j['promptFeedback'] as Map?)?['blockReason'];
      throw GeminiError('No answer${block == null ? '' : ' ($block)'}');
    }
    final content = (cands.first as Map)['content'] as Map?;
    final text = ((content?['parts'] as List?) ?? const [])
        .map((p) => (p as Map)['text'] as String? ?? '')
        .join();
    if (text.trim().isEmpty) throw GeminiError('Empty answer', retryable: true);
    return text;
  }

  Future<Map<String, Object?>> generateJson(
    List<Map<String, Object?>> parts, {
    String? system,
    required Map<String, Object?> schema,
  }) async {
    final t = await generate(parts, system: system, schema: schema, temperature: 0.2);
    try {
      return jsonDecode(t) as Map<String, Object?>;
    } catch (_) {
      throw GeminiError('Answer was not valid JSON', retryable: true);
    }
  }

  static Map<String, Object?> text(String t) => {'text': t};

  static String audioMime(String path) => switch (path.split('.').last.toLowerCase()) {
        'mp3' => 'audio/mpeg',
        'wav' => 'audio/wav',
        'ogg' || 'opus' => 'audio/ogg',
        'aac' => 'audio/aac',
        'flac' => 'audio/flac',
        'amr' => 'audio/amr',
        '3gp' => 'audio/3gpp',
        _ => 'audio/mp4',
      };

  static Map<String, Object?> inlineAudio(Uint8List bytes, String mime) => {
        'inline_data': {'mime_type': mime, 'data': base64Encode(bytes)},
      };

  static Map<String, Object?> fileRef(String uri, String mime) => {
        'file_data': {'mime_type': mime, 'file_uri': uri},
      };

  /// Audio as a request part: inline when small, otherwise via the Files API.
  Future<Map<String, Object?>> audioPart(File f, {String? mime}) async {
    mime ??= audioMime(f.path);
    final bytes = await f.readAsBytes();
    if (bytes.length <= inlineLimitBytes) return inlineAudio(bytes, mime);
    return fileRef(await uploadFile(bytes, mime, displayName: f.uri.pathSegments.last), mime);
  }

  /// Resumable upload to the Files API; waits until the file is ACTIVE.
  Future<String> uploadFile(Uint8List bytes, String mime, {String displayName = 'audio'}) async {
    final start = await _http.post(
      Uri.parse('$_base/upload/v1beta/files'),
      headers: {
        'x-goog-api-key': apiKey,
        'X-Goog-Upload-Protocol': 'resumable',
        'X-Goog-Upload-Command': 'start',
        'X-Goog-Upload-Header-Content-Length': '${bytes.length}',
        'X-Goog-Upload-Header-Content-Type': mime,
        'content-type': 'application/json',
      },
      body: jsonEncode({
        'file': {'display_name': displayName},
      }),
    );
    if (start.statusCode != 200) throw _error(start);
    final url = start.headers['x-goog-upload-url'];
    if (url == null) throw GeminiError('Upload URL missing', retryable: true);
    final up = await _http
        .post(
          Uri.parse(url),
          headers: {
            'Content-Length': '${bytes.length}',
            'X-Goog-Upload-Offset': '0',
            'X-Goog-Upload-Command': 'upload, finalize',
          },
          body: bytes,
        )
        .timeout(const Duration(minutes: 10));
    if (up.statusCode != 200) throw _error(up);
    final file = (jsonDecode(up.body) as Map)['file'] as Map;
    final name = file['name'] as String;
    var state = file['state'] as String? ?? 'PROCESSING';
    var uri = file['uri'] as String;
    for (var i = 0; i < 60 && state == 'PROCESSING'; i++) {
      await Future<void>.delayed(const Duration(seconds: 3));
      final r = await _http.get(Uri.parse('$_base/v1beta/$name'), headers: _headers);
      if (r.statusCode != 200) throw _error(r);
      final j = jsonDecode(r.body) as Map;
      state = j['state'] as String? ?? 'ACTIVE';
      uri = j['uri'] as String? ?? uri;
    }
    if (state != 'ACTIVE') throw GeminiError('File processing failed ($state)', retryable: true);
    return uri;
  }

  GeminiError _error(http.Response r) {
    var msg = 'HTTP ${r.statusCode}';
    try {
      msg = ((jsonDecode(r.body) as Map)['error'] as Map)['message'] as String? ?? msg;
    } catch (_) {}
    final retry = r.statusCode == 429 || r.statusCode >= 500;
    if (r.statusCode == 400 && msg.contains('API key')) msg = 'Your Gemini API key was rejected. Check it in Me → AI.';
    return GeminiError(msg, status: r.statusCode, retryable: retry);
  }

  void close() => _http.close();
}

/// Retries [job] on retryable errors with exponential backoff.
Future<T> withRetry<T>(Future<T> Function() job, {int attempts = 3, Duration base = const Duration(seconds: 4)}) async {
  for (var i = 0;; i++) {
    try {
      return await job();
    } on GeminiError catch (e) {
      if (!e.retryable || i >= attempts - 1) rethrow;
    } on SocketException {
      if (i >= attempts - 1) rethrow;
    } on TimeoutException {
      if (i >= attempts - 1) rethrow;
    }
    await Future<void>.delayed(base * (1 << i));
  }
}
