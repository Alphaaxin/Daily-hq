/// Backup files in Drive's hidden app folder: nizam-backup-YYYYMMDD-HHMM.db.gz
String backupName(DateTime utc) {
  String p(int n) => n.toString().padLeft(2, '0');
  final u = utc.toUtc();
  return 'nizam-backup-${u.year}${p(u.month)}${p(u.day)}-${p(u.hour)}${p(u.minute)}.db.gz';
}

final _re = RegExp(r'^nizam-backup-(\d{4})(\d{2})(\d{2})-(\d{2})(\d{2})\.db\.gz$');

/// When a backup was taken, from its name; null for foreign files.
DateTime? backupTime(String name) {
  final m = _re.firstMatch(name);
  if (m == null) return null;
  final g = [for (var i = 1; i <= 5; i++) int.parse(m.group(i)!)];
  return DateTime.utc(g[0], g[1], g[2], g[3], g[4]);
}

/// Which backups to delete so only the newest [keep] remain.
List<String> backupsToPrune(Iterable<String> names, {int keep = 14}) {
  final ours = names.where((n) => backupTime(n) != null).toList()
    ..sort((a, b) => backupTime(b)!.compareTo(backupTime(a)!));
  return ours.length <= keep ? const [] : ours.sublist(keep);
}

/// Next 10:00 local (as UTC) after [nowUtc], for the safety-net backup.
DateTime nextLocalHour(DateTime nowUtc, Duration utcOffset, int hour) {
  final local = nowUtc.add(utcOffset);
  var target = DateTime.utc(local.year, local.month, local.day, hour);
  if (!target.isAfter(local)) target = target.add(const Duration(days: 1));
  return target.subtract(utcOffset);
}
