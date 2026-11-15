import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers.dart';
import '../secrets.dart';
import 'gemini_client.dart';

class AiNotReady implements Exception {
  @override
  String toString() => 'Add your Gemini API key in Me → AI (Gemini) first.';
}

/// App-level AI helpers on top of [GeminiClient].
class AiService {
  AiService(this.ref);
  final Ref ref;

  Future<bool> get hasKey async => ((await ref.read(secretsProvider).read(Secrets.geminiKey)) ?? '').isNotEmpty;

  Future<GeminiClient> client() async {
    final key = (await ref.read(secretsProvider).read(Secrets.geminiKey)) ?? '';
    if (key.isEmpty) throw AiNotReady();
    return GeminiClient(apiKey: key, model: ref.read(settingsProvider).geminiModel);
  }

  Future<void> saveKey(String key) => ref.read(secretsProvider).write(Secrets.geminiKey, key.trim());
  Future<void> clearKey() => ref.read(secretsProvider).delete(Secrets.geminiKey);

  /// Cheap call to check the key and model work.
  Future<String> ping() async {
    final c = await client();
    try {
      return (await c.generate([GeminiClient.text('Reply with the single word: ready')])).trim();
    } finally {
      c.close();
    }
  }

  /// Speech → English text (voice notes, meeting chunks).
  Future<String> transcribe(File audio, {String prompt = 'Transcribe this audio. Write it in English (translate '
      'Hindi, Urdu or Telugu if spoken). Return only the text.'}) async {
    final c = await client();
    try {
      final part = await c.audioPart(audio);
      return (await withRetry(() => c.generate([part, GeminiClient.text(prompt)], temperature: 0.1))).trim();
    } finally {
      c.close();
    }
  }

  /// Free text in, text out.
  Future<String> write(String prompt, {String? system}) async {
    final c = await client();
    try {
      return (await withRetry(() => c.generate([GeminiClient.text(prompt)], system: system))).trim();
    } finally {
      c.close();
    }
  }

  Future<Map<String, Object?>> json(String prompt, Map<String, Object?> schema, {String? system}) async {
    final c = await client();
    try {
      return await withRetry(() => c.generateJson([GeminiClient.text(prompt)], schema: schema, system: system));
    } finally {
      c.close();
    }
  }
}

final aiProvider = Provider((ref) => AiService(ref));

const aiStyle = 'You help Habeeb, a digital marketer in Hyderabad (sales, marketing, research; Zillvox and '
    'Triumphs of Talent). Write clearly and warmly in simple English. No hype, no emojis unless asked.';
