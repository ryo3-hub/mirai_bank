import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/category/presentation/category_list_page.dart';
import '../features/goals/presentation/goal_list_page.dart';
import '../features/history/presentation/calendar_page.dart';
import '../features/history/presentation/history_page.dart';
import '../features/settings/presentation/settings_page.dart';
import '../features/statistics/presentation/statistics_page.dart';
import '../features/timer/presentation/home_page.dart';
import '../shared/widgets/app_shell.dart';

class AppRouter {
  const AppRouter._();

  static final GlobalKey<NavigatorState> rootNavigatorKey =
      GlobalKey<NavigatorState>();

  static final GoRouter router = GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/home',
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            AppShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                builder: (context, state) => const HomePage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/calendar',
                builder: (context, state) => const CalendarPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/statistics',
                builder: (context, state) => const StatisticsPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/history',
                builder: (context, state) => const HistoryPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/settings',
                builder: (context, state) => const SettingsPage(),
                routes: [
                  GoRoute(
                    path: 'categories',
                    builder: (context, state) => const CategoryListPage(),
                  ),
                  GoRoute(
                    path: 'goals',
                    builder: (context, state) => const GoalListPage(),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
