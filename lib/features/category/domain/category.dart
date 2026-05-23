class Category {
  const Category({
    required this.id,
    required this.name,
    required this.hourlyRate,
    required this.colorCode,
    required this.iconCode,
    this.sortOrder = 0,
    this.masterKey,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  final String id;
  final String name;
  final int hourlyRate;
  final String colorCode;
  final String iconCode;
  final int sortOrder;

  /// プリセット master 由来の場合、`CategoryMaster.minors[].key` を保持する
  /// （issue #97）。自由入力で作成した場合は null。
  final String? masterKey;

  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  static const int nameMaxLength = 30;
  static const int hourlyRateMin = 100;
  static const int hourlyRateMax = 10000;

  static String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'カテゴリ名を入力してください';
    }
    if (value.trim().length > nameMaxLength) {
      return '$nameMaxLength文字以内で入力してください';
    }
    return null;
  }

  static String? validateHourlyRate(String? value) {
    if (value == null || value.trim().isEmpty) {
      return '時給を入力してください';
    }
    final parsed = int.tryParse(value.trim());
    if (parsed == null) {
      return '数値を入力してください';
    }
    if (parsed < hourlyRateMin) {
      return '$hourlyRateMin円以上を入力してください';
    }
    if (parsed > hourlyRateMax) {
      return '$hourlyRateMax円以下を入力してください';
    }
    return null;
  }

  Category copyWith({
    String? name,
    int? hourlyRate,
    String? colorCode,
    String? iconCode,
    int? sortOrder,
    String? masterKey,
    bool clearMasterKey = false,
    DateTime? updatedAt,
    DateTime? deletedAt,
  }) {
    return Category(
      id: id,
      name: name ?? this.name,
      hourlyRate: hourlyRate ?? this.hourlyRate,
      colorCode: colorCode ?? this.colorCode,
      iconCode: iconCode ?? this.iconCode,
      sortOrder: sortOrder ?? this.sortOrder,
      masterKey: clearMasterKey ? null : (masterKey ?? this.masterKey),
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }
}
