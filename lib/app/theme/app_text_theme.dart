import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_typography.dart';

class AppTextTheme {
  AppTextTheme._();

  // ============================================================
  // Light Theme
  // ============================================================

  static TextTheme get light {
    return TextTheme(
      // Display
      displayLarge: const TextStyle(
        fontFamily: AppTypography.fontFamily,
        fontSize: 57,
        fontWeight: AppTypography.bold,
        color: AppColors.lightText,
        letterSpacing: -0.25,
      ),
      displayMedium: const TextStyle(
        fontFamily: AppTypography.fontFamily,
        fontSize: 45,
        fontWeight: AppTypography.bold,
        color: AppColors.lightText,
      ),
      displaySmall: const TextStyle(
        fontFamily: AppTypography.fontFamily,
        fontSize: 36,
        fontWeight: AppTypography.bold,
        color: AppColors.lightText,
      ),

      // Headlines
      headlineLarge: const TextStyle(
        fontFamily: AppTypography.fontFamily,
        fontSize: 32,
        fontWeight: AppTypography.bold,
        color: AppColors.lightText,
      ),
      headlineMedium: const TextStyle(
        fontFamily: AppTypography.fontFamily,
        fontSize: 28,
        fontWeight: AppTypography.semiBold,
        color: AppColors.lightText,
      ),
      headlineSmall: const TextStyle(
        fontFamily: AppTypography.fontFamily,
        fontSize: 24,
        fontWeight: AppTypography.semiBold,
        color: AppColors.lightText,
      ),

      // Titles
      titleLarge: const TextStyle(
        fontFamily: AppTypography.fontFamily,
        fontSize: 22,
        fontWeight: AppTypography.semiBold,
        color: AppColors.lightText,
      ),
      titleMedium: const TextStyle(
        fontFamily: AppTypography.fontFamily,
        fontSize: 16,
        fontWeight: AppTypography.semiBold,
        color: AppColors.lightText,
        letterSpacing: 0.15,
      ),
      titleSmall: const TextStyle(
        fontFamily: AppTypography.fontFamily,
        fontSize: 14,
        fontWeight: AppTypography.semiBold,
        color: AppColors.lightText,
        letterSpacing: 0.1,
      ),

      // Body
      bodyLarge: const TextStyle(
        fontFamily: AppTypography.fontFamily,
        fontSize: 16,
        fontWeight: AppTypography.regular,
        color: AppColors.lightText,
        letterSpacing: 0.15,
      ),
      bodyMedium: const TextStyle(
        fontFamily: AppTypography.fontFamily,
        fontSize: 14,
        fontWeight: AppTypography.regular,
        color: AppColors.lightSubtitle,
        letterSpacing: 0.25,
      ),
      bodySmall: const TextStyle(
        fontFamily: AppTypography.fontFamily,
        fontSize: 12,
        fontWeight: AppTypography.regular,
        color: AppColors.lightSubtitle,
        letterSpacing: 0.4,
      ),

      // Labels
      labelLarge: const TextStyle(
        fontFamily: AppTypography.fontFamily,
        fontSize: 14,
        fontWeight: AppTypography.semiBold,
        color: AppColors.lightText,
        letterSpacing: 0.1,
      ),
      labelMedium: const TextStyle(
        fontFamily: AppTypography.fontFamily,
        fontSize: 12,
        fontWeight: AppTypography.medium,
        color: AppColors.lightSubtitle,
        letterSpacing: 0.5,
      ),
      labelSmall: const TextStyle(
        fontFamily: AppTypography.fontFamily,
        fontSize: 11,
        fontWeight: AppTypography.medium,
        color: AppColors.lightSubtitle,
        letterSpacing: 0.5,
      ),
    );
  }

  // ============================================================
  // Dark Theme
  // ============================================================

  static TextTheme get dark {
    return TextTheme(
      // Display
      displayLarge: const TextStyle(
        fontFamily: AppTypography.fontFamily,
        fontSize: 57,
        fontWeight: AppTypography.bold,
        color: AppColors.darkText,
        letterSpacing: -0.25,
      ),
      displayMedium: const TextStyle(
        fontFamily: AppTypography.fontFamily,
        fontSize: 45,
        fontWeight: AppTypography.bold,
        color: AppColors.darkText,
      ),
      displaySmall: const TextStyle(
        fontFamily: AppTypography.fontFamily,
        fontSize: 36,
        fontWeight: AppTypography.bold,
        color: AppColors.darkText,
      ),

      // Headlines
      headlineLarge: const TextStyle(
        fontFamily: AppTypography.fontFamily,
        fontSize: 32,
        fontWeight: AppTypography.bold,
        color: AppColors.darkText,
      ),
      headlineMedium: const TextStyle(
        fontFamily: AppTypography.fontFamily,
        fontSize: 28,
        fontWeight: AppTypography.semiBold,
        color: AppColors.darkText,
      ),
      headlineSmall: const TextStyle(
        fontFamily: AppTypography.fontFamily,
        fontSize: 24,
        fontWeight: AppTypography.semiBold,
        color: AppColors.darkText,
      ),

      // Titles
      titleLarge: const TextStyle(
        fontFamily: AppTypography.fontFamily,
        fontSize: 22,
        fontWeight: AppTypography.semiBold,
        color: AppColors.darkText,
      ),
      titleMedium: const TextStyle(
        fontFamily: AppTypography.fontFamily,
        fontSize: 16,
        fontWeight: AppTypography.semiBold,
        color: AppColors.darkText,
        letterSpacing: 0.15,
      ),
      titleSmall: const TextStyle(
        fontFamily: AppTypography.fontFamily,
        fontSize: 14,
        fontWeight: AppTypography.semiBold,
        color: AppColors.darkText,
        letterSpacing: 0.1,
      ),

      // Body
      bodyLarge: const TextStyle(
        fontFamily: AppTypography.fontFamily,
        fontSize: 16,
        fontWeight: AppTypography.regular,
        color: AppColors.darkText,
        letterSpacing: 0.15,
      ),
      bodyMedium: const TextStyle(
        fontFamily: AppTypography.fontFamily,
        fontSize: 14,
        fontWeight: AppTypography.regular,
        color: AppColors.darkSubtitle,
        letterSpacing: 0.25,
      ),
      bodySmall: const TextStyle(
        fontFamily: AppTypography.fontFamily,
        fontSize: 12,
        fontWeight: AppTypography.regular,
        color: AppColors.darkSubtitle,
        letterSpacing: 0.4,
      ),

      // Labels
      labelLarge: const TextStyle(
        fontFamily: AppTypography.fontFamily,
        fontSize: 14,
        fontWeight: AppTypography.semiBold,
        color: AppColors.darkText,
        letterSpacing: 0.1,
      ),
      labelMedium: const TextStyle(
        fontFamily: AppTypography.fontFamily,
        fontSize: 12,
        fontWeight: AppTypography.medium,
        color: AppColors.darkSubtitle,
        letterSpacing: 0.5,
      ),
      labelSmall: const TextStyle(
        fontFamily: AppTypography.fontFamily,
        fontSize: 11,
        fontWeight: AppTypography.medium,
        color: AppColors.darkSubtitle,
        letterSpacing: 0.5,
      ),
    );
  }
}
