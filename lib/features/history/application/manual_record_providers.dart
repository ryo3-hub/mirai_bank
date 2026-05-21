import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'work_session_providers.dart';

part 'manual_record_providers.g.dart';

/// 履歴セッションに対する操作。
///
/// issue #85 で履歴の手動追加 / 編集 UI を撤去したため、現状は **削除**
/// （スワイプ削除）でのみ使われる。新規セッションの作成はタイマー
/// 経路に一本化された。
@riverpod
class ManualRecordController extends _$ManualRecordController {
  @override
  void build() {}

  Future<void> delete(String sessionId) {
    return ref.read(workSessionRepositoryProvider).softDelete(sessionId);
  }
}
