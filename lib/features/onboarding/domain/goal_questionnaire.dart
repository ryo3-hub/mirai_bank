/// オンボーディング目標設定の質問票。issue #108 で導入。
///
/// 3 つの質問（学習頻度 / 1 回あたりの時間 / 期間）にユーザーが答えると、
/// 累計目標金額を以下の式で算出する：
///
///   期間日数       = 期間月数 × 30
///   総稼働日数     = 期間日数 × (週稼働日数 ÷ 7)
///   累計目標金額   = 総稼働日数 × 1日あたり時間 × 時給
///
/// 月間目標は `累計目標金額 ÷ 期間月数` で導出可能。
library;

/// Q1: 学習頻度（ライフスタイル）
enum LearningFrequency {
  daily(
    daysPerWeek: 7,
    label: '毎日コツコツ続けたい',
    emoji: '🌱',
    sub: '週7日',
  ),
  weekday(
    daysPerWeek: 5,
    label: '平日中心にしっかりやりたい',
    emoji: '💼',
    sub: '週5日',
  ),
  weekend(
    daysPerWeek: 2,
    label: '週末メインで集中したい',
    emoji: '🎯',
    sub: '週2日',
  ),
  ownPace(
    daysPerWeek: 3,
    label: '自分のペースで気が向いたとき',
    emoji: '🌊',
    sub: '週3日想定',
  );

  const LearningFrequency({
    required this.daysPerWeek,
    required this.label,
    required this.emoji,
    required this.sub,
  });

  /// 計算式で使う 1 週間あたりの稼働日数。
  final int daysPerWeek;

  /// 選択肢のメインラベル。
  final String label;

  /// 選択肢の左に置く絵文字。
  final String emoji;

  /// 補足テキスト（週X日）。
  final String sub;

  /// 警告文中で使う短い表記（毎日 / 平日 / 週末 / 気が向いたとき）。
  String get phrase {
    switch (this) {
      case LearningFrequency.daily:
        return '毎日';
      case LearningFrequency.weekday:
        return '平日';
      case LearningFrequency.weekend:
        return '週末';
      case LearningFrequency.ownPace:
        return '気が向いたとき';
    }
  }

  /// 「続けやすい」推奨選択肢かどうか。
  /// 毎日だと負担、週末のみだと習慣化しにくい — 平日中心が習慣形成のスイートスポット。
  bool get isRecommended => this == LearningFrequency.weekday;
}

/// Q2: 1 回あたりの作業時間（集中度）
enum LearningSessionLength {
  deep(
    hoursPerDay: 2.5,
    label: 'じっくり腰を据えて',
    emoji: '⏳',
    sub: '2時間以上',
  ),
  focused(
    hoursPerDay: 1.5,
    label: 'しっかり集中して',
    emoji: '🔥',
    sub: '1〜2時間',
  ),
  quick(
    hoursPerDay: 0.75,
    label: '短時間でテンポよく',
    emoji: '⚡',
    sub: '30分〜1時間',
  ),
  spare(
    hoursPerDay: 0.4,
    label: 'スキマ時間で少しずつ',
    emoji: '☕',
    sub: '15〜30分',
  );

  const LearningSessionLength({
    required this.hoursPerDay,
    required this.label,
    required this.emoji,
    required this.sub,
  });

  /// 計算式で使う 1 日あたりの想定時間（時間）。
  final double hoursPerDay;

  final String label;
  final String emoji;
  final String sub;

  /// 「続けやすい」推奨選択肢かどうか。
  /// じっくりは負担、スキマは効果が薄い — 30〜60 分が定番の続けやすい長さ。
  bool get isRecommended => this == LearningSessionLength.quick;
}

/// Q3: 取り組み期間（コミット度）
enum LearningPeriod {
  oneMonth(
    months: 1,
    label: '短期集中で結果を出したい',
    emoji: '🚀',
    sub: '1ヶ月',
  ),
  threeMonths(
    months: 3,
    label: '中期的に身につけたい',
    emoji: '📈',
    sub: '3ヶ月',
  ),
  sixMonths(
    months: 6,
    label: '半年かけてじっくり',
    emoji: '🌳',
    sub: '半年',
  ),
  oneYear(
    months: 12,
    label: '長期的に習慣にしたい',
    emoji: '♾️',
    sub: '1年以上',
  );

  const LearningPeriod({
    required this.months,
    required this.label,
    required this.emoji,
    required this.sub,
  });

  /// 計算式で使う期間（月）。
  final int months;

  /// `periodEnd - periodStart` に使う日数。1 ヶ月 = 30 日換算。
  int get days => months * 30;

  final String label;
  final String emoji;
  final String sub;

  /// 警告文中で使う短い表記（1ヶ月 / 3ヶ月 / 半年 / 1年）。
  String get phrase {
    switch (this) {
      case LearningPeriod.oneMonth:
        return '1ヶ月';
      case LearningPeriod.threeMonths:
        return '3ヶ月';
      case LearningPeriod.sixMonths:
        return '半年';
      case LearningPeriod.oneYear:
        return '1年';
    }
  }

  /// 「続けやすい」推奨選択肢かどうか。
  /// 1ヶ月だと習慣化しきらない、半年・1年はコミット負担が大きい —
  /// 3ヶ月が習慣形成に必要十分な期間。
  bool get isRecommended => this == LearningPeriod.threeMonths;
}

/// 質問票への 3 つの回答を保持し、目標金額を算出する。
class GoalQuestionnaireResult {
  const GoalQuestionnaireResult({
    required this.frequency,
    required this.sessionLength,
    required this.period,
  });

  final LearningFrequency frequency;
  final LearningSessionLength sessionLength;
  final LearningPeriod period;

  /// 累計目標金額 = 総稼働日数 × 1日あたり時間 × 時給
  ///
  /// 総稼働日数 = 期間日数(=月数×30) × (週稼働日数 ÷ 7)
  /// 小数は四捨五入。
  int cumulativeTargetAmount(int hourlyRate) {
    final periodDays = period.months * 30;
    final activeDays = periodDays * frequency.daysPerWeek / 7;
    final totalHours = activeDays * sessionLength.hoursPerDay;
    return (totalHours * hourlyRate).round();
  }

  /// 月間目標金額 = 累計 ÷ 期間月数（端数四捨五入）。
  int monthlyTargetAmount(int hourlyRate) {
    return (cumulativeTargetAmount(hourlyRate) / period.months).round();
  }

  /// 年間累計目標金額 = 月間目標 × 12（端数四捨五入）。
  /// 警告文の「年間累計 約◯万円」の算出に使う。
  int annualTargetAmount(int hourlyRate) {
    return monthlyTargetAmount(hourlyRate) * 12;
  }

  /// 「飛ばしすぎ」の組み合わせかどうか。
  ///
  /// 高頻度（毎日 / 平日）× 高強度（じっくり / しっかり）× 長期（半年 / 1年）の
  /// 8 通りで true を返す。issue #108 の継続支援メッセージで使う。
  bool get isHardCombo {
    final highFreq = frequency == LearningFrequency.daily ||
        frequency == LearningFrequency.weekday;
    final highIntensity =
        sessionLength == LearningSessionLength.deep ||
            sessionLength == LearningSessionLength.focused;
    final longTerm = period == LearningPeriod.sixMonths ||
        period == LearningPeriod.oneYear;
    return highFreq && highIntensity && longTerm;
  }
}
