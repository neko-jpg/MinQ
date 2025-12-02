import 'dart:async';

import 'package:flutter/services.dart';

/// Platform channel facade for managing Live Activities / Android Live Widgets.
class LiveActivityChannel {
  LiveActivityChannel({MethodChannel? channel})
    : _channel = channel ?? const MethodChannel('miinq/live_activity');

  final MethodChannel _channel;

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

  Future<void> endProgress(String questId) async {
    await _channel.invokeMethod<void>('end', {'questId': questId});
  }
}
