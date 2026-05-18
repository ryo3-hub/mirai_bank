import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../shared/notification/post_session_notifier.dart';
import '../../category/application/category_providers.dart';
import '../../timer/domain/amount_calculator.dart';
import '../domain/work_session.dart';
import 'work_session_providers.dart';

part 'manual_record_providers.g.dart';

@riverpod
class ManualRecordController extends _$ManualRecordController {
  @override
  void build() {}

  Future<WorkSession> create({
    required String categoryId,
    required DateTime date,
    required int durationSec,
    String? memo,
  }) async {
    final category =
        await ref.read(categoryRepositoryProvider).findById(categoryId);
    if (category == null) {
      throw StateError('カテゴリが見つかりません');
    }
    final amount = AmountCalculator.calculate(
      durationSec: durationSec,
      hourlyRate: category.hourlyRate,
    );
    final endTime = _anchorTime(date);
    final startTime = endTime.subtract(Duration(seconds: durationSec));
    final session = await ref.read(workSessionRepositoryProvider).create(
          categoryId: categoryId,
          startTime: startTime,
          endTime: endTime,
          durationSec: durationSec,
          amount: amount,
          memo: _normalizeMemo(memo),
          inputMethod: WorkSessionInputMethod.manual,
        );
    await ref.read(postSessionNotifierProvider).runAfterSessionSave();
    return session;
  }

  Future<void> updateRecord({
    required WorkSession session,
    required String categoryId,
    required DateTime date,
    required int durationSec,
    String? memo,
  }) async {
    final category =
        await ref.read(categoryRepositoryProvider).findById(categoryId);
    if (category == null) {
      throw StateError('カテゴリが見つかりません');
    }
    final amount = AmountCalculator.calculate(
      durationSec: durationSec,
      hourlyRate: category.hourlyRate,
    );
    final endTime = _anchorTime(date);
    final startTime = endTime.subtract(Duration(seconds: durationSec));
    final updated = WorkSession(
      id: session.id,
      categoryId: categoryId,
      startTime: startTime,
      endTime: endTime,
      durationSec: durationSec,
      amount: amount,
      memo: _normalizeMemo(memo),
      inputMethod: session.inputMethod,
      createdAt: session.createdAt,
      updatedAt: session.updatedAt,
      deletedAt: session.deletedAt,
    );
    await ref.read(workSessionRepositoryProvider).update(updated);
    await ref.read(postSessionNotifierProvider).runAfterSessionSave();
  }

  Future<void> delete(String sessionId) {
    return ref.read(workSessionRepositoryProvider).softDelete(sessionId);
  }

  DateTime _anchorTime(DateTime date) =>
      DateTime(date.year, date.month, date.day, 12);

  String? _normalizeMemo(String? memo) {
    if (memo == null) return null;
    final trimmed = memo.trim();
    return trimmed.isEmpty ? null : trimmed;
  }
}
