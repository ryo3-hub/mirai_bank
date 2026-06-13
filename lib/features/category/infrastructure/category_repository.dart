import '../domain/category.dart';

abstract interface class CategoryRepository {
  Stream<List<Category>> watchAll();

  Future<List<Category>> fetchAll();

  /// ソフトデリート済みも含む全カテゴリ。統計集計で削除済みカテゴリの
  /// セッションを内訳に含めるために使う（issue #190）。
  Future<List<Category>> fetchAllIncludingDeleted();

  Future<Category?> findById(String id);

  Future<Category> create({
    required String name,
    required int hourlyRate,
    required String colorCode,
    required String iconCode,
    String? masterKey,
  });

  Future<void> update(Category category);

  Future<void> softDelete(String id);

  Future<void> ensureDefaultCategory();

  /// `orderedIds` の並び順に従ってアクティブカテゴリの
  /// sortOrder を 0..N に更新する。
  Future<void> reorder(List<String> orderedIds);
}
