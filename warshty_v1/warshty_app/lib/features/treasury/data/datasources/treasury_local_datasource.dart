import 'package:sqflite/sqflite.dart';

import '../../../../core/database/database_helper.dart';
import '../../../../core/database/database_constants.dart';
import '../../../../core/enums/treasury_tx_type.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/treasury_transaction_model.dart';

class TreasuryLocalDataSource {
  final DatabaseHelper _dbHelper;

  TreasuryLocalDataSource(this._dbHelper);

  Future<Database> get _db => _dbHelper.database;

  Future<List<TreasuryTransactionModel>> getAll() async {
    final db = await _db;
    final result = await db.rawQuery('''
      SELECT
        tt.*,
        c.name as category_name,
        w.name as workshop_name
      FROM treasury_transaction tt
      LEFT JOIN category c ON c.id = tt.category_id
      LEFT JOIN workshop w ON w.id = tt.workshop_id
      WHERE tt.treasury_id = 1
      ORDER BY tt.date ASC, tt.partial_id ASC
    ''');
    return result.map((row) => TreasuryTransactionModel.fromMap(row)).toList();
  }

  Future<List<TreasuryTransactionModel>> getFiltered({
    TreasuryTxType? type,
    String? dateFrom,
    String? dateTo,
  }) async {
    final db = await _db;
    final conditions = <String>['tt.treasury_id = 1'];
    final args = <dynamic>[];

    if (type != null) {
      conditions.add('tt.type = ?');
      args.add(type.dbValue);
    }
    if (dateFrom != null) {
      conditions.add('tt.date >= ?');
      args.add(dateFrom);
    }
    if (dateTo != null) {
      conditions.add('tt.date <= ?');
      args.add(dateTo);
    }

    final result = await db.rawQuery('''
      SELECT
        tt.*,
        c.name as category_name,
        w.name as workshop_name
      FROM treasury_transaction tt
      LEFT JOIN category c ON c.id = tt.category_id
      LEFT JOIN workshop w ON w.id = tt.workshop_id
      WHERE ${conditions.join(' AND ')}
      ORDER BY tt.date ASC, tt.partial_id ASC
    ''', args);
    return result.map((row) => TreasuryTransactionModel.fromMap(row)).toList();
  }

  Future<Map<String, double>> getSummary() async {
    final db = await _db;
    final result = await db.rawQuery('''
      SELECT
        COALESCE(SUM(CASE WHEN type = 'وارد' THEN amount ELSE 0 END), 0) as total_income,
        COALESCE(SUM(CASE WHEN type = 'مصروف' THEN amount ELSE 0 END), 0) as total_expense
      FROM treasury_transaction
      WHERE treasury_id = 1
    ''');
    final row = result.first;
    return {
      'total_income': (row['total_income'] as num?)?.toDouble() ?? 0,
      'total_expense': (row['total_expense'] as num?)?.toDouble() ?? 0,
    };
  }

  Future<int> insert(TreasuryTransactionModel tx) async {
    final db = await _db;
    final partialId = await _dbHelper.nextPartialId(
      db, DatabaseConstants.treasuryTransactionTable, 'treasury_id', tx.treasuryId,
    );
    await db.insert(DatabaseConstants.treasuryTransactionTable, {
      'treasury_id': tx.treasuryId,
      'partial_id': partialId,
      'type': tx.type.dbValue,
      'amount': tx.amount,
      'description': tx.description,
      'date': tx.date,
      'source': tx.source ?? 'يدوي',
      'category_id': tx.categoryId,
      'workshop_id': tx.workshopId,
      'job_id': tx.jobId,
    });
    return partialId;
  }

  Future<void> update(TreasuryTransactionModel tx) async {
    if (tx.partialId <= 0) {
      throw const AppDatabaseException(message: 'لا يمكن تعديل معاملة بدون partial_id');
    }
    final db = await _db;
    await db.update(
      DatabaseConstants.treasuryTransactionTable,
      {
        'type': tx.type.dbValue,
        'amount': tx.amount,
        'description': tx.description,
        'date': tx.date,
        'category_id': tx.categoryId,
        'workshop_id': tx.workshopId,
      },
      where: 'treasury_id = ? AND partial_id = ?',
      whereArgs: [tx.treasuryId, tx.partialId],
    );
  }

  Future<void> delete(int partialId) async {
    final db = await _db;
    await db.delete(
      DatabaseConstants.treasuryTransactionTable,
      where: 'treasury_id = 1 AND partial_id = ?',
      whereArgs: [partialId],
    );
  }
}
