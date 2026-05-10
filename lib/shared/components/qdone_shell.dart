import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_to_do_list_app/core/localization/qdone_localizations.dart';
import 'package:flutter_to_do_list_app/core/theme/app_colors.dart';
import 'package:flutter_to_do_list_app/core/widgets/glass_panel.dart';
import 'package:flutter_to_do_list_app/core/widgets/liquid_background.dart';

class QDoneShell extends StatelessWidget {
  const QDoneShell({super.key, required this.location, required this.child});

  final String location;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LiquidBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBody: true,
        body: SafeArea(bottom: false, child: child),
        bottomNavigationBar: _LiquidBottomNav(location: location),
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
      _NavItem(
        '/tasks',
        Icons.check_circle_rounded,
        strings.text('tasks'),
        primary: true,
      ),
      _NavItem('/menu', Icons.tune_rounded, strings.text('menu')),
    ];
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
      child: GlassPanel(
        borderRadius: 30,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        opacity: 0.16,
        child: Row(
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
        ? Colors.white.withValues(alpha: 0.34)
        : Colors.transparent;

    return Semantics(
      button: true,
      selected: active,
      label: item.label,
      child: AnimatedScale(
        scale: active && item.primary ? 1.04 : 1,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(24),
            onTap: onTap,
            child: AnimatedContainer(
              height: item.primary ? 58 : 52,
              duration: const Duration(milliseconds: 260),
              curve: Curves.easeOutCubic,
              decoration: BoxDecoration(
                gradient: active ? AppColors.liquidGradient : null,
                color: active ? null : inactiveBackground,
                borderRadius: BorderRadius.circular(24),
                boxShadow: active
                    ? <BoxShadow>[
                        BoxShadow(
                          color: AppColors.violet.withValues(alpha: 0.35),
                          blurRadius: 22,
                          offset: const Offset(0, 10),
                        ),
                      ]
                    : null,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Icon(
                    item.icon,
                    size: item.primary ? 25 : 23,
                    color: active ? Colors.white : inactiveColor,
                  ),
                  AnimatedSize(
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOutCubic,
                    child: active
                        ? Padding(
                            padding: const EdgeInsets.only(left: 7),
                            child: Text(
                              item.label,
                              maxLines: 1,
                              overflow: TextOverflow.fade,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                              ),
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  const _NavItem(this.path, this.icon, this.label, {this.primary = false});

  final String path;
  final IconData icon;
  final String label;
  final bool primary;
}
