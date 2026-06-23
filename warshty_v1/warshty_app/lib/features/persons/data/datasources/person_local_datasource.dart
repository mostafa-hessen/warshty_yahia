import 'package:sqflite/sqflite.dart';

import '../../../../core/database/database_helper.dart';
import '../../../../core/database/database_constants.dart';
import '../../../../core/enums/transaction_type.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../jobs/data/models/job_model.dart';
import '../models/person_model.dart';
import '../models/person_transaction_model.dart';

/// PersonLocalDataSource — الطبقة الوحيدة اللي بتعمل SQL queries مباشرة
///
/// الـ Cubit و Repository مش بيلمسوا SQL خالص — بيستخدموا الـ DataSource ده
class PersonLocalDataSource {
  final DatabaseHelper _dbHelper;

  PersonLocalDataSource(this._dbHelper);

  Future<Database> get _db => _dbHelper.database;

  // ── Get All ──────────────────────────────────────────────
  /// جيب كل الأشخاص النشطين مع computed balance وعدد الشغلانات
  Future<List<PersonModel>> getAll() async {
    final db = await _db;
    final result = await db.rawQuery('''
      SELECT
        p.*,
        COALESCE((
          SELECT SUM(
            CASE
              WHEN pt.type = 'أخذت' THEN pt.amount
              WHEN pt.type = 'عطيت' THEN -pt.amount
              ELSE 0
            END
          )
          FROM person_transaction pt
          WHERE pt.person_id = p.id
        ), 0) as balance,
        (SELECT COUNT(*) FROM job j WHERE j.person_id = p.id) as jobs_count
      FROM person p
      WHERE p.is_active = 1
      ORDER BY p.name
    ''');
    return result.map((row) => PersonModel.fromMap(row)).toList();
  }

  // ── Get By Id ────────────────────────────────────────────
  /// جيب شخص واحد فقط
  Future<PersonModel?> getById(int id) async {
    final db = await _db;
    final result = await db.rawQuery('''
      SELECT
        p.*,
        COALESCE((
          SELECT SUM(
            CASE
              WHEN pt.type = 'أخذت' THEN pt.amount
              WHEN pt.type = 'عطيت' THEN -pt.amount
              ELSE 0
            END
          )
          FROM person_transaction pt
          WHERE pt.person_id = p.id
        ), 0) as balance,
        (SELECT COUNT(*) FROM job j WHERE j.person_id = p.id) as jobs_count
      FROM person p
      WHERE p.id = ? AND p.is_active = 1
    ''', [id]);
    if (result.isEmpty) return null;
    return PersonModel.fromMap(result.first);
  }

  // ── Insert ───────────────────────────────────────────────
  /// إضافة شخص جديد
  Future<int> insert(PersonModel person) async {
    final db = await _db;
    final id = await db.insert(DatabaseConstants.personTable, person.toMap());
    return id;
  }

  // ── Update ───────────────────────────────────────────────
  /// تعديل بيانات شخص
  Future<void> update(PersonModel person) async {
    if (person.id == null) {
      throw const AppDatabaseException(message: 'لا يمكن تعديل شخص بدون id');
    }
    final db = await _db;
    await db.update(
      DatabaseConstants.personTable,
      person.toMap(),
      where: 'id = ?',
      whereArgs: [person.id],
    );
  }

  // ── Soft Delete ──────────────────────────────────────────
  /// إخفاء الشخص (is_active = 0) مش حذف فعلي
  Future<void> softDelete(int id) async {
    final db = await _db;
    await db.update(
      DatabaseConstants.personTable,
      {'is_active': 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ── Toggle Active ────────────────────────────────────────
  /// تبديل حالة is_active
  Future<void> toggleActive(int id, bool isActive) async {
    final db = await _db;
    await db.update(
      DatabaseConstants.personTable,
      {'is_active': isActive ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ── Person Transactions ──────────────────────────────────
  /// جيب كل معاملات شخص (sorted by date + partial_id)
  Future<List<PersonTransactionModel>> getTransactions(int personId) async {
    final db = await _db;
    final result = await db.query(
      DatabaseConstants.personTransactionTable,
      where: 'person_id = ?',
      whereArgs: [personId],
      orderBy: 'date, partial_id',
    );
    return result.map((row) => PersonTransactionModel.fromMap(row)).toList();
  }

  /// إضافة معاملة جديدة (weak entity → nextPartialId)
  Future<void> addTransaction(PersonTransactionModel tx) async {
    final db = await _db;
    final partialId = await _dbHelper.nextPartialId(
      db, DatabaseConstants.personTransactionTable, 'person_id', tx.personId,
    );
    await db.insert(DatabaseConstants.personTransactionTable, {
      'person_id': tx.personId,
      'partial_id': partialId,
      'type': tx.type.dbValue,
      'amount': tx.amount,
      'description': tx.description,
      'date': tx.date,
    });
  }

  /// تعديل معاملة
  Future<void> updateTransaction(PersonTransactionModel tx) async {
    final db = await _db;
    await db.update(
      DatabaseConstants.personTransactionTable,
      {
        'type': tx.type.dbValue,
        'amount': tx.amount,
        'description': tx.description,
        'date': tx.date,
      },
      where: 'person_id = ? AND partial_id = ?',
      whereArgs: [tx.personId, tx.partialId],
    );
  }

  /// حذف معاملة
  Future<void> deleteTransaction(int personId, int partialId) async {
    final db = await _db;
    await db.delete(
      DatabaseConstants.personTransactionTable,
      where: 'person_id = ? AND partial_id = ?',
      whereArgs: [personId, partialId],
    );
  }

  // ── Person Jobs ──────────────────────────────────────────
  /// جيب شغلانات الشخص (معلومات أساسية + computed totals)
  Future<List<JobModel>> getPersonJobs(int personId) async {
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
}
