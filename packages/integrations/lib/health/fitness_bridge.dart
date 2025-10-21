import 'dart:async';

import 'package:flutter/services.dart';

/// Provides a unified method channel API for HealthKit / Google Fit integrations.
class FitnessBridge {
  /// Creates a new [FitnessBridge].
  FitnessBridge({MethodChannel? channel})
      : _channel = channel ?? const MethodChannel('miinq/fitness_bridge');

  final MethodChannel _channel;

  /// Checks if the fitness integration is available on the current platform.
  Future<bool> isAvailable() async {
    final available = await _channel.invokeMethod<bool>('isAvailable');
    return available ?? false;
  }

  /// Fetches the number of steps for a given [date].
  Future<int> fetchDailySteps(DateTime date) async {
    final result = await _channel.invokeMethod<int>('fetchDailySteps', {
      'year': date.year,
      'month': date.month,
      'day': date.day,
    });
    return result ?? 0;
  }

  /// Syncs a habit completion to the native fitness store.
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
