import 'dart:ui';

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
    final surfaceColor = isLight
        ? const Color(0xFFF5F1FF).withValues(alpha: 0.96)
        : const Color(0xFF0E0A16).withValues(alpha: 0.97);
    final borderColor = isLight
        ? Colors.white.withValues(alpha: 0.72)
        : Colors.white.withValues(alpha: 0.16);

    return ClipRRect(
      borderRadius: BorderRadius.vertical(top: Radius.circular(borderRadius)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 34, sigmaY: 34),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(borderRadius),
            ),
            border: Border(
              top: BorderSide(color: borderColor),
              left: BorderSide(color: borderColor.withValues(alpha: 0.56)),
              right: BorderSide(color: borderColor.withValues(alpha: 0.56)),
            ),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: AppColors.violet.withValues(
                  alpha: isLight ? 0.14 : 0.26,
                ),
                blurRadius: 34,
                offset: const Offset(0, -10),
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: isLight ? 0.10 : 0.34),
                blurRadius: 42,
                offset: const Offset(0, -18),
              ),
            ],
          ),
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}
