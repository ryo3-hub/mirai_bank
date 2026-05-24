import 'package:flutter_test/flutter_test.dart';
import 'package:mirai_bank/features/onboarding/domain/goal_questionnaire.dart';

void main() {
  group('GoalQuestionnaireResult.cumulativeTargetAmount', () {
    test('日次 + じっくり + 1ヶ月 + 時給1000 = 525,000', () {
      // 週稼働日数=7 × 時間/日=2.5 × 30 × 期間月数=1 × 時給=1000
      const result = GoalQuestionnaireResult(
        frequency: LearningFrequency.daily,
        sessionLength: LearningSessionLength.deep,
        period: LearningPeriod.oneMonth,
      );
      expect(result.cumulativeTargetAmount(1000), 525000);
    });

    test('週末 + スキマ + 1ヶ月 + 時給1000 = 24,000', () {
      // 2 × 0.4 × 30 × 1 × 1000 = 24,000
      const result = GoalQuestionnaireResult(
        frequency: LearningFrequency.weekend,
        sessionLength: LearningSessionLength.spare,
        period: LearningPeriod.oneMonth,
      );
      expect(result.cumulativeTargetAmount(1000), 24000);
    });

    test('平日 + しっかり + 3ヶ月 + 時給2000 = 1,350,000', () {
      // 5 × 1.5 × 30 × 3 × 2000 = 1,350,000
      const result = GoalQuestionnaireResult(
        frequency: LearningFrequency.weekday,
        sessionLength: LearningSessionLength.focused,
        period: LearningPeriod.threeMonths,
      );
      expect(result.cumulativeTargetAmount(2000), 1350000);
    });

    test('自分のペース + 短時間 + 半年 + 時給1500 = 607,500', () {
      // 3 × 0.75 × 30 × 6 × 1500 = 607,500
      const result = GoalQuestionnaireResult(
        frequency: LearningFrequency.ownPace,
        sessionLength: LearningSessionLength.quick,
        period: LearningPeriod.sixMonths,
      );
      expect(result.cumulativeTargetAmount(1500), 607500);
    });

    test('1年期間でも算出できる', () {
      // 7 × 2.5 × 30 × 12 × 1000 = 6,300,000
      const result = GoalQuestionnaireResult(
        frequency: LearningFrequency.daily,
        sessionLength: LearningSessionLength.deep,
        period: LearningPeriod.oneYear,
      );
      expect(result.cumulativeTargetAmount(1000), 6300000);
    });
  });

  group('GoalQuestionnaireResult.monthlyTargetAmount', () {
    test('累計 ÷ 期間月数 で月間目標を返す', () {
      const result = GoalQuestionnaireResult(
        frequency: LearningFrequency.daily,
        sessionLength: LearningSessionLength.deep,
        period: LearningPeriod.threeMonths,
      );
      // 累計: 7 × 2.5 × 30 × 3 × 1000 = 1,575,000
      // 月間: 1,575,000 ÷ 3 = 525,000
      expect(result.monthlyTargetAmount(1000), 525000);
    });
  });

  group('LearningPeriod.days', () {
    test('1ヶ月=30日 / 3ヶ月=90日 / 半年=180日 / 1年=360日', () {
      expect(LearningPeriod.oneMonth.days, 30);
      expect(LearningPeriod.threeMonths.days, 90);
      expect(LearningPeriod.sixMonths.days, 180);
      expect(LearningPeriod.oneYear.days, 360);
    });
  });
}
