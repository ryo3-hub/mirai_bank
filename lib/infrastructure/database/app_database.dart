import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'tables.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [Categories, WorkSessions, ActiveTimers, Goals, Settings],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) => m.createAll(),
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
        },
      );

  static QueryExecutor _openConnection() {
    return LazyDatabase(() async {
      final dir = await getApplicationDocumentsDirectory();
      final file = File(p.join(dir.path, 'mirai_bank.sqlite'));
      return NativeDatabase.createInBackground(file);
    });
  }
}
