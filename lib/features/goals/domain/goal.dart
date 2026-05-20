enum GoalType {
  cumulative,
  period;

  String get dbValue => name;

  static GoalType fromDbValue(String value) {
    return GoalType.values.firstWhere(
      (e) => e.dbValue == value,
      orElse: () => GoalType.cumulative,
    );
  }
}

class Goal {
  const Goal({
    required this.id,
    required this.type,
    required this.targetAmount,
    this.categoryId,
    this.periodStart,
    this.periodEnd,
    this.achievedAt,
    this.sortOrder = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final GoalType type;
  final int targetAmount;
  final String? categoryId;
  final DateTime? periodStart;
  final DateTime? periodEnd;
  final DateTime? achievedAt;
  final int sortOrder;
  final DateTime createdAt;
  final DateTime updatedAt;

  bool get isAchieved => achievedAt != null;
  bool get isCategoryScoped => categoryId != null;

  static const int targetAmountMin = 1;
  static const int targetAmountMax = 100000000;

  static String? validateTargetAmount(String? value) {
    if (value == null || value.trim().isEmpty) {
      return '目標金額を入力してください';
    }
    final parsed = int.tryParse(value.trim());
    if (parsed == null) return '数値を入力してください';
    if (parsed < targetAmountMin) return '$targetAmountMin円以上を入力してください';
    if (parsed > targetAmountMax) return '上限を超えています';
    return null;
  }

  static String? validatePeriod({
    required GoalType type,
    DateTime? start,
    DateTime? end,
  }) {
    if (type != GoalType.period) return null;
    if (start == null || end == null) return '期間を選択してください';
    if (!start.isBefore(end) && start != end) {
      return '開始日は終了日以前にしてください';
    }
    return null;
  }

  Goal copyWith({
    GoalType? type,
    int? targetAmount,
    String? categoryId,
    bool clearCategoryId = false,
    DateTime? periodStart,
    DateTime? periodEnd,
    bool clearPeriod = false,
    DateTime? achievedAt,
    bool clearAchievedAt = false,
    int? sortOrder,
    DateTime? updatedAt,
  }) {
    return Goal(
      id: id,
      type: type ?? this.type,
      targetAmount: targetAmount ?? this.targetAmount,
      categoryId: clearCategoryId ? null : (categoryId ?? this.categoryId),
      periodStart: clearPeriod ? null : (periodStart ?? this.periodStart),
      periodEnd: clearPeriod ? null : (periodEnd ?? this.periodEnd),
      achievedAt: clearAchievedAt ? null : (achievedAt ?? this.achievedAt),
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
