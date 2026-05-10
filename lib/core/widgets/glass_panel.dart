import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_to_do_list_app/core/theme/app_colors.dart';

class GlassPanel extends StatelessWidget {
  const GlassPanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.borderRadius = 28,
    this.opacity = 0.12,
    this.borderOpacity = 0.16,
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final double opacity;
  final double borderOpacity;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final surfaceColor = isLight ? Colors.white : AppColors.white;
    final panel = ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: surfaceColor.withValues(alpha: isLight ? 0.72 : opacity),
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color: surfaceColor.withValues(
                alpha: isLight ? 0.62 : borderOpacity,
              ),
            ),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: AppColors.violet.withValues(
                  alpha: isLight ? 0.08 : 0.18,
                ),
                blurRadius: 24,
                offset: const Offset(0, 18),
              ),
            ],
          ),
          child: Padding(padding: padding, child: child),
        ),
      ),
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
