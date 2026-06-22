/// ثوابت التطبيق — أبعاد، نسب، أسماء قواعد البيانات
/// مأخوذة مباشرة من قيم CSS في ملف HTML المرجعي
abstract final class AppConstants {
  // ── اسم التطبيق وقاعدة البيانات ──────────────────────────
  static const String appName = 'ورشتي';
  static const String appVersion = 'v4';
  static const String dbName = 'warshty.db';
  static const int dbVersion = 1;

  // ── Border Radius (بالبكسل — من CSS) ──────────────────────
  /// 4px — Scrollbar thumb
  static const double radiusXs = 4.0;
  /// 8px — workshop-btn, back-btn, period-btn, stat-icon
  static const double radiusSm = 8.0;
  /// 10px — form-input, btn, tab, icon-btn, logo-icon, nav-item,
  ///        workshop-toggle, detail-tab, finance-mini-card, pl-total-row
  static const double radiusMd = 10.0;
  /// 12px — login-input, login-btn, badge, tx-item, action-btn,
  ///        report-card, fab (partial)
  static const double radiusLg = 12.0;
  /// 14px — stat-card, person-card, job-card, fab, detail-section,
  ///        summary-card, treasury-card, pl-section, finance-card-large
  static const double radiusXl = 14.0;
  /// 18px — balance-card
  static const double radius2xl = 18.0;
  /// 22px — modal (top corners)
  static const double radius3xl = 22.0;
  /// 16px — category-chip
  static const double radiusChip = 16.0;

  // ── Spacing / Padding / Gap (بالبكسل — من CSS) ──────────
  static const double spacing2 = 2.0;
  static const double spacing3 = 3.0;
  static const double spacing4 = 4.0;
  static const double spacing6 = 6.0;
  static const double spacing8 = 8.0;
  static const double spacing10 = 10.0;
  static const double spacing12 = 12.0;
  static const double spacing14 = 14.0;
  static const double spacing16 = 16.0;
  static const double spacing18 = 18.0;
  static const double spacing20 = 20.0;
  static const double spacing24 = 24.0;
  static const double spacing28 = 28.0;
  static const double spacing32 = 32.0;
  static const double spacing40 = 40.0;
  static const double spacing50 = 50.0;
  static const double spacing100 = 100.0;

  // ── Icon Sizes ────────────────────────────────────────────
  static const double iconSm = 14.0;
  static const double iconMd = 16.0;
  static const double iconLg = 20.0;
  static const double iconXl = 22.0;
  static const double iconBtnSize = 36.0;

  // ── Misc Sizes ────────────────────────────────────────────
  /// أقصى عرض للتطبيق (موبايل)
  static const double maxAppWidth = 430.0;
  /// ارتفاع شريط التنقل السفلي
  static const double bottomNavHeight = 56.0;
  /// ارتفاع FAB
  static const double fabSize = 52.0;
  /// ارتفاع شريط أخذت/عطيت السفلي
  static const double personBottomBarHeight = 56.0;

  // ── Avatar Colors (للـ getAvatarColor) ────────────────────
  static const List<String> avatarColors = [
    '#00d4aa',
    '#3b82f6',
    '#8b5cf6',
    '#f59e0b',
    '#ef4444',
    '#10b981',
    '#ec4899',
    '#14b8a6',
    '#f97316',
    '#6366f1',
  ];
}
