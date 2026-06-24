import '../../../../core/enums/category_type.dart';
import '../../domain/repositories/category_repository.dart';
import '../datasources/category_local_datasource.dart';
import '../models/category_model.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  final CategoryLocalDataSource _dataSource;

  CategoryRepositoryImpl(this._dataSource);

  @override
  Future<List<CategoryModel>> getAll() => _dataSource.getAll();

  @override
  Future<List<CategoryModel>> getByType(CategoryType type) => _dataSource.getByType(type);

  @override
  Future<CategoryModel?> getById(int id) => _dataSource.getById(id);

  @override
  Future<int> add(CategoryModel category) => _dataSource.insert(category);

  @override
  Future<void> update(CategoryModel category) => _dataSource.update(category);

  @override
  Future<void> softDelete(int id) => _dataSource.softDelete(id);

  @override
  Future<void> toggleActive(int id, bool isActive) => _dataSource.toggleActive(id, isActive);
}
