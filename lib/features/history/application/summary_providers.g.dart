// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'summary_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$summaryHash() => r'892bebc27e068c4c1d1e3f96f5375e7c896e6ac2';

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

/// See also [summary].
@ProviderFor(summary)
const summaryProvider = SummaryFamily();

/// See also [summary].
class SummaryFamily extends Family<AsyncValue<SessionSummary>> {
  /// See also [summary].
  const SummaryFamily();

  /// See also [summary].
  SummaryProvider call(
    SummaryPeriod period,
  ) {
    return SummaryProvider(
      period,
    );
  }

  @override
  SummaryProvider getProviderOverride(
    covariant SummaryProvider provider,
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
  String? get name => r'summaryProvider';
}

/// See also [summary].
class SummaryProvider extends AutoDisposeStreamProvider<SessionSummary> {
  /// See also [summary].
  SummaryProvider(
    SummaryPeriod period,
  ) : this._internal(
          (ref) => summary(
            ref as SummaryRef,
            period,
          ),
          from: summaryProvider,
          name: r'summaryProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$summaryHash,
          dependencies: SummaryFamily._dependencies,
          allTransitiveDependencies: SummaryFamily._allTransitiveDependencies,
          period: period,
        );

  SummaryProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.period,
  }) : super.internal();

  final SummaryPeriod period;

  @override
  Override overrideWith(
    Stream<SessionSummary> Function(SummaryRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: SummaryProvider._internal(
        (ref) => create(ref as SummaryRef),
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
  AutoDisposeStreamProviderElement<SessionSummary> createElement() {
    return _SummaryProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is SummaryProvider && other.period == period;
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
mixin SummaryRef on AutoDisposeStreamProviderRef<SessionSummary> {
  /// The parameter `period` of this provider.
  SummaryPeriod get period;
}

class _SummaryProviderElement
    extends AutoDisposeStreamProviderElement<SessionSummary> with SummaryRef {
  _SummaryProviderElement(super.provider);

  @override
  SummaryPeriod get period => (origin as SummaryProvider).period;
}

String _$categoryBreakdownHash() => r'401e3e256e399b677b354c8e2228a7baadd39aa8';

/// See also [categoryBreakdown].
@ProviderFor(categoryBreakdown)
const categoryBreakdownProvider = CategoryBreakdownFamily();

/// See also [categoryBreakdown].
class CategoryBreakdownFamily
    extends Family<AsyncValue<List<CategoryBreakdownItem>>> {
  /// See also [categoryBreakdown].
  const CategoryBreakdownFamily();

  /// See also [categoryBreakdown].
  CategoryBreakdownProvider call(
    SummaryPeriod period,
  ) {
    return CategoryBreakdownProvider(
      period,
    );
  }

  @override
  CategoryBreakdownProvider getProviderOverride(
    covariant CategoryBreakdownProvider provider,
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
  String? get name => r'categoryBreakdownProvider';
}

/// See also [categoryBreakdown].
class CategoryBreakdownProvider
    extends AutoDisposeStreamProvider<List<CategoryBreakdownItem>> {
  /// See also [categoryBreakdown].
  CategoryBreakdownProvider(
    SummaryPeriod period,
  ) : this._internal(
          (ref) => categoryBreakdown(
            ref as CategoryBreakdownRef,
            period,
          ),
          from: categoryBreakdownProvider,
          name: r'categoryBreakdownProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$categoryBreakdownHash,
          dependencies: CategoryBreakdownFamily._dependencies,
          allTransitiveDependencies:
              CategoryBreakdownFamily._allTransitiveDependencies,
          period: period,
        );

  CategoryBreakdownProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.period,
  }) : super.internal();

  final SummaryPeriod period;

  @override
  Override overrideWith(
    Stream<List<CategoryBreakdownItem>> Function(CategoryBreakdownRef provider)
        create,
  ) {
    return ProviderOverride(
      origin: this,
      override: CategoryBreakdownProvider._internal(
        (ref) => create(ref as CategoryBreakdownRef),
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
  AutoDisposeStreamProviderElement<List<CategoryBreakdownItem>>
      createElement() {
    return _CategoryBreakdownProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is CategoryBreakdownProvider && other.period == period;
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
mixin CategoryBreakdownRef
    on AutoDisposeStreamProviderRef<List<CategoryBreakdownItem>> {
  /// The parameter `period` of this provider.
  SummaryPeriod get period;
}

class _CategoryBreakdownProviderElement
    extends AutoDisposeStreamProviderElement<List<CategoryBreakdownItem>>
    with CategoryBreakdownRef {
  _CategoryBreakdownProviderElement(super.provider);

  @override
  SummaryPeriod get period => (origin as CategoryBreakdownProvider).period;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
