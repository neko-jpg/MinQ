import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';
import 'package:minq/data/logging/minq_logger.dart';

class AnalyticsService {
  AnalyticsService(this._analytics);

  final FirebaseAnalytics? _analytics;

  // Regex to enforce verb_object naming convention (e.g., create_quest, start_pair)
  static final RegExp _eventNameRegex = RegExp(r'^[a-z]+_[a-z]+(_[a-z]+)*$');

  Future<void> logEvent(String name, {Map<String, Object>? parameters}) async {
    if (_analytics == null) {
      MinqLogger.debug('Analytics not available. Skipping event: $name');
      return;
    }

    if (!_eventNameRegex.hasMatch(name)) {
      MinqLogger.warn(
        'Invalid event name format. Should be verb_object.',
        metadata: {'eventName': name},
      );
      // In debug mode, we might want to throw an error to catch this early.
      if (kDebugMode) {
        throw ArgumentError(
          'イベント名の形式が正しくありません: "$name"。verb_object 形式（例: "create_quest"）で指定してください。',
        );
      }
      return;
    }

    try {
      await _analytics!.logEvent(
        name: name,
        parameters: parameters,
      );
      MinqLogger.info('Analytics event logged: $name', metadata: parameters);
    } catch (e, s) {
      MinqLogger.error('Failed to log analytics event: $name', exception: e, stackTrace: s);
    }
  }

  Future<void> setUserProperties({
    required String userId,
    Map<String, String>? properties,
  }) async {
    if (_analytics == null) return;

    await _analytics!.setUserId(id: userId);
    if (properties != null) {
      properties.forEach((key, value) {
        _analytics!.setUserProperty(name: key, value: value);
      });
    }
    MinqLogger.info('User properties set for analytics.', metadata: {'userId': userId, ...?properties});
  }
}