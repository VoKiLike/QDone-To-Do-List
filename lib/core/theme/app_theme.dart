import 'package:flutter/material.dart';
import 'package:qdone/core/theme/app_colors.dart';
import 'package:qdone/core/theme/app_fonts.dart';

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
      dialogTheme: _dialogTheme(false),
      datePickerTheme: _datePickerTheme(false),
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
      dialogTheme: _dialogTheme(true),
      datePickerTheme: _datePickerTheme(true),
      inputDecorationTheme: _inputDecorationTheme(true),
    );
  }

  static TextTheme _textTheme(TextTheme base, Color color) {
    return base
        .apply(bodyColor: color, displayColor: color, fontFamily: AppFonts.text)
        .copyWith(
          headlineSmall: base.headlineSmall?.copyWith(
            fontFamily: AppFonts.text,
            fontWeight: FontWeight.w800,
            letterSpacing: 0,
          ),
          headlineMedium: base.headlineMedium?.copyWith(
            fontFamily: AppFonts.text,
            fontWeight: FontWeight.w800,
            letterSpacing: 0,
          ),
          titleLarge: base.titleLarge?.copyWith(
            fontFamily: AppFonts.text,
            fontWeight: FontWeight.w800,
            letterSpacing: 0,
          ),
          titleMedium: base.titleMedium?.copyWith(
            fontFamily: AppFonts.text,
            fontWeight: FontWeight.w700,
            letterSpacing: 0,
          ),
          labelLarge: base.labelLarge?.copyWith(
            fontFamily: AppFonts.text,
            fontWeight: FontWeight.w800,
            letterSpacing: 0,
          ),
          bodyMedium: base.bodyMedium?.copyWith(
            fontFamily: AppFonts.text,
            height: 1.42,
            letterSpacing: 0,
          ),
          bodySmall: base.bodySmall?.copyWith(
            fontFamily: AppFonts.text,
            height: 1.35,
            letterSpacing: 0,
          ),
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

  static DialogThemeData _dialogTheme(bool light) {
    final background = light ? Colors.white : const Color(0xFF11101B);
    return DialogThemeData(
      backgroundColor: background,
      surfaceTintColor: Colors.transparent,
      elevation: 18,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
    );
  }

  static DatePickerThemeData _datePickerTheme(bool light) {
    final background = light ? Colors.white : const Color(0xFF11101B);
    final headerBackground = light
        ? const Color(0xFFF3EFFF)
        : const Color(0xFF171326);
    final foreground = light ? const Color(0xFF15151F) : AppColors.white;
    final muted = light ? const Color(0xFF5F6474) : const Color(0xFFC8C6D6);
    final selectedForeground = Colors.white;

    return DatePickerThemeData(
      backgroundColor: background,
      surfaceTintColor: Colors.transparent,
      elevation: 18,
      shadowColor: Colors.black.withValues(alpha: light ? 0.14 : 0.46),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      headerBackgroundColor: headerBackground,
      headerForegroundColor: foreground,
      weekdayStyle: TextStyle(color: muted, fontWeight: FontWeight.w700),
      dayForegroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return selectedForeground;
        }
        if (states.contains(WidgetState.disabled)) {
          return muted.withValues(alpha: 0.42);
        }
        return foreground;
      }),
      dayBackgroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.violet;
        }
        if (states.contains(WidgetState.hovered) ||
            states.contains(WidgetState.focused) ||
            states.contains(WidgetState.pressed)) {
          return AppColors.violet.withValues(alpha: light ? 0.12 : 0.22);
        }
        return Colors.transparent;
      }),
      todayForegroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return selectedForeground;
        }
        return AppColors.cyan;
      }),
      todayBorder: const BorderSide(color: AppColors.cyan, width: 1.4),
      yearForegroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return selectedForeground;
        }
        if (states.contains(WidgetState.disabled)) {
          return muted.withValues(alpha: 0.42);
        }
        return foreground;
      }),
      yearBackgroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.violet;
        }
        return Colors.transparent;
      }),
      cancelButtonStyle: TextButton.styleFrom(
        foregroundColor: AppColors.neonPurple,
      ),
      confirmButtonStyle: TextButton.styleFrom(
        foregroundColor: AppColors.neonPurple,
      ),
    );
  }
}
