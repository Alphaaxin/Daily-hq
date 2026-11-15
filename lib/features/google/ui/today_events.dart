import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/db/app_db.dart';
import '../../../core/providers.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/theme/widgets.dart';
import '../../../core/time/format.dart';
import '../data/calendar_store.dart';

/// "Today's calendar" lines on the Focus card. Hidden when there are none.
class TodayEventsSection extends ConsumerWidget {
  const TodayEventsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final events = ref.watch(todayEventsProvider).value ?? const <CalendarEvent>[];
    if (events.isEmpty) return const SizedBox.shrink();
    final clock = ref.watch(clockProvider);
    final now = clock.nowUtc();
    final upcoming = events.where((e) => e.endUtc == null || e.endUtc!.isAfter(now)).take(4).toList();
    if (upcoming.isEmpty) return const SizedBox.shrink();
    return SubSection(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Eyebrow('Calendar'),
              const Spacer(),
              GestureDetector(
                onTap: () => context.push('/calendar'),
                child: const Text(
                  'Open',
                  style: TextStyle(color: N.gold, fontWeight: FontWeight.w600, fontSize: 13),
                ),
              ),
            ],
          ),
          for (final e in upcoming)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Row(
                children: [
                  SizedBox(
                    width: 70,
                    child: Text(
                      e.allDayDate != null ? 'All day' : fmtTime(clock, e.startUtc!),
                      style: N.num(12, color: e.startUtc != null && e.startUtc!.isBefore(now) ? N.gold : N.muted),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      e.title.isEmpty ? '(no title)' : e.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
