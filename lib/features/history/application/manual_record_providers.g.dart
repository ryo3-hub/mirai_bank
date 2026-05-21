// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'manual_record_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$manualRecordControllerHash() =>
    r'95df9811eeef12d351588fc24b576b69d845e5cf';

/// 履歴セッションに対する操作。
///
/// issue #85 で履歴の手動追加 / 編集 UI を撤去したため、現状は **削除**
/// （スワイプ削除）でのみ使われる。新規セッションの作成はタイマー
/// 経路に一本化された。
///
/// Copied from [ManualRecordController].
@ProviderFor(ManualRecordController)
final manualRecordControllerProvider =
    AutoDisposeNotifierProvider<ManualRecordController, void>.internal(
  ManualRecordController.new,
  name: r'manualRecordControllerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$manualRecordControllerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$ManualRecordController = AutoDisposeNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
