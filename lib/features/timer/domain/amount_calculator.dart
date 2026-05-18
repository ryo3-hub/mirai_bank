class AmountCalculator {
  const AmountCalculator._();

  static int calculate({
    required int durationSec,
    required int hourlyRate,
  }) {
    if (durationSec <= 0 || hourlyRate <= 0) return 0;
    return (durationSec * hourlyRate / 3600).round();
  }
}
