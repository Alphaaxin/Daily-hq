/// XP values for every meaningful action. Source keys are unique per day, so
/// awarding the same key twice on one day never double-counts.
class Xp {
  Xp._();

  static const goodMorning = 10;
  static const goodMorningOnTarget = 15;
  static const task = 10;
  static const habit = 5;
  static const allHabitsBonus = 10;
  static const waterGoal = 15;
  static const salahOnTime = 5;
  static const salahLate = 3;
  static const mood = 2;

  /// Shown on the Rewards tab ("How you earn XP").
  static const table = <(String, int)>[
    ('Good Morning logged', goodMorning),
    ('…and you hit your sleep target', goodMorningOnTarget),
    ('Task completed', task),
    ('Habit done', habit),
    ('All habits done (bonus)', allHabitsBonus),
    ('Water goal reached', waterGoal),
    ('Salah on time', salahOnTime),
    ('Salah prayed late', salahLate),
    ('Mood check', mood),
  ];

  static String taskKey(int id) => 'task:$id';
  static String habitKey(int id) => 'habit:$id';
  static const allHabitsKey = 'habits:all';
  static const waterKey = 'water:goal';
  static String salahKey(String prayerDate, String prayer) => 'salah:$prayerDate:$prayer';
  static const moodKey = 'mood';
  static const sleepKey = 'sleep:morning';
}

/// Pure, in-memory model of the XP ledger. The database repository applies the
/// same rules; this exists so the rules are unit-testable.
class XpLedgerModel {
  final Map<String, int> _entries = {}; // "$day|$source" -> amount
  int spent = 0;

  /// Sets the XP for (day, source) to [amount]; 0 removes it.
  /// Returns the change in total XP.
  int set(String day, String source, int amount) {
    final k = '$day|$source';
    final old = _entries[k] ?? 0;
    if (amount <= 0) {
      _entries.remove(k);
    } else {
      _entries[k] = amount;
    }
    return (amount <= 0 ? 0 : amount) - old;
  }

  int get total => _entries.values.fold(0, (a, b) => a + b);
  int get balance => total - spent;

  int dayTotal(String day) => _entries.entries.where((e) => e.key.startsWith('$day|')).fold(0, (a, e) => a + e.value);

  bool redeem(int cost) {
    if (cost <= 0 || cost > balance) return false;
    spent += cost;
    return true;
  }
}
