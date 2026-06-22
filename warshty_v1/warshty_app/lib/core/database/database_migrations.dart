import 'package:sqflite/sqflite.dart';

/// migrations قاعدة البيانات
/// هنا هتحط أي تعديلات على الـ Schema في المستقبل
abstract final class DatabaseMigrations {
  /// تنفيذ الـ migration حسب version
  static Future<void> migrate(Database db, int oldVersion, int newVersion) async {
    // مثال على migration:
    // if (oldVersion < 2) {
    //   await db.execute('ALTER TABLE job ADD COLUMN priority TEXT DEFAULT "عادي"');
    // }
    //
    // if (oldVersion < 3) {
    //   await db.execute('ALTER TABLE person ADD COLUMN email TEXT');
    // }
  }
}
