class AmountCalculator {
  const AmountCalculator._();

  /// 課金単位（秒）。日本のアルバイト式の 15 分単位（issue #95）。
  static const int billingUnitSec = 15 * 60;

  static int calculate({
    required int durationSec,
    required int hourlyRate,
  }) {
    if (durationSec <= 0 || hourlyRate <= 0) return 0;
    return (durationSec * hourlyRate / 3600).round();
  }

  /// 15 分単位に切り下げてから金額を計算する。
  ///
  /// 例（時給 2000 円）:
  ///   14:59 → 0 円
  ///   15:00 → 500 円
  ///   23:00 → 500 円
  ///   30:00 → 1,000 円
  static int calculatePaid({
    required int workedSec,
    required int hourlyRate,
  }) {
    final paidSec = paidDurationSec(workedSec);
    return calculate(durationSec: paidSec, hourlyRate: hourlyRate);
  }

  /// 経過秒数を 15 分単位で切り下げた秒数（=課金対象時間）を返す。
  static int paidDurationSec(int workedSec) {
    if (workedSec <= 0) return 0;
    return (workedSec ~/ billingUnitSec) * billingUnitSec;
  }
}
