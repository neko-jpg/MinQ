import 'package:flutter/services.dart';

/// A channel for interacting with the native desktop menu bar.
class MenuBarChannel {
  /// Creates a new [MenuBarChannel].
  MenuBarChannel({MethodChannel? channel})
      : _channel = channel ?? const MethodChannel('miinq/desktop_menu_bar');

  final MethodChannel _channel;

  /// Updates the timer in the menu bar.
  Future<void> updateTimer({
    required String title,
    required Duration remaining,
  }) async {
    await _channel.invokeMethod<void>('updateTimer', <String, dynamic>{
      'title': title,
      'remainingSeconds': remaining.inSeconds,
    });
  }

  /// Clears the timer from the menu bar.
  Future<void> clear() async {
    await _channel.invokeMethod<void>('clear');
  }
}
