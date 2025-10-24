import 'dart:async';

import 'package:flutter/services.dart';

/// Platform channel facade for managing Live Activities / Android Live Widgets.
class LiveActivityChannel {
  /// Creates a new [LiveActivityChannel].
  LiveActivityChannel({MethodChannel? channel})
    : _channel = channel ?? const MethodChannel('miinq/live_activity');

  final MethodChannel _channel;

  /// Starts a new progress-based live activity.
  Future<void> startProgressActivity({
    /// The unique ID of the quest.
    required String questId,

    /// The title of the quest.
    required String title,

    /// The number of completed items.
    required int completed,

    /// The total number of items.
    required int total,
  }) async {
    await _channel.invokeMethod<void>('start', {
      'questId': questId,
      'title': title,
      'completed': completed,
      'total': total,
    });
  }

  /// Updates the progress of an existing live activity.
  Future<void> updateProgress({
    /// The unique ID of the quest.
    required String questId,

    /// The number of completed items.
    required int completed,

    /// The total number of items.
    required int total,
  }) async {
    await _channel.invokeMethod<void>('update', {
      'questId': questId,
      'completed': completed,
      'total': total,
    });
  }

  /// Ends a live activity.
  Future<void> endProgress(String questId) async {
    await _channel.invokeMethod<void>('end', {'questId': questId});
  }
}
