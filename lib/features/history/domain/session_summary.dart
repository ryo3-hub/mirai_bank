import '../../category/domain/category.dart';

class SessionSummary {
  const SessionSummary({
    required this.amount,
    required this.durationSec,
  });

  static const SessionSummary empty =
      SessionSummary(amount: 0, durationSec: 0);

  final int amount;
  final int durationSec;
}

class CategoryBreakdownItem {
  const CategoryBreakdownItem({
    required this.category,
    required this.amount,
    required this.durationSec,
  });

  final Category category;
  final int amount;
  final int durationSec;
}
