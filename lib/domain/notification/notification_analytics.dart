import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:minq/domain/notification/notification_settings.dart';

part 'notification_analytics.freezed.dart';
part 'notification_analytics.g.dart';

/// 通知イベントタイプ
enum NotificationEventType {
  sent('sent', '送信'),
  delivered('delivered', '配信'),
  opened('opened', '開封'),
  clicked('clicked', 'クリック'),
  dismissed('dismissed', '却下'),
  converted('converted', 'コンバージョン');

  const NotificationEventType(this.id, this.displayName);
  final String id;
  final String displayName;
}

/// 通知イベント
@freezed
class NotificationEvent with _$NotificationEvent {
  const factory NotificationEvent({
    required String id,
    required String notificationId,
    required String userId,
    required NotificationEventType eventType,
    required NotificationCategory category,
    required DateTime timestamp,
    Map<String, dynamic>? metadata,
    String? actionTaken, // 実行されたアクション
    Duration? timeToAction, // アクションまでの時間
  }) = _NotificationEvent;

  factory NotificationEvent.fromJson(Map<String, dynamic> json) =>
      _$NotificationEventFromJson(json);
}

/// 通知効果メトリクス
@freezed
class NotificationMetrics with _$NotificationMetrics {
  const factory NotificationMetrics({
    required String userId,
    required NotificationCategory category,
    required DateTime periodStart,
    required DateTime periodEnd,
    @Default(0) int totalSent,
    @Default(0) int totalDelivered,
    @Default(0) int totalOpened,
    @Default(0) int totalClicked,
    @Default(0) int totalDismissed,
    @Default(0) int totalConverted,
    @Default(0.0) double deliveryRate,
    @Default(0.0) double openRate,
    @Default(0.0) double clickRate,
    @Default(0.0) double conversionRate,
    @Default(Duration.zero) Duration averageTimeToAction,
    Map<String, int>? hourlyDistribution, // 時間別分布
    Map<String, double>? dayOfWeekPerformance, // 曜日別パフォーマンス
  }) = _NotificationMetrics;

  factory NotificationMetrics.fromJson(Map<String, dynamic> json) =>
      _$NotificationMetricsFromJson(json);
}

/// 最適タイミング分析結果
@freezed
class OptimalTimingAnalysis with _$OptimalTimingAnalysis {
  const factory OptimalTimingAnalysis({
    required String userId,
    required NotificationCategory category,
    required DateTime analyzedAt,
    @Default([]) List<int> optimalHours, // 最適な時間帯（0-23）
    @Default([]) List<int> optimalDaysOfWeek, // 最適な曜日（1-7）
    @Default(0.0) double confidence, // 分析の信頼度
    @Default(0) int sampleSize, // サンプル数
    Map<String, double>? hourlyEngagementRates, // 時間別エンゲージメント率
    Map<String, double>? dailyEngagementRates, // 曜日別エンゲージメント率
  }) = _OptimalTimingAnalysis;

  factory OptimalTimingAnalysis.fromJson(Map<String, dynamic> json) =>
      _$OptimalTimingAnalysisFromJson(json);
}

/// 行動パターン分析結果
@freezed
class BehaviorPatternAnalysis with _$BehaviorPatternAnalysis {
  const factory BehaviorPatternAnalysis({
    required String userId,
    required DateTime analyzedAt,
    @Default([]) List<String> activeHours, // アクティブな時間帯
    @Default([]) List<String> preferredCategories, // 好みのカテゴリ
    @Default(0.0) double engagementTrend, // エンゲージメント傾向
    @Default(0.0) double responsiveness, // 応答性スコア
    @Default(Duration.zero) Duration averageResponseTime, // 平均応答時間
    Map<String, double>? categoryPreferences, // カテゴリ別好み度
    Map<String, double>? timingPreferences, // タイミング別好み度
  }) = _BehaviorPatternAnalysis;

  factory BehaviorPatternAnalysis.fromJson(Map<String, dynamic> json) =>
      _$BehaviorPatternAnalysisFromJson(json);
}

/// A/Bテスト結果
@freezed
class NotificationABTestResult with _$NotificationABTestResult {
  const factory NotificationABTestResult({
    required String testId,
    required String userId,
    required NotificationCategory category,
    required String variant, // A, B, C等
    required DateTime startDate,
    required DateTime endDate,
    @Default(0) int impressions,
    @Default(0) int conversions,
    @Default(0.0) double conversionRate,
    @Default(0.0) double confidence,
    Map<String, dynamic>? testParameters,
  }) = _NotificationABTestResult;

  factory NotificationABTestResult.fromJson(Map<String, dynamic> json) =>
      _$NotificationABTestResultFromJson(json);
}