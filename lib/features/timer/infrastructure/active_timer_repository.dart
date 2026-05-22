import '../domain/active_timer.dart';

abstract interface class ActiveTimerRepository {
  Stream<ActiveTimer?> watch();

  Future<ActiveTimer?> fetch();

  /// 新規タイマーを開始する。
  Future<void> start({
    required String categoryId,
    required DateTime startTime,
    required int targetDurationSec,
    String? memo,
  });

  /// 一時停止：これまでの稼働秒数を accumulated に確定して resumedAt を null に。
  Future<void> pause({required DateTime now});

  /// 再開：resumedAt を更新（accumulatedSec はそのまま）。
  Future<void> resume({required DateTime now});

  /// メモの更新。
  Future<void> updateMemo(String? memo);

  Future<void> clear();
}
