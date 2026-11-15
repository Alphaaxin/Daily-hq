import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:nizam/features/mail/domain/mail_merge.dart';

void main() {
  group('placeholders', () {
    test('finds unique names, case-insensitive', () {
      expect(placeholders('Hi {{Name}}, {{ business }} and {{name}} again {{college}}'), [
        'name',
        'business',
        'college',
      ]);
      expect(placeholders('no tags'), isEmpty);
    });

    test('renders values and reports missing ones', () {
      final r = render('Hi {{name}}, loved {{Business}}! {{college}}', {'NAME': 'Rahul', 'business': 'Chai Point'});
      expect(r.text, 'Hi Rahul, loved Chai Point! ');
      expect(r.missing, ['college']);
      expect(r.ok, isFalse);
    });

    test('fallback after a pipe', () {
      expect(render('Hi {{name|there}},', {}).text, 'Hi there,');
      expect(render('Hi {{name|there}},', {'name': 'Ayesha'}).text, 'Hi Ayesha,');
      expect(render('Hi {{name|there}},', {}).ok, isTrue);
    });

    test('first name', () {
      expect(firstName('  Rahul  Sharma '), 'Rahul');
    });
  });

  group('CSV', () {
    test('headers, quotes, commas and newlines in cells', () {
      final rows = parseCsv(
        '﻿Name,Email,Business\r\n"Sharma, Rahul",rahul@x.com,"Chai ""Point"""\n'
        'Ayesha,ayesha@y.in,"Line1\nLine2"\n\n',
      );
      expect(rows, hasLength(2));
      expect(rows[0], {'name': 'Sharma, Rahul', 'email': 'rahul@x.com', 'business': 'Chai "Point"'});
      expect(rows[1]['business'], 'Line1\nLine2');
    });

    test('short rows are padded', () {
      expect(parseCsv('a,b,c\n1')[0], {'a': '1', 'b': '', 'c': ''});
      expect(parseCsv(''), isEmpty);
    });

    test('email check', () {
      expect(isEmail('a@b.co'), isTrue);
      expect(isEmail('not an email'), isFalse);
      expect(isEmail('a@b'), isFalse);
    });
  });

  group('Gmail message', () {
    test('base64url RFC 2822 with UTF-8 subject and name', () {
      final raw = gmailRaw(to: 'rahul@x.com', toName: 'Rahul', subject: 'Quick idea ✨', body: 'Namaste 🙏\nLine 2');
      expect(raw.contains('='), isFalse);
      final msg = utf8.decode(base64Url.decode(base64Url.normalize(raw)));
      expect(msg, contains('To: Rahul <rahul@x.com>'));
      expect(msg, contains('Subject: =?UTF-8?B?'));
      final body = msg.split('\r\n\r\n').last.replaceAll('\r\n', '');
      expect(utf8.decode(base64.decode(body)), 'Namaste 🙏\nLine 2');
    });

    test('ASCII subject stays readable', () {
      final msg = utf8.decode(
        base64Url.decode(base64Url.normalize(gmailRaw(to: 'a@b.co', subject: 'Hello', body: 'x'))),
      );
      expect(msg, contains('Subject: Hello'));
    });
  });

  test('throttle gaps stay between 25 and 45 seconds; daily limit', () {
    final gaps = [for (var i = 0; i < 50; i++) sendGap(i).inSeconds];
    expect(gaps.every((g) => g >= 25 && g <= 45), isTrue);
    expect(remainingToday(sentToday: 280, dailyLimit: 300), 20);
    expect(remainingToday(sentToday: 320, dailyLimit: 300), 0);
  });
}
