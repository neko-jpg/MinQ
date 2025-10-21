// TODO: Fix integrations package
// import 'package:miinq_integrations/miinq_integrations.dart';
import 'package:riverpod/riverpod.dart';

// Dummy type until integrations package is fixed
class MenuBarChannel {
  const MenuBarChannel();
  Future<void> updateTimer({
    required String title,
    required Duration remaining,
  }) async {}
  Future<void> clear() async {}
}

class DesktopMenuBarService {
  DesktopMenuBarService({required MenuBarChannel channel}) : _channel = channel;

  final MenuBarChannel _channel;

  Future<void> updateTimer({
    required String title,
    required Duration remaining,
  }) async {
    await _channel.updateTimer(title: title, remaining: remaining);
  }

  Future<void> clear() => _channel.clear();
}

final menuBarChannelProvider = Provider<MenuBarChannel>((ref) {
  return const MenuBarChannel();
});

final desktopMenuBarServiceProvider = Provider<DesktopMenuBarService>((ref) {
  return DesktopMenuBarService(channel: ref.watch(menuBarChannelProvider));
});
