import 'dart:convert';

/// Mail merge: {{placeholder}} templates, CSV import and RFC 2822 messages.

final _ph = RegExp(r'\{\{\s*([a-zA-Z_][a-zA-Z0-9_ ]*?)\s*\}\}');

/// Placeholder names used in [text], lower-cased, in order of appearance.
List<String> placeholders(String text) {
  final seen = <String>{};
  return [
    for (final m in _ph.allMatches(text))
      if (seen.add(m.group(1)!.trim().toLowerCase())) m.group(1)!.trim().toLowerCase(),
  ];
}

class RenderResult {
  const RenderResult(this.text, this.missing);
  final String text;

  /// Placeholders that had no value (left empty in [text]).
  final List<String> missing;
  bool get ok => missing.isEmpty;
}

/// Fills placeholders (case-insensitive). `{{name|there}}` uses "there" when
/// name is empty. Unknown / empty ones are reported in [RenderResult.missing].
RenderResult render(String template, Map<String, String> values) {
  final v = {for (final e in values.entries) e.key.trim().toLowerCase(): e.value.trim()};
  final missing = <String>[];
  final out = template.replaceAllMapped(RegExp(r'\{\{\s*([a-zA-Z_][a-zA-Z0-9_ ]*?)\s*(?:\|([^}]*))?\}\}'), (m) {
    final key = m.group(1)!.trim().toLowerCase();
    final fallback = m.group(2);
    final val = v[key] ?? '';
    if (val.isNotEmpty) return val;
    if (fallback != null) return fallback.trim();
    if (!missing.contains(key)) missing.add(key);
    return '';
  });
  return RenderResult(out, missing);
}

/// First name for friendlier greetings ("Rahul Sharma" → "Rahul").
String firstName(String full) => full.trim().split(RegExp(r'\s+')).first;

/// Minimal RFC 4180 CSV parser (quotes, escaped quotes, commas/newlines in
/// quotes). Returns rows as maps keyed by lower-cased header.
List<Map<String, String>> parseCsv(String input) {
  final rows = <List<String>>[];
  var row = <String>[];
  final cell = StringBuffer();
  var q = false;
  final s = input.replaceAll('\r\n', '\n').replaceAll('\r', '\n');
  for (var i = 0; i < s.length; i++) {
    final c = s[i];
    if (q) {
      if (c == '"') {
        if (i + 1 < s.length && s[i + 1] == '"') {
          cell.write('"');
          i++;
        } else {
          q = false;
        }
      } else {
        cell.write(c);
      }
    } else if (c == '"') {
      q = true;
    } else if (c == ',') {
      row.add(cell.toString());
      cell.clear();
    } else if (c == '\n') {
      row.add(cell.toString());
      cell.clear();
      rows.add(row);
      row = <String>[];
    } else {
      cell.write(c);
    }
  }
  if (cell.isNotEmpty || row.isNotEmpty) {
    row.add(cell.toString());
    rows.add(row);
  }
  final clean = rows.where((r) => r.any((x) => x.trim().isNotEmpty)).toList();
  if (clean.isEmpty) return const [];
  final header = clean.first.map((h) => h.trim().toLowerCase().replaceFirst('﻿', '')).toList();
  return [
    for (final r in clean.skip(1))
      {for (var i = 0; i < header.length; i++) header[i]: i < r.length ? r[i].trim() : ''},
  ];
}

final _email = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]{2,}$');
bool isEmail(String s) => _email.hasMatch(s.trim());

String _encodeHeader(String v) =>
    RegExp(r'^[\x20-\x7E]*$').hasMatch(v) ? v : '=?UTF-8?B?${base64.encode(utf8.encode(v))}?=';

/// RFC 2822 message, base64url-encoded for Gmail's users.messages.send.
String gmailRaw({required String to, String toName = '', required String subject, required String body, String? from}) {
  final toHeader = toName.trim().isEmpty ? to : '${_encodeHeader(toName.trim())} <$to>';
  final msg = [
    if (from != null) 'From: $from',
    'To: $toHeader',
    'Subject: ${_encodeHeader(subject)}',
    'MIME-Version: 1.0',
    'Content-Type: text/plain; charset="UTF-8"',
    'Content-Transfer-Encoding: base64',
    '',
    base64.encode(utf8.encode(body)).replaceAllMapped(RegExp(r'.{1,76}'), (m) => '${m.group(0)}\r\n'),
  ].join('\r\n');
  return base64Url.encode(utf8.encode(msg)).replaceAll('=', '');
}

/// Delay before each e-mail: 25–45 s, so Gmail doesn't flag the burst.
Duration sendGap(int index, {int seed = 7}) => Duration(seconds: 25 + ((index * 7919 + seed) % 21));

/// How many more e-mails may go out today.
int remainingToday({required int sentToday, required int dailyLimit}) => (dailyLimit - sentToday).clamp(0, dailyLimit);
