import 'dart:developer';

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:minq/core/ai/ai_integration_manager.dart';
import 'package:minq/data/providers.dart';
import 'package:minq/presentation/controllers/home_data_controller.dart';

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

final aiConciergeChatControllerProvider = AutoDisposeAsyncNotifierProvider<
  AiConciergeChatController,
  List<AiConciergeMessage>
>(AiConciergeChatController.new);

class AiConciergeChatController
    extends AutoDisposeAsyncNotifier<List<AiConciergeMessage>> {
  AiConciergeChatController();

  final AIIntegrationManager _aiManager = AIIntegrationManager.instance;
  final List<String> _conversationHistory = <String>[];

  @override
  Future<List<AiConciergeMessage>> build() async {
    try {
      final uid = ref.watch(uidProvider);
      await _aiManager.initialize(userId: uid ?? 'guest');
    } catch (error, stackTrace) {
      log('AI init failed', error: error, stackTrace: stackTrace);
    }
    return <AiConciergeMessage>[_initialGreeting()];
  }

  Future<void> resetConversation() async {
    state = const AsyncValue.loading();
    _conversationHistory.clear();
    state = AsyncValue.data(<AiConciergeMessage>[_initialGreeting()]);
  }

  String getCurrentAIMode() => 'オフラインAIコーチ';

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
    _conversationHistory.add('USER: $message');

    final reply = await _generateReply(message);
    _conversationHistory.add('AI: $reply');

    final updated = List<AiConciergeMessage>.from(
      state.valueOrNull ?? <AiConciergeMessage>[],
    )..add(
      AiConciergeMessage(text: reply, isUser: false, timestamp: DateTime.now()),
    );
    state = AsyncValue.data(updated);
  }

  AiConciergeMessage _initialGreeting() {
    final greeting = _buildGreeting();
    _conversationHistory.add('AI: $greeting');
    return AiConciergeMessage(
      text: greeting,
      isUser: false,
      timestamp: DateTime.now(),
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
      return 'おかえりなさい！現在 ${streak} 日連続で達成しています。今日も一歩ずつ進めていきましょう。';
    }
    return 'はじめまして！まずはシンプルなクエストから肩慣らししてみましょう。';
  }

  Future<String> _generateReply(String userMessage) async {
    try {
      final reply = await _aiManager.generateChatResponse(
        userMessage,
        conversationHistory: _conversationHistory.take(8).toList(),
        systemPrompt:
            'You are a supportive Japanese habit coach for the MinQ app. '
            'Respond in Japanese with short encouragement and a clear next action. '
            'Keep responses under 120 Japanese characters.',
        maxTokens: 150,
      );
      final trimmed = reply.trim();
      if (trimmed.isNotEmpty) {
        return trimmed;
      }
    } catch (error, stackTrace) {
      log('AI reply failed', error: error, stackTrace: stackTrace);
    }
    return _fallbackHeuristic(userMessage);
  }

  String _fallbackHeuristic(String userMessage) {
    final homeData = ref.read(homeDataProvider).valueOrNull;
    final focus = homeData?.focus;
    final questTitle =
        focus?.questTitle ?? homeData?.quests.firstOrNull?.title ?? 'MiniQuest';

    final completionsToday = homeData?.completionsToday ?? 0;
    final encouragement =
        completionsToday > 0
            ? 'すでに今日 ${completionsToday} 件進んでいます。この勢いで続けていきましょう。'
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
