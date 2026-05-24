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

  group('GoalQuestionnaireResult.isHardCombo', () {
    // 高頻度（毎日 / 平日）× 高強度（じっくり / しっかり）× 長期（半年 / 1年）
    // の 8 通りで true。それ以外は false。
    test('毎日 + じっくり + 1年 → true', () {
      const r = GoalQuestionnaireResult(
        frequency: LearningFrequency.daily,
        sessionLength: LearningSessionLength.deep,
        period: LearningPeriod.oneYear,
      );
      expect(r.isHardCombo, isTrue);
    });

    test('平日 + しっかり + 半年 → true', () {
      const r = GoalQuestionnaireResult(
        frequency: LearningFrequency.weekday,
        sessionLength: LearningSessionLength.focused,
        period: LearningPeriod.sixMonths,
      );
      expect(r.isHardCombo, isTrue);
    });

    test('週末 + じっくり + 1年 → false (頻度が低い)', () {
      const r = GoalQuestionnaireResult(
        frequency: LearningFrequency.weekend,
        sessionLength: LearningSessionLength.deep,
        period: LearningPeriod.oneYear,
      );
      expect(r.isHardCombo, isFalse);
    });

    test('毎日 + スキマ + 1年 → false (強度が低い)', () {
      const r = GoalQuestionnaireResult(
        frequency: LearningFrequency.daily,
        sessionLength: LearningSessionLength.spare,
        period: LearningPeriod.oneYear,
      );
      expect(r.isHardCombo, isFalse);
    });

    test('毎日 + じっくり + 1ヶ月 → false (短期)', () {
      const r = GoalQuestionnaireResult(
        frequency: LearningFrequency.daily,
        sessionLength: LearningSessionLength.deep,
        period: LearningPeriod.oneMonth,
      );
      expect(r.isHardCombo, isFalse);
    });
  });

  group('GoalQuestionnaireResult.annualTargetAmount', () {
    test('1年期間: 累計 = 年間累計', () {
      const r = GoalQuestionnaireResult(
        frequency: LearningFrequency.daily,
        sessionLength: LearningSessionLength.deep,
        period: LearningPeriod.oneYear,
      );
      // 累計: 7 × 2.5 × 30 × 12 × 1000 = 6,300,000
      // 月間: 6,300,000 / 12 = 525,000 / 年間: × 12 = 6,300,000
      expect(r.annualTargetAmount(1000), 6300000);
    });

    test('半年期間: 月間 × 12 が年間累計', () {
      const r = GoalQuestionnaireResult(
        frequency: LearningFrequency.daily,
        sessionLength: LearningSessionLength.deep,
        period: LearningPeriod.sixMonths,
      );
      // 累計: 7 × 2.5 × 30 × 6 × 1000 = 3,150,000
      // 月間: 3,150,000 / 6 = 525,000 / 年間: × 12 = 6,300,000
      expect(r.annualTargetAmount(1000), 6300000);
    });
  });

  group('LearningFrequency.phrase / LearningPeriod.phrase', () {
    test('警告文用の短縮表記が定義されている', () {
      expect(LearningFrequency.daily.phrase, '毎日');
      expect(LearningFrequency.weekday.phrase, '平日');
      expect(LearningFrequency.weekend.phrase, '週末');
      expect(LearningFrequency.ownPace.phrase, '気が向いたとき');
      expect(LearningPeriod.oneMonth.phrase, '1ヶ月');
      expect(LearningPeriod.threeMonths.phrase, '3ヶ月');
      expect(LearningPeriod.sixMonths.phrase, '半年');
      expect(LearningPeriod.oneYear.phrase, '1年');
    });
  });

  group('isRecommended', () {
    test('LearningFrequency は weekday のみ true', () {
      expect(LearningFrequency.daily.isRecommended, isFalse);
      expect(LearningFrequency.weekday.isRecommended, isTrue);
      expect(LearningFrequency.weekend.isRecommended, isFalse);
      expect(LearningFrequency.ownPace.isRecommended, isFalse);
    });

    test('LearningSessionLength は quick のみ true', () {
      expect(LearningSessionLength.deep.isRecommended, isFalse);
      expect(LearningSessionLength.focused.isRecommended, isFalse);
      expect(LearningSessionLength.quick.isRecommended, isTrue);
      expect(LearningSessionLength.spare.isRecommended, isFalse);
    });

    test('LearningPeriod は threeMonths のみ true', () {
      expect(LearningPeriod.oneMonth.isRecommended, isFalse);
      expect(LearningPeriod.threeMonths.isRecommended, isTrue);
      expect(LearningPeriod.sixMonths.isRecommended, isFalse);
      expect(LearningPeriod.oneYear.isRecommended, isFalse);
    });
  });
}
