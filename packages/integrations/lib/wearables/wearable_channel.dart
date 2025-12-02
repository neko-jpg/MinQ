import 'dart:async';

import 'package:flutter/services.dart';

/// Bridge for Wear OS / Apple Watch quick progress sync.
class WearableChannel {
  WearableChannel({MethodChannel? channel})
    : _channel = channel ?? const MethodChannel('miinq/wearables');

  final MethodChannel _channel;

  Future<void> syncSnapshot({
    required String userId,
    required List<Map<String, dynamic>> quests,
  }) async {
    await _channel.invokeMethod<void>('syncSnapshot', {
      'userId': userId,
      'quests': quests,
    });
  }

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
