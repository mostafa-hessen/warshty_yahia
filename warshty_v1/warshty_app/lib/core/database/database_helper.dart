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
  /// يستخدم MAX بدل COUNT عشان لو في rows اتحدفت، مايعيدش ID موجود فعلاً
  Future<int> nextPartialId(
    Database db,
    String table,
    String ownerColumn,
    int ownerId,
  ) async {
    final result = await db.rawQuery(
      'SELECT COALESCE(MAX(partial_id), 0) + 1 as next FROM $table WHERE $ownerColumn = ?',
      [ownerId],
    );
    return (result.first['next'] as int);
  }

  // ── Ensure Seed Data ──────────────────────────────────────
  /// بيتأكد إن بيانات الـ seed موجودة — لو مش موجودة بيعملها
  /// (لازم نستدعيها بعد فتح الـ Database عشان الـ onCreate مش بيشتغل غير مرة واحدة)
  Future<void> ensureSeedData() async {
    final db = await database;

    final workshopCount = (await db.rawQuery('SELECT COUNT(*) as c FROM workshop')).first['c'] as int;
    if (workshopCount == 0) {
      await DatabaseSeed.seedWorkshops(db);
    } else {
      await db.update('workshop', {'name': 'ورشه البيت'}, where: 'name = ?', whereArgs: ['سيلا']);
      await db.update('workshop', {'name': 'الورشه الشرقيه'}, where: 'name = ?', whereArgs: ['الفيوم']);
      await db.update('workshop', {'name': 'الورشه الشرقيه'}, where: 'name = ?', whereArgs: ['الفيوك']);
    }

    final categoryCount = (await db.rawQuery('SELECT COUNT(*) as c FROM category')).first['c'] as int;
    if (categoryCount == 0) {
      await DatabaseSeed.seedCategories(db);
    }
  }

  // ── Close (للـ Testing بس) ────────────────────────────────
  Future<void> close() async {
    await _database?.close();
    _database = null;
  }
}
