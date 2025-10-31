import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:minq/core/analytics/behavior_analysis_service.dart';
import 'package:minq/domain/analytics/analytics_insight.dart';
import 'package:minq/domain/analytics/behavior_pattern.dart';

/// インサイト生成エンジン
class InsightsEngine {
  final BehaviorAnalysisService _behaviorAnalysisService;

  InsightsEngine(this._behaviorAnalysisService);

  /// 全てのインサイトを生成
  Future<List<AnalyticsInsight>> generateAllInsights() async {
    final insights = <AnalyticsInsight>[];
    
    // 習慣継続率インサイト
    final continuityInsights = await _generateContinuityInsights();
    insights.addAll(continuityInsights);
    
    // 失敗パターンインサイト
    final failureInsights = await _generateFailurePatternInsights();
    insights.addAll(failureInsights);
    
    // 最適化インサイト
    final optimizationInsights = await _generateOptimizationInsights();
    insights.addAll(optimizationInsights);
    
    // 達成インサイト
    final achievementInsights = await _generateAchievementInsights();
    insights.addAll(achievementInsights);
    
    // リスク警告インサイト
    final riskInsights = await _behaviorAnalysisService.generateRiskWarnings();
    insights.addAll(riskInsights);
    
    // 優先度でソート
    insights.sort((a, b) => _getPriorityScore(b.priority).compareTo(_getPriorityScore(a.priority)));
    
    return insights;
  }

  /// 習慣継続率に関するインサイトを生成
  Future<List<AnalyticsInsight>> _generateContinuityInsights() async {
    final insights = <AnalyticsInsight>[];
    
    // 過去30日の継続率を分析
    final endDate = DateTime.now();
    final startDate = endDate.subtract(const Duration(days: 30));
    final continuityRate = await _behaviorAnalysisService.analyzeHabitContinuityRate(
      startDate: startDate,
      endDate: endDate,
    );
    
    if (continuityRate > 0.8) {
      insights.add(AnalyticsInsight(
        id: 'high_continuity_${DateTime.now().millisecondsSinceEpoch}',
        type: InsightType.habitContinuity,
        priority: InsightPriority.medium,
        title: '素晴らしい継続率！',
        description: '過去30日間の習慣継続率が${(continuityRate * 100).toStringAsFixed(1)}%と非常に高い水準を維持しています。この調子で続けましょう！',
        actionItems: const [
          ActionItem(
            title: '進捗を共有',
            description: '素晴らしい成果を友達と共有しましょう',
            actionType: ActionType.shareProgress,
          ),
          ActionItem(
            title: '新しいチャレンジ',
            description: 'より高い目標に挑戦してみませんか？',
            actionType: ActionType.adjustGoals,
          ),
        ],
        confidence: 0.95,
        relatedPatterns: const [],
        metadata: {
          'continuity_rate': continuityRate,
          'period_days': 30,
        },
        generatedAt: DateTime.now(),
      ));
    } else if (continuityRate < 0.5) {
      insights.add(AnalyticsInsight(
        id: 'low_continuity_${DateTime.now().millisecondsSinceEpoch}',
        type: InsightType.habitContinuity,
        priority: InsightPriority.high,
        title: '継続率の改善が必要です',
        description: '過去30日間の習慣継続率が${(continuityRate * 100).toStringAsFixed(1)}%と低下しています。小さな変更から始めてみましょう。',
        actionItems: const [
          ActionItem(
            title: 'クエストを簡単にする',
            description: '達成しやすい小さなクエストから再開しましょう',
            actionType: ActionType.adjustGoals,
          ),
          ActionItem(
            title: 'リマインダーを設定',
            description: '忘れないようにリマインダーを設定しましょう',
            actionType: ActionType.setReminder,
          ),
        ],
        confidence: 0.85,
        relatedPatterns: const [],
        metadata: {
          'continuity_rate': continuityRate,
          'period_days': 30,
        },
        generatedAt: DateTime.now(),
      ));
    }
    
    return insights;
  }

  /// 失敗パターンに関するインサイトを生成
  Future<List<AnalyticsInsight>> _generateFailurePatternInsights() async {
    final insights = <AnalyticsInsight>[];
    final failurePatterns = await _behaviorAnalysisService.analyzeFailurePatterns();
    
    for (final pattern in failurePatterns.take(3)) { // 上位3つのパターン
      if (pattern.confidence > 0.6) { // 信頼度60%以上
        insights.add(AnalyticsInsight(
          id: 'failure_pattern_${pattern.type.name}_${DateTime.now().millisecondsSinceEpoch}',
          type: InsightType.failurePattern,
          priority: _mapConfidenceToPriority(pattern.confidence),
          title: pattern.name,
          description: pattern.description,
          actionItems: pattern.suggestions.map((suggestion) => ActionItem(
            title: suggestion,
            description: '${pattern.name}を改善するための提案',
            actionType: ActionType.adjustSchedule,
          )).toList(),
          confidence: pattern.confidence,
          relatedPatterns: [pattern],
          metadata: pattern.metadata,
          generatedAt: DateTime.now(),
        ));
      }
    }
    
    return insights;
  }

  /// 最適化に関するインサイトを生成
  Future<List<AnalyticsInsight>> _generateOptimizationInsights() async {
    final insights = <AnalyticsInsight>[];
    
    // 時間帯最適化インサイト
    final timePatterns = await _behaviorAnalysisService.analyzeTimePatterns();
    final bestTimePattern = timePatterns.fold<TimePattern?>(null, (best, current) {
      if (best == null || current.successRate > best.successRate) {
        return current;
      }
      return best;
    });
    
    if (bestTimePattern != null && bestTimePattern.successRate > 0.8) {
      insights.add(AnalyticsInsight(
        id: 'time_optimization_${DateTime.now().millisecondsSinceEpoch}',
        type: InsightType.optimization,
        priority: InsightPriority.medium,
        title: '最適な時間帯を発見！',
        description: '${bestTimePattern.hour}時台の成功率が${(bestTimePattern.successRate * 100).toStringAsFixed(1)}%と最も高いです。この時間帯により多くのクエストをスケジュールしてみませんか？',
        actionItems: [
          ActionItem(
            title: 'スケジュールを調整',
            description: '${bestTimePattern.hour}時台により多くのクエストを配置する',
            actionType: ActionType.adjustSchedule,
          ),
        ],
        confidence: bestTimePattern.successRate,
        relatedPatterns: const [],
        metadata: {
          'optimal_hour': bestTimePattern.hour,
          'success_rate': bestTimePattern.successRate,
          'completion_count': bestTimePattern.completionCount,
        },
        generatedAt: DateTime.now(),
      ));
    }
    
    // 曜日最適化インサイト
    final dayPatterns = await _behaviorAnalysisService.analyzeDayOfWeekPatterns();
    final bestDayPattern = dayPatterns.fold<DayOfWeekPattern?>(null, (best, current) {
      if (best == null || current.successRate > best.successRate) {
        return current;
      }
      return best;
    });
    
    if (bestDayPattern != null && bestDayPattern.successRate > 0.8) {
      insights.add(AnalyticsInsight(
        id: 'day_optimization_${DateTime.now().millisecondsSinceEpoch}',
        type: InsightType.optimization,
        priority: InsightPriority.medium,
        title: '${bestDayPattern.dayName}曜日が最適！',
        description: '${bestDayPattern.dayName}曜日の成功率が${(bestDayPattern.successRate * 100).toStringAsFixed(1)}%と最も高いです。この曜日のパターンを他の曜日にも応用してみましょう。',
        actionItems: [
          ActionItem(
            title: 'パターンを分析',
            description: '${bestDayPattern.dayName}曜日の成功要因を他の曜日に適用する',
            actionType: ActionType.viewStats,
          ),
        ],
        confidence: bestDayPattern.successRate,
        relatedPatterns: const [],
        metadata: {
          'optimal_day': bestDayPattern.dayOfWeek,
          'day_name': bestDayPattern.dayName,
          'success_rate': bestDayPattern.successRate,
          'completion_count': bestDayPattern.completionCount,
        },
        generatedAt: DateTime.now(),
      ));
    }
    
    return insights;
  }

  /// 達成に関するインサイトを生成
  Future<List<AnalyticsInsight>> _generateAchievementInsights() async {
    final insights = <AnalyticsInsight>[];
    
    // 季節別パフォーマンス
    final seasonalPatterns = await _behaviorAnalysisService.analyzeSeasonalPatterns();
    final currentSeason = SeasonFromMonth.fromMonth(DateTime.now().month);
    final currentSeasonPattern = seasonalPatterns.firstWhere(
      (pattern) => pattern.season == currentSeason,
      orElse: () => SeasonalPattern(
        season: currentSeason,
        successRate: 0.0,
        completionCount: 0,
        popularCategories: const [],
      ),
    );
    
    if (currentSeasonPattern.successRate > 0.7) {
      insights.add(AnalyticsInsight(
        id: 'seasonal_achievement_${DateTime.now().millisecondsSinceEpoch}',
        type: InsightType.achievement,
        priority: InsightPriority.low,
        title: '${currentSeason.displayName}の好調をキープ！',
        description: '${currentSeason.displayName}の成功率が${(currentSeasonPattern.successRate * 100).toStringAsFixed(1)}%と好調です。人気カテゴリ: ${currentSeasonPattern.popularCategories.join(', ')}',
        actionItems: const [
          ActionItem(
            title: '成果を記録',
            description: 'この季節の成功パターンを記録しておきましょう',
            actionType: ActionType.viewStats,
          ),
        ],
        confidence: currentSeasonPattern.successRate,
        relatedPatterns: const [],
        metadata: {
          'season': currentSeason.name,
          'success_rate': currentSeasonPattern.successRate,
          'popular_categories': currentSeasonPattern.popularCategories,
        },
        generatedAt: DateTime.now(),
      ));
    }
    
    return insights;
  }

  /// 信頼度を優先度にマッピング
  InsightPriority _mapConfidenceToPriority(double confidence) {
    if (confidence >= 0.9) return InsightPriority.critical;
    if (confidence >= 0.7) return InsightPriority.high;
    if (confidence >= 0.5) return InsightPriority.medium;
    return InsightPriority.low;
  }

  /// 優先度のスコアを取得
  int _getPriorityScore(InsightPriority priority) {
    switch (priority) {
      case InsightPriority.critical:
        return 4;
      case InsightPriority.high:
        return 3;
      case InsightPriority.medium:
        return 2;
      case InsightPriority.low:
        return 1;
    }
  }
}

final insightsEngineProvider = Provider<InsightsEngine>((ref) {
  final behaviorAnalysisService = ref.watch(behaviorAnalysisServiceProvider);
  return InsightsEngine(behaviorAnalysisService);
});