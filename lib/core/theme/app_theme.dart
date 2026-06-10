import 'package:flutter/material.dart';
import 'package:qdone/core/theme/app_colors.dart';
import 'package:qdone/core/theme/app_fonts.dart';

class AppTheme {
  const AppTheme._();

  static ThemeData dark() {
    final base = ThemeData.dark(useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: AppColors.darkVoid,
      splashFactory: NoSplash.splashFactory,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.electricBlue,
        secondary: AppColors.electricViolet,
        tertiary: AppColors.magenta,
        surface: AppColors.darkPanelSolid,
        onSurface: AppColors.darkText,
        onSurfaceVariant: AppColors.darkMuted,
        error: AppColors.warning,
      ),
      textTheme: _textTheme(base.textTheme, AppColors.darkText),
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
      snackBarTheme: _snackBarTheme(false),
      textButtonTheme: TextButtonThemeData(style: _tapReleaseButtonStyle()),
      filledButtonTheme: FilledButtonThemeData(style: _tapReleaseButtonStyle()),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: _tapReleaseButtonStyle(),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: _tapReleaseButtonStyle(),
      ),
      iconButtonTheme: IconButtonThemeData(style: _tapReleaseButtonStyle()),
    );
  }

  static ThemeData light() {
    final base = ThemeData.light(useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: AppColors.lightMist,
      splashFactory: NoSplash.splashFactory,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      colorScheme: const ColorScheme.light(
        primary: AppColors.lightBlue,
        secondary: AppColors.lightViolet,
        tertiary: AppColors.lightMagenta,
        surface: AppColors.lightMist,
        onSurface: AppColors.lightText,
        onSurfaceVariant: AppColors.lightMuted,
        error: AppColors.warning,
      ),
      textTheme: _textTheme(base.textTheme, AppColors.lightText),
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
      snackBarTheme: _snackBarTheme(true),
      textButtonTheme: TextButtonThemeData(style: _tapReleaseButtonStyle()),
      filledButtonTheme: FilledButtonThemeData(style: _tapReleaseButtonStyle()),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: _tapReleaseButtonStyle(),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: _tapReleaseButtonStyle(),
      ),
      iconButtonTheme: IconButtonThemeData(style: _tapReleaseButtonStyle()),
    );
  }

  static ButtonStyle _tapReleaseButtonStyle() {
    return ButtonStyle(
      splashFactory: NoSplash.splashFactory,
      overlayColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.pressed)) {
          return Colors.transparent;
        }
        return null;
      }),
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
          ? Colors.white.withValues(alpha: 0.86)
          : AppColors.darkPanelSolid.withValues(alpha: 0.92),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(
          color: light ? AppColors.lightLine : AppColors.darkLine,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(
          color: light ? AppColors.lightLine : AppColors.darkLine,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: AppColors.electricBlue, width: 1.4),
      ),
    );
  }

  static DialogThemeData _dialogTheme(bool light) {
    final background = light ? Colors.white : AppColors.darkPanelSolid;
    return DialogThemeData(
      backgroundColor: background,
      surfaceTintColor: Colors.transparent,
      elevation: 18,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
    );
  }

  static DatePickerThemeData _datePickerTheme(bool light) {
    final background = light ? Colors.white : AppColors.darkPanelSolid;
    final headerBackground = light ? AppColors.lightIce : AppColors.darkNavy;
    final foreground = light ? AppColors.lightText : AppColors.darkText;
    final muted = light ? AppColors.lightMuted : AppColors.darkMuted;
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
          return AppColors.electricBlue;
        }
        if (states.contains(WidgetState.hovered) ||
            states.contains(WidgetState.focused)) {
          return AppColors.electricBlue.withValues(alpha: light ? 0.12 : 0.22);
        }
        return Colors.transparent;
      }),
      todayForegroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return selectedForeground;
        }
        return AppColors.electricBlue;
      }),
      todayBorder: const BorderSide(color: AppColors.electricBlue, width: 1.4),
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
          return AppColors.electricBlue;
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

  static SnackBarThemeData _snackBarTheme(bool light) {
    return SnackBarThemeData(
      backgroundColor: light ? AppColors.lightText : AppColors.darkPanelSolid,
      contentTextStyle: TextStyle(
        color: light ? Colors.white : AppColors.darkText,
        fontFamily: AppFonts.text,
        fontWeight: FontWeight.w700,
      ),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
    );
  }
}
