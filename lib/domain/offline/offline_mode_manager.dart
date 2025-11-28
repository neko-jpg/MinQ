import 'dart:collection';

import 'package:minq/domain/log/quest_log.dart';
import 'package:minq/domain/quest/quest.dart';

enum OfflineActionType { createQuest, updateQuest, deleteQuest, logCompletion }

class OfflineSyncAction {
  OfflineSyncAction({
    required this.type,
    required this.payload,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now().toUtc();

  final OfflineActionType type;
  final Map<String, Object?> payload;
  final DateTime createdAt;
}

class OfflineSnapshot {
  OfflineSnapshot({
    required this.quests,
    required this.logs,
    required this.pendingActions,
  });

  final List<Quest> quests;
  final List<QuestLog> logs;
  final List<OfflineSyncAction> pendingActions;
}

class OfflineModeManager {
  OfflineModeManager();

  final Map<int, Quest> _questCache = {};
  final Map<int, QuestLog> _logCache = {};
  final Queue<OfflineSyncAction> _pendingActions = Queue();

  void cacheQuest(Quest quest) {
    _questCache[quest.id] = quest;
  }

  void cacheLog(QuestLog log) {
    _logCache[log.id] = log;
  }

  void enqueueAction(OfflineSyncAction action) {
    _pendingActions.add(action);
  }

  OfflineSnapshot snapshot() {
    return OfflineSnapshot(
      quests: _questCache.values.toList(growable: false),
      logs: _logCache.values.toList(growable: false),
      pendingActions: _pendingActions.toList(growable: false),
    );
  }

  List<OfflineSyncAction> drainPendingActions() {
    final drained = List<OfflineSyncAction>.from(_pendingActions);
    _pendingActions.clear();
    return drained;
  }

  void applyRemoteQuest(Quest quest) {
    _questCache[quest.id] = quest;
  }

  void applyRemoteLog(QuestLog log) {
    _logCache[log.id] = log;
  }

  void clear() {
    _questCache.clear();
    _logCache.clear();
    _pendingActions.clear();
  }
}
