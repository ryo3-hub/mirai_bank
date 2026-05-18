import '../domain/active_timer.dart';

abstract interface class ActiveTimerRepository {
  Stream<ActiveTimer?> watch();

  Future<ActiveTimer?> fetch();

  Future<void> save({
    required String categoryId,
    required DateTime startTime,
    String? memo,
  });

  Future<void> clear();
}
