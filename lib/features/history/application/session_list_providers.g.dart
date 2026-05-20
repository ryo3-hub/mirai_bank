// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'session_list_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$sessionListHash() => r'8da9b3a3b53c09c95b33d53f6754bdb9768e1d47';

/// See also [sessionList].
@ProviderFor(sessionList)
final sessionListProvider =
    AutoDisposeStreamProvider<List<WorkSession>>.internal(
  sessionList,
  name: r'sessionListProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$sessionListHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SessionListRef = AutoDisposeStreamProviderRef<List<WorkSession>>;
String _$groupedSessionListHash() =>
    r'a12a2f2885635209b3262c35dfabdafd3e82f3fa';

/// 履歴一覧用の表示データ。最新 [LimitedSessionGroups.displayLimit] 件に
/// 絞ってから日付グループ化する。総件数も同梱して、画面側で「N 件以上」
/// の告知に使えるようにする。
///
/// Copied from [groupedSessionList].
@ProviderFor(groupedSessionList)
final groupedSessionListProvider =
    AutoDisposeStreamProvider<LimitedSessionGroups>.internal(
  groupedSessionList,
  name: r'groupedSessionListProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$groupedSessionListHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef GroupedSessionListRef
    = AutoDisposeStreamProviderRef<LimitedSessionGroups>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
