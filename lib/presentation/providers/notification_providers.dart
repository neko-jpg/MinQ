import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:minq/core/notifications/advanced_notification_service.dart';
import 'package:minq/core/notifications/behavior_learning_service.dart';
import 'package:minq/core/notifications/notification_analytics_service.dart';
import 'package:minq/domain/notification/notification_analytics.dart';
import 'package:minq/domain/notification/notification_settings.dart' as domain;
import 'package:minq/presentation/providers/core_providers.dart';

export 'package:minq/domain/notification/notification_analytics.dart';
export 'package:minq/domain/notification/notification_settings.dart'
    show NotificationCategory;

/// 通知設定プロバイダー
final notificationSettingsProvider = StateNotifierProvider<
  NotificationSettingsNotifier,
  AsyncValue<domain.NotificationSettings>
>((ref) {
  final notificationService = ref.watch(notificationServiceProvider);
  return NotificationSettingsNotifier(notificationService);
});

/// 通知設定ノーティファイアー
class NotificationSettingsNotifier
    extends StateNotifier<AsyncValue<domain.NotificationSettings>> {
  final AdvancedNotificationService _notificationService;

  NotificationSettingsNotifier(this._notificationService)
    : super(const AsyncValue.loading()) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final settings = _notificationService.currentSettings;
      state = AsyncValue.data(settings);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> updateGlobalEnabled(bool enabled) async {
    final currentSettings = state.valueOrNull;
    if (currentSettings == null) return;

    try {
      final updatedSettings = currentSettings.copyWith(globalEnabled: enabled);
      await _notificationService.updateSettings(updatedSettings);
      state = AsyncValue.data(updatedSettings);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> updateCategorySettings(
    domain.NotificationCategory category,
    domain.CategoryNotificationSettings settings,
  ) async {
    final currentSettings = state.valueOrNull;
    if (currentSettings == null) return;

    try {
      await _notificationService.updateCategorySettings(category, settings);
      final updatedCategorySettings = Map<
        domain.NotificationCategory,
        domain.CategoryNotificationSettings
      >.from(currentSettings.categorySettings);
      updatedCategorySettings[category] = settings;

      final updatedSettings = currentSettings.copyWith(
        categorySettings: updatedCategorySettings,
      );
      state = AsyncValue.data(updatedSettings);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> updateTimeSettings(
    domain.TimeBasedNotificationSettings settings,
  ) async {
    final currentSettings = state.valueOrNull;
    if (currentSettings == null) return;

    try {
      await _notificationService.updateTimeSettings(settings);
      final updatedSettings = currentSettings.copyWith(timeSettings: settings);
      state = AsyncValue.data(updatedSettings);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> updateSmartSettings(
    domain.SmartNotificationSettings settings,
  ) async {
    final currentSettings = state.valueOrNull;
    if (currentSettings == null) return;

    try {
      await _notificationService.updateSmartSettings(settings);
      final updatedSettings = currentSettings.copyWith(smartSettings: settings);
      state = AsyncValue.data(updatedSettings);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> updateAnalyticsSettings(
    domain.NotificationAnalyticsSettings settings,
  ) async {
    final currentSettings = state.valueOrNull;
    if (currentSettings == null) return;

    try {
      final updatedSettings = currentSettings.copyWith(
        analyticsSettings: settings,
      );
      await _notificationService.updateSettings(updatedSettings);
      state = AsyncValue.data(updatedSettings);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> resetToDefaults() async {
    try {
      final defaultSettings = domain.NotificationSettings.defaultSettings();
      await _notificationService.updateSettings(defaultSettings);
      state = AsyncValue.data(defaultSettings);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}

/// 通知サービスプロバイダー
final notificationServiceProvider = Provider<AdvancedNotificationService>((
  ref,
) {
  final localNotifications = ref.watch(localNotificationsProvider);
  final firebaseMessaging = ref.watch(firebaseMessagingProvider);
  final sharedPreferencesAsync = ref.watch(sharedPreferencesProvider);
  final analyticsService = ref.watch(notificationAnalyticsServiceProvider);
  final behaviorService = ref.watch(behaviorLearningServiceProvider);

  return sharedPreferencesAsync.when(
    data:
        (sharedPreferences) => AdvancedNotificationService(
          localNotifications: localNotifications,
          firebaseMessaging: firebaseMessaging,
          prefs: sharedPreferences,
          analyticsService: analyticsService,
          behaviorService: behaviorService,
        ),
    loading: () => throw StateError('SharedPreferences not ready'),
    error: (error, stack) => throw error,
  );
});

/// ローカル通知プロバイダー
final localNotificationsProvider = Provider<FlutterLocalNotificationsPlugin>((
  ref,
) {
  return FlutterLocalNotificationsPlugin();
});

/// Firebase Messaging プロバイダー
final firebaseMessagingProvider = Provider<FirebaseMessaging>((ref) {
  return FirebaseMessaging.instance;
});

/// 通知分析サービスプロバイダー
final notificationAnalyticsServiceProvider =
    Provider<NotificationAnalyticsService>((ref) {
      final sharedPreferencesAsync = ref.watch(sharedPreferencesProvider);
      final isarAsync = ref.watch(isarProvider);

      return sharedPreferencesAsync.when(
        data:
            (sharedPreferences) => isarAsync.when(
              data:
                  (isar) => NotificationAnalyticsService(
                    prefs: sharedPreferences,
                    isar: isar,
                  ),
              loading: () => throw StateError('Isar not ready'),
              error: (error, stack) => throw error,
            ),
        loading: () => throw StateError('SharedPreferences not ready'),
        error: (error, stack) => throw error,
      );
    });

/// 行動学習サービスプロバイダー
final behaviorLearningServiceProvider = Provider<BehaviorLearningService>((
  ref,
) {
  final sharedPreferencesAsync = ref.watch(sharedPreferencesProvider);

  return sharedPreferencesAsync.when(
    data:
        (sharedPreferences) =>
            BehaviorLearningService(prefs: sharedPreferences),
    loading: () => throw StateError('SharedPreferences not ready'),
    error: (error, stack) => throw error,
  );
});

/// 通知メトリクスパラメータ
class NotificationMetricsParams {
  final String userId;
  final domain.NotificationCategory category;
  final DateTime startDate;
  final DateTime endDate;

  const NotificationMetricsParams({
    required this.userId,
    required this.category,
    required this.startDate,
    required this.endDate,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NotificationMetricsParams &&
          runtimeType == other.runtimeType &&
          userId == other.userId &&
          category == other.category &&
          startDate == other.startDate &&
          endDate == other.endDate;

  @override
  int get hashCode =>
      userId.hashCode ^
      category.hashCode ^
      startDate.hashCode ^
      endDate.hashCode;
}

/// 通知メトリクスプロバイダー
final notificationMetricsProvider =
    FutureProvider.family<NotificationMetrics, NotificationMetricsParams>((
      ref,
      params,
    ) async {
      final notificationService = ref.watch(notificationServiceProvider);

      return await notificationService.getMetrics(
        userId: params.userId,
        category: params.category,
        startDate: params.startDate,
        endDate: params.endDate,
      );
    });

/// 最適タイミング分析パラメータ
class OptimalTimingParams {
  final String userId;
  final domain.NotificationCategory category;

  const OptimalTimingParams({required this.userId, required this.category});
}

/// 最適タイミング分析プロバイダー
final optimalTimingAnalysisProvider =
    FutureProvider.family<OptimalTimingAnalysis?, OptimalTimingParams>((
      ref,
      params,
    ) async {
      final notificationService = ref.watch(notificationServiceProvider);

      return await notificationService.getOptimalTimingAnalysis(
        userId: params.userId,
        category: params.category,
      );
    });

/// 行動パターン分析プロバイダー
final behaviorPatternAnalysisProvider = FutureProvider.family<
  BehaviorPatternAnalysis?,
  String
>((ref, userId) async {
  final notificationService = ref.watch(notificationServiceProvider);

  return await notificationService.getBehaviorPatternAnalysis(userId: userId);
});

/// 全カテゴリメトリクスプロバイダー
final allCategoryMetricsProvider = FutureProvider.family<
  Map<domain.NotificationCategory, NotificationMetrics>,
  AllMetricsParams
>((ref, params) async {
  final analyticsService = ref.watch(notificationAnalyticsServiceProvider);

  return await analyticsService.getAllMetrics(
    userId: params.userId,
    startDate: params.startDate,
    endDate: params.endDate,
  );
});

/// 通知イベントストリームプロバイダー
final notificationEventStreamProvider = StreamProvider<NotificationEvent>((
  ref,
) {
  final notificationService = ref.watch(notificationServiceProvider);
  return notificationService.eventStream;
});

class AllMetricsParams {
  final String userId;
  final DateTime startDate;
  final DateTime endDate;

  const AllMetricsParams({
    required this.userId,
    required this.startDate,
    required this.endDate,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AllMetricsParams &&
          runtimeType == other.runtimeType &&
          userId == other.userId &&
          startDate == other.startDate &&
          endDate == other.endDate;

  @override
  int get hashCode => userId.hashCode ^ startDate.hashCode ^ endDate.hashCode;
}
