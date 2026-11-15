import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';

import '../../../core/db/app_db.dart';
import '../../../core/providers.dart';
import '../../../core/theme/dialogs.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/theme/widgets.dart';
import '../../../core/time/day_clock.dart';
import '../../../core/time/format.dart';
import '../../profiles/data/profiles_repo.dart';
import '../data/focus_repo.dart';
import '../domain/focus_logic.dart';

/// Retainer / work time per profile, week or month, with CSV & PDF export.
class TimeScreen extends ConsumerStatefulWidget {
  const TimeScreen({super.key});

  @override
  ConsumerState<TimeScreen> createState() => _TimeScreenState();
}

class _TimeScreenState extends ConsumerState<TimeScreen> {
  bool _month = false;
  int _offset = 0; // 0 = this week/month, -1 = previous…

  (String, String, String) _range(String today) {
    if (_month) {
      final d = DayKey.toDate(today);
      final first = DateTime.utc(d.year, d.month + _offset, 1);
      final last = DateTime.utc(first.year, first.month + 1, 0);
      return (DayKey.fromDate(first), DayKey.fromDate(last), '${monShort[first.month - 1]} ${first.year}');
    }
    final start = DayKey.add(weekStart(today), 7 * _offset);
    final end = DayKey.add(start, 6);
    return (start, end, '${fmtDayKey(start)} – ${fmtDayKey(end)}');
  }

  @override
  Widget build(BuildContext context) {
    final today = ref.watch(todayProvider);
    final (from, to, label) = _range(today);
    final sessions = ref.watch(_rangeProvider((from, to))).value ?? const <FocusSession>[];
    final profiles = ref.watch(profilesProvider).value ?? const <Profile>[];
    final names = <int?, String>{null: 'Untagged', for (final p in profiles) p.id: p.name};
    final colors = {for (final p in profiles) p.id: Color(p.color)};
    final totals = totalsByProfile(sessions.map((s) => s.log), from, to);
    final all = totals.values.fold(0, (a, b) => a + b);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: N.bg,
        surfaceTintColor: Colors.transparent,
        title: Text('Time log', style: N.h2.copyWith(fontSize: 18)),
        actions: [
          IconButton(
            tooltip: 'Add time manually',
            icon: const Icon(Icons.add_rounded, color: N.gold),
            onPressed: () => _addManual(context, profiles),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 40),
        children: [
          Row(
            children: [
              Expanded(
                child: NChip(
                  'Week',
                  on: !_month,
                  onTap: () => setState(() {
                    _month = false;
                    _offset = 0;
                  }),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: NChip(
                  'Month',
                  on: _month,
                  onTap: () => setState(() {
                    _month = true;
                    _offset = 0;
                  }),
                ),
              ),
            ],
          ),
          const SizedBox(height: N.gap),
          GlassCard(
            hero: true,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    IconBtn(Icons.chevron_left_rounded, label: 'Previous', onTap: () => setState(() => _offset--)),
                    Expanded(
                      child: Column(
                        children: [
                          Eyebrow(_month ? 'Month' : 'Week'),
                          const SizedBox(height: 2),
                          Text(label, style: N.h2),
                        ],
                      ),
                    ),
                    IconBtn(
                      Icons.chevron_right_rounded,
                      label: 'Next',
                      onTap: () => setState(() => _offset = (_offset + 1).clamp(-120, 0)),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Center(child: GoldText(fmtHours(all), style: N.num(36))),
                const SizedBox(height: 4),
                Center(child: Text('tracked', style: N.small)),
                const SizedBox(height: 12),
                for (final e in totals.entries)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            Expanded(child: Text(names[e.key] ?? '?')),
                            Text(fmtHours(e.value), style: N.num(13)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        GoldBar(all == 0 ? 0 : e.value / all, color: colors[e.key], height: 5),
                      ],
                    ),
                  ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: NButton(
                        'CSV',
                        kind: BtnKind.raise,
                        icon: Icons.table_chart_outlined,
                        onTap: sessions.isEmpty ? null : () => _export(context, sessions, names, label, csv: true),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: NButton(
                        'PDF',
                        kind: BtnKind.raise,
                        icon: Icons.picture_as_pdf_outlined,
                        onTap: sessions.isEmpty ? null : () => _export(context, sessions, names, label, csv: false),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: N.gap),
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const CardHeader('Sessions'),
                if (sessions.isEmpty) const EmptyNote('No tracked time in this period.'),
                for (final s in sessions)
                  Dismissible(
                    key: ValueKey('f-${s.id}'),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 16),
                      color: N.badSoft,
                      child: const Icon(Icons.delete_outline_rounded, color: N.bad),
                    ),
                    onDismissed: (_) => ref.read(focusRepoProvider).delete(s),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: const BoxDecoration(
                        border: Border(top: BorderSide(color: N.line)),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  s.note.isEmpty ? s.focusKind.label : s.note,
                                  style: const TextStyle(fontWeight: FontWeight.w600),
                                ),
                                Text(
                                  '${fmtDayKey(s.day)} · ${s.focusKind.label} · ${names[s.profileId]}',
                                  style: N.small.copyWith(fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                          Text(fmtHours(s.seconds), style: N.num(14)),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _addManual(BuildContext context, List<Profile> profiles) async {
    final mins = await askInt(context, 'Minutes worked (×15)', 4, 1, 48, fmt: (x) => fmtHours(x * 15 * 60));
    if (mins == null || !context.mounted) return;
    final prof = await showDialog<int?>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: Text('For which profile?', style: N.h2),
        children: [
          for (final p in profiles) SimpleDialogOption(onPressed: () => Navigator.pop(ctx, p.id), child: Text(p.name)),
        ],
      ),
    );
    if (!context.mounted) return;
    final note = await askText(context, 'What was it?', '');
    await ref
        .read(focusRepoProvider)
        .addManual(
          day: ref.read(todayProvider),
          minutes: mins * 15,
          profileId: prof,
          note: note ?? '',
          nowUtc: ref.read(clockProvider).nowUtc(),
        );
  }

  Future<void> _export(
    BuildContext context,
    List<FocusSession> sessions,
    Map<int?, String> names,
    String label, {
    required bool csv,
  }) async {
    final dir = await getTemporaryDirectory();
    final safe = label.replaceAll(RegExp(r'[^A-Za-z0-9]+'), '-');
    final logs = sessions.map((s) => s.log).toList();
    final File f;
    if (csv) {
      f = File(p.join(dir.path, 'nizam-time-$safe.csv'))..writeAsStringSync(timeLogCsv(logs, names));
    } else {
      f = File(p.join(dir.path, 'nizam-time-$safe.pdf'))..writeAsBytesSync(await _pdf(logs, names, label));
    }
    await SharePlus.instance.share(ShareParams(files: [XFile(f.path)], subject: 'Time log · $label'));
  }

  Future<List<int>> _pdf(List<TimeLog> logs, Map<int?, String> names, String label) async {
    final doc = pw.Document();
    final totals = <int?, int>{};
    for (final l in logs) {
      totals[l.profileId] = (totals[l.profileId] ?? 0) + l.seconds;
    }
    final sorted = logs.toList()..sort((a, b) => a.day.compareTo(b.day));
    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (_) => [
          pw.Text('Time log', style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold)),
          pw.Text(label),
          pw.SizedBox(height: 14),
          pw.TableHelper.fromTextArray(
            headers: ['Profile', 'Hours'],
            data: [
              for (final e in totals.entries) [names[e.key] ?? '', (e.value / 3600).toStringAsFixed(2)],
            ],
          ),
          pw.SizedBox(height: 14),
          pw.TableHelper.fromTextArray(
            headers: ['Date', 'Profile', 'Type', 'Hours', 'Note'],
            data: [
              for (final l in sorted)
                [l.day, names[l.profileId] ?? '', l.kind.label, (l.seconds / 3600).toStringAsFixed(2), l.note],
            ],
          ),
        ],
      ),
    );
    return doc.save();
  }
}

final _rangeProvider = StreamProvider.family<List<FocusSession>, (String, String)>(
  (ref, r) => ref.watch(focusRepoProvider).watchRange(r.$1, r.$2),
);
