import '../entities/category.dart';

abstract class CategoryRepository {
  Future<List<Category>> getCategories({String? type});
  Future<void> addCategory(Category category);
  Future<void> updateCategory(Category category);
  Future<void> deleteCategory(String id);
  String getCategoryName(String id);
}
