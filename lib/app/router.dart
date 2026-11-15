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
import '../features/placeholders/ui/coming_soon.dart';
import '../features/targets/ui/targets_section.dart';
import '../features/tasks/ui/tasks_screen.dart';
import '../features/today/ui/today_screen.dart';
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
          routes: [GoRoute(path: '/notes', builder: (_, _) => notesComingSoon)],
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
    GoRoute(path: '/tasks', parentNavigatorKey: rootNavKey, builder: (_, _) => const TasksScreen()),
    GoRoute(path: '/setup', parentNavigatorKey: rootNavKey, builder: (_, _) => const SetupScreen()),
    GoRoute(path: '/welcome', parentNavigatorKey: rootNavKey, builder: (_, _) => const SetupScreen(firstRun: true)),
  ],
);
