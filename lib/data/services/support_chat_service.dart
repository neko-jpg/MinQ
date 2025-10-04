// TODO: Re-enable when miinq_integrations package is available
// import 'package:miinq_integrations/miinq_integrations.dart';
import 'package:minq/domain/support/support_message.dart';
import 'package:riverpod/riverpod.dart';

class SupportChatService {
  // TODO: Re-enable when miinq_integrations package is available
  // SupportChatService({required GenerativeSupportClient client}) : _client = client;
  // final GenerativeSupportClient _client;

  Future<SupportMessage> sendMessage({
    required String conversationId,
    required String content,
    required List<SupportMessage> history,
  }) async {
    // TODO: Re-enable when miinq_integrations package is available
    // final reply = await _client.generateResponse(
    //   conversationId: conversationId,
    //   messages: <Map<String, String>>[
    //     for (final message in history)
    //       <String, String>{
    //         'role': message.role,
    //         'content': message.content,
    //       },
    //     <String, String>{'role': 'user', 'content': content},
    //   ],
    // );
    // return SupportMessage(role: 'assistant', content: reply);
    
    // Temporary placeholder response
    return const SupportMessage(
      role: 'assistant',
      content: 'Support chat is currently unavailable. Please try again later.',
    );
  }
}

final supportChatServiceProvider = Provider<SupportChatService?>((ref) {
  // TODO: Re-enable when miinq_integrations package is available
  // final remoteConfig = ref.watch(remoteConfigServiceProvider);
  // final endpoint = remoteConfig.tryGetUri('support_bot_endpoint');
  // final apiKey = remoteConfig.tryGetString('support_bot_api_key');
  // if (endpoint == null || apiKey == null || apiKey.isEmpty) {
  //   return null;
  // }
  // final client = GenerativeSupportClient(
  //   httpClient: ref.watch(httpClientProvider),
  //   endpoint: endpoint.toString(),
  //   apiKey: apiKey,
  // );
  // return SupportChatService(client: client);
  
  // Temporary: return null until package is available
  return null;
});
