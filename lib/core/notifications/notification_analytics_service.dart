import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';
import 'package:minq/domain/notification/notification_analytics.dart';
import 'package:minq/domain/notification/notification_settings.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 通知分析サービス
class NotificationAnalyticsService {
  static const String _eventsKey = 'notification_events';
  static const String _metricsKey = 'notification_metrics';

  final SharedPreferences _prefs;
  final Isar _isar;

  final List<NotificationEvent> _eventBuffer = [];
  Timer? _flushTimer;

  NotificationAnalyticsService({
    required SharedPreferences prefs,
    required Isar isar,
  }) : _prefs = prefs,
       _isar = isar;

  /// 初期化
  Future<void> initialize() async {
    // 定期的にイベントをフラッシュ
    _flushTimer = Timer.periodic(
      const Duration(minutes: 5),
      (_) => _flushEvents(),
    );

    debugPrint('NotificationAnalyticsService initialized');
  }

  /// イベントを記録
  Future<void> recordEvent(NotificationEvent event) async {
    _eventBuffer.add(event);

    // バッファが満杯になったら即座にフラッシュ
    if (_eventBuffer.length >= 10) {
      await _flushEvents();
    }
  }

  /// イベントをストレージにフラッシュ
  Future<void> _flushEvents() async {
    if (_eventBuffer.isEmpty) return;

    try {
      // ローカルストレージに保存
      final existingEventsJson = _prefs.getString(_eventsKey) ?? '[]';
      final existingEvents =
          (jsonDecode(existingEventsJson) as List)
              .map((e) => NotificationEvent.fromJson(e as Map<String, dynamic>))
              .toList();

      existingEvents.addAll(_eventBuffer);

      // 古いイベントを削除（30日以上前）
      final cutoffDate = DateTime.now().subtract(const Duration(days: 30));
      existingEvents.removeWhere(
        (event) => event.timestamp.isBefore(cutoffDate),
      );

      // 保存
      final eventsJson = jsonEncode(
        existingEvents.map((e) => e.toJson()).toList(),
      );
      await _prefs.setString(_eventsKey, eventsJson);

      _eventBuffer.clear();
      debugPrint('Flushed ${existingEvents.length} notification events');
    } catch (e) {
      debugPrint('Failed to flush notification events: $e');
    }
  }

  /// メトリクスを計算
  Future<NotificationMetrics> getMetrics({
    required String userId,
    required NotificationCategory category,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final events = await _getEventsInRange(
      userId,
      category,
      startDate,
      endDate,
    );

    final totalSent =
        events.where((e) => e.eventType == NotificationEventType.sent).length;
    final totalDelivered =
        events
            .where((e) => e.eventType == NotificationEventType.delivered)
            .length;
    final totalOpened =
        events.where((e) => e.eventType == NotificationEventType.opened).length;
    final totalClicked =
        events
            .where((e) => e.eventType == NotificationEventType.clicked)
            .length;
    final totalDismissed =
        events
            .where((e) => e.eventType == NotificationEventType.dismissed)
            .length;
    final totalConverted =
        events
            .where((e) => e.eventType == NotificationEventType.converted)
            .length;

    final deliveryRate = totalSent > 0 ? totalDelivered / totalSent : 0.0;
    final openRate = totalDelivered > 0 ? totalOpened / totalDelivered : 0.0;
    final clickRate = totalOpened > 0 ? totalClicked / totalOpened : 0.0;
    final conversionRate = totalOpened > 0 ? totalConverted / totalOpened : 0.0;

    // 平均アクション時間を計算
    final actionEvents = events.where((e) => e.timeToAction != null);
    final averageTimeToAction =
        actionEvents.isNotEmpty
            ? Duration(
              milliseconds:
                  actionEvents
                      .map((e) => e.timeToAction!.inMilliseconds)
                      .reduce((a, b) => a + b) ~/
                  actionEvents.length,
            )
            : Duration.zero;

    // 時間別分布を計算
    final hourlyDistribution = <String, int>{};
    for (var i = 0; i < 24; i++) {
      hourlyDistribution[i.toString()] = 0;
    }
    for (final event in events) {
      final hour = event.timestamp.hour.toString();
      hourlyDistribution[hour] = (hourlyDistribution[hour] ?? 0) + 1;
    }

    // 曜日別パフォーマンスを計算
    final dayOfWeekPerformance = <String, double>{};
    for (var i = 1; i <= 7; i++) {
      final dayEvents = events.where((e) => e.timestamp.weekday == i);
      final dayOpened =
          dayEvents
              .where((e) => e.eventType == NotificationEventType.opened)
              .length;
      final dayDelivered =
          dayEvents
              .where((e) => e.eventType == NotificationEventType.delivered)
              .length;

      dayOfWeekPerformance[i.toString()] =
          dayDelivered > 0 ? dayOpened / dayDelivered : 0.0;
    }

    return NotificationMetrics(
      userId: userId,
      category: category,
      periodStart: startDate,
      periodEnd: endDate,
      totalSent: totalSent,
      totalDelivered: totalDelivered,
      totalOpened: totalOpened,
      totalClicked: totalClicked,
      totalDismissed: totalDismissed,
      totalConverted: totalConverted,
      deliveryRate: deliveryRate,
      openRate: openRate,
      clickRate: clickRate,
      conversionRate: conversionRate,
      averageTimeToAction: averageTimeToAction,
      hourlyDistribution: hourlyDistribution,
      dayOfWeekPerformance: dayOfWeekPerformance,
    );
  }

  /// 指定期間のイベントを取得
  Future<List<NotificationEvent>> _getEventsInRange(
    String userId,
    NotificationCategory category,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final eventsJson = _prefs.getString(_eventsKey) ?? '[]';
      final allEvents =
          (jsonDecode(eventsJson) as List)
              .map((e) => NotificationEvent.fromJson(e as Map<String, dynamic>))
              .toList();

      return allEvents.where((event) {
        return event.userId == userId &&
            event.category == category &&
            event.timestamp.isAfter(startDate) &&
            event.timestamp.isBefore(endDate);
      }).toList();
    } catch (e) {
      debugPrint('Failed to get events in range: $e');
      return [];
    }
  }

  /// 全カテゴリのメトリクスを取得
  Future<Map<NotificationCategory, NotificationMetrics>> getAllMetrics({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final metrics = <NotificationCategory, NotificationMetrics>{};

    for (final category in NotificationCategory.values) {
      metrics[category] = await getMetrics(
        userId: userId,
        category: category,
        startDate: startDate,
        endDate: endDate,
      );
    }

    return metrics;
  }

  /// 最適タイミング分析を実行
  Future<OptimalTimingAnalysis> analyzeOptimalTiming({
    required String userId,
    required NotificationCategory category,
  }) async {
    final endDate = DateTime.now();
    final startDate = endDate.subtract(const Duration(days: 30));

    final events = await _getEventsInRange(
      userId,
      category,
      startDate,
      endDate,
    );
    final openedEvents = events.where(
      (e) => e.eventType == NotificationEventType.opened,
    );

    // 時間別エンゲージメント率を計算
    final hourlyEngagementRates = <String, double>{};
    final hourlyStats = <int, List<bool>>{};

    for (final event in events) {
      final hour = event.timestamp.hour;
      hourlyStats[hour] ??= [];

      // 同じ通知IDの開封イベントがあるかチェック
      final wasOpened = openedEvents.any(
        (e) => e.notificationId == event.notificationId,
      );
      hourlyStats[hour]!.add(wasOpened);
    }

    for (final entry in hourlyStats.entries) {
      final hour = entry.key;
      final results = entry.value;
      final engagementRate =
          results.isNotEmpty
              ? results.where((opened) => opened).length / results.length
              : 0.0;
      hourlyEngagementRates[hour.toString()] = engagementRate;
    }

    // 最適な時間帯を特定（エンゲージメント率が平均以上）
    final averageEngagement =
        hourlyEngagementRates.values.isNotEmpty
            ? hourlyEngagementRates.values.reduce((a, b) => a + b) /
                hourlyEngagementRates.length
            : 0.0;

    final optimalHours =
        hourlyEngagementRates.entries
            .where((entry) => entry.value >= averageEngagement)
            .map((entry) => int.parse(entry.key))
            .toList()
          ..sort();

    // 曜日別エンゲージメント率を計算
    final dailyEngagementRates = <String, double>{};
    final dailyStats = <int, List<bool>>{};

    for (final event in events) {
      final dayOfWeek = event.timestamp.weekday;
      dailyStats[dayOfWeek] ??= [];

      final wasOpened = openedEvents.any(
        (e) => e.notificationId == event.notificationId,
      );
      dailyStats[dayOfWeek]!.add(wasOpened);
    }

    for (final entry in dailyStats.entries) {
      final day = entry.key;
      final results = entry.value;
      final engagementRate =
          results.isNotEmpty
              ? results.where((opened) => opened).length / results.length
              : 0.0;
      dailyEngagementRates[day.toString()] = engagementRate;
    }

    // 最適な曜日を特定
    final averageDailyEngagement =
        dailyEngagementRates.values.isNotEmpty
            ? dailyEngagementRates.values.reduce((a, b) => a + b) /
                dailyEngagementRates.length
            : 0.0;

    final optimalDaysOfWeek =
        dailyEngagementRates.entries
            .where((entry) => entry.value >= averageDailyEngagement)
            .map((entry) => int.parse(entry.key))
            .toList()
          ..sort();

    // 信頼度を計算（サンプル数に基づく）
    final sampleSize = events.length;
    final confidence = sampleSize >= 30 ? 1.0 : sampleSize / 30.0;

    return OptimalTimingAnalysis(
      userId: userId,
      category: category,
      analyzedAt: DateTime.now(),
      optimalHours: optimalHours,
      optimalDaysOfWeek: optimalDaysOfWeek,
      confidence: confidence,
      sampleSize: sampleSize,
      hourlyEngagementRates: hourlyEngagementRates,
      dailyEngagementRates: dailyEngagementRates,
    );
  }

  /// A/Bテスト結果を記録
  Future<void> recordABTestResult(NotificationABTestResult result) async {
    try {
      const key = 'ab_test_results';
      final existingResultsJson = _prefs.getString(key) ?? '[]';
      final existingResults =
          (jsonDecode(existingResultsJson) as List)
              .map(
                (e) => NotificationABTestResult.fromJson(
                  e as Map<String, dynamic>,
                ),
              )
              .toList();

      existingResults.add(result);

      // 古い結果を削除（90日以上前）
      final cutoffDate = DateTime.now().subtract(const Duration(days: 90));
      existingResults.removeWhere((r) => r.endDate.isBefore(cutoffDate));

      final resultsJson = jsonEncode(
        existingResults.map((r) => r.toJson()).toList(),
      );
      await _prefs.setString(key, resultsJson);

      debugPrint('Recorded A/B test result: ${result.testId}');
    } catch (e) {
      debugPrint('Failed to record A/B test result: $e');
    }
  }

  /// データをクリーンアップ
  Future<void> cleanup() async {
    await _flushEvents();

    // 古いデータを削除
    final cutoffDate = DateTime.now().subtract(const Duration(days: 30));

    try {
      final eventsJson = _prefs.getString(_eventsKey) ?? '[]';
      final events =
          (jsonDecode(eventsJson) as List)
              .map((e) => NotificationEvent.fromJson(e as Map<String, dynamic>))
              .where((event) => event.timestamp.isAfter(cutoffDate))
              .toList();

      final cleanedEventsJson = jsonEncode(
        events.map((e) => e.toJson()).toList(),
      );
      await _prefs.setString(_eventsKey, cleanedEventsJson);

      debugPrint('Cleaned up notification analytics data');
    } catch (e) {
      debugPrint('Failed to cleanup notification analytics data: $e');
    }
  }

  /// リソースを解放
  void dispose() {
    _flushTimer?.cancel();
    _flushEvents();
  }
}
