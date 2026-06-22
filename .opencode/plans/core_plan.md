# خطة تنفيذ lib/core — ورشتي Flutter

## الملفات المطلوبة:

### 1. pubspec.yaml — تعديلات
### 2. lib/core/constants/app_constants.dart
### 3. lib/core/theme/app_text_styles.dart
### 4. lib/core/theme/app_theme.dart
### 5. lib/core/utils/formatters.dart
### 6. lib/core/network/connection_checker.dart
### 7. lib/core/database/database_helper.dart
### 8. lib/core/errors/exceptions.dart

---

## تعديلات pubspec.yaml

```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.8
  sqflite: ^2.3.0
  path: ^1.9.0
  intl: ^0.19.0
  connectivity_plus: ^6.0.0
  google_fonts: ^6.2.1

flutter:
  uses-material-design: true
```

---

## lib/core/constants/app_constants.dart

```dart
import 'package:flutter/material.dart';

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
```

---

## lib/core/theme/app_text_styles.dart

```dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// أنماط النصوص — مأخوذة من أكواد CSS في ملف HTML المرجعي
/// كل TextStyle له تعليق بالكلاس اللي أخدناه منه
abstract final class AppTextStyles {
  // ── Logo ──────────────────────────────────────────────────
  /// `.logo-text` — 16px, w800, gradient (نستخدم w800 هنا)
  static TextStyle logoText(BuildContext context) =>
      _base(context).copyWith(fontSize: 16, fontWeight: FontWeight.w800);

  /// `.login-title` — 28px, w900, gradient text
  static TextStyle loginTitle(BuildContext context) =>
      _base(context).copyWith(fontSize: 28, fontWeight: FontWeight.w900);

  // ── Balance ───────────────────────────────────────────────
  /// `.balance-amount` — 32px, w900, accent color
  static TextStyle balanceAmount(BuildContext context) =>
      _base(context).copyWith(fontSize: 32, fontWeight: FontWeight.w900);

  /// `.balance-label` — 13px, text-secondary
  static TextStyle balanceLabel(BuildContext context) =>
      _base(context).copyWith(fontSize: 13, fontWeight: FontWeight.w400);

  // ── Stats ─────────────────────────────────────────────────
  /// `.stat-value` — 16px, w800
  static TextStyle statValue(BuildContext context) =>
      _base(context).copyWith(fontSize: 16, fontWeight: FontWeight.w800);

  /// `.stat-label` — 10px, text-secondary
  static TextStyle statLabel(BuildContext context) =>
      _base(context).copyWith(fontSize: 10, fontWeight: FontWeight.w400);

  // ── Sections ──────────────────────────────────────────────
  /// `.section-title` — 14px, w700
  static TextStyle sectionTitle(BuildContext context) =>
      _base(context).copyWith(fontSize: 14, fontWeight: FontWeight.w700);

  /// `.section-title a` — 12px, accent, w500
  static TextStyle sectionLink(BuildContext context) =>
      _base(context).copyWith(fontSize: 12, fontWeight: FontWeight.w500);

  // ── Cards ─────────────────────────────────────────────────
  /// `.card-title` — 14px, w700
  static TextStyle cardTitle(BuildContext context) =>
      _base(context).copyWith(fontSize: 14, fontWeight: FontWeight.w700);

  /// `.card-sub` — 11px, text-secondary
  static TextStyle cardSub(BuildContext context) =>
      _base(context).copyWith(fontSize: 11, fontWeight: FontWeight.w400);

  /// `.card-amount` — 14px, w800, accent
  static TextStyle cardAmount(BuildContext context) =>
      _base(context).copyWith(fontSize: 14, fontWeight: FontWeight.w800);

  /// `.empty-title` — 16px, w700
  static TextStyle emptyTitle(BuildContext context) =>
      _base(context).copyWith(fontSize: 16, fontWeight: FontWeight.w700);

  /// `.empty-text` — 13px, text-secondary
  static TextStyle emptyText(BuildContext context) =>
      _base(context).copyWith(fontSize: 13, fontWeight: FontWeight.w400);

  // ── Modal ─────────────────────────────────────────────────
  /// `.modal-title` — 18px, w800
  static TextStyle modalTitle(BuildContext context) =>
      _base(context).copyWith(fontSize: 18, fontWeight: FontWeight.w800);

  // ── Forms ─────────────────────────────────────────────────
  /// `.form-label` — 12px, w600, text-secondary
  static TextStyle formLabel(BuildContext context) =>
      _base(context).copyWith(fontSize: 12, fontWeight: FontWeight.w600);

  /// `.form-input` — 14px, regular
  static TextStyle formInput(BuildContext context) =>
      _base(context).copyWith(fontSize: 14, fontWeight: FontWeight.w400);

  /// `.form-input::placeholder` — 14px, text-muted
  static TextStyle formPlaceholder(BuildContext context) =>
      _base(context).copyWith(fontSize: 14, fontWeight: FontWeight.w400);

  // ── Buttons ───────────────────────────────────────────────
  /// `.btn` — 14px, w700
  static TextStyle button(BuildContext context) =>
      _base(context).copyWith(fontSize: 14, fontWeight: FontWeight.w700);

  /// `.btn-primary` — same as .btn
  static TextStyle buttonPrimary(BuildContext context) => button(context);

  /// `.login-btn` — 16px, w700
  static TextStyle loginButton(BuildContext context) =>
      _base(context).copyWith(fontSize: 16, fontWeight: FontWeight.w700);

  /// `.login-input` — 16px, regular
  static TextStyle loginInput(BuildContext context) =>
      _base(context).copyWith(fontSize: 16, fontWeight: FontWeight.w400);

  // ── Tabs & Chips ──────────────────────────────────────────
  /// `.tab` — 12px, w600
  static TextStyle tab(BuildContext context) =>
      _base(context).copyWith(fontSize: 12, fontWeight: FontWeight.w600);

  /// `.workshop-btn` — 11px, w700
  static TextStyle workshopButton(BuildContext context) =>
      _base(context).copyWith(fontSize: 11, fontWeight: FontWeight.w700);

  /// `.category-chip` — 10px, w700
  static TextStyle categoryChip(BuildContext context) =>
      _base(context).copyWith(fontSize: 10, fontWeight: FontWeight.w700);

  /// `.period-btn` — 11px, w600
  static TextStyle periodButton(BuildContext context) =>
      _base(context).copyWith(fontSize: 11, fontWeight: FontWeight.w600);

  /// `.nav-label` — 8px, w600
  static TextStyle navLabel(BuildContext context) =>
      _base(context).copyWith(fontSize: 8, fontWeight: FontWeight.w600);

  // ── Badge ─────────────────────────────────────────────────
  /// `.badge` — 10px, w600
  static TextStyle badge(BuildContext context) =>
      _base(context).copyWith(fontSize: 10, fontWeight: FontWeight.w600);

  // ── Search ────────────────────────────────────────────────
  /// `.search-input` — 13px, regular
  static TextStyle searchInput(BuildContext context) =>
      _base(context).copyWith(fontSize: 13, fontWeight: FontWeight.w400);

  // ── Details ───────────────────────────────────────────────
  /// `.detail-section-title` — 13px, w700
  static TextStyle detailSectionTitle(BuildContext context) =>
      _base(context).copyWith(fontSize: 13, fontWeight: FontWeight.w700);

  /// `.detail-label` — 12px, text-secondary
  static TextStyle detailLabel(BuildContext context) =>
      _base(context).copyWith(fontSize: 12, fontWeight: FontWeight.w400);

  /// `.detail-value` — 13px, w600
  static TextStyle detailValue(BuildContext context) =>
      _base(context).copyWith(fontSize: 13, fontWeight: FontWeight.w600);

  /// `.detail-tab` — 13px, w700
  static TextStyle detailTab(BuildContext context) =>
      _base(context).copyWith(fontSize: 13, fontWeight: FontWeight.w700);

  // ── Summary ───────────────────────────────────────────────
  /// `.summary-label` — 12px, text-secondary
  static TextStyle summaryLabel(BuildContext context) =>
      _base(context).copyWith(fontSize: 12, fontWeight: FontWeight.w400);

  /// `.summary-value` — 13px, w700
  static TextStyle summaryValue(BuildContext context) =>
      _base(context).copyWith(fontSize: 13, fontWeight: FontWeight.w700);

  /// `.summary-total` — 16px, accent
  static TextStyle summaryTotal(BuildContext context) =>
      _base(context).copyWith(fontSize: 16, fontWeight: FontWeight.w700);

  // ── Treasury ──────────────────────────────────────────────
  /// `.treasury-card .t-amount` — 14px, w800
  static TextStyle treasuryAmount(BuildContext context) =>
      _base(context).copyWith(fontSize: 14, fontWeight: FontWeight.w800);

  /// `.finance-mini-card .fvalue` — 16px, w800
  static TextStyle financeMiniValue(BuildContext context) =>
      _base(context).copyWith(fontSize: 16, fontWeight: FontWeight.w800);

  /// `.finance-mini-card .flabel` — 10px, text-secondary
  static TextStyle financeMiniLabel(BuildContext context) =>
      _base(context).copyWith(fontSize: 10, fontWeight: FontWeight.w400);

  /// `.finance-card-large .fvalue` — 26px, w900
  static TextStyle financeLargeValue(BuildContext context) =>
      _base(context).copyWith(fontSize: 26, fontWeight: FontWeight.w900);

  /// `.finance-card-large .flabel` — 11px, w600, text-secondary
  static TextStyle financeLargeLabel(BuildContext context) =>
      _base(context).copyWith(fontSize: 11, fontWeight: FontWeight.w600);

  // ── Transactions ──────────────────────────────────────────
  /// `.tx-amount-main` — 16px, w800
  static TextStyle txAmountMain(BuildContext context) =>
      _base(context).copyWith(fontSize: 16, fontWeight: FontWeight.w800);

  /// `.tx-date-label` — 11px, text-secondary
  static TextStyle txDateLabel(BuildContext context) =>
      _base(context).copyWith(fontSize: 11, fontWeight: FontWeight.w400);

  /// `.tx-before-label` — 11px, text-muted
  static TextStyle txBeforeLabel(BuildContext context) =>
      _base(context).copyWith(fontSize: 11, fontWeight: FontWeight.w400);

  /// `.tx-note-label` — 11px, text-secondary
  static TextStyle txNoteLabel(BuildContext context) =>
      _base(context).copyWith(fontSize: 11, fontWeight: FontWeight.w400);

  /// `.tx-tag-amount` — 20px, w900
  static TextStyle txTagAmount(BuildContext context) =>
      _base(context).copyWith(fontSize: 20, fontWeight: FontWeight.w900);

  /// `.tx-tag-label` — 10px, w700
  static TextStyle txTagLabel(BuildContext context) =>
      _base(context).copyWith(fontSize: 10, fontWeight: FontWeight.w700);

  // ── Reports ───────────────────────────────────────────────
  /// `.report-card .rc-label` — 11px, text-secondary
  static TextStyle reportCardLabel(BuildContext context) =>
      _base(context).copyWith(fontSize: 11, fontWeight: FontWeight.w400);

  /// `.report-card .rc-value` — 20px, w800
  static TextStyle reportCardValue(BuildContext context) =>
      _base(context).copyWith(fontSize: 20, fontWeight: FontWeight.w800);

  // ── PL Report ─────────────────────────────────────────────
  /// `.pl-section-title` — 14px, w800
  static TextStyle plSectionTitle(BuildContext context) =>
      _base(context).copyWith(fontSize: 14, fontWeight: FontWeight.w800);

  /// `.pl-row` — 12px
  static TextStyle plRow(BuildContext context) =>
      _base(context).copyWith(fontSize: 12, fontWeight: FontWeight.w400);

  /// `.pl-total-row` — 14px, w800
  static TextStyle plTotalRow(BuildContext context) =>
      _base(context).copyWith(fontSize: 14, fontWeight: FontWeight.w800);

  // ── Person Detail ─────────────────────────────────────────
  /// `.person-bottom-bar .action-btn` — 14px, w800
  static TextStyle personActionBtn(BuildContext context) =>
      _base(context).copyWith(fontSize: 14, fontWeight: FontWeight.w800);

  /// `.action-btn` — 15px, w800
  static TextStyle actionBtn(BuildContext context) =>
      _base(context).copyWith(fontSize: 15, fontWeight: FontWeight.w800);

  /// `.back-btn` — 12px, w600
  static TextStyle backBtn(BuildContext context) =>
      _base(context).copyWith(fontSize: 12, fontWeight: FontWeight.w600);

  // ── Helper ────────────────────────────────────────────────
  static TextStyle _base(BuildContext context) {
    return GoogleFonts.tajawal(
      color: Theme.of(context).colorScheme.onSurface,
    );
  }
}
```

---

## lib/core/theme/app_theme.dart

```dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// ثيم التطبيق — Dark + Light mode
/// يستخدم الألوان من AppColors والخطوط من Google Fonts (Tajawal)
abstract final class AppTheme {
  // ════════════════════════════════════════════════════════════
  //  DARK THEME
  // ════════════════════════════════════════════════════════════

  static ThemeData get dark {
    final colorScheme = ColorScheme.dark(
      primary: AppColors.darkAccent,
      onPrimary: AppColors.darkBgPrimary,
      secondary: AppColors.darkAccent,
      onSecondary: AppColors.darkBgPrimary,
      surface: AppColors.darkBgCard,
      onSurface: AppColors.darkTextPrimary,
      error: AppColors.danger,
      onError: Colors.white,
      outline: AppColors.darkBorder,
      shadow: AppColors.darkAccentGlow,
    );

    return ThemeData(
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.darkBgPrimary,
      cardColor: AppColors.darkBgCard,
      dividerColor: AppColors.darkBorder,
      fontFamily: GoogleFonts.tajawal().fontFamily,
      textTheme: _textTheme(colorScheme.onSurface),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.darkBgPrimary.withAlpha(0),
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: GoogleFonts.tajawal(
          fontSize: 16,
          fontWeight: FontWeight.w800,
          color: AppColors.darkTextPrimary,
        ),
        iconTheme: IconThemeData(color: AppColors.darkTextSecondary),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkBgCard,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: AppColors.darkBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: AppColors.darkBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: AppColors.darkAccent, width: 1.5),
        ),
        hintStyle: GoogleFonts.tajawal(
          color: AppColors.darkTextMuted,
          fontSize: 14,
        ),
        labelStyle: GoogleFonts.tajawal(
          color: AppColors.darkTextSecondary,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.darkAccent,
          foregroundColor: AppColors.darkBgPrimary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          textStyle: GoogleFonts.tajawal(
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.darkBgCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: AppColors.darkBorder),
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: const Color(0xF2111827),
        selectedItemColor: AppColors.darkAccent,
        unselectedItemColor: AppColors.darkTextMuted,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.darkBgCard,
        selectedColor: AppColors.darkAccent,
        labelStyle: GoogleFonts.tajawal(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: AppColors.darkTextSecondary,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: AppColors.darkBorder),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.darkBgSecondary,
        shape: RoundedRectangleBorder(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.darkBgCard,
        contentTextStyle: GoogleFonts.tajawal(
          color: AppColors.darkTextPrimary,
          fontSize: 13,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════════════════
  //  LIGHT THEME
  // ════════════════════════════════════════════════════════════

  static ThemeData get light {
    final colorScheme = ColorScheme.light(
      primary: AppColors.lightAccent,
      onPrimary: Colors.white,
      secondary: AppColors.lightAccent,
      onSecondary: Colors.white,
      surface: AppColors.lightBgCard,
      onSurface: AppColors.lightTextPrimary,
      error: AppColors.dangerLight,
      onError: Colors.white,
      outline: AppColors.lightBorder,
      shadow: AppColors.lightAccentGlow,
    );

    return ThemeData(
      brightness: Brightness.light,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.lightBgPrimary,
      cardColor: AppColors.lightBgCard,
      dividerColor: AppColors.lightBorder,
      fontFamily: GoogleFonts.tajawal().fontFamily,
      textTheme: _textTheme(colorScheme.onSurface),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.lightBgPrimary.withAlpha(0),
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: GoogleFonts.tajawal(
          fontSize: 16,
          fontWeight: FontWeight.w800,
          color: AppColors.lightTextPrimary,
        ),
        iconTheme: IconThemeData(color: AppColors.lightTextSecondary),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF8FDFB),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFB0CDC7)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFB0CDC7)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: AppColors.lightAccent, width: 1.5),
        ),
        hintStyle: GoogleFonts.tajawal(
          color: AppColors.lightTextMuted,
          fontSize: 14,
        ),
        labelStyle: GoogleFonts.tajawal(
          color: AppColors.lightTextSecondary,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.lightAccent,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          textStyle: GoogleFonts.tajawal(
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.lightBgCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: AppColors.lightBorder),
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: const Color(0xFFF7FFFE),
        selectedItemColor: AppColors.lightAccent,
        unselectedItemColor: AppColors.lightTextMuted,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.lightBgCard,
        selectedColor: AppColors.lightAccent,
        labelStyle: GoogleFonts.tajawal(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: AppColors.lightTextSecondary,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: AppColors.lightBorder),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.lightBgCard,
        contentTextStyle: GoogleFonts.tajawal(
          color: AppColors.lightTextPrimary,
          fontSize: 13,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  // ── Text Theme Helper ──────────────────────────────────────

  static TextTheme _textTheme(Color onSurface) {
    return TextTheme(
      displayLarge: GoogleFonts.tajawal(
        fontSize: 32,
        fontWeight: FontWeight.w900,
        color: onSurface,
      ),
      displayMedium: GoogleFonts.tajawal(
        fontSize: 28,
        fontWeight: FontWeight.w900,
        color: onSurface,
      ),
      displaySmall: GoogleFonts.tajawal(
        fontSize: 26,
        fontWeight: FontWeight.w900,
        color: onSurface,
      ),
      headlineLarge: GoogleFonts.tajawal(
        fontSize: 20,
        fontWeight: FontWeight.w800,
        color: onSurface,
      ),
      headlineMedium: GoogleFonts.tajawal(
        fontSize: 18,
        fontWeight: FontWeight.w800,
        color: onSurface,
      ),
      headlineSmall: GoogleFonts.tajawal(
        fontSize: 16,
        fontWeight: FontWeight.w800,
        color: onSurface,
      ),
      titleLarge: GoogleFonts.tajawal(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: onSurface,
      ),
      titleMedium: GoogleFonts.tajawal(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: onSurface,
      ),
      titleSmall: GoogleFonts.tajawal(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: onSurface,
      ),
      bodyLarge: GoogleFonts.tajawal(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: onSurface,
      ),
      bodyMedium: GoogleFonts.tajawal(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: onSurface,
      ),
      bodySmall: GoogleFonts.tajawal(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: onSurface,
      ),
      labelLarge: GoogleFonts.tajawal(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: onSurface,
      ),
      labelMedium: GoogleFonts.tajawal(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: onSurface,
      ),
      labelSmall: GoogleFonts.tajawal(
        fontSize: 10,
        fontWeight: FontWeight.w600,
        color: onSurface,
      ),
    );
  }
}
```

---

## lib/core/utils/formatters.dart

```dart
import 'package:intl/intl.dart';

/// تنسيق العملة والتواريخ
abstract final class AppFormatters {
  // ── Currency ───────────────────────────────────────────────

  /// تنسيق العملة بالجنيه المصري — "١٬٥٠٠ ج.م"
  /// مأخوذ من دالة fmt() في الـ JavaScript
  static final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'ar_EG',
    symbol: 'ج.م',
    decimalDigits: 0,
  );

  /// تنسيق مبلغ بالعملة: 15000 → "١٥٬٠٠٠ ج.م"
  static String currency(double amount) {
    return _currencyFormat.format(amount);
  }

  /// تنسيق مبلغ بدون عملة: 15000 → "١٥٬٠٠٠"
  static final NumberFormat _numberFormat = NumberFormat.decimalDigit('ar_EG');

  static String formatNumber(double amount) {
    return _numberFormat.format(amount);
  }

  // ── Date Formatting ────────────────────────────────────────

  /// تنسيق تاريخ عربي — "٢٠ يونيو ٢٠٢٦"
  /// يقبل ISO date string (yyyy-MM-dd)
  static String formatDate(String? isoDate) {
    if (isoDate == null || isoDate.isEmpty) return '—';
    try {
      final date = DateTime.parse(isoDate);
      return DateFormat('d MMMM yyyy', 'ar').format(date);
    } catch (_) {
      return isoDate;
    }
  }

  /// تنسيق تاريخ + وقت — "٢٠ يونيو ٢٠٢٦ ٢:٣٠ م"
  static String formatDateTime(String? isoDateTime) {
    if (isoDateTime == null || isoDateTime.isEmpty) return '—';
    try {
      final date = DateTime.parse(isoDateTime);
      return DateFormat('d MMMM yyyy h:mm a', 'ar').format(date);
    } catch (_) {
      return isoDateTime;
    }
  }

  /// تنسيق التاريخ المختصر — "20/06/2026"
  static String formatDateShort(String? isoDate) {
    if (isoDate == null || isoDate.isEmpty) return '—';
    try {
      final date = DateTime.parse(isoDate);
      return DateFormat('dd/MM/yyyy').format(date);
    } catch (_) {
      return isoDate;
    }
  }

  /// تاريخ اليوم بصيغة ISO — "2026-06-20"
  static String today() {
    return DateTime.now().toIso8601String().split('T').first;
  }

  /// تاريخ ووقت الآن بصيغة ISO
  static String now() {
    return DateTime.now().toIso8601String();
  }
}
```

---

## lib/core/network/connection_checker.dart

```dart
import 'package:connectivity_plus/connectivity_plus.dart';

import '../errors/exceptions.dart';

/// فحص الاتصال بالإنترنت
abstract final class ConnectionChecker {
  /// هل يوجد اتصال بالإنترنت؟
  static Future<bool> get isConnected async {
    final results = await Connectivity().checkConnectivity();
    // connectivity_plus v6 يرجع List<ConnectivityResult>
    // لو فيه أي نتيجة غير none يبقى فيه اتصال
    return results.any((result) => result != ConnectivityResult.none);
  }

  /// يتأكد من وجود اتصال، لو مش موجود يرمي ServerException
  static Future<void> ensureConnection() async {
    final connected = await isConnected;
    if (!connected) {
      throw const ServerException(
        message: 'لا يوجد اتصال بالإنترنت',
        statusCode: 0,
      );
    }
  }
}
```

---

## lib/core/errors/exceptions.dart

```dart
/// استثناءes مخصصة للتطبيق

/// خطأ عام في قاعدة البيانات
class DatabaseException implements Exception {
  final String message;
  final int? errorCode;

  const DatabaseException({required this.message, this.errorCode});

  @override
  String toString() => 'DatabaseException: $message (code: $errorCode)';
}

/// عدم العثور على عنصر في قاعدة البيانات
class NotFoundException implements Exception {
  final String entityType;
  final String? id;

  const NotFoundException({required this.entityType, this.id});

  @override
  String toString() {
    if (id != null) {
      return 'NotFoundException: $entityType with id=$id not found';
    }
    return 'NotFoundException: $entityType not found';
  }
}

/// خطأ في التحقق من صحة البيانات
class ValidationException implements Exception {
  final String field;
  final String message;

  const ValidationException({required this.field, required this.message});

  @override
  String toString() => 'ValidationException: $field — $message';
}

/// خطأ في الاتصال بالخادم / الشبكة
class ServerException implements Exception {
  final String message;
  final int statusCode;

  const ServerException({required this.message, required this.statusCode});

  @override
  String toString() =>
      'ServerException: $message (status: $statusCode)';
}

/// خطأ غير متوقع
class AppException implements Exception {
  final String message;

  const AppException({required this.message});

  @override
  String toString() => 'AppException: $message';
}
```

---

## lib/core/database/database_helper.dart

```dart
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../constants/app_constants.dart';

/// مساعد قاعدة البيانات — Singleton
/// يدير إنشاء وتحديث قاعدة البيانات
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
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, AppConstants.dbName);
    return await openDatabase(
      path,
      version: AppConstants.dbVersion,
      onCreate: _onCreate,
      onOpen: _onOpen,
    );
  }

  Future<void> _onOpen(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  // ── Schema Creation ────────────────────────────────────────

  Future<void> _onCreate(Database db, int version) async {
    // 1. جدول الأشخاص
    await db.execute('''
      CREATE TABLE persons (
        id TEXT PRIMARY KEY NOT NULL,
        name TEXT NOT NULL,
        phone TEXT NOT NULL,
        category TEXT DEFAULT 'عميل',
        notes TEXT DEFAULT '',
        dateAdded TEXT NOT NULL,
        status TEXT DEFAULT 'active'
      )
    ''');

    // 2. جدول التصنيفات
    await db.execute('''
      CREATE TABLE categories (
        id TEXT PRIMARY KEY NOT NULL,
        name TEXT NOT NULL,
        type TEXT NOT NULL
      )
    ''');

    // 3. جدول الشغلانات
    await db.execute('''
      CREATE TABLE jobs (
        id TEXT PRIMARY KEY NOT NULL,
        name TEXT NOT NULL,
        customerId TEXT NOT NULL,
        workshop TEXT NOT NULL,
        productType TEXT DEFAULT '',
        agreedAmount REAL NOT NULL,
        notes TEXT DEFAULT '',
        status TEXT DEFAULT 'in_progress',
        startDate TEXT,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL,
        FOREIGN KEY (customerId) REFERENCES persons(id) ON DELETE CASCADE
      )
    ''');

    // 4. جدول الخامات (كيان ضعيف — جزء من الشغلانة)
    await db.execute('''
      CREATE TABLE job_materials (
        id TEXT NOT NULL,
        jobId TEXT NOT NULL,
        description TEXT NOT NULL,
        quantity REAL NOT NULL,
        unitCost REAL NOT NULL,
        totalCost REAL NOT NULL,
        PRIMARY KEY (id, jobId),
        FOREIGN KEY (jobId) REFERENCES jobs(id) ON DELETE CASCADE
      )
    ''');

    // 5. جدول المصنعيات (كيان ضعيف)
    await db.execute('''
      CREATE TABLE job_labor_items (
        id TEXT NOT NULL,
        jobId TEXT NOT NULL,
        description TEXT NOT NULL,
        cost REAL NOT NULL,
        PRIMARY KEY (id, jobId),
        FOREIGN KEY (jobId) REFERENCES jobs(id) ON DELETE CASCADE
      )
    ''');

    // 6. جدول التكاليف الأخرى (كيان ضعيف)
    await db.execute('''
      CREATE TABLE job_other_costs (
        id TEXT NOT NULL,
        jobId TEXT NOT NULL,
        description TEXT NOT NULL,
        cost REAL NOT NULL,
        PRIMARY KEY (id, jobId),
        FOREIGN KEY (jobId) REFERENCES jobs(id) ON DELETE CASCADE
      )
    ''');

    // 7. جدول دفعات الشغلانة (كيان ضعيف)
    await db.execute('''
      CREATE TABLE job_payments (
        id TEXT NOT NULL,
        jobId TEXT NOT NULL,
        date TEXT NOT NULL,
        amount REAL NOT NULL,
        PRIMARY KEY (id, jobId),
        FOREIGN KEY (jobId) REFERENCES jobs(id) ON DELETE CASCADE
      )
    ''');

    // 8. جدول المعاملات المالية للأشخاص (كيان ضعيف)
    await db.execute('''
      CREATE TABLE person_transactions (
        id TEXT NOT NULL,
        personId TEXT NOT NULL,
        type TEXT NOT NULL,
        amount REAL NOT NULL,
        date TEXT,
        description TEXT DEFAULT '',
        PRIMARY KEY (id, personId),
        FOREIGN KEY (personId) REFERENCES persons(id) ON DELETE CASCADE
      )
    ''');

    // 9. جدول واردات الخزنة
    await db.execute('''
      CREATE TABLE treasury_income (
        id TEXT PRIMARY KEY NOT NULL,
        date TEXT NOT NULL,
        amount REAL NOT NULL,
        description TEXT NOT NULL,
        category TEXT DEFAULT '',
        workshop TEXT DEFAULT 'عام',
        linkedJobId TEXT
      )
    ''');

    // 10. جدول مصروفات الخزنة
    await db.execute('''
      CREATE TABLE treasury_expenses (
        id TEXT PRIMARY KEY NOT NULL,
        date TEXT NOT NULL,
        amount REAL NOT NULL,
        description TEXT NOT NULL,
        category TEXT DEFAULT '',
        workshop TEXT DEFAULT 'عام',
        linkedJobId TEXT
      )
    ''');

    // 11. جدول دفتر الأستاذ
    await db.execute('''
      CREATE TABLE ledger_transactions (
        id TEXT PRIMARY KEY NOT NULL,
        date TEXT NOT NULL,
        amount REAL NOT NULL,
        type TEXT NOT NULL,
        personId TEXT,
        jobId TEXT,
        category TEXT,
        description TEXT,
        source TEXT NOT NULL
      )
    ''');

    // 12. جدول إعدادات التطبيق
    await db.execute('''
      CREATE TABLE settings (
        key TEXT PRIMARY KEY NOT NULL,
        value TEXT
      )
    ''');

    // ── Seed data — التصنيفات الافتراضية ──────────────────
    await _seedCategories(db);
  }

  Future<void> _seedCategories(Database db) async {
    final categories = [
      {'id': 'c1', 'name': 'كهرباء', 'type': 'expense'},
      {'id': 'c2', 'name': 'ميات', 'type': 'expense'},
      {'id': 'c3', 'name': 'إيجار', 'type': 'expense'},
      {'id': 'c4', 'name': 'رواتب', 'type': 'expense'},
      {'id': 'c5', 'name': 'نقل', 'type': 'expense'},
      {'id': 'c6', 'name': 'صيانة', 'type': 'expense'},
      {'id': 'c7', 'name': 'خامات', 'type': 'expense'},
      {'id': 'c8', 'name': 'دفعة عميل', 'type': 'income'},
      {'id': 'c9', 'name': 'عربون', 'type': 'income'},
      {'id': 'c10', 'name': 'إيراد منوع', 'type': 'income'},
      {'id': 'c11', 'name': 'أجرة نجار', 'type': 'labor'},
      {'id': 'c12', 'name': 'أجرة دهان', 'type': 'labor'},
      {'id': 'c13', 'name': 'أجرة تركيب', 'type': 'labor'},
      {'id': 'c14', 'name': 'أجرة عام', 'type': 'labor'},
    ];

    for (final cat in categories) {
      await db.insert('categories', cat);
    }
  }

  // ── Helper: توليد ID فريد ──────────────────────────────────

  /// توليد ID جديد باستخدام الوقت + عشوائي
  /// يطابق دالة uid() في الـ JavaScript
  static String nextPartialId() {
    final now = DateTime.now().millisecondsSinceEpoch;
    final random = (now.toRadixString(36) +
            (DateTime.now().microsecondsSinceEpoch % 100000).toRadixString(36))
        .substring(0, 10);
    return random;
  }
}
```

---

## ملاحظات التنفيذ

1. **pubspec.yaml** — أضف `google_fonts` بدل `tajawal` لأن `google_fonts` أسهل في الاستخدام
2. **database_helper.dart** — الـ `PRIMARY KEY (id, jobId)` في الكيانات الضعيفة هو الـ composite PK المطلوب
3. **connection_checker.dart** — يستخدم `connectivity_plus` v6 اللي يرجع `List<ConnectivityResult>`
4. **app_theme.dart** — يستخدم `GoogleFonts.tajawal()` مباشرة بدلاً من ملفات الخطوط المحلية
5. **app_colors.dart** — موجود بالفعل ولا يحتاج تغيير

## للتنفيذ اليدوي:
1. انسخ محتوى كل ملف واحفظه في المسار الصحيح
2. شغّل `flutter pub get`
3. شغّل `dart analyze` للتأكد من عدم وجود أخطاء
