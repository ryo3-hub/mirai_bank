import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:mirai_bank/features/category/application/category_providers.dart';
import 'package:mirai_bank/features/category/domain/category.dart';
import 'package:mirai_bank/features/history/domain/work_session.dart';
import 'package:mirai_bank/features/history/presentation/manual_record_sheet.dart';

Category _category() => Category(
      id: 'cat-1',
      name: 'プログラミング',
      hourlyRate: 3000,
      colorCode: '#2E7D5B',
      iconCode: 'code',
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
    );

WorkSession _session({
  WorkSessionInputMethod inputMethod = WorkSessionInputMethod.timer,
}) =>
    WorkSession(
      id: 'sess-1',
      categoryId: 'cat-1',
      startTime: DateTime(2026, 5, 20, 10, 0),
      endTime: DateTime(2026, 5, 20, 11, 30),
      durationSec: 5400,
      amount: 4500,
      memo: '既存メモ',
      inputMethod: inputMethod,
      createdAt: DateTime(2026, 5, 20),
      updatedAt: DateTime(2026, 5, 20),
    );

Widget _harness({WorkSession? initial}) {
  return ProviderScope(
    overrides: [
      categoriesListProvider.overrideWith(
        (ref) => Stream.value([_category()]),
      ),
    ],
    child: MaterialApp(
      home: Scaffold(
        body: ManualRecordSheet(initial: initial),
      ),
    ),
  );
}

void main() {
  setUpAll(() async {
    await initializeDateFormatting('ja');
  });

  group('ManualRecordSheet — 編集制限はタイマー記録のみ', () {
    testWidgets(
        'timer record edit: locks category/date/time, memo remains editable',
        (tester) async {
      await tester.pumpWidget(_harness(
        initial: _session(inputMethod: WorkSessionInputMethod.timer),
      ));
      await tester.pumpAndSettle();

      // 編集モード見出し + タイマー用の注意書き
      expect(find.text('記録を編集'), findsOneWidget);
      expect(find.text('タイマー記録のためメモのみ編集できます'), findsOneWidget);

      // lock_outline: subtitle + category + date + start + end = 5
      expect(find.byIcon(Icons.lock_outline), findsNWidgets(5));

      // 編集対象アイコンは表示されない
      expect(find.byIcon(Icons.calendar_today), findsNothing);
      expect(find.byIcon(Icons.access_time), findsNothing);
      expect(find.byIcon(Icons.unfold_more), findsNothing);

      // 日付・時刻タップでピッカーが開かない
      await tester.tap(find.text('2026年5月20日 (水)'));
      await tester.pumpAndSettle();
      expect(find.byType(DatePickerDialog), findsNothing);

      await tester.tap(find.text('10:00'));
      await tester.pumpAndSettle();
      expect(find.byType(TimePickerDialog), findsNothing);

      // メモは編集可能
      final memoFinder = find.widgetWithText(TextField, '既存メモ');
      expect(memoFinder, findsOneWidget);
      await tester.enterText(memoFinder, '更新後のメモ');
      await tester.pump();
      expect(find.text('更新後のメモ'), findsOneWidget);
    });

    testWidgets(
        'manual record edit: all fields editable, no lock icons present',
        (tester) async {
      await tester.pumpWidget(_harness(
        initial: _session(inputMethod: WorkSessionInputMethod.manual),
      ));
      await tester.pumpAndSettle();

      // 編集モード見出しはあるが注意書きはなし
      expect(find.text('記録を編集'), findsOneWidget);
      expect(find.text('タイマー記録のためメモのみ編集できます'), findsNothing);

      // lock_outline はどこにも出ない
      expect(find.byIcon(Icons.lock_outline), findsNothing);

      // 通常の編集アイコンが揃っている
      expect(find.byIcon(Icons.calendar_today), findsOneWidget);
      expect(find.byIcon(Icons.access_time), findsNWidgets(2));
      expect(find.byIcon(Icons.unfold_more), findsOneWidget);

      // メモも編集可能
      final memoFinder = find.widgetWithText(TextField, '既存メモ');
      await tester.enterText(memoFinder, '新メモ');
      await tester.pump();
      expect(find.text('新メモ'), findsOneWidget);
    });

    testWidgets('new mode: all fields editable, no lock icons present',
        (tester) async {
      await tester.pumpWidget(_harness());
      await tester.pumpAndSettle();

      expect(find.text('手動で記録'), findsOneWidget);
      expect(find.text('タイマー記録のためメモのみ編集できます'), findsNothing);

      expect(find.byIcon(Icons.lock_outline), findsNothing);
      expect(find.byIcon(Icons.calendar_today), findsOneWidget);
      expect(find.byIcon(Icons.access_time), findsNWidgets(2));
      expect(find.byIcon(Icons.unfold_more), findsOneWidget);
    });
  });
}
