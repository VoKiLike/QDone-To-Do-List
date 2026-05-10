import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:qdone/core/localization/qdone_localizations.dart';
import 'package:qdone/core/theme/app_colors.dart';
import 'package:qdone/core/widgets/glass_panel.dart';
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
          bottomNavigationBar: _LiquidBottomNav(location: location),
        ),
      ),
    );
  }
}

class _LiquidBottomNav extends StatelessWidget {
  const _LiquidBottomNav({required this.location});

  final String location;

  @override
  Widget build(BuildContext context) {
    final strings = QDoneLocalizations.of(context);
    final items = <_NavItem>[
      _NavItem(
        '/calendar',
        Icons.calendar_month_rounded,
        strings.text('calendar'),
      ),
      _NavItem('/tasks', Icons.check_circle_rounded, strings.text('tasks')),
      _NavItem('/menu', Icons.tune_rounded, strings.text('menu')),
    ];
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
      child: RepaintBoundary(
        child: GlassPanel(
          borderRadius: 28,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          opacity: 0.14,
          blurSigma: 10,
          shadowBlurRadius: 14,
          child: SizedBox(
            height: 60,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: items.map((item) {
                final active = location == item.path;
                return Expanded(
                  child: _NavButton(
                    item: item,
                    active: active,
                    onTap: () {
                      if (!active) {
                        context.go(item.path);
                      }
                    },
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.item,
    required this.active,
    required this.onTap,
  });

  final _NavItem item;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final inactiveColor = isLight
        ? const Color(0xFF343047).withValues(alpha: 0.78)
        : Colors.white70;
    final inactiveBackground = isLight
        ? Colors.white.withValues(alpha: 0.30)
        : Colors.transparent;
    final labelStyle = TextStyle(
      color: active ? Colors.white : inactiveColor,
      fontWeight: active ? FontWeight.w800 : FontWeight.w600,
      fontSize: 11,
    );

    return Semantics(
      button: true,
      selected: active,
      label: item.label,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 3),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(22),
            onTap: onTap,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              curve: Curves.easeOutCubic,
              decoration: BoxDecoration(
                gradient: active ? AppColors.liquidGradient : null,
                color: active ? null : inactiveBackground,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: active
                      ? Colors.white.withValues(alpha: 0.22)
                      : Colors.white.withValues(alpha: isLight ? 0.34 : 0.08),
                ),
                boxShadow: active
                    ? <BoxShadow>[
                        BoxShadow(
                          color: AppColors.violet.withValues(alpha: 0.22),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ]
                    : null,
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Icon(
                      item.icon,
                      size: 23,
                      color: active ? Colors.white : inactiveColor,
                    ),
                    const SizedBox(height: 3),
                    AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 120),
                      curve: Curves.easeOutCubic,
                      style: labelStyle,
                      child: Text(
                        item.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  const _NavItem(this.path, this.icon, this.label);

  final String path;
  final IconData icon;
  final String label;
}
