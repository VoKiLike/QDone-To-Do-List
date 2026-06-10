import 'package:flutter/material.dart';

@immutable
class QDoneThemeTokens extends ThemeExtension<QDoneThemeTokens> {
  const QDoneThemeTokens({
    required this.id,
    required this.isLight,
    required this.canvas,
    required this.surface,
    required this.elevatedSurface,
    required this.mutedSurface,
    required this.line,
    required this.foreground,
    required this.subdued,
    required this.primary,
    required this.secondary,
    required this.tertiary,
    required this.warning,
    required this.success,
    required this.backgroundGradient,
    required this.accentGradient,
    required this.ribbonColors,
    required this.navBar,
    required this.navBorder,
    required this.shadow,
    required this.accentForeground,
  });

  static const light = QDoneThemeTokens(
    id: 'light',
    isLight: true,
    canvas: Color(0xFFDDE5EB),
    surface: Color(0xFFE7EDF2),
    elevatedSurface: Color(0xFFF0F3F5),
    mutedSurface: Color(0xFFCAD6DF),
    line: Color(0xFF99AABC),
    foreground: Color(0xFF182235),
    subdued: Color(0xFF4E5D72),
    primary: Color(0xFF23658D),
    secondary: Color(0xFF51449A),
    tertiary: Color(0xFF6950A4),
    warning: Color(0xFFA64E1C),
    success: Color(0xFF176B50),
    backgroundGradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: <Color>[
        Color(0xFFDDE5EB),
        Color(0xFFD3DEE6),
        Color(0xFFC3D4DE),
        Color(0xFFAFC7D6),
      ],
      stops: <double>[0, 0.42, 0.78, 1],
    ),
    accentGradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: <Color>[Color(0xFF51449A), Color(0xFF23658D), Color(0xFF2F708F)],
    ),
    ribbonColors: <Color>[
      Color(0xFF51449A),
      Color(0xFF78A8C2),
      Color(0xFFB9CDD9),
    ],
    navBar: Color(0xFFF0F3F5),
    navBorder: Color(0xFF99AABC),
    shadow: Color(0xFF203247),
    accentForeground: Colors.white,
  );

  static const graphite = QDoneThemeTokens(
    id: 'graphite',
    isLight: false,
    canvas: Color(0xFF050812),
    surface: Color(0xFF10182B),
    elevatedSurface: Color(0xFF17223A),
    mutedSurface: Color(0xFF1D2A46),
    line: Color(0xFF32446B),
    foreground: Color(0xFFF3F6FC),
    subdued: Color(0xFFADB8D0),
    primary: Color(0xFF55C4EE),
    secondary: Color(0xFF8874F1),
    tertiary: Color(0xFFA078E8),
    warning: Color(0xFFF2A05B),
    success: Color(0xFF5DD6AC),
    backgroundGradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: <Color>[
        Color(0xFF050812),
        Color(0xFF091126),
        Color(0xFF101A31),
        Color(0xFF172747),
      ],
      stops: <double>[0, 0.38, 0.72, 1],
    ),
    accentGradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: <Color>[Color(0xFF4930B6), Color(0xFF6546D8), Color(0xFF257FA4)],
    ),
    ribbonColors: <Color>[
      Color(0xFF8874F1),
      Color(0xFF55C4EE),
      Color(0xFFA078E8),
    ],
    navBar: Color(0xFF080F20),
    navBorder: Color(0xFF2B3D65),
    shadow: Colors.black,
    accentForeground: Colors.white,
  );

  static const indigo = QDoneThemeTokens(
    id: 'indigo',
    isLight: false,
    canvas: Color(0xFF080612),
    surface: Color(0xFF16112A),
    elevatedSurface: Color(0xFF21193A),
    mutedSurface: Color(0xFF2A2047),
    line: Color(0xFF4A3C70),
    foreground: Color(0xFFF7F3FC),
    subdued: Color(0xFFC3B9D8),
    primary: Color(0xFFA98CF5),
    secondary: Color(0xFF8A70EA),
    tertiary: Color(0xFFC084FC),
    warning: Color(0xFFF3A66B),
    success: Color(0xFF67D7B2),
    backgroundGradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: <Color>[
        Color(0xFF080612),
        Color(0xFF120B24),
        Color(0xFF1A1036),
        Color(0xFF25164B),
      ],
      stops: <double>[0, 0.38, 0.72, 1],
    ),
    accentGradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: <Color>[Color(0xFF4C2AA5), Color(0xFF5E3BC8), Color(0xFF754FDC)],
    ),
    ribbonColors: <Color>[
      Color(0xFFA98CF5),
      Color(0xFF8A70EA),
      Color(0xFFC084FC),
    ],
    navBar: Color(0xFF100B22),
    navBorder: Color(0xFF3F3266),
    shadow: Colors.black,
    accentForeground: Colors.white,
  );

  static const turquoise = QDoneThemeTokens(
    id: 'turquoise',
    isLight: false,
    canvas: Color(0xFF031013),
    surface: Color(0xFF0A1D24),
    elevatedSurface: Color(0xFF102A33),
    mutedSurface: Color(0xFF173640),
    line: Color(0xFF2B5968),
    foreground: Color(0xFFF0F9FA),
    subdued: Color(0xFFA9C4C9),
    primary: Color(0xFF52D3CE),
    secondary: Color(0xFF58B4CF),
    tertiary: Color(0xFF65D6A8),
    warning: Color(0xFFF1A261),
    success: Color(0xFF61D5A9),
    backgroundGradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: <Color>[
        Color(0xFF031013),
        Color(0xFF061D24),
        Color(0xFF092C36),
        Color(0xFF0E3E49),
      ],
      stops: <double>[0, 0.38, 0.72, 1],
    ),
    accentGradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: <Color>[Color(0xFF075467), Color(0xFF0B697A), Color(0xFF147E8E)],
    ),
    ribbonColors: <Color>[
      Color(0xFF52D3CE),
      Color(0xFF58B4CF),
      Color(0xFF65D6A8),
    ],
    navBar: Color(0xFF06161C),
    navBorder: Color(0xFF24505E),
    shadow: Colors.black,
    accentForeground: Colors.white,
  );

  final String id;
  final bool isLight;
  final Color canvas;
  final Color surface;
  final Color elevatedSurface;
  final Color mutedSurface;
  final Color line;
  final Color foreground;
  final Color subdued;
  final Color primary;
  final Color secondary;
  final Color tertiary;
  final Color warning;
  final Color success;
  final LinearGradient backgroundGradient;
  final LinearGradient accentGradient;
  final List<Color> ribbonColors;
  final Color navBar;
  final Color navBorder;
  final Color shadow;
  final Color accentForeground;

  @override
  QDoneThemeTokens copyWith({
    String? id,
    bool? isLight,
    Color? canvas,
    Color? surface,
    Color? elevatedSurface,
    Color? mutedSurface,
    Color? line,
    Color? foreground,
    Color? subdued,
    Color? primary,
    Color? secondary,
    Color? tertiary,
    Color? warning,
    Color? success,
    LinearGradient? backgroundGradient,
    LinearGradient? accentGradient,
    List<Color>? ribbonColors,
    Color? navBar,
    Color? navBorder,
    Color? shadow,
    Color? accentForeground,
  }) {
    return QDoneThemeTokens(
      id: id ?? this.id,
      isLight: isLight ?? this.isLight,
      canvas: canvas ?? this.canvas,
      surface: surface ?? this.surface,
      elevatedSurface: elevatedSurface ?? this.elevatedSurface,
      mutedSurface: mutedSurface ?? this.mutedSurface,
      line: line ?? this.line,
      foreground: foreground ?? this.foreground,
      subdued: subdued ?? this.subdued,
      primary: primary ?? this.primary,
      secondary: secondary ?? this.secondary,
      tertiary: tertiary ?? this.tertiary,
      warning: warning ?? this.warning,
      success: success ?? this.success,
      backgroundGradient: backgroundGradient ?? this.backgroundGradient,
      accentGradient: accentGradient ?? this.accentGradient,
      ribbonColors: ribbonColors ?? this.ribbonColors,
      navBar: navBar ?? this.navBar,
      navBorder: navBorder ?? this.navBorder,
      shadow: shadow ?? this.shadow,
      accentForeground: accentForeground ?? this.accentForeground,
    );
  }

  @override
  QDoneThemeTokens lerp(covariant QDoneThemeTokens? other, double t) {
    if (other == null) {
      return this;
    }
    return QDoneThemeTokens(
      id: t < 0.5 ? id : other.id,
      isLight: t < 0.5 ? isLight : other.isLight,
      canvas: Color.lerp(canvas, other.canvas, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      elevatedSurface: Color.lerp(elevatedSurface, other.elevatedSurface, t)!,
      mutedSurface: Color.lerp(mutedSurface, other.mutedSurface, t)!,
      line: Color.lerp(line, other.line, t)!,
      foreground: Color.lerp(foreground, other.foreground, t)!,
      subdued: Color.lerp(subdued, other.subdued, t)!,
      primary: Color.lerp(primary, other.primary, t)!,
      secondary: Color.lerp(secondary, other.secondary, t)!,
      tertiary: Color.lerp(tertiary, other.tertiary, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      success: Color.lerp(success, other.success, t)!,
      backgroundGradient: LinearGradient.lerp(
        backgroundGradient,
        other.backgroundGradient,
        t,
      )!,
      accentGradient: LinearGradient.lerp(
        accentGradient,
        other.accentGradient,
        t,
      )!,
      ribbonColors: List<Color>.generate(
        ribbonColors.length,
        (index) =>
            Color.lerp(ribbonColors[index], other.ribbonColors[index], t)!,
      ),
      navBar: Color.lerp(navBar, other.navBar, t)!,
      navBorder: Color.lerp(navBorder, other.navBorder, t)!,
      shadow: Color.lerp(shadow, other.shadow, t)!,
      accentForeground: Color.lerp(
        accentForeground,
        other.accentForeground,
        t,
      )!,
    );
  }
}
