import 'package:flutter_test/flutter_test.dart';

import 'package:minq/domain/log/quest_log.dart';
import 'package:minq/domain/offline/offline_mode_manager.dart';
import 'package:minq/domain/quest/quest.dart';

Quest buildQuest(int id) {
  final quest = Quest()
    ..id = id
    ..owner = 'user'
    ..title = 'Quest $id'
    ..category = 'category'
    ..estimatedMinutes = 10
    ..status = QuestStatus.active
    ..createdAt = DateTime.utc(2024, 1, 1);
  return quest;
}

QuestLog buildLog(int id, int questId) {
  final log = QuestLog()
    ..id = id
    ..questId = questId
    ..uid = 'user'
    ..ts = DateTime.utc(2024, 1, 1, id)
    ..proofType = ProofType.check
    ..synced = false;
  return log;
}

void main() {
  group('OfflineModeManager', () {
    test('stores caches and pending actions', () {
      final manager = OfflineModeManager();
      manager.cacheQuest(buildQuest(1));
      manager.cacheLog(buildLog(1, 1));
      manager.enqueueAction(OfflineSyncAction(
        type: OfflineActionType.createQuest,
        payload: {'id': 1},
      ),);

      final snapshot = manager.snapshot();
      expect(snapshot.quests, hasLength(1));
      expect(snapshot.logs, hasLength(1));
      expect(snapshot.pendingActions, hasLength(1));
    });

    test('drains pending actions in FIFO order', () {
      final manager = OfflineModeManager();
      manager.enqueueAction(OfflineSyncAction(type: OfflineActionType.createQuest, payload: {'id': 1}));
      manager.enqueueAction(OfflineSyncAction(type: OfflineActionType.logCompletion, payload: {'id': 2}));

      final drained = manager.drainPendingActions();
      expect(drained.map((action) => action.payload['id']), [1, 2]);
      expect(manager.snapshot().pendingActions, isEmpty);
    });
  });
}
