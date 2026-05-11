import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:qdone/core/localization/qdone_localizations.dart';
import 'package:qdone/core/theme/app_colors.dart';
import 'package:qdone/core/widgets/liquid_background.dart';

const double _navCurveSpan = 0.2;
const double _navBarHeight = 72;
const double _navTotalHeight = 104;
const double _positionTolerance = 0.000001;

class QDoneShell extends StatelessWidget {
  const QDoneShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return LiquidBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBody: true,
        body: SafeArea(bottom: false, child: navigationShell),
        bottomNavigationBar: RepaintBoundary(
          child: _LiquidQDoneNavigation(navigationShell: navigationShell),
        ),
      ),
    );
  }
}

class _LiquidQDoneNavigation extends StatelessWidget {
  const _LiquidQDoneNavigation({required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    final strings = QDoneLocalizations.of(context);
    final isLight = Theme.of(context).brightness == Brightness.light;
    final items = <_QDoneNavItem>[
      _QDoneNavItem(
        icon: Icons.calendar_month_rounded,
        label: strings.text('calendar'),
      ),
      _QDoneNavItem(
        icon: Icons.check_circle_rounded,
        label: strings.text('tasks'),
      ),
      _QDoneNavItem(icon: Icons.tune_rounded, label: strings.text('menu')),
    ];

    return SafeArea(
      top: false,
      minimum: const EdgeInsets.fromLTRB(12, 0, 12, 10),
      child: _CurvedLiquidNavigationBar(
        items: items,
        index: navigationShell.currentIndex,
        isLight: isLight,
        onTap: (index) {
          navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          );
        },
      ),
    );
  }
}

class _CurvedLiquidNavigationBar extends StatefulWidget {
  const _CurvedLiquidNavigationBar({
    required this.items,
    required this.index,
    required this.isLight,
    required this.onTap,
  }) : assert(items.length > 0),
       assert(index >= 0 && index < items.length);

  final List<_QDoneNavItem> items;
  final int index;
  final bool isLight;
  final ValueChanged<int> onTap;

  @override
  State<_CurvedLiquidNavigationBar> createState() =>
      _CurvedLiquidNavigationBarState();
}

class _CurvedLiquidNavigationBarState extends State<_CurvedLiquidNavigationBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late double _startingPos;
  late double _pos;
  late int _endingIndex;
  late int _visibleButtonIndex;
  double _buttonHide = 0;

  int get _length => widget.items.length;

  @override
  void initState() {
    super.initState();
    _pos = widget.index / _length;
    _startingPos = _pos;
    _endingIndex = widget.index;
    _visibleButtonIndex = widget.index;
    _animationController = AnimationController(vsync: this, value: _pos)
      ..addListener(_syncAnimationState);
  }

  @override
  void didUpdateWidget(covariant _CurvedLiquidNavigationBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.index != _endingIndex && widget.index >= 0) {
      _animateToIndex(widget.index);
    } else if (!_animationController.isAnimating) {
      _visibleButtonIndex = widget.index;
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _syncAnimationState() {
    final endingPos = _endingIndex / _length;
    final middle = (endingPos + _startingPos) / 2;
    var buttonHide = 0.0;
    if ((_startingPos - middle).abs() > _positionTolerance) {
      buttonHide =
          (1 -
                  ((middle - _animationController.value) /
                          (_startingPos - middle))
                      .abs())
              .abs();
    }

    setState(() {
      _pos = _animationController.value;
      if ((endingPos - _pos).abs() < (_startingPos - _pos).abs()) {
        _visibleButtonIndex = _endingIndex;
      }
      _buttonHide = buttonHide.clamp(0.0, 1.0);
    });
  }

  void _handleTap(int index) {
    if (_animationController.isAnimating) {
      return;
    }
    widget.onTap(index);
    if (index == _endingIndex) {
      return;
    }
    _animateToIndex(index);
  }

  void _animateToIndex(int index) {
    final newPosition = index / _length;
    if ((newPosition - _pos).abs() <= _positionTolerance) {
      setState(() {
        _startingPos = newPosition;
        _endingIndex = index;
        _visibleButtonIndex = index;
        _buttonHide = 0;
      });
      _animationController.value = newPosition;
      return;
    }

    setState(() {
      _startingPos = _pos;
      _endingIndex = index;
    });
    _animationController.animateTo(
      newPosition,
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final textDirection = Directionality.of(context);
    final platform = Theme.of(context).platform;
    final bottomFactor = switch (platform) {
      TargetPlatform.iOS || TargetPlatform.macOS => 0.45,
      _ => 0.55,
    };
    final inactiveColor = widget.isLight
        ? const Color(0xFF3F3A4B)
        : Colors.white.withValues(alpha: 0.74);
    final labelStyle = TextStyle(
      color: inactiveColor,
      fontSize: 11,
      height: 1,
      fontWeight: FontWeight.w800,
    );
    final barColor = widget.isLight
        ? Colors.white.withValues(alpha: 0.70)
        : const Color(0xFF0C0918).withValues(alpha: 0.70);
    final borderColor = Colors.white.withValues(
      alpha: widget.isLight ? 0.62 : 0.18,
    );

    return SizedBox(
      height: _navTotalHeight,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final maxWidth = constraints.maxWidth;
          return Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.bottomCenter,
            children: <Widget>[
              Positioned(
                bottom: _navBarHeight - 105,
                left: textDirection == TextDirection.rtl
                    ? null
                    : _pos * maxWidth,
                right: textDirection == TextDirection.rtl
                    ? _pos * maxWidth
                    : null,
                width: maxWidth / _length,
                child: Center(
                  child: Transform.translate(
                    offset: Offset(0, (_buttonHide - 1) * 80),
                    child: Opacity(
                      opacity: (1 - _buttonHide).clamp(0.0, 1.0),
                      child: _FloatingLiquidButton(
                        icon: widget.items[_visibleButtonIndex].icon,
                        isLight: widget.isLight,
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                height: _navBarHeight,
                child: CustomPaint(
                  foregroundPainter: _CurvedLiquidNavBorderPainter(
                    startingLoc: _pos,
                    itemsLength: _length,
                    textDirection: textDirection,
                    bottomFactor: bottomFactor,
                    borderColor: borderColor,
                  ),
                  child: ClipPath(
                    clipper: _CurvedLiquidNavClipper(
                      startingLoc: _pos,
                      itemsLength: _length,
                      textDirection: textDirection,
                      bottomFactor: bottomFactor,
                    ),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: barColor,
                          boxShadow: <BoxShadow>[
                            BoxShadow(
                              color: AppColors.violet.withValues(
                                alpha: widget.isLight ? 0.11 : 0.24,
                              ),
                              blurRadius: 24,
                              offset: const Offset(0, 14),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                height: _navBarHeight,
                child: Row(
                  children: <Widget>[
                    for (var index = 0; index < widget.items.length; index++)
                      _CurvedLiquidNavItemWidget(
                        onTap: _handleTap,
                        position: _pos,
                        length: _length,
                        index: index,
                        icon: widget.items[index].icon,
                        label: widget.items[index].label,
                        iconColor: inactiveColor,
                        labelStyle: labelStyle,
                      ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _FloatingLiquidButton extends StatelessWidget {
  const _FloatingLiquidButton({required this.icon, required this.isLight});

  final IconData icon;
  final bool isLight;

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: <Color>[
                Colors.white.withValues(alpha: isLight ? 0.78 : 0.22),
                AppColors.violet.withValues(alpha: isLight ? 0.92 : 0.82),
                AppColors.cyan.withValues(alpha: isLight ? 0.72 : 0.46),
              ],
            ),
            border: Border.all(
              color: Colors.white.withValues(alpha: isLight ? 0.72 : 0.34),
              width: 1.2,
            ),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: AppColors.violet.withValues(alpha: 0.42),
                blurRadius: 22,
                offset: const Offset(0, 10),
              ),
              BoxShadow(
                color: AppColors.cyan.withValues(alpha: 0.20),
                blurRadius: 14,
                offset: const Offset(-5, -4),
              ),
            ],
          ),
          child: SizedBox(
            width: 58,
            height: 58,
            child: Icon(icon, color: Colors.white, size: 27),
          ),
        ),
      ),
    );
  }
}

class _CurvedLiquidNavItemWidget extends StatelessWidget {
  const _CurvedLiquidNavItemWidget({
    required this.onTap,
    required this.position,
    required this.length,
    required this.index,
    required this.icon,
    required this.label,
    required this.iconColor,
    required this.labelStyle,
  });

  final ValueChanged<int> onTap;
  final double position;
  final int length;
  final int index;
  final IconData icon;
  final String label;
  final Color iconColor;
  final TextStyle labelStyle;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Semantics(
        button: true,
        selected:
            (position - (1.0 / length * index)).abs() < _positionTolerance,
        label: label,
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () => onTap(index),
          child: Column(
            children: <Widget>[
              Expanded(
                flex: 2,
                child: _CurvedLiquidNavIcon(
                  position: position,
                  length: length,
                  index: index,
                  icon: icon,
                  color: iconColor,
                ),
              ),
              Expanded(
                child: Align(
                  alignment: Alignment.center,
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: labelStyle,
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}

class _CurvedLiquidNavIcon extends StatelessWidget {
  const _CurvedLiquidNavIcon({
    required this.position,
    required this.length,
    required this.index,
    required this.icon,
    required this.color,
  });

  final double position;
  final int length;
  final int index;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final desiredPosition = 1.0 / length * index;
    final difference = (position - desiredPosition).abs();
    final verticalAlignment = 1 - length * difference;
    final opacity = difference < 1.0 / length * 0.99
        ? (length * difference).clamp(0.0, 1.0)
        : 1.0;

    return Transform.translate(
      offset: Offset(0, difference < 1.0 / length ? verticalAlignment * 40 : 0),
      child: Opacity(
        opacity: opacity,
        child: Center(child: Icon(icon, color: color, size: 25)),
      ),
    );
  }
}

class _CurvedLiquidNavClipper extends CustomClipper<Path> {
  const _CurvedLiquidNavClipper({
    required this.startingLoc,
    required this.itemsLength,
    required this.textDirection,
    required this.bottomFactor,
  });

  final double startingLoc;
  final int itemsLength;
  final TextDirection textDirection;
  final double bottomFactor;

  @override
  Path getClip(Size size) {
    return _buildCurvedNavPath(
      size: size,
      startingLoc: startingLoc,
      itemsLength: itemsLength,
      textDirection: textDirection,
      bottomFactor: bottomFactor,
    );
  }

  @override
  bool shouldReclip(covariant _CurvedLiquidNavClipper oldClipper) {
    return oldClipper.startingLoc != startingLoc ||
        oldClipper.itemsLength != itemsLength ||
        oldClipper.textDirection != textDirection ||
        oldClipper.bottomFactor != bottomFactor;
  }
}

class _CurvedLiquidNavBorderPainter extends CustomPainter {
  const _CurvedLiquidNavBorderPainter({
    required this.startingLoc,
    required this.itemsLength,
    required this.textDirection,
    required this.bottomFactor,
    required this.borderColor,
  });

  final double startingLoc;
  final int itemsLength;
  final TextDirection textDirection;
  final double bottomFactor;
  final Color borderColor;

  @override
  void paint(Canvas canvas, Size size) {
    final path = _buildCurvedNavPath(
      size: size,
      startingLoc: startingLoc,
      itemsLength: itemsLength,
      textDirection: textDirection,
      bottomFactor: bottomFactor,
    );
    final paint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _CurvedLiquidNavBorderPainter oldDelegate) {
    return oldDelegate.startingLoc != startingLoc ||
        oldDelegate.itemsLength != itemsLength ||
        oldDelegate.textDirection != textDirection ||
        oldDelegate.bottomFactor != bottomFactor ||
        oldDelegate.borderColor != borderColor;
  }
}

Path _buildCurvedNavPath({
  required Size size,
  required double startingLoc,
  required int itemsLength,
  required TextDirection textDirection,
  required double bottomFactor,
}) {
  final span = 1.0 / itemsLength;
  final initialLoc = startingLoc + (span - _navCurveSpan) / 2;
  final loc = textDirection == TextDirection.rtl
      ? (1 - _navCurveSpan) - initialLoc
      : initialLoc;
  const bottomRadius = 26.0;

  return Path()
    ..moveTo(0, 0)
    ..lineTo(size.width * (loc - 0.05), 0)
    ..cubicTo(
      size.width * (loc + _navCurveSpan * 0.2),
      size.height * 0.05,
      size.width * loc,
      size.height * bottomFactor,
      size.width * (loc + _navCurveSpan * 0.5),
      size.height * bottomFactor,
    )
    ..cubicTo(
      size.width * (loc + _navCurveSpan),
      size.height * bottomFactor,
      size.width * (loc + _navCurveSpan * 0.8),
      size.height * 0.05,
      size.width * (loc + _navCurveSpan + 0.05),
      0,
    )
    ..lineTo(size.width, 0)
    ..lineTo(size.width, size.height - bottomRadius)
    ..quadraticBezierTo(
      size.width,
      size.height,
      size.width - bottomRadius,
      size.height,
    )
    ..lineTo(bottomRadius, size.height)
    ..quadraticBezierTo(0, size.height, 0, size.height - bottomRadius)
    ..lineTo(0, 0)
    ..close();
}

class _QDoneNavItem {
  const _QDoneNavItem({required this.icon, required this.label});

  final IconData icon;
  final String label;
}
