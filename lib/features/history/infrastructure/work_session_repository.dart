import '../domain/work_session.dart';

abstract interface class WorkSessionRepository {
  Stream<List<WorkSession>> watchAll();

  Future<List<WorkSession>> fetchAll();

  Future<WorkSession?> findById(String id);

  Future<WorkSession> create({
    required String categoryId,
    required DateTime startTime,
    required DateTime endTime,
    required int durationSec,
    required int amount,
    String? memo,
    required WorkSessionInputMethod inputMethod,
  });

  Future<void> update(WorkSession session);

  Future<void> softDelete(String id);

  /// 指定された日のローカルタイムゾーン 0:00〜24:00 の範囲に
  /// `endTime` が含まれるアクティブ（ソフトデリート前）セッションが
  /// 1 件以上存在するかを返す（issue #178）。
  ///
  /// リマインダー通知の「今日はもう作業した」判定に使う。
  Future<bool> hasSessionOn(DateTime day);
}
