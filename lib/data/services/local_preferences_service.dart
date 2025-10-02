import 'package:shared_preferences/shared_preferences.dart';

import 'package:minq/domain/home/home_view_data.dart';
import 'package:minq/domain/stats/stats_view_data.dart';

typedef NowProvider = DateTime Function();

/// Stores lightweight privacy/safety related flags locally.
class LocalPreferencesService {
  LocalPreferencesService({NowProvider? now})
      : _prefsFuture = SharedPreferences.getInstance(),
        _now = now ?? DateTime.now;

  static const String _pairGuidelinesKey = 'pair_guidelines_seen_v1';
  static const String _reportHistoryKey = 'report_history_v1';
  static const String _preferredLocaleKey = 'preferred_locale_v1';
  static const String _npsScoreKey = 'nps_score_v1';
  static const String _npsCommentKey = 'nps_comment_v1';
  static const String _npsRecordedAtKey = 'nps_recorded_at_v1';
  static const String _utmSourceKey = 'utm_source_v1';
  static const String _utmMediumKey = 'utm_medium_v1';
  static const String _utmCampaignKey = 'utm_campaign_v1';
  static const String _utmContentKey = 'utm_content_v1';
  static const String _utmTermKey = 'utm_term_v1';
  static const String _utmCapturedAtKey = 'utm_captured_at_v1';
  static const String _cloudBackupKey = 'cloud_backup_enabled_v1';
  static const String _dummyDataModeKey = 'dummy_data_mode_enabled_v1';
  static const String _notificationEducationKey =
      'notification_permission_education_v1';
  static const String _inAppReviewPromptedAtKey =
      'in_app_review_prompted_at_v1';
  static const String _homeViewCacheKey = 'home_view_cache_v1';
  static const String _statsViewCacheKey = 'stats_view_cache_v1';

  final Future<SharedPreferences> _prefsFuture;
  final NowProvider _now;

  Future<bool> isDummyDataModeEnabled() async {
    final prefs = await _prefsFuture;
    return prefs.getBool(_dummyDataModeKey) ?? false;
  }

  Future<void> setDummyDataMode(bool enabled) async {
    final prefs = await _prefsFuture;
    await prefs.setBool(_dummyDataModeKey, enabled);
  }

  Future<bool> hasShownNotificationEducation() async {
    final prefs = await _prefsFuture;
    return prefs.getBool(_notificationEducationKey) ?? false;
  }

  Future<void> markNotificationEducationShown() async {
    final prefs = await _prefsFuture;
    await prefs.setBool(_notificationEducationKey, true);
  }

  Future<DateTime?> lastInAppReviewPromptedAt() async {
    final prefs = await _prefsFuture;
    final millis = prefs.getInt(_inAppReviewPromptedAtKey);
    if (millis == null || millis <= 0) {
      return null;
    }
    return DateTime.fromMillisecondsSinceEpoch(millis, isUtc: true).toLocal();
  }

  Future<void> recordInAppReviewPrompt(DateTime when) async {
    final prefs = await _prefsFuture;
    await prefs.setInt(
      _inAppReviewPromptedAtKey,
      when.toUtc().millisecondsSinceEpoch,
    );
  }

  Future<bool> hasSeenPairGuidelines() async {
    final prefs = await _prefsFuture;
    return prefs.getBool(_pairGuidelinesKey) ?? false;
  }

  Future<void> markPairGuidelinesSeen() async {
    final prefs = await _prefsFuture;
    await prefs.setBool(_pairGuidelinesKey, true);
  }

  /// Records a report submission and enforces a rate limit.
  ///
  /// Returns the required wait time if the action is rate limited.
  Future<Duration?> registerReportAttempt({
    int maxReports = 3,
    Duration window = const Duration(minutes: 10),
    DateTime? now,
  }) async {
    final prefs = await _prefsFuture;
    final currentTime = (now ?? _now()).toUtc();
    final cutoff = currentTime.subtract(window);

    final stored = prefs.getStringList(_reportHistoryKey) ?? <String>[];
    final timestamps = stored
        .map((String value) => DateTime.fromMillisecondsSinceEpoch(
              int.tryParse(value) ?? 0,
              isUtc: true,
            ))
        .where((DateTime timestamp) => timestamp.isAfter(cutoff))
        .toList()
      ..sort();

    if (timestamps.length >= maxReports) {
      final earliest = timestamps.first;
      final retryAfter = window - currentTime.difference(earliest);
      await prefs.setStringList(
        _reportHistoryKey,
        timestamps
            .map((DateTime ts) => ts.millisecondsSinceEpoch.toString())
            .toList(),
      );
      return retryAfter.isNegative ? Duration.zero : retryAfter;
    }

    timestamps.add(currentTime);
    await prefs.setStringList(
      _reportHistoryKey,
      timestamps
          .map((DateTime ts) => ts.millisecondsSinceEpoch.toString())
          .toList(),
    );
    return null;
  }

  Future<void> clearReportHistory() async {
    final prefs = await _prefsFuture;
    await prefs.remove(_reportHistoryKey);
  }

  Future<bool> isCloudBackupEnabled() async {
    final prefs = await _prefsFuture;
    return prefs.getBool(_cloudBackupKey) ?? false;
  }

  Future<void> setCloudBackupEnabled(bool enabled) async {
    final prefs = await _prefsFuture;
    await prefs.setBool(_cloudBackupKey, enabled);
  }

  Future<void> setPreferredLocale(String? localeTag) async {
    final prefs = await _prefsFuture;
    if (localeTag == null || localeTag.isEmpty) {
      await prefs.remove(_preferredLocaleKey);
      return;
    }
    await prefs.setString(_preferredLocaleKey, localeTag);
  }

  Future<String?> getPreferredLocale() async {
    final prefs = await _prefsFuture;
    final raw = prefs.getString(_preferredLocaleKey);
    if (raw == null || raw.isEmpty) {
      return null;
    }
    return raw;
  }

  Future<void> saveNpsResponse({
    required int score,
    String? comment,
    DateTime? recordedAt,
  }) async {
    final prefs = await _prefsFuture;
    await prefs.setInt(_npsScoreKey, score.clamp(0, 10));
    if (comment == null || comment.trim().isEmpty) {
      await prefs.remove(_npsCommentKey);
    } else {
      await prefs.setString(_npsCommentKey, comment.trim());
    }
    final timestamp = (recordedAt ?? _now()).toUtc().millisecondsSinceEpoch;
    await prefs.setInt(_npsRecordedAtKey, timestamp);
  }

  Future<NpsResponse?> loadNpsResponse() async {
    final prefs = await _prefsFuture;
    if (!prefs.containsKey(_npsScoreKey)) {
      return null;
    }
    final score = prefs.getInt(_npsScoreKey);
    if (score == null) {
      return null;
    }
    final comment = prefs.getString(_npsCommentKey);
    final recordedAtMillis = prefs.getInt(_npsRecordedAtKey) ?? 0;
    final recordedAt = DateTime.fromMillisecondsSinceEpoch(
      recordedAtMillis,
      isUtc: true,
    );
    return NpsResponse(score: score, comment: comment, recordedAt: recordedAt);
  }

  Future<void> saveAttribution(Map<String, String> attribution) async {
    final prefs = await _prefsFuture;
    if (attribution.isEmpty) {
      await prefs.remove(_utmSourceKey);
      await prefs.remove(_utmMediumKey);
      await prefs.remove(_utmCampaignKey);
      await prefs.remove(_utmContentKey);
      await prefs.remove(_utmTermKey);
      await prefs.remove(_utmCapturedAtKey);
      return;
    }

    await prefs.setString(_utmSourceKey, attribution['source'] ?? '');
    await prefs.setString(_utmMediumKey, attribution['medium'] ?? '');
    await prefs.setString(_utmCampaignKey, attribution['campaign'] ?? '');
    await prefs.setString(_utmContentKey, attribution['content'] ?? '');
    await prefs.setString(_utmTermKey, attribution['term'] ?? '');
    await prefs.setInt(
      _utmCapturedAtKey,
      (attribution['captured_at_epoch'] ?? '0').toIntOrZero(),
    );
  }

  Future<AttributionSnapshot?> loadAttribution() async {
    final prefs = await _prefsFuture;
    final source = prefs.getString(_utmSourceKey) ?? '';
    final medium = prefs.getString(_utmMediumKey) ?? '';
    final campaign = prefs.getString(_utmCampaignKey) ?? '';
    final content = prefs.getString(_utmContentKey) ?? '';
    final term = prefs.getString(_utmTermKey) ?? '';
    final capturedAtMillis = prefs.getInt(_utmCapturedAtKey) ?? 0;

    if ([source, medium, campaign, content, term]
        .every((element) => element.isEmpty)) {
      return null;
    }

    final capturedAt = DateTime.fromMillisecondsSinceEpoch(
      capturedAtMillis,
      isUtc: true,
    );

    return AttributionSnapshot(
      source: source,
      medium: medium,
      campaign: campaign,
      content: content,
      term: term,
      capturedAt: capturedAt,
    );
  }

  Future<void> saveHomeViewData(HomeViewData data) async {
    final prefs = await _prefsFuture;
    await prefs.setString(_homeViewCacheKey, data.toJson());
  }

  Future<HomeViewData?> loadHomeViewData() async {
    final prefs = await _prefsFuture;
    final raw = prefs.getString(_homeViewCacheKey);
    if (raw == null || raw.isEmpty) {
      return null;
    }
    try {
      return HomeViewData.fromJson(raw);
    } catch (_) {
      await prefs.remove(_homeViewCacheKey);
      return null;
    }
  }

  Future<void> saveStatsViewData(StatsViewData data) async {
    final prefs = await _prefsFuture;
    await prefs.setString(_statsViewCacheKey, data.toJson());
  }

  Future<StatsViewData?> loadStatsViewData() async {
    final prefs = await _prefsFuture;
    final raw = prefs.getString(_statsViewCacheKey);
    if (raw == null || raw.isEmpty) {
      return null;
    }
    try {
      return StatsViewData.fromJson(raw);
    } catch (_) {
      await prefs.remove(_statsViewCacheKey);
      return null;
    }
  }
}

class NpsResponse {
  const NpsResponse({
    required this.score,
    this.comment,
    required this.recordedAt,
  });

  final int score;
  final String? comment;
  final DateTime recordedAt;
}

class AttributionSnapshot {
  const AttributionSnapshot({
    required this.source,
    required this.medium,
    required this.campaign,
    required this.content,
    required this.term,
    required this.capturedAt,
  });

  final String source;
  final String medium;
  final String campaign;
  final String content;
  final String term;
  final DateTime capturedAt;
}

extension on String {
  int toIntOrZero() => int.tryParse(this) ?? 0;
}
