import 'package:sqflite/sqflite.dart' hide Transaction;
import '../../domain/entities/transaction.dart';
import '../../domain/repositories/treasury_repository.dart';
import '../database/app_database.dart';

class TreasuryRepositorySQLite implements TreasuryRepository {
  Future<Database> get db => AppDatabase.database;

  @override
  Future<List<Transaction>> getTransactions({
    String? type,
    String? period,
    String? from,
    String? to,
    String? workshop,
  }) async {
    final database = await db;
    final conditions = <String>[];
    final params = <dynamic>[];
    final dateFilter = _dateCondition(period, from, to);

    if (type != null && type != 'all') {
      conditions.add('type = ?');
      params.add(type);
    }
    if (dateFilter != null) {
      conditions.add(dateFilter);
    }
    if (workshop != null && workshop != 'all') {
      conditions.add('workshop_id = ?');
      params.add(workshop);
    }

    final where = conditions.isNotEmpty ? 'WHERE ${conditions.join(' AND ')}' : '';
    final rows = await database.rawQuery(
      'SELECT * FROM treasury_transactions $where ORDER BY date DESC, id DESC',
      params,
    );
    return rows.map((r) => _fromMap(r)).toList();
  }

  @override
  Future<void> addTransaction(Transaction transaction) async {
    final database = await db;
    await database.insert('treasury_transactions', {
      'type': transaction.type,
      'date': transaction.date,
      'amount': transaction.amount,
      'description': transaction.description,
      'category_id': transaction.categoryId,
      'workshop_id': transaction.workshopId,
      'job_id': transaction.jobId,
    });
  }

  @override
  Future<void> deleteTransaction(int id) async {
    final database = await db;
    await database.delete('treasury_transactions', where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<double> getTotalIncome({String? period, String? from, String? to, String? workshop}) async {
    return _sum('income', period, from, to, workshop);
  }

  @override
  Future<double> getTotalExpense({String? period, String? from, String? to, String? workshop}) async {
    return _sum('expense', period, from, to, workshop);
  }

  @override
  Future<double> getBalance() async {
    final income = await getTotalIncome();
    final expense = await getTotalExpense();
    return income - expense;
  }

  @override
  Future<Map<String, double>> getExpenseByCategory({
    String? period,
    String? from,
    String? to,
  }) async {
    final database = await db;
    final dateFilter = _dateCondition(period, from, to);
    final where = 'type = \'expense\'${dateFilter != null ? ' AND $dateFilter' : ''}';
    final rows = await database.rawQuery(
      'SELECT category_id, COALESCE(SUM(amount), 0) as total FROM treasury_transactions WHERE $where GROUP BY category_id',
    );
    final map = <String, double>{};
    for (final r in rows) {
      map[r['category_id'] as String] = (r['total'] as num).toDouble();
    }
    return map;
  }

  @override
  Future<double> getTotalLaborCost({String? period, String? workshop}) async {
    final database = await db;
    final conditions = <String>["type = 'expense'", "category_id = 'cat_labor'"];
    final params = <dynamic>[];
    final dateFilter = _dateCondition(period, null, null);
    if (dateFilter != null) conditions.add(dateFilter);
    if (workshop != null && workshop != 'all') {
      conditions.add('workshop_id = ?');
      params.add(workshop);
    }
    final where = conditions.join(' AND ');
    final rows = await database.rawQuery(
      'SELECT COALESCE(SUM(amount), 0) as total FROM treasury_transactions WHERE $where',
      params,
    );
    return (rows.first['total'] as num).toDouble();
  }

  @override
  Future<double> getTotalMaterialCost({String? period, String? workshop}) async {
    final database = await db;
    final conditions = <String>["type = 'expense'", "category_id = 'cat_materials'"];
    final params = <dynamic>[];
    final dateFilter = _dateCondition(period, null, null);
    if (dateFilter != null) conditions.add(dateFilter);
    if (workshop != null && workshop != 'all') {
      conditions.add('workshop_id = ?');
      params.add(workshop);
    }
    final where = conditions.join(' AND ');
    final rows = await database.rawQuery(
      'SELECT COALESCE(SUM(amount), 0) as total FROM treasury_transactions WHERE $where',
      params,
    );
    return (rows.first['total'] as num).toDouble();
  }

  Future<List<Map<String, dynamic>>> getMonthlySummary({int months = 6, String? workshop}) async {
    final database = await db;
    final conditions = <String>[];
    final params = <dynamic>[];
    final cutoff = DateTime.now().subtract(Duration(days: 30 * months)).toIso8601String();
    conditions.add("date >= ?");
    params.add(cutoff);
    if (workshop != null && workshop != 'all') {
      conditions.add('workshop_id = ?');
      params.add(workshop);
    }
    final where = conditions.join(' AND ');
    return await database.rawQuery(
      "SELECT strftime('%Y-%m', date) as month, "
      "COALESCE(SUM(CASE WHEN type='income' THEN amount ELSE 0 END), 0) as income, "
      "COALESCE(SUM(CASE WHEN type='expense' THEN amount ELSE 0 END), 0) as expense "
      'FROM treasury_transactions WHERE $where '
      "GROUP BY strftime('%Y-%m', date) ORDER BY month ASC",
      params,
    );
  }

  Future<double> _sum(String type, String? period, String? from, String? to, String? workshop) async {
    final database = await db;
    final conditions = <String>['type = ?'];
    final params = <dynamic>[type];
    final dateFilter = _dateCondition(period, from, to);
    if (dateFilter != null) conditions.add(dateFilter);
    if (workshop != null && workshop != 'all') {
      conditions.add('workshop_id = ?');
      params.add(workshop);
    }
    final where = conditions.join(' AND ');
    final rows = await database.rawQuery(
      'SELECT COALESCE(SUM(amount), 0) as total FROM treasury_transactions WHERE $where',
      params,
    );
    return (rows.first['total'] as num).toDouble();
  }

  String? _dateCondition(String? period, String? from, String? to) {
    final now = DateTime.now();
    if (from != null && to != null) {
      return "date >= '$from' AND date <= '$to'";
    }
    if (period == null || period == 'all') return null;
    String start;
    switch (period) {
      case 'today':
        start = DateTime(now.year, now.month, now.day).toIso8601String();
      case 'week':
        start = now.subtract(Duration(days: now.weekday - 1)).toIso8601String();
      case 'month':
        start = DateTime(now.year, now.month, 1).toIso8601String();
      case 'year':
        start = DateTime(now.year, 1, 1).toIso8601String();
      default:
        return null;
    }
    return "date >= '$start'";
  }

  Transaction _fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id'] as int?,
      type: map['type'] as String,
      date: map['date'] as String,
      amount: (map['amount'] as num).toDouble(),
      description: map['description'] as String,
      categoryId: map['category_id'] as String,
      workshopId: map['workshop_id'] as String? ?? 'all',
      jobId: map['job_id'] as int?,
    );
  }
}
