import 'package:sqflite/sqflite.dart';

import '../../../../core/database/database_helper.dart';
import '../../../../core/database/database_constants.dart';
import '../../../../core/enums/category_type.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/category_model.dart';

class CategoryLocalDataSource {
  final DatabaseHelper _dbHelper;

  CategoryLocalDataSource(this._dbHelper);

  Future<Database> get _db => _dbHelper.database;

  Future<List<CategoryModel>> getAll() async {
    final db = await _db;
    final result = await db.query(
      DatabaseConstants.categoryTable,
      where: 'is_active = 1',
      orderBy: 'name',
    );
    return result.map((row) => CategoryModel.fromMap(row)).toList();
  }

  Future<List<CategoryModel>> getByType(CategoryType type) async {
    final db = await _db;
    final result = await db.query(
      DatabaseConstants.categoryTable,
      where: 'is_active = 1 AND type = ?',
      whereArgs: [type.dbValue],
      orderBy: 'name',
    );
    return result.map((row) => CategoryModel.fromMap(row)).toList();
  }

  Future<CategoryModel?> getById(int id) async {
    final db = await _db;
    final result = await db.query(
      DatabaseConstants.categoryTable,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (result.isEmpty) return null;
    return CategoryModel.fromMap(result.first);
  }

  Future<int> insert(CategoryModel category) async {
    final db = await _db;
    final id = await db.insert(DatabaseConstants.categoryTable, category.toMap());
    return id;
  }

  Future<void> update(CategoryModel category) async {
    if (category.id == null) {
      throw const AppDatabaseException(message: 'لا يمكن تعديل تصنيف بدون id');
    }
    final db = await _db;
    await db.update(
      DatabaseConstants.categoryTable,
      category.toMap(),
      where: 'id = ?',
      whereArgs: [category.id],
    );
  }

  Future<void> softDelete(int id) async {
    final db = await _db;
    await db.update(
      DatabaseConstants.categoryTable,
      {'is_active': 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> toggleActive(int id, bool isActive) async {
    final db = await _db;
    await db.update(
      DatabaseConstants.categoryTable,
      {'is_active': isActive ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
