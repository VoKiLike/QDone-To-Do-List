import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:qdone/features/calendar/presentation/pages/calendar_page.dart';
import 'package:qdone/features/settings/presentation/pages/menu_page.dart';
import 'package:qdone/features/tasks/presentation/pages/focus_mode_page.dart';
import 'package:qdone/features/tasks/presentation/pages/tasks_page.dart';
import 'package:qdone/shared/components/qdone_shell.dart';

final appRouter = GoRouter(
  initialLocation: '/tasks',
  routes: <RouteBase>[
    ShellRoute(
      builder: (context, state, child) =>
          QDoneShell(location: state.uri.path, child: child),
      routes: <RouteBase>[
        GoRoute(
          path: '/calendar',
          builder: (context, state) => const CalendarPage(),
        ),
        GoRoute(path: '/tasks', builder: (context, state) => const TasksPage()),
        GoRoute(path: '/menu', builder: (context, state) => const MenuPage()),
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
