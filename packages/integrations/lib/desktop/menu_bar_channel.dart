import 'package:flutter/services.dart';

/// A method channel for interacting with the desktop menu bar.
class MenuBarChannel {
  /// Creates a new [MenuBarChannel].
  MenuBarChannel({MethodChannel? channel})
    : _channel = channel ?? const MethodChannel('miinq/desktop_menu_bar');

  final MethodChannel _channel;

  /// Updates the timer in the menu bar.
  Future<void> updateTimer({
    /// The title of the timer.
    required String title,

    /// The remaining duration of the timer.
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
