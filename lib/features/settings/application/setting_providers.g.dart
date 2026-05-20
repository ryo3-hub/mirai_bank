// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'setting_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$settingRepositoryHash() => r'0cf5dfaff6b0aa5378d9844fad97d0679569e79f';

/// See also [settingRepository].
@ProviderFor(settingRepository)
final settingRepositoryProvider = Provider<SettingRepository>.internal(
  settingRepository,
  name: r'settingRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$settingRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SettingRepositoryRef = ProviderRef<SettingRepository>;
String _$appSettingHash() => r'729eb87e2535a87ba22bf1aca43bdf7617486432';

/// See also [appSetting].
@ProviderFor(appSetting)
final appSettingProvider = AutoDisposeStreamProvider<AppSetting>.internal(
  appSetting,
  name: r'appSettingProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$appSettingHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AppSettingRef = AutoDisposeStreamProviderRef<AppSetting>;
String _$settingControllerHash() => r'a3a6d61ad675e96da8d0e032a88cf724339f5a69';

/// See also [SettingController].
@ProviderFor(SettingController)
final settingControllerProvider =
    AutoDisposeNotifierProvider<SettingController, void>.internal(
  SettingController.new,
  name: r'settingControllerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$settingControllerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$SettingController = AutoDisposeNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
