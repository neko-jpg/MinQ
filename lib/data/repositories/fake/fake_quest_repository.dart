import 'dart:async';
import 'package:minq/domain/quest/quest.dart';
import 'package:minq/data/repositories/interfaces/quest_repository_interface.dart';

/// テスト用のFakeクエストリポジトリ
class FakeQuestRepository implements IQuestRepository {
  final Map<String, List<Quest>> _quests = {};
  final _controller = StreamController<List<Quest>>.broadcast();

  /// テストデータを追加
  void addTestData(String userId, List<Quest> quests) {
    _quests[userId] = quests;
    _controller.add(quests);
  }

  /// データをクリア
  void clear() {
    _quests.clear();
    _controller.add([]);
  }

  @override
  Stream<List<Quest>> watchUserQuests(String userId) {
    return _controller.stream.map((_) => _quests[userId] ?? []);
  }

  @override
  Future<Quest?> getQuest(String questId) async {
    for (final quests in _quests.values) {
      final quest = quests.firstWhere(
        (q) => q.id.toString() == questId,
        orElse: () => throw StateError('Quest not found'),
      );
      if (quest.id.toString() == questId) return quest;
    }
    return null;
  }

  @override
  Future<void> createQuest(Quest quest) async {
    final userId = quest.owner;
    _quests[userId] = [...(_quests[userId] ?? []), quest];
    _controller.add(_quests[userId]!);
  }

  @override
  Future<void> updateQuest(Quest quest) async {
    final userId = quest.owner;
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
      quests.removeWhere((q) => q.id.toString() == questId);
      _quests[userId] = quests;
      _controller.add(quests);
    }
  }

  @override
  Future<void> updateQuestOrder(List<String> questIds) async {
    // 順序更新のシミュレーション
    for (final userId in _quests.keys) {
      final quests = _quests[userId]!;
      final reordered = <Quest>[];
      for (final id in questIds) {
        final quest = quests.firstWhere((q) => q.id.toString() == id);
        reordered.add(quest);
      }
      _quests[userId] = reordered;
      _controller.add(reordered);
    }
  }

  @override
  Stream<List<Quest>> watchActiveQuests(String userId) {
    return watchUserQuests(
      userId,
    ).map((quests) => quests.where((q) => q.status == QuestStatus.active).toList());
  }

  @override
  Future<int> getQuestCount(String userId) async {
    return (_quests[userId] ?? []).length;
  }

  void dispose() {
    _controller.close();
  }
}
