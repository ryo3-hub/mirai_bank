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
}
