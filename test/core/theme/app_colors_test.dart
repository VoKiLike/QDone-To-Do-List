import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qdone/core/theme/app_colors.dart';
import 'package:qdone/core/theme/qdone_theme_tokens.dart';

void main() {
  test('light palette stays muted and readable', () {
    expect(AppColors.lightMist, isNot(Colors.white));
    expect(AppColors.lightMist.computeLuminance(), lessThan(0.82));

    expect(
      _contrastRatio(AppColors.lightText, AppColors.lightSurface),
      greaterThanOrEqualTo(4.5),
    );
    expect(
      _contrastRatio(AppColors.lightMuted, AppColors.lightSurface),
      greaterThanOrEqualTo(4.5),
    );
    expect(
      _contrastRatio(Colors.white, AppColors.lightBlue),
      greaterThanOrEqualTo(4.5),
    );
    expect(
      _contrastRatio(AppColors.lightWarning, AppColors.lightSurface),
      greaterThanOrEqualTo(4.5),
    );
    expect(
      _contrastRatio(AppColors.lightSuccess, AppColors.lightSurface),
      greaterThanOrEqualTo(4.5),
    );
  });

  test('every palette keeps text and semantic colors readable', () {
    const palettes = <QDoneThemeTokens>[
      QDoneThemeTokens.light,
      QDoneThemeTokens.graphite,
      QDoneThemeTokens.indigo,
      QDoneThemeTokens.turquoise,
    ];

    for (final palette in palettes) {
      expect(
        _contrastRatio(palette.foreground, palette.surface),
        greaterThanOrEqualTo(4.5),
        reason: '${palette.id}: foreground/surface',
      );
      expect(
        _contrastRatio(palette.subdued, palette.surface),
        greaterThanOrEqualTo(4.5),
        reason: '${palette.id}: subdued/surface',
      );
      expect(
        _contrastRatio(palette.primary, palette.surface),
        greaterThanOrEqualTo(4.5),
        reason: '${palette.id}: primary/surface',
      );
      expect(
        _contrastRatio(palette.warning, palette.surface),
        greaterThanOrEqualTo(4.5),
        reason: '${palette.id}: warning/surface',
      );
      expect(
        _contrastRatio(palette.success, palette.surface),
        greaterThanOrEqualTo(4.5),
        reason: '${palette.id}: success/surface',
      );
      for (final accent in palette.accentGradient.colors) {
        expect(
          _contrastRatio(palette.accentForeground, accent),
          greaterThanOrEqualTo(4.5),
          reason: '${palette.id}: accent foreground',
        );
      }
    }
  });

  test('dark palettes remain visually distinct', () {
    expect(
      QDoneThemeTokens.graphite.backgroundGradient.colors,
      isNot(QDoneThemeTokens.indigo.backgroundGradient.colors),
    );
    expect(
      QDoneThemeTokens.indigo.backgroundGradient.colors,
      isNot(QDoneThemeTokens.turquoise.backgroundGradient.colors),
    );
  });
}

double _contrastRatio(Color foreground, Color background) {
  final foregroundLuminance = foreground.computeLuminance();
  final backgroundLuminance = background.computeLuminance();
  final lighter = foregroundLuminance > backgroundLuminance
      ? foregroundLuminance
      : backgroundLuminance;
  final darker = foregroundLuminance > backgroundLuminance
      ? backgroundLuminance
      : foregroundLuminance;
  return (lighter + 0.05) / (darker + 0.05);
}
