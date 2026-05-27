// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'encouragement_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$dailyEncouragementHash() =>
    r'30ce893faf92f7d26bdb71159b9f15d87e49e0c0';

/// アプリ起動時にランダムに選ばれる励ましメッセージ。
///
/// `keepAlive: true` なのでアプリのライフタイム中はキャッシュされ、
/// 同じセッション内では同じ文言を表示する。次回起動時に新たに選び直される。
///
/// 連続学習日数（[currentStreakProvider]）に応じてメッセージのプール（tier）が
/// 切り替わる。streak の取得を待ってから選ぶことで、適切なティアから引ける。
///
/// Copied from [dailyEncouragement].
@ProviderFor(dailyEncouragement)
final dailyEncouragementProvider = FutureProvider<String>.internal(
  dailyEncouragement,
  name: r'dailyEncouragementProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$dailyEncouragementHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef DailyEncouragementRef = FutureProviderRef<String>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
