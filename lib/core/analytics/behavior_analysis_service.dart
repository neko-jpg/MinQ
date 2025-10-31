import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:minq/core/database/database_service.dart';
import 'package:minq/domain/analytics/analytics_insight.dart';
import 'package:minq/domain/analytics/behavior_pattern.dart';
import 'package:minq/domain/quest/quest.dart';

/// 行動分析サービス
class BehaviorAnalysisService {
  final DatabaseService _databaseService;

  BehaviorAnalysisService(this._databaseService);

  /// 習慣継続率を分析
  Future<double> analyzeHabitContinuityRate({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final quests = await _databaseService.getQuestsInDateRange(startDate, endDate);
    if (quests.isEmpty) return 0.0;

    final totalDays = endDate.difference(startDate).inDays + 1;
    final activeDays = _getActiveDays(quests);
    
    return activeDays.length / totalDays;
  }

  /// 失敗パターンを分析
  Future<List<BehaviorPattern>> analyzeFailurePatterns() async {
    final patterns = <BehaviorPattern>[];
    
    // 時間帯別失敗パターン
    final timePatterns = await _analyzeTimeBasedFailures();
    patterns.addAll(timePatterns);
    
    // 曜日別失敗パターン
    final dayPatterns = await _analyzeDayOfWeekFailures();
    patterns.addAll(dayPatterns);
    
    // カテゴリ別失敗パターン
    final categoryPatterns = await _analyzeCategoryFailures();
    patterns.addAll(categoryPatterns);
    
    // ストリーク中断パターン
    final streakPatterns = await _analyzeStreakBreakPatterns();
    patterns.addAll(streakPatterns);
    
    return patterns;
  }

  /// 時間帯別パターンを分析
  Future<List<TimePattern>> analyzeTimePatterns() async {
    final patterns = <TimePattern>[];
    final quests = await _databaseService.getAllCompletedQuests();
    
    // 時間帯ごとにグループ化
    final hourlyData = <int, List<Quest>>{};
    for (final quest in quests) {
      final hour = quest.createdAt.hour;
      hourlyData.putIfAbsent(hour, () => []).add(quest);
    }
    
    for (int hour = 0; hour < 24; hour++) {
      final questsInHour = hourlyData[hour] ?? [];
      if (questsInHour.isEmpty) continue;
      
      final successRate = _calculateSuccessRate(questsInHour);
      final averageDuration = _calculateAverageDuration(questsInHour);
      
      patterns.add(TimePattern(
        hour: hour,
        successRate: successRate,
        completionCount: questsInHour.length,
        averageDuration: averageDuration,
      ));
    }
    
    return patterns;
  }

  /// 曜日別パターンを分析
  Future<List<DayOfWeekPattern>> analyzeDayOfWeekPatterns() async {
    final patterns = <DayOfWeekPattern>[];
    final quests = await _databaseService.getAllCompletedQuests();
    
    // 曜日ごとにグループ化
    final dailyData = <int, List<Quest>>{};
    for (final quest in quests) {
      final dayOfWeek = quest.createdAt.weekday;
      dailyData.putIfAbsent(dayOfWeek, () => []).add(quest);
    }
    
    for (int day = 1; day <= 7; day++) {
      final questsInDay = dailyData[day] ?? [];
      if (questsInDay.isEmpty) continue;
      
      final successRate = _calculateSuccessRate(questsInDay);
      final averageQuestsPerDay = _calculateAverageQuestsPerDay(questsInDay, day);
      
      patterns.add(DayOfWeekPattern(
        dayOfWeek: day,
        successRate: successRate,
        completionCount: questsInDay.length,
        averageQuestsPerDay: averageQuestsPerDay,
      ));
    }
    
    return patterns;
  }

  /// 季節別パターンを分析
  Future<List<SeasonalPattern>> analyzeSeasonalPatterns() async {
    final patterns = <SeasonalPattern>[];
    final quests = await _databaseService.getAllCompletedQuests();
    
    // 季節ごとにグループ化
    final seasonalData = <Season, List<Quest>>{};
    for (final quest in quests) {
      final season = SeasonFromMonth.fromMonth(quest.createdAt.month);
      seasonalData.putIfAbsent(season, () => []).add(quest);
    }
    
    for (final season in Season.values) {
      final questsInSeason = seasonalData[season] ?? [];
      if (questsInSeason.isEmpty) continue;
      
      final successRate = _calculateSuccessRate(questsInSeason);
      final popularCategories = _getPopularCategories(questsInSeason);
      
      patterns.add(SeasonalPattern(
        season: season,
        successRate: successRate,
        completionCount: questsInSeason.length,
        popularCategories: popularCategories,
      ));
    }
    
    return patterns;
  }

  /// 目標達成予測を生成
  Future<List<GoalPrediction>> generateGoalPredictions() async {
    final predictions = <GoalPrediction>[];
    
    // 週間目標予測
    final weeklyPrediction = await _predictWeeklyGoal();
    if (weeklyPrediction != null) predictions.add(weeklyPrediction);
    
    // 月間目標予測
    final monthlyPrediction = await _predictMonthlyGoal();
    if (monthlyPrediction != null) predictions.add(monthlyPrediction);
    
    // ストリーク目標予測
    final streakPrediction = await _predictStreakGoal();
    if (streakPrediction != null) predictions.add(streakPrediction);
    
    return predictions;
  }

  /// リスク警告を生成
  Future<List<AnalyticsInsight>> generateRiskWarnings() async {
    final warnings = <AnalyticsInsight>[];
    
    // ストリーク中断リスク
    final streakRisk = await _analyzeStreakRisk();
    if (streakRisk != null) warnings.add(streakRisk);
    
    // 完了率低下リスク
    final completionRisk = await _analyzeCompletionRateRisk();
    if (completionRisk != null) warnings.add(completionRisk);
    
    // 活動量低下リスク
    final activityRisk = await _analyzeActivityRisk();
    if (activityRisk != null) warnings.add(activityRisk);
    
    return warnings;
  }

  // プライベートメソッド

  Future<List<BehaviorPattern>> _analyzeTimeBasedFailures() async {
    final patterns = <BehaviorPattern>[];
    final failedQuests = await _databaseService.getFailedQuests();
    
    // 時間帯別の失敗率を計算
    final hourlyFailures = <int, int>{};
    for (final quest in failedQuests) {
      final hour = quest.createdAt.hour;
      hourlyFailures[hour] = (hourlyFailures[hour] ?? 0) + 1;
    }
    
    // 失敗率が高い時間帯を特定
    final totalFailures = failedQuests.length;
    for (final entry in hourlyFailures.entries) {
      final failureRate = entry.value / totalFailures;
      if (failureRate > 0.15) { // 15%以上の失敗率
        patterns.add(BehaviorPattern(
          type: PatternType.failure,
          name: '${entry.key}時台の失敗パターン',
          description: '${entry.key}時台に失敗する傾向があります（失敗率: ${(failureRate * 100).toStringAsFixed(1)}%）',
          confidence: failureRate,
          frequency: entry.value,
          impact: -failureRate,
          suggestions: [
            '${entry.key}時台のクエストを避ける',
            'より集中しやすい時間帯にスケジュールを変更する',
            '${entry.key}時台には簡単なクエストから始める',
          ],
          metadata: {
            'hour': entry.key,
            'failure_count': entry.value,
            'failure_rate': failureRate,
          },
          detectedAt: DateTime.now(),
        ));
      }
    }
    
    return patterns;
  }

  Future<List<BehaviorPattern>> _analyzeDayOfWeekFailures() async {
    final patterns = <BehaviorPattern>[];
    final failedQuests = await _databaseService.getFailedQuests();
    
    // 曜日別の失敗率を計算
    final dailyFailures = <int, int>{};
    for (final quest in failedQuests) {
      final dayOfWeek = quest.createdAt.weekday;
      dailyFailures[dayOfWeek] = (dailyFailures[dayOfWeek] ?? 0) + 1;
    }
    
    // 失敗率が高い曜日を特定
    final totalFailures = failedQuests.length;
    for (final entry in dailyFailures.entries) {
      final failureRate = entry.value / totalFailures;
      if (failureRate > 0.20) { // 20%以上の失敗率
        final dayName = DayOfWeekPattern(
          dayOfWeek: entry.key,
          successRate: 0,
          completionCount: 0,
          averageQuestsPerDay: 0,
        ).dayName;
        
        patterns.add(BehaviorPattern(
          type: PatternType.failure,
          name: '$dayName曜日の失敗パターン',
          description: '$dayName曜日に失敗する傾向があります（失敗率: ${(failureRate * 100).toStringAsFixed(1)}%）',
          confidence: failureRate,
          frequency: entry.value,
          impact: -failureRate,
          suggestions: [
            '$dayName曜日は軽めのクエストに調整する',
            '$dayName曜日の前日に準備を整える',
            '$dayName曜日には特別なモチベーション戦略を使う',
          ],
          metadata: {
            'day_of_week': entry.key,
            'day_name': dayName,
            'failure_count': entry.value,
            'failure_rate': failureRate,
          },
          detectedAt: DateTime.now(),
        ));
      }
    }
    
    return patterns;
  }

  Future<List<BehaviorPattern>> _analyzeCategoryFailures() async {
    final patterns = <BehaviorPattern>[];
    final failedQuests = await _databaseService.getFailedQuests();
    
    // カテゴリ別の失敗率を計算
    final categoryFailures = <String, int>{};
    for (final quest in failedQuests) {
      categoryFailures[quest.category] = (categoryFailures[quest.category] ?? 0) + 1;
    }
    
    // 失敗率が高いカテゴリを特定
    final totalFailures = failedQuests.length;
    for (final entry in categoryFailures.entries) {
      final failureRate = entry.value / totalFailures;
      if (failureRate > 0.25) { // 25%以上の失敗率
        patterns.add(BehaviorPattern(
          type: PatternType.failure,
          name: '${entry.key}カテゴリの失敗パターン',
          description: '${entry.key}カテゴリのクエストで失敗する傾向があります（失敗率: ${(failureRate * 100).toStringAsFixed(1)}%）',
          confidence: failureRate,
          frequency: entry.value,
          impact: -failureRate,
          suggestions: [
            '${entry.key}カテゴリのクエストを細分化する',
            '${entry.key}カテゴリの難易度を下げる',
            '${entry.key}カテゴリに特化したサポートを求める',
          ],
          metadata: {
            'category': entry.key,
            'failure_count': entry.value,
            'failure_rate': failureRate,
          },
          detectedAt: DateTime.now(),
        ));
      }
    }
    
    return patterns;
  }

  Future<List<BehaviorPattern>> _analyzeStreakBreakPatterns() async {
    final patterns = <BehaviorPattern>[];
    // ストリーク中断のパターンを分析
    // 実装は簡略化
    return patterns;
  }

  Set<DateTime> _getActiveDays(List<Quest> quests) {
    return quests.map((q) => DateTime(q.createdAt.year, q.createdAt.month, q.createdAt.day)).toSet();
  }

  double _calculateSuccessRate(List<Quest> quests) {
    if (quests.isEmpty) return 0.0;
    final completedQuests = quests.where((q) => q.status == QuestStatus.active).length;
    return completedQuests / quests.length;
  }

  Duration _calculateAverageDuration(List<Quest> quests) {
    if (quests.isEmpty) return Duration.zero;
    final totalMinutes = quests.fold<int>(0, (sum, q) => sum + q.estimatedMinutes);
    return Duration(minutes: totalMinutes ~/ quests.length);
  }

  double _calculateAverageQuestsPerDay(List<Quest> quests, int dayOfWeek) {
    if (quests.isEmpty) return 0.0;
    final activeDays = _getActiveDays(quests.where((q) => q.createdAt.weekday == dayOfWeek).toList());
    return quests.length / math.max(1, activeDays.length);
  }

  List<String> _getPopularCategories(List<Quest> quests) {
    final categoryCount = <String, int>{};
    for (final quest in quests) {
      categoryCount[quest.category] = (categoryCount[quest.category] ?? 0) + 1;
    }
    
    final sortedCategories = categoryCount.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    return sortedCategories.take(3).map((e) => e.key).toList();
  }

  Future<GoalPrediction?> _predictWeeklyGoal() async {
    // 週間目標予測の実装
    return null;
  }

  Future<GoalPrediction?> _predictMonthlyGoal() async {
    // 月間目標予測の実装
    return null;
  }

  Future<GoalPrediction?> _predictStreakGoal() async {
    // ストリーク目標予測の実装
    return null;
  }

  Future<AnalyticsInsight?> _analyzeStreakRisk() async {
    // ストリークリスク分析の実装
    return null;
  }

  Future<AnalyticsInsight?> _analyzeCompletionRateRisk() async {
    // 完了率リスク分析の実装
    return null;
  }

  Future<AnalyticsInsight?> _analyzeActivityRisk() async {
    // 活動量リスク分析の実装
    return null;
  }
}

final behaviorAnalysisServiceProvider = Provider<BehaviorAnalysisService>((ref) {
  final databaseService = ref.watch(databaseServiceProvider);
  return BehaviorAnalysisService(databaseService);
});