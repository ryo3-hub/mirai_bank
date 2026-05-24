import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../infrastructure/database/database_provider.dart';
import '../domain/timer_preset.dart';
import '../infrastructure/timer_preset_repository.dart';
import '../infrastructure/timer_preset_repository_impl.dart';

part 'timer_preset_providers.g.dart';

@Riverpod(keepAlive: true)
TimerPresetRepository timerPresetRepository(Ref ref) {
  return TimerPresetRepositoryImpl(ref.watch(appDatabaseProvider));
}

@riverpod
Stream<List<TimerPreset>> timerPresetList(Ref ref) {
  return ref.watch(timerPresetRepositoryProvider).watchAll();
}

@riverpod
class TimerPresetController extends _$TimerPresetController {
  @override
  void build() {}

  Future<void> create({
    required int minutes,
    required String label,
  }) {
    return ref
        .read(timerPresetRepositoryProvider)
        .create(minutes: minutes, label: label.trim());
  }

  Future<void> delete(String id) {
    return ref.read(timerPresetRepositoryProvider).softDelete(id);
  }

  /// 並べ替え（issue #120）。引数は新しい並び順の id 列。
  Future<void> reorder(List<String> orderedIds) {
    return ref.read(timerPresetRepositoryProvider).reorder(orderedIds);
  }
}
