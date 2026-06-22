import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../constants/app_constants.dart';
import '../errors/exceptions.dart';

/// مساعد قاعدة البيانات — Singleton
/// Schema مبني على الـ ERD بالظبط
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
    final batch = db.batch();

    // ══════════════════════════════════════════════════════════
    //  STRONG ENTITIES
    // ══════════════════════════════════════════════════════════

    // 1. USER — Strong Entity
    batch.execute('''
      CREATE TABLE user (
        id              INTEGER PRIMARY KEY AUTOINCREMENT,
        password_hash   TEXT    NOT NULL,
        remember_token  TEXT,
        failed_attempts INTEGER NOT NULL DEFAULT 0,
        locked_until    TEXT,
        created_at      TEXT    NOT NULL DEFAULT (datetime('now'))
      )
    ''');

    // 2. WORKSHOP — Strong Entity
    batch.execute('''
      CREATE TABLE workshop (
        id         INTEGER PRIMARY KEY AUTOINCREMENT,
        name       TEXT    NOT NULL,
        is_active  INTEGER NOT NULL DEFAULT 1,
        created_at TEXT    NOT NULL DEFAULT (datetime('now'))
      )
    ''');

    // 3. PERSON — Strong Entity
    // balance و jobs_balance = computed → بنحسبهم في Flutter
    batch.execute('''
      CREATE TABLE person (
        id        INTEGER PRIMARY KEY AUTOINCREMENT,
        name      TEXT    NOT NULL,
        phone     TEXT,
        type      TEXT    NOT NULL DEFAULT 'عميل',
        notes     TEXT,
        is_active INTEGER NOT NULL DEFAULT 1
      )
    ''');

    // 4. CATEGORY — Strong Entity
    batch.execute('''
      CREATE TABLE category (
        id         INTEGER PRIMARY KEY AUTOINCREMENT,
        name       TEXT    NOT NULL,
        type       TEXT    NOT NULL,
        is_active  INTEGER NOT NULL DEFAULT 1,
        created_at TEXT    NOT NULL DEFAULT (datetime('now'))
      )
    ''');

    // 5. TREASURY — Strong Entity (Singleton — صف واحد بس)
    // balance / total_income / total_expense = computed
    batch.execute('''
      CREATE TABLE treasury (
        id INTEGER PRIMARY KEY AUTOINCREMENT
      )
    ''');

    // 6. JOB — Strong Entity
    // علاقة M:1 مع Workshop → workshop_id هنا
    // علاقة M:1 مع Person   → person_id هنا
    // total_costs / profit / remaining = computed
    batch.execute('''
      CREATE TABLE job (
        id            INTEGER PRIMARY KEY AUTOINCREMENT,
        workshop_id   INTEGER NOT NULL,
        person_id     INTEGER NOT NULL,
        name          TEXT    NOT NULL,
        product_type  TEXT,
        agreed_amount REAL    NOT NULL DEFAULT 0,
        status        TEXT    NOT NULL DEFAULT 'قيد',
        start_date    TEXT,
        notes         TEXT,
        FOREIGN KEY (workshop_id) REFERENCES workshop(id),
        FOREIGN KEY (person_id)   REFERENCES person(id)
      )
    ''');

    // ══════════════════════════════════════════════════════════
    //  WEAK ENTITIES — PK = (owner_id + partial_id)
    // ══════════════════════════════════════════════════════════

    // 7. TREASURY TRANSACTION — Weak Entity (Owner: Treasury)
    batch.execute('''
      CREATE TABLE treasury_transaction (
        treasury_id INTEGER NOT NULL,
        partial_id  INTEGER NOT NULL,
        type        TEXT    NOT NULL,
        amount      REAL    NOT NULL,
        description TEXT,
        date        TEXT    NOT NULL,
        source      TEXT,
        category_id INTEGER,
        workshop_id INTEGER,
        job_id      INTEGER,
        PRIMARY KEY (treasury_id, partial_id),
        FOREIGN KEY (treasury_id) REFERENCES treasury(id),
        FOREIGN KEY (category_id) REFERENCES category(id),
        FOREIGN KEY (workshop_id) REFERENCES workshop(id),
        FOREIGN KEY (job_id)      REFERENCES job(id)
      )
    ''');
    // 📌 job_id nullable — مش كل معاملة بيكون ليها شغلانة

    // 8. PERSON TRANSACTION — Weak Entity (Owner: Person)
    batch.execute('''
      CREATE TABLE person_transaction (
        person_id  INTEGER NOT NULL,
        partial_id INTEGER NOT NULL,
        type       TEXT    NOT NULL,
        amount     REAL    NOT NULL,
        description TEXT,
        date       TEXT    NOT NULL,
        PRIMARY KEY (person_id, partial_id),
        FOREIGN KEY (person_id) REFERENCES person(id)
      )
    ''');

    // 9. JOB MATERIAL — Weak Entity (Owner: Job)
    batch.execute('''
      CREATE TABLE job_material (
        job_id     INTEGER NOT NULL,
        partial_id INTEGER NOT NULL,
        name       TEXT    NOT NULL,
        amount     REAL,
        description TEXT,
        date       TEXT,
        PRIMARY KEY (job_id, partial_id),
        FOREIGN KEY (job_id) REFERENCES job(id)
      )
    ''');

    // 10. JOB LABOR — Weak Entity (Owner: Job)
    // category_id FK موجودة في الـ ERD كـ attribute مباشرة
    batch.execute('''
      CREATE TABLE job_labor (
        job_id      INTEGER NOT NULL,
        partial_id  INTEGER NOT NULL,
        amount      REAL,
        description TEXT,
        date        TEXT,
        category_id INTEGER,
        PRIMARY KEY (job_id, partial_id),
        FOREIGN KEY (job_id)      REFERENCES job(id),
        FOREIGN KEY (category_id) REFERENCES category(id)
      )
    ''');

    // 11. JOB OTHER COST — Weak Entity (Owner: Job)
    batch.execute('''
      CREATE TABLE job_other_cost (
        job_id      INTEGER NOT NULL,
        partial_id  INTEGER NOT NULL,
        amount      REAL,
        description TEXT,
        date        TEXT,
        category_id INTEGER,
        PRIMARY KEY (job_id, partial_id),
        FOREIGN KEY (job_id)      REFERENCES job(id),
        FOREIGN KEY (category_id) REFERENCES category(id)
      )
    ''');

    // 12. JOB PAYMENT — Weak Entity (Owner: Job)
    // ttx_treasury_id + ttx_partial_id = Composite FK لـ treasury_transaction
    batch.execute('''
      CREATE TABLE job_payment (
        job_id          INTEGER NOT NULL,
        partial_id      INTEGER NOT NULL,
        amount          REAL    NOT NULL,
        description     TEXT,
        date            TEXT    NOT NULL,
        ttx_treasury_id INTEGER,
        ttx_partial_id  INTEGER,
        PRIMARY KEY (job_id, partial_id),
        FOREIGN KEY (job_id) REFERENCES job(id),
        FOREIGN KEY (ttx_treasury_id, ttx_partial_id)
          REFERENCES treasury_transaction(treasury_id, partial_id)
      )
    ''');

    await batch.commit(noResult: true);

    // إنشاء الـ Treasury singleton (صف واحد بس في حياة التطبيق)
    await db.insert('treasury', {'id': 1});

    // بيانات أولية للـ Categories
    await _seedCategories(db);
  }

  // ── Seed Categories ────────────────────────────────────────
  Future<void> _seedCategories(Database db) async {
    final categories = [
      // مصروفات الخزينة
      {'name': 'كهرباء',    'type': 'مصروف', 'is_active': 1},
      {'name': 'مياه',      'type': 'مصروف', 'is_active': 1},
      {'name': 'إيجار',     'type': 'مصروف', 'is_active': 1},
      {'name': 'رواتب',     'type': 'مصروف', 'is_active': 1},
      {'name': 'نقل',       'type': 'مصروف', 'is_active': 1},
      {'name': 'صيانة',     'type': 'مصروف', 'is_active': 1},
      // وارد الخزينة
      {'name': 'دفعة عميل', 'type': 'وارد',  'is_active': 1},
      {'name': 'عربون',     'type': 'وارد',  'is_active': 1},
      {'name': 'إيراد منوع','type': 'وارد',  'is_active': 1},
      // مصنعيات الشغلانة
      {'name': 'أجرة نجار', 'type': 'مصنعية','is_active': 1},
      {'name': 'أجرة دهان', 'type': 'مصنعية','is_active': 1},
      {'name': 'أجرة تركيب','type': 'مصنعية','is_active': 1},
      {'name': 'أجرة عام',  'type': 'مصنعية','is_active': 1},
      // تكاليف أخرى
      {'name': 'خامات',     'type': 'تكلفة', 'is_active': 1},
      {'name': 'شحن',       'type': 'تكلفة', 'is_active': 1},
    ];

    final batch = db.batch();
    for (final cat in categories) {
      batch.insert('category', cat);
    }
    await batch.commit(noResult: true);
  }

  // ── Helper: nextPartialId ──────────────────────────────────
  /// بيجيب الـ partial_id الجديد لأي Weak Entity
  /// بيعد الـ rows الموجودة للـ owner ده ويضيف 1
  ///
  /// مثال:
  /// job_material عندها 3 rows لـ job_id=5
  /// → nextPartialId(db, 'job_material', 'job_id', 5) → 4
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