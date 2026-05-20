enum WorkSessionInputMethod {
  timer,
  manual;

  String get dbValue => name;

  static WorkSessionInputMethod fromDbValue(String value) {
    return WorkSessionInputMethod.values.firstWhere(
      (e) => e.dbValue == value,
      orElse: () => WorkSessionInputMethod.manual,
    );
  }
}

class WorkSession {
  const WorkSession({
    required this.id,
    required this.categoryId,
    required this.startTime,
    required this.endTime,
    required this.durationSec,
    required this.amount,
    this.memo,
    required this.inputMethod,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  final String id;
  final String categoryId;
  final DateTime startTime;
  final DateTime endTime;
  final int durationSec;
  final int amount;
  final String? memo;
  final WorkSessionInputMethod inputMethod;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  static const int memoMaxLength = 100;

  /// Memo は任意項目。null・空文字は OK。
  /// 100 文字超は将来のクラウド DB 移行を見据えて拒否する。
  static String? validateMemo(String? value) {
    if (value == null) return null;
    if (value.length > memoMaxLength) {
      return 'メモは$memoMaxLength文字以内で入力してください';
    }
    return null;
  }

  WorkSession copyWith({
    String? categoryId,
    DateTime? startTime,
    DateTime? endTime,
    int? durationSec,
    int? amount,
    String? memo,
    WorkSessionInputMethod? inputMethod,
    DateTime? updatedAt,
    DateTime? deletedAt,
  }) {
    return WorkSession(
      id: id,
      categoryId: categoryId ?? this.categoryId,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      durationSec: durationSec ?? this.durationSec,
      amount: amount ?? this.amount,
      memo: memo ?? this.memo,
      inputMethod: inputMethod ?? this.inputMethod,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }
}
