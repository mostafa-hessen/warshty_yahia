import 'package:sqflite/sqflite.dart';
import '../../domain/entities/job.dart';
import '../../domain/entities/job_material.dart';
import '../../domain/entities/labor.dart';
import '../../domain/entities/payment.dart';
import '../../domain/repositories/job_repository.dart';
import '../database/app_database.dart';
import '../models/job_model.dart';
import '../models/job_material_model.dart';
import '../models/labor_model.dart';
import '../models/payment_model.dart';

class JobRepositorySQLite implements JobRepository {
  Future<Database> get db => AppDatabase.database;

  @override
  Future<List<Job>> getJobs({String? status, String? workshop, String? search}) async {
    final database = await db;
    final conditions = <String>[];
    final params = <dynamic>[];

    if (status != null && status != 'all') {
      conditions.add('status = ?');
      params.add(status);
    }
    if (workshop != null && workshop != 'all') {
      conditions.add('workshop_id = ?');
      params.add(workshop);
    }
    if (search != null && search.isNotEmpty) {
      conditions.add('(name LIKE ? OR client_name LIKE ? OR client_phone LIKE ?)');
      final s = '%$search%';
      params.addAll([s, s, s]);
    }

    final where = conditions.isNotEmpty ? 'WHERE ${conditions.join(' AND ')}' : '';
    final rows = await database.rawQuery('SELECT * FROM jobs $where ORDER BY id DESC', params);
    return rows.map((r) => JobModel.fromMap(r)).toList();
  }

  @override
  Future<Job?> getJob(int id) async {
    final database = await db;
    final rows = await database.query('jobs', where: 'id = ?', whereArgs: [id]);
    if (rows.isEmpty) return null;
    return JobModel.fromMap(rows.first);
  }

  @override
  Future<int> insertJob(Job job) async {
    final database = await db;
    final model = job is JobModel ? job : JobModel(
      name: job.name,
      workshopId: job.workshopId,
      productType: job.productType,
      status: job.status,
      clientName: job.clientName,
      clientPhone: job.clientPhone,
      agreedAmount: job.agreedAmount,
      createdAt: job.createdAt,
      updatedAt: job.updatedAt,
      notes: job.notes,
    );
    return await database.insert('jobs', model.toMap());
  }

  @override
  Future<void> updateJob(Job job) async {
    final database = await db;
    final model = job is JobModel ? job : JobModel(
      id: job.id,
      name: job.name,
      workshopId: job.workshopId,
      productType: job.productType,
      status: job.status,
      clientName: job.clientName,
      clientPhone: job.clientPhone,
      agreedAmount: job.agreedAmount,
      createdAt: job.createdAt,
      updatedAt: job.updatedAt ?? DateTime.now().toIso8601String(),
      notes: job.notes,
    );
    await database.update('jobs', model.toMap(), where: 'id = ?', whereArgs: [job.id]);
  }

  @override
  Future<void> deleteJob(int id) async {
    final database = await db;
    await database.delete('jobs', where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<void> archiveJob(int id) async {
    final database = await db;
    await database.update('jobs', {'status': 'archived'}, where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<void> restoreJob(int id) async {
    final database = await db;
    await database.update('jobs', {'status': 'active'}, where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<List<Job>> getArchivedJobs({String? search}) async {
    return getJobs(status: 'archived', search: search);
  }

  @override
  Future<List<JobMaterial>> getJobMaterials(int jobId) async {
    final database = await db;
    final rows = await database.query('job_materials', where: 'job_id = ?', whereArgs: [jobId]);
    return rows.map((r) => JobMaterialModel.fromMap(r)).toList();
  }

  @override
  Future<void> addJobMaterial(JobMaterial material) async {
    final database = await db;
    final model = material is JobMaterialModel ? material : JobMaterialModel(
      jobId: material.jobId,
      description: material.description,
      costPerUnit: material.costPerUnit,
      quantity: material.quantity,
      warehouseItemId: material.warehouseItemId,
    );
    await database.insert('job_materials', model.toMap());
  }

  @override
  Future<void> deleteJobMaterial(int materialId) async {
    final database = await db;
    await database.delete('job_materials', where: 'id = ?', whereArgs: [materialId]);
  }

  @override
  Future<List<Labor>> getJobLabors(int jobId) async {
    final database = await db;
    final rows = await database.query('job_labors', where: 'job_id = ?', whereArgs: [jobId]);
    return rows.map((r) => LaborModel.fromMap(r)).toList();
  }

  @override
  Future<void> addJobLabor(Labor labor) async {
    final database = await db;
    final model = labor is LaborModel ? labor : LaborModel(
      jobId: labor.jobId,
      description: labor.description,
      amount: labor.amount,
      categoryId: labor.categoryId,
    );
    await database.insert('job_labors', model.toMap());
  }

  @override
  Future<void> deleteJobLabor(int laborId) async {
    final database = await db;
    await database.delete('job_labors', where: 'id = ?', whereArgs: [laborId]);
  }

  @override
  Future<List<Map<String, dynamic>>> getJobOtherExpenses(int jobId) async {
    final database = await db;
    return await database.query('job_other_expenses', where: 'job_id = ?', whereArgs: [jobId]);
  }

  @override
  Future<void> addJobOtherExpense(int jobId, String description, double amount) async {
    final database = await db;
    await database.insert('job_other_expenses', {
      'job_id': jobId,
      'description': description,
      'amount': amount,
    });
  }

  @override
  Future<void> deleteJobOtherExpense(int expenseId) async {
    final database = await db;
    await database.delete('job_other_expenses', where: 'id = ?', whereArgs: [expenseId]);
  }

  @override
  Future<List<Payment>> getJobPayments(int jobId) async {
    final database = await db;
    final rows = await database.query('job_payments', where: 'job_id = ?', whereArgs: [jobId]);
    return rows.map((r) => PaymentModel.fromMap(r)).toList();
  }

  @override
  Future<void> addJobPayment(Payment payment) async {
    final database = await db;
    final model = payment is PaymentModel ? payment : PaymentModel(
      jobId: payment.jobId,
      amount: payment.amount,
      date: payment.date,
    );
    await database.insert('job_payments', model.toMap());
  }

  @override
  Future<void> deleteJobPayment(int paymentId) async {
    final database = await db;
    await database.delete('job_payments', where: 'id = ?', whereArgs: [paymentId]);
  }

  @override
  Future<double> getJobTotalCost(int jobId) async {
    final database = await db;
    final mats = await database.rawQuery(
      'SELECT COALESCE(SUM(cost_per_unit * quantity), 0) as total FROM job_materials WHERE job_id = ?',
      [jobId],
    );
    final lab = await database.rawQuery(
      'SELECT COALESCE(SUM(amount), 0) as total FROM job_labors WHERE job_id = ?',
      [jobId],
    );
    final exp = await database.rawQuery(
      'SELECT COALESCE(SUM(amount), 0) as total FROM job_other_expenses WHERE job_id = ?',
      [jobId],
    );
    return (mats.first['total'] as num).toDouble() +
        (lab.first['total'] as num).toDouble() +
        (exp.first['total'] as num).toDouble();
  }

  @override
  Future<double> getTotalPaid(int jobId) async {
    final database = await db;
    final result = await database.rawQuery(
      'SELECT COALESCE(SUM(amount), 0) as total FROM job_payments WHERE job_id = ?',
      [jobId],
    );
    return (result.first['total'] as num).toDouble();
  }
}
