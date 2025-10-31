import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:minq/domain/notification/notification_analytics.dart';
import 'package:minq/domain/notification/notification_settings.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 行動学習サービス
class BehaviorLearningService {
  static const String _behaviorDataKey = 'behavior_learning_data';
  static const String _timingAnalysisKey = 'timing_analysis_data';

  final SharedPreferences _prefs;

  BehaviorLearningService({
    required SharedPreferences prefs,
  }) : _prefs = prefs;

  /// 初期化
  Future<void> initialize() async {
    debugPrint('BehaviorLearningService initialized');
  }

  /// 通知送信を記録
  Future<void> recordNotificationSent(NotificationContext context) async {
    final data = await _getBehaviorData(context.userId);
    
    data['notifications_sent'] = (data['notifications_sent'] as int? ?? 0) + 1;
    data['last_notification_sent'] = context.timestamp.toIso8601String();
    
    // カテゴリ別統計
    final categoryKey = 'category_${context.category.id}_sent';
    data[categoryKey] = (data[categoryKey] as int? ?? 0) + 1;
    
    // 時間帯別統計
    final hourKey = 'hour_${context.timestamp.hour}_sent';
    data[hourKey] = (data[hourKey] as int? ?? 0) + 1;
    
    // 曜日別統計
    final dayKey = 'day_${context.timestamp.weekday}_sent';
    data[dayKey] = (data[dayKey] as int? ?? 0) + 1;

    await _saveBehaviorData(context.userId, data);
  }

  /// 通知開封を記録
  Future<void> recordNotificationOpened(
    String userId,
    NotificationCategory category,
    DateTime timestamp,
  ) async {
    final data = await _getBehaviorData(userId);
    
    data['notifications_opened'] = (data['notifications_opened'] as int? ?? 0) + 1;
    data['last_notification_opened'] = timestamp.toIso8601String();
    
    // カテゴリ別統計
    final categoryKey = 'category_${category.id}_opened';
    data[categoryKey] = (data[categoryKey] as int? ?? 0) + 1;
    
    // 時間帯別統計
    final hourKey = 'hour_${timestamp.hour}_opened';
    data[hourKey] = (data[hourKey] as int? ?? 0) + 1;
    
    // 曜日別統計
    final dayKey = 'day_${timestamp.weekday}_opened';
    data[dayKey] = (data[dayKey] as int? ?? 0) + 1;

    await _saveBehaviorData(userId, data);
    
    // 最適タイミング分析を更新
    await _updateOptimalTimingAnalysis(userId, category, timestamp);
  }

  /// アプリ使用を記録
  Future<void> recordAppUsage(String userId, DateTime timestamp) async {
    final data = await _getBehaviorData(userId);
    
    data['app_sessions'] = (data['app_sessions'] as int? ?? 0) + 1;
    data['last_app_usage'] = timestamp.toIso8601String();
    
    // 時間帯別アクティビティ
    final hourKey = 'hour_${timestamp.hour}_active';
    data[hourKey] = (data[hourKey] as int? ?? 0) + 1;
    
    // 曜日別アクティビティ
    final dayKey = 'day_${timestamp.weekday}_active';
    data[dayKey] = (data[dayKey] as int? ?? 0) + 1;

    await _saveBehaviorData(userId, data);
  }

  /// 行動データを取得
  Future<Map<String, dynamic>> _getBehaviorData(String userId) async {
    final key = '${_behaviorDataKey}_$userId';
    final dataJson = _prefs.getString(key) ?? '{}';
    
    try {
      return Map<String, dynamic>.from(jsonDecode(dataJson));
    } catch (e) {
      debugPrint('Failed to parse behavior data: $e');
      return <String, dynamic>{};
    }
  }

  /// 行動データを保存
  Future<void> _saveBehaviorData(String userId, Map<String, dynamic> data) async {
    final key = '${_behaviorDataKey}_$userId';
    data['updated_at'] = DateTime.now().toIso8601String();
    
    try {
      await _prefs.setString(key, jsonEncode(data));
    } catch (e) {
      debugPrint('Failed to save behavior data: $e');
    }
  }

  /// 最適タイミング分析を取得
  Future<OptimalTimingAnalysis?> getOptimalTiming(
    String userId,
    NotificationCategory category,
  ) async {
    final key = '${_timingAnalysisKey}_${userId}_${category.id}';
    final analysisJson = _prefs.getString(key);
    
    if (analysisJson == null) return null;
    
    try {
      final analysisMap = jsonDecode(analysisJson) as Map<String, dynamic>;
      return OptimalTimingAnalysis.fromJson(analysisMap);
    } catch (e) {
      debugPrint('Failed to parse timing analysis: $e');
      return null;
    }
  }

  /// 最適タイミング分析を更新
  Future<void> _updateOptimalTimingAnalysis(
    String userId,
    NotificationCategory category,
    DateTime timestamp,
  ) async {
    final behaviorData = await _getBehaviorData(userId);
    
    // 時間帯別エンゲージメント率を計算
    final hourlyEngagementRates = <String, double>{};
    final dailyEngagementRates = <String, double>{};
    
    for (var hour = 0; hour < 24; hour++) {
      final sentKey = 'hour_${hour}_sent';
      final openedKey = 'hour_${hour}_opened';
      
      final sent = behaviorData[sentKey] as int? ?? 0;
      final opened = behaviorData[openedKey] as int? ?? 0;
      
      final engagementRate = sent > 0 ? opened / sent : 0.0;
      hourlyEngagementRates[hour.toString()] = engagementRate;
    }
    
    for (var day = 1; day <= 7; day++) {
      final sentKey = 'day_${day}_sent';
      final openedKey = 'day_${day}_opened';
      
      final sent = behaviorData[sentKey] as int? ?? 0;
      final opened = behaviorData[openedKey] as int? ?? 0;
      
      final engagementRate = sent > 0 ? opened / sent : 0.0;
      dailyEngagementRates[day.toString()] = engagementRate;
    }
    
    // 最適な時間帯を特定
    final averageHourlyEngagement = hourlyEngagementRates.values.isNotEmpty
        ? hourlyEngagementRates.values.reduce((a, b) => a + b) / hourlyEngagementRates.length
        : 0.0;
    
    final optimalHours = hourlyEngagementRates.entries
        .where((entry) => entry.value >= averageHourlyEngagement && entry.value > 0.1)
        .map((entry) => int.parse(entry.key))
        .toList()
      ..sort();
    
    // 最適な曜日を特定
    final averageDailyEngagement = dailyEngagementRates.values.isNotEmpty
        ? dailyEngagementRates.values.reduce((a, b) => a + b) / dailyEngagementRates.length
        : 0.0;
    
    final optimalDaysOfWeek = dailyEngagementRates.entries
        .where((entry) => entry.value >= averageDailyEngagement && entry.value > 0.1)
        .map((entry) => int.parse(entry.key))
        .toList()
      ..sort();
    
    // サンプル数を計算
    final totalSent = behaviorData['notifications_sent'] as int? ?? 0;
    final totalOpened = behaviorData['notifications_opened'] as int? ?? 0;
    
    // 信頼度を計算
    final confidence = _calculateConfidence(totalSent, totalOpened);
    
    final analysis = OptimalTimingAnalysis(
      userId: userId,
      category: category,
      analyzedAt: DateTime.now(),
      optimalHours: optimalHours,
      optimalDaysOfWeek: optimalDaysOfWeek,
      confidence: confidence,
      sampleSize: totalSent,
      hourlyEngagementRates: hourlyEngagementRates,
      dailyEngagementRates: dailyEngagementRates,
    );
    
    // 分析結果を保存
    final key = '${_timingAnalysisKey}_${userId}_${category.id}';
    await _prefs.setString(key, jsonEncode(analysis.toJson()));
  }

  /// 行動パターン分析を取得
  Future<BehaviorPatternAnalysis?> getBehaviorPattern(String userId) async {
    final behaviorData = await _getBehaviorData(userId);
    
    if (behaviorData.isEmpty) return null;
    
    // アクティブな時間帯を特定
    final activeHours = <String>[];
    var maxActivity = 0;
    
    for (var hour = 0; hour < 24; hour++) {
      final activityKey = 'hour_${hour}_active';
      final activity = behaviorData[activityKey] as int? ?? 0;
      maxActivity = math.max(maxActivity, activity);
    }
    
    final activityThreshold = maxActivity * 0.3; // 30%以上のアクティビティ
    
    for (var hour = 0; hour < 24; hour++) {
      final activityKey = 'hour_${hour}_active';
      final activity = behaviorData[activityKey] as int? ?? 0;
      
      if (activity >= activityThreshold) {
        activeHours.add('${hour.toString().padLeft(2, '0')}:00');
      }
    }
    
    // 好みのカテゴリを特定
    final categoryPreferences = <String, double>{};
    final preferredCategories = <String>[];
    
    for (final category in NotificationCategory.values) {
      final sentKey = 'category_${category.id}_sent';
      final openedKey = 'category_${category.id}_opened';
      
      final sent = behaviorData[sentKey] as int? ?? 0;
      final opened = behaviorData[openedKey] as int? ?? 0;
      
      final preference = sent > 0 ? opened / sent : 0.0;
      categoryPreferences[category.id] = preference;
      
      if (preference > 0.5) { // 50%以上の開封率
        preferredCategories.add(category.displayName);
      }
    }
    
    // エンゲージメント傾向を計算
    final totalSent = behaviorData['notifications_sent'] as int? ?? 0;
    final totalOpened = behaviorData['notifications_opened'] as int? ?? 0;
    final engagementTrend = totalSent > 0 ? totalOpened / totalSent : 0.0;
    
    // 応答性スコアを計算
    final responsiveness = _calculateResponsiveness(behaviorData);
    
    // 平均応答時間を計算（簡略化）
    const averageResponseTime = Duration(minutes: 15);
    
    // タイミング好みを計算
    final timingPreferences = <String, double>{};
    for (var hour = 0; hour < 24; hour++) {
      final openedKey = 'hour_${hour}_opened';
      final opened = behaviorData[openedKey] as int? ?? 0;
      timingPreferences[hour.toString()] = opened.toDouble();
    }
    
    return BehaviorPatternAnalysis(
      userId: userId,
      analyzedAt: DateTime.now(),
      activeHours: activeHours,
      preferredCategories: preferredCategories,
      engagementTrend: engagementTrend,
      responsiveness: responsiveness,
      averageResponseTime: averageResponseTime,
      categoryPreferences: categoryPreferences,
      timingPreferences: timingPreferences,
    );
  }

  /// 信頼度を計算
  double _calculateConfidence(int totalSent, int totalOpened) {
    if (totalSent < 10) return 0.0;
    if (totalSent < 30) return 0.3;
    if (totalSent < 50) return 0.6;
    if (totalSent < 100) return 0.8;
    return 1.0;
  }

  /// 応答性スコアを計算
  double _calculateResponsiveness(Map<String, dynamic> behaviorData) {
    final totalSent = behaviorData['notifications_sent'] as int? ?? 0;
    final totalOpened = behaviorData['notifications_opened'] as int? ?? 0;
    final appSessions = behaviorData['app_sessions'] as int? ?? 0;
    
    if (totalSent == 0) return 0.0;
    
    final openRate = totalOpened / totalSent;
    final sessionRate = appSessions > 0 ? totalOpened / appSessions : 0.0;
    
    // 開封率とセッション率を組み合わせて応答性を計算
    return (openRate * 0.7 + sessionRate * 0.3).clamp(0.0, 1.0);
  }

  /// 学習データをリセット
  Future<void> resetLearningData(String userId) async {
    final behaviorKey = '${_behaviorDataKey}_$userId';
    await _prefs.remove(behaviorKey);
    
    // 全カテゴリの分析データをリセット
    for (final category in NotificationCategory.values) {
      final timingKey = '${_timingAnalysisKey}_${userId}_${category.id}';
      await _prefs.remove(timingKey);
    }
    
    debugPrint('Reset learning data for user: $userId');
  }

  /// 学習データをエクスポート
  Future<Map<String, dynamic>> exportLearningData(String userId) async {
    final behaviorData = await _getBehaviorData(userId);
    final timingAnalyses = <String, dynamic>{};
    
    for (final category in NotificationCategory.values) {
      final analysis = await getOptimalTiming(userId, category);
      if (analysis != null) {
        timingAnalyses[category.id] = analysis.toJson();
      }
    }
    
    return {
      'behavior_data': behaviorData,
      'timing_analyses': timingAnalyses,
      'exported_at': DateTime.now().toIso8601String(),
    };
  }

  /// 学習データをインポート
  Future<void> importLearningData(String userId, Map<String, dynamic> data) async {
    try {
      // 行動データをインポート
      final behaviorData = data['behavior_data'] as Map<String, dynamic>?;
      if (behaviorData != null) {
        await _saveBehaviorData(userId, behaviorData);
      }
      
      // タイミング分析データをインポート
      final timingAnalyses = data['timing_analyses'] as Map<String, dynamic>?;
      if (timingAnalyses != null) {
        for (final entry in timingAnalyses.entries) {
          final categoryId = entry.key;
          final analysisData = entry.value as Map<String, dynamic>;
          
          final key = '${_timingAnalysisKey}_${userId}_$categoryId';
          await _prefs.setString(key, jsonEncode(analysisData));
        }
      }
      
      debugPrint('Imported learning data for user: $userId');
    } catch (e) {
      debugPrint('Failed to import learning data: $e');
    }
  }

  /// データをクリーンアップ
  Future<void> cleanup() async {
    // 古い学習データを削除（90日以上前）
    final cutoffDate = DateTime.now().subtract(const Duration(days: 90));
    
    final keys = _prefs.getKeys().where((key) => 
        key.startsWith(_behaviorDataKey) || key.startsWith(_timingAnalysisKey));
    
    for (final key in keys) {
      try {
        final dataJson = _prefs.getString(key);
        if (dataJson != null) {
          final data = jsonDecode(dataJson) as Map<String, dynamic>;
          final updatedAtStr = data['updated_at'] as String?;
          
          if (updatedAtStr != null) {
            final updatedAt = DateTime.parse(updatedAtStr);
            if (updatedAt.isBefore(cutoffDate)) {
              await _prefs.remove(key);
              debugPrint('Removed old learning data: $key');
            }
          }
        }
      } catch (e) {
        debugPrint('Failed to cleanup learning data for key $key: $e');
      }
    }
  }
}