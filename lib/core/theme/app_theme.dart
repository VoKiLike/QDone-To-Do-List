import 'package:flutter/material.dart';
import 'package:qdone/core/theme/app_fonts.dart';
import 'package:qdone/core/theme/qdone_theme_tokens.dart';

class AppTheme {
  const AppTheme._();

  static ThemeData light() => _build(QDoneThemeTokens.light);

  static ThemeData dark() => _build(QDoneThemeTokens.graphite);

  static ThemeData indigo() => _build(QDoneThemeTokens.indigo);

  static ThemeData turquoise() => _build(QDoneThemeTokens.turquoise);

  static ThemeData _build(QDoneThemeTokens tokens) {
    final brightness = tokens.isLight ? Brightness.light : Brightness.dark;
    final base = ThemeData(brightness: brightness, useMaterial3: true);
    final colorScheme = tokens.isLight
        ? ColorScheme.light(
            primary: tokens.primary,
            onPrimary: tokens.accentForeground,
            primaryContainer: tokens.mutedSurface,
            onPrimaryContainer: tokens.foreground,
            secondary: tokens.secondary,
            onSecondary: tokens.accentForeground,
            secondaryContainer: tokens.surface,
            onSecondaryContainer: tokens.foreground,
            tertiary: tokens.tertiary,
            onTertiary: tokens.accentForeground,
            surface: tokens.surface,
            onSurface: tokens.foreground,
            onSurfaceVariant: tokens.subdued,
            error: tokens.warning,
            onError: tokens.accentForeground,
            outline: tokens.line,
            outlineVariant: tokens.mutedSurface,
            shadow: tokens.shadow,
          )
        : ColorScheme.dark(
            primary: tokens.primary,
            onPrimary: tokens.canvas,
            primaryContainer: tokens.mutedSurface,
            onPrimaryContainer: tokens.foreground,
            secondary: tokens.secondary,
            onSecondary: tokens.canvas,
            secondaryContainer: tokens.mutedSurface,
            onSecondaryContainer: tokens.foreground,
            tertiary: tokens.tertiary,
            onTertiary: tokens.canvas,
            surface: tokens.surface,
            onSurface: tokens.foreground,
            onSurfaceVariant: tokens.subdued,
            error: tokens.warning,
            onError: tokens.canvas,
            outline: tokens.line,
            outlineVariant: tokens.mutedSurface,
            shadow: tokens.shadow,
          );

    return base.copyWith(
      scaffoldBackgroundColor: tokens.canvas,
      splashFactory: NoSplash.splashFactory,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      colorScheme: colorScheme,
      extensions: <ThemeExtension<dynamic>>[tokens],
      textTheme: _textTheme(base.textTheme, tokens.foreground),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
      ),
      dividerTheme: DividerThemeData(
        color: tokens.line.withValues(alpha: tokens.isLight ? 0.62 : 0.72),
        thickness: 1,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Colors.transparent,
        modalBackgroundColor: Colors.transparent,
      ),
      dialogTheme: _dialogTheme(tokens),
      datePickerTheme: _datePickerTheme(tokens),
      inputDecorationTheme: _inputDecorationTheme(tokens),
      snackBarTheme: _snackBarTheme(tokens),
      textButtonTheme: TextButtonThemeData(
        style: _tapReleaseButtonStyle(foregroundColor: tokens.primary),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: _tapReleaseButtonStyle(
          foregroundColor: tokens.accentForeground,
          backgroundColor: tokens.primary,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: _tapReleaseButtonStyle(
          foregroundColor: tokens.foreground,
          backgroundColor: tokens.elevatedSurface,
          side: BorderSide(color: tokens.line, width: 1.2),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: _tapReleaseButtonStyle(
          foregroundColor: tokens.foreground,
          side: BorderSide(color: tokens.primary, width: 1.2),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: _tapReleaseButtonStyle(foregroundColor: tokens.foreground),
      ),
    );
  }

  static ButtonStyle _tapReleaseButtonStyle({
    Color? foregroundColor,
    Color? backgroundColor,
    BorderSide? side,
    double? elevation,
  }) {
    return ButtonStyle(
      splashFactory: NoSplash.splashFactory,
      overlayColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.pressed)) {
          return Colors.transparent;
        }
        return null;
      }),
      foregroundColor: foregroundColor == null
          ? null
          : WidgetStatePropertyAll(foregroundColor),
      backgroundColor: backgroundColor == null
          ? null
          : WidgetStatePropertyAll(backgroundColor),
      side: side == null ? null : WidgetStatePropertyAll(side),
      elevation: elevation == null ? null : WidgetStatePropertyAll(elevation),
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

  static InputDecorationTheme _inputDecorationTheme(QDoneThemeTokens tokens) {
    return InputDecorationTheme(
      filled: true,
      fillColor: tokens.elevatedSurface,
      labelStyle: TextStyle(color: tokens.subdued),
      hintStyle: TextStyle(color: tokens.subdued.withValues(alpha: 0.86)),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(
          color: tokens.line,
          width: tokens.isLight ? 1.2 : 1,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(
          color: tokens.line,
          width: tokens.isLight ? 1.2 : 1,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(color: tokens.primary, width: 1.6),
      ),
    );
  }

  static DialogThemeData _dialogTheme(QDoneThemeTokens tokens) {
    return DialogThemeData(
      backgroundColor: tokens.elevatedSurface,
      surfaceTintColor: Colors.transparent,
      elevation: 18,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
    );
  }

  static DatePickerThemeData _datePickerTheme(QDoneThemeTokens tokens) {
    return DatePickerThemeData(
      backgroundColor: tokens.elevatedSurface,
      surfaceTintColor: Colors.transparent,
      elevation: 18,
      shadowColor: tokens.shadow.withValues(
        alpha: tokens.isLight ? 0.14 : 0.46,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      headerBackgroundColor: tokens.mutedSurface,
      headerForegroundColor: tokens.foreground,
      weekdayStyle: TextStyle(
        color: tokens.subdued,
        fontWeight: FontWeight.w700,
      ),
      dayForegroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return tokens.accentForeground;
        }
        if (states.contains(WidgetState.disabled)) {
          return tokens.subdued.withValues(alpha: 0.42);
        }
        return tokens.foreground;
      }),
      dayBackgroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return tokens.primary;
        }
        if (states.contains(WidgetState.hovered) ||
            states.contains(WidgetState.focused)) {
          return tokens.primary.withValues(alpha: tokens.isLight ? 0.14 : 0.22);
        }
        return Colors.transparent;
      }),
      todayForegroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return tokens.accentForeground;
        }
        return tokens.primary;
      }),
      todayBorder: BorderSide(color: tokens.primary, width: 1.4),
      yearForegroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return tokens.accentForeground;
        }
        if (states.contains(WidgetState.disabled)) {
          return tokens.subdued.withValues(alpha: 0.42);
        }
        return tokens.foreground;
      }),
      yearBackgroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return tokens.primary;
        }
        return Colors.transparent;
      }),
      cancelButtonStyle: TextButton.styleFrom(
        foregroundColor: tokens.secondary,
      ),
      confirmButtonStyle: TextButton.styleFrom(
        foregroundColor: tokens.secondary,
      ),
    );
  }

  static SnackBarThemeData _snackBarTheme(QDoneThemeTokens tokens) {
    return SnackBarThemeData(
      backgroundColor: tokens.isLight
          ? tokens.foreground
          : tokens.elevatedSurface,
      contentTextStyle: TextStyle(
        color: tokens.isLight ? Colors.white : tokens.foreground,
        fontFamily: AppFonts.text,
        fontWeight: FontWeight.w700,
      ),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
    );
  }
}
