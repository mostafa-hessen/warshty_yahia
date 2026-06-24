import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../constants/app_constants.dart';
import '../errors/exceptions.dart';
import 'database_tables.dart';
import 'database_seed.dart';
import 'database_migrations.dart';

/// مساعد قاعدة البيانات — Singleton
class DatabaseHelper {
  // ── Singleton ──────────────────────────────────────────────
  static DatabaseHelper? _instance;
  static Database? _database;

  DatabaseHelper._internal();
  static DatabaseHelper get instance {
    _instance ??= DatabaseHelper._internal();
    return _instance!;
  }

  // ── Database Access ────────────────────────────────────────
  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    try {
      final dbPath = await getDatabasesPath();
      final path = join(dbPath, AppConstants.dbName);
      return await openDatabase(
        path,
        version: AppConstants.dbVersion,
        onCreate: _onCreate,
        onConfigure: _onConfigure,
        onUpgrade: DatabaseMigrations.migrate,
      );
    } catch (e) {
      throw AppDatabaseException(
        message: 'فشل في فتح قاعدة البيانات',
        errorCode: -1,
      );
    }
  }

  /// تفعيل الـ Foreign Keys — لازم يتفعل قبل أي عملية
  Future<void> _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  // ── Schema Creation ────────────────────────────────────────
  Future<void> _onCreate(Database db, int version) async {
    await DatabaseTables.createAll(db);
    await DatabaseSeed.seedCategories(db);
    await DatabaseSeed.seedWorkshops(db);
  }

  // ── Helper: nextPartialId ──────────────────────────────────
  /// بيجيب الـ partial_id الجديد لأي Weak Entity
  Future<int> nextPartialId(
    Database db,
    String table,
    String ownerColumn,
    int ownerId,
  ) async {
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM $table WHERE $ownerColumn = ?',
      [ownerId],
    );
    return (result.first['count'] as int) + 1;
  }

  // ── Close (للـ Testing بس) ────────────────────────────────
  Future<void> close() async {
    await _database?.close();
    _database = null;
  }
}
