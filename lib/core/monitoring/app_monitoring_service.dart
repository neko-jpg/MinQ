import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_performance/firebase_performance.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:minq/core/logging/app_logger.dart';

/// アプリ監視サービス
///
/// 稼働状況、パフォーマンス、エラーを監視し、
/// 重大なイベントを検出・通知する
class AppMonitoringService {
  final FirebaseAnalytics _analytics;
  final FirebaseCrashlytics _crashlytics;
  final FirebasePerformance _performance;

  AppMonitoringService({
    FirebaseAnalytics? analytics,
    FirebaseCrashlytics? crashlytics,
    FirebasePerformance? performance,
  }) : _analytics = analytics ?? FirebaseAnalytics.instance,
       _crashlytics = crashlytics ?? FirebaseCrashlytics.instance,
       _performance = performance ?? FirebasePerformance.instance;

  /// 重大イベントの閾値
  static const double _criticalCrashRate = 0.05; // 5%
  static const double _criticalErrorRate = 0.10; // 10%
  static const int _criticalResponseTime = 5000; // 5秒

  /// アプリ起動を記録
  Future<void> trackAppLaunch() async {
    try {
      await _analytics.logAppOpen();
      AppLogger.info('App launched');
    } catch (e, stack) {
      AppLogger.error('Failed to track app launch', e, stack);
    }
  }

  /// 画面遷移を記録
  Future<void> trackScreenView(String screenName) async {
    try {
      await _analytics.logScreenView(screenName: screenName);
      AppLogger.debug('Screen view: $screenName');
    } catch (e, stack) {
      AppLogger.error('Failed to track screen view', e, stack);
    }
  }

  /// ユーザーアクションを記録
  Future<void> trackUserAction(
    String action, {
    Map<String, dynamic>? parameters,
  }) async {
    try {
      await _analytics.logEvent(name: action, parameters: parameters);
      AppLogger.debug('User action: $action', parameters);
    } catch (e, stack) {
      AppLogger.error('Failed to track user action', e, stack);
    }
  }

  /// エラーを記録
  Future<void> recordError(
    dynamic error,
    StackTrace? stackTrace, {
    String? reason,
    bool fatal = false,
  }) async {
    try {
      await _crashlytics.recordError(
        error,
        stackTrace,
        reason: reason,
        fatal: fatal,
      );

      if (fatal) {
        AppLogger.fatal('Fatal error recorded', error, stackTrace);
        await _notifyCriticalEvent('Fatal Error', error.toString());
      } else {
        AppLogger.error('Error recorded', error, stackTrace);
      }
    } catch (e, stack) {
      AppLogger.error('Failed to record error', e, stack);
    }
  }

  /// パフォーマンストレースを開始
  Trace startTrace(String name) {
    return _performance.newTrace(name);
  }

  /// HTTPリクエストのメトリクスを記録
  Future<void> recordHttpMetric({
    required String url,
    required String method,
    required int statusCode,
    required int requestPayloadSize,
    required int responsePayloadSize,
    required Duration duration,
  }) async {
    try {
      final metric = _performance.newHttpMetric(
        url,
        HttpMethod.values.firstWhere(
          (m) => m.name.toUpperCase() == method.toUpperCase(),
          orElse: () => HttpMethod.Get,
        ),
      );

      metric.httpResponseCode = statusCode;
      metric.requestPayloadSize = requestPayloadSize;
      metric.responsePayloadSize = responsePayloadSize;

      await metric.start();
      await Future.delayed(duration);
      await metric.stop();

      // レスポンスタイムが閾値を超えた場合
      if (duration.inMilliseconds > _criticalResponseTime) {
        AppLogger.warning('Slow API response detected', {
          'url': url,
          'duration': duration.inMilliseconds,
        });
        await _notifyCriticalEvent(
          'Slow API Response',
          'URL: $url, Duration: ${duration.inMilliseconds}ms',
        );
      }
    } catch (e, stack) {
      AppLogger.error('Failed to record HTTP metric', e, stack);
    }
  }

  /// カスタムメトリクスを記録
  Future<void> recordCustomMetric(
    String name,
    double value, {
    Map<String, String>? attributes,
  }) async {
    try {
      await _analytics.logEvent(
        name: 'custom_metric',
        parameters: {
          'metric_name': name,
          'metric_value': value,
          ...?attributes,
        },
      );
      AppLogger.debug('Custom metric: $name = $value', attributes);
    } catch (e, stack) {
      AppLogger.error('Failed to record custom metric', e, stack);
    }
  }

  /// クラッシュ率を監視
  Future<void> monitorCrashRate(double crashRate) async {
    if (crashRate > _criticalCrashRate) {
      AppLogger.critical('Critical crash rate detected', {
        'crash_rate': crashRate,
      });
      await _notifyCriticalEvent(
        'High Crash Rate',
        'Current crash rate: ${(crashRate * 100).toStringAsFixed(2)}%',
      );
    }
  }

  /// エラー率を監視
  Future<void> monitorErrorRate(double errorRate) async {
    if (errorRate > _criticalErrorRate) {
      AppLogger.warning('High error rate detected', {'error_rate': errorRate});
      await _notifyCriticalEvent(
        'High Error Rate',
        'Current error rate: ${(errorRate * 100).toStringAsFixed(2)}%',
      );
    }
  }

  /// ユーザーセッションを記録
  Future<void> recordSession({
    required Duration duration,
    required int screenViews,
    required int userActions,
  }) async {
    try {
      await _analytics.logEvent(
        name: 'session_end',
        parameters: {
          'duration_seconds': duration.inSeconds,
          'screen_views': screenViews,
          'user_actions': userActions,
        },
      );
      AppLogger.info('Session recorded', {
        'duration': duration.inSeconds,
        'screens': screenViews,
        'actions': userActions,
      });
    } catch (e, stack) {
      AppLogger.error('Failed to record session', e, stack);
    }
  }

  /// アプリの健全性チェック
  Future<HealthStatus> checkHealth() async {
    try {
      // 各サービスの状態を確認
      final analyticsHealthy = await _checkAnalyticsHealth();
      final crashlyticsHealthy = await _checkCrashlyticsHealth();
      final performanceHealthy = await _checkPerformanceHealth();

      final isHealthy =
          analyticsHealthy && crashlyticsHealthy && performanceHealthy;

      return HealthStatus(
        isHealthy: isHealthy,
        analyticsHealthy: analyticsHealthy,
        crashlyticsHealthy: crashlyticsHealthy,
        performanceHealthy: performanceHealthy,
        timestamp: DateTime.now(),
      );
    } catch (e, stack) {
      AppLogger.error('Health check failed', e, stack);
      return HealthStatus(
        isHealthy: false,
        analyticsHealthy: false,
        crashlyticsHealthy: false,
        performanceHealthy: false,
        timestamp: DateTime.now(),
      );
    }
  }

  Future<bool> _checkAnalyticsHealth() async {
    try {
      // Analyticsが正常に動作しているか確認
      await _analytics.logEvent(name: 'health_check');
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> _checkCrashlyticsHealth() async {
    try {
      // Crashlyticsが正常に動作しているか確認
      await _crashlytics.log('Health check');
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> _checkPerformanceHealth() async {
    try {
      // Performance Monitoringが正常に動作しているか確認
      final trace = _performance.newTrace('health_check');
      await trace.start();
      await trace.stop();
      return true;
    } catch (e) {
      return false;
    }
  }

  /// 重大イベントを通知
  ///
  /// 実際の実装では、Slack/メール/PagerDutyなどに通知
  Future<void> _notifyCriticalEvent(String title, String message) async {
    try {
      // Crashlyticsにログを記録
      await _crashlytics.log('CRITICAL: $title - $message');

      // カスタムキーを設定
      await _crashlytics.setCustomKey('critical_event', title);
      await _crashlytics.setCustomKey('critical_message', message);

      AppLogger.critical('Critical event notification', {
        'title': title,
        'message': message,
      });

      // TODO: 実際の通知実装（Slack, Email, PagerDutyなど）
      // await _sendSlackNotification(title, message);
      // await _sendEmailNotification(title, message);
    } catch (e, stack) {
      AppLogger.error('Failed to notify critical event', e, stack);
    }
  }

  /// ユーザープロパティを設定
  Future<void> setUserProperty(String name, String value) async {
    try {
      await _analytics.setUserProperty(name: name, value: value);
      await _crashlytics.setCustomKey(name, value);
    } catch (e, stack) {
      AppLogger.error('Failed to set user property', e, stack);
    }
  }

  /// ユーザーIDを設定
  Future<void> setUserId(String userId) async {
    try {
      await _analytics.setUserId(id: userId);
      await _crashlytics.setUserIdentifier(userId);
    } catch (e, stack) {
      AppLogger.error('Failed to set user ID', e, stack);
    }
  }
}

/// アプリの健全性ステータス
class HealthStatus {
  final bool isHealthy;
  final bool analyticsHealthy;
  final bool crashlyticsHealthy;
  final bool performanceHealthy;
  final DateTime timestamp;

  HealthStatus({
    required this.isHealthy,
    required this.analyticsHealthy,
    required this.crashlyticsHealthy,
    required this.performanceHealthy,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
    'is_healthy': isHealthy,
    'analytics_healthy': analyticsHealthy,
    'crashlytics_healthy': crashlyticsHealthy,
    'performance_healthy': performanceHealthy,
    'timestamp': timestamp.toIso8601String(),
  };
}

/// 監視サービスのProvider
final appMonitoringServiceProvider = Provider<AppMonitoringService>((ref) {
  return AppMonitoringService();
});
