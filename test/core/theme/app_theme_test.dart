import 'package:flutter_test/flutter_test.dart';
import 'package:qdone/core/theme/app_theme.dart';
import 'package:qdone/core/theme/qdone_theme_tokens.dart';

void main() {
  test('theme factories expose the expected palette extension', () {
    expect(
      AppTheme.light().extension<QDoneThemeTokens>()?.id,
      QDoneThemeTokens.light.id,
    );
    expect(
      AppTheme.dark().extension<QDoneThemeTokens>()?.id,
      QDoneThemeTokens.graphite.id,
    );
    expect(
      AppTheme.indigo().extension<QDoneThemeTokens>()?.id,
      QDoneThemeTokens.indigo.id,
    );
    expect(
      AppTheme.turquoise().extension<QDoneThemeTokens>()?.id,
      QDoneThemeTokens.turquoise.id,
    );
  });
}
