// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'calendar_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$dailyStatsMapHash() => r'47164c3aabfe363175ad8a569d45ce7fa797d9a0';

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

/// See also [dailyStatsMap].
@ProviderFor(dailyStatsMap)
const dailyStatsMapProvider = DailyStatsMapFamily();

/// See also [dailyStatsMap].
class DailyStatsMapFamily
    extends Family<AsyncValue<Map<DateTime, DailyStats>>> {
  /// See also [dailyStatsMap].
  const DailyStatsMapFamily();

  /// See also [dailyStatsMap].
  DailyStatsMapProvider call(
    DateTime month,
  ) {
    return DailyStatsMapProvider(
      month,
    );
  }

  @override
  DailyStatsMapProvider getProviderOverride(
    covariant DailyStatsMapProvider provider,
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
  String? get name => r'dailyStatsMapProvider';
}

/// See also [dailyStatsMap].
class DailyStatsMapProvider
    extends AutoDisposeStreamProvider<Map<DateTime, DailyStats>> {
  /// See also [dailyStatsMap].
  DailyStatsMapProvider(
    DateTime month,
  ) : this._internal(
          (ref) => dailyStatsMap(
            ref as DailyStatsMapRef,
            month,
          ),
          from: dailyStatsMapProvider,
          name: r'dailyStatsMapProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$dailyStatsMapHash,
          dependencies: DailyStatsMapFamily._dependencies,
          allTransitiveDependencies:
              DailyStatsMapFamily._allTransitiveDependencies,
          month: month,
        );

  DailyStatsMapProvider._internal(
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
    Stream<Map<DateTime, DailyStats>> Function(DailyStatsMapRef provider)
        create,
  ) {
    return ProviderOverride(
      origin: this,
      override: DailyStatsMapProvider._internal(
        (ref) => create(ref as DailyStatsMapRef),
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
  AutoDisposeStreamProviderElement<Map<DateTime, DailyStats>> createElement() {
    return _DailyStatsMapProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is DailyStatsMapProvider && other.month == month;
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
mixin DailyStatsMapRef
    on AutoDisposeStreamProviderRef<Map<DateTime, DailyStats>> {
  /// The parameter `month` of this provider.
  DateTime get month;
}

class _DailyStatsMapProviderElement
    extends AutoDisposeStreamProviderElement<Map<DateTime, DailyStats>>
    with DailyStatsMapRef {
  _DailyStatsMapProviderElement(super.provider);

  @override
  DateTime get month => (origin as DailyStatsMapProvider).month;
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
