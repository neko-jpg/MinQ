import 'package:minq/domain/log/quest_log.dart';

/// クエストログリポジトリインターフェース
abstract class IQuestLogRepository {
  /// ユーザーのすべてのログを取得
  Stream<List<QuestLog>> watchUserLogs(String userId);

  /// 特定の日付のログを取得
  Stream<List<QuestLog>> watchLogsByDate(String userId, DateTime date);

  /// 期間内のログを取得
  Future<List<QuestLog>> getLogsByDateRange(
    String userId,
    DateTime startDate,
    DateTime endDate,
  );

  /// ログを作成
  Future<void> createLog(QuestLog log);

  /// ログを更新
  Future<void> updateLog(QuestLog log);

  /// ログを削除
  Future<void> deleteLog(String logId);

  /// クエストの完了状態を切り替え
  Future<void> toggleQuestCompletion(
    String userId,
    String questId,
    DateTime date,
  );

  /// 連続達成日数を計算
  Future<int> calculateStreak(String userId);

  /// 週間達成率を計算
  Future<double> calculateWeeklyAchievementRate(String userId);

  /// 当日の完了数を取得
  Future<int> getTodayCompletionCount(String userId);
}
