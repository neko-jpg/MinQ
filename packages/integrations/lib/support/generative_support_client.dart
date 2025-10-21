import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:meta/meta.dart';

/// Lightweight API client for the GPT-4o Mini support bot endpoint.
class GenerativeSupportClient {
  /// Creates a new [GenerativeSupportClient].
  GenerativeSupportClient({
    required http.Client httpClient,
    required String endpoint,
    required String apiKey,
  })  : _httpClient = httpClient,
        _endpoint = endpoint,
        _apiKey = apiKey;

  final http.Client _httpClient;
  final String _endpoint;
  final String _apiKey;

  /// Generates a response from the support bot.
  Future<String> generateResponse({
    required String conversationId,
    required List<Map<String, String>> messages,
  }) async {
    final response = await _httpClient.post(
      Uri.parse(_endpoint),
      headers: <String, String>{
        'Authorization': 'Bearer $_apiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(<String, dynamic>{
        'conversationId': conversationId,
        'messages': messages,
        'model': 'gpt-4o-mini',
        'temperature': 0.5,
      }),
    );

    if (response.statusCode >= 400) {
      throw GenerativeSupportException(
        'Failed to fetch support response (${response.statusCode})',
      );
    }

    final payload = jsonDecode(response.body) as Map<String, dynamic>;
    final reply = payload['reply'] as String?;
    if (reply == null || reply.isEmpty) {
      throw const GenerativeSupportException('Empty response from support bot');
    }
    return reply;
  }
}

/// An exception thrown by the [GenerativeSupportClient].
@immutable
class GenerativeSupportException implements Exception {
  /// Creates a new [GenerativeSupportException].
  const GenerativeSupportException(this.message);

  /// The error message.
  final String message;

  @override
  String toString() => 'GenerativeSupportException: $message';
}
