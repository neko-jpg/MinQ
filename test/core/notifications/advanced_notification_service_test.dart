import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:minq/core/notifications/advanced_notification_service.dart';
import 'package:minq/core/notifications/notification_analytics_service.dart';
import 'package:minq/core/notifications/behavior_learning_service.dart';
import 'package:minq/domain/notification/notification_settings.dart';

class MockFlutterLocalNotificationsPlugin extends Mock implements FlutterLocalNotificationsPlugin {}
class MockFirebaseMessaging extends Mock implements FirebaseMessaging {}
class MockSharedPreferences extends Mock implements SharedPreferences {}
class MockNotificationAnalyticsService extends Mock implements NotificationAnalyticsService {}
class MockBehaviorLearningService extends Mock implements BehaviorLearningService {}

void main() {
  group('AdvancedNotificationService', () {
    late AdvancedNotificationService service;
    late MockFlutterLocalNotificationsPlugin mockLocalNotifications;
    late MockFirebaseMessaging mockFirebaseMessaging;
    late MockSharedPreferences mockSharedPreferences;
    late MockNotificationAnalyticsService mockAnalyticsService;
    late MockBehaviorLearningService mockBehaviorService;

    setUp(() {
      mockLocalNotifications = MockFlutterLocalNotificationsPlugin();
      mockFirebaseMessaging = MockFirebaseMessaging();
      mockSharedPreferences = MockSharedPreferences();
      mockAnalyticsService = MockNotificationAnalyticsService();
      mockBehaviorService = MockBehaviorLearningService();

      // Setup default mocks
      when(() => mockSharedPreferences.getString(any())).thenReturn(null);
      when(() => mockSharedPreferences.setString(any(), any())).thenAnswer((_) async => true);
      when(() => mockLocalNotifications.initialize(any(), onDidReceiveNotificationResponse: any(named: 'onDidReceiveNotificationResponse')))
          .thenAnswer((_) async => true);
      when(() => mockFirebaseMessaging.requestPermission(
        alert: any(named: 'alert'),
        badge: any(named: 'badge'),
        sound: any(named: 'sound'),
        provisional: any(named: 'provisional'),
      )).thenAnswer((_) async => const NotificationSettings(
        authorizationStatus: AuthorizationStatus.authorized,
        alert: AppleNotificationSetting.enabled,
        badge: AppleNotificationSetting.enabled,
        sound: AppleNotificationSetting.enabled,
        announcement: AppleNotificationSetting.notSupported,
        carPlay: AppleNotificationSetting.notSupported,
        lockScreen: AppleNotificationSetting.enabled,
        notificationCenter: AppleNotificationSetting.enabled,
        showPreviews: AppleShowPreviewSetting.always,
        criticalAlert: AppleNotificationSetting.notSupported,
        providesAppNotificationSettings: false,
      ));
      when(() => mockFirebaseMessaging.getToken()).thenAnswer((_) async => 'test_token');
      when(() => mockAnalyticsService.initialize()).thenAnswer((_) async {});
      when(() => mockBehaviorService.initialize()).thenAnswer((_) async {});

      service = AdvancedNotificationService(
        localNotifications: mockLocalNotifications,
        firebaseMessaging: mockFirebaseMessaging,
        prefs: mockSharedPreferences,
        analyticsService: mockAnalyticsService,
        behaviorService: mockBehaviorService,
      );
    });

    group('initialization', () {
      test('should initialize successfully', () async {
        await service.initialize();

        verify(() => mockLocalNotifications.initialize(any(), onDidReceiveNotificationResponse: any(named: 'onDidReceiveNotificationResponse'))).called(1);
        verify(() => mockFirebaseMessaging.requestPermission(
          alert: true,
          badge: true,
          sound: true,
          provisional: false,
        )).called(1);
        verify(() => mockAnalyticsService.initialize()).called(1);
        verify(() => mockBehaviorService.initialize()).called(1);
      });

      test('should load default settings when no saved settings exist', () async {
        await service.initialize();

        final settings = service.currentSettings;
        expect(settings.globalEnabled, isTrue);
        expect(settings.categorySettings, isNotEmpty);
        expect(settings.timeSettings.enabled, isTrue);
        expect(settings.smartSettings.enabled, isTrue);
        expect(settings.analyticsSettings.enabled, isTrue);
      });
    });

    group('settings management', () {
      test('should update global enabled setting', () async {
        await service.initialize();

        await service.updateSettings(
          service.currentSettings.copyWith(globalEnabled: false),
        );

        expect(service.currentSettings.globalEnabled, isFalse);
        verify(() => mockSharedPreferences.setString(any(), any())).called(greaterThan(0));
      });

      test('should update category settings', () async {
        await service.initialize();

        const newCategorySettings = CategoryNotificationSettings(
          category: NotificationCategory.quest,
          enabled: false,
          frequency: NotificationFrequency.hourly,
        );

        await service.updateCategorySettings(
          NotificationCategory.quest,
          newCategorySettings,
        );

        final updatedSettings = service.currentSettings.categorySettings[NotificationCategory.quest];
        expect(updatedSettings?.enabled, isFalse);
        expect(updatedSettings?.frequency, NotificationFrequency.hourly);
      });

      test('should update time settings', () async {
        await service.initialize();

        const newTimeSettings = TimeBasedNotificationSettings(
          enabled: false,
          respectSystemDnd: false,
        );

        await service.updateTimeSettings(newTimeSettings);

        expect(service.currentSettings.timeSettings.enabled, isFalse);
        expect(service.currentSettings.timeSettings.respectSystemDnd, isFalse);
      });

      test('should update smart settings', () async {
        await service.initialize();

        const newSmartSettings = SmartNotificationSettings(
          enabled: false,
          behaviorLearning: false,
          confidenceThreshold: 0.5,
        );

        await service.updateSmartSettings(newSmartSettings);

        expect(service.currentSettings.smartSettings.enabled, isFalse);
        expect(service.currentSettings.smartSettings.behaviorLearning, isFalse);
        expect(service.currentSettings.smartSettings.confidenceThreshold, 0.5);
      });
    });

    group('notification scheduling', () {
      test('should not schedule notification when globally disabled', () async {
        await service.initialize();
        await service.updateSettings(
          service.currentSettings.copyWith(globalEnabled: false),
        );

        final result = await service.scheduleNotification(
          id: 'test_notification',
          title: 'Test Title',
          body: 'Test Body',
          category: NotificationCategory.quest,
          userId: 'test_user',
        );

        expect(result, isFalse);
        verifyNever(() => mockLocalNotifications.show(any(), any(), any(), any(), payload: any(named: 'payload')));
      });

      test('should not schedule notification when category disabled', () async {
        await service.initialize();
        
        const disabledCategorySettings = CategoryNotificationSettings(
          category: NotificationCategory.quest,
          enabled: false,
        );
        
        await service.updateCategorySettings(
          NotificationCategory.quest,
          disabledCategorySettings,
        );

        final result = await service.scheduleNotification(
          id: 'test_notification',
          title: 'Test Title',
          body: 'Test Body',
          category: NotificationCategory.quest,
          userId: 'test_user',
        );

        expect(result, isFalse);
        verifyNever(() => mockLocalNotifications.show(any(), any(), any(), any(), payload: any(named: 'payload')));
      });

      test('should schedule notification when enabled', () async {
        await service.initialize();
        
        when(() => mockLocalNotifications.show(any(), any(), any(), any(), payload: any(named: 'payload')))
            .thenAnswer((_) async {});
        when(() => mockAnalyticsService.recordEvent(any())).thenAnswer((_) async {});
        when(() => mockBehaviorService.recordNotificationSent(any())).thenAnswer((_) async {});

        final result = await service.scheduleNotification(
          id: 'test_notification',
          title: 'Test Title',
          body: 'Test Body',
          category: NotificationCategory.quest,
          userId: 'test_user',
        );

        expect(result, isTrue);
        verify(() => mockLocalNotifications.show(any(), any(), any(), any(), payload: any(named: 'payload'))).called(1);
        verify(() => mockAnalyticsService.recordEvent(any())).called(1);
      });
    });

    group('time-based control', () {
      test('should respect sleep time settings', () async {
        await service.initialize();
        
        const timeSettings = TimeBasedNotificationSettings(
          enabled: true,
          sleepTime: TimeSlot(
            startHour: 22,
            startMinute: 0,
            endHour: 7,
            endMinute: 0,
          ),
        );
        
        await service.updateTimeSettings(timeSettings);

        // Test during sleep time (23:00)
        final sleepTime = DateTime(2024, 1, 1, 23, 0);
        
        when(() => mockLocalNotifications.zonedSchedule(
          any(), any(), any(), any(), any(),
          payload: any(named: 'payload'),
          androidScheduleMode: any(named: 'androidScheduleMode'),
          uiLocalNotificationDateInterpretation: any(named: 'uiLocalNotificationDateInterpretation'),
        )).thenAnswer((_) async {});
        when(() => mockAnalyticsService.recordEvent(any())).thenAnswer((_) async {});
        when(() => mockBehaviorService.recordNotificationSent(any())).thenAnswer((_) async {});

        final result = await service.scheduleNotification(
          id: 'test_notification',
          title: 'Test Title',
          body: 'Test Body',
          category: NotificationCategory.quest,
          userId: 'test_user',
          scheduledTime: sleepTime,
        );

        expect(result, isTrue);
        // Should be rescheduled to a later time, not immediate
        verify(() => mockLocalNotifications.zonedSchedule(
          any(), any(), any(), any(), any(),
          payload: any(named: 'payload'),
          androidScheduleMode: any(named: 'androidScheduleMode'),
          uiLocalNotificationDateInterpretation: any(named: 'uiLocalNotificationDateInterpretation'),
        )).called(1);
      });
    });
  });
}