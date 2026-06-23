import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../storage/app_prefs.dart';

class ThemeCubit extends Cubit<ThemeMode> {
  final AppPrefs _appPrefs;

  ThemeCubit(this._appPrefs) : super(_appPrefs.getThemeMode());

  void toggleTheme() {
    final newMode = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    _appPrefs.setThemeMode(newMode);
    emit(newMode);
  }
}
