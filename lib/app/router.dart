import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/gamification/ui/rewards_screen.dart';
import '../features/me/ui/me_screen.dart';
import '../features/onboarding/ui/setup_screen.dart';
import '../features/placeholders/ui/coming_soon.dart';
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
          routes: [GoRoute(path: '/money', builder: (_, _) => moneyComingSoon)],
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
    GoRoute(path: '/tasks', parentNavigatorKey: rootNavKey, builder: (_, _) => const TasksScreen()),
    GoRoute(path: '/setup', parentNavigatorKey: rootNavKey, builder: (_, _) => const SetupScreen()),
    GoRoute(path: '/welcome', parentNavigatorKey: rootNavKey, builder: (_, _) => const SetupScreen(firstRun: true)),
  ],
);
