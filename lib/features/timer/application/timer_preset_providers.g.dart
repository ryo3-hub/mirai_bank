// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'timer_preset_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$timerPresetRepositoryHash() =>
    r'78054b98ec159efdd730fa9cd49d5f6a4375a99b';

/// See also [timerPresetRepository].
@ProviderFor(timerPresetRepository)
final timerPresetRepositoryProvider = Provider<TimerPresetRepository>.internal(
  timerPresetRepository,
  name: r'timerPresetRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$timerPresetRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TimerPresetRepositoryRef = ProviderRef<TimerPresetRepository>;
String _$timerPresetListHash() => r'b50ca6cc321a3aca05ba2e19c7854b6261118a38';

/// See also [timerPresetList].
@ProviderFor(timerPresetList)
final timerPresetListProvider =
    AutoDisposeStreamProvider<List<TimerPreset>>.internal(
  timerPresetList,
  name: r'timerPresetListProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$timerPresetListHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TimerPresetListRef = AutoDisposeStreamProviderRef<List<TimerPreset>>;
String _$timerPresetControllerHash() =>
    r'714872c7d551ae37ad819a7820e3d9ffaa045a31';

/// See also [TimerPresetController].
@ProviderFor(TimerPresetController)
final timerPresetControllerProvider =
    AutoDisposeNotifierProvider<TimerPresetController, void>.internal(
  TimerPresetController.new,
  name: r'timerPresetControllerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$timerPresetControllerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$TimerPresetController = AutoDisposeNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
