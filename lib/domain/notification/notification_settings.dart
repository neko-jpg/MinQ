import 'package:freezed_annotation/freezed_annotation.dart';

part 'notification_settings.freezed.dart';
part 'notification_settings.g.dart';

/// 通知カテゴリ
enum NotificationCategory {
  quest('quest', 'クエスト'),
  challenge('challenge', 'チャレンジ'),
  pair('pair', 'ペア'),
  league('league', 'リーグ'),
  ai('ai', 'AIコーチ'),
  system('system', 'システム'),
  achievement('achievement', '実績'),
  reminder('reminder', 'リマインダー');

  const NotificationCategory(this.id, this.displayName);
  final String id;
  final String displayName;
}

/// 通知頻度
enum NotificationFrequency {
  immediate('immediate', '即座'),
  hourly('hourly', '1時間後'),
  threeHours('three_hours', '3時間後'),
  daily('daily', '翌日');

  const NotificationFrequency(this.id, this.displayName);
  final String id;
  final String displayName;
}

/// 時間帯設定
@freezed
class TimeSlot with _$TimeSlot {
  const factory TimeSlot({
    required int startHour,
    required int startMinute,
    required int endHour,
    required int endMinute,
  }) = _TimeSlot;

  factory TimeSlot.fromJson(Map<String, dynamic> json) =>
      _$TimeSlotFromJson(json);
}

/// カテゴリ別通知設定
@freezed
class CategoryNotificationSettings with _$CategoryNotificationSettings {
  const factory CategoryNotificationSettings({
    required NotificationCategory category,
    @Default(true) bool enabled,
    @Default(NotificationFrequency.immediate) NotificationFrequency frequency,
    @Default(true) bool sound,
    @Default(true) bool vibration,
    @Default(true) bool badge,
    @Default(true) bool lockScreen,
    String? customSound,
    List<int>? vibrationPattern,
  }) = _CategoryNotificationSettings;

  factory CategoryNotificationSettings.fromJson(Map<String, dynamic> json) =>
      _$CategoryNotificationSettingsFromJson(json);
}

/// 時間帯別通知制御設定
@freezed
class TimeBasedNotificationSettings with _$TimeBasedNotificationSettings {
  const factory TimeBasedNotificationSettings({
    @Default(true) bool enabled,
    TimeSlot? sleepTime, // 就寝時間（通知停止）
    TimeSlot? workTime, // 勤務時間（制限モード）
    @Default([]) List<TimeSlot> customQuietHours, // カスタム静音時間
    @Default(true) bool respectSystemDnd, // システムのDNDモードを尊重
    @Default(false) bool weekendMode, // 週末モード（異なる時間設定）
    TimeSlot? weekendSleepTime,
    TimeSlot? weekendWorkTime,
  }) = _TimeBasedNotificationSettings;

  factory TimeBasedNotificationSettings.fromJson(Map<String, dynamic> json) =>
      _$TimeBasedNotificationSettingsFromJson(json);
}

/// スマート通知設定
@freezed
class SmartNotificationSettings with _$SmartNotificationSettings {
  const factory SmartNotificationSettings({
    @Default(true) bool enabled,
    @Default(true) bool behaviorLearning, // 行動パターン学習
    @Default(true) bool adaptiveFrequency, // 適応的頻度調整
    @Default(true) bool contextAware, // コンテキスト認識
    @Default(true) bool engagementOptimization, // エンゲージメント最適化
    @Default(0.7) double confidenceThreshold, // 予測信頼度閾値
    @Default(7) int learningPeriodDays, // 学習期間（日）
  }) = _SmartNotificationSettings;

  factory SmartNotificationSettings.fromJson(Map<String, dynamic> json) =>
      _$SmartNotificationSettingsFromJson(json);
}

/// 通知効果測定設定
@freezed
class NotificationAnalyticsSettings with _$NotificationAnalyticsSettings {
  const factory NotificationAnalyticsSettings({
    @Default(true) bool enabled,
    @Default(true) bool trackOpenRate, // 開封率追跡
    @Default(true) bool trackEngagementRate, // エンゲージメント率追跡
    @Default(true) bool trackConversionRate, // コンバージョン率追跡
    @Default(true) bool trackOptimalTiming, // 最適タイミング分析
    @Default(30) int retentionPeriodDays, // データ保持期間
  }) = _NotificationAnalyticsSettings;

  factory NotificationAnalyticsSettings.fromJson(Map<String, dynamic> json) =>
      _$NotificationAnalyticsSettingsFromJson(json);
}

/// 統合通知設定
@freezed
class NotificationSettings with _$NotificationSettings {
  const factory NotificationSettings({
    @Default(true) bool globalEnabled,
    @Default({}) Map<NotificationCategory, CategoryNotificationSettings> categorySettings,
    @Default(TimeBasedNotificationSettings()) TimeBasedNotificationSettings timeSettings,
    @Default(SmartNotificationSettings()) SmartNotificationSettings smartSettings,
    @Default(NotificationAnalyticsSettings()) NotificationAnalyticsSettings analyticsSettings,
    @Default('') String deviceToken,
    DateTime? lastUpdated,
  }) = _NotificationSettings;

  factory NotificationSettings.fromJson(Map<String, dynamic> json) =>
      _$NotificationSettingsFromJson(json);

  /// デフォルト設定を生成
  factory NotificationSettings.defaultSettings() {
    final categorySettings = <NotificationCategory, CategoryNotificationSettings>{};
    
    for (final category in NotificationCategory.values) {
      categorySettings[category] = CategoryNotificationSettings(
        category: category,
        enabled: true,
        frequency: NotificationFrequency.immediate,
        sound: true,
        vibration: true,
        badge: true,
        lockScreen: true,
      );
    }

    return NotificationSettings(
      globalEnabled: true,
      categorySettings: categorySettings,
      timeSettings: const TimeBasedNotificationSettings(
        enabled: true,
        sleepTime: TimeSlot(startHour: 22, startMinute: 0, endHour: 7, endMinute: 0),
        respectSystemDnd: true,
      ),
      smartSettings: const SmartNotificationSettings(),
      analyticsSettings: const NotificationAnalyticsSettings(),
      lastUpdated: DateTime.now(),
    );
  }
}

/// 通知コンテキスト情報
@freezed
class NotificationContext with _$NotificationContext {
  const factory NotificationContext({
    required DateTime timestamp,
    required NotificationCategory category,
    required String userId,
    String? questId,
    String? challengeId,
    String? pairId,
    Map<String, dynamic>? metadata,
    @Default(false) bool isUrgent,
    @Default(1.0) double priority,
  }) = _NotificationContext;

  factory NotificationContext.fromJson(Map<String, dynamic> json) =>
      _$NotificationContextFromJson(json);
}