import 'package:flutter/material.dart';
import '/constants/colors.dart';

class AppTheme {
  static final ThemeData light = ThemeData(
    useMaterial3: true,

    // WARNA UTAMA APLIKASI
    colorScheme: ColorScheme.light(
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      tertiary: AppColors.accent,
    ),

    // WARNA LATAR BELAKANG
    scaffoldBackgroundColor: AppColors.background,
  );
}