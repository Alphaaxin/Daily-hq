import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/theme/widgets.dart';
import '../../../core/time/format.dart';
import '../data/salah_repo.dart';
import '../domain/prayer_times.dart';

class SalahSection extends ConsumerWidget {
  const SalahSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final day = ref.watch(currentPrayerDayProvider);
    final st = ref.watch(salahStatusesProvider);
    final clock = ref.watch(clockProvider);
    final streak = ref.watch(salahStreakProvider);
    final prayed = st.values.where((v) => v == SalahStatus.onTime || v == SalahStatus.late).length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Eyebrow('Salah'),
            const SizedBox(width: 6),
            Text('$prayed/5', style: N.num(12, color: prayed == 5 ? N.good : N.muted)),
            const Spacer(),
            if (streak > 0) Text('$streak-day streak', style: N.small.copyWith(fontSize: 12)),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            for (final p in Prayer.values) ...[
              if (p.index > 0) const SizedBox(width: 6),
              Expanded(
                child: _PrayerButton(
                  prayer: p,
                  time: fmtTime(clock, day.start(p)).replaceAll(' AM', '').replaceAll(' PM', ''),
                  status: st[p]!,
                  onTap: () async {
                    final r = await ref.read(salahRepoProvider).toggle(day, p, clock);
                    if (r == SalahStatus.late && context.mounted) {
                      showSnack(context, '${p.label} logged as late. Still counts 🤲');
                    }
                  },
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

class _PrayerButton extends StatelessWidget {
  const _PrayerButton({required this.prayer, required this.time, required this.status, required this.onTap});
  final Prayer prayer;
  final String time;
  final SalahStatus status;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final (Color bg, Color fg, Color border) = switch (status) {
      SalahStatus.onTime => (N.goodSoft, N.good, N.good),
      SalahStatus.late => (const Color(0x21E9C062), N.warn, N.warn),
      SalahStatus.missed => (N.badSoft, N.bad, Colors.transparent),
      SalahStatus.open => (N.goldSoft, N.goldHi, N.gold.withValues(alpha: .6)),
      SalahStatus.upcoming => (N.raise, N.muted, N.line),
    };
    final mark = switch (status) {
      SalahStatus.onTime => '✓',
      SalahStatus.late => 'late',
      SalahStatus.missed => 'missed',
      SalahStatus.open => 'now',
      SalahStatus.upcoming => time,
    };
    return Semantics(
      button: true,
      label: '${prayer.label} $mark',
      child: Material(
        color: bg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: border),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            Haptic.light();
            onTap();
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Column(
              children: [
                Text(
                  prayer.label,
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: fg),
                ),
                const SizedBox(height: 2),
                Text(
                  mark,
                  style: N.num(10, color: fg.withValues(alpha: .85), weight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// "Next: Asr 3:52 PM · in 1h 10m" for the Focus card.
class NextPrayerLine extends ConsumerWidget {
  const NextPrayerLine({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final day = ref.watch(currentPrayerDayProvider);
    final clock = ref.watch(clockProvider);
    final now = clock.nowUtc();
    final next = day.nextAfter(now);
    final (String name, DateTime at) = next == null ? ('Fajr', day.nextFajr) : (next.label, day.start(next));
    return Row(
      children: [
        const Icon(Icons.mosque_outlined, size: 20, color: N.gold),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Eyebrow('Next prayer'),
              const SizedBox(height: 2),
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(text: '$name  ', style: N.h2),
                    TextSpan(text: fmtTime(clock, at), style: N.num(15)),
                  ],
                ),
              ),
            ],
          ),
        ),
        Pill(fmtIn(at.difference(now)), hot: true),
      ],
    );
  }
}
