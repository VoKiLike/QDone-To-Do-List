import 'package:flutter/material.dart';

class AppColors {
  const AppColors._();

  static const darkInk = Color(0xFF03040B);
  static const darkVoid = darkInk;
  static const darkNavy = Color(0xFF071226);
  static const darkPanelSolid = Color(0xFF101936);
  static const darkPanel = Color(0xE6101936);
  static const deepBlue = Color(0xFF1D3F8F);
  static const electricBlue = Color(0xFF45C9FF);
  static const electricViolet = Color(0xFF5A35F2);
  static const indigoViolet = Color(0xFF6E46FF);
  static const magenta = Color(0xFF8B5CFF);
  static const darkText = Color(0xFFF4F7FF);
  static const darkMuted = Color(0xFFA8B4D8);
  static const darkLine = Color(0xFF263A72);

  static const lightMist = Color(0xFFF2FBFF);
  static const lightIce = Color(0xFFDDF5FF);
  static const lightSky = Color(0xFF8EDBFF);
  static const lightBlue = Color(0xFF2E9BFF);
  static const lightViolet = Color(0xFF5946D2);
  static const lightMagenta = Color(0xFF7357F5);
  static const lightHighlight = Color(0xFFFFF0C7);
  static const lightText = Color(0xFF11172B);
  static const lightMuted = Color(0xFF66708B);
  static const lightLine = Color(0xFFC9E6F6);

  static const white = Color(0xFFFFFFFF);
  static const softWhite = lightMist;
  static const violet = electricViolet;
  static const neonPurple = indigoViolet;
  static const cyan = electricBlue;
  static const turquoise = lightSky;
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
    colors: <Color>[darkInk, darkNavy, darkPanelSolid, deepBlue],
    stops: <double>[0, 0.38, 0.72, 1],
  );

  static const lightAuroraGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: <Color>[lightMist, lightIce, lightSky, lightBlue],
    stops: <double>[0, 0.42, 0.78, 1],
  );

  static Color surface(BuildContext context) {
    final light = Theme.of(context).brightness == Brightness.light;
    return light ? white.withValues(alpha: 0.82) : darkPanelSolid;
  }

  static Color elevatedSurface(BuildContext context) {
    final light = Theme.of(context).brightness == Brightness.light;
    return light ? white.withValues(alpha: 0.92) : const Color(0xFF121D3B);
  }

  static Color line(BuildContext context) {
    final light = Theme.of(context).brightness == Brightness.light;
    return light ? lightLine : darkLine;
  }

  static Color foreground(BuildContext context) {
    final light = Theme.of(context).brightness == Brightness.light;
    return light ? lightText : darkText;
  }

  static Color subdued(BuildContext context) {
    final light = Theme.of(context).brightness == Brightness.light;
    return light ? lightMuted : darkMuted;
  }
}
