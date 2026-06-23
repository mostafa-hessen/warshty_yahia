import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service layer فوق SharedPreferences
/// يوفر واجهة نوعية لقراءة/كتابة الإعدادات
class AppPrefs {
  static const _themeModeKey = 'theme_mode';

  final SharedPreferences _prefs;

  AppPrefs(this._prefs);

  // ── Theme ───────────────────────────────────────────────────
  ThemeMode getThemeMode() {
    final value = _prefs.getString(_themeModeKey);
    return value == 'light' ? ThemeMode.light : ThemeMode.dark;
  }

  Future<void> setThemeMode(ThemeMode mode) {
    return _prefs.setString(
      _themeModeKey,
      mode == ThemeMode.dark ? 'dark' : 'light',
    );
  }
}
