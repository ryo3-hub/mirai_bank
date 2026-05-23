import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'tables.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    Categories,
    WorkSessions,
    ActiveTimers,
    Goals,
    Settings,
    TimerPresets,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 6;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
          // 初回起動時にデフォルトのタイマープリセット 3 件をシード。
          await _seedDefaultTimerPresets();
        },
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            // v2: Goals に sortOrder カラムを追加。既存目標は createdAt 昇順で
            // sortOrder を 0,1,2,... と初期化する。
            await m.addColumn(goals, goals.sortOrder);
            final rows = await (select(goals)
                  ..orderBy([(g) => OrderingTerm.asc(g.createdAt)]))
                .get();
            for (var i = 0; i < rows.length; i++) {
              await (update(goals)..where((g) => g.id.equals(rows[i].id)))
                  .write(GoalsCompanion(sortOrder: Value(i)));
            }
          }
          if (from < 3) {
            // v3: Settings に reminderWeekdaysCsv カラムを追加。
            // 既存ユーザーはデフォルト「毎日」("1,2,3,4,5,6,7") で初期化される。
            await m.addColumn(settings, settings.reminderWeekdaysCsv);
          }
          if (from < 4) {
            // v4: Categories に sortOrder カラムを追加。既存カテゴリは
            // createdAt 昇順で sortOrder を 0,1,2,... と初期化する。
            await m.addColumn(categories, categories.sortOrder);
            final rows = await (select(categories)
                  ..orderBy([(c) => OrderingTerm.asc(c.createdAt)]))
                .get();
            for (var i = 0; i < rows.length; i++) {
              await (update(categories)
                    ..where((c) => c.id.equals(rows[i].id)))
                  .write(CategoriesCompanion(sortOrder: Value(i)));
            }
          }
          if (from < 5) {
            // v5: ActiveTimers に target/accumulated/resumedAt 追加 +
            // TimerPresets テーブル新設 + デフォルトプリセットをシード。
            await m.addColumn(
              activeTimers,
              activeTimers.targetDurationSec,
            );
            await m.addColumn(activeTimers, activeTimers.accumulatedSec);
            await m.addColumn(activeTimers, activeTimers.resumedAt);
            await m.createTable(timerPresets);
            await _seedDefaultTimerPresets();
          }
          if (from < 6) {
            // v6: Categories に masterKey カラムを追加（issue #97）。
            // 既存カテゴリは null のまま（プリセット由来ではない自由入力扱い）。
            await m.addColumn(categories, categories.masterKey);
          }
        },
      );

  /// デフォルトのタイマープリセットを 3 件シードする。
  /// 既にレコードがある場合は何もしない（onCreate / onUpgrade 双方から呼ぶため）。
  Future<void> _seedDefaultTimerPresets() async {
    final existing = await select(timerPresets).get();
    if (existing.isNotEmpty) return;
    final now = DateTime.now();
    const defaults = [
      (id: 'default-15', minutes: 15, label: 'さくっと集中', sortOrder: 0),
      (id: 'default-30', minutes: 30, label: '集中する', sortOrder: 1),
      (id: 'default-60', minutes: 60, label: 'じっくり腰を据えて', sortOrder: 2),
    ];
    for (final d in defaults) {
      await into(timerPresets).insert(
        TimerPresetsCompanion(
          id: Value(d.id),
          minutes: Value(d.minutes),
          label: Value(d.label),
          sortOrder: Value(d.sortOrder),
          isDefault: const Value(true),
          createdAt: Value(now),
          updatedAt: Value(now),
        ),
      );
    }
  }

  static QueryExecutor _openConnection() {
    return LazyDatabase(() async {
      final dir = await getApplicationDocumentsDirectory();
      final file = File(p.join(dir.path, 'mirai_bank.sqlite'));
      return NativeDatabase.createInBackground(file);
    });
  }
}
