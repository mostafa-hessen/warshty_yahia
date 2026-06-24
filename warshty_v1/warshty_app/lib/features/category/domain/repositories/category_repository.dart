import '../../../../core/enums/category_type.dart';
import '../../data/models/category_model.dart';

abstract class CategoryRepository {
  Future<List<CategoryModel>> getAll();
  Future<List<CategoryModel>> getByType(CategoryType type);
  Future<CategoryModel?> getById(int id);
  Future<int> add(CategoryModel category);
  Future<void> update(CategoryModel category);
  Future<void> softDelete(int id);
  Future<void> toggleActive(int id, bool isActive);
}
