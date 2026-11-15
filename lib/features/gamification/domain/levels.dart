const levelNames = [
  'Rookie',
  'Starter',
  'Builder',
  'Hustler',
  'Operator',
  'Strategist',
  'Architect',
  'Closer',
  'Founder',
  'Legend',
];

/// Total XP needed to reach [level] (level 1 starts at 0).
/// Level L starts at 50·L·(L−1): 0, 100, 300, 600, 1000, …
int xpForLevel(int level) => 50 * level * (level - 1);

String levelName(int level) {
  if (level <= levelNames.length) return levelNames[level - 1];
  return 'Legend ${_roman(level - levelNames.length + 1)}';
}

String _roman(int n) {
  const v = [1000, 900, 500, 400, 100, 90, 50, 40, 10, 9, 5, 4, 1];
  const s = ['M', 'CM', 'D', 'CD', 'C', 'XC', 'L', 'XL', 'X', 'IX', 'V', 'IV', 'I'];
  final b = StringBuffer();
  for (var i = 0; i < v.length; i++) {
    while (n >= v[i]) {
      b.write(s[i]);
      n -= v[i];
    }
  }
  return b.toString();
}

class LevelInfo {
  const LevelInfo({
    required this.level,
    required this.name,
    required this.floorXp,
    required this.nextXp,
    required this.xp,
  });

  final int level;
  final String name;
  final int floorXp;
  final int nextXp;
  final int xp;

  int get toNext => nextXp - xp;
  double get progress => ((xp - floorXp) / (nextXp - floorXp)).clamp(0.0, 1.0);
}

LevelInfo levelFor(int xp) {
  if (xp < 0) xp = 0;
  var l = 1;
  while (xpForLevel(l + 1) <= xp) {
    l++;
  }
  return LevelInfo(level: l, name: levelName(l), floorXp: xpForLevel(l), nextXp: xpForLevel(l + 1), xp: xp);
}
