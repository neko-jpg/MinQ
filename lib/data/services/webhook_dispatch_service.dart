import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:minq/core/logging/app_logger.dart';
import 'package:minq/data/services/local_preferences_service.dart';
import 'package:minq/domain/log/quest_log.dart';
import 'package:minq/domain/quest/quest.dart';

class WebhookDispatchService {
  WebhookDispatchService({
    required this.client,
    required this.preferences,
    required this.logger,
  });

  final http.Client client;
  final LocalPreferencesService preferences;
  final AppLogger logger;

  Future<List<Uri>> loadEndpoints() async {
    final stored = await preferences.loadWebhookEndpoints();
    return stored
        .map((endpoint) => Uri.tryParse(endpoint.trim()))
        .where((uri) => uri != null && uri.hasScheme)
        .cast<Uri>()
        .toList(growable: false);
  }

  Future<void> saveEndpoints(List<String> endpoints) async {
    await preferences.saveWebhookEndpoints(endpoints);
  }

  Future<void> dispatchQuestCompletion({
    required Quest quest,
    required QuestLog log,
  }) async {
    final endpoints = await loadEndpoints();
    if (endpoints.isEmpty) {
      return;
    }

    final payload = <String, dynamic>{
      'event': 'quest_completed',
      'questId': quest.id,
      'questTitle': quest.title,
      'questCategory': quest.category,
      'questEstimatedMinutes': quest.estimatedMinutes,
      'completedAt': log.ts.toIso8601String(),
      'proofType': log.proofType,
      'proofValue': log.proofValue,
    };

    for (final endpoint in endpoints) {
      try {
        logger.logApiRequest('POST', endpoint.toString(), body: payload);
        final response = await client.post(
          endpoint,
          headers: const {
            'Content-Type': 'application/json',
            'User-Agent': 'MinQWebhookBot/1.0',
          },
          body: jsonEncode(payload),
        );
        logger.logApiResponse(
          'POST',
          endpoint.toString(),
          response.statusCode,
          body: response.body,
        );
      } catch (error, stackTrace) {
        logger.warning(
          'Failed to dispatch webhook',
          error,
          stackTrace,
        );
      }
    }
  }
}
