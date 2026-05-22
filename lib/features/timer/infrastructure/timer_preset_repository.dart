import '../domain/timer_preset.dart';

abstract interface class TimerPresetRepository {
  Stream<List<TimerPreset>> watchAll();

  Future<List<TimerPreset>> fetchAll();

  Future<TimerPreset?> findById(String id);

  Future<TimerPreset> create({
    required int minutes,
    required String label,
  });

  Future<void> softDelete(String id);
}
