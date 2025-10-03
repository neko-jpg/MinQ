import 'dart:async';

import 'package:flutter/services.dart';

/// Provides a unified method channel API for HealthKit / Google Fit integrations.
class FitnessBridge {
  FitnessBridge({
    MethodChannel? channel,
  }) : _channel = channel ?? const MethodChannel('miinq/fitness_bridge');

  final MethodChannel _channel;

  Future<bool> isAvailable() async {
    final available = await _channel.invokeMethod<bool>('isAvailable');
    return available ?? false;
  }

  Future<int> fetchDailySteps(DateTime date) async {
    final result = await _channel.invokeMethod<int>('fetchDailySteps', {
      'year': date.year,
      'month': date.month,
      'day': date.day,
    });
    return result ?? 0;
  }

  Future<void> syncHabitCompletion({
    required String habitId,
    required DateTime completionDate,
    required int steps,
  }) async {
    await _channel.invokeMethod<void>('syncHabitCompletion', {
      'habitId': habitId,
      'timestamp': completionDate.millisecondsSinceEpoch,
      'steps': steps,
    });
  }
}
