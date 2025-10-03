import 'package:miinq_integrations/miinq_integrations.dart';
import 'package:riverpod/riverpod.dart';

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
  return LiveActivityChannel();
});

final liveActivityServiceProvider = Provider<LiveActivityService>((ref) {
  return LiveActivityService(channel: ref.watch(liveActivityChannelProvider));
});
