import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../core/constants/constants.dart';
import 'src/database_init_io.dart'
    if (dart.library.html) 'src/database_init_web.dart';

class AppDatabase {
  static Database? _database;

  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  static Future<Database> _initDB() async {
    ensureDatabaseFactory();
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, AppConstants.dbName);
    return await openDatabase(
      path,
      version: AppConstants.dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  static Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE categories (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        type TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE jobs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        workshop_id TEXT NOT NULL,
        product_type TEXT NOT NULL,
        status TEXT NOT NULL DEFAULT 'active',
        client_name TEXT NOT NULL,
        client_phone TEXT NOT NULL DEFAULT '',
        agreed_amount REAL NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT,
        notes TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE job_materials (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        job_id INTEGER NOT NULL REFERENCES jobs(id) ON DELETE CASCADE,
        description TEXT NOT NULL,
        cost_per_unit REAL NOT NULL,
        quantity REAL NOT NULL,
        warehouse_item_id INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE job_labors (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        job_id INTEGER NOT NULL REFERENCES jobs(id) ON DELETE CASCADE,
        description TEXT NOT NULL,
        amount REAL NOT NULL,
        category_id TEXT REFERENCES categories(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE job_other_expenses (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        job_id INTEGER NOT NULL REFERENCES jobs(id) ON DELETE CASCADE,
        description TEXT NOT NULL,
        amount REAL NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE job_payments (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        job_id INTEGER NOT NULL REFERENCES jobs(id) ON DELETE CASCADE,
        amount REAL NOT NULL,
        date TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE treasury_transactions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        type TEXT NOT NULL,
        date TEXT NOT NULL,
        amount REAL NOT NULL,
        description TEXT NOT NULL,
        category_id TEXT REFERENCES categories(id),
        workshop_id TEXT NOT NULL DEFAULT 'all',
        job_id INTEGER REFERENCES jobs(id) ON DELETE SET NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE warehouse (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        unit TEXT NOT NULL,
        cost REAL NOT NULL,
        quantity REAL NOT NULL,
        min_quantity REAL NOT NULL DEFAULT 5
      )
    ''');

    for (final cat in AppConstants.defaultCategories) {
      await db.insert('categories', {
        'id': cat['id'],
        'name': cat['name'],
        'type': cat['type'],
      });
    }
  }

  static Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
  }

  static Future<void> resetDatabase() async {
    final db = await database;
    await db.execute('DROP TABLE IF EXISTS job_payments');
    await db.execute('DROP TABLE IF EXISTS job_other_expenses');
    await db.execute('DROP TABLE IF EXISTS job_labors');
    await db.execute('DROP TABLE IF EXISTS job_materials');
    await db.execute('DROP TABLE IF EXISTS treasury_transactions');
    await db.execute('DROP TABLE IF EXISTS warehouse');
    await db.execute('DROP TABLE IF EXISTS jobs');
    await db.execute('DROP TABLE IF EXISTS categories');
    _database = null;
    await _initDB();
  }
}
