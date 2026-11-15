import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:nizam/core/ai/gemini_client.dart';
import 'package:nizam/features/meetings/domain/mom.dart';

void main() {
  group('MoM schema', () {
    test('schema has every field and required list', () {
      final s = momSchema(profiles: ['Zillvox', 'Personal']);
      final props = (s['properties'] as Map).keys.toSet();
      expect(
        props,
        containsAll([
          'title',
          'date',
          'attendees',
          'summary',
          'key_points',
          'decisions',
          'action_items',
          'follow_up_date',
          'work_profile',
        ]),
      );
      expect(s['required'], containsAll(['title', 'summary', 'action_items']));
      final ai = ((s['properties'] as Map)['action_items'] as Map)['items'] as Map;
      expect((ai['properties'] as Map).keys, containsAll(['task', 'owner', 'deadline']));
      expect(((s['properties'] as Map)['work_profile'] as Map)['enum'], ['Zillvox', 'Personal']);
    });

    test('parses a full answer', () {
      final m = Mom.fromJson(
        jsonDecode('''{
        "title":"Zillvox Q4 plan","date":"2026-11-15","attendees":["Habeeb","Rahul"],
        "summary":"Agreed on the Q4 lead plan.","key_points":["Target 200 leads"],"decisions":["Use LinkedIn ads"],
        "action_items":[{"task":"Send proposal","owner":"Habeeb","deadline":"2026-11-20"},{"task":"  "}],
        "follow_up_date":"2026-11-22","work_profile":"Zillvox"}''')
            as Map<String, Object?>,
      );
      expect(m.title, 'Zillvox Q4 plan');
      expect(m.attendees, ['Habeeb', 'Rahul']);
      expect(m.actionItems.single.deadline, '2026-11-20');
      expect(m.followUpDate, '2026-11-22');
      expect(m.workProfile, 'Zillvox');
      expect(Mom.fromJson(m.toJson()).toJson(), m.toJson(), reason: 'round-trips');
      expect(m.toText(), contains('• Send proposal — Habeeb (by 2026-11-20)'));
    });

    test('tolerates missing and bad fields', () {
      final m = Mom.fromJson({
        'date': 'next friday',
        'action_items': 'oops',
        'attendees': [null, 'A'],
        'work_profile': '',
      });
      expect(m.title, 'Meeting');
      expect(m.date, isNull);
      expect(m.actionItems, isEmpty);
      expect(m.attendees, ['A']);
      expect(m.workProfile, isNull);
      expect(Mom.fromJson({'follow_up_date': '2026-13-40'}).followUpDate, isNull);
    });
  });

  group('GeminiClient', () {
    test('sends the key in a header and the schema in generationConfig', () async {
      late http.Request seen;
      final c = GeminiClient(
        apiKey: 'k',
        model: 'gemini-test',
        httpClient: MockClient((r) async {
          seen = r;
          return http.Response(
            jsonEncode({
              'candidates': [
                {
                  'content': {
                    'parts': [
                      {
                        'text':
                            '{"title":"T","summary":"S","key_points":[],"decisions":[],"action_items":[],"attendees":[]}',
                      },
                    ],
                  },
                },
              ],
            }),
            200,
          );
        }),
      );
      final j = await c.generateJson([GeminiClient.text('hi')], schema: momSchema());
      expect(j['title'], 'T');
      expect(seen.url.path, '/v1beta/models/gemini-test:generateContent');
      expect(seen.headers['x-goog-api-key'], 'k');
      expect(seen.url.queryParameters, isEmpty, reason: 'key never in the URL');
      final body = jsonDecode(seen.body) as Map;
      expect((body['generationConfig'] as Map)['responseMimeType'], 'application/json');
    });

    test('rate limits are retryable, bad keys are not', () async {
      var calls = 0;
      final c = GeminiClient(
        apiKey: 'k',
        model: 'm',
        httpClient: MockClient((r) async {
          calls++;
          if (calls == 1) return http.Response('{"error":{"message":"quota"}}', 429);
          return http.Response('{"candidates":[{"content":{"parts":[{"text":"ok"}]}}]}', 200);
        }),
      );
      expect(await withRetry(() => c.generate([GeminiClient.text('x')]), base: Duration.zero), 'ok');
      expect(calls, 2);

      final bad = GeminiClient(
        apiKey: 'k',
        model: 'm',
        httpClient: MockClient((r) async => http.Response('{"error":{"message":"API key not valid"}}', 400)),
      );
      await expectLater(
        withRetry(() => bad.generate([GeminiClient.text('x')]), base: Duration.zero),
        throwsA(isA<GeminiError>().having((e) => e.retryable, 'retryable', false)),
      );
    });
  });
}
