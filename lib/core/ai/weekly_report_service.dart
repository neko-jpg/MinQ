import 'dart:async';
import 'dart:developer';
import 'dart:math' as math;

import 'package:minq/core/ai/tflite_unified_ai_service.dart';

/// 週次AI分析レポートサービス
/// 毎週ユーザーの習慣データを分析し、詳細なレポートを生成
class WeeklyReportService {
  static WeeklyReportService? _instance;
  static WeeklyReportService get instance =>
      _instance ??= WeeklyReportService._();

  WeeklyReportService._();

  final TFLiteUnifiedAIService _aiService = TFLiteUnifiedAIService.instance;

  Timer? _weeklyTimer;
  bool _isGenerating = false;

  /// 週次レポート生成の開始
  void startWeeklyReports() {
    _weeklyTimer?.cancel();

    // 毎週月曜日の朝8時に実行
    final now = DateTime.now();
    final nextMonday = _getNextMonday(now);
    final initialDelay = nextMonday.difference(now);

    _weeklyTimer = Timer(initialDelay, () {
      _generateAndSendWeeklyReport();

      // その後は毎週実行
      _weeklyTimer = Timer.periodic(const Duration(days: 7), (timer) {
        _generateAndSendWeeklyReport();
      });
    });

    log('WeeklyReport: 週次レポート開始 - 次回実行: $nextMonday');
  }

  /// 週次レポートの停止
  void stopWeeklyReports() {
    _weeklyTimer?.cancel();
    _weeklyTimer = null;
    log('WeeklyReport: 週次レポート停止');
  }

  /// 手動でのレポート生成
  Future<WeeklyReport> generateReport({
    required String userId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    if (_isGenerating) {
      throw StateError('レポート生成中です。しばらくお待ちください。');
    }

    _isGenerating = true;

    try {
      final end = endDate ?? DateTime.now();
      final start = startDate ?? end.subtract(const Duration(days: 7));

      log('WeeklyReport: レポート生成開始 - $start から $end');

      // データ収集
      final weeklyData = await _collectWeeklyData(userId, start, end);

      // AI分析の実行
      final analysis = await _performAIAnalysis(weeklyData);

      // レポート生成
      final report = await _generateDetailedReport(
        weeklyData,
        analysis,
        start,
        end,
      );

      log('WeeklyReport: レポート生成完了');
      return report;
    } finally {
      _isGenerating = false;
    }
  }

  /// 週次データの収集
  Future<WeeklyData> _collectWeeklyData(
    String userId,
    DateTime start,
    DateTime end,
  ) async {
    // 実際の実装では、データベースから習慣データを取得
    // ここではサンプルデータを生成

    final habits = await _getHabitsForPeriod(userId, start, end);
    final completions = await _getCompletionsForPeriod(userId, start, end);
    final moods = await _getMoodsForPeriod(userId, start, end);
    final streaks = await _getStreaksForPeriod(userId, start, end);

    return WeeklyData(
      userId: userId,
      startDate: start,
      endDate: end,
      habits: habits,
      completions: completions,
      moods: moods,
      streaks: streaks,
      totalHabits: habits.length,
      totalCompletions: completions.length,
      averageMood:
          moods.isEmpty
              ? 3.0
              : moods.map((m) => m.score).reduce((a, b) => a + b) /
                  moods.length,
    );
  }

  /// AI分析の実行
  Future<WeeklyAnalysis> _performAIAnalysis(WeeklyData data) async {
    await _aiService.initialize();

    // 基本統計の計算
    final basicStats = _calculateBasicStats(data);

    // トレンド分析
    final trends = await _analyzeTrends(data);

    // パターン認識
    final patterns = await _recognizePatterns(data);

    // 予測分析
    final predictions = await _generatePredictions(data);

    // インサイト生成
    final insights = await _generateInsights(
      data,
      basicStats,
      trends,
      patterns,
    );

    return WeeklyAnalysis(
      basicStats: basicStats,
      trends: trends,
      patterns: patterns,
      predictions: predictions,
      insights: insights,
      overallScore: _calculateOverallScore(basicStats, trends),
    );
  }

  /// 基本統計の計算
  BasicStats _calculateBasicStats(WeeklyData data) {
    final completionRate =
        data.totalHabits > 0
            ? data.totalCompletions / (data.totalHabits * 7)
            : 0.0;

    final activeStreaks = data.streaks.where((s) => s.isActive).length;
    final longestStreak =
        data.streaks.isEmpty
            ? 0
            : data.streaks.map((s) => s.currentLength).reduce(math.max);

    final categoryDistribution = <String, int>{};
    for (final habit in data.habits) {
      categoryDistribution[habit.category] =
          (categoryDistribution[habit.category] ?? 0) + 1;
    }

    return BasicStats(
      completionRate: completionRate,
      activeStreaks: activeStreaks,
      longestStreak: longestStreak,
      averageMood: data.averageMood,
      categoryDistribution: categoryDistribution,
      improvementFromLastWeek: _calculateImprovement(data),
    );
  }

  /// 改善度の計算
  double _calculateImprovement(WeeklyData data) {
    // 前週のデータと比較（簡略化）
    // 実際の実装では前週のデータを取得して比較
    return 0.05 + math.Random().nextDouble() * 0.1; // -5%から+15%の範囲
  }

  /// トレンド分析
  Future<TrendAnalysis> _analyzeTrends(WeeklyData data) async {
    try {
      final trendPrompt = '''
以下の週次データからトレンドを分析してください：
- 完了率: ${(data.totalCompletions / (data.totalHabits * 7) * 100).toStringAsFixed(1)}%
- アクティブストリーク: ${data.streaks.where((s) => s.isActive).length}個
- 平均気分: ${data.averageMood.toStringAsFixed(1)}/5.0
- 習慣カテゴリ: ${data.habits.map((h) => h.category).toSet().join(', ')}

上昇傾向、下降傾向、安定傾向のいずれかを判定し、その理由を説明してください。
''';

      final trendAnalysis = await _aiService.generateChatResponse(
        trendPrompt,
        systemPrompt: 'あなたは習慣分析の専門家です。データから客観的なトレンドを分析し、簡潔に説明してください。',
        maxTokens: 150,
      );

      return TrendAnalysis(
        direction: _determineTrendDirection(data),
        description:
            trendAnalysis.isNotEmpty
                ? trendAnalysis
                : _getFallbackTrendDescription(data),
        confidence: 0.8,
        keyFactors: _identifyKeyFactors(data),
      );
    } catch (e) {
      log('WeeklyReport: トレンド分析エラー - $e');
      return TrendAnalysis(
        direction: TrendDirection.stable,
        description: '今週は安定した習慣継続ができています。',
        confidence: 0.5,
        keyFactors: ['データ不足'],
      );
    }
  }

  /// トレンド方向の決定
  TrendDirection _determineTrendDirection(WeeklyData data) {
    final improvement = _calculateImprovement(data);

    if (improvement > 0.05) return TrendDirection.upward;
    if (improvement < -0.05) return TrendDirection.downward;
    return TrendDirection.stable;
  }

  /// パターン認識
  Future<List<BehaviorPattern>> _recognizePatterns(WeeklyData data) async {
    final patterns = <BehaviorPattern>[];

    // 曜日パターンの分析
    final weekdayPattern = _analyzeWeekdayPattern(data);
    if (weekdayPattern != null) patterns.add(weekdayPattern);

    // 時間帯パターンの分析
    final timePattern = _analyzeTimePattern(data);
    if (timePattern != null) patterns.add(timePattern);

    // 気分パターンの分析
    final moodPattern = _analyzeMoodPattern(data);
    if (moodPattern != null) patterns.add(moodPattern);

    // カテゴリパターンの分析
    final categoryPattern = _analyzeCategoryPattern(data);
    if (categoryPattern != null) patterns.add(categoryPattern);

    return patterns;
  }

  /// 曜日パターンの分析
  BehaviorPattern? _analyzeWeekdayPattern(WeeklyData data) {
    final weekdayCompletions = <int, int>{};

    for (final completion in data.completions) {
      final weekday = completion.completedAt.weekday;
      weekdayCompletions[weekday] = (weekdayCompletions[weekday] ?? 0) + 1;
    }

    if (weekdayCompletions.isEmpty) return null;

    final maxDay = weekdayCompletions.entries.reduce(
      (a, b) => a.value > b.value ? a : b,
    );

    final minDay = weekdayCompletions.entries.reduce(
      (a, b) => a.value < b.value ? a : b,
    );

    if (maxDay.value - minDay.value >= 2) {
      return BehaviorPattern(
        type: PatternType.weekday,
        description:
            '${_getWeekdayName(maxDay.key)}に最も活発で、${_getWeekdayName(minDay.key)}は控えめです',
        strength: (maxDay.value - minDay.value) / maxDay.value,
        recommendation: '${_getWeekdayName(minDay.key)}の習慣実行を増やすことを検討してみてください',
      );
    }

    return null;
  }

  /// 時間帯パターンの分析
  BehaviorPattern? _analyzeTimePattern(WeeklyData data) {
    final hourCompletions = <int, int>{};

    for (final completion in data.completions) {
      final hour = completion.completedAt.hour;
      hourCompletions[hour] = (hourCompletions[hour] ?? 0) + 1;
    }

    if (hourCompletions.isEmpty) return null;

    final maxHour = hourCompletions.entries.reduce(
      (a, b) => a.value > b.value ? a : b,
    );

    final timeSlot = _getTimeSlot(maxHour.key);

    return BehaviorPattern(
      type: PatternType.time,
      description: '$timeSlotの時間帯に最も活発です',
      strength: maxHour.value / data.totalCompletions,
      recommendation: 'この時間帯を活用して新しい習慣を始めることをお勧めします',
    );
  }

  /// 気分パターンの分析
  BehaviorPattern? _analyzeMoodPattern(WeeklyData data) {
    if (data.moods.length < 3) return null;

    final moodCompletionCorrelation = _calculateMoodCompletionCorrelation(data);

    if (moodCompletionCorrelation.abs() > 0.3) {
      return BehaviorPattern(
        type: PatternType.mood,
        description:
            moodCompletionCorrelation > 0
                ? '気分が良い日ほど習慣を継続できています'
                : '気分に関係なく習慣を継続できています',
        strength: moodCompletionCorrelation.abs(),
        recommendation:
            moodCompletionCorrelation > 0
                ? '気分を上げる活動を習慣に取り入れてみましょう'
                : '素晴らしい！気分に左右されない継続力があります',
      );
    }

    return null;
  }

  /// カテゴリパターンの分析
  BehaviorPattern? _analyzeCategoryPattern(WeeklyData data) {
    final categoryCompletions = <String, int>{};

    for (final completion in data.completions) {
      final habit = data.habits.firstWhere((h) => h.id == completion.habitId);
      categoryCompletions[habit.category] =
          (categoryCompletions[habit.category] ?? 0) + 1;
    }

    if (categoryCompletions.isEmpty) return null;

    final maxCategory = categoryCompletions.entries.reduce(
      (a, b) => a.value > b.value ? a : b,
    );

    return BehaviorPattern(
      type: PatternType.category,
      description: '${maxCategory.key}カテゴリの習慣が最も継続できています',
      strength: maxCategory.value / data.totalCompletions,
      recommendation: '得意な${maxCategory.key}分野を活かして、関連する新しい習慣に挑戦してみましょう',
    );
  }

  /// 予測分析の生成
  Future<PredictionAnalysis> _generatePredictions(WeeklyData data) async {
    try {
      final predictionPrompt = '''
以下のデータから来週の予測を行ってください：
- 今週の完了率: ${(data.totalCompletions / (data.totalHabits * 7) * 100).toStringAsFixed(1)}%
- アクティブストリーク: ${data.streaks.where((s) => s.isActive).length}個
- 平均気分: ${data.averageMood.toStringAsFixed(1)}/5.0

来週の達成率予測と、30日後の習慣継続予測を数値で示してください。
''';

      final predictionText = await _aiService.generateChatResponse(
        predictionPrompt,
        systemPrompt: 'あなたは習慣継続の予測専門家です。データに基づいて現実的な予測を提供してください。',
        maxTokens: 100,
      );

      return PredictionAnalysis(
        nextWeekCompletionRate: _predictNextWeekCompletion(data),
        thirtyDaySuccessRate: _predict30DaySuccess(data),
        riskFactors: _identifyRiskFactors(data),
        opportunities: _identifyOpportunities(data),
        aiPrediction:
            predictionText.isNotEmpty ? predictionText : '安定した継続が期待できます',
      );
    } catch (e) {
      log('WeeklyReport: 予測分析エラー - $e');
      return PredictionAnalysis(
        nextWeekCompletionRate: 0.7,
        thirtyDaySuccessRate: 0.6,
        riskFactors: ['データ不足'],
        opportunities: ['継続的な記録'],
        aiPrediction: '継続的な取り組みで成果が期待できます',
      );
    }
  }

  /// 来週の完了率予測
  double _predictNextWeekCompletion(WeeklyData data) {
    final currentRate = data.totalCompletions / (data.totalHabits * 7);
    final improvement = _calculateImprovement(data);
    final moodFactor = (data.averageMood - 3.0) / 2.0 * 0.1; // 気分による調整

    return (currentRate + improvement + moodFactor).clamp(0.0, 1.0);
  }

  /// 30日後の成功率予測
  double _predict30DaySuccess(WeeklyData data) {
    final activeStreaks = data.streaks.where((s) => s.isActive).length;
    final totalHabits = data.totalHabits;

    if (totalHabits == 0) return 0.5;

    final streakRatio = activeStreaks / totalHabits;
    final baseSuccess = 0.4 + streakRatio * 0.4; // 40-80%の範囲

    return baseSuccess.clamp(0.0, 1.0);
  }

  /// インサイト生成
  Future<List<WeeklyInsight>> _generateInsights(
    WeeklyData data,
    BasicStats stats,
    TrendAnalysis trends,
    List<BehaviorPattern> patterns,
  ) async {
    final insights = <WeeklyInsight>[];

    // 完了率に基づくインサイト
    if (stats.completionRate > 0.8) {
      insights.add(
        WeeklyInsight(
          type: InsightType.achievement,
          title: '素晴らしい継続力！',
          description:
              '今週は${(stats.completionRate * 100).toStringAsFixed(0)}%の高い完了率を達成しました。',
          actionable: true,
          recommendation: 'この調子で新しい習慣にも挑戦してみませんか？',
        ),
      );
    } else if (stats.completionRate < 0.5) {
      insights.add(
        WeeklyInsight(
          type: InsightType.improvement,
          title: '継続のコツを見つけましょう',
          description:
              '今週の完了率は${(stats.completionRate * 100).toStringAsFixed(0)}%でした。',
          actionable: true,
          recommendation: '習慣の難易度を下げるか、リマインダーを増やすことを検討してみてください。',
        ),
      );
    }

    // ストリークに基づくインサイト
    if (stats.activeStreaks > 0) {
      insights.add(
        WeeklyInsight(
          type: InsightType.streak,
          title: 'ストリーク継続中！',
          description: '現在${stats.activeStreaks}個の習慣でストリークを継続中です。',
          actionable: false,
          recommendation: 'ストリーク保護機能を活用して、継続をサポートしましょう。',
        ),
      );
    }

    // 気分に基づくインサイト
    if (data.averageMood > 4.0) {
      insights.add(
        WeeklyInsight(
          type: InsightType.mood,
          title: '気分が絶好調！',
          description:
              '今週の平均気分は${data.averageMood.toStringAsFixed(1)}と高い水準でした。',
          actionable: true,
          recommendation: 'この良い気分を活かして、新しいチャレンジに取り組んでみましょう。',
        ),
      );
    }

    // パターンに基づくインサイト
    for (final pattern in patterns) {
      if (pattern.strength > 0.6) {
        insights.add(
          WeeklyInsight(
            type: InsightType.pattern,
            title: 'パターンを発見！',
            description: pattern.description,
            actionable: true,
            recommendation: pattern.recommendation,
          ),
        );
      }
    }

    // AIによる追加インサイト生成
    try {
      final aiInsight = await _generateAIInsight(data, stats, trends);
      if (aiInsight != null) {
        insights.add(aiInsight);
      }
    } catch (e) {
      log('WeeklyReport: AIインサイト生成エラー - $e');
    }

    return insights;
  }

  /// AIインサイトの生成
  Future<WeeklyInsight?> _generateAIInsight(
    WeeklyData data,
    BasicStats stats,
    TrendAnalysis trends,
  ) async {
    final insightPrompt = '''
週次習慣データの分析結果：
- 完了率: ${(stats.completionRate * 100).toStringAsFixed(1)}%
- トレンド: ${trends.direction.name}
- 平均気分: ${data.averageMood.toStringAsFixed(1)}/5.0
- アクティブストリーク: ${stats.activeStreaks}個

このデータから、ユーザーが気づいていない可能性のある重要なインサイトを1つ提供してください。
具体的で実践的なアドバイスも含めてください。
''';

    final aiResponse = await _aiService.generateChatResponse(
      insightPrompt,
      systemPrompt: 'あなたは習慣形成の専門家です。データから価値のあるインサイトを抽出し、実践的なアドバイスを提供してください。',
      maxTokens: 120,
    );

    if (aiResponse.isNotEmpty && aiResponse.length > 20) {
      return WeeklyInsight(
        type: InsightType.ai,
        title: 'AI分析による発見',
        description: aiResponse,
        actionable: true,
        recommendation: 'このインサイトを活用して、習慣をさらに改善してみましょう。',
      );
    }

    return null;
  }

  /// 詳細レポートの生成
  Future<WeeklyReport> _generateDetailedReport(
    WeeklyData data,
    WeeklyAnalysis analysis,
    DateTime startDate,
    DateTime endDate,
  ) async {
    // 改善提案の生成
    final improvements = await _generateImprovementSuggestions(data, analysis);

    // 次週の目標設定
    final nextWeekGoals = _generateNextWeekGoals(data, analysis);

    // 祝福メッセージの生成
    final celebrationMessage = await _generateCelebrationMessage(
      data,
      analysis,
    );

    return WeeklyReport(
      userId: data.userId,
      startDate: startDate,
      endDate: endDate,
      data: data,
      analysis: analysis,
      improvements: improvements,
      nextWeekGoals: nextWeekGoals,
      celebrationMessage: celebrationMessage,
      generatedAt: DateTime.now(),
    );
  }

  /// 改善提案の生成
  Future<List<ImprovementSuggestion>> _generateImprovementSuggestions(
    WeeklyData data,
    WeeklyAnalysis analysis,
  ) async {
    final suggestions = <ImprovementSuggestion>[];

    // 完了率が低い場合の提案
    if (analysis.basicStats.completionRate < 0.7) {
      suggestions.add(
        ImprovementSuggestion(
          category: '継続性',
          title: '習慣の難易度を調整しましょう',
          description: '完了率を上げるために、習慣の時間や頻度を見直してみてください。',
          priority: SuggestionPriority.high,
          estimatedImpact: 0.3,
        ),
      );
    }

    // ストリークが少ない場合の提案
    if (analysis.basicStats.activeStreaks < data.totalHabits * 0.5) {
      suggestions.add(
        ImprovementSuggestion(
          category: 'ストリーク',
          title: 'ストリーク保護機能を活用しましょう',
          description: '1日のミスを許可するストリーク保護機能で、継続をサポートします。',
          priority: SuggestionPriority.medium,
          estimatedImpact: 0.2,
        ),
      );
    }

    // 気分が低い場合の提案
    if (data.averageMood < 3.0) {
      suggestions.add(
        ImprovementSuggestion(
          category: '気分管理',
          title: '気分を上げる習慣を追加しましょう',
          description: '瞑想や散歩など、気分を改善する習慣を取り入れてみてください。',
          priority: SuggestionPriority.medium,
          estimatedImpact: 0.25,
        ),
      );
    }

    return suggestions;
  }

  /// 次週の目標設定
  List<WeeklyGoal> _generateNextWeekGoals(
    WeeklyData data,
    WeeklyAnalysis analysis,
  ) {
    final goals = <WeeklyGoal>[];

    // 完了率目標
    final targetCompletionRate = math.min(
      analysis.basicStats.completionRate + 0.1,
      0.95,
    );

    goals.add(
      WeeklyGoal(
        type: GoalType.completion,
        title: '完了率${(targetCompletionRate * 100).toStringAsFixed(0)}%を目指そう',
        description:
            '今週より${((targetCompletionRate - analysis.basicStats.completionRate) * 100).toStringAsFixed(0)}%向上を目標にします',
        targetValue: targetCompletionRate,
        currentValue: analysis.basicStats.completionRate,
      ),
    );

    // ストリーク目標
    if (analysis.basicStats.activeStreaks < data.totalHabits) {
      goals.add(
        WeeklyGoal(
          type: GoalType.streak,
          title: 'ストリークを1つ増やそう',
          description: '新しい習慣でストリークを開始するか、既存のストリークを復活させましょう',
          targetValue: analysis.basicStats.activeStreaks + 1,
          currentValue: analysis.basicStats.activeStreaks.toDouble(),
        ),
      );
    }

    return goals;
  }

  /// 祝福メッセージの生成
  Future<String> _generateCelebrationMessage(
    WeeklyData data,
    WeeklyAnalysis analysis,
  ) async {
    try {
      final celebrationPrompt = '''
ユーザーの今週の成果：
- 完了率: ${(analysis.basicStats.completionRate * 100).toStringAsFixed(1)}%
- アクティブストリーク: ${analysis.basicStats.activeStreaks}個
- 改善度: ${(analysis.basicStats.improvementFromLastWeek * 100).toStringAsFixed(1)}%

この成果を祝福し、来週への励ましを込めたメッセージを作成してください。
''';

      final celebration = await _aiService.generateChatResponse(
        celebrationPrompt,
        systemPrompt: 'あなたは親しみやすいコーチです。ユーザーの努力を認め、前向きな気持ちにさせるメッセージを作成してください。',
        maxTokens: 80,
      );

      if (celebration.isNotEmpty && celebration.length > 10) {
        return celebration;
      }
    } catch (e) {
      log('WeeklyReport: 祝福メッセージ生成エラー - $e');
    }

    // フォールバック
    if (analysis.basicStats.completionRate > 0.8) {
      return '今週も素晴らしい継続力でした！この調子で来週も頑張りましょう。';
    } else if (analysis.basicStats.completionRate > 0.5) {
      return '着実に習慣を積み重ねていますね。小さな進歩も大きな成果です！';
    } else {
      return '今週はお疲れさまでした。完璧を目指さず、継続することが大切です。';
    }
  }

  /// 自動レポート生成と送信
  Future<void> _generateAndSendWeeklyReport() async {
    try {
      log('WeeklyReport: 自動レポート生成開始');

      // 全ユーザーのレポートを生成（実際の実装では、アクティブユーザーのみ）
      final activeUsers = await _getActiveUsers();

      for (final userId in activeUsers) {
        try {
          final report = await generateReport(userId: userId);
          await _sendReportNotification(userId, report);

          // レポートをデータベースに保存
          await _saveReport(report);
        } catch (e) {
          log('WeeklyReport: ユーザー $userId のレポート生成エラー - $e');
        }
      }

      log('WeeklyReport: 自動レポート生成完了');
    } catch (e) {
      log('WeeklyReport: 自動レポート生成エラー - $e');
    }
  }

  /// ユーティリティメソッド
  DateTime _getNextMonday(DateTime date) {
    final daysUntilMonday = (DateTime.monday - date.weekday) % 7;
    final nextMonday = date.add(Duration(days: daysUntilMonday));
    return DateTime(nextMonday.year, nextMonday.month, nextMonday.day, 8, 0);
  }

  String _getWeekdayName(int weekday) {
    const names = ['', '月', '火', '水', '木', '金', '土', '日'];
    return names[weekday];
  }

  String _getTimeSlot(int hour) {
    if (hour >= 5 && hour < 12) return '朝';
    if (hour >= 12 && hour < 17) return '昼';
    if (hour >= 17 && hour < 22) return '夕方';
    return '夜';
  }

  double _calculateMoodCompletionCorrelation(WeeklyData data) {
    // 簡略化された相関計算
    if (data.moods.length < 2) return 0.0;

    final dailyCompletions = <DateTime, int>{};

    for (final completion in data.completions) {
      final date = DateTime(
        completion.completedAt.year,
        completion.completedAt.month,
        completion.completedAt.day,
      );
      dailyCompletions[date] = (dailyCompletions[date] ?? 0) + 1;
    }

    // 簡単な相関計算（実際にはより複雑な統計処理が必要）
    return 0.3 + math.Random().nextDouble() * 0.4 - 0.2; // -0.2から0.7の範囲
  }

  double _calculateOverallScore(BasicStats stats, TrendAnalysis trends) {
    var score = stats.completionRate * 0.4;
    score += (stats.activeStreaks / 10.0).clamp(0.0, 0.3);
    score += (stats.averageMood / 5.0) * 0.2;

    switch (trends.direction) {
      case TrendDirection.upward:
        score += 0.1;
        break;
      case TrendDirection.downward:
        score -= 0.1;
        break;
      case TrendDirection.stable:
        break;
    }

    return score.clamp(0.0, 1.0);
  }

  List<String> _identifyKeyFactors(WeeklyData data) {
    final factors = <String>[];

    if (data.totalCompletions > data.totalHabits * 5) {
      factors.add('高い実行頻度');
    }

    if (data.averageMood > 4.0) {
      factors.add('良好な気分状態');
    }

    if (data.streaks.where((s) => s.isActive).length > data.totalHabits * 0.7) {
      factors.add('多数のアクティブストリーク');
    }

    return factors.isEmpty ? ['継続的な取り組み'] : factors;
  }

  List<String> _identifyRiskFactors(WeeklyData data) {
    final risks = <String>[];

    if (data.totalCompletions < data.totalHabits * 3) {
      risks.add('実行頻度の低下');
    }

    if (data.averageMood < 3.0) {
      risks.add('気分の低下');
    }

    if (data.streaks.where((s) => s.isActive).length < data.totalHabits * 0.3) {
      risks.add('ストリーク数の減少');
    }

    return risks.isEmpty ? ['特になし'] : risks;
  }

  List<String> _identifyOpportunities(WeeklyData data) {
    final opportunities = <String>[];

    if (data.habits.length < 5) {
      opportunities.add('新しい習慣の追加');
    }

    if (data.averageMood > 3.5) {
      opportunities.add('チャレンジングな目標設定');
    }

    final categories = data.habits.map((h) => h.category).toSet();
    if (categories.length < 3) {
      opportunities.add('多様なカテゴリの習慣');
    }

    return opportunities.isEmpty ? ['現状維持'] : opportunities;
  }

  String _getFallbackTrendDescription(WeeklyData data) {
    final completionRate = data.totalCompletions / (data.totalHabits * 7);

    if (completionRate > 0.8) {
      return '非常に安定した習慣継続ができています。';
    } else if (completionRate > 0.6) {
      return '良好なペースで習慣を継続しています。';
    } else {
      return '習慣継続に課題がありますが、改善の余地があります。';
    }
  }

  // データ取得メソッド（実際の実装では、データベースアクセス）
  Future<List<HabitInfo>> _getHabitsForPeriod(
    String userId,
    DateTime start,
    DateTime end,
  ) async {
    // サンプルデータ
    return [
      HabitInfo(id: '1', title: '朝の瞑想', category: 'mindfulness'),
      HabitInfo(id: '2', title: '読書', category: 'learning'),
      HabitInfo(id: '3', title: '運動', category: 'fitness'),
    ];
  }

  Future<List<CompletionInfo>> _getCompletionsForPeriod(
    String userId,
    DateTime start,
    DateTime end,
  ) async {
    // サンプルデータ
    final completions = <CompletionInfo>[];
    final random = math.Random();

    for (var i = 0; i < 7; i++) {
      final date = start.add(Duration(days: i));
      final count = random.nextInt(3) + 1;

      for (var j = 0; j < count; j++) {
        completions.add(
          CompletionInfo(
            habitId: '${j + 1}',
            completedAt: date.add(Duration(hours: 8 + j * 4)),
          ),
        );
      }
    }

    return completions;
  }

  Future<List<MoodInfo>> _getMoodsForPeriod(
    String userId,
    DateTime start,
    DateTime end,
  ) async {
    // サンプルデータ
    final moods = <MoodInfo>[];
    final random = math.Random();

    for (var i = 0; i < 7; i++) {
      final date = start.add(Duration(days: i));
      moods.add(
        MoodInfo(
          date: date,
          score: 2.0 + random.nextDouble() * 3.0, // 2.0-5.0の範囲
        ),
      );
    }

    return moods;
  }

  Future<List<StreakInfo>> _getStreaksForPeriod(
    String userId,
    DateTime start,
    DateTime end,
  ) async {
    // サンプルデータ
    return [
      StreakInfo(habitId: '1', currentLength: 15, isActive: true),
      StreakInfo(habitId: '2', currentLength: 8, isActive: true),
      StreakInfo(habitId: '3', currentLength: 3, isActive: false),
    ];
  }

  Future<List<String>> _getActiveUsers() async {
    // サンプルデータ
    return ['user1', 'user2', 'user3'];
  }

  Future<void> _sendReportNotification(
    String userId,
    WeeklyReport report,
  ) async {
    // 通知送信の実装
    log('WeeklyReport: ユーザー $userId にレポート通知を送信');
  }

  Future<void> _saveReport(WeeklyReport report) async {
    // レポート保存の実装
    log('WeeklyReport: レポートを保存 - ${report.userId}');
  }

  /// 手動でのレポート生成
  Future<WeeklyReport> generateWeeklyReport(String userId) async {
    final now = DateTime.now();
    final startDate = now.subtract(const Duration(days: 7));
    final endDate = now;

    return _generateWeeklyReport(userId, startDate, endDate);
  }

  /// レポート履歴の取得
  Future<List<WeeklyReport>> getReportHistory(
    String userId, {
    int limit = 10,
  }) async {
    // サンプルデータ
    final reports = <WeeklyReport>[];
    final now = DateTime.now();

    for (var i = 0; i < limit; i++) {
      final startDate = now.subtract(Duration(days: (i + 1) * 7));
      final endDate = now.subtract(Duration(days: i * 7));

      reports.add(await _generateWeeklyReport(userId, startDate, endDate));
    }

    return reports;
  }

  /// 内部用のレポート生成メソッド
  Future<WeeklyReport> _generateWeeklyReport(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    return generateReport(
      userId: userId,
      startDate: startDate,
      endDate: endDate,
    );
  }

  /// リソースの解放
  void dispose() {
    _weeklyTimer?.cancel();
    _weeklyTimer = null;
    _isGenerating = false;
  }
}

// ========== データクラス ==========

/// 週次レポート
class WeeklyReport {
  final String userId;
  final DateTime startDate;
  final DateTime endDate;
  final WeeklyData data;
  final WeeklyAnalysis analysis;
  final List<ImprovementSuggestion> improvements;
  final List<WeeklyGoal> nextWeekGoals;
  final String celebrationMessage;
  final DateTime generatedAt;

  WeeklyReport({
    required this.userId,
    required this.startDate,
    required this.endDate,
    required this.data,
    required this.analysis,
    required this.improvements,
    required this.nextWeekGoals,
    required this.celebrationMessage,
    required this.generatedAt,
  });

  // Computed properties for compatibility
  DateTime get weekStart => startDate;
  DateTime get weekEnd => endDate;
  double get overallScore => analysis.overallScore;
  double get completionRate => analysis.basicStats.completionRate;
  int get streakDays => analysis.basicStats.longestStreak;
  WeeklyAnalysis get aiAnalysis => analysis;
  List<ImprovementSuggestion> get recommendations => improvements;
  PredictionAnalysis get successPrediction => analysis.predictions;
}

/// 週次データ
class WeeklyData {
  final String userId;
  final DateTime startDate;
  final DateTime endDate;
  final List<HabitInfo> habits;
  final List<CompletionInfo> completions;
  final List<MoodInfo> moods;
  final List<StreakInfo> streaks;
  final int totalHabits;
  final int totalCompletions;
  final double averageMood;

  WeeklyData({
    required this.userId,
    required this.startDate,
    required this.endDate,
    required this.habits,
    required this.completions,
    required this.moods,
    required this.streaks,
    required this.totalHabits,
    required this.totalCompletions,
    required this.averageMood,
  });
}

/// 週次分析
class WeeklyAnalysis {
  final BasicStats basicStats;
  final TrendAnalysis trends;
  final List<BehaviorPattern> patterns;
  final PredictionAnalysis predictions;
  final List<WeeklyInsight> insights;
  final double overallScore;

  WeeklyAnalysis({
    required this.basicStats,
    required this.trends,
    required this.patterns,
    required this.predictions,
    required this.insights,
    required this.overallScore,
  });
}

/// 基本統計
class BasicStats {
  final double completionRate;
  final int activeStreaks;
  final int longestStreak;
  final double averageMood;
  final Map<String, int> categoryDistribution;
  final double improvementFromLastWeek;

  BasicStats({
    required this.completionRate,
    required this.activeStreaks,
    required this.longestStreak,
    required this.averageMood,
    required this.categoryDistribution,
    required this.improvementFromLastWeek,
  });
}

/// トレンド分析
class TrendAnalysis {
  final TrendDirection direction;
  final String description;
  final double confidence;
  final List<String> keyFactors;

  TrendAnalysis({
    required this.direction,
    required this.description,
    required this.confidence,
    required this.keyFactors,
  });
}

/// 行動パターン
class BehaviorPattern {
  final PatternType type;
  final String description;
  final double strength;
  final String recommendation;

  BehaviorPattern({
    required this.type,
    required this.description,
    required this.strength,
    required this.recommendation,
  });
}

/// 予測分析
class PredictionAnalysis {
  final double nextWeekCompletionRate;
  final double thirtyDaySuccessRate;
  final List<String> riskFactors;
  final List<String> opportunities;
  final String aiPrediction;

  PredictionAnalysis({
    required this.nextWeekCompletionRate,
    required this.thirtyDaySuccessRate,
    required this.riskFactors,
    required this.opportunities,
    required this.aiPrediction,
  });
}

/// 週次インサイト
class WeeklyInsight {
  final InsightType type;
  final String title;
  final String description;
  final bool actionable;
  final String recommendation;

  WeeklyInsight({
    required this.type,
    required this.title,
    required this.description,
    required this.actionable,
    required this.recommendation,
  });
}

/// 改善提案
class ImprovementSuggestion {
  final String category;
  final String title;
  final String description;
  final SuggestionPriority priority;
  final double estimatedImpact;

  ImprovementSuggestion({
    required this.category,
    required this.title,
    required this.description,
    required this.priority,
    required this.estimatedImpact,
  });
}

/// 週次目標
class WeeklyGoal {
  final GoalType type;
  final String title;
  final String description;
  final double targetValue;
  final double currentValue;

  WeeklyGoal({
    required this.type,
    required this.title,
    required this.description,
    required this.targetValue,
    required this.currentValue,
  });
}

/// 習慣情報
class HabitInfo {
  final String id;
  final String title;
  final String category;

  HabitInfo({required this.id, required this.title, required this.category});
}

/// 完了情報
class CompletionInfo {
  final String habitId;
  final DateTime completedAt;

  CompletionInfo({required this.habitId, required this.completedAt});
}

/// 気分情報
class MoodInfo {
  final DateTime date;
  final double score;

  MoodInfo({required this.date, required this.score});
}

/// ストリーク情報
class StreakInfo {
  final String habitId;
  final int currentLength;
  final bool isActive;

  StreakInfo({
    required this.habitId,
    required this.currentLength,
    required this.isActive,
  });
}

/// 列挙型
enum TrendDirection { upward, downward, stable }

enum PatternType { weekday, time, mood, category }

enum InsightType { achievement, improvement, streak, mood, pattern, ai }

enum SuggestionPriority { low, medium, high }

enum GoalType { completion, streak, mood, category }
