import 'dart:async';
import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:minq/core/ai/habit_story_generator.dart';
import 'package:minq/core/ai/personality_diagnosis_service.dart';
import 'package:minq/core/ai/realtime_coach_service.dart';
import 'package:minq/core/ai/social_proof_service.dart';
import 'package:minq/core/ai/tflite_unified_ai_service.dart';
import 'package:minq/core/ai/weekly_report_service.dart';

/// AI統合マネージャー
/// すべてのAI機能を統合し、一元的に管理
class AIIntegrationManager {
  static AIIntegrationManager? _instance;
  static AIIntegrationManager get instance =>
      _instance ??= AIIntegrationManager._();

  AIIntegrationManager._();

  // AI サービス
  final TFLiteUnifiedAIService _unifiedAI = TFLiteUnifiedAIService.instance;
  final RealtimeCoachService _realtimeCoach = RealtimeCoachService.instance;
  final PersonalityDiagnosisService _personalityDiagnosis =
      PersonalityDiagnosisService.instance;
  final WeeklyReportService _weeklyReport = WeeklyReportService.instance;
  final SocialProofService _socialProof = SocialProofService.instance;
  final HabitStoryGenerator _storyGenerator = HabitStoryGenerator.instance;

  bool _isInitialized = false;
  AISettings _settings = const AISettings();

  final StreamController<AIEvent> _eventController =
      StreamController<AIEvent>.broadcast();
  Stream<AIEvent> get eventStream => _eventController.stream;

  /// AI統合システムの初期化
  Future<void> initialize({
    required String userId,
    AISettings? settings,
  }) async {
    if (_isInitialized) return;

    try {
      log('AIIntegration: 統合AI初期化開始');

      _settings = settings ?? const AISettings();

      // 基盤AIサービスの初期化
      await _unifiedAI.initialize();

      // 各AIサービスの初期化
      if (_settings.enableRealtimeCoach) {
        // リアルタイムコーチは必要時に初期化
      }

      if (_settings.enableSocialProof) {
        await _socialProof.startSocialProof(userId: userId);
      }

      if (_settings.enableWeeklyReports) {
        _weeklyReport.startWeeklyReports();
      }

      _isInitialized = true;

      _eventController.add(
        AIEvent(
          type: AIEventType.initialized,
          message: 'AI統合システムが初期化されました',
          timestamp: DateTime.now(),
        ),
      );

      log('AIIntegration: 統合AI初期化完了');
    } catch (e, stackTrace) {
      log('AIIntegration: 初期化エラー - $e', stackTrace: stackTrace);
      _eventController.add(
        AIEvent(
          type: AIEventType.error,
          message: '初期化エラー: $e',
          timestamp: DateTime.now(),
        ),
      );
      rethrow;
    }
  }

  /// チャット応答の生成
  Future<String> generateChatResponse(
    String userMessage, {
    List<String> conversationHistory = const [],
    String? systemPrompt,
    int maxTokens = 150,
  }) async {
    try {
      _eventController.add(
        AIEvent(
          type: AIEventType.chatRequest,
          message: 'チャット応答生成中...',
          timestamp: DateTime.now(),
        ),
      );

      final response = await _unifiedAI.generateChatResponse(
        userMessage,
        conversationHistory: conversationHistory,
        systemPrompt: systemPrompt,
        maxTokens: maxTokens,
      );

      _eventController.add(
        AIEvent(
          type: AIEventType.chatResponse,
          message: 'チャット応答生成完了',
          data: {'response': response},
          timestamp: DateTime.now(),
        ),
      );

      return response;
    } catch (e) {
      log('AIIntegration: チャット応答エラー - $e');
      _eventController.add(
        AIEvent(
          type: AIEventType.error,
          message: 'チャット応答エラー: $e',
          timestamp: DateTime.now(),
        ),
      );
      return '申し訳ございません。現在AIサービスを利用できません。';
    }
  }

  /// 習慣推薦の生成
  Future<List<HabitRecommendation>> generateHabitRecommendations({
    required List<String> userHabits,
    required List<String> completedHabits,
    required Map<String, double> preferences,
    int limit = 5,
  }) async {
    try {
      _eventController.add(
        AIEvent(
          type: AIEventType.recommendationRequest,
          message: '習慣推薦生成中...',
          timestamp: DateTime.now(),
        ),
      );

      final recommendations = await _unifiedAI.recommendHabits(
        userHabits: userHabits,
        completedHabits: completedHabits,
        preferences: preferences,
        limit: limit,
      );

      _eventController.add(
        AIEvent(
          type: AIEventType.recommendationGenerated,
          message: '習慣推薦生成完了',
          data: {'count': recommendations.length},
          timestamp: DateTime.now(),
        ),
      );

      return recommendations;
    } catch (e) {
      log('AIIntegration: 習慣推薦エラー - $e');
      _eventController.add(
        AIEvent(
          type: AIEventType.error,
          message: '習慣推薦エラー: $e',
          timestamp: DateTime.now(),
        ),
      );
      return [];
    }
  }

  /// 失敗予測の実行
  Future<FailurePrediction> predictHabitFailure({
    required String habitId,
    required List<CompletionRecord> history,
    required DateTime targetDate,
  }) async {
    try {
      _eventController.add(
        AIEvent(
          type: AIEventType.predictionRequest,
          message: '失敗予測分析中...',
          timestamp: DateTime.now(),
        ),
      );

      final prediction = await _unifiedAI.predictFailure(
        habitId: habitId,
        history: history,
        targetDate: targetDate,
      );

      _eventController.add(
        AIEvent(
          type: AIEventType.predictionGenerated,
          message: '失敗予測完了',
          data: {'riskScore': prediction.riskScore},
          timestamp: DateTime.now(),
        ),
      );

      // 高リスクの場合は緊急介入をトリガー
      if (prediction.riskScore > 0.7 && _settings.enableEmergencyIntervention) {
        await _triggerEmergencyIntervention(habitId, prediction);
      }

      return prediction;
    } catch (e) {
      log('AIIntegration: 失敗予測エラー - $e');
      _eventController.add(
        AIEvent(
          type: AIEventType.error,
          message: '失敗予測エラー: $e',
          timestamp: DateTime.now(),
        ),
      );
      return FailurePrediction(
        riskScore: 0.5,
        confidence: 0.0,
        factors: ['データ不足'],
        suggestions: ['継続的な記録をお勧めします'],
      );
    }
  }

  /// リアルタイムコーチングの開始
  Future<void> startRealtimeCoaching({
    required String questId,
    required String questTitle,
    required Duration estimatedDuration,
    CoachingSettings? settings,
  }) async {
    if (!_settings.enableRealtimeCoach) return;

    try {
      await _realtimeCoach.startCoaching(
        questId: questId,
        questTitle: questTitle,
        estimatedDuration: estimatedDuration,
        settings: settings,
      );

      _eventController.add(
        AIEvent(
          type: AIEventType.coachingStarted,
          message: 'リアルタイムコーチング開始',
          data: {'questId': questId, 'questTitle': questTitle},
          timestamp: DateTime.now(),
        ),
      );
    } catch (e) {
      log('AIIntegration: コーチング開始エラー - $e');
      _eventController.add(
        AIEvent(
          type: AIEventType.error,
          message: 'コーチング開始エラー: $e',
          timestamp: DateTime.now(),
        ),
      );
    }
  }

  /// リアルタイムコーチングの停止
  Future<void> stopRealtimeCoaching() async {
    try {
      await _realtimeCoach.stopCoaching();

      _eventController.add(
        AIEvent(
          type: AIEventType.coachingStopped,
          message: 'リアルタイムコーチング停止',
          timestamp: DateTime.now(),
        ),
      );
    } catch (e) {
      log('AIIntegration: コーチング停止エラー - $e');
    }
  }

  /// パーソナリティ診断の実行
  Future<PersonalityDiagnosis> performPersonalityDiagnosis({
    required List<HabitData> habitHistory,
    required List<CompletionPattern> completionPatterns,
    required UserPreferences preferences,
    List<QuestionnaireAnswer>? questionnaire,
  }) async {
    try {
      _eventController.add(
        AIEvent(
          type: AIEventType.diagnosisRequest,
          message: 'パーソナリティ診断実行中...',
          timestamp: DateTime.now(),
        ),
      );

      final diagnosis = await _personalityDiagnosis.diagnosePpersonality(
        habitHistory: habitHistory,
        completionPatterns: completionPatterns,
        preferences: preferences,
        questionnaire: questionnaire,
      );

      _eventController.add(
        AIEvent(
          type: AIEventType.diagnosisCompleted,
          message: 'パーソナリティ診断完了',
          data: {
            'archetype': diagnosis.archetype.displayName,
            'confidence': diagnosis.confidence,
          },
          timestamp: DateTime.now(),
        ),
      );

      return diagnosis;
    } catch (e) {
      log('AIIntegration: パーソナリティ診断エラー - $e');
      _eventController.add(
        AIEvent(
          type: AIEventType.error,
          message: 'パーソナリティ診断エラー: $e',
          timestamp: DateTime.now(),
        ),
      );
      rethrow;
    }
  }

  /// 週次レポートの生成
  Future<WeeklyReport> generateWeeklyReport({
    required String userId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      _eventController.add(
        AIEvent(
          type: AIEventType.reportRequest,
          message: '週次レポート生成中...',
          timestamp: DateTime.now(),
        ),
      );

      final report = await _weeklyReport.generateReport(
        userId: userId,
        startDate: startDate,
        endDate: endDate,
      );

      _eventController.add(
        AIEvent(
          type: AIEventType.reportGenerated,
          message: '週次レポート生成完了',
          data: {'userId': userId},
          timestamp: DateTime.now(),
        ),
      );

      return report;
    } catch (e) {
      log('AIIntegration: 週次レポートエラー - $e');
      _eventController.add(
        AIEvent(
          type: AIEventType.error,
          message: '週次レポートエラー: $e',
          timestamp: DateTime.now(),
        ),
      );
      rethrow;
    }
  }

  /// ハビットストーリーの生成
  Future<HabitStory> generateHabitStory({
    required StoryType type,
    required HabitProgressData progressData,
    StoryTemplate? customTemplate,
    StorySettings? settings,
  }) async {
    try {
      _eventController.add(
        AIEvent(
          type: AIEventType.storyRequest,
          message: 'ハビットストーリー生成中...',
          timestamp: DateTime.now(),
        ),
      );

      final story = await _storyGenerator.generateStory(
        type: type,
        progressData: progressData,
        customTemplate: customTemplate,
        settings: settings,
      );

      _eventController.add(
        AIEvent(
          type: AIEventType.storyGenerated,
          message: 'ハビットストーリー生成完了',
          data: {'storyId': story.id, 'type': type.name},
          timestamp: DateTime.now(),
        ),
      );

      return story;
    } catch (e) {
      log('AIIntegration: ストーリー生成エラー - $e');
      _eventController.add(
        AIEvent(
          type: AIEventType.error,
          message: 'ストーリー生成エラー: $e',
          timestamp: DateTime.now(),
        ),
      );
      rethrow;
    }
  }

  /// 習慣開始の記録（ソーシャルプルーフ）
  Future<void> recordHabitStart({
    required String habitId,
    required String habitTitle,
    required String category,
    Duration? estimatedDuration,
  }) async {
    if (!_settings.enableSocialProof) return;

    try {
      await _socialProof.recordHabitStart(
        habitId: habitId,
        habitTitle: habitTitle,
        category: category,
        estimatedDuration: estimatedDuration,
      );

      _eventController.add(
        AIEvent(
          type: AIEventType.habitStarted,
          message: '習慣開始記録完了',
          data: {'habitId': habitId, 'habitTitle': habitTitle},
          timestamp: DateTime.now(),
        ),
      );
    } catch (e) {
      log('AIIntegration: 習慣開始記録エラー - $e');
    }
  }

  /// 習慣完了の記録（ソーシャルプルーフ）
  Future<void> recordHabitCompletion({
    required String habitId,
    required String habitTitle,
    required String category,
    Duration? actualDuration,
  }) async {
    if (!_settings.enableSocialProof) return;

    try {
      await _socialProof.recordHabitCompletion(
        habitId: habitId,
        habitTitle: habitTitle,
        category: category,
        actualDuration: actualDuration,
      );

      _eventController.add(
        AIEvent(
          type: AIEventType.habitCompleted,
          message: '習慣完了記録完了',
          data: {'habitId': habitId, 'habitTitle': habitTitle},
          timestamp: DateTime.now(),
        ),
      );

      // 完了時の自動ストーリー生成（設定で有効な場合）
      if (_settings.enableAutoStoryGeneration) {
        _generateCompletionStory(habitId, habitTitle, category);
      }
    } catch (e) {
      log('AIIntegration: 習慣完了記録エラー - $e');
    }
  }

  /// 感情分析の実行
  Future<SentimentResult> analyzeSentiment(String text) async {
    try {
      final result = await _unifiedAI.analyzeSentiment(text);

      _eventController.add(
        AIEvent(
          type: AIEventType.sentimentAnalyzed,
          message: '感情分析完了',
          data: {
            'sentiment': result.dominantSentiment.name,
            'positive': result.positive,
            'negative': result.negative,
          },
          timestamp: DateTime.now(),
        ),
      );

      return result;
    } catch (e) {
      log('AIIntegration: 感情分析エラー - $e');
      return SentimentResult(positive: 0.5, neutral: 0.5, negative: 0.0);
    }
  }

  /// 緊急介入のトリガー
  Future<void> _triggerEmergencyIntervention(
    String habitId,
    FailurePrediction prediction,
  ) async {
    try {
      // リアルタイムコーチに緊急介入を要請
      final reason =
          prediction.factors.isNotEmpty
              ? prediction.factors.first
              : '継続リスクが高まっています';

      await _realtimeCoach.triggerEmergencyIntervention(reason);

      _eventController.add(
        AIEvent(
          type: AIEventType.emergencyIntervention,
          message: '緊急介入実行',
          data: {'habitId': habitId, 'riskScore': prediction.riskScore},
          timestamp: DateTime.now(),
        ),
      );
    } catch (e) {
      log('AIIntegration: 緊急介入エラー - $e');
    }
  }

  /// 完了時の自動ストーリー生成
  void _generateCompletionStory(
    String habitId,
    String habitTitle,
    String category,
  ) {
    // 非同期でストーリー生成（エラーが発生してもメイン処理に影響しない）
    Future(() async {
      try {
        // 簡単な進捗データを作成（実際の実装では、データベースから取得）
        final progressData = HabitProgressData(
          habitTitle: habitTitle,
          category: category,
          currentStreak: 1, // 実際の値を取得
          totalCompletions: 1, // 実際の値を取得
          weeklyCompletionRate: 1.0,
          averageWeeklyMood: 4.0,
          todayMood: 4,
          activeHabits: 1,
          achievements: ['今日の達成'],
          startDate: DateTime.now().subtract(const Duration(days: 1)),
        );

        await generateHabitStory(
          type: StoryType.dailyAchievement,
          progressData: progressData,
        );
      } catch (e) {
        log('AIIntegration: 自動ストーリー生成エラー - $e');
      }
    });
  }

  /// 現在のソーシャル統計を取得
  Future<CurrentActivityStats?> getCurrentSocialStats() async {
    if (!_settings.enableSocialProof) return null;

    try {
      return await _socialProof.getCurrentStats();
    } catch (e) {
      log('AIIntegration: ソーシャル統計取得エラー - $e');
      return null;
    }
  }

  /// 励ましスタンプの送信
  Future<void> sendEncouragementStamp({
    required String targetUserId,
    required EncouragementType stampType,
  }) async {
    if (!_settings.enableSocialProof) return;

    try {
      await _socialProof.sendEncouragementStamp(
        targetUserId: targetUserId,
        stampType: stampType,
      );

      _eventController.add(
        AIEvent(
          type: AIEventType.encouragementSent,
          message: '励ましスタンプ送信完了',
          data: {'targetUserId': targetUserId, 'stampType': stampType.name},
          timestamp: DateTime.now(),
        ),
      );
    } catch (e) {
      log('AIIntegration: 励ましスタンプ送信エラー - $e');
    }
  }

  /// AI設定の更新
  void updateSettings(AISettings settings) {
    _settings = settings;

    // 各サービスの設定を更新
    if (settings.enableRealtimeCoach) {
      _realtimeCoach.updateSettings(settings.coachingSettings);
    }

    if (settings.enableSocialProof) {
      _socialProof.updateSettings(settings.socialSettings);
    }

    _eventController.add(
      AIEvent(
        type: AIEventType.settingsUpdated,
        message: 'AI設定が更新されました',
        timestamp: DateTime.now(),
      ),
    );
  }

  /// 診断情報の取得
  Future<Map<String, dynamic>> getDiagnosticInfo() async {
    final info = <String, dynamic>{
      'isInitialized': _isInitialized,
      'settings': {
        'enableRealtimeCoach': _settings.enableRealtimeCoach,
        'enableSocialProof': _settings.enableSocialProof,
        'enableWeeklyReports': _settings.enableWeeklyReports,
        'enableAutoStoryGeneration': _settings.enableAutoStoryGeneration,
      },
      'services': {},
    };

    try {
      info['services']['unifiedAI'] = await _unifiedAI.getDiagnosticInfo();
    } catch (e) {
      info['services']['unifiedAI'] = {'error': e.toString()};
    }

    return info;
  }

  /// システムのシャットダウン
  Future<void> shutdown() async {
    try {
      log('AIIntegration: システムシャットダウン開始');

      await _realtimeCoach.stopCoaching();
      await _socialProof.stopSocialProof();
      _weeklyReport.stopWeeklyReports();

      _realtimeCoach.dispose();
      _socialProof.dispose();
      _weeklyReport.dispose();
      _unifiedAI.dispose();

      _eventController.add(
        AIEvent(
          type: AIEventType.shutdown,
          message: 'AI統合システムがシャットダウンされました',
          timestamp: DateTime.now(),
        ),
      );

      _eventController.close();
      _isInitialized = false;

      log('AIIntegration: システムシャットダウン完了');
    } catch (e) {
      log('AIIntegration: シャットダウンエラー - $e');
    }
  }
}

// ========== プロバイダー ==========

final aiIntegrationManagerProvider = Provider<AIIntegrationManager>((ref) {
  return AIIntegrationManager.instance;
});

final aiEventStreamProvider = StreamProvider<AIEvent>((ref) {
  final manager = ref.watch(aiIntegrationManagerProvider);
  return manager.eventStream;
});

// ========== データクラス ==========

/// AI設定
class AISettings {
  final bool enableRealtimeCoach;
  final bool enableSocialProof;
  final bool enableWeeklyReports;
  final bool enableAutoStoryGeneration;
  final bool enableEmergencyIntervention;
  final CoachingSettings coachingSettings;
  final SocialSettings socialSettings;

  const AISettings({
    this.enableRealtimeCoach = true,
    this.enableSocialProof = true,
    this.enableWeeklyReports = true,
    this.enableAutoStoryGeneration = false,
    this.enableEmergencyIntervention = true,
    this.coachingSettings = const CoachingSettings(),
    this.socialSettings = const SocialSettings(),
  });

  AISettings copyWith({
    bool? enableRealtimeCoach,
    bool? enableSocialProof,
    bool? enableWeeklyReports,
    bool? enableAutoStoryGeneration,
    bool? enableEmergencyIntervention,
    CoachingSettings? coachingSettings,
    SocialSettings? socialSettings,
  }) {
    return AISettings(
      enableRealtimeCoach: enableRealtimeCoach ?? this.enableRealtimeCoach,
      enableSocialProof: enableSocialProof ?? this.enableSocialProof,
      enableWeeklyReports: enableWeeklyReports ?? this.enableWeeklyReports,
      enableAutoStoryGeneration:
          enableAutoStoryGeneration ?? this.enableAutoStoryGeneration,
      enableEmergencyIntervention:
          enableEmergencyIntervention ?? this.enableEmergencyIntervention,
      coachingSettings: coachingSettings ?? this.coachingSettings,
      socialSettings: socialSettings ?? this.socialSettings,
    );
  }
}

/// AIイベント
class AIEvent {
  final AIEventType type;
  final String message;
  final Map<String, dynamic>? data;
  final DateTime timestamp;

  AIEvent({
    required this.type,
    required this.message,
    this.data,
    required this.timestamp,
  });
}

/// AIイベントタイプ
enum AIEventType {
  initialized,
  chatRequest,
  chatResponse,
  recommendationRequest,
  recommendationGenerated,
  predictionRequest,
  predictionGenerated,
  coachingStarted,
  coachingStopped,
  diagnosisRequest,
  diagnosisCompleted,
  reportRequest,
  reportGenerated,
  storyRequest,
  storyGenerated,
  habitStarted,
  habitCompleted,
  sentimentAnalyzed,
  emergencyIntervention,
  encouragementSent,
  settingsUpdated,
  shutdown,
  error,
}
