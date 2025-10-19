import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:minq/core/ai/gemma_ai_service.dart';
import 'package:minq/core/ai/lightweight_ai_service.dart';

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
  GemmaAIService? _gemma;
  final LightweightAIService _lightweightAI = LightweightAIService();
  bool _useGemma = true; // Gemma AIを有効化

  @override
  Future<List<AiConciergeMessage>> build() async {
    if (_useGemma) {
      final gemmaAsync = ref.watch(gemmaAIServiceProvider);
      _gemma = gemmaAsync.valueOrNull;
    }
    return _createInitialConversation();
  }

  Future<void> resetConversation() async {
    state = const AsyncValue.loading();
    try {
      if (_useGemma) {
        await _gemma?.reset();
      }
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

  /// Gemmaモードと軽量AIモードを切り替える
  void toggleAIMode() {
    _useGemma = !_useGemma;
    log('AI mode switched to: ${_useGemma ? 'Gemma' : 'Lightweight'}');
    resetConversation();
  }

  /// 現在のAIモードを取得
  String getCurrentAIMode() {
    return _useGemma ? 'Gemma AI' : 'Lightweight AI';
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
    try {
      String reply;
      if (_useGemma) {
        final history = _toGemmaHistory(current, dropLastUser: true);
        reply = await _generateReply(text, history);
      } else {
        reply = _lightweightAI.generateResponse(text);
      }
      
      final trimmed = reply.trim().isEmpty ? _fallbackReply : reply.trim();
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
      return <AiConciergeMessage>[message];
    } catch (error, stackTrace) {
      log('Gemma greeting failed', error: error, stackTrace: stackTrace);
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
    if (!_useGemma) {
      return _lightweightAI.generateGreeting();
    }

    final gemma = _gemma;
    if (gemma == null) {
      return _lightweightAI.generateGreeting();
    }

    try {
      final response = await gemma.generateText(
        _greetingPrompt,
        systemPrompt: _conversationGuidance,
        maxTokens: 120,
      );
      return _sanitizeResponse(response) ?? _lightweightAI.generateGreeting();
    } catch (error, stackTrace) {
      log('Gemma greeting failed', error: error, stackTrace: stackTrace);
      return _lightweightAI.generateGreeting();
    }
  }

  Future<String> _generateReply(
    String userText,
    List<GemmaChatMessage> history,
  ) async {
    if (!_useGemma) {
      return _lightweightAI.generateResponse(userText);
    }

    final gemma = _gemma;
    if (gemma == null) {
      return _lightweightAI.generateResponse(userText);
    }

    try {
      final primary = await gemma.generateText(
        userText,
        history: history,
        systemPrompt: _conversationGuidance,
        maxTokens: 320,
      );
      final sanitized = _sanitizeResponse(primary);
      if (sanitized != null && sanitized.isNotEmpty) {
        return sanitized;
      }

      final retry = await gemma.generateText(
        userText,
        history: history,
        systemPrompt: _conversationGuidance,
        maxTokens: 320,
        temperature: 0.8,
        topP: 0.9,
      );
      final retrySanitized = _sanitizeResponse(retry);
      if (retrySanitized != null && retrySanitized.isNotEmpty) {
        return retrySanitized;
      }
    } catch (error, stackTrace) {
      log('Gemma reply failed', error: error, stackTrace: stackTrace);
    }

    // Gemmaが失敗した場合は軽量AIにフォールバック
    return _lightweightAI.generateResponse(userText);
  }

  List<GemmaChatMessage> _toGemmaHistory(
    List<AiConciergeMessage> conversation, {
    bool dropLastUser = false,
  }) {
    if (conversation.isEmpty) {
      return const <GemmaChatMessage>[];
    }

    final mapped =
        conversation
            .map(
              (message) =>
                  message.isUser
                      ? GemmaChatMessage.user(message.text)
                      : GemmaChatMessage.assistant(message.text),
            )
            .toList();

    if (dropLastUser && mapped.isNotEmpty && mapped.last.isUser) {
      mapped.removeLast();
    }

    return mapped;
  }

  String? _sanitizeResponse(String response) {
    final trimmed = response.trim();
    if (trimmed.isEmpty) {
      return null;
    }

    final cleaned = _cleanResponse(trimmed);
    if (cleaned.isEmpty) {
      return null;
    }

    return cleaned;
  }

  /// Normalize the AI response text.
  String _cleanResponse(String response) {
    // 特殊トークンを除去
    var withoutTokens = response.replaceAll(
      RegExp(r'<pad>|<bos>|<eos>|<unk>|<unused\d+>|<mask>|\[multimodal\]'),
      '',
    );
    
    // 山括弧と角括弧で囲まれたトークンを除去
    withoutTokens = withoutTokens.replaceAll(RegExp(r'<[^>]*>'), '');
    withoutTokens = withoutTokens.replaceAll(RegExp(r'\[[^\]]*\]'), '');

    final lines =
        withoutTokens
            .split('\n')
            .map((line) => line.trim())
            .where((line) => line.isNotEmpty)
            .map(
              (line) => line.replaceFirst(
                RegExp(r'^(AI|Assistant|User|System)\s*[:\uFF1A]\s*'),
                '',
              ),
            )
            .where((line) => line.isNotEmpty)
            .toList();

    if (lines.isEmpty) {
      return '';
    }

    final cleaned =
        lines
            .join(' ')
            .replaceAll(RegExp(r'[<>|#`]+'), ' ')
            .replaceAll(RegExp(r'\s{2,}'), ' ')
            .trim();
    return cleaned;
  }

  String _selectGreetingFallback() {
    if (_greetingVariations.isEmpty) {
      return _fallbackGreeting;
    }
    final now = DateTime.now().millisecondsSinceEpoch;
    final index = now % _greetingVariations.length;
    return _greetingVariations[index];
  }
}

const String _greetingPrompt = '''
こんにちは！MinQのAIコンシェルジュです。今日の調子はいかがですか？
習慣づくりのお手伝いをさせていただきます。
''';

const String _conversationGuidance = '''
あなたは習慣形成アプリ「MinQ」の親しみやすいAIコンシェルジュです。
ユーザーの気持ちに寄り添い、自然な日本語で2〜3文のわかりやすい回答を返してください。
''';

const String _fallbackGreeting =
    'Hello! I am the MinQ AI concierge. How are you feeling today?';

const String _fallbackReply =
    'すみません、うまく回答できませんでした。もう少し詳しく教えていただけますか？';

const List<String> _greetingVariations = [
  'Hello! I am the MinQ AI concierge. How are you feeling today?',
  'Hi there, this is the MinQ AI concierge checking in. What shall we work on first?',
  'Welcome back! Let me know how your habits are going; I am ready to help.',
  'Great to see you again. Tell me what you would like support with right now.',
];
