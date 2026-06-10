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
    final surfaceColor = AppColors.elevatedSurface(context);
    final lineColor = AppColors.line(context);
    final primary = AppColors.primaryFor(context);
    final secondary = AppColors.secondaryFor(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: surfaceColor.withValues(alpha: isLight ? 0.99 : 0.98),
        borderRadius: BorderRadius.vertical(top: Radius.circular(borderRadius)),
        border: Border.all(
          color: lineColor.withValues(alpha: isLight ? 1 : 0.78),
          width: isLight ? 1.2 : 1,
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppColors.shadowFor(
              context,
            ).withValues(alpha: isLight ? 0.14 : 0.36),
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
                      primary.withValues(alpha: 0),
                      primary.withValues(alpha: isLight ? 0.34 : 0.30),
                      secondary.withValues(alpha: isLight ? 0.25 : 0.28),
                      secondary.withValues(alpha: 0),
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
