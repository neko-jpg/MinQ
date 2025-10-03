import 'package:miinq/data/providers.dart';
import 'package:miinq/domain/support/support_message.dart';
import 'package:miinq_integrations/miinq_integrations.dart';
import 'package:riverpod/riverpod.dart';

class SupportChatService {
  SupportChatService({required GenerativeSupportClient client}) : _client = client;

  final GenerativeSupportClient _client;

  Future<SupportMessage> sendMessage({
    required String conversationId,
    required String content,
    required List<SupportMessage> history,
  }) async {
    final reply = await _client.generateResponse(
      conversationId: conversationId,
      messages: <Map<String, String>>[
        for (final message in history)
          <String, String>{
            'role': message.role,
            'content': message.content,
          },
        <String, String>{'role': 'user', 'content': content},
      ],
    );

    return SupportMessage(role: 'assistant', content: reply);
  }
}

final supportChatServiceProvider = Provider<SupportChatService?>((ref) {
  final remoteConfig = ref.watch(remoteConfigServiceProvider);
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
  return SupportChatService(client: client);
});
