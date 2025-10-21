import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:miinq_integrations/miinq_integrations.dart';
import 'package:minq/core/ai/gemma_ai_service.dart';
import 'package:minq/data/providers.dart';
import 'package:minq/data/providers/gemma_ai_provider.dart';
import 'package:minq/domain/support/support_message.dart';

class SupportChatService {
  SupportChatService({
    GenerativeSupportClient? client,
    GemmaAIService? gemmaService,
  }) : _client = client,
       _gemmaService = gemmaService;

  final GenerativeSupportClient? _client;
  final GemmaAIService? _gemmaService;

  Future<SupportMessage> sendMessage({
    required String conversationId,
    required String content,
    required List<SupportMessage> history,
  }) async {
    final gemma = _gemmaService;
    if (gemma != null) {
      try {
        final historyMessages =
            history
                .map(
                  (message) => GemmaChatMessage(
                    role:
                        message.role == 'user'
                            ? GemmaChatRole.user
                            : GemmaChatRole.assistant,
                    content: message.content,
                  ),
                )
                .toList();

        final reply = await gemma.generateText(
          content,
          history: historyMessages,
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
        log('Gemma support reply failed', error: error, stackTrace: stackTrace);
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
  final gemmaServiceAsync = ref.watch(gemmaAIServiceProvider);
  final gemmaService = gemmaServiceAsync.valueOrNull;

  // Gemma AIが利用可能な場合は優先的に使用
  if (gemmaService != null) {
    return SupportChatService(gemmaService: gemmaService);
  }

  // フォールバック: 従来のクライアント
  final endpoint = remoteConfig.tryGetUri('support_bot_endpoint');
  final apiKey = remoteConfig.tryGetString('support_bot_api_key');
  if (endpoint == null || apiKey == null || apiKey.isEmpty) {
    return null;
  }

  final client = GenerativeSupportClient(
    httpClient: ref.watch(httpClientProvider),
    endpoint: endpoint.toString(),
    apiKey: apiKey,
  );
  return SupportChatService(client: client, gemmaService: gemmaService);
});

const String _supportSystemPrompt =
    'あなたは習慣形成アプリ「MinQ」のサポートAI Gemma です。ユーザーの不安を'
    '和らげつつ、具体的で実行しやすい提案や次のアクションを日本語で提供し'
    'てください。';

const String _supportFallback =
    '申し訳ありません。うまく回答できませんでした。もう少し詳しく教えても'
    'らえますか？';

const String _supportErrorMessage = 'エラーが発生しました。しばらくしてからもう一度お試しください。';
