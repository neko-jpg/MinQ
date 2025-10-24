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
    /// The user's ID.
    required String userId,

    /// A list of quests to sync.
    required List<Map<String, dynamic>> quests,
  }) async {
    await _channel.invokeMethod<void>('syncSnapshot', {
      'userId': userId,
      'quests': quests,
    });
  }

  /// Registers a quick action on the wearable.
  Future<void> registerQuickAction({
    /// The ID of the quest to associate with the quick action.
    required String questId,

    /// The label for the quick action.
    required String label,
  }) async {
    await _channel.invokeMethod<void>('registerQuickAction', {
      'questId': questId,
      'label': label,
    });
  }
}
