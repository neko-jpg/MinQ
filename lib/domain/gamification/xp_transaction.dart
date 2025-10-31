import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:isar/isar.dart';

part 'xp_transaction.freezed.dart';
part 'xp_transaction.g.dart';

/// XP獲得履歴を記録するモデル
@freezed
@Collection()
class XPTransaction with _$XPTransaction {
  const factory XPTransaction({
    @Default(Isar.autoIncrement) Id id,
    required String userId,
    required int xpAmount,
    required String reason,
    required XPSource source,
    required DateTime createdAt,
    Map<String, dynamic>? metadata,
    double? multiplier,
    int? streakBonus,
    int? difficultyBonus,
  }) = _XPTransaction;

  factory XPTransaction.fromJson(Map<String, dynamic> json) =>
      _$XPTransactionFromJson(json);
}

/// XP獲得源の種類
@JsonEnum()
enum XPSource {
  @JsonValue('quest_complete')
  questComplete,
  @JsonValue('mini_quest_complete')
  miniQuestComplete,
  @JsonValue('streak_milestone')
  streakMilestone,
  @JsonValue('challenge_complete')
  challengeComplete,
  @JsonValue('weekly_goal')
  weeklyGoal,
  @JsonValue('monthly_goal')
  monthlyGoal,
  @JsonValue('early_completion')
  earlyCompletion,
  @JsonValue('perfect_completion')
  perfectCompletion,
  @JsonValue('comeback_bonus')
  comebackBonus,
  @JsonValue('weekend_activity')
  weekendActivity,
  @JsonValue('special_event')
  specialEvent,
}

/// XP獲得結果
@freezed
class XPGainResult with _$XPGainResult {
  const factory XPGainResult({
    required int xpGained,
    required int newTotalXP,
    required int previousLevel,
    required int newLevel,
    required bool leveledUp,
    required List<String> newRewards,
    required XPTransaction transaction,
  }) = _XPGainResult;

  factory XPGainResult.fromJson(Map<String, dynamic> json) =>
      _$XPGainResultFromJson(json);
}

/// レベル情報
@freezed
class LevelInfo with _$LevelInfo {
  const factory LevelInfo({
    required int level,
    required String name,
    required String description,
    required int minXP,
    required int maxXP,
    required List<String> rewards,
    required List<String> unlockedFeatures,
  }) = _LevelInfo;

  factory LevelInfo.fromJson(Map<String, dynamic> json) =>
      _$LevelInfoFromJson(json);
}

/// ユーザーのレベル進捗情報
@freezed
class UserLevelProgress with _$UserLevelProgress {
  const factory UserLevelProgress({
    required int currentLevel,
    required String currentLevelName,
    required int currentXP,
    required int xpToNextLevel,
    required double progressToNextLevel,
    required bool isMaxLevel,
    required LevelInfo currentLevelInfo,
    LevelInfo? nextLevelInfo,
  }) = _UserLevelProgress;

  factory UserLevelProgress.fromJson(Map<String, dynamic> json) =>
      _$UserLevelProgressFromJson(json);
}

/// 詳細なXP分析データ
@freezed
class XPAnalytics with _$XPAnalytics {
  const factory XPAnalytics({
    required int totalXP,
    required int totalTransactions,
    required int todayXP,
    required int weeklyXP,
    required int monthlyXP,
    required double averageXPPerDay,
    required double averageXPPerTransaction,
    required Map<int, int> hourlyDistribution,
    required Map<int, int> weekdayDistribution,
    required Map<XPSource, SourceAnalytics> sourceAnalysis,
    required int totalStreakBonus,
    required int streakBonusTransactions,
    required GrowthTrend growthTrend,
    required int mostActiveHour,
    required int mostActiveWeekday,
    XPSource? topSource,
    required DateTime firstActivity,
    required DateTime lastActivity,
  }) = _XPAnalytics;

  factory XPAnalytics.fromJson(Map<String, dynamic> json) =>
      _$XPAnalyticsFromJson(json);

  factory XPAnalytics.empty() => XPAnalytics(
    totalXP: 0,
    totalTransactions: 0,
    todayXP: 0,
    weeklyXP: 0,
    monthlyXP: 0,
    averageXPPerDay: 0.0,
    averageXPPerTransaction: 0.0,
    hourlyDistribution: {},
    weekdayDistribution: {},
    sourceAnalysis: {},
    totalStreakBonus: 0,
    streakBonusTransactions: 0,
    growthTrend: GrowthTrend.stable,
    mostActiveHour: 12,
    mostActiveWeekday: 1,
    topSource: null,
    firstActivity: DateTime.now(),
    lastActivity: DateTime.now(),
  );
}

/// ソース別分析データ
@freezed
class SourceAnalytics with _$SourceAnalytics {
  const factory SourceAnalytics({
    required int totalXP,
    required int transactionCount,
    required double averageXP,
    required DateTime lastActivity,
  }) = _SourceAnalytics;

  factory SourceAnalytics.fromJson(Map<String, dynamic> json) =>
      _$SourceAnalyticsFromJson(json);
}

/// 成長トレンド
@JsonEnum()
enum GrowthTrend {
  @JsonValue('increasing')
  increasing,
  @JsonValue('stable')
  stable,
  @JsonValue('decreasing')
  decreasing,
}