// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stats_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$periodStatsHash() => r'1f3c4dfd5dd1698d60f9408ae2cd3c27ccff8647';

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

/// See also [periodStats].
@ProviderFor(periodStats)
const periodStatsProvider = PeriodStatsFamily();

/// See also [periodStats].
class PeriodStatsFamily extends Family<AsyncValue<PeriodStats>> {
  /// See also [periodStats].
  const PeriodStatsFamily();

  /// See also [periodStats].
  PeriodStatsProvider call(
    StatsPeriod period,
  ) {
    return PeriodStatsProvider(
      period,
    );
  }

  @override
  PeriodStatsProvider getProviderOverride(
    covariant PeriodStatsProvider provider,
  ) {
    return call(
      provider.period,
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
  String? get name => r'periodStatsProvider';
}

/// See also [periodStats].
class PeriodStatsProvider extends AutoDisposeStreamProvider<PeriodStats> {
  /// See also [periodStats].
  PeriodStatsProvider(
    StatsPeriod period,
  ) : this._internal(
          (ref) => periodStats(
            ref as PeriodStatsRef,
            period,
          ),
          from: periodStatsProvider,
          name: r'periodStatsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$periodStatsHash,
          dependencies: PeriodStatsFamily._dependencies,
          allTransitiveDependencies:
              PeriodStatsFamily._allTransitiveDependencies,
          period: period,
        );

  PeriodStatsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.period,
  }) : super.internal();

  final StatsPeriod period;

  @override
  Override overrideWith(
    Stream<PeriodStats> Function(PeriodStatsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: PeriodStatsProvider._internal(
        (ref) => create(ref as PeriodStatsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        period: period,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<PeriodStats> createElement() {
    return _PeriodStatsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is PeriodStatsProvider && other.period == period;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, period.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin PeriodStatsRef on AutoDisposeStreamProviderRef<PeriodStats> {
  /// The parameter `period` of this provider.
  StatsPeriod get period;
}

class _PeriodStatsProviderElement
    extends AutoDisposeStreamProviderElement<PeriodStats> with PeriodStatsRef {
  _PeriodStatsProviderElement(super.provider);

  @override
  StatsPeriod get period => (origin as PeriodStatsProvider).period;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
