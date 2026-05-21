/// 1 日分のカレンダー集計。
///
/// [amount] はその日の合計金額（円）、[dominantCategoryId] はその日に
/// 最も金額を稼いだカテゴリの ID（同点の場合は最初に出現した方）。
/// 記録がない日は Map に entry が入らないので、ここでは「必ず amount > 0」を
/// 前提に扱ってよい。
class DailyStats {
  const DailyStats({
    required this.amount,
    required this.dominantCategoryId,
  });

  final int amount;
  final String dominantCategoryId;
}
