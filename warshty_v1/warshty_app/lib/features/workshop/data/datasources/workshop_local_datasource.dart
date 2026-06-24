import 'package:sqflite/sqflite.dart';

import '../../../../core/database/database_helper.dart';
import '../../../../core/database/database_constants.dart';
import '../models/workshop_model.dart';

class WorkshopLocalDataSource {
  final DatabaseHelper _dbHelper;

  WorkshopLocalDataSource(this._dbHelper);

  Future<Database> get _db => _dbHelper.database;

  Future<List<WorkshopModel>> getAll() async {
    final db = await _db;
    final result = await db.query(
      DatabaseConstants.workshopTable,
      where: 'is_active = 1',
      orderBy: 'name',
    );
    return result.map((row) => WorkshopModel.fromMap(row)).toList();
  }
}
