// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'timer_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$activeTimerRepositoryHash() =>
    r'c1ed4f24bc2328b0a334af06caf63f98592d4bf2';

/// See also [activeTimerRepository].
@ProviderFor(activeTimerRepository)
final activeTimerRepositoryProvider = Provider<ActiveTimerRepository>.internal(
  activeTimerRepository,
  name: r'activeTimerRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$activeTimerRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ActiveTimerRepositoryRef = ProviderRef<ActiveTimerRepository>;
String _$activeTimerHash() => r'09c1d0a72651777fa1fd43ce766a53aa692ddf46';

/// See also [activeTimer].
@ProviderFor(activeTimer)
final activeTimerProvider = AutoDisposeStreamProvider<ActiveTimer?>.internal(
  activeTimer,
  name: r'activeTimerProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$activeTimerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ActiveTimerRef = AutoDisposeStreamProviderRef<ActiveTimer?>;
String _$timerElapsedHash() => r'c039d1bc6e64eed2fe503fc2684807a82eca93e4';

/// アクティブタイマーの累計経過秒数を 1 秒間隔で emit する。
/// 一時停止中は固定値を返し続ける。
///
/// Copied from [timerElapsed].
@ProviderFor(timerElapsed)
final timerElapsedProvider = AutoDisposeStreamProvider<int>.internal(
  timerElapsed,
  name: r'timerElapsedProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$timerElapsedHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TimerElapsedRef = AutoDisposeStreamProviderRef<int>;
String _$timerControllerHash() => r'1a088bd4ac81ff67dbae5e389a4235fa8e83fed0';

/// See also [TimerController].
@ProviderFor(TimerController)
final timerControllerProvider =
    AutoDisposeNotifierProvider<TimerController, void>.internal(
  TimerController.new,
  name: r'timerControllerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$timerControllerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$TimerController = AutoDisposeNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
