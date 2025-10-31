import 'dart:async';
import 'dart:developer';
import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:minq/core/ai/dynamic_prompt_engine.dart';
import 'package:minq/core/ai/tflite_unified_ai_service.dart';
import 'package:minq/core/ai/user_progress_service.dart';

/// 強化されたAIコーチサービス
/// 動的プロンプト生成とオフライン対応を統合
class EnhancedAICoachService {
  static EnhancedAICoachService? _instance;
  static EnhancedAICoachService get instance =>
      _instance ??= EnhancedAICoachService._();

  EnhancedAICoachService._();

  final TFLiteUnifiedAIService _aiService = TFLiteUnifiedAIService.instance;
  final DynamicPromptEngine _promptEngine = DynamicPromptEngine.instance;
  
  Ref? _ref;
  UserProgressService? _progressService;
  
  final List<String> _conversationHistory = [];
  UserProgressContext? _lastContext;
  DateTime? _lastContextUpdate;

  /// サービスの初期化
  Future<void> initialize({required Ref ref}) async {
    _ref = ref;
    _progressService = UserProgressService(ref);
    
    try {
      await _aiService.initialize();
      log('EnhancedAICoach: サービスが初期化されました');
    } catch (e) {
      log('EnhancedAICoach: 初期化エラー - $e');
    }
  }

  /// チャット応答を生成（動的プロンプト対応）
  Future<AICoachResponse> generateChatResponse(
    String userMessage, {
    List<String>? conversationHistory,
    int maxTokens = 150,
  }) async {
    try {
      // ユーザー進捗コンテキストを取得
      final context = await _getOrUpdateContext();
      if (context == null) {
        return _generateFallbackResponse(userMessage);
      }

      // 動的システムプロンプトを生成
      final systemPrompt = _promptEngine.generateSystemPrompt(context);
      
      // 文脈情報を含むプロンプトを生成
      final contextualPrompt = _promptEngine.generateContextualPrompt(
        userMessage,
        context,
        conversationHistory ?? _conversationHistory,
      );

      // クイックアクションを生成
      final quickActions = _promptEngine.generateQuickActions(context);

      // ネットワーク状態をチェック（簡易実装）
      const isOnline = true; // TODO: 実際のネットワーク状態を取得

      String responseMessage;
      
      if (isOnline) {
        // オンライン時はAIサービスを使用
        responseMessage = await _aiService.generateChatResponse(
          contextualPrompt,
          conversationHistory: conversationHistory ?? _conversationHistory,
          systemPrompt: systemPrompt,
          maxTokens: maxTokens,
        );
      } else {
        // オフライン時はヒューリスティック応答
        responseMessage = _generateHeuristicResponse(userMessage, context);
      }

      // 会話履歴を更新
      _updateConversationHistory(userMessage, responseMessage);

      return AICoachResponse(
        message: responseMessage,
        quickActions: quickActions,
        context: context,
        isOffline: !isOnline,
        suggestions: _generateSuggestions(context),
        encouragementLevel: context.motivationLevel,
      );

    } catch (e, stackTrace) {
      log('EnhancedAICoach: 応答生成エラー', error: e, stackTrace: stackTrace);
      return _generateFallbackResponse(userMessage);
    }
  }

  /// ユーザー進捗コンテキストを取得または更新
  Future<UserProgressContext?> _getOrUpdateContext() async {
    final now = DateTime.now();
    
    // キャッシュが有効な場合はそれを使用（5分間有効）
    if (_lastContext != null && 
        _lastContextUpdate != null &&
        now.difference(_lastContextUpdate!).inMinutes < 5) {
      return _lastContext;
    }

    // 新しいコンテキストを取得
    try {
      _lastContext = await _progressService?.getCurrentProgress();
      _lastContextUpdate = now;
      return _lastContext;
    } catch (e) {
      log('EnhancedAICoach: コンテキスト取得エラー - $e');
      return _lastContext; // 古いキャッシュを返す
    }
  }

  /// オフライン時のヒューリスティック応答生成
  String _generateHeuristicResponse(String userMessage, UserProgressContext context) {
    final message = userMessage.toLowerCase();
    
    // 挨拶パターン
    if (_containsAny(message, ['こんにちは', 'おはよう', 'こんばんは', 'はじめまして'])) {
      return _generateGreetingResponse(context);
    }
    
    // モチベーション関連
    if (_containsAny(message, ['やる気', 'モチベーション', '続かない', '挫折', 'しんどい'])) {
      return _generateMotivationResponse(context);
    }
    
    // 習慣・継続関連
    if (_containsAny(message, ['習慣', 'ルーティン', '続ける', 'コツ', '方法'])) {
      return _generateHabitAdviceResponse(context);
    }
    
    // 進捗・成果関連
    if (_containsAny(message, ['進捗', '成果', '結果', '効果', '変化'])) {
      return _generateProgressResponse(context);
    }
    
    // 時間・スケジュール関連
    if (_containsAny(message, ['時間', 'スケジュール', '忙しい', '時間がない'])) {
      return _generateTimeManagementResponse(context);
    }
    
    // 目標・計画関連
    if (_containsAny(message, ['目標', '計画', '設定', 'プラン'])) {
      return _generateGoalSettingResponse(context);
    }
    
    // デフォルト応答
    return _generateDefaultResponse(context);
  }

  /// 挨拶応答の生成
  String _generateGreetingResponse(UserProgressContext context) {
    if (context.streak > 0) {
      return 'こんにちは！${context.streak}日連続達成、素晴らしいですね。今日も一緒に頑張りましょう！';
    } else if (context.completionsToday > 0) {
      return 'こんにちは！今日はすでに${context.completionsToday}件完了していますね。調子が良さそうです！';
    } else {
      return 'こんにちは！今日も新しい一歩を踏み出しましょう。小さなことから始めてみませんか？';
    }
  }

  /// モチベーション応答の生成
  String _generateMotivationResponse(UserProgressContext context) {
    if (context.streak >= 7) {
      return '${context.streak}日も継続できているあなたなら大丈夫！完璧を目指さず、今日できることから始めましょう。';
    } else if (context.completionsToday > 0) {
      return '今日はすでに行動を起こしていますね。それだけでも素晴らしいことです。無理せず続けましょう。';
    } else {
      return '気持ちはよく分かります。まずは1分だけでも始めてみませんか？小さな一歩が大きな変化を生みます。';
    }
  }

  /// 習慣アドバイス応答の生成
  String _generateHabitAdviceResponse(UserProgressContext context) {
    if (context.habitStage == HabitStage.initial) {
      return '新しい習慣は小さく始めるのがコツです。毎日同じ時間に1分だけでも続けることから始めましょう。';
    } else if (context.habitStage == HabitStage.forming) {
      return '良いスタートですね！習慣が身につくまで約21日。焦らず、今のペースを大切にしましょう。';
    } else {
      return '素晴らしい継続力です！今度は質を高めることを意識してみてはいかがでしょうか。';
    }
  }

  /// 進捗応答の生成
  String _generateProgressResponse(UserProgressContext context) {
    if (context.streak >= 21) {
      return '${context.streak}日連続は驚異的です！習慣が完全に身についていますね。新しいチャレンジも検討してみませんか？';
    } else if (context.streak >= 7) {
      return '1週間継続、素晴らしい成果です！この調子で3週間を目指しましょう。確実に変化が現れているはずです。';
    } else if (context.completionsToday >= 3) {
      return '今日は${context.completionsToday}件も完了！とても充実した1日ですね。この積み重ねが大きな成果につながります。';
    } else {
      return '進捗は必ず現れます。継続こそが最大の成果です。今日の小さな一歩も大切な進歩ですよ。';
    }
  }

  /// 時間管理応答の生成
  String _generateTimeManagementResponse(UserProgressContext context) {
    if (context.activeQuests.isNotEmpty) {
      final shortQuest = context.activeQuests.where(
        (quest) => quest.estimatedMinutes <= 10,
      ).firstOrNull;
      
      if (shortQuest != null) {
        return '忙しい時こそ「${shortQuest.title}」のような短時間のクエストがおすすめです。5分でも継続が大切です。';
      }
    }
    
    return '忙しい時は5分だけでも大丈夫。完璧を目指さず、継続することを優先しましょう。隙間時間を活用してみてください。';
  }

  /// 目標設定応答の生成
  String _generateGoalSettingResponse(UserProgressContext context) {
    if (context.activeQuests.isEmpty) {
      return '目標設定は素晴らしいですね！まずは1つ、達成しやすい小さなクエストから始めてみましょう。';
    } else if (context.activeQuests.length >= 3) {
      return '複数のクエストに取り組んでいますね。まずは今のクエストを安定させてから新しい目標を追加しましょう。';
    } else {
      return '現在のクエストに慣れてきたら、新しいカテゴリの目標を追加してみるのも良いですね。';
    }
  }

  /// デフォルト応答の生成
  String _generateDefaultResponse(UserProgressContext context) {
    final responses = [
      'そうですね。${context.focusQuest?.title ?? 'クエスト'}に取り組んでみるのはいかがでしょうか？',
      '素晴らしい質問ですね。継続することで必ず成果が現れますよ。',
      'MinQで一緒に成長していきましょう。小さな一歩も大切な進歩です。',
      'あなたのペースで大丈夫です。今日できることから始めてみませんか？',
    ];
    
    return responses[math.Random().nextInt(responses.length)];
  }

  /// 提案事項を生成
  List<String> _generateSuggestions(UserProgressContext context) {
    final suggestions = <String>[];
    
    // ストリーク状況に応じた提案
    if (context.streak == 0) {
      suggestions.add('今日から新しいストリークを始めましょう');
    } else if (context.streak < 7) {
      suggestions.add('1週間継続を目指しましょう');
    } else if (context.streak < 21) {
      suggestions.add('3週間で習慣が定着します');
    }
    
    // 今日の活動に応じた提案
    if (context.completionsToday == 0) {
      suggestions.add('今日の最初のクエストを完了しましょう');
    } else if (context.completionsToday < 3) {
      suggestions.add('もう1つクエストに挑戦してみませんか');
    }
    
    // フォーカスクエストの提案
    if (context.focusQuest != null) {
      suggestions.add('「${context.focusQuest!.title}」がおすすめです');
    }
    
    return suggestions;
  }

  /// フォールバック応答の生成
  AICoachResponse _generateFallbackResponse(String userMessage) {
    return const AICoachResponse(
      message: 'ありがとうございます。MinQで一緒に習慣づくりを頑張りましょう！',
      quickActions: [
        QuickAction(
          id: 'create_quest',
          title: 'クエストを作成',
          description: '新しい習慣を始めましょう',
          icon: 'add_task',
          route: '/create-quest',
          priority: 10,
        ),
      ],
      context: null,
      isOffline: true,
      suggestions: ['小さなことから始めてみましょう'],
      encouragementLevel: MotivationLevel.starting,
    );
  }

  /// 会話履歴を更新
  void _updateConversationHistory(String userMessage, String aiResponse) {
    _conversationHistory.add('USER: $userMessage');
    _conversationHistory.add('AI: $aiResponse');
    
    // 履歴は最新10件まで保持
    while (_conversationHistory.length > 10) {
      _conversationHistory.removeAt(0);
    }
  }

  /// キーワード含有チェック
  bool _containsAny(String text, List<String> keywords) {
    return keywords.any((keyword) => text.contains(keyword));
  }

  /// 会話履歴をクリア
  void clearConversationHistory() {
    _conversationHistory.clear();
    log('EnhancedAICoach: 会話履歴をクリアしました');
  }

  /// コンテキストキャッシュをクリア
  void clearContextCache() {
    _lastContext = null;
    _lastContextUpdate = null;
    log('EnhancedAICoach: コンテキストキャッシュをクリアしました');
  }

  /// サービスの健全性チェック
  Future<bool> healthCheck() async {
    try {
      final context = await _getOrUpdateContext();
      return context != null;
    } catch (e) {
      log('EnhancedAICoach: ヘルスチェック失敗 - $e');
      return false;
    }
  }

  /// 診断情報の取得
  Future<Map<String, dynamic>> getDiagnosticInfo() async {
    final aiDiagnostics = await _aiService.getDiagnosticInfo();
    
    return {
      ...aiDiagnostics,
      'enhancedCoach': {
        'conversationHistoryLength': _conversationHistory.length,
        'lastContextUpdate': _lastContextUpdate?.toIso8601String(),
        'hasContext': _lastContext != null,
        'progressServiceInitialized': _progressService != null,
      },
    };
  }
}

/// AIコーチ応答
class AICoachResponse {
  final String message;
  final List<QuickAction> quickActions;
  final UserProgressContext? context;
  final bool isOffline;
  final List<String> suggestions;
  final MotivationLevel encouragementLevel;

  const AICoachResponse({
    required this.message,
    required this.quickActions,
    required this.context,
    required this.isOffline,
    required this.suggestions,
    required this.encouragementLevel,
  });

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'quickActions': quickActions.map((action) => action.toJson()).toList(),
      'isOffline': isOffline,
      'suggestions': suggestions,
      'encouragementLevel': encouragementLevel.name,
      'hasContext': context != null,
    };
  }
}

/// プロバイダー定義
final enhancedAICoachServiceProvider = Provider<EnhancedAICoachService>((ref) {
  final service = EnhancedAICoachService.instance;
  service.initialize(ref: ref);
  return service;
});