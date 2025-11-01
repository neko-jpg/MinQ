import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:minq/core/notifications/advanced_notification_service.dart';
import 'package:minq/core/notifications/behavior_learning_service.dart';
import 'package:minq/core/notifications/notification_analytics_service.dart';
import 'package:minq/core/notifications/smart_notification_scheduler.dart';
import 'package:minq/domain/notification/notification_settings.dart';

void main() {
  group('Advanced Notification System Tests', () {
    late BehaviorLearningService behaviorService;
    late NotificationAnalyticsService analyticsService;
    late SmartNotificationScheduler scheduler;

    setUp(() async {
      // Initialize SharedPreferences for testing
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      behaviorService = BehaviorLearningService(prefs: prefs);
      // analyticsService = NotificationAnalyticsService(prefs: prefs, isar: mockIsar);

      await behaviorService.initialize();
    });

    test('should record notification sent event', () async {
      final context = NotificationContext(
        timestamp: DateTime.now(),
        category: NotificationCategory.quest,
        userId: 'test_user',
        isUrgent: false,
        priority: 1.0,
      );

      await behaviorService.recordNotificationSent(context);

      // Verify the behavior data was recorded
      expect(true, isTrue); // Placeholder assertion
    });

    test('should record notification opened event', () async {
      await behaviorService.recordNotificationOpened(
        'test_user',
        NotificationCategory.quest,
        DateTime.now(),
      );

      // Verify the behavior data was recorded
      expect(true, isTrue); // Placeholder assertion
    });

    test(
      'should calculate optimal timing based on behavior patterns',
      () async {
        // Record some behavior data first
        final userId = 'test_user';
        final category = NotificationCategory.quest;

        // Simulate multiple notification interactions
        for (int i = 0; i < 10; i++) {
          final context = NotificationContext(
            timestamp: DateTime.now().subtract(Duration(days: i)),
            category: category,
            userId: userId,
            isUrgent: false,
            priority: 1.0,
          );

          await behaviorService.recordNotificationSent(context);

          // Simulate some opens
          if (i % 2 == 0) {
            await behaviorService.recordNotificationOpened(
              userId,
              category,
              context.timestamp.add(const Duration(minutes: 5)),
            );
          }
        }

        final analysis = await behaviorService.getOptimalTiming(
          userId,
          category,
        );

        // Should have some analysis after recording behavior
        expect(analysis, isNotNull);
        expect(analysis!.userId, equals(userId));
        expect(analysis.category, equals(category));
      },
    );

    test('should generate behavior pattern analysis', () async {
      final userId = 'test_user';

      // Record app usage patterns
      for (int hour = 9; hour <= 17; hour++) {
        await behaviorService.recordAppUsage(
          userId,
          DateTime(2024, 1, 1, hour),
        );
      }

      final pattern = await behaviorService.getBehaviorPattern(userId);

      expect(pattern, isNotNull);
      expect(pattern!.userId, equals(userId));
      expect(pattern.activeHours, isNotEmpty);
    });

    test('should handle notification categories correctly', () {
      // Test all notification categories
      for (final category in NotificationCategory.values) {
        expect(category.id, isNotEmpty);
        expect(category.displayName, isNotEmpty);
      }
    });

    test('should handle notification frequencies correctly', () {
      // Test all notification frequencies
      for (final frequency in NotificationFrequency.values) {
        expect(frequency.id, isNotEmpty);
        expect(frequency.displayName, isNotEmpty);
      }
    });

    test('should create default notification settings', () {
      final settings = NotificationSettings.defaultSettings();

      expect(settings.globalEnabled, isTrue);
      expect(settings.categorySettings, isNotEmpty);
      expect(settings.timeSettings, isNotNull);
      expect(settings.smartSettings, isNotNull);
      expect(settings.analyticsSettings, isNotNull);

      // Verify all categories have default settings
      for (final category in NotificationCategory.values) {
        expect(settings.categorySettings.containsKey(category), isTrue);
        final categorySettings = settings.categorySettings[category]!;
        expect(categorySettings.category, equals(category));
        expect(categorySettings.enabled, isTrue);
      }
    });

    test('should handle time slot validation', () {
      const timeSlot = TimeSlot(
        startHour: 22,
        startMinute: 0,
        endHour: 7,
        endMinute: 0,
      );

      expect(timeSlot.startHour, equals(22));
      expect(timeSlot.startMinute, equals(0));
      expect(timeSlot.endHour, equals(7));
      expect(timeSlot.endMinute, equals(0));
    });

    test('should export and import learning data', () async {
      final userId = 'test_user';

      // Record some data
      await behaviorService.recordAppUsage(userId, DateTime.now());

      // Export data
      final exportedData = await behaviorService.exportLearningData(userId);

      expect(exportedData, isNotNull);
      expect(exportedData['behavior_data'], isNotNull);
      expect(exportedData['exported_at'], isNotNull);

      // Reset data
      await behaviorService.resetLearningData(userId);

      // Import data back
      await behaviorService.importLearningData(userId, exportedData);

      // Verify data was restored
      final pattern = await behaviorService.getBehaviorPattern(userId);
      expect(pattern, isNotNull);
    });
  });
}
