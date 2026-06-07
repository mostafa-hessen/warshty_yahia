import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors extends ThemeExtension<AppColors> {
  // Dark mode
  final Color bgPrimary;
  final Color bgSecondary;
  final Color bgCard;
  final Color bgCardHover;
  final Color accent;
  final Color accentGlow;
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;
  final Color border;
  final Color success;
  final Color warning;
  final Color danger;
  final Color info;
  final Color purple;

  const AppColors({
    required this.bgPrimary,
    required this.bgSecondary,
    required this.bgCard,
    required this.bgCardHover,
    required this.accent,
    required this.accentGlow,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.border,
    required this.success,
    required this.warning,
    required this.danger,
    required this.info,
    required this.purple,
  });

  static const dark = AppColors(
    bgPrimary: Color(0xFF0a0f1a),
    bgSecondary: Color(0xFF111827),
    bgCard: Color(0xFF1a2235),
    bgCardHover: Color(0xFF222d42),
    accent: Color(0xFF00d4aa),
    accentGlow: Color(0x4D00d4aa),
    textPrimary: Color(0xFFf0f4f8),
    textSecondary: Color(0xFF8892a4),
    textMuted: Color(0xFF5a6478),
    border: Color(0xFF2a3548),
    success: Color(0xFF10b981),
    warning: Color(0xFFf59e0b),
    danger: Color(0xFFef4444),
    info: Color(0xFF3b82f6),
    purple: Color(0xFF8b5cf6),
  );

  static const light = AppColors(
    bgPrimary: Color(0xFFf0f4f0),
    bgSecondary: Color(0xFFffffff),
    bgCard: Color(0xFFffffff),
    bgCardHover: Color(0xFFe8f5f2),
    accent: Color(0xFF008a6e),
    accentGlow: Color(0x40008a6e),
    textPrimary: Color(0xFF0d1f1a),
    textSecondary: Color(0xFF3d5a52),
    textMuted: Color(0xFF7a9990),
    border: Color(0xFFc5ddd8),
    success: Color(0xFF059669),
    warning: Color(0xFFb45309),
    danger: Color(0xFFdc2626),
    info: Color(0xFF1d4ed8),
    purple: Color(0xFF7c3aed),
  );

  @override
  AppColors copyWith({
    Color? bgPrimary,
    Color? bgSecondary,
    Color? bgCard,
    Color? bgCardHover,
    Color? accent,
    Color? accentGlow,
    Color? textPrimary,
    Color? textSecondary,
    Color? textMuted,
    Color? border,
    Color? success,
    Color? warning,
    Color? danger,
    Color? info,
    Color? purple,
  }) {
    return AppColors(
      bgPrimary: bgPrimary ?? this.bgPrimary,
      bgSecondary: bgSecondary ?? this.bgSecondary,
      bgCard: bgCard ?? this.bgCard,
      bgCardHover: bgCardHover ?? this.bgCardHover,
      accent: accent ?? this.accent,
      accentGlow: accentGlow ?? this.accentGlow,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textMuted: textMuted ?? this.textMuted,
      border: border ?? this.border,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      danger: danger ?? this.danger,
      info: info ?? this.info,
      purple: purple ?? this.purple,
    );
  }

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;
    return AppColors(
      bgPrimary: Color.lerp(bgPrimary, other.bgPrimary, t)!,
      bgSecondary: Color.lerp(bgSecondary, other.bgSecondary, t)!,
      bgCard: Color.lerp(bgCard, other.bgCard, t)!,
      bgCardHover: Color.lerp(bgCardHover, other.bgCardHover, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      accentGlow: Color.lerp(accentGlow, other.accentGlow, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      border: Color.lerp(border, other.border, t)!,
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
      info: Color.lerp(info, other.info, t)!,
      purple: Color.lerp(purple, other.purple, t)!,
    );
  }
}

// Extension for easy access: context.colors
extension ThemeColors on BuildContext {
  AppColors get colors => Theme.of(this).extension<AppColors>()!;
}

ThemeData _baseTheme(Brightness brightness, AppColors appColors) {
  return ThemeData(
    brightness: brightness,
    colorScheme: ColorScheme(
      brightness: brightness,
      primary: appColors.accent,
      secondary: appColors.accent,
      surface: appColors.bgSecondary,
      error: appColors.danger,
      onPrimary: appColors.textPrimary,
      onSecondary: appColors.textPrimary,
      onSurface: appColors.textPrimary,
      onError: Colors.white,
    ),
    scaffoldBackgroundColor: appColors.bgPrimary,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
    ),
    cardTheme: CardThemeData(
      color: appColors.bgCard,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: appColors.border),
      ),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: appColors.bgSecondary,
      selectedItemColor: appColors.accent,
      unselectedItemColor: appColors.textMuted,
      type: BottomNavigationBarType.fixed,
    ),
    dividerTheme: DividerThemeData(color: appColors.border),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: appColors.bgCard,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: appColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: appColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: appColors.accent, width: 2),
      ),
      labelStyle: TextStyle(color: appColors.textSecondary),
      hintStyle: TextStyle(color: appColors.textMuted),
    ),
    textTheme: GoogleFonts.tajawalTextTheme(
      TextTheme(
        headlineLarge: TextStyle(
          color: appColors.textPrimary,
          fontSize: 24,
          fontWeight: FontWeight.w800,
        ),
        headlineMedium: TextStyle(
          color: appColors.textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
        titleLarge: TextStyle(
          color: appColors.textPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w700,
        ),
        titleMedium: TextStyle(
          color: appColors.textPrimary,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: TextStyle(color: appColors.textPrimary, fontSize: 15),
        bodyMedium: TextStyle(color: appColors.textSecondary, fontSize: 13),
        bodySmall: TextStyle(color: appColors.textMuted, fontSize: 11),
        labelLarge: TextStyle(
          color: appColors.accent,
          fontSize: 16,
          fontWeight: FontWeight.w800,
        ),
      ),
    ),
    extensions: [appColors],
  );
}

class AppTheme {
  static final darkTheme = _baseTheme(Brightness.dark, AppColors.dark);
  static final lightTheme = _baseTheme(Brightness.light, AppColors.light);
}
