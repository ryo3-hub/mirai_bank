import '../../category/domain/category.dart';

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

/// issue #100 で導入したプリセット目標の種別。
///
/// 自由入力をやめ、短期 / 中期 / 長期の 3 ボタンから選択する方式に変更した。
/// DB スキーマは互換性のためそのまま（`GoalType.period` で保存し、
/// `periodEnd - periodStart` の日数から本 enum を導出する）。
enum GoalPreset {
  short(days: 7, allCategoriesAmount: 10000, label: '短期目標'),
  mid(days: 30, allCategoriesAmount: 50000, label: '中期目標'),
  long(days: 90, allCategoriesAmount: 150000, label: '長期目標');

  const GoalPreset({
    required this.days,
    required this.allCategoriesAmount,
    required this.label,
  });

  /// 開始から達成予定日までの日数。
  final int days;

  /// 全カテゴリ（カテゴリ未指定）時に使う固定の目標金額。
  final int allCategoriesAmount;

  /// 画面表示ラベル。
  final String label;

  /// 指定カテゴリで本プリセットを使う場合の目標金額を返す。
  /// カテゴリが null の場合は [allCategoriesAmount]、
  /// カテゴリ指定時は `hourlyRate × days`。
  int targetAmountFor(Category? category) {
    if (category == null) return allCategoriesAmount;
    return category.hourlyRate * days;
  }

  /// 既存 [Goal] からプリセットを逆引きする。
  /// 期間日数が 7 / 30 / 90 のいずれにも合致しない（issue #100 以前の自由入力 /
  /// 累計目標）場合は null を返す。
  static GoalPreset? fromGoal(Goal goal) {
    if (goal.type != GoalType.period) return null;
    final start = goal.periodStart;
    final end = goal.periodEnd;
    if (start == null || end == null) return null;
    final days = end.difference(start).inDays;
    for (final p in GoalPreset.values) {
      if (p.days == days) return p;
    }
    return null;
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
