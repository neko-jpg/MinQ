import 'package:minq/domain/quest/quest.dart';
// TODO: Fix integrations package
// import 'package:miinq_integrations/miinq_integrations.dart';
import 'package:riverpod/riverpod.dart';

// Dummy type until integrations package is fixed
class WearableChannel {
  const WearableChannel();
  Future<void> syncSnapshot({String? userId, List<Map<String, dynamic>>? quests}) async {}
  Future<void> registerQuickAction({String? questId, String? label}) async {}
}

class WearableSyncService {
  WearableSyncService({required WearableChannel channel}) : _channel = channel;

  final WearableChannel _channel;

  Future<void> syncQuests({
    required String userId,
    required List<Quest> quests,
  }) async {
    await _channel.syncSnapshot(
      userId: userId,
      quests: quests
          .map(
            (quest) => <String, dynamic>{
              'id': quest.id.toString(),
              'title': quest.title,
              'completedToday': false,
            },
          )
          .toList(),
    );
  }

  Future<void> registerQuickActions(List<Quest> quickActions) async {
    for (final quest in quickActions) {
      await _channel.registerQuickAction(
        questId: quest.id.toString(),
        label: quest.title,
      );
    }
  }
}

final wearableChannelProvider = Provider<WearableChannel>((ref) {
  return const WearableChannel();
});

final wearableSyncServiceProvider = Provider<WearableSyncService>((ref) {
  return WearableSyncService(channel: ref.watch(wearableChannelProvider));
});
