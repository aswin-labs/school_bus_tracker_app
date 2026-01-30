import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppTheme {
  static final light = ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: AppColors.background,
    brightness: Brightness.light,
    colorScheme: const ColorScheme(
      brightness: Brightness.light,
      primary: AppColors.primary,
      onPrimary: Colors.white,

      secondary: AppColors.primary,
      onSecondary: Colors.white,

      surface: AppColors.card,
      onSurface: Colors.black,

      error: AppColors.error,
      onError: Colors.white,
    ),
  );

  static final dark = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme(
      brightness: Brightness.dark,
      primary: AppColors.primary,
      onPrimary: Colors.black,

      secondary: AppColors.primary,
      onSecondary: Colors.black,

      surface: Colors.grey.shade900,
      onSurface: Colors.white,

      error: AppColors.error,
      onError: Colors.black,
    ),
  );
}
