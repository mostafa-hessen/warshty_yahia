import 'package:sqflite/sqflite.dart';

import 'database_constants.dart';

/// بيانات أولية للـ Database
abstract final class DatabaseSeed {
  /// زرع بيانات الـ Workshops
  static Future<void> seedWorkshops(Database db) async {
    final workshops = [
      {'name': 'ورشه البيت', 'is_active': 1},
      {'name': 'الورشه الشرقيه', 'is_active': 1},
    ];
    final batch = db.batch();
    for (final w in workshops) {
      batch.insert(DatabaseConstants.workshopTable, w);
    }
    await batch.commit(noResult: true);
  }

  /// زرع بيانات الـ Categories
  static Future<void> seedCategories(Database db) async {
    final categories = [
      // مصروفات الخزينة
      {'name': 'كهرباء', 'type': 'مصروف', 'is_active': 1},
      {'name': 'مياه', 'type': 'مصروف', 'is_active': 1},
      {'name': 'إيجار', 'type': 'مصروف', 'is_active': 1},
      {'name': 'رواتب', 'type': 'مصروف', 'is_active': 1},
      {'name': 'نقل', 'type': 'مصروف', 'is_active': 1},
      {'name': 'صيانة', 'type': 'مصروف', 'is_active': 1},
      // وارد الخزينة
      {'name': 'دفعة عميل', 'type': 'وارد', 'is_active': 1},
      {'name': 'عربون', 'type': 'وارد', 'is_active': 1},
      {'name': 'إيراد منوع', 'type': 'وارد', 'is_active': 1},
      // مصنعيات الشغلانة
      {'name': 'أجرة نجار', 'type': 'مصنعية', 'is_active': 1},
      {'name': 'أجرة دهان', 'type': 'مصنعية', 'is_active': 1},
      {'name': 'أجرة تركيب', 'type': 'مصنعية', 'is_active': 1},
      {'name': 'أجرة عام', 'type': 'مصنعية', 'is_active': 1},
      // تكاليف أخرى
      {'name': 'خامات', 'type': 'تكلفة', 'is_active': 1},
      {'name': 'شحن', 'type': 'تكلفة', 'is_active': 1},
    ];

    final batch = db.batch();
    for (final cat in categories) {
      batch.insert(DatabaseConstants.categoryTable, cat);
    }
    await batch.commit(noResult: true);
  }
}
