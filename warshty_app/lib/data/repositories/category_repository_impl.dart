import 'package:sqflite/sqflite.dart';
import '../../domain/entities/category.dart';
import '../../domain/repositories/category_repository.dart';
import '../database/app_database.dart';

class CategoryRepositorySQLite implements CategoryRepository {
  Future<Database> get db => AppDatabase.database;

  @override
  Future<List<Category>> getCategories({String? type}) async {
    final database = await db;
    if (type != null) {
      final rows = await database.query('categories', where: 'type = ?', whereArgs: [type]);
      return rows.map((r) => _fromMap(r)).toList();
    }
    final rows = await database.query('categories', orderBy: 'name ASC');
    return rows.map((r) => _fromMap(r)).toList();
  }

  @override
  Future<void> addCategory(Category category) async {
    final database = await db;
    await database.insert('categories', {
      'id': category.id,
      'name': category.name,
      'type': category.type,
    });
  }

  @override
  Future<void> updateCategory(Category category) async {
    final database = await db;
    await database.update(
      'categories',
      {'name': category.name, 'type': category.type},
      where: 'id = ?',
      whereArgs: [category.id],
    );
  }

  @override
  Future<void> deleteCategory(String id) async {
    final database = await db;
    await database.delete('categories', where: 'id = ?', whereArgs: [id]);
  }

  @override
  String getCategoryName(String id) {
    for (final cat in _defaultNames.entries) {
      if (cat.key == id) return cat.value;
    }
    return id;
  }

  static const _defaultNames = <String, String>{
    'cat_elec': 'كهرباء',
    'cat_water': 'مياه',
    'cat_rent': 'إيجار',
    'cat_salary': 'رواتب',
    'cat_labor': 'مصنعيات',
    'cat_transport': 'نقل',
    'cat_maint': 'صيانة',
    'cat_materials': 'خامات',
    'cat_admin': 'مصروف إداري',
    'cat_misc_exp': 'مصروف متنوع',
    'cat_deposit': 'عربون عميل',
    'cat_payment': 'دفعة من عميل',
    'cat_sale': 'إيراد بيع',
    'cat_misc_inc': 'إيراد متنوع',
    'cat_carpenter': 'أجرة نجار',
    'cat_painter': 'أجرة دهان',
    'cat_install': 'أجرة تركيب',
    'cat_worker': 'أجرة عامل',
  };

  Category _fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'] as String,
      name: map['name'] as String,
      type: map['type'] as String,
    );
  }
}
