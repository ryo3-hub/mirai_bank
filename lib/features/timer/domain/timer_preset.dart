/// タイマーを開始するときに選ぶプリセット時間。
///
/// デフォルトの 15 / 30 / 60 分はアプリ初回起動時にシードされる
/// （`isDefault = true`）。ユーザーが追加 / 削除（ソフトデリート）できる。
class TimerPreset {
  const TimerPreset({
    required this.id,
    required this.minutes,
    this.label = '',
    this.sortOrder = 0,
    this.isDefault = false,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  final String id;
  final int minutes;
  final String label;
  final int sortOrder;
  final bool isDefault;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  int get durationSec => minutes * 60;

  static const int minutesMin = 5;
  static const int minutesMax = 480; // 8 時間
  static const int minutesStep = 5;

  static String? validateMinutes(int? value) {
    if (value == null) return '時間を入力してください';
    if (value < minutesMin) return '$minutesMin分以上を入力してください';
    if (value > minutesMax) return '$minutesMax分以下を入力してください';
    if (value % minutesStep != 0) return '$minutesStep分単位で入力してください';
    return null;
  }

  TimerPreset copyWith({
    int? minutes,
    String? label,
    int? sortOrder,
    DateTime? updatedAt,
    DateTime? deletedAt,
  }) {
    return TimerPreset(
      id: id,
      minutes: minutes ?? this.minutes,
      label: label ?? this.label,
      sortOrder: sortOrder ?? this.sortOrder,
      isDefault: isDefault,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }
}
