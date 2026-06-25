import 'package:flutter/material.dart';

// ============================================================
//  AppColors — مترجم من CSS variables في الـ HTML
//  كل لون له اسم واضح بيوصف وظيفته مش قيمته
// ============================================================

abstract final class AppColors {
  // ── Dark Mode ──────────────────────────────────────────────

  static const darkBgPrimary   = Color(0xFF0A0F1A);
  static const darkBgSecondary = Color(0xFF111827);
  static const darkBgCard      = Color(0xFF1A2235);
  static const darkBgCardHover = Color(0xFF222D42);

  static const darkTextPrimary   = Color(0xFFF0F4F8);
  static const darkTextSecondary = Color(0xFF8892A4);
  static const darkTextMuted     = Color(0xFF5A6478);

  static const darkBorder = Color(0xFF2A3548);

  // ── Light Mode ─────────────────────────────────────────────

  static const lightBgPrimary   = Color(0xFFF0F4F0);
  static const lightBgSecondary = Color(0xFFFFFFFF);
  static const lightBgCard      = Color(0xFFFFFFFF);
  static const lightBgCardHover = Color(0xFFE8F5F2);

  static const lightTextPrimary   = Color(0xFF0D1F1A);
  static const lightTextSecondary = Color(0xFF3D5A52);
  static const lightTextMuted     = Color(0xFF7A9990);

  static const lightBorder = Color(0xFFC5DDD8);

  // ── Accent ─────────────────────────────────────────────────

  static const darkAccent  = Color(0xFF00D4AA);
  static const lightAccent = Color(0xFF008A6E);

  static const darkAccentGlow  = Color(0x4D00D4AA);
  static const lightAccentGlow = Color(0x40008A6E);

  // ── Semantic ───────────────────────────────────────────────

  static const success = Color(0xFF10B981);
  static const warning = Color(0xFFF59E0B);
  static const danger  = Color(0xFFEF4444);
  static const info    = Color(0xFF3B82F6);
  static const purple  = Color(0xFF8B5CF6);

  static const successLight = Color(0xFF059669);
  static const warningLight = Color(0xFFB45309);
  static const dangerLight  = Color(0xFFDC2626);
  static const infoLight    = Color(0xFF1D4ED8);
  static const purpleLight  = Color(0xFF7C3AED);

  // ── Logo / Overlay ─────────────────────────────────────────
  static const logoSienna = Color(0xFFA0522D);
  static const modalOverlay = Color(0xB3000000);
}

// ═══════════════════════════════════════════════════════════════
//  Theme-aware color helpers
//  استخدمها في الـ Widgets عشان تختار اللون الصح حسب الثيم
//  example: context.bgCard  ← يرجع lightBgCard أو darkBgCard
// ═══════════════════════════════════════════════════════════════

extension AppColorsX on BuildContext {
  bool get _isDark => Theme.of(this).brightness == Brightness.dark;

  Color get bgPrimary   => _isDark ? AppColors.darkBgPrimary   : AppColors.lightBgPrimary;
  Color get bgSecondary => _isDark ? AppColors.darkBgSecondary : AppColors.lightBgSecondary;
  Color get bgCard      => _isDark ? AppColors.darkBgCard      : AppColors.lightBgCard;
  Color get bgCardHover => _isDark ? AppColors.darkBgCardHover : AppColors.lightBgCardHover;

  Color get textPrimary   => _isDark ? AppColors.darkTextPrimary   : AppColors.lightTextPrimary;
  Color get textSecondary => _isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
  Color get textMuted     => _isDark ? AppColors.darkTextMuted     : AppColors.lightTextMuted;

  Color get borderColor => _isDark ? AppColors.darkBorder : AppColors.lightBorder;

  Color get accentColor    => _isDark ? AppColors.darkAccent  : AppColors.lightAccent;
  Color get accentGlow     => _isDark ? AppColors.darkAccentGlow  : AppColors.lightAccentGlow;
}
