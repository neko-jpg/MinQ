import 'dart:async';

import 'package:flutter/services.dart';

/// Platform channel facade for managing Live Activities / Android Live Widgets.
class LiveActivityChannel {
  /// Creates a new [LiveActivityChannel].
  LiveActivityChannel({MethodChannel? channel})
      : _channel = channel ?? const MethodChannel('miinq/live_activity');

  final MethodChannel _channel;

  /// Starts a new progress-based Live Activity.
  Future<void> startProgressActivity({
    required String questId,
    required String title,
    required int completed,
    required int total,
  }) async {
    await _channel.invokeMethod<void>('start', {
      'questId': questId,
      'title': title,
      'completed': completed,
      'total': total,
    });
  }

  /// Updates an existing progress-based Live Activity.
  Future<void> updateProgress({
    required String questId,
    required int completed,
    required int total,
  }) async {
    await _channel.invokeMethod<void>('update', {
      'questId': questId,
      'completed': completed,
      'total': total,
    });
  }

  /// Ends a progress-based Live Activity.
  Future<void> endProgress(String questId) async {
    await _channel.invokeMethod<void>('end', {'questId': questId});
  }
}
