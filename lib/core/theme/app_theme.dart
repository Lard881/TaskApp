import 'package:flutter/material.dart';
import 'package:planpal/core/constants/app_colors.dart';
import 'package:planpal/core/constants/app_sizes.dart';

/// Static [ThemeData] instances for light and dark modes.
/// The root [MaterialApp] switches between these based on [AppPreferences.themeMode].
abstract final class AppTheme {
  // ── Light theme ───────────────────────────────────────────────────────────

  static final ThemeData light = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.light,
    ).copyWith(
      primary: AppColors.primary,
      surface: AppColors.lightSurface,
      error: AppColors.error,
    ),
    scaffoldBackgroundColor: AppColors.lightBackground,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.lightSurface,
      foregroundColor: AppColors.lightOnSurface,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        color: AppColors.lightOnSurface,
        fontSize: AppSizes.fontTitle,
        fontWeight: FontWeight.w700,
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.lightSurface,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.lightOnSurfaceMuted,
      selectedLabelStyle: TextStyle(
        fontSize: AppSizes.fontSmall,
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelStyle: TextStyle(
        fontSize: AppSizes.fontSmall,
      ),
      showSelectedLabels: true,
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),
    cardTheme: CardThemeData(
      color: AppColors.lightSurface,
      elevation: AppSizes.cardElevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.lightBackground,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
        borderSide: const BorderSide(color: AppColors.divider),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
        borderSide: const BorderSide(color: AppColors.divider),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
        borderSide: const BorderSide(color: AppColors.error),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSizes.spaceM,
        vertical: AppSizes.spaceM,
      ),
      labelStyle: const TextStyle(color: AppColors.lightOnSurfaceMuted),
      hintStyle: const TextStyle(color: AppColors.lightOnSurfaceMuted),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        minimumSize: const Size(0, AppSizes.minTouchTarget),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusM),
        ),
        textStyle: const TextStyle(
          fontSize: AppSizes.fontBody,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primary,
        minimumSize: const Size(0, AppSizes.minTouchTarget),
        textStyle: const TextStyle(
          fontSize: AppSizes.fontBody,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
    ),
    dividerTheme: const DividerThemeData(
      color: AppColors.divider,
      thickness: AppSizes.dividerThickness,
      space: 0,
    ),
    chipTheme: ChipThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusFull),
      ),
    ),
    textTheme: _textTheme(AppColors.lightOnSurface),
    iconTheme: const IconThemeData(color: AppColors.lightOnSurface),
  );

  // ── Dark theme ────────────────────────────────────────────────────────────

  static final ThemeData dark = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.dark,
    ).copyWith(
      primary: AppColors.primary,
      surface: AppColors.darkSurface,
      error: AppColors.error,
    ),
    scaffoldBackgroundColor: AppColors.darkBackground,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.darkSurface,
      foregroundColor: AppColors.darkOnSurface,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        color: AppColors.darkOnSurface,
        fontSize: AppSizes.fontTitle,
        fontWeight: FontWeight.w700,
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.darkSurface,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.darkOnSurfaceMuted,
      selectedLabelStyle: TextStyle(
        fontSize: AppSizes.fontSmall,
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelStyle: TextStyle(
        fontSize: AppSizes.fontSmall,
      ),
      showSelectedLabels: true,
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),
    cardTheme: CardThemeData(
      color: AppColors.darkSurface,
      elevation: AppSizes.cardElevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.darkBackground,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.15)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.15)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
        borderSide: const BorderSide(color: AppColors.error),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSizes.spaceM,
        vertical: AppSizes.spaceM,
      ),
      labelStyle: const TextStyle(color: AppColors.darkOnSurfaceMuted),
      hintStyle: const TextStyle(color: AppColors.darkOnSurfaceMuted),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        minimumSize: const Size(0, AppSizes.minTouchTarget),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusM),
        ),
        textStyle: const TextStyle(
          fontSize: AppSizes.fontBody,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primaryMuted,
        minimumSize: const Size(0, AppSizes.minTouchTarget),
        textStyle: const TextStyle(
          fontSize: AppSizes.fontBody,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
    ),
    dividerTheme: DividerThemeData(
      color: Colors.white.withOpacity(0.12),
      thickness: AppSizes.dividerThickness,
      space: 0,
    ),
    chipTheme: ChipThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusFull),
      ),
    ),
    textTheme: _textTheme(AppColors.darkOnSurface),
    iconTheme: const IconThemeData(color: AppColors.darkOnSurface),
  );

  // ── Shared text theme ─────────────────────────────────────────────────────

  static TextTheme _textTheme(Color baseColor) => TextTheme(
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w800,
          color: baseColor,
        ),
        titleLarge: TextStyle(
          fontSize: AppSizes.fontTitle,
          fontWeight: FontWeight.w700,
          color: baseColor,
        ),
        titleMedium: TextStyle(
          fontSize: AppSizes.fontHeading,
          fontWeight: FontWeight.w600,
          color: baseColor,
        ),
        bodyLarge: TextStyle(
          fontSize: AppSizes.fontBody,
          fontWeight: FontWeight.w400,
          color: baseColor,
        ),
        bodyMedium: TextStyle(
          fontSize: AppSizes.fontBody,
          color: baseColor,
        ),
        bodySmall: TextStyle(
          fontSize: AppSizes.fontSmall,
          color: baseColor,
        ),
        labelSmall: TextStyle(
          fontSize: AppSizes.fontSmall,
          fontWeight: FontWeight.w500,
          color: baseColor,
        ),
      );
}
