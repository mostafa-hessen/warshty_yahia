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
