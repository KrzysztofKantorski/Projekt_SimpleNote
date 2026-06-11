import 'AppButtons.dart';
import 'AppColors.dart';
import 'AppText.dart';
import 'package:flutter/material.dart';
class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.grey).copyWith(
          primary: Colors.black, 
      ),
      useMaterial3: true,
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.background,
      textTheme: TextTheme(
        headlineLarge: AppText.heading1,
        headlineMedium: AppText.heading2,
        bodyMedium: AppText.body,
        bodySmall: AppText.caption,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(style: AppButtons.primaryButton),
      outlinedButtonTheme: OutlinedButtonThemeData(style: AppButtons.secondaryButton),
    );
  }
}