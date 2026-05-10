import 'package:flutter/material.dart';

class AppColors {
  const AppColors._();

  static const darkVoid = Color(0xFF05050A);
  static const darkPanel = Color(0xAA151522);
  static const white = Color(0xFFFFFFFF);
  static const softWhite = Color(0xFFF7F7FF);
  static const violet = Color(0xFF8B5CF6);
  static const neonPurple = Color(0xFFC084FC);
  static const cyan = Color(0xFF22D3EE);
  static const turquoise = Color(0xFF2DD4BF);
  static const softBlueGreen = Color(0xFF67E8F9);
  static const warning = Color(0xFFF59E0B);
  static const success = Color(0xFF34D399);
  static const muted = Color(0xFF8A8EA3);

  static const liquidGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: <Color>[violet, cyan, turquoise],
  );
}
