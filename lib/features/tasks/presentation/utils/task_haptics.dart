import 'package:flutter/services.dart';

class TaskHaptics {
  const TaskHaptics._();

  static const MethodChannel _channel = MethodChannel('qdone/haptics');

  static Future<void> tap() async {
    try {
      await _channel.invokeMethod<void>('taskTap');
    } catch (_) {
      await HapticFeedback.lightImpact();
    }
  }
}
