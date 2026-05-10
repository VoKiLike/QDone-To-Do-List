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
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isLight
              ? const <Color>[
                  Color(0xFFF8FAFC),
                  Color(0xFFEFF6FF),
                  Color(0xFFF7F7FF),
                ]
              : const <Color>[
                  AppColors.darkVoid,
                  Color(0xFF080818),
                  Color(0xFF071417),
                ],
        ),
      ),
      child: Stack(
        children: <Widget>[
          Positioned(
            top: -120,
            right: -80,
            child: _Glow(
              color: AppColors.violet.withValues(alpha: isLight ? 0.18 : 0.32),
              size: 260,
            ),
          ),
          Positioned(
            bottom: -100,
            left: -70,
            child: _Glow(
              color: AppColors.turquoise.withValues(
                alpha: isLight ? 0.18 : 0.28,
              ),
              size: 240,
            ),
          ),
          child,
        ],
      ),
    );
  }
}

class _Glow extends StatelessWidget {
  const _Glow({required this.color, required this.size});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: <BoxShadow>[
            BoxShadow(color: color, blurRadius: 140, spreadRadius: 54),
          ],
        ),
      ),
    );
  }
}
