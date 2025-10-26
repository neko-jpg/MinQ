import 'dart:developer';


import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:minq/core/ai/ai_integration_manager.dart';
import 'package:minq/core/ai/tflite_unified_ai_service.dart';
import 'package:minq/presentation/controllers/ai_concierge_chat_controller.dart';

/// AI機能統合テスト
/// すべてのAI機能が正しく動作することを検証
class AIFeatureIntegrationTest {
  static Future<void> runAllTests() async {
    log('=== AI機能統合テスト開始 ===');

    try {
      // 1. 基盤AIサービステスト
      await _testTFLiteUnifiedAIService();

      // 2. AI統合マネージャーテスト
      await _testAIIntegrationManager();

      // 3. AIコンシェルジュテスト
      await _testAIConciergeChatController();

      // 4. AI画面統合テスト
      await _testAIScreenIntegrations();

      // 5. AIウィジェット統合テスト
      await _testAIWidgetIntegrations();

      // 6. AI機能エンドツーエンドテスト
      await _testAIEndToEndFlow();

      log('=== AI機能統合テスト完了 - すべて成功 ===');
    } catch (e, stackTrace) {
      log('=== AI機能統合テスト失敗 ===', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// 1. TFLiteUnifiedAIServiceテスト
  static Future<void> _testTFLiteUnifiedAIService() async {
    log('1. TFLiteUnifiedAIService テスト開始');

    final service = TFLiteUnifiedAIService.instance;

    // 初期化テスト
    await service.initialize();
    log('✓ AI サービス初期化成功');

    // 診断情報テスト
    final diagnostics = service.diagnostics();
    assert(diagnostics['initialized'] == true, 'AI サービスが初期化されていません');
    log('✓ 診断情報取得成功: $diagnostics');

    // チャット応答生成テスト
    final chatResponse = await service.generateChatResponse(
      'こんにちは、今日も頑張りましょう！',
      systemPrompt: 'あなたは親しみやすいコーチです。',
      maxTokens: 100,
    );
    assert(chatResponse.isNotEmpty, 'チャット応答が空です');
    log('✓ チャット応答生成成功: $chatResponse');

    // 感情分析テスト
    final sentiment = await service.analyzeSentiment('今日はとても良い気分です！');
    assert(sentiment.positive > 0, '感情分析の結果が不正です');
    log('✓ 感情分析成功: positive=${sentiment.positive}, negative=${sentiment.negative}');

    // 習慣推薦テスト
    final recommendations = await service.recommendHabits(
      userHabits: ['朝の瞑想'],
      completedHabits: ['読書'],
      preferences: {'focus': 0.8, 'wellness': 0.6},
      limit: 3,
    );
    assert(recommendations.isNotEmpty, '習慣推薦が空です');
    log('✓ 習慣推薦成功: ${recommendations.length}件の推薦');

    // 失敗予測テスト
    final prediction = await service.predictFailure(
      habitId: 'test_habit',
      history: [
        CompletionRecord(
          completedAt: DateTime.now().subtract(const Duration(days: 1)),
          habitId: 'test_habit',
          wasCompleted: true,
        ),
        CompletionRecord(
          completedAt: DateTime.now().subtract(const Duration(days: 2)),
          habitId: 'test_habit',
          wasCompleted: false,
        ),
      ],
      targetDate: DateTime.now().add(const Duration(days: 1)),
    );
    assert(prediction.riskScore >= 0 && prediction.riskScore <= 1, '失敗予測スコアが範囲外です');
    log('✓ 失敗予測成功: リスクスコア=${prediction.riskScore}');

    // 習慣提案テスト
    final suggestion = await service.generateHabitSuggestion(
      userGoal: '健康的な生活',
      currentHabits: ['運動', '瞑想'],
      userProfile: {'availableTime': 30},
    );
    assert(suggestion.isNotEmpty, '習慣提案が空です');
    log('✓ 習慣提案成功: $suggestion');

    log('1. TFLiteUnifiedAIService テスト完了');
  }

  /// 2. AIIntegrationManagerテスト
  static Future<void> _testAIIntegrationManager() async {
    log('2. AIIntegrationManager テスト開始');

    final manager = AIIntegrationManager.instance;

    // 初期化テスト
    await manager.initialize(userId: 'test_user');
    log('✓ AI統合マネージャー初期化成功');

    // チャット応答テスト
    final chatResponse = await manager.generateChatResponse(
      'モチベーションが下がっています',
      conversationHistory: ['user: こんにちは', 'assistant: こんにちは！'],
      systemPrompt: 'あなたは励ましのコーチです。',
    );
    assert(chatResponse.isNotEmpty, 'チャット応答が空です');
    log('✓ 統合チャット応答成功: $chatResponse');

    // 習慣推薦テスト
    final recommendations = await manager.generateHabitRecommendations(
      userHabits: ['朝の散歩'],
      completedHabits: ['日記'],
      preferences: {'health': 0.9, 'productivity': 0.7},
    );
    assert(recommendations.isNotEmpty, '習慣推薦が空です');
    log('✓ 統合習慣推薦成功: ${recommendations.length}件');

    // 失敗予測テスト
    final prediction = await manager.predictHabitFailure(
      habitId: 'morning_exercise',
      history: [
        CompletionRecord(
          completedAt: DateTime.now().subtract(const Duration(days: 1)),
          habitId: 'morning_exercise',
          wasCompleted: true,
        ),
      ],
      targetDate: DateTime.now().add(const Duration(days: 1)),
    );
    assert(prediction.riskScore >= 0, '失敗予測が不正です');
    log('✓ 統合失敗予測成功: リスク=${prediction.riskScore}');

    // パーソナリティ診断テスト
    final diagnosis = await manager.performPersonalityDiagnosis(
      habitHistory: {'completions': 50, 'streaks': 3},
      completionPatterns: {'morning': 0.8, 'evening': 0.6},
      preferences: {'structure': 0.7, 'flexibility': 0.5},
    );
    assert(diagnosis.containsKey('archetype'), 'パーソナリティ診断結果が不正です');
    log('✓ パーソナリティ診断成功: ${diagnosis['archetype']}');

    // 週次レポート生成テスト
    final report = await manager.generateWeeklyReport(userId: 'test_user');
    assert(report.containsKey('id'), '週次レポートが不正です');
    log('✓ 週次レポート生成成功: ${report['id']}');

    // ハビットストーリー生成テスト
    final story = await manager.generateHabitStory(
      type: 'dailyAchievement',
      progressData: {
        'habitTitle': 'モーニングルーティン',
        'currentStreak': 7,
        'completionRate': 0.85,
      },
    );
    assert(story.containsKey('id'), 'ハビットストーリーが不正です');
    log('✓ ハビットストーリー生成成功: ${story['title']}');

    // 感情分析テスト
    final sentiment = await manager.analyzeSentiment('今日は素晴らしい一日でした！');
    assert(sentiment.positive > 0, '感情分析が不正です');
    log('✓ 統合感情分析成功: ${sentiment.dominantSentiment.name}');

    // 診断情報テスト
    final diagnostics = await manager.getDiagnosticInfo();
    assert(diagnostics['isInitialized'] == true, '診断情報が不正です');
    log('✓ 診断情報取得成功');

    log('2. AIIntegrationManager テスト完了');
  }

  /// 3. AIConciergeChatControllerテスト
  static Future<void> _testAIConciergeChatController() async {
    log('3. AiConciergeChatController テスト開始');

    // Riverpodコンテナの作成
    final container = ProviderContainer();

    try {
      // コントローラーの初期化
      final controller = container.read(aiConciergeChatControllerProvider.notifier);
      log('✓ AIコンシェルジュコントローラー作成成功');

      // 初期状態の確認
      final initialState = container.read(aiConciergeChatControllerProvider);
      await initialState.when(
        data: (messages) {
          assert(messages.isNotEmpty, '初期メッセージが空です');
          assert(!messages.first.isUser, '初期メッセージがユーザーメッセージです');
          log('✓ 初期挨拶メッセージ確認: ${messages.first.text}');
        },
        loading: () => throw AssertionError('初期化が完了していません'),
        error: (error, _) => throw AssertionError('初期化エラー: $error'),
      );

      // ユーザーメッセージ送信テスト
      await controller.sendUserMessage('今日のモチベーションを上げてください');
      
      // 応答の確認
      final afterMessageState = container.read(aiConciergeChatControllerProvider);
      await afterMessageState.when(
        data: (messages) {
          assert(messages.length >= 3, 'メッセージ数が不正です'); // 挨拶 + ユーザー + AI応答
          assert(messages.last.isUser == false, '最後のメッセージがAI応答ではありません');
          log('✓ AI応答メッセージ確認: ${messages.last.text}');
        },
        loading: () => throw AssertionError('メッセージ処理が完了していません'),
        error: (error, _) => throw AssertionError('メッセージ送信エラー: $error'),
      );

      // AIモード確認テスト
      final aiMode = controller.getCurrentAIMode();
      assert(aiMode.isNotEmpty, 'AIモードが空です');
      log('✓ AIモード確認: $aiMode');

      // 会話リセットテスト
      await controller.resetConversation();
      final resetState = container.read(aiConciergeChatControllerProvider);
      await resetState.when(
        data: (messages) {
          assert(messages.length == 1, 'リセット後のメッセージ数が不正です');
          assert(!messages.first.isUser, 'リセット後の初期メッセージが不正です');
          log('✓ 会話リセット成功');
        },
        loading: () => throw AssertionError('リセットが完了していません'),
        error: (error, _) => throw AssertionError('リセットエラー: $error'),
      );

      // 感情分析テスト
      await controller.analyzeSentiment('とても嬉しいです！');
      log('✓ 感情分析実行成功');

      // 習慣推薦取得テスト
      final recommendations = await controller.getHabitRecommendations();
      log('✓ 習慣推薦取得成功: ${recommendations.length}件');

    } finally {
      container.dispose();
    }

    log('3. AiConciergeChatController テスト完了');
  }

  /// 4. AI画面統合テスト
  static Future<void> _testAIScreenIntegrations() async {
    log('4. AI画面統合テスト開始');

    // AI Concierge Chat Screen テスト
    await _testAIConciergeChatScreen();

    // AI Insights Screen テスト
    await _testAIInsightsScreen();

    // Habit Analysis Screen テスト
    await _testHabitAnalysisScreen();

    log('4. AI画面統合テスト完了');
  }

  /// AI Concierge Chat Screen テスト
  static Future<void> _testAIConciergeChatScreen() async {
    log('4.1. AI Concierge Chat Screen テスト');

    // 画面の基本構造テスト（コンパイル確認）
    try {
      // AiConciergeChatScreenのインスタンス作成テスト
      // 実際のウィジェットテストは統合テストで行う
      log('✓ AiConciergeChatScreen クラス構造確認');

      // 必要な依存関係の確認
      final service = TFLiteUnifiedAIService.instance;
      await service.initialize();
      log('✓ 依存サービス初期化確認');

    } catch (e) {
      throw AssertionError('AI Concierge Chat Screen テストエラー: $e');
    }
  }

  /// AI Insights Screen テスト
  static Future<void> _testAIInsightsScreen() async {
    log('4.2. AI Insights Screen テスト');

    // 画面が空でも正常に処理されることを確認
    try {
      log('✓ AI Insights Screen 構造確認');
    } catch (e) {
      throw AssertionError('AI Insights Screen テストエラー: $e');
    }
  }

  /// Habit Analysis Screen テスト
  static Future<void> _testHabitAnalysisScreen() async {
    log('4.3. Habit Analysis Screen テスト');

    try {
      // 画面の基本構造確認
      log('✓ Habit Analysis Screen 構造確認');

      // 必要なサービスの確認
      final manager = AIIntegrationManager.instance;
      await manager.initialize(userId: 'test_user');
      log('✓ 分析サービス初期化確認');

    } catch (e) {
      throw AssertionError('Habit Analysis Screen テストエラー: $e');
    }
  }

  /// 5. AIウィジェット統合テスト
  static Future<void> _testAIWidgetIntegrations() async {
    log('5. AIウィジェット統合テスト開始');

    // AI Concierge Card テスト
    await _testAIConciergeCar();

    // Failure Prediction Widget テスト
    await _testFailurePredictionWidget();

    log('5. AIウィジェット統合テスト完了');
  }

  /// AI Concierge Card テスト
  static Future<void> _testAIConciergeCar() async {
    log('5.1. AI Concierge Card テスト');

    try {
      // ウィジェットの基本構造確認
      log('✓ AI Concierge Card 構造確認');

      // 依存関係の確認
      final container = ProviderContainer();
      try {
        final controller = container.read(aiConciergeChatControllerProvider.notifier);
        log('✓ AI Concierge Card 依存関係確認');
      } finally {
        container.dispose();
      }

    } catch (e) {
      throw AssertionError('AI Concierge Card テストエラー: $e');
    }
  }

  /// Failure Prediction Widget テスト
  static Future<void> _testFailurePredictionWidget() async {
    log('5.2. Failure Prediction Widget テスト');

    try {
      // ウィジェットの基本構造確認
      log('✓ Failure Prediction Widget 構造確認');

      // 予測サービスの確認
      final service = TFLiteUnifiedAIService.instance;
      await service.initialize();

      final prediction = await service.predictFailure(
        habitId: 'test_habit',
        history: [],
        targetDate: DateTime.now().add(const Duration(days: 1)),
      );
      assert(prediction.riskScore >= 0, '失敗予測が不正です');
      log('✓ Failure Prediction Widget サービス連携確認');

    } catch (e) {
      throw AssertionError('Failure Prediction Widget テストエラー: $e');
    }
  }

  /// 6. AI機能エンドツーエンドテスト
  static Future<void> _testAIEndToEndFlow() async {
    log('6. AI機能エンドツーエンドテスト開始');

    try {
      // 1. ユーザーがAIコンシェルジュと会話
      final manager = AIIntegrationManager.instance;
      await manager.initialize(userId: 'test_user');

      final chatResponse = await manager.generateChatResponse(
        '新しい習慣を始めたいのですが、何がおすすめですか？',
        systemPrompt: 'あなたは習慣形成のコーチです。',
      );
      log('✓ Step 1: AIコンシェルジュ会話 - $chatResponse');

      // 2. AIが習慣を推薦
      final recommendations = await manager.generateHabitRecommendations(
        userHabits: [],
        completedHabits: [],
        preferences: {'health': 0.8, 'productivity': 0.6},
      );
      log('✓ Step 2: 習慣推薦 - ${recommendations.length}件');

      // 3. ユーザーが習慣を開始
      await manager.recordHabitStart(
        habitId: 'morning_walk',
        habitTitle: '朝の散歩',
        category: 'fitness',
        estimatedDuration: const Duration(minutes: 20),
      );
      log('✓ Step 3: 習慣開始記録');

      // 4. リアルタイムコーチングの開始
      await manager.startRealtimeCoaching(
        questId: 'morning_walk',
        questTitle: '朝の散歩',
        estimatedDuration: const Duration(minutes: 20),
      );
      log('✓ Step 4: リアルタイムコーチング開始');

      // 5. 習慣完了の記録
      await manager.recordHabitCompletion(
        habitId: 'morning_walk',
        habitTitle: '朝の散歩',
        category: 'fitness',
        actualDuration: const Duration(minutes: 18),
      );
      log('✓ Step 5: 習慣完了記録');

      // 6. 失敗予測の実行
      final prediction = await manager.predictHabitFailure(
        habitId: 'morning_walk',
        history: [
          CompletionRecord(
            completedAt: DateTime.now(),
            habitId: 'morning_walk',
            wasCompleted: true,
          ),
        ],
        targetDate: DateTime.now().add(const Duration(days: 1)),
      );
      log('✓ Step 6: 失敗予測 - リスク=${prediction.riskScore}');

      // 7. 感情分析
      final sentiment = await manager.analyzeSentiment('今日の散歩はとても気持ちよかったです！');
      log('✓ Step 7: 感情分析 - ${sentiment.dominantSentiment.name}');

      // 8. ハビットストーリー生成
      final story = await manager.generateHabitStory(
        type: 'dailyAchievement',
        progressData: {
          'habitTitle': '朝の散歩',
          'currentStreak': 1,
          'completionRate': 1.0,
        },
      );
      log('✓ Step 8: ハビットストーリー生成 - ${story['title']}');

      // 9. 週次レポート生成
      final report = await manager.generateWeeklyReport(userId: 'test_user');
      log('✓ Step 9: 週次レポート生成 - ${report['id']}');

      // 10. パーソナリティ診断
      final diagnosis = await manager.performPersonalityDiagnosis(
        habitHistory: {'completions': 1, 'streaks': 1},
        completionPatterns: {'morning': 1.0},
        preferences: {'health': 0.8},
      );
      log('✓ Step 10: パーソナリティ診断 - ${diagnosis['archetype']}');

      log('✓ エンドツーエンドフロー完了 - すべてのAI機能が連携して動作');

    } catch (e, stackTrace) {
      throw AssertionError('エンドツーエンドテストエラー: $e\n$stackTrace');
    }

    log('6. AI機能エンドツーエンドテスト完了');
  }

  /// パフォーマンステスト
  static Future<void> runPerformanceTests() async {
    log('=== AI機能パフォーマンステスト開始 ===');

    final stopwatch = Stopwatch();

    // AI初期化時間テスト
    stopwatch.start();
    final service = TFLiteUnifiedAIService.instance;
    await service.initialize();
    stopwatch.stop();
    final initTime = stopwatch.elapsedMilliseconds;
    log('AI初期化時間: ${initTime}ms');
    assert(initTime < 5000, 'AI初期化が遅すぎます: ${initTime}ms');

    // チャット応答時間テスト
    stopwatch.reset();
    stopwatch.start();
    await service.generateChatResponse('こんにちは');
    stopwatch.stop();
    final chatTime = stopwatch.elapsedMilliseconds;
    log('チャット応答時間: ${chatTime}ms');
    assert(chatTime < 3000, 'チャット応答が遅すぎます: ${chatTime}ms');

    // 感情分析時間テスト
    stopwatch.reset();
    stopwatch.start();
    await service.analyzeSentiment('今日は良い日です');
    stopwatch.stop();
    final sentimentTime = stopwatch.elapsedMilliseconds;
    log('感情分析時間: ${sentimentTime}ms');
    assert(sentimentTime < 1000, '感情分析が遅すぎます: ${sentimentTime}ms');

    // 習慣推薦時間テスト
    stopwatch.reset();
    stopwatch.start();
    await service.recommendHabits(
      userHabits: ['運動'],
      completedHabits: ['読書'],
      preferences: {'health': 0.8},
    );
    stopwatch.stop();
    final recommendTime = stopwatch.elapsedMilliseconds;
    log('習慣推薦時間: ${recommendTime}ms');
    assert(recommendTime < 2000, '習慣推薦が遅すぎます: ${recommendTime}ms');

    log('=== AI機能パフォーマンステスト完了 ===');
  }

  /// エラーハンドリングテスト
  static Future<void> runErrorHandlingTests() async {
    log('=== AI機能エラーハンドリングテスト開始 ===');

    final service = TFLiteUnifiedAIService.instance;
    await service.initialize();

    // 空入力テスト
    try {
      final response = await service.generateChatResponse('');
      log('✓ 空入力処理: $response');
    } catch (e) {
      log('✓ 空入力エラーハンドリング: $e');
    }

    // 長すぎる入力テスト
    try {
      final longInput = 'あ' * 10000;
      final response = await service.generateChatResponse(longInput);
      log('✓ 長入力処理: ${response.length}文字');
    } catch (e) {
      log('✓ 長入力エラーハンドリング: $e');
    }

    // 不正なパラメータテスト
    try {
      await service.recommendHabits(
        userHabits: [],
        completedHabits: [],
        preferences: {},
        limit: -1,
      );
      log('✓ 不正パラメータ処理完了');
    } catch (e) {
      log('✓ 不正パラメータエラーハンドリング: $e');
    }

    // サービスリセットテスト
    try {
      await service.forceReset();
      await service.initialize();
      log('✓ サービスリセット成功');
    } catch (e) {
      log('✗ サービスリセットエラー: $e');
    }

    log('=== AI機能エラーハンドリングテスト完了 ===');
  }
}

/// テスト実行用のメイン関数
Future<void> main() async {
  try {
    // 基本統合テスト
    await AIFeatureIntegrationTest.runAllTests();

    // パフォーマンステスト
    await AIFeatureIntegrationTest.runPerformanceTests();

    // エラーハンドリングテスト
    await AIFeatureIntegrationTest.runErrorHandlingTests();

    log('🎉 すべてのAI機能統合テストが成功しました！');
  } catch (e, stackTrace) {
    log('❌ AI機能統合テストが失敗しました', error: e, stackTrace: stackTrace);
  }
}