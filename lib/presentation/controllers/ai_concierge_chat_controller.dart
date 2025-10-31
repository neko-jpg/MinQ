import 'dart:developer';

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:minq/core/ai/ai_integration_manager.dart';
import 'package:minq/core/ai/enhanced_ai_coach_service.dart';
import 'package:minq/data/providers.dart';
import 'package:minq/presentation/controllers/home_data_controller.dart';

@immutable
class AiConciergeMessage {
  const AiConciergeMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.quickActions = const [],
    this.suggestions = const [],
    this.isOffline = false,
  });

  final String text;
  final bool isUser;
  final DateTime timestamp;
  final List<QuickAction> quickActions;
  final List<String> suggestions;
  final bool isOffline;
}

final aiConciergeChatControllerProvider = AutoDisposeAsyncNotifierProvider<
  AiConciergeChatController,
  List<AiConciergeMessage>
>(AiConciergeChatController.new);

class AiConciergeChatController
    extends AutoDisposeAsyncNotifier<List<AiConciergeMessage>> {
  AiConciergeChatController();

  final AIIntegrationManager _aiManager = AIIntegrationManager.instance;
  final List<String> _conversationHistory = <String>[];
  EnhancedAICoachService? _enhancedCoach;

  @override
  Future<List<AiConciergeMessage>> build() async {
    try {
      final uid = ref.watch(uidProvider);
      await _aiManager.initialize(userId: uid ?? 'guest');
      
      // 強化されたAIコーチサービスを初期化
      _enhancedCoach = ref.read(enhancedAICoachServiceProvider);
    } catch (error, stackTrace) {
      log('AI init failed', error: error, stackTrace: stackTrace);
    }
    return <AiConciergeMessage>[await _initialGreeting()];
  }

  Future<void> resetConversation() async {
    state = const AsyncValue.loading();
    _conversationHistory.clear();
    _enhancedCoach?.clearConversationHistory();
    state = AsyncValue.data(<AiConciergeMessage>[await _initialGreeting()]);
  }

  String getCurrentAIMode() => '動的AIコーチ';

  void toggleAIMode() {
    log('AI mode toggled (placeholder)');
  }

  Future<void> sendUserMessage(String rawText) async {
    final message = rawText.trim();
    if (message.isEmpty) return;

    final existing = List<AiConciergeMessage>.from(
      state.valueOrNull ?? <AiConciergeMessage>[],
    );
    final userEntry = AiConciergeMessage(
      text: message,
      isUser: true,
      timestamp: DateTime.now(),
    );
    existing.add(userEntry);
    state = AsyncValue.data(existing);

    final response = await _generateEnhancedReply(message);

    final updated = List<AiConciergeMessage>.from(
      state.valueOrNull ?? <AiConciergeMessage>[],
    )..add(
      AiConciergeMessage(
        text: response.message,
        isUser: false,
        timestamp: DateTime.now(),
        quickActions: response.quickActions,
        suggestions: response.suggestions,
        isOffline: response.isOffline,
      ),
    );
    state = AsyncValue.data(updated);
  }

  Future<AiConciergeMessage> _initialGreeting() async {
    final greeting = _buildGreeting();
    
    // 初期クイックアクションを生成
    final quickActions = <QuickAction>[
      QuickAction(
        id: 'create_quest',
        title: '今日のクエストを作成',
        description: '新しい習慣を始めましょう',
        icon: 'add_task',
        route: '/create-quest',
        priority: 10,
      ),
      QuickAction(
        id: 'view_stats',
        title: '進捗を確認',
        description: 'これまでの成果を見てみましょう',
        icon: 'trending_up',
        route: '/stats',
        priority: 8,
      ),
    ];
    
    return AiConciergeMessage(
      text: greeting,
      isUser: false,
      timestamp: DateTime.now(),
      quickActions: quickActions,
      suggestions: const ['小さなことから始めてみましょう'],
    );
  }

  String _buildGreeting() {
    final homeAsync = ref.read(homeDataProvider);
    final homeData = homeAsync.valueOrNull;
    if (homeData == null) {
      return _fallbackGreeting;
    }

    final streak = homeData.streak;
    if (streak > 0) {
      return 'おかえりなさい！現在 $streak 日連続で達成しています。今日も一歩ずつ進めていきましょう。';
    }
    return 'はじめまして！まずはシンプルなクエストから肩慣らししてみましょう。';
  }

  Future<AICoachResponse> _generateEnhancedReply(String userMessage) async {
    try {
      if (_enhancedCoach != null) {
        return await _enhancedCoach!.generateChatResponse(
          userMessage,
          conversationHistory: _conversationHistory.take(8).toList(),
          maxTokens: 150,
        );
      }
    } catch (error, stackTrace) {
      log('Enhanced AI reply failed', error: error, stackTrace: stackTrace);
    }
    
    // フォールバック
    return AICoachResponse(
      message: _fallbackHeuristic(userMessage),
      quickActions: [],
      context: null,
      isOffline: true,
      suggestions: [],
      encouragementLevel: MotivationLevel.starting,
    );
  }

  String _fallbackHeuristic(String userMessage) {
    final homeData = ref.read(homeDataProvider).valueOrNull;
    final focus = homeData?.focus;
    final questTitle =
        focus?.questTitle ?? homeData?.quests.firstOrNull?.title ?? 'MiniQuest';

    final completionsToday = homeData?.completionsToday ?? 0;
    final encouragement =
        completionsToday > 0
            ? 'すでに今日 $completionsToday 件進んでいます。この勢いで続けていきましょう。'
            : 'ウォームアップのつもりで軽く取り組んでみましょう。';

    final suggestion =
        _isTimeLike(userMessage)
            ? 'タイマーを ${_parseGoalMinutes(userMessage)} 分にセットして集中タイムを作ってみてください。'
            : 'まずは 1 回だけこなして完了報告を残しましょう。';

    return '了解しました。「$questTitle」に取り組むのがおすすめです。$encouragement $suggestion';
  }

  bool _isTimeLike(String message) {
    return message.contains('分') || message.contains('時間');
  }

  int _parseGoalMinutes(String message) {
    final match = RegExp(r'(\d{1,2})').firstMatch(message);
    if (match == null) return 5;
    final value = int.tryParse(match.group(1)!);
    if (value == null || value <= 0) return 5;
    return value.clamp(3, 45);
  }
}

const String _fallbackGreeting = 'こんにちは！今日も小さな一歩を積み上げていきましょう。';
