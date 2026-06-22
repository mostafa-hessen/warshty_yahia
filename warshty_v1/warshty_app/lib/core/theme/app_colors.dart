import 'package:flutter/material.dart';

// ============================================================
//  AppColors — مترجم من CSS variables في الـ HTML
//  كل لون له اسم واضح بيوصف وظيفته مش قيمته
// ============================================================

abstract final class AppColors {
  // ── Dark Mode ──────────────────────────────────────────────

  // خلفيات
  static const darkBgPrimary   = Color(0xFF0A0F1A); // --bg-primary
  static const darkBgSecondary = Color(0xFF111827); // --bg-secondary (modal)
  static const darkBgCard      = Color(0xFF1A2235); // --bg-card
  static const darkBgCardHover = Color(0xFF222D42); // --bg-card-hover

  // نصوص
  static const darkTextPrimary   = Color(0xFFF0F4F8); // --text-primary
  static const darkTextSecondary = Color(0xFF8892A4); // --text-secondary
  static const darkTextMuted     = Color(0xFF5A6478); // --text-muted

  // حدود
  static const darkBorder = Color(0xFF2A3548); // --border

  // ── Light Mode ─────────────────────────────────────────────

  static const lightBgPrimary   = Color(0xFFF0F4F0);
  static const lightBgSecondary = Color(0xFFFFFFFF);
  static const lightBgCard      = Color(0xFFFFFFFF);
  static const lightBgCardHover = Color(0xFFE8F5F2);

  static const lightTextPrimary   = Color(0xFF0D1F1A);
  static const lightTextSecondary = Color(0xFF3D5A52);
  static const lightTextMuted     = Color(0xFF7A9990);

  static const lightBorder = Color(0xFFC5DDD8);

  // ── Accent (اللون الرئيسي) ─────────────────────────────────
  // بيتغير بين dark و light

  static const darkAccent  = Color(0xFF00D4AA); // --accent dark
  static const lightAccent = Color(0xFF008A6E); // --accent light

  // Glow بتاع الـ accent (للـ BoxShadow)
  static const darkAccentGlow  = Color(0x4D00D4AA); // rgba(0,212,170,.3)
  static const lightAccentGlow = Color(0x40008A6E); // rgba(0,138,110,.25)

  // ── Semantic Colors (نفسهم في dark و light) ────────────────

  static const success = Color(0xFF10B981); // --success  (أخضر)
  static const warning = Color(0xFFF59E0B); // --warning  (برتقالي)
  static const danger  = Color(0xFFEF4444); // --danger   (أحمر)
  static const info    = Color(0xFF3B82F6); // --info     (أزرق)
  static const purple  = Color(0xFF8B5CF6); // --purple

  // light mode بيغير success/warning/danger شوية
  static const successLight = Color(0xFF059669);
  static const warningLight = Color(0xFFB45309);
  static const dangerLight  = Color(0xFFDC2626);
  static const infoLight    = Color(0xFF1D4ED8);
  static const purpleLight  = Color(0xFF7C3AED);

  // ── Logo gradient ──────────────────────────────────────────
  static const logoSienna = Color(0xFFA0522D); // اللون البني في الـ logo

  // ── Overlay ───────────────────────────────────────────────
  static const modalOverlay = Color(0xB3000000); // rgba(0,0,0,.7)
}