import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/focus/ui/focus_screen.dart';
import '../features/focus/ui/time_screen.dart';
import '../features/gamification/ui/rewards_screen.dart';
import '../features/google/ui/calendar_screen.dart';
import '../features/google/ui/google_screen.dart';
import '../features/me/ui/me_screen.dart';
import '../features/money/ui/money_screen.dart';
import '../features/money/ui/money_settings_screen.dart';
import '../features/onboarding/ui/setup_screen.dart';
import '../features/targets/ui/targets_section.dart';
import '../features/tasks/ui/tasks_screen.dart';
import '../features/today/ui/today_screen.dart';
import '../features/insights/ui/insights_screens.dart';
import '../features/leads/ui/leads_screen.dart';
import '../features/mail/ui/mail_screen.dart';
import '../features/me/ui/ai_screen.dart';
import '../features/meetings/ui/meeting_screen.dart';
import '../features/notes/ui/note_editor.dart';
import '../features/notes/ui/notes_screen.dart';
import '../features/people/ui/people_screen.dart';
import 'shell.dart';

final rootNavKey = GlobalKey<NavigatorState>();

GoRouter buildRouter(String initialLocation) => GoRouter(
  navigatorKey: rootNavKey,
  initialLocation: initialLocation,
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, shell) => AppShell(shell: shell),
      branches: [
        StatefulShellBranch(
          routes: [GoRoute(path: '/today', builder: (_, _) => const TodayScreen())],
        ),
        StatefulShellBranch(
          routes: [GoRoute(path: '/money', builder: (_, _) => const MoneyScreen())],
        ),
        StatefulShellBranch(
          routes: [GoRoute(path: '/notes', builder: (_, _) => const NotesHub())],
        ),
        StatefulShellBranch(
          routes: [GoRoute(path: '/rewards', builder: (_, _) => const RewardsScreen())],
        ),
        StatefulShellBranch(
          routes: [GoRoute(path: '/me', builder: (_, _) => const MeScreen())],
        ),
      ],
    ),
    GoRoute(path: '/money-settings', parentNavigatorKey: rootNavKey, builder: (_, _) => const MoneySettingsScreen()),
    GoRoute(path: '/focus', parentNavigatorKey: rootNavKey, builder: (_, _) => const FocusScreen()),
    GoRoute(path: '/time', parentNavigatorKey: rootNavKey, builder: (_, _) => const TimeScreen()),
    GoRoute(path: '/targets', parentNavigatorKey: rootNavKey, builder: (_, _) => const TargetsScreen()),
    GoRoute(path: '/google', parentNavigatorKey: rootNavKey, builder: (_, _) => const GoogleScreen()),
    GoRoute(path: '/calendar', parentNavigatorKey: rootNavKey, builder: (_, _) => const CalendarScreen()),
    GoRoute(
      path: '/note/new',
      parentNavigatorKey: rootNavKey,
      builder: (_, s) => NoteEditor(template: s.uri.queryParameters['t'] ?? 'Thought dump'),
    ),
    GoRoute(
      path: '/note/:id',
      parentNavigatorKey: rootNavKey,
      builder: (_, s) => NoteEditor(id: int.tryParse(s.pathParameters['id'] ?? '')),
    ),
    GoRoute(
      path: '/meeting/:id',
      parentNavigatorKey: rootNavKey,
      builder: (_, s) => MeetingScreen(id: int.parse(s.pathParameters['id']!)),
    ),
    GoRoute(path: '/people', parentNavigatorKey: rootNavKey, builder: (_, _) => const PeopleScreen()),
    GoRoute(path: '/leads', parentNavigatorKey: rootNavKey, builder: (_, _) => const LeadsScreen()),
    GoRoute(
      path: '/leads/new',
      parentNavigatorKey: rootNavKey,
      builder: (_, s) => LeadEditor(shared: s.extra as String?),
    ),
    GoRoute(
      path: '/leads/:id',
      parentNavigatorKey: rootNavKey,
      builder: (_, s) => LeadEditor(id: int.tryParse(s.pathParameters['id'] ?? '')),
    ),
    GoRoute(path: '/mail', parentNavigatorKey: rootNavKey, builder: (_, _) => const MailScreen()),
    GoRoute(path: '/ai', parentNavigatorKey: rootNavKey, builder: (_, _) => const AiScreen()),
    GoRoute(path: '/review', parentNavigatorKey: rootNavKey, builder: (_, _) => const ReviewScreen()),
    GoRoute(path: '/report', parentNavigatorKey: rootNavKey, builder: (_, _) => const ReportScreen()),
    GoRoute(path: '/pixels', parentNavigatorKey: rootNavKey, builder: (_, _) => const YearInPixelsScreen()),
    GoRoute(path: '/learning', parentNavigatorKey: rootNavKey, builder: (_, _) => const LearningScreen()),
    GoRoute(path: '/screentime', parentNavigatorKey: rootNavKey, builder: (_, _) => const ScreenTimeScreen()),
    GoRoute(path: '/nudges', parentNavigatorKey: rootNavKey, builder: (_, _) => const NudgeSettingsScreen()),
    GoRoute(path: '/tasks', parentNavigatorKey: rootNavKey, builder: (_, _) => const TasksScreen()),
    GoRoute(path: '/setup', parentNavigatorKey: rootNavKey, builder: (_, _) => const SetupScreen()),
    GoRoute(path: '/welcome', parentNavigatorKey: rootNavKey, builder: (_, _) => const SetupScreen(firstRun: true)),
  ],
);
