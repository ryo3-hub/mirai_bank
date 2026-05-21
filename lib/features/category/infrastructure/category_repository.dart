import '../domain/category.dart';

abstract interface class CategoryRepository {
  Stream<List<Category>> watchAll();

  Future<List<Category>> fetchAll();

  Future<Category?> findById(String id);

  Future<Category> create({
    required String name,
    required int hourlyRate,
    required String colorCode,
    required String iconCode,
  });

  Future<void> update(Category category);

  Future<void> softDelete(String id);

  Future<void> ensureDefaultCategory();

  /// `orderedIds` の並び順に従ってアクティブカテゴリの
  /// sortOrder を 0..N に更新する。
  Future<void> reorder(List<String> orderedIds);
}
