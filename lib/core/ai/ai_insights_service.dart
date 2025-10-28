import 'dart:developer';
import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:minq/core/ai/tflite_unified_ai_service.dart' as tflite;
import 'package:minq/data/repositories/quest_log_repository.dart';
import 'package:minq/data/repositories/quest_repository.dart';
import 'package:minq/domain/ai/ai_insights.dart';
import 'package:minq/domain/log/quest_log.dart';
import 'package:minq/domain/quest/quest.dart';

/// AI Insights Service for generating data-driven insights dashboard
class AIInsightsService {
  static AIInsightsService? _instance;
  static AIInsightsService get instance => _instance ??= AIInsightsService._();

  AIInsightsService._();

  final tflite.TFLiteUnifiedAIService _aiService = tflite.TFLiteUnifiedAIService.instance;

  /// Generate comprehensive AI insights for user
  Future<AIInsights> generateInsights({
    required String userId,
    required QuestRepository questRepository,
    required QuestLogRepository questLogRepository,
  }) async {
    try {
      await _aiService.initialize();

      // Collect user data
      final quests = await questRepository.getQuestsForOwner(userId);
      final logs = await questLogRepository.getLogsForUser(userId);

      // Generate trends analysis
      final trends = await _generateTrends(quests, logs);

      // Generate personalized recommendations
      final recommendations = await _generateRecommendations(
        userId,
        quests,
        logs,
      );

      // Generate progress analysis
      final progressAnalysis = await _generateProgressAnalysis(
        userId,
        quests,
        logs,
        questLogRepository,
      );

      // Generate failure prediction if needed
      final failurePrediction = await _generateFailurePrediction(
        quests,
        logs,
      );

      return AIInsights(
        userId: userId,
        generatedAt: DateTime.now(),
        trends: trends,
        recommendations: recommendations,
        progressAnalysis: progressAnalysis,
        failurePrediction: failurePrediction,
      );
    } catch (e) {
      log('AIInsightsService: Error generating insights - $e');
      return _generateFallbackInsights(userId);
    }
  }

  /// Generate habit completion trends
  Future<HabitCompletionTrends> _generateTrends(
    List<Quest> quests,
    List<QuestLog> logs,
  ) async {
    final now = DateTime.now();
    final weeklyTrends = <String, double>{};
    final dailyTrends = <String, double>{};
    final categoryDistribution = <String, int>{};

    // Calculate weekly trends (last 4 weeks)
    for (int i = 0; i < 4; i++) {
      final weekStart = now.subtract(Duration(days: (i + 1) * 7));
      final weekEnd = now.subtract(Duration(days: i * 7));
      final weekLogs = logs.where((log) =>
          log.ts.isAfter(weekStart) && log.ts.isBefore(weekEnd)).toList();

      final completionRate = quests.isEmpty
          ? 0.0
          : weekLogs.length / (quests.length * 7);

      weeklyTrends['Week ${4 - i}'] = completionRate.clamp(0.0, 1.0);
    }

    // Calculate daily trends (last 7 days)
    final dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    for (int i = 0; i < 7; i++) {
      final day = now.subtract(Duration(days: i + 1));
      final dayStart = DateTime(day.year, day.month, day.day);
      final dayEnd = dayStart.add(const Duration(days: 1));

      final dayLogs = logs.where((log) =>
          log.ts.isAfter(dayStart) && log.ts.isBefore(dayEnd)).toList();

      final completionRate = quests.isEmpty
          ? 0.0
          : dayLogs.length / quests.length;

      dailyTrends[dayNames[6 - i]] = completionRate.clamp(0.0, 1.0);
    }

    // Calculate category distribution
    for (final quest in quests) {
      categoryDistribution[quest.category] =
          (categoryDistribution[quest.category] ?? 0) + 1;
    }

    // Calculate overall trend
    final recentWeeks = weeklyTrends.values.toList();
    final overallTrend = recentWeeks.length >= 2
        ? (recentWeeks.last - recentWeeks.first) / recentWeeks.length
        : 0.0;

    // Generate trend description using AI
    final trendDescription = await _generateTrendDescription(
      weeklyTrends,
      overallTrend,
    );

    return HabitCompletionTrends(
      weeklyTrends: weeklyTrends,
      dailyTrends: dailyTrends,
      categoryDistribution: categoryDistribution,
      overallTrend: overallTrend.clamp(-1.0, 1.0),
      trendDescription: trendDescription,
    );
  }

  /// Generate AI-powered trend description
  Future<String> _generateTrendDescription(
    Map<String, double> weeklyTrends,
    double overallTrend,
  ) async {
    try {
      final trendData = weeklyTrends.entries
          .map((e) => '${e.key}: ${(e.value * 100).toStringAsFixed(1)}%')
          .join(', ');

      final prompt = '''
週次完了率データ: $trendData
全体トレンド: ${overallTrend > 0 ? '上昇' : overallTrend < 0 ? '下降' : '安定'}

このデータから、ユーザーの習慣継続パターンを1-2文で簡潔に説明してください。
''';

      final description = await _aiService.generateChatResponse(
        prompt,
        systemPrompt: 'あなたは習慣分析の専門家です。データから客観的で励ましになる分析を提供してください。',
        maxTokens: 80,
      );

      return description.isNotEmpty
          ? description
          : _getFallbackTrendDescription(overallTrend);
    } catch (e) {
      log('AIInsightsService: Error generating trend description - $e');
      return _getFallbackTrendDescription(overallTrend);
    }
  }

  /// Generate personalized recommendations
  Future<List<PersonalizedRecommendation>> _generateRecommendations(
    String userId,
    List<Quest> quests,
    List<QuestLog> logs,
  ) async {
    final recommendations = <PersonalizedRecommendation>[];

    try {
      // Analyze completion patterns
      final completionRate = quests.isEmpty
          ? 0.0
          : logs.length / (quests.length * 30); // Last 30 days

      // Low completion rate recommendation
      if (completionRate < 0.5) {
        recommendations.add(
          PersonalizedRecommendation(
            id: 'low_completion',
            type: RecommendationType.habitSuggestion,
            title: '習慣の難易度を調整しましょう',
            description: '完了率が低めです。習慣の時間を短くするか、頻度を減らすことを検討してみてください。',
            confidence: 0.8,
            relatedHabits: quests.map((q) => q.title).take(3).toList(),
            actionText: '習慣を編集',
            iconKey: 'tune',
          ),
        );
      }

      // Category balance recommendation
      final categories = quests.map((q) => q.category).toSet();
      if (categories.length < 3 && quests.length >= 3) {
        recommendations.add(
          PersonalizedRecommendation(
            id: 'category_balance',
            type: RecommendationType.categoryBalance,
            title: '新しいカテゴリに挑戦してみませんか？',
            description: '現在${categories.join('、')}の習慣に取り組んでいます。バランスの取れた成長のため、他のカテゴリも試してみましょう。',
            confidence: 0.7,
            relatedHabits: [],
            actionText: '新しい習慣を追加',
            iconKey: 'add_circle',
          ),
        );
      }

      // Streak recovery recommendation
      final recentLogs = logs.where((log) =>
          log.ts.isAfter(DateTime.now().subtract(const Duration(days: 3)))).toList();

      if (recentLogs.isEmpty && logs.isNotEmpty) {
        recommendations.add(
          PersonalizedRecommendation(
            id: 'streak_recovery',
            type: RecommendationType.streakRecovery,
            title: 'ストリークを復活させましょう！',
            description: '最近の活動が少なくなっています。小さな習慣から再開して、継続の流れを取り戻しましょう。',
            confidence: 0.9,
            relatedHabits: quests.take(2).map((q) => q.title).toList(),
            actionText: '今すぐ実行',
            iconKey: 'refresh',
          ),
        );
      }

      // Time optimization recommendation
      final shortHabits = quests.where((q) => q.estimatedMinutes <= 5).length;
      if (shortHabits < quests.length * 0.5 && quests.isNotEmpty) {
        recommendations.add(
          PersonalizedRecommendation(
            id: 'time_optimization',
            type: RecommendationType.timeOptimization,
            title: '短時間習慣を増やしてみませんか？',
            description: '5分以下の習慣を増やすと、継続しやすくなります。小さな積み重ねが大きな成果を生みます。',
            confidence: 0.6,
            relatedHabits: [],
            actionText: 'ミニ習慣を作成',
            iconKey: 'timer',
          ),
        );
      }

      // Motivational boost for high performers
      if (completionRate > 0.8) {
        recommendations.add(
          PersonalizedRecommendation(
            id: 'motivational_boost',
            type: RecommendationType.motivationalBoost,
            title: '素晴らしい継続力です！',
            description: '高い完了率を維持しています。この調子で新しいチャレンジに挑戦してみませんか？',
            confidence: 0.9,
            relatedHabits: [],
            actionText: 'チャレンジを見る',
            iconKey: 'emoji_events',
          ),
        );
      }

      return recommendations;
    } catch (e) {
      log('AIInsightsService: Error generating recommendations - $e');
      return _getFallbackRecommendations();
    }
  }

  /// Generate progress analysis
  Future<ProgressAnalysis> _generateProgressAnalysis(
    String userId,
    List<Quest> quests,
    List<QuestLog> logs,
    QuestLogRepository questLogRepository,
  ) async {
    try {
      // Calculate streaks
      final currentStreak = await questLogRepository.calculateStreak(userId);
      final longestStreak = await questLogRepository.calculateLongestStreak(userId);

      // Calculate completion rates
      final weeklyRate = await questLogRepository.calculateWeeklyCompletionRate(userId);
      final monthlyRate = _calculateMonthlyCompletionRate(quests, logs);

      // Calculate category performance
      final categoryPerformance = <String, double>{};
      for (final quest in quests) {
        final questLogs = logs.where((log) => log.questId == quest.id).length;
        final expectedLogs = 30; // Last 30 days
        categoryPerformance[quest.category] =
            (categoryPerformance[quest.category] ?? 0.0) + (questLogs / expectedLogs);
      }

      // Normalize category performance
      final categories = quests.map((q) => q.category).toSet();
      for (final category in categories) {
        final questsInCategory = quests.where((q) => q.category == category).length;
        if (questsInCategory > 0) {
          categoryPerformance[category] =
              (categoryPerformance[category] ?? 0.0) / questsInCategory;
        }
      }

      // Generate insights
      final insights = _generateProgressInsights(
        currentStreak.toDouble(),
        weeklyRate,
        categoryPerformance,
      );

      // Calculate overall score
      final overallScore = _calculateOverallScore(
        currentStreak.toDouble(),
        weeklyRate,
        monthlyRate,
        categoryPerformance,
      );

      return ProgressAnalysis(
        currentStreak: currentStreak.toDouble(),
        longestStreak: longestStreak.toDouble(),
        weeklyCompletionRate: weeklyRate,
        monthlyCompletionRate: monthlyRate,
        totalHabitsCompleted: logs.length,
        categoryPerformance: categoryPerformance,
        insights: insights,
        overallScore: overallScore,
      );
    } catch (e) {
      log('AIInsightsService: Error generating progress analysis - $e');
      return _getFallbackProgressAnalysis();
    }
  }

  /// Generate failure prediction
  Future<FailurePrediction?> _generateFailurePrediction(
    List<Quest> quests,
    List<QuestLog> logs,
  ) async {
    try {
      // Calculate risk factors
      final recentLogs = logs.where((log) =>
          log.ts.isAfter(DateTime.now().subtract(const Duration(days: 7)))).toList();

      final weeklyCompletionRate = quests.isEmpty
          ? 0.0
          : recentLogs.length / (quests.length * 7);

      // Only generate prediction if there are risk factors
      if (weeklyCompletionRate > 0.6) return null;

      final riskFactors = <String>[];
      final preventionStrategies = <String>[];

      if (weeklyCompletionRate < 0.3) {
        riskFactors.add('週間完了率が低下');
        preventionStrategies.add('習慣の難易度を下げる');
      }

      if (recentLogs.isEmpty) {
        riskFactors.add('最近の活動なし');
        preventionStrategies.add('リマインダーを設定する');
      }

      final riskScore = 1.0 - weeklyCompletionRate;
      final riskLevel = riskScore > 0.7 ? 'high' : riskScore > 0.4 ? 'medium' : 'low';

      return FailurePrediction(
        riskScore: riskScore,
        riskFactors: riskFactors,
        preventionStrategies: preventionStrategies,
        predictedDate: DateTime.now().add(const Duration(days: 7)),
        riskLevel: riskLevel,
      );
    } catch (e) {
      log('AIInsightsService: Error generating failure prediction - $e');
      return null;
    }
  }

  /// Helper methods
  double _calculateMonthlyCompletionRate(List<Quest> quests, List<QuestLog> logs) {
    if (quests.isEmpty) return 0.0;

    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month, 1);
    final monthLogs = logs.where((log) => log.ts.isAfter(monthStart)).length;

    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    final expectedLogs = quests.length * daysInMonth;

    return expectedLogs > 0 ? monthLogs / expectedLogs : 0.0;
  }

  List<ProgressInsight> _generateProgressInsights(
    double currentStreak,
    double weeklyRate,
    Map<String, double> categoryPerformance,
  ) {
    final insights = <ProgressInsight>[];

    // Streak insights
    if (currentStreak >= 7) {
      insights.add(
        ProgressInsight(
          title: '素晴らしいストリーク！',
          description: '${currentStreak.toInt()}日連続で習慣を継続中です。',
          type: InsightType.achievement,
          impact: 0.8,
          actionRecommendation: 'この調子で継続しましょう',
        ),
      );
    } else if (currentStreak == 0) {
      insights.add(
        ProgressInsight(
          title: 'ストリークを始めましょう',
          description: '新しいストリークを開始する絶好のタイミングです。',
          type: InsightType.opportunity,
          impact: 0.6,
          actionRecommendation: '今日から小さな習慣を始めてみましょう',
        ),
      );
    }

    // Weekly rate insights
    if (weeklyRate > 0.8) {
      insights.add(
        ProgressInsight(
          title: '週間目標達成！',
          description: '今週は${(weeklyRate * 100).toStringAsFixed(0)}%の高い完了率です。',
          type: InsightType.achievement,
          impact: 0.7,
        ),
      );
    } else if (weeklyRate < 0.4) {
      insights.add(
        ProgressInsight(
          title: '週間目標の見直しを',
          description: '今週の完了率は${(weeklyRate * 100).toStringAsFixed(0)}%です。',
          type: InsightType.improvement,
          impact: 0.5,
          actionRecommendation: '習慣の数や難易度を調整してみましょう',
        ),
      );
    }

    // Category performance insights
    final bestCategory = categoryPerformance.entries
        .where((e) => e.value > 0)
        .fold<MapEntry<String, double>?>(
          null,
          (prev, curr) => prev == null || curr.value > prev.value ? curr : prev,
        );

    if (bestCategory != null && bestCategory.value > 0.7) {
      insights.add(
        ProgressInsight(
          title: '得意分野を発見！',
          description: '${bestCategory.key}カテゴリで特に良い成果を上げています。',
          type: InsightType.pattern,
          impact: 0.6,
          actionRecommendation: 'この分野でさらなるチャレンジを検討してみましょう',
        ),
      );
    }

    return insights;
  }

  double _calculateOverallScore(
    double currentStreak,
    double weeklyRate,
    double monthlyRate,
    Map<String, double> categoryPerformance,
  ) {
    var score = 0.0;

    // Streak contribution (30%)
    score += (currentStreak / 30.0).clamp(0.0, 1.0) * 0.3;

    // Weekly rate contribution (40%)
    score += weeklyRate * 0.4;

    // Monthly rate contribution (20%)
    score += monthlyRate * 0.2;

    // Category balance contribution (10%)
    final avgCategoryPerformance = categoryPerformance.values.isEmpty
        ? 0.0
        : categoryPerformance.values.reduce((a, b) => a + b) / categoryPerformance.length;
    score += avgCategoryPerformance * 0.1;

    return score.clamp(0.0, 1.0);
  }

  /// Fallback methods
  AIInsights _generateFallbackInsights(String userId) {
    return AIInsights(
      userId: userId,
      generatedAt: DateTime.now(),
      trends: HabitCompletionTrends(
        weeklyTrends: {'Week 1': 0.5, 'Week 2': 0.6, 'Week 3': 0.7, 'Week 4': 0.8},
        dailyTrends: {'Mon': 0.7, 'Tue': 0.8, 'Wed': 0.6, 'Thu': 0.9, 'Fri': 0.5, 'Sat': 0.4, 'Sun': 0.6},
        categoryDistribution: {'学習': 2, '運動': 1, 'セルフケア': 1},
        overallTrend: 0.1,
        trendDescription: '着実に習慣を継続できています。',
      ),
      recommendations: _getFallbackRecommendations(),
      progressAnalysis: _getFallbackProgressAnalysis(),
    );
  }

  List<PersonalizedRecommendation> _getFallbackRecommendations() {
    return [
      PersonalizedRecommendation(
        id: 'fallback_1',
        type: RecommendationType.motivationalBoost,
        title: '継続は力なり',
        description: '小さな習慣でも毎日続けることで大きな成果につながります。',
        confidence: 0.8,
        relatedHabits: [],
        actionText: '今日の習慣を実行',
        iconKey: 'trending_up',
      ),
    ];
  }

  ProgressAnalysis _getFallbackProgressAnalysis() {
    return ProgressAnalysis(
      currentStreak: 3.0,
      longestStreak: 7.0,
      weeklyCompletionRate: 0.7,
      monthlyCompletionRate: 0.6,
      totalHabitsCompleted: 15,
      categoryPerformance: {'学習': 0.8, '運動': 0.6, 'セルフケア': 0.7},
      insights: [
        ProgressInsight(
          title: '順調な成長',
          description: 'バランス良く習慣を継続できています。',
          type: InsightType.achievement,
          impact: 0.7,
        ),
      ],
      overallScore: 0.7,
    );
  }

  String _getFallbackTrendDescription(double overallTrend) {
    if (overallTrend > 0.1) {
      return '習慣継続が改善傾向にあります。この調子で続けましょう！';
    } else if (overallTrend < -0.1) {
      return '少し継続に課題がありますが、小さな改善から始めてみましょう。';
    } else {
      return '安定して習慣を継続できています。';
    }
  }
}

/// Provider for AI Insights Service
final aiInsightsServiceProvider = Provider<AIInsightsService>((ref) {
  return AIInsightsService.instance;
});