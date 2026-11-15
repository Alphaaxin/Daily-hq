import 'package:flutter/material.dart';

import '../../../core/theme/tokens.dart';
import '../../../core/theme/widgets.dart';

class ComingSoonScreen extends StatelessWidget {
  const ComingSoonScreen({
    super.key,
    required this.title,
    required this.phase,
    required this.icon,
    required this.points,
  });
  final String title;
  final String phase;
  final IconData icon;
  final List<String> points;

  @override
  Widget build(BuildContext context) => ListView(
    padding: EdgeInsets.fromLTRB(16, 12, 16, 120 + MediaQuery.of(context).padding.bottom),
    children: [
      GlassCard(
        hero: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(gradient: N.goldGradient, borderRadius: BorderRadius.circular(14)),
                  child: Icon(icon, color: N.goldInk),
                ),
                const Spacer(),
                Pill(phase, hot: true),
              ],
            ),
            const SizedBox(height: 16),
            Text(title, style: N.h1.copyWith(fontSize: 24)),
            const SizedBox(height: 6),
            Text('Being built next. Here\'s what\'s coming:', style: N.small),
          ],
        ),
      ),
      const SizedBox(height: N.gap),
      GlassCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final p in points)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 7),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 6),
                      child: SizedBox(
                        width: 6,
                        height: 6,
                        child: DecoratedBox(
                          decoration: BoxDecoration(color: N.gold, shape: BoxShape.circle),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(child: Text(p, style: const TextStyle(fontSize: 14, height: 1.4))),
                  ],
                ),
              ),
          ],
        ),
      ),
    ],
  );
}

const notesComingSoon = ComingSoonScreen(
  title: 'Notes · Brain',
  phase: 'Phase 3',
  icon: Icons.sticky_note_2_outlined,
  points: [
    'Templates: Research, Blog draft, Product idea, Thought dump, Meetings',
    'Tags, work profiles, full-text search, links to Build Hour sessions',
    'Voice capture and Gemini clean-up into a template',
    'Meeting recorder → transcript → structured Minutes of Meeting → tasks and follow-ups',
  ],
);
