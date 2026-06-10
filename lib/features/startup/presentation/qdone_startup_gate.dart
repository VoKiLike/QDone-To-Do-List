import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qdone/core/theme/app_colors.dart';
import 'package:qdone/core/widgets/qdone_brand_text.dart';
import 'package:qdone/features/settings/domain/user_settings.dart';
import 'package:qdone/features/settings/presentation/controllers/settings_controller.dart';
import 'package:qdone/features/tasks/presentation/controllers/tasks_controller.dart';

class QDoneStartupGate extends ConsumerStatefulWidget {
  const QDoneStartupGate({super.key, required this.child, this.onReleased});

  final Widget child;
  final VoidCallback? onReleased;

  @override
  ConsumerState<QDoneStartupGate> createState() => _QDoneStartupGateState();
}

class _QDoneStartupGateState extends ConsumerState<QDoneStartupGate>
    with SingleTickerProviderStateMixin {
  static const _minimumDuration = Duration(seconds: 5);
  static const _maximumNormalDuration = Duration(seconds: 7);

  late final AnimationController _brandController;
  late final Animation<double> _brandOpacity;
  late final Animation<double> _brandScale;
  late final Timer _minimumTimer;
  late final Timer _maximumTimer;
  bool _minimumElapsed = false;
  bool _maximumElapsed = false;
  bool _released = false;
  bool _removed = false;

  @override
  void initState() {
    super.initState();
    _trace('startup shown');
    _brandController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..forward();
    final curve = CurvedAnimation(
      parent: _brandController,
      curve: Curves.easeOutCubic,
    );
    _brandOpacity = Tween<double>(begin: 0, end: 1).animate(curve);
    _brandScale = Tween<double>(begin: 0.94, end: 1).animate(curve);
    _minimumTimer = Timer(_minimumDuration, () {
      if (!mounted) {
        return;
      }
      setState(() => _minimumElapsed = true);
    });
    _maximumTimer = Timer(_maximumNormalDuration, () {
      if (!mounted) {
        return;
      }
      setState(() => _maximumElapsed = true);
    });
  }

  @override
  void dispose() {
    _brandController.dispose();
    _minimumTimer.cancel();
    _maximumTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settingsState = ref.watch(settingsControllerProvider);
    final tasksState = ref.watch(tasksControllerProvider);

    _releaseAfterBuildIfReady(settingsState, tasksState);

    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        widget.child,
        if (!_removed)
          IgnorePointer(
            ignoring: _released,
            child: AnimatedOpacity(
              opacity: _released ? 0 : 1,
              duration: const Duration(milliseconds: 260),
              curve: Curves.easeOutCubic,
              onEnd: () {
                if (mounted && _released && !_removed) {
                  setState(() => _removed = true);
                }
              },
              child: _QDoneBrandSplash(
                opacity: _brandOpacity,
                scale: _brandScale,
              ),
            ),
          ),
      ],
    );
  }

  void _releaseAfterBuildIfReady(
    AsyncValue<UserSettings> settingsState,
    AsyncValue<TasksFeedState> tasksState,
  ) {
    if (_released || !_minimumElapsed) {
      return;
    }
    final settingsReady = settingsState.hasValue || settingsState.hasError;
    final tasksReady =
        tasksState.hasValue || tasksState.hasError || _maximumElapsed;
    if (!settingsReady || !tasksReady) {
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _released) {
        return;
      }
      _trace('startup hidden');
      setState(() => _released = true);
      widget.onReleased?.call();
    });
  }
}

class _QDoneBrandSplash extends StatelessWidget {
  const _QDoneBrandSplash({required this.opacity, required this.scale});

  final Animation<double> opacity;
  final Animation<double> scale;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.darkNavy,
      child: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: <Color>[
              AppColors.darkNavy,
              AppColors.darkPanelSolid,
              AppColors.darkInk,
            ],
            stops: <double>[0, 0.54, 1],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: FadeTransition(
              opacity: opacity,
              child: ScaleTransition(
                scale: scale,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Image.asset(
                      'assets/images/qdone_logo.png',
                      width: 92,
                      height: 92,
                      filterQuality: FilterQuality.medium,
                    ),
                    const SizedBox(height: 18),
                    const QDoneBrandText(color: AppColors.darkText),
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

void _trace(String name) {
  if (kDebugMode || kProfileMode) {
    developer.Timeline.instantSync('qdone.$name');
  }
}
