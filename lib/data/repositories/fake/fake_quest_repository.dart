import 'dart:async';
import 'package:minq/data/models/mini_quest.dart';
import 'package:minq/data/repositories/interfaces/quest_repository_interface.dart';

/// テスト用のFakeクエストリポジトリ
class FakeQuestRepository implements IQuestRepository {
  final Map<String, List<MiniQuest>> _quests = {};
  final _controller = StreamController<List<MiniQuest>>.broadcast();

  /// テストデータを追加
  void addTestData(String userId, List<MiniQuest> quests) {
    _quests[userId] = quests;
    _controller.add(quests);
  }

  /// データをクリア
  void clear() {
    _quests.clear();
    _controller.add([]);
  }

  @override
  Stream<List<MiniQuest>> watchUserQuests(String userId) {
    return _controller.stream.map((_) => _quests[userId] ?? []);
  }

  @override
  Future<MiniQuest?> getQuest(String questId) async {
    for (final quests in _quests.values) {
      final quest = quests.firstWhere(
        (q) => q.id == questId,
        orElse: () => throw StateError('Quest not found'),
      );
      if (quest.id == questId) return quest;
    }
    return null;
  }

  @override
  Future<void> createQuest(MiniQuest quest) async {
    final userId = quest.userId;
    _quests[userId] = [...(_quests[userId] ?? []), quest];
    _controller.add(_quests[userId]!);
  }

  @override
  Future<void> updateQuest(MiniQuest quest) async {
    final userId = quest.userId;
    final quests = _quests[userId] ?? [];
    final index = quests.indexWhere((q) => q.id == quest.id);
    if (index != -1) {
      quests[index] = quest;
      _quests[userId] = quests;
      _controller.add(quests);
    }
  }

  @override
  Future<void> deleteQuest(String questId) async {
    for (final userId in _quests.keys) {
      final quests = _quests[userId]!;
      quests.removeWhere((q) => q.id == questId);
      _quests[userId] = quests;
      _controller.add(quests);
    }
  }

  @override
  Future<void> updateQuestOrder(List<String> questIds) async {
    // 順序更新のシミュレーション
    for (final userId in _quests.keys) {
      final quests = _quests[userId]!;
      final reordered = <MiniQuest>[];
      for (final id in questIds) {
        final quest = quests.firstWhere((q) => q.id == id);
        reordered.add(quest);
      }
      _quests[userId] = reordered;
      _controller.add(reordered);
    }
  }

  @override
  Stream<List<MiniQuest>> watchActiveQuests(String userId) {
    return watchUserQuests(
      userId,
    ).map((quests) => quests.where((q) => q.isActive).toList());
  }

  @override
  Future<int> getQuestCount(String userId) async {
    return (_quests[userId] ?? []).length;
  }

  void dispose() {
    _controller.close();
  }
}
