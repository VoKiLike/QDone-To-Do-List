import 'dart:async';

import 'package:flutter/material.dart';

typedef QDoneTapFeedbackBuilder =
    Widget Function(BuildContext context, bool tapped);

class QDoneTapFeedback extends StatefulWidget {
  const QDoneTapFeedback({
    super.key,
    required this.onTap,
    required this.builder,
    this.borderRadius,
    this.customBorder,
    this.duration = const Duration(milliseconds: 200),
    this.focusColor,
    this.hoverColor,
    this.autofocus = false,
    this.focusNode,
  }) : assert(borderRadius == null || customBorder == null);

  final VoidCallback? onTap;
  final QDoneTapFeedbackBuilder builder;
  final BorderRadius? borderRadius;
  final ShapeBorder? customBorder;
  final Duration duration;
  final Color? focusColor;
  final Color? hoverColor;
  final bool autofocus;
  final FocusNode? focusNode;

  @override
  State<QDoneTapFeedback> createState() => _QDoneTapFeedbackState();
}

class _QDoneTapFeedbackState extends State<QDoneTapFeedback> {
  Timer? _timer;
  bool _tapped = false;

  @override
  void didUpdateWidget(covariant QDoneTapFeedback oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.onTap == null && _tapped) {
      _clearFeedback();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _handleTap() {
    final onTap = widget.onTap;
    if (onTap == null) {
      return;
    }
    _timer?.cancel();
    if (!_tapped) {
      setState(() => _tapped = true);
    }
    onTap();
    _timer = Timer(widget.duration, _clearFeedback);
  }

  void _clearFeedback() {
    _timer?.cancel();
    _timer = null;
    if (mounted && _tapped) {
      setState(() => _tapped = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: Colors.transparent,
      shape: widget.customBorder,
      borderRadius: widget.borderRadius,
      child: InkWell(
        onTap: widget.onTap == null ? null : _handleTap,
        autofocus: widget.autofocus,
        focusNode: widget.focusNode,
        borderRadius: widget.borderRadius,
        customBorder: widget.customBorder,
        splashFactory: NoSplash.splashFactory,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        overlayColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.pressed)) {
            return Colors.transparent;
          }
          if (states.contains(WidgetState.focused)) {
            return widget.focusColor ?? theme.focusColor;
          }
          if (states.contains(WidgetState.hovered)) {
            return widget.hoverColor ?? theme.hoverColor;
          }
          return Colors.transparent;
        }),
        child: widget.builder(context, _tapped && widget.onTap != null),
      ),
    );
  }
}

class QDoneMaterialTapFeedback extends StatelessWidget {
  const QDoneMaterialTapFeedback({
    super.key,
    required this.onTap,
    required this.semanticLabel,
    required this.child,
    this.borderRadius = const BorderRadius.all(Radius.circular(18)),
    this.flashColor,
    this.tappedScale = 0.98,
  });

  final VoidCallback? onTap;
  final String semanticLabel;
  final Widget child;
  final BorderRadius borderRadius;
  final Color? flashColor;
  final double tappedScale;

  @override
  Widget build(BuildContext context) {
    final color =
        flashColor ??
        Theme.of(context).colorScheme.primary.withValues(alpha: 0.22);
    return Semantics(
      button: true,
      enabled: onTap != null,
      label: semanticLabel,
      child: QDoneTapFeedback(
        onTap: onTap,
        borderRadius: borderRadius,
        builder: (context, tapped) {
          return AnimatedScale(
            scale: tapped && onTap != null ? tappedScale : 1,
            duration: const Duration(milliseconds: 140),
            curve: Curves.easeOutCubic,
            child: Stack(
              fit: StackFit.passthrough,
              children: <Widget>[
                ExcludeSemantics(
                  child: IgnorePointer(ignoring: true, child: child),
                ),
                Positioned.fill(
                  child: IgnorePointer(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 140),
                      curve: Curves.easeOutCubic,
                      decoration: BoxDecoration(
                        color: tapped ? color : Colors.transparent,
                        borderRadius: borderRadius,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
