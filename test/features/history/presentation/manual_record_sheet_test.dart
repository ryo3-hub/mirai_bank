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

WorkSession _session() => WorkSession(
      id: 'sess-1',
      categoryId: 'cat-1',
      startTime: DateTime(2026, 5, 20, 10, 0),
      endTime: DateTime(2026, 5, 20, 11, 30),
      durationSec: 5400,
      amount: 4500,
      memo: '既存メモ',
      inputMethod: WorkSessionInputMethod.manual,
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

  group('ManualRecordSheet — 編集モードはメモのみ編集可', () {
    testWidgets('edit mode: subtitle + lock icons appear, time/date untappable',
        (tester) async {
      await tester.pumpWidget(_harness(initial: _session()));
      await tester.pumpAndSettle();

      // 編集モード見出し + 注意書き
      expect(find.text('記録を編集'), findsOneWidget);
      expect(find.text('編集できるのはメモのみです'), findsOneWidget);

      // lock_outline は subtitle + category + date + start + end = 5 箇所
      expect(find.byIcon(Icons.lock_outline), findsNWidgets(5));

      // 編集対象アイコン（カレンダー・時計・unfold）は表示されない
      expect(find.byIcon(Icons.calendar_today), findsNothing);
      expect(find.byIcon(Icons.access_time), findsNothing);
      expect(find.byIcon(Icons.unfold_more), findsNothing);

      // 日付・開始時刻・終了時刻のタップでピッカーが開かないこと
      await tester.tap(find.text('2026年5月20日 (水)'));
      await tester.pumpAndSettle();
      expect(find.byType(DatePickerDialog), findsNothing);

      await tester.tap(find.text('10:00'));
      await tester.pumpAndSettle();
      expect(find.byType(TimePickerDialog), findsNothing);
    });

    testWidgets('edit mode: memo field remains editable', (tester) async {
      await tester.pumpWidget(_harness(initial: _session()));
      await tester.pumpAndSettle();

      // 初期メモが表示されている
      expect(find.text('既存メモ'), findsOneWidget);

      // メモ TextField は通常通り入力可能
      final memoFinder = find.widgetWithText(TextField, '既存メモ');
      expect(memoFinder, findsOneWidget);
      await tester.enterText(memoFinder, '更新後のメモ');
      await tester.pump();
      expect(find.text('更新後のメモ'), findsOneWidget);
    });

    testWidgets('new mode: all fields editable, no lock icons present',
        (tester) async {
      await tester.pumpWidget(_harness());
      await tester.pumpAndSettle();

      expect(find.text('手動で記録'), findsOneWidget);
      expect(find.text('編集できるのはメモのみです'), findsNothing);

      // lock_outline はどこにも出ない
      expect(find.byIcon(Icons.lock_outline), findsNothing);

      // 通常の編集アイコンが揃っている
      expect(find.byIcon(Icons.calendar_today), findsOneWidget);
      expect(find.byIcon(Icons.access_time), findsNWidgets(2));
      expect(find.byIcon(Icons.unfold_more), findsOneWidget);
    });
  });
}
