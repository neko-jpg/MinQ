import 'package:flutter/foundation.dart';
import 'package:minq/data/services/local_preferences_service.dart';

class MarketingAttributionService {
  MarketingAttributionService(this._preferences, {NowProvider? now})
      : _now = now ?? DateTime.now;

  final LocalPreferencesService _preferences;
  final NowProvider _now;

  Future<void> captureUri(Uri? uri) async {
    if (uri == null) {
      return;
    }
    final params = uri.queryParameters;
    final source = params['utm_source'] ?? '';
    final medium = params['utm_medium'] ?? '';
    final campaign = params['utm_campaign'] ?? '';
    final content = params['utm_content'] ?? '';
    final term = params['utm_term'] ?? '';

    if ([source, medium, campaign, content, term]
        .every((element) => element.isEmpty)) {
      return;
    }

    debugPrint('Captured marketing attribution: $params');
    await _preferences.saveAttribution(<String, String>{
      'source': source,
      'medium': medium,
      'campaign': campaign,
      'content': content,
      'term': term,
      'captured_at_epoch':
          _now().toUtc().millisecondsSinceEpoch.toString(),
    });
  }
}
