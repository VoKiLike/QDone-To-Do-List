import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:qdone/features/calendar/presentation/pages/calendar_page.dart';
import 'package:qdone/features/settings/presentation/pages/menu_page.dart';
import 'package:qdone/features/tasks/presentation/pages/focus_mode_page.dart';
import 'package:qdone/features/tasks/presentation/pages/tasks_page.dart';
import 'package:qdone/shared/components/qdone_shell.dart';

final appRouter = GoRouter(
  initialLocation: '/tasks',
  redirect: (context, state) {
    final uri = state.uri;
    if (uri.scheme != 'qdone') {
      return null;
    }

    if (uri.host == 'home') {
      return '/tasks';
    }
    if (uri.host == 'menu') {
      return '/menu';
    }
    if ((uri.host == 'task' || uri.host == 'focus') &&
        uri.pathSegments.isNotEmpty) {
      return '/focus/${uri.pathSegments.first}';
    }
    return '/tasks';
  },
  routes: <RouteBase>[
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) =>
          QDoneShell(navigationShell: navigationShell),
      branches: <StatefulShellBranch>[
        StatefulShellBranch(
          routes: <RouteBase>[
            GoRoute(
              path: '/calendar',
              builder: (context, state) => const CalendarPage(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: <RouteBase>[
            GoRoute(
              path: '/tasks',
              builder: (context, state) => const TasksPage(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: <RouteBase>[
            GoRoute(
              path: '/menu',
              builder: (context, state) => const MenuPage(),
            ),
          ],
        ),
      ],
    ),
    GoRoute(
      path: '/focus/:taskId',
      pageBuilder: (context, state) {
        return CustomTransitionPage<void>(
          key: state.pageKey,
          child: FocusModePage(taskId: state.pathParameters['taskId']!),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: ScaleTransition(
                scale: Tween<double>(begin: 0.96, end: 1).animate(
                  CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOutCubic,
                  ),
                ),
                child: child,
              ),
            );
          },
        );
      },
    ),
  ],
);
