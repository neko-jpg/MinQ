import '../../models/mini_quest.dart';

/// クエストリポジトリインターフェース
/// テスト用のFake実装を可能にする
abstract class IQuestRepository {
  /// ユーザーのすべてのクエストを取得
  Stream<List<MiniQuest>> watchUserQuests(String userId);

  /// クエストを取得
  Future<MiniQuest?> getQuest(String questId);

  /// クエストを作成
  Future<void> createQuest(MiniQuest quest);

  /// クエストを更新
  Future<void> updateQuest(MiniQuest quest);

  /// クエストを削除
  Future<void> deleteQuest(String questId);

  /// クエストの順序を更新
  Future<void> updateQuestOrder(List<String> questIds);

  /// アクティブなクエストのみを取得
  Stream<List<MiniQuest>> watchActiveQuests(String userId);

  /// クエストの数を取得
  Future<int> getQuestCount(String userId);
}
