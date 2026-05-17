import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:qdone/core/theme/app_colors.dart';

class GlassPanel extends StatelessWidget {
  const GlassPanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.borderRadius = 28,
    this.opacity = 0.12,
    this.borderOpacity = 0.16,
    this.blurSigma = 18,
    this.shadowBlurRadius = 24,
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final double opacity;
  final double borderOpacity;
  final double blurSigma;
  final double shadowBlurRadius;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final surfaceColor = isLight ? Colors.white : AppColors.white;
    final boxShadows = shadowBlurRadius > 0
        ? <BoxShadow>[
            BoxShadow(
              color: AppColors.violet.withValues(
                alpha: isLight ? 0.08 : 0.18,
              ),
              blurRadius: shadowBlurRadius,
              offset: const Offset(0, 18),
            ),
          ]
        : const <BoxShadow>[];
    final decoratedPanel = DecoratedBox(
      decoration: BoxDecoration(
        color: surfaceColor.withValues(alpha: isLight ? 0.72 : opacity),
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: surfaceColor.withValues(
            alpha: isLight ? 0.62 : borderOpacity,
          ),
        ),
        boxShadow: boxShadows,
      ),
      child: Padding(padding: padding, child: child),
    );
    final filteredPanel = blurSigma > 0
        ? BackdropFilter(
            filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
            child: decoratedPanel,
          )
        : decoratedPanel;
    final panel = ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: filteredPanel,
    );
    if (onTap == null) {
      return panel;
    }
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(borderRadius),
        child: panel,
      ),
    );
  }
}
