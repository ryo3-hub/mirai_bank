import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/category/application/category_providers.dart';
import '../features/category/presentation/category_list_page.dart';
import '../features/goals/presentation/goal_list_page.dart';
import '../features/history/presentation/calendar_page.dart';
import '../features/history/presentation/history_page.dart';
import '../features/onboarding/application/onboarding_state.dart';
import '../features/onboarding/presentation/onboarding_page.dart';
import '../features/settings/presentation/settings_page.dart';
import '../features/statistics/presentation/statistics_page.dart';
import '../features/timer/presentation/home_page.dart';
import '../shared/widgets/app_shell.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final notifier = _RouterRefreshNotifier(ref);
  ref.onDispose(notifier.dispose);
  return GoRouter(
    navigatorKey: AppRouter.rootNavigatorKey,
    initialLocation: '/home',
    refreshListenable: notifier,
    redirect: (context, state) {
      final categoriesAsync = ref.read(categoriesListProvider);
      final onboardingAsync = ref.read(onboardingStateProvider);
      if (categoriesAsync.isLoading ||
          categoriesAsync.hasError ||
          onboardingAsync.isLoading ||
          onboardingAsync.hasError) {
        return null;
      }
      final hasCategories = categoriesAsync.valueOrNull?.isNotEmpty ?? false;
      final onboardingCompleted = onboardingAsync.valueOrNull ?? false;
      final isOnboarding = state.matchedLocation == '/onboarding';
      // Force onboarding only when both: not completed AND no categories.
      if (!onboardingCompleted && !hasCategories && !isOnboarding) {
        return '/onboarding';
      }
      // Exit /onboarding once it's marked complete (or categories exist).
      if (isOnboarding && (onboardingCompleted || hasCategories)) {
        return '/home';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingPage(),
      ),
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
});

class AppRouter {
  const AppRouter._();

  static final GlobalKey<NavigatorState> rootNavigatorKey =
      GlobalKey<NavigatorState>();
}

/// Notifies GoRouter to re-run [GoRouter.redirect] whenever the
/// category list or the onboarding flag changes.
class _RouterRefreshNotifier extends ChangeNotifier {
  _RouterRefreshNotifier(this._ref) {
    _categorySub = _ref.listen<AsyncValue<dynamic>>(
      categoriesListProvider,
      (_, __) => notifyListeners(),
    );
    _onboardingSub = _ref.listen<AsyncValue<dynamic>>(
      onboardingStateProvider,
      (_, __) => notifyListeners(),
    );
  }

  final Ref _ref;
  ProviderSubscription<AsyncValue<dynamic>>? _categorySub;
  ProviderSubscription<AsyncValue<dynamic>>? _onboardingSub;

  @override
  void dispose() {
    _categorySub?.close();
    _onboardingSub?.close();
    super.dispose();
  }
}
