import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:miinq_integrations/miinq_integrations.dart';
import 'package:minq/data/providers.dart';
import 'package:minq/domain/support/support_message.dart';
import 'package:minq/core/ai/tflite_unified_ai_service.dart';
import 'package:minq/core/ai/tflite_unified_ai_service_provider.dart';

class SupportChatService {
  SupportChatService({
    GenerativeSupportClient? client,
    TFLiteUnifiedAIService? aiService,
  }) : _client = client,
       _aiService = aiService;

  final GenerativeSupportClient? _client;
  final TFLiteUnifiedAIService? _aiService;

  Future<SupportMessage> sendMessage({
    required String conversationId,
    required String content,
    required List<SupportMessage> history,
  }) async {
    final ai = _aiService;
    if (ai != null) {
      try {
        final historyMessages = history
            .map((message) => '${message.role}: ${message.content}')
            .toList();

        final reply = await ai.generateChatResponse(
          content,
          conversationHistory: historyMessages,
          systemPrompt: _supportSystemPrompt,
          maxTokens: 400,
        );

        final cleaned = reply.trim();
        if (cleaned.isNotEmpty) {
          return SupportMessage(role: 'assistant', content: cleaned);
        }
        return const SupportMessage(
          role: 'assistant',
          content: _supportFallback,
        );
      } catch (error, stackTrace) {
        log('AI support reply failed', error: error, stackTrace: stackTrace);
        if (_client != null) {
          return _fallbackToClient(conversationId, content, history);
        }
        return const SupportMessage(
          role: 'assistant',
          content: _supportErrorMessage,
        );
      }
    }

    if (_client != null) {
      return _fallbackToClient(conversationId, content, history);
    }

    return const SupportMessage(
      role: 'assistant',
      content: 'サポートチャットは現在利用できません。',
    );
  }

  Future<SupportMessage> _fallbackToClient(
    String conversationId,
    String content,
    List<SupportMessage> history,
  ) async {
    final reply = await _client!.generateResponse(
      conversationId: conversationId,
      messages: <Map<String, String>>[
        for (final message in history)
          <String, String>{'role': message.role, 'content': message.content},
        <String, String>{'role': 'user', 'content': content},
      ],
    );

    return SupportMessage(role: 'assistant', content: reply);
  }
}

final supportChatServiceProvider = Provider<SupportChatService?>((ref) {
  final remoteConfig = ref.watch(remoteConfigServiceProvider);
  final aiService = ref.watch(tfliteUnifiedAIServiceProvider);

  // AIが利用可能な場合は優先的に使用
  // TFLiteサービスは常にnullではないが、初期化チェックなどは内部で行われる
  return SupportChatService(aiService: aiService);
});

const String _supportSystemPrompt =
    'あなたは習慣形成アプリ「MinQ」のサポートAIです。ユーザーの不安を'
    '和らげつつ、具体的で実行しやすい提案や次のアクションを日本語で提供し'
    'てください。';

const String _supportFallback =
    '申し訳ありません。うまく回答できませんでした。もう少し詳しく教えても'
    'らえますか？';

const String _supportErrorMessage = 'エラーが発生しました。しばらくしてからもう一度お試しください。';
