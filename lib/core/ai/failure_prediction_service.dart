import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:minq/core/ai/tflite_unified_ai_service.dart';
import 'package:minq/data/repositories/quest_log_repository.dart';
import 'package:minq/data/services/analytics_service.dart';
import 'package:minq/domain/ai/failure_prediction.dart';
import 'package:minq/domain/ai/habit_analysis.dart';
import 'package:minq/domain/log/quest_log.dart';

/// 失敗予測AIサービス
/// 習慣の失敗を事前に予測し、介入を提案
class FailurePredictionService {
  final FirebaseFirestore _firestore;
  final QuestLogRepository _questLogRepository;
  final TFLiteUnifiedAIService _aiService;
  final AnalyticsService _analytics;

  FailurePredictionService({
    FirebaseFirestore? firestore,
    required QuestLogRepository questLogRepository,
    required TFLiteUnifiedAIService aiService,
    required AnalyticsService analytics,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _questLogRepository = questLogRepository,
       _aiService = aiService,
       _analytics = analytics;

  /// 失敗リスクを予測
  Future<FailurePredictionResult> predictFailureRisk({
    required String userId,
    required String habitId,
    DateTime? targetDate,
  }) async {
    try {
      targetDate ??= DateTime.now();

      // 習慣分析データを取得
      final analysis = await _getHabitAnalysis(userId, habitId);

      // 予測スコアを計算
      final predictionScore = await _calculatePredictionScore(
        analysis,
        targetDate,
      );

      // リスクレベルを判定
      final riskLevel = _determineRiskLevel(predictionScore);

      // 改善提案を生成
      final suggestions = await _generateSuggestions(
        analysis,
        riskLevel,
        targetDate,
      );

      // 予測結果を保存
      final prediction = FailurePredictionModel(
        id: _generatePredictionId(),
        userId: userId,
        habitId: habitId,
        predictionScore: predictionScore,
        createdAt: DateTime.now(),
      );

      await _savePrediction(prediction);

      // 分析結果を記録
      await _analytics.logEvent(
        'failure_prediction_generated',
        parameters: {
          'user_id': userId,
          'habit_id': habitId,
          'prediction_score': predictionScore,
          'risk_level': riskLevel.name,
        },
      );

      return FailurePredictionResult(
        prediction: prediction,
        riskLevel: riskLevel,
        suggestions: suggestions,
        analysis: analysis,
      );
    } catch (e, stack) {
      await _analytics.logEvent('error', parameters: {'failure_prediction_failed': e.toString(), 'stack': stack.toString()});
      rethrow;
    }
  }

  /// 習慣分析データを取得
  Future<HabitAnalysis> _getHabitAnalysis(String userId, String habitId) async {
    // 既存の分析データを取得
    final doc =
        await _firestore
            .collection('habit_analyses')
            .doc('${userId}_$habitId')
            .get();

    if (doc.exists) {
      return HabitAnalysis.fromJson(doc.data()!);
    }

    // 分析データが存在しない場合は新規作成
    return await _createHabitAnalysis(userId, habitId);
  }

  /// 新規習慣分析を作成
  Future<HabitAnalysis> _createHabitAnalysis(
    String userId,
    String habitId,
  ) async {
    // クエストログを取得
    final logs = await _questLogRepository.getQuestLogs(userId);
    final habitLogs =
        logs.where((log) => log.questId.toString() == habitId).toList();

    if (habitLogs.isEmpty) {
      // データが不足している場合のデフォルト分析
      return HabitAnalysis(
        id: '${userId}_$habitId',
        userId: userId,
        habitId: habitId,
        successRate: 0.5, // デフォルト50%
        successByDay: _getDefaultSuccessByDay(),
        successByTime: _getDefaultSuccessByTime(),
        lastUpdated: DateTime.now(),
      );
    }

    // 実際のデータから分析を計算
    final analysis = _calculateAnalysisFromLogs(habitLogs, userId, habitId);

    // Firestoreに保存
    await _firestore
        .collection('habit_analyses')
        .doc(analysis.id)
        .set(analysis.toJson());

    return analysis;
  }

  /// ログデータから分析を計算
  HabitAnalysis _calculateAnalysisFromLogs(
    List<QuestLog> logs,
    String userId,
    String habitId,
  ) {
    final totalLogs = logs.length;
    final successfulLogs = logs.where((log) => log.isCompleted).length;
    final successRate = totalLogs > 0 ? successfulLogs / totalLogs : 0.5;

    // 曜日別成功率を計算
    final successByDay = <String, double>{};
    final dayNames = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];

    for (final dayName in dayNames) {
      final dayIndex = dayNames.indexOf(dayName) + 1;
      final dayLogs =
          logs.where((log) => log.completedAt.weekday == dayIndex).toList();
      final daySuccessful = dayLogs.where((log) => log.isCompleted).length;
      successByDay[dayName] =
          dayLogs.isNotEmpty ? daySuccessful / dayLogs.length : 0.5;
    }

    // 時間帯別成功率を計算
    final successByTime = <String, double>{};
    final timeSlots = ['Morning', 'Afternoon', 'Evening', 'Night'];

    for (final timeSlot in timeSlots) {
      final timeLogs =
          logs
              .where((log) => _getTimeSlot(log.completedAt) == timeSlot)
              .toList();
      final timeSuccessful = timeLogs.where((log) => log.isCompleted).length;
      successByTime[timeSlot] =
          timeLogs.isNotEmpty ? timeSuccessful / timeLogs.length : 0.5;
    }

    return HabitAnalysis(
      id: '${userId}_$habitId',
      userId: userId,
      habitId: habitId,
      successRate: successRate,
      successByDay: successByDay,
      successByTime: successByTime,
      lastUpdated: DateTime.now(),
    );
  }

  /// 予測スコアを計算
  Future<double> _calculatePredictionScore(
    HabitAnalysis analysis,
    DateTime targetDate,
  ) async {
    // 基本成功率
    double baseScore = 1.0 - analysis.successRate;

    // 曜日による調整
    final dayName = _getDayName(targetDate.weekday);
    final daySuccessRate = analysis.successByDay[dayName] ?? 0.5;
    final dayAdjustment = 1.0 - daySuccessRate;

    // 時間帯による調整
    final timeSlot = _getTimeSlot(targetDate);
    final timeSuccessRate = analysis.successByTime[timeSlot] ?? 0.5;
    final timeAdjustment = 1.0 - timeSuccessRate;

    // 最近のトレンドを考慮
    final trendAdjustment = await _calculateTrendAdjustment(analysis);

    // 季節性を考慮
    final seasonalAdjustment = _calculateSeasonalAdjustment(targetDate);

    // 総合スコアを計算（重み付き平均）
    final totalScore =
        (baseScore * 0.4) +
        (dayAdjustment * 0.25) +
        (timeAdjustment * 0.2) +
        (trendAdjustment * 0.1) +
        (seasonalAdjustment * 0.05);

    return totalScore.clamp(0.0, 1.0);
  }

  /// トレンド調整を計算
  Future<double> _calculateTrendAdjustment(HabitAnalysis analysis) async {
    // 最近7日間のトレンドを分析

    try {
      // 最近のログを取得（簡略化）
      final recentSuccessRate = analysis.successRate; // 実際は最近のデータを計算
      final overallSuccessRate = analysis.successRate;

      // トレンドが下降している場合はリスクが高い
      if (recentSuccessRate < overallSuccessRate) {
        return 0.3; // リスク増加
      } else if (recentSuccessRate > overallSuccessRate) {
        return -0.2; // リスク減少
      }

      return 0.0; // 変化なし
    } catch (e) {
      return 0.0; // エラー時はニュートラル
    }
  }

  /// 季節性調整を計算
  double _calculateSeasonalAdjustment(DateTime date) {
    final month = date.month;

    // 1月（新年の決意）、9月（新学期）はモチベーションが高い
    if (month == 1 || month == 9) {
      return -0.1; // リスク減少
    }

    // 12月（年末）、8月（夏休み）はモチベーションが低い
    if (month == 12 || month == 8) {
      return 0.1; // リスク増加
    }

    return 0.0; // 通常
  }

  /// リスクレベルを判定
  FailureRiskLevel _determineRiskLevel(double predictionScore) {
    if (predictionScore >= 0.7) {
      return FailureRiskLevel.high;
    } else if (predictionScore >= 0.4) {
      return FailureRiskLevel.medium;
    } else {
      return FailureRiskLevel.low;
    }
  }

  /// 改善提案を生成
  Future<List<FailureSuggestion>> _generateSuggestions(
    HabitAnalysis analysis,
    FailureRiskLevel riskLevel,
    DateTime targetDate,
  ) async {
    final suggestions = <FailureSuggestion>[];

    try {
      // AI提案を生成
      final aiSuggestions = await _generateAISuggestions(analysis, riskLevel);
      suggestions.addAll(aiSuggestions);

      // ルールベース提案を追加
      final ruleSuggestions = _generateRuleBasedSuggestions(
        analysis,
        targetDate,
      );
      suggestions.addAll(ruleSuggestions);

      // 重複を除去し、優先度順にソート
      return _deduplicateAndSort(suggestions);
    } catch (e) {
      // AI生成に失敗した場合はルールベースのみ
      return _generateRuleBasedSuggestions(analysis, targetDate);
    }
  }

  /// AI提案を生成
  Future<List<FailureSuggestion>> _generateAISuggestions(
    HabitAnalysis analysis,
    FailureRiskLevel riskLevel,
  ) async {
    try {
      final logs = await _questLogRepository.getQuestLogs(analysis.userId);
      final habitLogs = logs
          .where((log) => log.questId.toString() == analysis.habitId)
          .toList();
      final history = habitLogs
          .map((log) => CompletionRecord(
              completedAt: log.completedAt, habitId: log.questId.toString()))
          .toList();

      final prediction = await _aiService.predictFailure(
        habitId: analysis.habitId,
        history: history,
        targetDate: DateTime.now(),
      );

      return prediction.suggestions
          .map((s) => FailureSuggestion(
              id: 'ai_suggestion',
              type: SuggestionType.strategy,
              title: 'AIからの提案',
              description: s,
              priority: SuggestionPriority.medium,
              actionable: true))
          .toList();
    } catch (e) {
      // AI生成に失敗した場合は空のリストを返す
      return [];
    }
  }

  /// ルールベース提案を生成
  List<FailureSuggestion> _generateRuleBasedSuggestions(
    HabitAnalysis analysis,
    DateTime targetDate,
  ) {
    final suggestions = <FailureSuggestion>[];

    // 曜日別の提案
    final dayName = _getDayName(targetDate.weekday);
    final daySuccessRate = analysis.successByDay[dayName] ?? 0.5;

    if (daySuccessRate < 0.5) {
      suggestions.add(
        FailureSuggestion(
          id: 'day_specific',
          type: SuggestionType.timing,
          title: '${_getDayDisplayName(dayName)}は要注意',
          description: '${_getDayDisplayName(dayName)}の成功率が低めです。特別な準備をしましょう。',
          priority: SuggestionPriority.high,
          actionable: true,
        ),
      );
    }

    // 時間帯別の提案
    final timeSlot = _getTimeSlot(targetDate);
    final timeSuccessRate = analysis.successByTime[timeSlot] ?? 0.5;

    if (timeSuccessRate < 0.5) {
      suggestions.add(
        FailureSuggestion(
          id: 'time_specific',
          type: SuggestionType.timing,
          title: '${_getTimeDisplayName(timeSlot)}の対策',
          description:
              '${_getTimeDisplayName(timeSlot)}の成功率が低めです。時間を変更することを検討してみてください。',
          priority: SuggestionPriority.medium,
          actionable: true,
        ),
      );
    }

    // 全体的な成功率による提案
    if (analysis.successRate < 0.3) {
      suggestions.add(
        const FailureSuggestion(
          id: 'overall_low',
          type: SuggestionType.strategy,
          title: '習慣を簡単にしましょう',
          description: '成功率が低いようです。習慣をより小さく、簡単にすることから始めてみませんか？',
          priority: SuggestionPriority.high,
          actionable: true,
        ),
      );
    }

    return suggestions;
  }

  /// 提案の重複除去とソート
  List<FailureSuggestion> _deduplicateAndSort(
    List<FailureSuggestion> suggestions,
  ) {
    // IDで重複除去
    final uniqueSuggestions = <String, FailureSuggestion>{};
    for (final suggestion in suggestions) {
      uniqueSuggestions[suggestion.id] = suggestion;
    }

    // 優先度順にソート
    final sortedSuggestions = uniqueSuggestions.values.toList();
    sortedSuggestions.sort(
      (a, b) => b.priority.index.compareTo(a.priority.index),
    );

    return sortedSuggestions.take(5).toList(); // 最大5個まで
  }

  /// 予測を保存
  Future<void> _savePrediction(FailurePredictionModel prediction) async {
    await _firestore
        .collection('failure_predictions')
        .doc(prediction.id)
        .set(prediction.toJson());
  }

  /// ユーザーの最新予測を取得
  Future<List<FailurePredictionResult>> getRecentPredictions(
    String userId,
  ) async {
    try {
      final snapshot =
          await _firestore
              .collection('failure_predictions')
              .where('userId', isEqualTo: userId)
              .orderBy('createdAt', descending: true)
              .limit(10)
              .get();

      final results = <FailurePredictionResult>[];

      for (final doc in snapshot.docs) {
        final prediction = FailurePredictionModel.fromJson(doc.data());
        final analysis = await _getHabitAnalysis(userId, prediction.habitId);
        final riskLevel = _determineRiskLevel(prediction.predictionScore);
        final suggestions = await _generateSuggestions(
          analysis,
          riskLevel,
          DateTime.now(),
        );

        results.add(
          FailurePredictionResult(
            prediction: prediction,
            riskLevel: riskLevel,
            suggestions: suggestions,
            analysis: analysis,
          ),
        );
      }

      return results;
    } catch (e, stack) {
      await _analytics.logEvent('error', parameters: {
        'get_recent_predictions_failed': e.toString(),
        'stack': stack.toString()
      });
      return [];
    }
  }

  /// 高リスク習慣を取得
  Future<List<String>> getHighRiskHabits(String userId) async {
    try {
      final snapshot =
          await _firestore
              .collection('failure_predictions')
              .where('userId', isEqualTo: userId)
              .where('predictionScore', isGreaterThan: 0.7)
              .orderBy('predictionScore', descending: true)
              .limit(5)
              .get();

      return snapshot.docs
          .map((doc) => doc.data()['habitId'] as String)
          .toList();
    } catch (e) {
      return [];
    }
  }

  // ヘルパーメソッド
  String _generatePredictionId() {
    return '${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(1000)}';
  }

  String _getDayName(int weekday) {
    const days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    return days[weekday - 1];
  }

  String _getDayDisplayName(String dayName) {
    const displayNames = {
      'Monday': '月曜日',
      'Tuesday': '火曜日',
      'Wednesday': '水曜日',
      'Thursday': '木曜日',
      'Friday': '金曜日',
      'Saturday': '土曜日',
      'Sunday': '日曜日',
    };
    return displayNames[dayName] ?? dayName;
  }

  String _getTimeSlot(DateTime dateTime) {
    final hour = dateTime.hour;
    if (hour >= 5 && hour < 12) return 'Morning';
    if (hour >= 12 && hour < 17) return 'Afternoon';
    if (hour >= 17 && hour < 22) return 'Evening';
    return 'Night';
  }

  String _getTimeDisplayName(String timeSlot) {
    const displayNames = {
      'Morning': '朝',
      'Afternoon': '午後',
      'Evening': '夕方',
      'Night': '夜',
    };
    return displayNames[timeSlot] ?? timeSlot;
  }

  Map<String, double> _getDefaultSuccessByDay() {
    return {
      'Monday': 0.5,
      'Tuesday': 0.5,
      'Wednesday': 0.5,
      'Thursday': 0.5,
      'Friday': 0.5,
      'Saturday': 0.5,
      'Sunday': 0.5,
    };
  }

  Map<String, double> _getDefaultSuccessByTime() {
    return {'Morning': 0.6, 'Afternoon': 0.5, 'Evening': 0.4, 'Night': 0.3};
  }
}

/// 失敗予測結果
class FailurePredictionResult {
  final FailurePredictionModel prediction;
  final FailureRiskLevel riskLevel;
  final List<FailureSuggestion> suggestions;
  final HabitAnalysis analysis;

  const FailurePredictionResult({
    required this.prediction,
    required this.riskLevel,
    required this.suggestions,
    required this.analysis,
  });
}

/// 失敗リスクレベル
enum FailureRiskLevel { low, medium, high }

/// 失敗予防提案
class FailureSuggestion {
  final String id;
  final SuggestionType type;
  final String title;
  final String description;
  final SuggestionPriority priority;
  final bool actionable;

  const FailureSuggestion({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.priority,
    required this.actionable,
  });
}

/// 提案タイプ
enum SuggestionType { timing, strategy, environment, motivation }

/// 提案優先度
enum SuggestionPriority { low, medium, high }
