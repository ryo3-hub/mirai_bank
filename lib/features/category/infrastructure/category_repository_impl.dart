import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../../infrastructure/database/app_database.dart';
import '../domain/category.dart';
import '../domain/category_presets.dart';
import 'category_repository.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  CategoryRepositoryImpl(this._db, {Uuid? uuid}) : _uuid = uuid ?? const Uuid();

  final AppDatabase _db;
  final Uuid _uuid;

  $CategoriesTable get _table => _db.categories;

  SimpleSelectStatement<$CategoriesTable, CategoryRow> _activeQuery() {
    return _db.select(_table)
      ..where((c) => c.deletedAt.isNull())
      ..orderBy([
        (c) => OrderingTerm.asc(c.sortOrder),
        (c) => OrderingTerm.asc(c.createdAt),
      ]);
  }

  @override
  Stream<List<Category>> watchAll() {
    return _activeQuery().watch().map(
          (rows) => rows.map(_toEntity).toList(growable: false),
        );
  }

  @override
  Future<List<Category>> fetchAll() async {
    final rows = await _activeQuery().get();
    return rows.map(_toEntity).toList(growable: false);
  }

  @override
  Future<Category?> findById(String id) async {
    final row = await (_db.select(_table)..where((c) => c.id.equals(id)))
        .getSingleOrNull();
    if (row == null) return null;
    return _toEntity(row);
  }

  @override
  Future<Category> create({
    required String name,
    required int hourlyRate,
    required String colorCode,
    required String iconCode,
  }) async {
    final now = DateTime.now();
    final id = _uuid.v4();
    // 新規カテゴリはアクティブカテゴリの末尾に追加する（最大 sortOrder + 1）。
    final nextSortOrder = await _computeNextSortOrder();
    await _db.into(_table).insert(
          CategoriesCompanion(
            id: Value(id),
            name: Value(name.trim()),
            hourlyRate: Value(hourlyRate),
            colorCode: Value(colorCode),
            iconCode: Value(iconCode),
            sortOrder: Value(nextSortOrder),
            createdAt: Value(now),
            updatedAt: Value(now),
          ),
        );
    return Category(
      id: id,
      name: name.trim(),
      hourlyRate: hourlyRate,
      colorCode: colorCode,
      iconCode: iconCode,
      sortOrder: nextSortOrder,
      createdAt: now,
      updatedAt: now,
    );
  }

  Future<int> _computeNextSortOrder() async {
    final maxExp = _table.sortOrder.max();
    final query = _db.selectOnly(_table)
      ..where(_table.deletedAt.isNull())
      ..addColumns([maxExp]);
    final row = await query.getSingleOrNull();
    final current = row?.read(maxExp);
    return (current ?? -1) + 1;
  }

  @override
  Future<void> update(Category category) async {
    final now = DateTime.now();
    await (_db.update(_table)..where((c) => c.id.equals(category.id))).write(
      CategoriesCompanion(
        name: Value(category.name.trim()),
        hourlyRate: Value(category.hourlyRate),
        colorCode: Value(category.colorCode),
        iconCode: Value(category.iconCode),
        updatedAt: Value(now),
      ),
    );
  }

  @override
  Future<void> softDelete(String id) async {
    final now = DateTime.now();
    await (_db.update(_table)..where((c) => c.id.equals(id))).write(
      CategoriesCompanion(
        deletedAt: Value(now),
        updatedAt: Value(now),
      ),
    );
  }

  @override
  Future<void> ensureDefaultCategory() async {
    final existing = await fetchAll();
    if (existing.isNotEmpty) return;
    await create(
      name: '勉強',
      hourlyRate: 2000,
      colorCode: CategoryPresets.defaultColor,
      iconCode: CategoryPresets.defaultIcon,
    );
  }

  @override
  Future<void> reorder(List<String> orderedIds) async {
    final now = DateTime.now();
    await _db.transaction(() async {
      for (var i = 0; i < orderedIds.length; i++) {
        await (_db.update(_table)..where((c) => c.id.equals(orderedIds[i])))
            .write(CategoriesCompanion(
          sortOrder: Value(i),
          updatedAt: Value(now),
        ));
      }
    });
  }

  Category _toEntity(CategoryRow row) {
    return Category(
      id: row.id,
      name: row.name,
      hourlyRate: row.hourlyRate,
      colorCode: row.colorCode,
      iconCode: row.iconCode,
      sortOrder: row.sortOrder,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
      deletedAt: row.deletedAt,
    );
  }
}
