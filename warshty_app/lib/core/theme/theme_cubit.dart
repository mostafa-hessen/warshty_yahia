import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'app_theme.dart';

class ThemeCubit extends Cubit<ThemeData> {
  ThemeCubit() : super(AppTheme.darkTheme);

  bool get isDark => state == AppTheme.darkTheme;

  void toggleTheme() {
    emit(isDark ? AppTheme.lightTheme : AppTheme.darkTheme);
  }

  void setDark() => emit(AppTheme.darkTheme);
  void setLight() => emit(AppTheme.lightTheme);
}
