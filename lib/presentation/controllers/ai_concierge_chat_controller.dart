import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:minq/core/ai/ai_integration_manager.dart';

@immutable
class AiConciergeMessage {
  const AiConciergeMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });

  final String text;
  final bool isUser;
  final DateTime timestamp;
}

final AutoDisposeAsyncNotifierProvider<
  AiConciergeChatController,
  List<AiConciergeMessage>
>
aiConciergeChatControllerProvider = AutoDisposeAsyncNotifierProvider<
  AiConciergeChatController,
  List<AiConciergeMessage>
>(AiConciergeChatController.new);

class AiConciergeChatController
    extends AutoDisposeAsyncNotifier<List<AiConciergeMessage>> {
  final AIIntegrationManager _aiManager = AIIntegrationManager.instance;
  final List<String> _conversationHistory = [];

  @override
  Future<List<AiConciergeMessage>> build() async {
    // AI統合マネージャーの初期化
    try {
      await _aiManager.initialize(userId: 'current_user'); // 実際のユーザーIDを使用
    } catch (e) {
      log('AI統合マネージャー初期化エラー: $e');
    }
    
    return _createInitialConversation();
  }

  Future<void> resetConversation() async {
    state = const AsyncValue.loading();
    try {
      _conversationHistory.clear();
      final messages = await _createInitialConversation();
      state = AsyncValue.data(messages);
    } catch (error, stackTrace) {
      log(
        'Failed to reset AI concierge conversation',
        error: error,
        stackTrace: stackTrace,
      );
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// 現在のAIモードを取得
  String getCurrentAIMode() {
    return 'TensorFlow Lite AI Assistant';
  }

  Future<void> sendUserMessage(String rawText) async {
    final text = rawText.trim();
    if (text.isEmpty) {
      return;
    }
    
    final current = List<AiConciergeMessage>.from(
      state.valueOrNull ?? <AiConciergeMessage>[],
    );
    final userMessage = AiConciergeMessage(
      text: text,
      isUser: true,
      timestamp: DateTime.now(),
    );
    current.add(userMessage);
    state = AsyncValue.data(current);
    
    // 会話履歴に追加
    _conversationHistory.add('ユーザー: $text');
    
    try {
      // TensorFlow Lite統合AIを使用して応答生成
      final reply = await _aiManager.generateChatResponse(
        text,
        conversationHistory: _conversationHistory.take(10).toList(), // 最新10件のみ
        systemPrompt: 'あなたはMinQの親しみやすいAIコンシェルジュです。ユーザーの習慣形成をサポートし、励ましの言葉をかけてください。',
        maxTokens: 150,
      );
      
      final trimmed = reply.trim().isEmpty ? _fallbackReply : reply.trim();
      
      // 会話履歴に追加
      _conversationHistory.add('AI: $trimmed');
      
      final aiMessage = AiConciergeMessage(
        text: trimmed,
        isUser: false,
        timestamp: DateTime.now(),
      );
      final updated = List<AiConciergeMessage>.from(
        state.valueOrNull ?? <AiConciergeMessage>[],
      )..add(aiMessage);
      state = AsyncValue.data(updated);
    } catch (error, stackTrace) {
      log('AI reply failed', error: error, stackTrace: stackTrace);
      final failureMessage = AiConciergeMessage(
        text: _fallbackReply,
        isUser: false,
        timestamp: DateTime.now(),
      );
      final updated = List<AiConciergeMessage>.from(
        state.valueOrNull ?? <AiConciergeMessage>[],
      )..add(failureMessage);
      state = AsyncValue.data(updated);
    }
  }

  Future<List<AiConciergeMessage>> _createInitialConversation() async {
    try {
      final greeting = await _generateGreeting();
      final message = AiConciergeMessage(
        text: greeting.trim().isEmpty ? _fallbackGreeting : greeting.trim(),
        isUser: false,
        timestamp: DateTime.now(),
      );
      
      // 会話履歴に追加
      _conversationHistory.add('AI: ${message.text}');
      
      return <AiConciergeMessage>[message];
    } catch (error, stackTrace) {
      log('AI greeting failed', error: error, stackTrace: stackTrace);
      return <AiConciergeMessage>[
        AiConciergeMessage(
          text: _fallbackGreeting,
          isUser: false,
          timestamp: DateTime.now(),
        ),
      ];
    }
  }

  Future<String> _generateGreeting() async {
    try {
      final greeting = await _aiManager.generateChatResponse(
        'こんにちは',
        systemPrompt: 'あなたはMinQのAIコンシェルジュです。ユーザーに親しみやすい挨拶をしてください。',
        maxTokens: 50,
      );
      return greeting.isNotEmpty ? greeting : _fallbackGreeting;
    } catch (error) {
      log('AI greeting generation failed: $error');
      return _fallbackGreeting;
    }
  }

  /// 感情分析の実行
  Future<void> analyzeSentiment(String text) async {
    try {
      final result = await _aiManager.analyzeSentiment(text);
      log('感情分析結果: ${result.dominantSentiment.name}');
    } catch (e) {
      log('感情分析エラー: $e');
    }
  }

  /// 習慣推薦の取得
  Future<List<String>> getHabitRecommendations() async {
    try {
      final recommendations = await _aiManager.generateHabitRecommendations(
        userHabits: [], // 実際のユーザー習慣データを渡す
        completedHabits: [], // 実際の完了習慣データを渡す
        preferences: {}, // 実際のユーザー好みデータを渡す
      );
      return recommendations.map((r) => r.title).toList();
    } catch (e) {
      log('習慣推薦エラー: $e');
      return [];
    }
  }

  /// AIモードの切り替え
  void toggleAIMode() {
    // TODO: AIモードの切り替え実装
    log('AIモードを切り替えました');
  }
}

const String _fallbackGreeting =
    'こんにちは！MinQのAIコンシェルジュです。今日も習慣づくりを頑張りましょう！';

const String _fallbackReply =
    'すみません、うまく回答できませんでした。もう少し詳しく教えていただけますか？';
