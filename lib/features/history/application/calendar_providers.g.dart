// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'calendar_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$dailyAmountMapHash() => r'892c2c6863387aafee11bef66466dc055da9f93d';

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

/// See also [dailyAmountMap].
@ProviderFor(dailyAmountMap)
const dailyAmountMapProvider = DailyAmountMapFamily();

/// See also [dailyAmountMap].
class DailyAmountMapFamily extends Family<AsyncValue<Map<DateTime, int>>> {
  /// See also [dailyAmountMap].
  const DailyAmountMapFamily();

  /// See also [dailyAmountMap].
  DailyAmountMapProvider call(
    DateTime month,
  ) {
    return DailyAmountMapProvider(
      month,
    );
  }

  @override
  DailyAmountMapProvider getProviderOverride(
    covariant DailyAmountMapProvider provider,
  ) {
    return call(
      provider.month,
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
  String? get name => r'dailyAmountMapProvider';
}

/// See also [dailyAmountMap].
class DailyAmountMapProvider
    extends AutoDisposeStreamProvider<Map<DateTime, int>> {
  /// See also [dailyAmountMap].
  DailyAmountMapProvider(
    DateTime month,
  ) : this._internal(
          (ref) => dailyAmountMap(
            ref as DailyAmountMapRef,
            month,
          ),
          from: dailyAmountMapProvider,
          name: r'dailyAmountMapProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$dailyAmountMapHash,
          dependencies: DailyAmountMapFamily._dependencies,
          allTransitiveDependencies:
              DailyAmountMapFamily._allTransitiveDependencies,
          month: month,
        );

  DailyAmountMapProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.month,
  }) : super.internal();

  final DateTime month;

  @override
  Override overrideWith(
    Stream<Map<DateTime, int>> Function(DailyAmountMapRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: DailyAmountMapProvider._internal(
        (ref) => create(ref as DailyAmountMapRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        month: month,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<Map<DateTime, int>> createElement() {
    return _DailyAmountMapProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is DailyAmountMapProvider && other.month == month;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, month.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin DailyAmountMapRef on AutoDisposeStreamProviderRef<Map<DateTime, int>> {
  /// The parameter `month` of this provider.
  DateTime get month;
}

class _DailyAmountMapProviderElement
    extends AutoDisposeStreamProviderElement<Map<DateTime, int>>
    with DailyAmountMapRef {
  _DailyAmountMapProviderElement(super.provider);

  @override
  DateTime get month => (origin as DailyAmountMapProvider).month;
}

String _$sessionsOnDayHash() => r'592854fcefa46d1e777842e17e1efe76f654093e';

/// See also [sessionsOnDay].
@ProviderFor(sessionsOnDay)
const sessionsOnDayProvider = SessionsOnDayFamily();

/// See also [sessionsOnDay].
class SessionsOnDayFamily extends Family<AsyncValue<List<WorkSession>>> {
  /// See also [sessionsOnDay].
  const SessionsOnDayFamily();

  /// See also [sessionsOnDay].
  SessionsOnDayProvider call(
    DateTime date,
  ) {
    return SessionsOnDayProvider(
      date,
    );
  }

  @override
  SessionsOnDayProvider getProviderOverride(
    covariant SessionsOnDayProvider provider,
  ) {
    return call(
      provider.date,
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
  String? get name => r'sessionsOnDayProvider';
}

/// See also [sessionsOnDay].
class SessionsOnDayProvider
    extends AutoDisposeStreamProvider<List<WorkSession>> {
  /// See also [sessionsOnDay].
  SessionsOnDayProvider(
    DateTime date,
  ) : this._internal(
          (ref) => sessionsOnDay(
            ref as SessionsOnDayRef,
            date,
          ),
          from: sessionsOnDayProvider,
          name: r'sessionsOnDayProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$sessionsOnDayHash,
          dependencies: SessionsOnDayFamily._dependencies,
          allTransitiveDependencies:
              SessionsOnDayFamily._allTransitiveDependencies,
          date: date,
        );

  SessionsOnDayProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.date,
  }) : super.internal();

  final DateTime date;

  @override
  Override overrideWith(
    Stream<List<WorkSession>> Function(SessionsOnDayRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: SessionsOnDayProvider._internal(
        (ref) => create(ref as SessionsOnDayRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        date: date,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<List<WorkSession>> createElement() {
    return _SessionsOnDayProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is SessionsOnDayProvider && other.date == date;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, date.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin SessionsOnDayRef on AutoDisposeStreamProviderRef<List<WorkSession>> {
  /// The parameter `date` of this provider.
  DateTime get date;
}

class _SessionsOnDayProviderElement
    extends AutoDisposeStreamProviderElement<List<WorkSession>>
    with SessionsOnDayRef {
  _SessionsOnDayProviderElement(super.provider);

  @override
  DateTime get date => (origin as SessionsOnDayProvider).date;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
