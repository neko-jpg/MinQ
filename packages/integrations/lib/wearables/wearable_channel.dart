import 'dart:async';

import 'package:flutter/services.dart';

/// Bridge for Wear OS / Apple Watch quick progress sync.
class WearableChannel {
  /// Creates a new [WearableChannel].
  WearableChannel({MethodChannel? channel})
      : _channel = channel ?? const MethodChannel('miinq/wearables');

  final MethodChannel _channel;

  /// Syncs a snapshot of the user's quests to the wearable.
  Future<void> syncSnapshot({
    required String userId,
    required List<Map<String, dynamic>> quests,
  }) async {
    await _channel.invokeMethod<void>('syncSnapshot', {
      'userId': userId,
      'quests': quests,
    });
  }

  /// Registers a quick action on the wearable.
  Future<void> registerQuickAction({
    required String questId,
    required String label,
  }) async {
    await _channel.invokeMethod<void>('registerQuickAction', {
      'questId': questId,
      'label': label,
    });
  }
}
