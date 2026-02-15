import 'package:flutter/material.dart';

class AppThemeColors {
  static const Color background = Color(0xFF0B0B0D);
  static const Color backgroundAlt = Color(0xFF101015);
  static const Color surface = Color(0xFF141418);
  static const Color border = Color(0xFF232329);
  static const Color inputBackground = Color(0xFF1C1C21);
  static const Color inputBorder = Color(0xFF2D2D35);
  static const Color textMain = Color(0xFFF5F6F7);
  static const Color textSecondary = Color(0xFFB8BBC2);
  static const Color primary = Color(0xFFB79BFF);
  static const Color primaryDark = Color(0xFF9775EA);
  static const Color error = Color(0xFFE35D6A);
  static const Color errorText = Color(0xFFF3C4CB);
}

class AppSpacing {
  static const double xxs = 8;
  static const double xs = 12;
  static const double sm = 14;
  static const double md = 16;
  static const double lg = 20;
  static const double xl = 24;
  static const double xxl = 28;
  static const double xxxl = 30;
}

class AppRadius {
  static const double sm = 10;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
}

class AppTheme {
  static ThemeData get dark {
    final colorScheme =
        ColorScheme.fromSeed(
          seedColor: AppThemeColors.primary,
          brightness: Brightness.dark,
        ).copyWith(
          primary: AppThemeColors.primary,
          onPrimary: const Color(0xFF222026),
          surface: AppThemeColors.surface,
          onSurface: AppThemeColors.textMain,
          error: AppThemeColors.error,
          onError: AppThemeColors.errorText,
        );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppThemeColors.background,
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppThemeColors.inputBackground,
        labelStyle: const TextStyle(
          color: AppThemeColors.textMain,
          fontWeight: FontWeight.w700,
          fontSize: 14,
        ),
        hintStyle: const TextStyle(
          color: AppThemeColors.textSecondary,
          fontSize: 15,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppThemeColors.inputBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppThemeColors.inputBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppThemeColors.primary),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppThemeColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppThemeColors.error),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppThemeColors.primary,
          foregroundColor: const Color(0xFF222026),
          disabledBackgroundColor: AppThemeColors.primary.withValues(
            alpha: 0.5,
          ),
          minimumSize: const Size.fromHeight(56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
      textTheme: const TextTheme(
        headlineMedium: TextStyle(
          color: AppThemeColors.textMain,
          fontSize: 30,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.4,
        ),
        bodyMedium: TextStyle(
          color: AppThemeColors.textSecondary,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
