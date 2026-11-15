/// Structured Minutes of Meeting, produced by Gemini with a response schema.
class ActionItem {
  const ActionItem({required this.task, this.owner = '', this.deadline});
  final String task;
  final String owner;

  /// YYYY-MM-DD or null.
  final String? deadline;

  Map<String, Object?> toJson() => {'task': task, 'owner': owner, 'deadline': deadline};
  static ActionItem fromJson(Map<String, Object?> j) => ActionItem(
        task: (j['task'] as String? ?? '').trim(),
        owner: (j['owner'] as String? ?? '').trim(),
        deadline: _date(j['deadline']),
      );
}

class Mom {
  const Mom({
    required this.title,
    this.date,
    this.attendees = const [],
    this.summary = '',
    this.keyPoints = const [],
    this.decisions = const [],
    this.actionItems = const [],
    this.followUpDate,
    this.workProfile,
  });

  final String title;
  final String? date;
  final List<String> attendees;
  final String summary;
  final List<String> keyPoints;
  final List<String> decisions;
  final List<ActionItem> actionItems;
  final String? followUpDate;
  final String? workProfile;

  Mom copyWith({String? title, List<String>? attendees}) => Mom(
        title: title ?? this.title,
        date: date,
        attendees: attendees ?? this.attendees,
        summary: summary,
        keyPoints: keyPoints,
        decisions: decisions,
        actionItems: actionItems,
        followUpDate: followUpDate,
        workProfile: workProfile,
      );

  Map<String, Object?> toJson() => {
        'title': title,
        'date': date,
        'attendees': attendees,
        'summary': summary,
        'key_points': keyPoints,
        'decisions': decisions,
        'action_items': actionItems.map((a) => a.toJson()).toList(),
        'follow_up_date': followUpDate,
        'work_profile': workProfile,
      };

  /// Tolerant parser: missing lists become empty, bad dates become null,
  /// blank action items are dropped.
  static Mom fromJson(Map<String, Object?> j) {
    List<String> strs(Object? v) =>
        (v is List ? v : const []).map((e) => '$e'.trim()).where((s) => s.isNotEmpty && s != 'null').toList();
    final title = (j['title'] as String? ?? '').trim();
    return Mom(
      title: title.isEmpty ? 'Meeting' : title,
      date: _date(j['date']),
      attendees: strs(j['attendees']),
      summary: (j['summary'] as String? ?? '').trim(),
      keyPoints: strs(j['key_points']),
      decisions: strs(j['decisions']),
      actionItems: (j['action_items'] is List ? j['action_items'] as List : const [])
          .whereType<Map>()
          .map((m) => ActionItem.fromJson(m.cast<String, Object?>()))
          .where((a) => a.task.isNotEmpty)
          .toList(),
      followUpDate: _date(j['follow_up_date']),
      workProfile: (j['work_profile'] as String?)?.trim().isEmpty ?? true ? null : (j['work_profile'] as String).trim(),
    );
  }

  /// Plain-text version for notes, e-mails and sharing.
  String toText() {
    final b = StringBuffer('$title${date == null ? '' : ' ($date)'}\n');
    if (attendees.isNotEmpty) b.writeln('Attendees: ${attendees.join(', ')}');
    if (summary.isNotEmpty) b.writeln('\nSummary\n$summary');
    void list(String h, List<String> l) {
      if (l.isEmpty) return;
      b.writeln('\n$h');
      for (final x in l) {
        b.writeln('• $x');
      }
    }

    list('Key points', keyPoints);
    list('Decisions', decisions);
    list('Action items', [
      for (final a in actionItems)
        '${a.task}${a.owner.isEmpty ? '' : ' — ${a.owner}'}${a.deadline == null ? '' : ' (by ${a.deadline})'}',
    ]);
    if (followUpDate != null) b.writeln('\nFollow-up: $followUpDate');
    return b.toString().trim();
  }
}

String? _date(Object? v) {
  if (v is! String) return null;
  final m = RegExp(r'^(\d{4})-(\d{2})-(\d{2})').firstMatch(v.trim());
  if (m == null) return null;
  final mo = int.parse(m.group(2)!), d = int.parse(m.group(3)!);
  if (mo < 1 || mo > 12 || d < 1 || d > 31) return null;
  return m.group(0);
}

/// Gemini response schema (OpenAPI subset) for [Mom].
Map<String, Object?> momSchema({List<String> profiles = const []}) => {
      'type': 'OBJECT',
      'properties': {
        'title': {'type': 'STRING', 'description': 'Short meeting title'},
        'date': {'type': 'STRING', 'description': 'YYYY-MM-DD', 'nullable': true},
        'attendees': {
          'type': 'ARRAY',
          'items': {'type': 'STRING'},
        },
        'summary': {'type': 'STRING', 'description': '3-6 sentence summary in English'},
        'key_points': {
          'type': 'ARRAY',
          'items': {'type': 'STRING'},
        },
        'decisions': {
          'type': 'ARRAY',
          'items': {'type': 'STRING'},
        },
        'action_items': {
          'type': 'ARRAY',
          'items': {
            'type': 'OBJECT',
            'properties': {
              'task': {'type': 'STRING'},
              'owner': {'type': 'STRING'},
              'deadline': {'type': 'STRING', 'description': 'YYYY-MM-DD', 'nullable': true},
            },
            'required': ['task'],
          },
        },
        'follow_up_date': {'type': 'STRING', 'description': 'YYYY-MM-DD', 'nullable': true},
        'work_profile': {
          'type': 'STRING',
          'nullable': true,
          if (profiles.isNotEmpty) 'enum': profiles,
        },
      },
      'required': ['title', 'summary', 'key_points', 'decisions', 'action_items', 'attendees'],
      'propertyOrdering': [
        'title',
        'date',
        'attendees',
        'summary',
        'key_points',
        'decisions',
        'action_items',
        'follow_up_date',
        'work_profile',
      ],
    };

const transcribePrompt =
    'Transcribe this meeting audio. Speakers may use English, Hindi, Urdu, Telugu or a mix. '
    'Write the transcript in English only (translate anything else faithfully). '
    'Label speakers as "Speaker 1", "Speaker 2"… or by name when they say it. '
    'Return only the transcript text.';

String momPrompt({required String transcript, required String today, required List<String> profiles}) =>
    'Today is $today (Asia/Kolkata). From this meeting transcript, write Minutes of Meeting in English. '
    'Resolve relative dates ("next Friday") to YYYY-MM-DD. Keep action items concrete and assign owners when stated. '
    '${profiles.isEmpty ? '' : 'Pick work_profile from: ${profiles.join(', ')} (or null).'}\n\nTRANSCRIPT:\n$transcript';
