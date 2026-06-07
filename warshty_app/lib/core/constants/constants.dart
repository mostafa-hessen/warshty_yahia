class AppConstants {
  static const String appName = 'ورشتي';
  static const String appVersion = 'v1.0.0';
  static const String dbName = 'warshty.db';
  static const int dbVersion = 1;

  static const String defaultCurrency = 'ج.م';

  // Workshop IDs
  static const String workshopSila = 'sila';
  static const String workshopFayoum = 'fayoum';
  static const String workshopAll = 'all';

  // Default categories
  static const List<Map<String, String>> defaultCategories = [
    {'id': 'cat_elec', 'name': 'كهرباء', 'type': 'expense'},
    {'id': 'cat_water', 'name': 'مياه', 'type': 'expense'},
    {'id': 'cat_rent', 'name': 'إيجار', 'type': 'expense'},
    {'id': 'cat_salary', 'name': 'رواتب', 'type': 'expense'},
    {'id': 'cat_labor', 'name': 'مصنعيات', 'type': 'expense'},
    {'id': 'cat_transport', 'name': 'نقل', 'type': 'expense'},
    {'id': 'cat_maint', 'name': 'صيانة', 'type': 'expense'},
    {'id': 'cat_materials', 'name': 'خامات', 'type': 'expense'},
    {'id': 'cat_admin', 'name': 'مصروف إداري', 'type': 'expense'},
    {'id': 'cat_misc_exp', 'name': 'مصروف متنوع', 'type': 'expense'},
    {'id': 'cat_deposit', 'name': 'عربون عميل', 'type': 'income'},
    {'id': 'cat_payment', 'name': 'دفعة من عميل', 'type': 'income'},
    {'id': 'cat_sale', 'name': 'إيراد بيع', 'type': 'income'},
    {'id': 'cat_misc_inc', 'name': 'إيراد متنوع', 'type': 'income'},
    {'id': 'cat_carpenter', 'name': 'أجرة نجار', 'type': 'labor'},
    {'id': 'cat_painter', 'name': 'أجرة دهان', 'type': 'labor'},
    {'id': 'cat_install', 'name': 'أجرة تركيب', 'type': 'labor'},
    {'id': 'cat_worker', 'name': 'أجرة عامل', 'type': 'labor'},
  ];
}
