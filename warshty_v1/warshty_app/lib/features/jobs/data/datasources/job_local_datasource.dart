import 'package:sqflite/sqflite.dart';

import '../../../../core/database/database_helper.dart';
import '../../../../core/database/database_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/job_model.dart';

class JobLocalDataSource {
  final DatabaseHelper _dbHelper;

  JobLocalDataSource(this._dbHelper);

  Future<Database> get _db => _dbHelper.database;

  Future<List<JobModel>> getAll() async {
    final db = await _db;
    final result = await db.rawQuery('''
      SELECT
        j.*,
        w.name as workshop_name,
        p.name as person_name,
        COALESCE((SELECT SUM(jp.amount) FROM job_payment jp WHERE jp.job_id = j.id), 0) as total_payments
      FROM job j
      LEFT JOIN workshop w ON w.id = j.workshop_id
      LEFT JOIN person p ON p.id = j.person_id
      ORDER BY j.start_date DESC
    ''');
    return result.map((row) => JobModel.fromMap(row)).toList();
  }

  Future<List<JobModel>> getByPerson(int personId) async {
    final db = await _db;
    final result = await db.rawQuery('''
      SELECT
        j.*,
        w.name as workshop_name,
        COALESCE((SELECT SUM(jp.amount) FROM job_payment jp WHERE jp.job_id = j.id), 0) as total_payments
      FROM job j
      LEFT JOIN workshop w ON w.id = j.workshop_id
      WHERE j.person_id = ?
      ORDER BY j.start_date DESC
    ''', [personId]);
    return result.map((row) => JobModel.fromMap(row)).toList();
  }

  Future<JobModel?> getById(int id) async {
    final db = await _db;
    final result = await db.rawQuery('''
      SELECT
        j.*,
        w.name as workshop_name,
        p.name as person_name,
        COALESCE((SELECT SUM(jp.amount) FROM job_payment jp WHERE jp.job_id = j.id), 0) as total_payments
      FROM job j
      LEFT JOIN workshop w ON w.id = j.workshop_id
      LEFT JOIN person p ON p.id = j.person_id
      WHERE j.id = ?
    ''', [id]);
    if (result.isEmpty) return null;
    return JobModel.fromMap(result.first);
  }

  Future<int> insert(JobModel job) async {
    final db = await _db;
    final id = await db.insert(DatabaseConstants.jobTable, job.toMap());
    return id;
  }

  Future<void> update(JobModel job) async {
    final db = await _db;
    final updated = await db.update(
      DatabaseConstants.jobTable,
      job.toMap(),
      where: 'id = ?',
      whereArgs: [job.id],
    );
    if (updated == 0) {
      throw const AppDatabaseException(message: 'لم يتم العثور على الشغلانة');
    }
  }

  Future<void> delete(int id) async {
    final db = await _db;
    await db.delete(
      DatabaseConstants.jobTable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
