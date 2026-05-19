import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persisted flag indicating whether the user has been through the
/// first-launch onboarding flow (either by creating a category or by
/// explicitly skipping). Once true, the router stops forcing the
/// onboarding page even when no categories exist.
class OnboardingState extends AsyncNotifier<bool> {
  static const _key = 'onboarding_completed';

  @override
  Future<bool> build() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_key) ?? false;
  }

  Future<void> markCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, true);
    state = const AsyncValue.data(true);
  }
}

final onboardingStateProvider =
    AsyncNotifierProvider<OnboardingState, bool>(OnboardingState.new);
