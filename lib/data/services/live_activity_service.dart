// TODO: Fix integrations package
// import 'package:miinq_integrations/miinq_integrations.dart';
import 'package:riverpod/riverpod.dart';

// Dummy type until integrations package is fixed
class LiveActivityChannel {
  const LiveActivityChannel();
  Future<void> startProgressActivity({required String questId, required String title, required int completed, required int total}) async {}
  Future<void> updateProgress({required String questId, required int completed, required int total}) async {}
  Future<void> endProgress(String questId) async {}
}

class LiveActivityService {
  LiveActivityService({required LiveActivityChannel channel}) : _channel = channel;

  final LiveActivityChannel _channel;

  Future<void> startForQuest({
    required String questId,
    required String title,
    required int completed,
    required int total,
  }) async {
    await _channel.startProgressActivity(
      questId: questId,
      title: title,
      completed: completed,
      total: total,
    );
  }

  Future<void> updateProgress({
    required String questId,
    required int completed,
    required int total,
  }) async {
    await _channel.updateProgress(
      questId: questId,
      completed: completed,
      total: total,
    );
  }

  Future<void> endForQuest(String questId) async {
    await _channel.endProgress(questId);
  }
}

final liveActivityChannelProvider = Provider<LiveActivityChannel>((ref) {
  return const LiveActivityChannel();
});

final liveActivityServiceProvider = Provider<LiveActivityService>((ref) {
  return LiveActivityService(channel: ref.watch(liveActivityChannelProvider));
});
