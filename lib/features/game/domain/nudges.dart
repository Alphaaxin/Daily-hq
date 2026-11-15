/// Smart nudges: small context rules, each firing at most once a day, never
/// during quiet hours, and each type can be switched off.
class NudgeContext {
  const NudgeContext({
    required this.day,
    required this.localHour,
    required this.quiet,
    this.off = const {},
    this.targetsLeft = 0,
    this.buildMinutesToday = 0,
    this.buildModuleOn = true,
    this.meetingsAwaitingActions = 0,
    this.budgetWarnings = const [],
    this.overLimitApps = const [],
    this.isReviewDay = false,
    this.reviewDone = false,
    this.waterLeft = 0,
    this.eveningHour = 21,
  });

  final String day;
  final int localHour;
  final bool quiet;
  final Set<String> off;
  final int targetsLeft;
  final int buildMinutesToday;
  final bool buildModuleOn;
  final int meetingsAwaitingActions;

  /// e.g. "₹500 left for Food this month".
  final List<String> budgetWarnings;

  /// App labels over their daily limit.
  final List<String> overLimitApps;
  final bool isReviewDay;
  final bool reviewDone;
  final int waterLeft;
  final int eveningHour;
}

class Nudge {
  const Nudge(this.type, this.title, this.body, this.route);
  final String type;
  final String title;
  final String body;
  final String route;

  /// Once per day per type.
  String key(String day) => '$type:$day';
}

const nudgeTypes = {
  'targets': 'Evening target sprint',
  'build': 'Build Hour reminder',
  'meeting': 'Meeting follow-ups',
  'budget': 'Budget warnings',
  'screen': 'Screen-time swaps',
  'review': 'Weekly review',
  'water': 'Water catch-up',
};

List<Nudge> evaluateNudges(NudgeContext c, {Set<String> alreadySent = const {}}) {
  if (c.quiet) return const [];
  final out = <Nudge>[];
  void add(Nudge n) {
    if (c.off.contains(n.type) || alreadySent.contains(n.key(c.day))) return;
    out.add(n);
  }

  if (c.localHour >= c.eveningHour && c.localHour < 24 && c.targetsLeft > 0) {
    add(
      Nudge(
        'targets',
        'Quick 15-min lead sprint?',
        '${c.targetsLeft} daily target${c.targetsLeft == 1 ? '' : 's'} still open. '
            'One focused sprint closes the day strong.',
        '/today',
      ),
    );
  }
  if (c.buildModuleOn && c.buildMinutesToday < 15 && c.localHour >= 16 && c.localHour < c.eveningHour + 2) {
    add(
      const Nudge('build', 'Build Hour time', 'Close Instagram, open your idea list, and start the timer.', '/focus'),
    );
  }
  if (c.meetingsAwaitingActions > 0) {
    add(
      Nudge(
        'meeting',
        'Turn action items into tasks?',
        '${c.meetingsAwaitingActions} meeting'
            '${c.meetingsAwaitingActions == 1 ? ' has' : 's have'} minutes ready.',
        '/notes',
      ),
    );
  }
  if (c.budgetWarnings.isNotEmpty) {
    add(Nudge('budget', 'Budget check', c.budgetWarnings.first, '/money'));
  }
  if (c.overLimitApps.isNotEmpty) {
    add(
      Nudge(
        'screen',
        '${c.overLimitApps.first} limit reached',
        'Swap the next scroll for a quest: open Solo Leveling and pick one.',
        '/rewards',
      ),
    );
  }
  if (c.isReviewDay && !c.reviewDone && c.localHour >= 18) {
    add(
      const Nudge(
        'review',
        'Weekly review',
        'Five minutes: what worked, what didn\'t, and next week\'s focus.',
        '/review',
      ),
    );
  }
  if (c.waterLeft >= 4 && c.localHour >= 17 && c.localHour < 22) {
    add(Nudge('water', 'Water catch-up', '${c.waterLeft} glasses to go. Fill a bottle now.', '/today'));
  }
  return out;
}
