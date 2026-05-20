// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'goal_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$goalRepositoryHash() => r'379f6c647cee4a9a9b56e0ad98c719b87b23a107';

/// See also [goalRepository].
@ProviderFor(goalRepository)
final goalRepositoryProvider = Provider<GoalRepository>.internal(
  goalRepository,
  name: r'goalRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$goalRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef GoalRepositoryRef = ProviderRef<GoalRepository>;
String _$goalAchievementCheckerHash() =>
    r'c6f43c94a17de2c235ce6fecbf7b0a6e54c6a351';

/// See also [goalAchievementChecker].
@ProviderFor(goalAchievementChecker)
final goalAchievementCheckerProvider =
    Provider<GoalAchievementChecker>.internal(
  goalAchievementChecker,
  name: r'goalAchievementCheckerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$goalAchievementCheckerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef GoalAchievementCheckerRef = ProviderRef<GoalAchievementChecker>;
String _$activeGoalsWithProgressHash() =>
    r'934c29bdd689779053f7d3617760e91cf37bd94e';

/// See also [activeGoalsWithProgress].
@ProviderFor(activeGoalsWithProgress)
final activeGoalsWithProgressProvider =
    AutoDisposeStreamProvider<List<GoalProgress>>.internal(
  activeGoalsWithProgress,
  name: r'activeGoalsWithProgressProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$activeGoalsWithProgressHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ActiveGoalsWithProgressRef
    = AutoDisposeStreamProviderRef<List<GoalProgress>>;
String _$achievedGoalsHash() => r'cb86c2d254e475d066520337c13af30f0f8211ca';

/// See also [achievedGoals].
@ProviderFor(achievedGoals)
final achievedGoalsProvider = AutoDisposeStreamProvider<List<Goal>>.internal(
  achievedGoals,
  name: r'achievedGoalsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$achievedGoalsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AchievedGoalsRef = AutoDisposeStreamProviderRef<List<Goal>>;
String _$goalControllerHash() => r'40062caf7b70a99fc5ba14da695519826669d0d3';

/// See also [GoalController].
@ProviderFor(GoalController)
final goalControllerProvider =
    AutoDisposeNotifierProvider<GoalController, void>.internal(
  GoalController.new,
  name: r'goalControllerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$goalControllerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$GoalController = AutoDisposeNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
