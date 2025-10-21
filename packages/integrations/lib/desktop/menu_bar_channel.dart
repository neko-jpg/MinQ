import 'package:flutter/services.dart';

class MenuBarChannel {
  MenuBarChannel({MethodChannel? channel})
    : _channel = channel ?? const MethodChannel('miinq/desktop_menu_bar');

  final MethodChannel _channel;

  Future<void> updateTimer({
    required String title,
    required Duration remaining,
  }) async {
    await _channel.invokeMethod<void>('updateTimer', <String, dynamic>{
      'title': title,
      'remainingSeconds': remaining.inSeconds,
    });
  }

  Future<void> clear() async {
    await _channel.invokeMethod<void>('clear');
  }
}
