import 'package:flutter/material.dart';
import 'package:qdone/core/theme/qdone_theme_tokens.dart';

class AppColors {
  const AppColors._();

  static const darkInk = Color(0xFF050812);
  static const darkVoid = darkInk;
  static const darkNavy = Color(0xFF080F20);
  static const darkPanelSolid = Color(0xFF10182B);
  static const darkPanel = Color(0xE610182B);
  static const deepBlue = Color(0xFF172747);
  static const electricBlue = Color(0xFF55C4EE);
  static const electricViolet = Color(0xFF6546D8);
  static const indigoViolet = Color(0xFF8874F1);
  static const magenta = Color(0xFFA078E8);
  static const darkText = Color(0xFFF3F6FC);
  static const darkMuted = Color(0xFFADB8D0);
  static const darkLine = Color(0xFF32446B);

  static const lightMist = Color(0xFFDDE5EB);
  static const lightIce = Color(0xFFD3DEE6);
  static const lightSky = Color(0xFF78A8C2);
  static const lightBlue = Color(0xFF23658D);
  static const lightViolet = Color(0xFF51449A);
  static const lightMagenta = Color(0xFF6950A4);
  static const lightHighlight = Color(0xFFB9CDD9);
  static const lightText = Color(0xFF182235);
  static const lightMuted = Color(0xFF4E5D72);
  static const lightLine = Color(0xFF99AABC);
  static const lightSurface = Color(0xFFE7EDF2);
  static const lightElevatedSurface = Color(0xFFF0F3F5);
  static const lightSurfaceMuted = Color(0xFFCAD6DF);
  static const lightWarning = Color(0xFFA64E1C);
  static const lightSuccess = Color(0xFF176B50);

  static const white = Color(0xFFFFFFFF);
  static const softWhite = Color(0xFFF2FBFF);
  static const violet = electricViolet;
  static const neonPurple = indigoViolet;
  static const cyan = electricBlue;
  static const turquoise = Color(0xFF8EDBFF);
  static const softBlueGreen = Color(0xFF9DEBFF);
  static const warning = Color(0xFFF4A261);
  static const success = Color(0xFF54D6A7);
  static const muted = darkMuted;

  static const liquidGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: <Color>[electricViolet, indigoViolet, electricBlue, lightSky],
  );

  static const darkAuroraGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: <Color>[darkInk, Color(0xFF091126), Color(0xFF101A31), deepBlue],
    stops: <double>[0, 0.38, 0.72, 1],
  );

  static const lightAuroraGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: <Color>[lightMist, lightIce, Color(0xFFC3D4DE), Color(0xFFAFC7D6)],
    stops: <double>[0, 0.42, 0.78, 1],
  );

  static const lightLiquidGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: <Color>[lightViolet, lightBlue, Color(0xFF2F708F)],
  );

  static Color surface(BuildContext context) {
    return tokens(context).surface;
  }

  static Color elevatedSurface(BuildContext context) {
    return tokens(context).elevatedSurface;
  }

  static Color mutedSurface(BuildContext context) {
    return tokens(context).mutedSurface;
  }

  static Color primaryFor(BuildContext context) {
    return tokens(context).primary;
  }

  static Color secondaryFor(BuildContext context) {
    return tokens(context).secondary;
  }

  static Color tertiaryFor(BuildContext context) {
    return tokens(context).tertiary;
  }

  static Color warningFor(BuildContext context) {
    return tokens(context).warning;
  }

  static Color successFor(BuildContext context) {
    return tokens(context).success;
  }

  static LinearGradient liquidGradientFor(BuildContext context) {
    return tokens(context).accentGradient;
  }

  static LinearGradient backgroundGradientFor(BuildContext context) {
    return tokens(context).backgroundGradient;
  }

  static List<Color> ribbonColorsFor(BuildContext context) {
    return tokens(context).ribbonColors;
  }

  static Color navBarFor(BuildContext context) {
    return tokens(context).navBar;
  }

  static Color navBorderFor(BuildContext context) {
    return tokens(context).navBorder;
  }

  static Color shadowFor(BuildContext context) {
    return tokens(context).shadow;
  }

  static Color accentForegroundFor(BuildContext context) {
    return tokens(context).accentForeground;
  }

  static Color line(BuildContext context) {
    return tokens(context).line;
  }

  static Color foreground(BuildContext context) {
    return tokens(context).foreground;
  }

  static Color subdued(BuildContext context) {
    return tokens(context).subdued;
  }

  static QDoneThemeTokens tokens(BuildContext context) {
    return Theme.of(context).extension<QDoneThemeTokens>() ??
        (Theme.of(context).brightness == Brightness.light
            ? QDoneThemeTokens.light
            : QDoneThemeTokens.graphite);
  }
}
