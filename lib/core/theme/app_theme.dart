import 'package:flutter/material.dart';
import 'package:lengoal/core/theme/app_colors.dart';
import 'package:lengoal/core/theme/app_spacing.dart';
import 'package:lengoal/core/theme/app_text_styles.dart';

class AppTheme {
  const new();

  static ThemeData get light => _themeFor(brightness: Brightness.light);
  static ThemeData get dark => _themeFor(brightness: Brightness.dark);

  static ThemeData _themeFor({required Brightness brightness}) {
    final isDark = brightness == Brightness.dark;
    final colorScheme =
        ColorScheme.fromSeed(
          seedColor: AppColors.brandPrimary,
          brightness: brightness,
        ).copyWith(
          primary: AppColors.brandPrimary,
          onPrimary: Colors.white,
          surface: isDark ? null : Colors.white,
        );

    final base = ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      fontFamily: AppTextStyles.bodyFamily,
      scaffoldBackgroundColor: isDark
          ? AppColors.darkBackground
          : AppColors.lightBackground,
      dialogTheme: DialogThemeData(
        backgroundColor: isDark ? null : Colors.white,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        centerTitle: true,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? colorScheme.surface : Colors.white,
        contentPadding: const EdgeInsets.only(
          left: AppSpacing.s16,
          right: AppSpacing.s24,
          top: AppSpacing.s16,
          bottom: AppSpacing.s16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
          borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
          borderSide: BorderSide(color: colorScheme.error, width: 1.5),
        ),
        hintStyle: AppTextStyles.body.copyWith(
          color: colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.brandPrimary,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(55),
          shape: const StadiumBorder(),
          textStyle: AppTextStyles.button,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colorScheme.onSurface,
          minimumSize: const Size.fromHeight(55),
          shape: StadiumBorder(
            side: BorderSide(color: colorScheme.outlineVariant),
          ),
          textStyle: AppTextStyles.button,
        ),
      ),
      checkboxTheme: CheckboxThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.r4),
        ),
        side: const BorderSide(
          color: AppColors.borderGray200,
          width: AppSpacing.s2,
        ),
        fillColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? AppColors.brandPrimary
              : Colors.transparent,
        ),
      ),
    );

    return base.copyWith(
      textTheme: base.textTheme
          .copyWith(
            headlineMedium: AppTextStyles.h1,
            headlineSmall: AppTextStyles.h2,
            titleLarge: AppTextStyles.h3,
            titleMedium: AppTextStyles.h4,
            bodyLarge: AppTextStyles.body,
            bodyMedium: AppTextStyles.bodySecondary,
            labelLarge: AppTextStyles.button,
            bodySmall: AppTextStyles.caption,
          )
          .apply(
            bodyColor: colorScheme.onSurface,
            displayColor: colorScheme.onSurface,
          ),
    );
  }
}
