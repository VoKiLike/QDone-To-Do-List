import 'package:flutter/material.dart';
import 'package:qdone/core/theme/app_colors.dart';

enum NeonControlStyle { primary, secondary, danger, quiet }

class NeonActionButton extends StatefulWidget {
  const NeonActionButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.style = NeonControlStyle.secondary,
    this.isLoading = false,
    this.fullWidth = false,
    this.height = 48,
    this.attentionGlow = false,
  });

  final Widget label;
  final VoidCallback? onPressed;
  final Widget? icon;
  final NeonControlStyle style;
  final bool isLoading;
  final bool fullWidth;
  final double height;
  final bool attentionGlow;

  @override
  State<NeonActionButton> createState() => _NeonActionButtonState();
}

class _NeonActionButtonState extends State<NeonActionButton>
    with SingleTickerProviderStateMixin {
  bool _pressed = false;
  AnimationController? _attentionController;

  bool get _enabled => widget.onPressed != null && !widget.isLoading;

  @override
  void initState() {
    super.initState();
    _syncAttentionAnimation();
  }

  @override
  void didUpdateWidget(covariant NeonActionButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.attentionGlow != widget.attentionGlow) {
      _syncAttentionAnimation();
    }
  }

  @override
  void dispose() {
    _attentionController?.dispose();
    super.dispose();
  }

  void _syncAttentionAnimation() {
    if (!widget.attentionGlow) {
      _attentionController?.dispose();
      _attentionController = null;
      return;
    }

    _attentionController ??= AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat();
  }

  @override
  Widget build(BuildContext context) {
    final theme = _NeonTokens.from(context, widget.style, _enabled);
    final pressedTheme = theme.pressed();
    final attentionActive = widget.attentionGlow && _enabled && !_pressed;
    final attentionController = _attentionController;
    final currentTheme = _pressed && _enabled
        ? pressedTheme
        : attentionActive && attentionController != null
        ? theme.attention(attentionController.value)
        : theme;
    final radius = BorderRadius.circular(18);
    final textStyle = Theme.of(context).textTheme.labelLarge?.copyWith(
      color: currentTheme.foreground,
      fontWeight: FontWeight.w900,
      letterSpacing: 0,
    );
    final buttonSurface = AnimatedScale(
      scale: _pressed && _enabled ? 0.98 : 1,
      duration: const Duration(milliseconds: 140),
      curve: Curves.easeOutCubic,
      child: AnimatedBuilder(
        animation: attentionController ?? kAlwaysDismissedAnimation,
        builder: (context, _) {
          final animatedTheme = _pressed && _enabled
              ? pressedTheme
              : attentionActive && attentionController != null
              ? theme.attention(attentionController.value)
              : theme;
          return DecoratedBox(
            decoration: BoxDecoration(
              gradient: animatedTheme.gradient,
              color: animatedTheme.fill,
              borderRadius: radius,
              border: Border.all(color: animatedTheme.border, width: 1.1),
              boxShadow: animatedTheme.shadows,
            ),
            child: ClipRRect(
              borderRadius: radius,
              child: Stack(
                children: <Widget>[
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      minWidth: widget.fullWidth ? 0 : 96,
                    ),
                    child: SizedBox(
                      width: widget.fullWidth ? double.infinity : null,
                      height: widget.height,
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: _ButtonContent(
                            label: widget.label,
                            icon: widget.icon,
                            isLoading: widget.isLoading,
                            foreground: animatedTheme.foreground,
                            textStyle: textStyle?.copyWith(
                              color: animatedTheme.foreground,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (attentionActive && attentionController != null)
                    Positioned.fill(
                      child: IgnorePointer(
                        child: _AttentionSweep(value: attentionController.value),
                      ),
                    ),
                  if (attentionActive && attentionController != null)
                    Positioned(
                      left: 16,
                      right: 16,
                      bottom: 0,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: <Color>[
                              AppColors.cyan.withValues(alpha: 0),
                              AppColors.cyan.withValues(alpha: 0.50),
                              AppColors.neonPurple.withValues(alpha: 0.36),
                              AppColors.neonPurple.withValues(alpha: 0),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(99),
                        ),
                        child: const SizedBox(height: 2),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );

    final content = widget.attentionGlow
        ? AnimatedBuilder(
            animation: attentionController ?? kAlwaysDismissedAnimation,
            builder: (context, child) {
              final t = attentionController?.value ?? 0;
              final scale = attentionActive
                  ? 1 + (0.015 * (1 - (2 * t - 1).abs()))
                  : 1.0;
              return Transform.scale(scale: scale, child: child);
            },
            child: buttonSurface,
          )
        : buttonSurface;

    return Semantics(
      button: true,
      enabled: _enabled,
      child: Material(
        color: Colors.transparent,
        borderRadius: radius,
        child: InkWell(
          onTap: _enabled ? widget.onPressed : null,
          onHighlightChanged: (value) => setState(() => _pressed = value),
          borderRadius: radius,
          splashColor: currentTheme.splash,
          highlightColor: currentTheme.splash.withValues(alpha: 0.10),
          child: content,
        ),
      ),
    );
  }
}

class NeonIconButton extends StatefulWidget {
  const NeonIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    required this.tooltip,
    this.style = NeonControlStyle.secondary,
    this.size = 44,
    this.radius = 18,
  });

  final Widget icon;
  final VoidCallback? onPressed;
  final String tooltip;
  final NeonControlStyle style;
  final double size;
  final double radius;

  @override
  State<NeonIconButton> createState() => _NeonIconButtonState();
}

class _NeonIconButtonState extends State<NeonIconButton> {
  bool _pressed = false;

  bool get _enabled => widget.onPressed != null;

  @override
  Widget build(BuildContext context) {
    final theme = _NeonTokens.from(context, widget.style, _enabled);
    final pressedTheme = theme.pressed();
    final currentTheme = _pressed && _enabled ? pressedTheme : theme;
    final radius = BorderRadius.circular(widget.radius);
    return Tooltip(
      message: widget.tooltip,
      child: Semantics(
        button: true,
        enabled: _enabled,
        label: widget.tooltip,
        child: Material(
          color: Colors.transparent,
          borderRadius: radius,
          child: InkWell(
            onTap: widget.onPressed,
            onHighlightChanged: (value) => setState(() => _pressed = value),
            borderRadius: radius,
            splashColor: currentTheme.splash,
            child: AnimatedScale(
              scale: _pressed && _enabled ? 0.94 : 1,
              duration: const Duration(milliseconds: 130),
              curve: Curves.easeOutCubic,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: currentTheme.gradient,
                  color: currentTheme.fill,
                  borderRadius: radius,
                  border: Border.all(color: currentTheme.border, width: 1.05),
                  boxShadow: currentTheme.shadows,
                ),
                child: SizedBox.square(
                  dimension: widget.size,
                  child: IconTheme.merge(
                    data: IconThemeData(
                      color: currentTheme.foreground,
                      size: 22,
                    ),
                    child: widget.icon,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class NeonSwitchTile extends StatelessWidget {
  const NeonSwitchTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final border = value ? AppColors.cyan : AppColors.neonPurple;
    return _PressableScale(
      enabled: true,
      builder: (context, pressed) {
        final activeBorder = pressed ? AppColors.cyan : border;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOutCubic,
          margin: const EdgeInsets.symmetric(vertical: 4),
          padding: const EdgeInsets.fromLTRB(12, 10, 8, 10),
          decoration: BoxDecoration(
            color: isLight
                ? Colors.white.withValues(
                    alpha: pressed
                        ? 0.90
                        : value
                        ? 0.80
                        : 0.58,
                  )
                : Colors.white.withValues(
                    alpha: pressed
                        ? 0.105
                        : value
                        ? 0.075
                        : 0.045,
                  ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: activeBorder.withValues(
                alpha: pressed
                    ? 0.58
                    : value
                    ? 0.42
                    : 0.20,
              ),
            ),
            boxShadow: pressed || value
                ? <BoxShadow>[
                    BoxShadow(
                      color: activeBorder.withValues(
                        alpha: pressed
                            ? isLight
                                  ? 0.18
                                  : 0.26
                            : isLight
                            ? 0.13
                            : 0.18,
                      ),
                      blurRadius: pressed ? 20 : 16,
                      offset: const Offset(0, 7),
                    ),
                  ]
                : const <BoxShadow>[],
          ),
          child: Row(
            children: <Widget>[
              DecoratedBox(
                decoration: BoxDecoration(
                  color: activeBorder.withValues(
                    alpha: pressed
                        ? 0.22
                        : value
                        ? 0.17
                        : 0.10,
                  ),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: activeBorder.withValues(
                      alpha: pressed ? 0.40 : 0.28,
                    ),
                  ),
                ),
                child: SizedBox.square(
                  dimension: 38,
                  child: Icon(icon, color: activeBorder, size: 20),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              IgnorePointer(
                child: Switch.adaptive(
                  value: value,
                  activeColor: AppColors.cyan,
                  activeTrackColor: AppColors.cyan.withValues(
                    alpha: pressed ? 0.46 : 0.34,
                  ),
                  inactiveThumbColor: pressed
                      ? AppColors.neonPurple
                      : isLight
                      ? const Color(0xFF6D7182)
                      : Colors.white.withValues(alpha: 0.72),
                  inactiveTrackColor: pressed
                      ? AppColors.neonPurple.withValues(alpha: 0.24)
                      : isLight
                      ? const Color(0xFFD8DCE8)
                      : Colors.white.withValues(alpha: 0.12),
                  onChanged: onChanged,
                ),
              ),
            ],
          ),
        );
      },
      onTap: () => onChanged(!value),
    );
  }
}

class _PressableScale extends StatefulWidget {
  const _PressableScale({
    required this.enabled,
    required this.builder,
    required this.onTap,
  });

  final bool enabled;
  final Widget Function(BuildContext context, bool pressed) builder;
  final VoidCallback onTap;

  @override
  State<_PressableScale> createState() => _PressableScaleState();
}

class _PressableScaleState extends State<_PressableScale> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: _pressed && widget.enabled ? 0.99 : 1,
      duration: const Duration(milliseconds: 130),
      curve: Curves.easeOutCubic,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: widget.enabled ? widget.onTap : null,
          onHighlightChanged: (value) => setState(() => _pressed = value),
          borderRadius: BorderRadius.circular(20),
          splashColor: AppColors.cyan.withValues(alpha: 0.16),
          highlightColor: AppColors.cyan.withValues(alpha: 0.08),
          child: widget.builder(context, _pressed && widget.enabled),
        ),
      ),
    );
  }
}

class _AttentionSweep extends StatelessWidget {
  const _AttentionSweep({required this.value});

  final double value;

  @override
  Widget build(BuildContext context) {
    return FractionalTranslation(
      translation: Offset(-1.15 + value * 2.3, 0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Transform.rotate(
          angle: -0.28,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: <Color>[
                  Colors.white.withValues(alpha: 0),
                  Colors.white.withValues(alpha: 0.24),
                  AppColors.cyan.withValues(alpha: 0.18),
                  Colors.white.withValues(alpha: 0),
                ],
              ),
            ),
            child: const SizedBox(width: 34, height: 86),
          ),
        ),
      ),
    );
  }
}

class _ButtonContent extends StatelessWidget {
  const _ButtonContent({
    required this.label,
    required this.icon,
    required this.isLoading,
    required this.foreground,
    required this.textStyle,
  });

  final Widget label;
  final Widget? icon;
  final bool isLoading;
  final Color foreground;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return SizedBox.square(
        dimension: 18,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: foreground,
        ),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        if (icon != null) ...<Widget>[
          IconTheme.merge(
            data: IconThemeData(color: foreground, size: 20),
            child: icon!,
          ),
          const SizedBox(width: 8),
        ],
        Flexible(
          child: DefaultTextStyle.merge(
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: textStyle,
            child: label,
          ),
        ),
      ],
    );
  }
}

class _NeonTokens {
  const _NeonTokens({
    required this.fill,
    required this.border,
    required this.foreground,
    required this.splash,
    required this.gradient,
    required this.shadows,
    this.isDanger = false,
  });

  static const _dangerRed = Color(0xFFFF4D6D);
  static const _dangerDeepRed = Color(0xFF9F1239);

  final Color fill;
  final Color border;
  final Color foreground;
  final Color splash;
  final Gradient? gradient;
  final List<BoxShadow> shadows;
  final bool isDanger;

  _NeonTokens pressed() {
    final pressAccent = isDanger ? _dangerRed : AppColors.cyan;
    final pressShadow = isDanger ? _dangerRed : AppColors.neonPurple;
    return _NeonTokens(
      fill: Color.alphaBlend(border.withValues(alpha: 0.30), fill),
      border: Color.alphaBlend(pressAccent.withValues(alpha: 0.42), border),
      foreground: foreground,
      splash: Color.alphaBlend(pressAccent.withValues(alpha: 0.32), splash),
      gradient: gradient == null
          ? LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: <Color>[
                Color.alphaBlend(pressAccent.withValues(alpha: 0.24), fill),
                Color.alphaBlend(
                  pressShadow.withValues(alpha: 0.18),
                  fill,
                ),
              ],
            )
          : const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: <Color>[
                AppColors.cyan,
                AppColors.violet,
                AppColors.neonPurple,
              ],
            ),
      shadows: shadows
          .map(
            (shadow) => BoxShadow(
              color: shadow.color.withValues(alpha: 0.52),
              blurRadius: shadow.blurRadius + 10,
              spreadRadius: shadow.spreadRadius,
              offset: shadow.offset,
            ),
          )
          .toList()
        ..add(
          BoxShadow(
            color: pressAccent.withValues(alpha: 0.34),
            blurRadius: 24,
            offset: const Offset(0, 7),
          ),
        )
        ..add(
          BoxShadow(
            color: pressShadow.withValues(alpha: 0.20),
            blurRadius: 18,
            offset: const Offset(0, 4),
          ),
        ),
      isDanger: isDanger,
    );
  }

  _NeonTokens attention(double value) {
    final pulse = 1 - (2 * value - 1).abs();
    return _NeonTokens(
      fill: Color.alphaBlend(
        AppColors.cyan.withValues(alpha: 0.025 + pulse * 0.035),
        fill,
      ),
      border: Color.alphaBlend(
        AppColors.cyan.withValues(alpha: 0.20 + pulse * 0.22),
        border,
      ),
      foreground: foreground,
      splash: splash,
      gradient: gradient,
      shadows: <BoxShadow>[
        ...shadows,
        BoxShadow(
          color: AppColors.cyan.withValues(alpha: 0.10 + pulse * 0.12),
          blurRadius: 18 + pulse * 8,
          offset: const Offset(0, 7),
        ),
      ],
    );
  }

  static _NeonTokens from(
    BuildContext context,
    NeonControlStyle style,
    bool enabled,
  ) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    if (!enabled) {
      return _NeonTokens(
        fill: isLight
            ? Colors.white.withValues(alpha: 0.44)
            : Colors.white.withValues(alpha: 0.045),
        border: Colors.white.withValues(alpha: isLight ? 0.24 : 0.10),
        foreground: Theme.of(context)
            .colorScheme
            .onSurface
            .withValues(alpha: isLight ? 0.34 : 0.30),
        splash: Colors.transparent,
        gradient: null,
        shadows: const <BoxShadow>[],
      );
    }

    return switch (style) {
      NeonControlStyle.primary => _NeonTokens(
          fill: AppColors.violet,
          border: Colors.white.withValues(alpha: isLight ? 0.62 : 0.36),
          foreground: Colors.white,
          splash: AppColors.cyan.withValues(alpha: 0.20),
          gradient: AppColors.liquidGradient,
          shadows: <BoxShadow>[
            BoxShadow(
              color: AppColors.cyan.withValues(alpha: isLight ? 0.20 : 0.26),
              blurRadius: 16,
              offset: const Offset(0, 7),
            ),
            BoxShadow(
              color: AppColors.violet.withValues(alpha: isLight ? 0.14 : 0.22),
              blurRadius: 22,
              offset: const Offset(0, 10),
            ),
          ],
        ),
      NeonControlStyle.secondary => _NeonTokens(
          fill: isLight
              ? Colors.white.withValues(alpha: 0.76)
              : Colors.white.withValues(alpha: 0.065),
          border: AppColors.cyan.withValues(alpha: isLight ? 0.48 : 0.34),
          foreground: isLight ? const Color(0xFF1F2440) : AppColors.softWhite,
          splash: AppColors.cyan.withValues(alpha: 0.18),
          gradient: null,
          shadows: <BoxShadow>[
            BoxShadow(
              color: AppColors.cyan.withValues(alpha: isLight ? 0.10 : 0.14),
              blurRadius: 14,
              offset: const Offset(0, 7),
            ),
          ],
        ),
      NeonControlStyle.danger => _NeonTokens(
          fill: _NeonTokens._dangerRed.withValues(alpha: isLight ? 0.11 : 0.10),
          border: _NeonTokens._dangerRed.withValues(
            alpha: isLight ? 0.50 : 0.44,
          ),
          foreground: isLight
              ? _NeonTokens._dangerDeepRed
              : _NeonTokens._dangerRed,
          splash: _NeonTokens._dangerRed.withValues(alpha: 0.20),
          gradient: null,
          shadows: <BoxShadow>[
            BoxShadow(
              color: _NeonTokens._dangerRed.withValues(
                alpha: isLight ? 0.10 : 0.15,
              ),
              blurRadius: 14,
              offset: const Offset(0, 7),
            ),
          ],
          isDanger: true,
        ),
      NeonControlStyle.quiet => _NeonTokens(
          fill: isLight
              ? Colors.white.withValues(alpha: 0.58)
              : Colors.white.withValues(alpha: 0.040),
          border: AppColors.neonPurple.withValues(alpha: isLight ? 0.32 : 0.24),
          foreground: isLight ? const Color(0xFF2E2944) : AppColors.softWhite,
          splash: AppColors.neonPurple.withValues(alpha: 0.16),
          gradient: null,
          shadows: const <BoxShadow>[],
        ),
    };
  }
}
