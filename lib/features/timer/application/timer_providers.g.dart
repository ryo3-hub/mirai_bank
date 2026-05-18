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
String _$elapsedSecondsHash() => r'f294a6148aceacffaf2790c7d1c2b2771fef400b';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// See also [elapsedSeconds].
@ProviderFor(elapsedSeconds)
const elapsedSecondsProvider = ElapsedSecondsFamily();

/// See also [elapsedSeconds].
class ElapsedSecondsFamily extends Family<AsyncValue<int>> {
  /// See also [elapsedSeconds].
  const ElapsedSecondsFamily();

  /// See also [elapsedSeconds].
  ElapsedSecondsProvider call(
    DateTime startTime,
  ) {
    return ElapsedSecondsProvider(
      startTime,
    );
  }

  @override
  ElapsedSecondsProvider getProviderOverride(
    covariant ElapsedSecondsProvider provider,
  ) {
    return call(
      provider.startTime,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'elapsedSecondsProvider';
}

/// See also [elapsedSeconds].
class ElapsedSecondsProvider extends AutoDisposeStreamProvider<int> {
  /// See also [elapsedSeconds].
  ElapsedSecondsProvider(
    DateTime startTime,
  ) : this._internal(
          (ref) => elapsedSeconds(
            ref as ElapsedSecondsRef,
            startTime,
          ),
          from: elapsedSecondsProvider,
          name: r'elapsedSecondsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$elapsedSecondsHash,
          dependencies: ElapsedSecondsFamily._dependencies,
          allTransitiveDependencies:
              ElapsedSecondsFamily._allTransitiveDependencies,
          startTime: startTime,
        );

  ElapsedSecondsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.startTime,
  }) : super.internal();

  final DateTime startTime;

  @override
  Override overrideWith(
    Stream<int> Function(ElapsedSecondsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ElapsedSecondsProvider._internal(
        (ref) => create(ref as ElapsedSecondsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        startTime: startTime,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<int> createElement() {
    return _ElapsedSecondsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ElapsedSecondsProvider && other.startTime == startTime;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, startTime.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ElapsedSecondsRef on AutoDisposeStreamProviderRef<int> {
  /// The parameter `startTime` of this provider.
  DateTime get startTime;
}

class _ElapsedSecondsProviderElement
    extends AutoDisposeStreamProviderElement<int> with ElapsedSecondsRef {
  _ElapsedSecondsProviderElement(super.provider);

  @override
  DateTime get startTime => (origin as ElapsedSecondsProvider).startTime;
}

String _$timerControllerHash() => r'7765df63a0e9a6d7a9781bee18700a685bfb3830';

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
