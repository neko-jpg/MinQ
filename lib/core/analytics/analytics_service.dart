import 'package:flutter/foundation.dart';

/// Minimal analytics facade used by core monitoring utilities.
class AnalyticsService {
  const AnalyticsService();

  Future<void> trackEvent(
    String name, [
    Map<String, dynamic>? properties,
  ]) async {
    debugPrint('AnalyticsService.trackEvent → $name ${properties ?? {}}');
  }

  Future<void> trackError(
    String name, [
    Map<String, dynamic>? details,
  ]) async {
    debugPrint('AnalyticsService.trackError → $name ${details ?? {}}');
  }
}
