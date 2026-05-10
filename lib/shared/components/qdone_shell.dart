import 'package:curved_labeled_navigation_bar/curved_navigation_bar.dart';
import 'package:curved_labeled_navigation_bar/curved_navigation_bar_item.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:qdone/core/localization/qdone_localizations.dart';
import 'package:qdone/core/theme/app_colors.dart';
import 'package:qdone/core/widgets/liquid_background.dart';

class QDoneShell extends StatelessWidget {
  const QDoneShell({super.key, required this.location, required this.child});

  final String location;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LiquidBackground(
      child: RepaintBoundary(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          extendBody: true,
          body: SafeArea(bottom: false, child: child),
          bottomNavigationBar: _CurvedQDoneNavigation(location: location),
        ),
      ),
    );
  }
}

class _CurvedQDoneNavigation extends StatelessWidget {
  const _CurvedQDoneNavigation({required this.location});

  final String location;

  @override
  Widget build(BuildContext context) {
    final strings = QDoneLocalizations.of(context);
    final isLight = Theme.of(context).brightness == Brightness.light;
    final index = switch (location) {
      '/calendar' => 0,
      '/menu' => 2,
      _ => 1,
    };
    final barColor = isLight
        ? const Color(0xFFF9F7FF)
        : const Color(0xFF171121);
    final inactiveColor = isLight
        ? const Color(0xFF4B445C)
        : Colors.white.withValues(alpha: 0.72);
    final labelStyle = TextStyle(
      color: inactiveColor,
      fontSize: 11,
      fontWeight: FontWeight.w800,
    );

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.only(top: 6),
        child: CurvedNavigationBar(
          index: index,
          height: 68,
          iconPadding: 12,
          color: barColor,
          buttonBackgroundColor: AppColors.violet,
          backgroundColor: Colors.transparent,
          animationCurve: Curves.easeOutCubic,
          animationDuration: const Duration(milliseconds: 260),
          onTap: (value) {
            final path = switch (value) {
              0 => '/calendar',
              2 => '/menu',
              _ => '/tasks',
            };
            if (path != location) {
              context.go(path);
            }
          },
          items: <CurvedNavigationBarItem>[
            CurvedNavigationBarItem(
              child: Icon(
                Icons.calendar_month_rounded,
                color: index == 0 ? Colors.white : inactiveColor,
                size: 26,
              ),
              label: strings.text('calendar'),
              labelStyle: labelStyle,
            ),
            CurvedNavigationBarItem(
              child: Icon(
                Icons.check_circle_rounded,
                color: index == 1 ? Colors.white : inactiveColor,
                size: 28,
              ),
              label: strings.text('tasks'),
              labelStyle: labelStyle,
            ),
            CurvedNavigationBarItem(
              child: Icon(
                Icons.tune_rounded,
                color: index == 2 ? Colors.white : inactiveColor,
                size: 26,
              ),
              label: strings.text('menu'),
              labelStyle: labelStyle,
            ),
          ],
        ),
      ),
    );
  }
}
