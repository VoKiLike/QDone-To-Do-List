import 'package:flutter/material.dart';
import 'package:flutter_to_do_list_app/core/theme/app_colors.dart';

class AppTheme {
  const AppTheme._();

  static ThemeData dark() {
    final base = ThemeData.dark(useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: AppColors.darkVoid,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.violet,
        secondary: AppColors.cyan,
        tertiary: AppColors.turquoise,
        surface: AppColors.darkPanel,
        error: AppColors.warning,
      ),
      textTheme: _textTheme(base.textTheme, AppColors.white),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Colors.transparent,
        modalBackgroundColor: Colors.transparent,
      ),
      inputDecorationTheme: _inputDecorationTheme(false),
    );
  }

  static ThemeData light() {
    final base = ThemeData.light(useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: const Color(0xFFF8FAFC),
      colorScheme: const ColorScheme.light(
        primary: AppColors.violet,
        secondary: AppColors.turquoise,
        tertiary: AppColors.cyan,
        surface: AppColors.softWhite,
        error: AppColors.warning,
      ),
      textTheme: _textTheme(base.textTheme, const Color(0xFF15151F)),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Colors.transparent,
        modalBackgroundColor: Colors.transparent,
      ),
      inputDecorationTheme: _inputDecorationTheme(true),
    );
  }

  static TextTheme _textTheme(TextTheme base, Color color) {
    return base
        .apply(bodyColor: color, displayColor: color, fontFamily: 'Roboto')
        .copyWith(
          headlineMedium: base.headlineMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
          titleLarge: base.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          titleMedium: base.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          bodyMedium: base.bodyMedium?.copyWith(height: 1.42),
        );
  }

  static InputDecorationTheme _inputDecorationTheme(bool light) {
    return InputDecorationTheme(
      filled: true,
      fillColor: light
          ? Colors.white.withValues(alpha: 0.8)
          : Colors.white.withValues(alpha: 0.08),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(
          color: Colors.white.withValues(alpha: light ? 0.45 : 0.14),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(
          color: Colors.white.withValues(alpha: light ? 0.55 : 0.12),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: AppColors.cyan, width: 1.4),
      ),
    );
  }
}
