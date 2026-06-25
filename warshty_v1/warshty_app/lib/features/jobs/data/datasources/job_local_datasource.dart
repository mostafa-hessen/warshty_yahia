import 'package:sqflite/sqflite.dart';

import '../../../../core/database/database_helper.dart';
import '../../../../core/database/database_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/job_labor_model.dart';
import '../models/job_material_model.dart';
import '../models/job_model.dart';
import '../models/job_other_cost_model.dart';
import '../models/job_payment_model.dart';

class JobLocalDataSource {
  final DatabaseHelper _dbHelper;

  JobLocalDataSource(this._dbHelper);

  Future<Database> get _db => _dbHelper.database;

  // ── Main Job ────────────────────────────────────────────────────

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
        p.name as person_name,
        COALESCE((SELECT SUM(jp.amount) FROM job_payment jp WHERE jp.job_id = j.id), 0) as total_payments
      FROM job j
      LEFT JOIN workshop w ON w.id = j.workshop_id
      LEFT JOIN person p ON p.id = j.person_id
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
    return await db.insert(DatabaseConstants.jobTable, job.toMap());
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

    // 1. حذف sub-entities اللي معندهاش FK للـ treasury_transaction
    await db.delete(DatabaseConstants.jobMaterialTable, where: 'job_id = ?', whereArgs: [id]);
    await db.delete(DatabaseConstants.jobLaborTable, where: 'job_id = ?', whereArgs: [id]);
    await db.delete(DatabaseConstants.jobOtherCostTable, where: 'job_id = ?', whereArgs: [id]);

    // 2. حذف الـ payments عشان تفك FK الـ ttx
    await db.delete(DatabaseConstants.jobPaymentTable, where: 'job_id = ?', whereArgs: [id]);

    // 3. حذف treasury_transactions المرتبطة (بقى الـ FK مفكوك)
    await db.delete(
      DatabaseConstants.treasuryTransactionTable,
      where: 'job_id = ?',
      whereArgs: [id],
    );

    // 4. حذف الـ Job نفسه
    await db.delete(DatabaseConstants.jobTable, where: 'id = ?', whereArgs: [id]);
  }

  // ── Materials ────────────────────────────────────────────────────

  Future<List<JobMaterialModel>> getMaterials(int jobId) async {
    final db = await _db;
    final result = await db.rawQuery('''
      SELECT * FROM job_material WHERE job_id = ? ORDER BY partial_id ASC
    ''', [jobId]);
    return result.map((row) => JobMaterialModel.fromMap(row)).toList();
  }

  Future<void> insertMaterial(JobMaterialModel item) async {
    final db = await _db;
    final partialId = await _dbHelper.nextPartialId(
      db, DatabaseConstants.jobMaterialTable, 'job_id', item.jobId,
    );
    await db.insert(DatabaseConstants.jobMaterialTable, {
      'job_id': item.jobId,
      'partial_id': partialId,
      'name': item.name,
      'amount': item.amount,
      'description': item.description,
      'date': item.date,
    });
  }

  Future<void> updateMaterial(JobMaterialModel item) async {
    final db = await _db;
    await db.update(
      DatabaseConstants.jobMaterialTable,
      {'name': item.name, 'amount': item.amount, 'description': item.description, 'date': item.date},
      where: 'job_id = ? AND partial_id = ?',
      whereArgs: [item.jobId, item.partialId],
    );
  }

  Future<void> deleteMaterial(int jobId, int partialId) async {
    final db = await _db;
    await db.delete(
      DatabaseConstants.jobMaterialTable,
      where: 'job_id = ? AND partial_id = ?',
      whereArgs: [jobId, partialId],
    );
  }

  // ── Labors ───────────────────────────────────────────────────────

  Future<List<JobLaborModel>> getLabors(int jobId) async {
    final db = await _db;
    final result = await db.rawQuery('''
      SELECT
        jl.*,
        c.name as category_name
      FROM job_labor jl
      LEFT JOIN category c ON c.id = jl.category_id
      WHERE jl.job_id = ?
      ORDER BY jl.partial_id ASC
    ''', [jobId]);
    return result.map((row) => JobLaborModel.fromMap(row)).toList();
  }

  Future<void> insertLabor(JobLaborModel item) async {
    final db = await _db;
    final partialId = await _dbHelper.nextPartialId(
      db, DatabaseConstants.jobLaborTable, 'job_id', item.jobId,
    );
    await db.insert(DatabaseConstants.jobLaborTable, {
      'job_id': item.jobId,
      'partial_id': partialId,
      'amount': item.amount,
      'description': item.description,
      'date': item.date,
      'category_id': item.categoryId,
    });
  }

  Future<void> updateLabor(JobLaborModel item) async {
    final db = await _db;
    await db.update(
      DatabaseConstants.jobLaborTable,
      {'amount': item.amount, 'description': item.description, 'date': item.date, 'category_id': item.categoryId},
      where: 'job_id = ? AND partial_id = ?',
      whereArgs: [item.jobId, item.partialId],
    );
  }

  Future<void> deleteLabor(int jobId, int partialId) async {
    final db = await _db;
    await db.delete(
      DatabaseConstants.jobLaborTable,
      where: 'job_id = ? AND partial_id = ?',
      whereArgs: [jobId, partialId],
    );
  }

  // ── Other Costs ──────────────────────────────────────────────────

  Future<List<JobOtherCostModel>> getOtherCosts(int jobId) async {
    final db = await _db;
    final result = await db.rawQuery('''
      SELECT
        joc.*,
        c.name as category_name
      FROM job_other_cost joc
      LEFT JOIN category c ON c.id = joc.category_id
      WHERE joc.job_id = ?
      ORDER BY joc.partial_id ASC
    ''', [jobId]);
    return result.map((row) => JobOtherCostModel.fromMap(row)).toList();
  }

  Future<void> insertOtherCost(JobOtherCostModel item) async {
    final db = await _db;
    final partialId = await _dbHelper.nextPartialId(
      db, DatabaseConstants.jobOtherCostTable, 'job_id', item.jobId,
    );
    await db.insert(DatabaseConstants.jobOtherCostTable, {
      'job_id': item.jobId,
      'partial_id': partialId,
      'amount': item.amount,
      'description': item.description,
      'date': item.date,
      'category_id': item.categoryId,
    });
  }

  Future<void> updateOtherCost(JobOtherCostModel item) async {
    final db = await _db;
    await db.update(
      DatabaseConstants.jobOtherCostTable,
      {'amount': item.amount, 'description': item.description, 'date': item.date, 'category_id': item.categoryId},
      where: 'job_id = ? AND partial_id = ?',
      whereArgs: [item.jobId, item.partialId],
    );
  }

  Future<void> deleteOtherCost(int jobId, int partialId) async {
    final db = await _db;
    await db.delete(
      DatabaseConstants.jobOtherCostTable,
      where: 'job_id = ? AND partial_id = ?',
      whereArgs: [jobId, partialId],
    );
  }

  // ── Payments ─────────────────────────────────────────────────────

  Future<List<JobPaymentModel>> getPayments(int jobId) async {
    final db = await _db;
    final result = await db.rawQuery('''
      SELECT * FROM job_payment WHERE job_id = ? ORDER BY partial_id ASC
    ''', [jobId]);
    return result.map((row) => JobPaymentModel.fromMap(row)).toList();
  }

  Future<int> insertPayment(JobPaymentModel item) async {
    final db = await _db;
    final partialId = await _dbHelper.nextPartialId(
      db, DatabaseConstants.jobPaymentTable, 'job_id', item.jobId,
    );
    final map = {
      'job_id': item.jobId,
      'partial_id': partialId,
      'amount': item.amount,
      'description': item.description,
      'date': item.date,
    };
    if (item.ttxTreasuryId != null) map['ttx_treasury_id'] = item.ttxTreasuryId;
    if (item.ttxPartialId != null) map['ttx_partial_id'] = item.ttxPartialId;
    await db.insert(DatabaseConstants.jobPaymentTable, map);
    return partialId;
  }

  Future<void> updatePayment(JobPaymentModel item) async {
    final db = await _db;
    final map = <String, dynamic>{
      'amount': item.amount,
      'description': item.description,
      'date': item.date,
    };
    if (item.ttxTreasuryId != null) map['ttx_treasury_id'] = item.ttxTreasuryId;
    if (item.ttxPartialId != null) map['ttx_partial_id'] = item.ttxPartialId;
    await db.update(
      DatabaseConstants.jobPaymentTable,
      map,
      where: 'job_id = ? AND partial_id = ?',
      whereArgs: [item.jobId, item.partialId],
    );
  }

  Future<void> deletePayment(int jobId, int partialId) async {
    final db = await _db;
    await db.delete(
      DatabaseConstants.jobPaymentTable,
      where: 'job_id = ? AND partial_id = ?',
      whereArgs: [jobId, partialId],
    );
  }
}
