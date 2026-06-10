import 'package:flutter/material.dart';
import 'package:qdone/core/theme/app_colors.dart';
import 'package:qdone/core/widgets/qdone_tap_feedback.dart';

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
    final surfaceColor = isLight ? Colors.white : AppColors.darkPanelSolid;
    final radius = BorderRadius.circular(borderRadius);

    Widget buildPanel(bool tapped) {
      final boxShadows = shadowBlurRadius > 0 || tapped
          ? <BoxShadow>[
              if (shadowBlurRadius > 0)
                BoxShadow(
                  color: (isLight ? AppColors.lightBlue : Colors.black)
                      .withValues(alpha: isLight ? 0.07 : 0.18),
                  blurRadius: shadowBlurRadius.clamp(6, 14),
                  offset: const Offset(0, 7),
                ),
              if (tapped)
                BoxShadow(
                  color: AppColors.cyan.withValues(
                    alpha: isLight ? 0.16 : 0.24,
                  ),
                  blurRadius: 20,
                  offset: const Offset(0, 7),
                ),
            ]
          : const <BoxShadow>[];
      return ClipRRect(
        borderRadius: radius,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOutCubic,
          decoration: BoxDecoration(
            color: Color.alphaBlend(
              AppColors.cyan.withValues(alpha: tapped ? 0.08 : 0),
              surfaceColor.withValues(alpha: 0.84),
            ),
            borderRadius: radius,
            border: Border.all(
              color: tapped
                  ? AppColors.cyan.withValues(alpha: 0.72)
                  : (isLight ? AppColors.lightLine : AppColors.darkLine)
                        .withValues(
                          alpha: isLight ? 0.88 : borderOpacity + 0.22,
                        ),
            ),
            boxShadow: boxShadows,
          ),
          child: Padding(padding: padding, child: child),
        ),
      );
    }

    if (onTap == null) {
      return buildPanel(false);
    }
    return QDoneTapFeedback(
      onTap: onTap,
      borderRadius: radius,
      builder: (context, tapped) => buildPanel(tapped),
    );
  }
}
