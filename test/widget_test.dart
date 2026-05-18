import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mirai_bank/app/app.dart';
import 'package:mirai_bank/features/category/application/category_providers.dart';
import 'package:mirai_bank/features/category/domain/category.dart';
import 'package:mirai_bank/features/goals/application/goal_providers.dart';
import 'package:mirai_bank/features/goals/domain/goal_progress.dart';
import 'package:mirai_bank/features/history/application/summary_providers.dart';
import 'package:mirai_bank/features/history/domain/session_summary.dart';
import 'package:mirai_bank/features/settings/application/setting_providers.dart';
import 'package:mirai_bank/features/settings/domain/app_setting.dart';
import 'package:mirai_bank/features/timer/application/timer_providers.dart';

List<Override> _stubOverrides() {
  return [
    activeTimerProvider.overrideWith((ref) => Stream.value(null)),
    categoriesListProvider.overrideWith((ref) => Stream.value(<Category>[])),
    for (final period in SummaryPeriod.values)
      summaryProvider(period).overrideWith(
        (ref) => Stream.value(SessionSummary.empty),
      ),
    activeGoalsWithProgressProvider.overrideWith(
      (ref) => Stream.value(<GoalProgress>[]),
    ),
    appSettingProvider.overrideWith(
      (ref) => Stream.value(AppSetting.defaults),
    ),
  ];
}

void main() {
  testWidgets('App boots and shows bottom navigation with 5 destinations',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: _stubOverrides(),
        child: const MiraiBankApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.text('ホーム'), findsWidgets);
    expect(find.text('カレンダー'), findsOneWidget);
    expect(find.text('統計'), findsOneWidget);
    expect(find.text('履歴'), findsOneWidget);
    expect(find.text('設定'), findsOneWidget);
  });

  testWidgets('Tapping bottom nav switches screens',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: _stubOverrides(),
        child: const MiraiBankApp(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('設定'));
    await tester.pumpAndSettle();

    expect(find.text('カテゴリ管理'), findsOneWidget);
  });
}
