import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:miinq/config/stripe_config.dart';
import 'package:miinq/data/providers.dart';
import 'package:miinq/domain/support/tip_option.dart';
import 'package:riverpod/riverpod.dart';

class TipJarService {
  TipJarService({
    required this.client,
    required this.tipEndpoint,
  });

  final http.Client client;
  final Uri tipEndpoint;

  Future<List<TipOption>> fetchTipOptions() async {
    final response = await client.get(tipEndpoint);
    if (response.statusCode >= 300) {
      throw Exception('Failed to load tip options');
    }
    final decoded = jsonDecode(response.body) as List<dynamic>;
    return decoded
        .map((dynamic raw) => TipOption(
              id: raw['id'] as String,
              label: raw['label'] as String,
              amount: (raw['amount'] as num).toInt(),
            ))
        .toList();
  }

  Future<Uri> createTipCheckout(String optionId) async {
    final response = await client.post(
      tipEndpoint,
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode(<String, dynamic>{'optionId': optionId}),
    );
    if (response.statusCode >= 300) {
      throw Exception('Failed to create tip checkout session');
    }
    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    final url = decoded['checkoutUrl'] as String?;
    if (url == null || url.isEmpty) {
      throw Exception('Tip checkout URL was missing');
    }
    return Uri.parse(url);
  }
}

final tipJarServiceProvider = Provider<TipJarService?>((ref) {
  final config = StripeConfig.maybeFromRemoteConfig(
    ref.watch(remoteConfigServiceProvider),
  );
  final tipEndpoint = config?.tipEndpoint;
  if (tipEndpoint == null) {
    return null;
  }
  return TipJarService(
    client: ref.watch(httpClientProvider),
    tipEndpoint: tipEndpoint,
  );
});
