import 'package:minq/domain/quest/quest.dart';

/// クエストリポジトリインターフェース
/// テスト用のFake実装を可能にする
abstract class IQuestRepository {
  /// ユーザーのすべてのクエストを取得
  Stream<List<Quest>> watchUserQuests(String userId);

  /// クエストを取得
  Future<Quest?> getQuest(String questId);

  /// クエストを作成
  Future<void> createQuest(Quest quest);

  /// クエストを更新
  Future<void> updateQuest(Quest quest);

  /// クエストを削除
  Future<void> deleteQuest(String questId);

  /// クエストの順序を更新
  Future<void> updateQuestOrder(List<String> questIds);

  /// アクティブなクエストのみを取得
  Stream<List<Quest>> watchActiveQuests(String userId);

  /// クエストの数を取得
  Future<int> getQuestCount(String userId);
}
