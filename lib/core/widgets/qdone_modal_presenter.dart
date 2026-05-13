import 'package:flutter/material.dart';

class QDoneModalPresenter {
  const QDoneModalPresenter._();

  static const _sheetMaxHeightFactor = 0.92;
  static const _barrierOpacity = 0.78;

  static Future<T?> showSheet<T>({
    required BuildContext context,
    required WidgetBuilder builder,
    bool useRootNavigator = true,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      useRootNavigator: useRootNavigator,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: _barrierOpacity),
      builder: (modalContext) {
        final height = MediaQuery.sizeOf(modalContext).height;
        final viewInsets = MediaQuery.viewInsetsOf(modalContext);
        final availableHeight = (height - viewInsets.bottom)
            .clamp(0.0, height)
            .toDouble();
        return AnimatedPadding(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          padding: EdgeInsets.only(bottom: viewInsets.bottom),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: availableHeight * _sheetMaxHeightFactor,
            ),
            child: builder(modalContext),
          ),
        );
      },
    );
  }

  static Future<T?> showAppDialog<T>({
    required BuildContext context,
    required WidgetBuilder builder,
    bool useRootNavigator = true,
  }) {
    return showDialog<T>(
      context: context,
      useRootNavigator: useRootNavigator,
      builder: builder,
    );
  }

  static void close<T extends Object?>(BuildContext context, [T? result]) {
    Navigator.of(context).pop<T>(result);
  }
}
