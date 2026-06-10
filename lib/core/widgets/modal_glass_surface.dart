import 'package:flutter/material.dart';
import 'package:qdone/core/theme/app_colors.dart';

class ModalGlassSurface extends StatelessWidget {
  const ModalGlassSurface({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.borderRadius = 32,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final surfaceColor = isLight ? Colors.white : AppColors.darkPanelSolid;
    final lineColor = isLight ? AppColors.lightLine : AppColors.darkLine;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: surfaceColor.withValues(alpha: isLight ? 0.96 : 0.98),
        borderRadius: BorderRadius.vertical(top: Radius.circular(borderRadius)),
        border: Border.all(color: lineColor.withValues(alpha: 0.78)),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: isLight ? 0.12 : 0.36),
            blurRadius: 26,
            offset: const Offset(0, -12),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.vertical(top: Radius.circular(borderRadius)),
        child: Stack(
          children: <Widget>[
            Positioned(
              left: 22,
              right: 22,
              top: 0,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: <Color>[
                      AppColors.electricBlue.withValues(alpha: 0),
                      AppColors.electricBlue.withValues(
                        alpha: isLight ? 0.34 : 0.30,
                      ),
                      AppColors.magenta.withValues(
                        alpha: isLight ? 0.25 : 0.28,
                      ),
                      AppColors.magenta.withValues(alpha: 0),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(99),
                ),
                child: const SizedBox(height: 2),
              ),
            ),
            Padding(padding: padding, child: child),
          ],
        ),
      ),
    );
  }
}
