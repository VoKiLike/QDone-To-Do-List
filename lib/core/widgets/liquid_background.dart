import 'package:flutter/material.dart';
import 'package:qdone/core/theme/app_colors.dart';

class LiquidBackground extends StatelessWidget {
  const LiquidBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final ribbonColors = AppColors.ribbonColorsFor(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: AppColors.backgroundGradientFor(context),
      ),
      child: CustomPaint(
        painter: _AuroraRibbonPainter(isLight: isLight, colors: ribbonColors),
        child: child,
      ),
    );
  }
}

class _AuroraRibbonPainter extends CustomPainter {
  const _AuroraRibbonPainter({required this.isLight, required this.colors});

  final bool isLight;
  final List<Color> colors;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = isLight ? 40 : 46
      ..strokeCap = StrokeCap.round
      ..shader = LinearGradient(
        colors: <Color>[
          colors[0].withValues(alpha: isLight ? 0.09 : 0.10),
          colors[1].withValues(alpha: isLight ? 0.12 : 0.12),
          colors[2].withValues(alpha: isLight ? 0.08 : 0.08),
        ],
      ).createShader(Offset.zero & size);

    final path = Path()
      ..moveTo(size.width * 0.92, -32)
      ..cubicTo(
        size.width * 0.78,
        size.height * 0.22,
        size.width * 0.24,
        size.height * 0.26,
        size.width * 0.38,
        size.height * 0.54,
      )
      ..cubicTo(
        size.width * 0.52,
        size.height * 0.78,
        size.width * 0.92,
        size.height * 0.80,
        size.width * 0.72,
        size.height + 36,
      );
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _AuroraRibbonPainter oldDelegate) {
    return oldDelegate.isLight != isLight || oldDelegate.colors != colors;
  }
}
