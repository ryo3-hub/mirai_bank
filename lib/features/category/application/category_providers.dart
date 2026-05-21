import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../infrastructure/database/database_provider.dart';
import '../domain/category.dart';
import '../infrastructure/category_repository.dart';
import '../infrastructure/category_repository_impl.dart';

part 'category_providers.g.dart';

@Riverpod(keepAlive: true)
CategoryRepository categoryRepository(Ref ref) {
  return CategoryRepositoryImpl(ref.watch(appDatabaseProvider));
}

@riverpod
Stream<List<Category>> categoriesList(Ref ref) {
  return ref.watch(categoryRepositoryProvider).watchAll();
}

@riverpod
Future<Category?> categoryById(Ref ref, String id) {
  return ref.watch(categoryRepositoryProvider).findById(id);
}

@riverpod
class CategoryController extends _$CategoryController {
  @override
  void build() {}

  Future<void> create({
    required String name,
    required int hourlyRate,
    required String colorCode,
    required String iconCode,
  }) {
    return ref.read(categoryRepositoryProvider).create(
          name: name,
          hourlyRate: hourlyRate,
          colorCode: colorCode,
          iconCode: iconCode,
        );
  }

  Future<void> updateCategory(Category category) {
    return ref.read(categoryRepositoryProvider).update(category);
  }

  Future<void> delete(String id) {
    return ref.read(categoryRepositoryProvider).softDelete(id);
  }

  Future<void> reorder(List<String> orderedIds) {
    return ref.read(categoryRepositoryProvider).reorder(orderedIds);
  }
}
