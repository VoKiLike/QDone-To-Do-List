import 'package:flutter/material.dart';
import 'package:qdone/core/theme/app_colors.dart';
import 'package:qdone/core/widgets/qdone_tap_feedback.dart';

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
    final tappedTheme = theme.tapped();
    final primary = AppColors.primaryFor(context);
    final secondary = AppColors.secondaryFor(context);
    final attentionController = _attentionController;
    final radius = BorderRadius.circular(18);

    return Semantics(
      button: true,
      enabled: _enabled,
      child: QDoneTapFeedback(
        onTap: _enabled ? widget.onPressed : null,
        borderRadius: radius,
        builder: (context, tapped) {
          final attentionActive = widget.attentionGlow && _enabled && !tapped;
          final textStyle = Theme.of(context).textTheme.labelLarge?.copyWith(
            color: tappedTheme.foreground,
            fontWeight: FontWeight.w900,
            letterSpacing: 0,
          );
          final buttonSurface = AnimatedScale(
            scale: tapped && _enabled ? 0.98 : 1,
            duration: const Duration(milliseconds: 140),
            curve: Curves.easeOutCubic,
            child: AnimatedBuilder(
              animation: attentionController ?? kAlwaysDismissedAnimation,
              builder: (context, _) {
                final animatedTheme = tapped && _enabled
                    ? tappedTheme
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
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
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
                              child: _AttentionSweep(
                                value: attentionController.value,
                              ),
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
                                    primary.withValues(alpha: 0),
                                    primary.withValues(alpha: 0.50),
                                    secondary.withValues(alpha: 0.36),
                                    secondary.withValues(alpha: 0),
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

          if (!widget.attentionGlow) {
            return buttonSurface;
          }
          return AnimatedBuilder(
            animation: attentionController ?? kAlwaysDismissedAnimation,
            builder: (context, child) {
              final t = attentionController?.value ?? 0;
              final scale = attentionActive
                  ? 1 + (0.015 * (1 - (2 * t - 1).abs()))
                  : 1.0;
              return Transform.scale(scale: scale, child: child);
            },
            child: buttonSurface,
          );
        },
      ),
    );
  }
}

class NeonIconButton extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    final theme = _NeonTokens.from(context, style, enabled);
    final tappedTheme = theme.tapped();
    final borderRadius = BorderRadius.circular(radius);
    return Tooltip(
      message: tooltip,
      child: Semantics(
        button: true,
        enabled: enabled,
        label: tooltip,
        child: QDoneTapFeedback(
          onTap: onPressed,
          borderRadius: borderRadius,
          builder: (context, tapped) {
            final currentTheme = tapped && enabled ? tappedTheme : theme;
            return AnimatedScale(
              scale: tapped && enabled ? 0.94 : 1,
              duration: const Duration(milliseconds: 130),
              curve: Curves.easeOutCubic,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: currentTheme.gradient,
                  color: currentTheme.fill,
                  borderRadius: borderRadius,
                  border: Border.all(color: currentTheme.border, width: 1.05),
                  boxShadow: currentTheme.shadows,
                ),
                child: SizedBox.square(
                  dimension: size,
                  child: IconTheme.merge(
                    data: IconThemeData(
                      color: currentTheme.foreground,
                      size: 22,
                    ),
                    child: icon,
                  ),
                ),
              ),
            );
          },
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
    final primary = AppColors.primaryFor(context);
    final secondary = AppColors.secondaryFor(context);
    final border = value ? primary : secondary;
    return QDoneTapFeedback(
      onTap: () => onChanged(!value),
      borderRadius: BorderRadius.circular(20),
      builder: (context, tapped) {
        final activeBorder = tapped ? primary : border;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOutCubic,
          margin: const EdgeInsets.symmetric(vertical: 4),
          padding: const EdgeInsets.fromLTRB(12, 10, 8, 10),
          decoration: BoxDecoration(
            color: Color.alphaBlend(
              activeBorder.withValues(
                alpha: tapped
                    ? isLight
                          ? 0.12
                          : 0.14
                    : value
                    ? isLight
                          ? 0.07
                          : 0.09
                    : 0,
              ),
              value
                  ? AppColors.elevatedSurface(context)
                  : AppColors.surface(context),
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: activeBorder.withValues(
                alpha: tapped
                    ? 0.58
                    : value
                    ? 0.42
                    : isLight
                    ? 0.42
                    : 0.20,
              ),
            ),
            boxShadow: tapped || value
                ? <BoxShadow>[
                    BoxShadow(
                      color: activeBorder.withValues(
                        alpha: tapped
                            ? isLight
                                  ? 0.18
                                  : 0.26
                            : isLight
                            ? 0.13
                            : 0.18,
                      ),
                      blurRadius: tapped ? 20 : 16,
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
                    alpha: tapped
                        ? 0.22
                        : value
                        ? 0.17
                        : 0.10,
                  ),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: activeBorder.withValues(alpha: tapped ? 0.40 : 0.28),
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
                  activeThumbColor: primary,
                  activeTrackColor: primary.withValues(
                    alpha: tapped
                        ? 0.58
                        : isLight
                        ? 0.46
                        : 0.34,
                  ),
                  inactiveThumbColor: tapped
                      ? secondary
                      : AppColors.subdued(context),
                  inactiveTrackColor: tapped
                      ? secondary.withValues(alpha: 0.28)
                      : AppColors.mutedSurface(context),
                  onChanged: onChanged,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _AttentionSweep extends StatelessWidget {
  const _AttentionSweep({required this.value});

  final double value;

  @override
  Widget build(BuildContext context) {
    final accent = AppColors.primaryFor(context);
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
                  accent.withValues(alpha: 0.18),
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
        child: CircularProgressIndicator(strokeWidth: 2, color: foreground),
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
    this.tapAccent = AppColors.cyan,
    this.tapShadow = AppColors.neonPurple,
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
  final Color tapAccent;
  final Color tapShadow;
  final bool isDanger;

  _NeonTokens tapped() {
    final pressAccent = isDanger ? _dangerRed : tapAccent;
    final pressShadow = isDanger ? _dangerRed : tapShadow;
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
                Color.alphaBlend(pressShadow.withValues(alpha: 0.18), fill),
              ],
            )
          : LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: <Color>[
                pressAccent,
                Color.alphaBlend(
                  pressShadow.withValues(alpha: 0.44),
                  pressAccent,
                ),
                pressShadow,
              ],
            ),
      shadows:
          shadows
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
      tapAccent: tapAccent,
      tapShadow: tapShadow,
    );
  }

  _NeonTokens attention(double value) {
    final pulse = 1 - (2 * value - 1).abs();
    return _NeonTokens(
      fill: Color.alphaBlend(
        tapAccent.withValues(alpha: 0.025 + pulse * 0.035),
        fill,
      ),
      border: Color.alphaBlend(
        tapAccent.withValues(alpha: 0.20 + pulse * 0.22),
        border,
      ),
      foreground: foreground,
      splash: splash,
      gradient: gradient,
      shadows: <BoxShadow>[
        ...shadows,
        BoxShadow(
          color: tapAccent.withValues(alpha: 0.10 + pulse * 0.12),
          blurRadius: 18 + pulse * 8,
          offset: const Offset(0, 7),
        ),
      ],
      tapAccent: tapAccent,
      tapShadow: tapShadow,
    );
  }

  static _NeonTokens from(
    BuildContext context,
    NeonControlStyle style,
    bool enabled,
  ) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final primary = AppColors.primaryFor(context);
    final secondary = AppColors.secondaryFor(context);
    if (!enabled) {
      return _NeonTokens(
        fill: AppColors.mutedSurface(context),
        border: AppColors.line(context).withValues(alpha: isLight ? 1 : 0.72),
        foreground: AppColors.subdued(
          context,
        ).withValues(alpha: isLight ? 0.72 : 0.54),
        splash: Colors.transparent,
        gradient: null,
        shadows: const <BoxShadow>[],
        tapAccent: primary,
        tapShadow: secondary,
      );
    }

    return switch (style) {
      NeonControlStyle.primary => _NeonTokens(
        fill: secondary,
        border: Colors.white.withValues(alpha: isLight ? 0.62 : 0.36),
        foreground: AppColors.accentForegroundFor(context),
        splash: primary.withValues(alpha: 0.20),
        gradient: AppColors.liquidGradientFor(context),
        shadows: <BoxShadow>[
          BoxShadow(
            color: primary.withValues(alpha: isLight ? 0.18 : 0.26),
            blurRadius: 16,
            offset: const Offset(0, 7),
          ),
          BoxShadow(
            color: secondary.withValues(alpha: isLight ? 0.14 : 0.22),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
        tapAccent: primary,
        tapShadow: secondary,
      ),
      NeonControlStyle.secondary => _NeonTokens(
        fill: AppColors.elevatedSurface(context),
        border: primary.withValues(alpha: isLight ? 0.72 : 0.34),
        foreground: AppColors.foreground(context),
        splash: primary.withValues(alpha: 0.18),
        gradient: null,
        shadows: <BoxShadow>[
          BoxShadow(
            color: primary.withValues(alpha: isLight ? 0.12 : 0.14),
            blurRadius: 14,
            offset: const Offset(0, 7),
          ),
        ],
        tapAccent: primary,
        tapShadow: secondary,
      ),
      NeonControlStyle.danger => _NeonTokens(
        fill: _NeonTokens._dangerRed.withValues(alpha: isLight ? 0.11 : 0.10),
        border: _NeonTokens._dangerRed.withValues(alpha: isLight ? 0.50 : 0.44),
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
        tapAccent: _NeonTokens._dangerRed,
        tapShadow: _NeonTokens._dangerDeepRed,
        isDanger: true,
      ),
      NeonControlStyle.quiet => _NeonTokens(
        fill: AppColors.surface(context),
        border: secondary.withValues(alpha: isLight ? 0.54 : 0.24),
        foreground: AppColors.foreground(context),
        splash: secondary.withValues(alpha: 0.16),
        gradient: null,
        shadows: const <BoxShadow>[],
        tapAccent: primary,
        tapShadow: secondary,
      ),
    };
  }
}
