import 'package:flutter/material.dart';
import 'package:qdone/core/theme/app_colors.dart';

class LiquidBackground extends StatelessWidget {
  const LiquidBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: isLight
            ? AppColors.lightAuroraGradient
            : AppColors.darkAuroraGradient,
      ),
      child: CustomPaint(painter: _AuroraRibbonPainter(isLight), child: child),
    );
  }
}

class _AuroraRibbonPainter extends CustomPainter {
  const _AuroraRibbonPainter(this.isLight);

  final bool isLight;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 46
      ..strokeCap = StrokeCap.round
      ..shader = LinearGradient(
        colors: isLight
            ? <Color>[
                AppColors.lightViolet.withValues(alpha: 0.14),
                AppColors.lightSky.withValues(alpha: 0.18),
                AppColors.lightHighlight.withValues(alpha: 0.12),
              ]
            : <Color>[
                AppColors.electricViolet.withValues(alpha: 0.14),
                AppColors.electricBlue.withValues(alpha: 0.16),
                AppColors.magenta.withValues(alpha: 0.10),
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
    return oldDelegate.isLight != isLight;
  }
}
