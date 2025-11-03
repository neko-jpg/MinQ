import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:minq/core/notifications/advanced_notification_service.dart';
import 'package:minq/core/notifications/behavior_learning_service.dart';
import 'package:minq/core/notifications/notification_analytics_service.dart';
import 'package:minq/data/services/isar_service.dart';
import 'package:minq/data/services/local_file_service.dart';
import 'package:minq/data/services/network_status_service.dart';
import 'package:minq/data/services/system_profile_service.dart';
import 'package:minq/models/user_profile.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/services/analytics/analytics_service_provider.dart';
import '../core/services/local_storage_service.dart';
import 'services/firestore_service.dart';
import 'services/user_service.dart';

// ignore_for_file: unnecessary_lambdas

//==============================================================================
// Service Initialization and Mocking Support
//==============================================================================

// Allows overriding service implementations for testing.
// In production, this map is empty. In test setups, it's populated with mocks.
final Map<Provider, Override> _serviceOverrides = {};

void registerServiceOverride(Provider provider, Override override) {
  _serviceOverrides[provider] = override;
}

// Helper to create a provider with a potential override.
Provider<T> _createProvider<T>(
  T Function(Ref) create, {
  Map<Provider, Override> overrides = const {},
  required Provider<T> provider,
}) {
  if (overrides.containsKey(provider)) {
    return provider..overrideWith((ref) => overrides[provider] as T);
  }
  return provider..overrideWith(create);
}

//==============================================================================
// Core Firebase Service Providers
//==============================================================================

/// Provider for the [FirebaseAuth] instance.
final firebaseAuthProvider =
    Provider<FirebaseAuth>((ref) => FirebaseAuth.instance);

/// Provider for the [FirebaseFirestore] instance.
final firebaseFirestoreProvider =
    Provider<FirebaseFirestore>((ref) => FirebaseFirestore.instance);

/// Provider for the [FirebaseCrashlytics] instance.
final firebaseCrashlyticsProvider =
    Provider<FirebaseCrashlytics>((ref) => FirebaseCrashlytics.instance);

/// Provider for the [FirebaseMessaging] instance.
final firebaseMessagingProvider =
    Provider<FirebaseMessaging>((ref) => FirebaseMessaging.instance);

//==============================================================================
// Application-Specific Service Providers
//==============================================================================

/// Provider for the [FirestoreService].
///
/// This service handles all direct interactions with Firebase Firestore.
final firestoreServiceProvider = Provider<FirestoreService>((ref) {
  final firestore = ref.watch(firebaseFirestoreProvider);
  return FirestoreService(firestore);
});

/// Provider for the [UserService].
///
/// Manages user authentication state and user data.
final userServiceProvider = Provider<UserService>((ref) {
  final auth = ref.watch(firebaseAuthProvider);
  final firestore = ref.watch(firebaseFirestoreProvider);
  return UserService(auth, firestore);
});

/// Provider for the application's analytics service.
///
/// This is a wrapper around the core analytics service to provide
/// app-specific logging.
final appAnalyticsServiceProvider = Provider<AnalyticsService>((ref) {
  // This could be configured with a different implementation for tests
  // or different flavors.
  return ref.watch(analyticsServiceProvider);
});

/// Provider for [SharedPreferences].
///
/// Used for simple key-value storage.
final sharedPreferencesProvider =
    FutureProvider<SharedPreferences>((ref) => SharedPreferences.getInstance());

/// Provider for the [IsarService].
///
/// Manages the local Isar database instance.
final isarProvider = FutureProvider<IsarService>((ref) async {
  final isarService = IsarService();
  await isarService.init();
  return isarService;
});

/// Provider for the [LocalFileService].
///
/// Handles reading from and writing to the local file system.
final localFileServiceProvider = Provider<LocalFileService>((ref) {
  return LocalFileService();
});

/// Provider for the [SystemProfileService].
///
/// Provides information about the device and operating system.
final systemProfileServiceProvider =
    Provider<SystemProfileService>((ref) => SystemProfileService());

/// Provider for the [NetworkStatusService].
///
/// Monitors the device's network connectivity.
final networkStatusServiceProvider = Provider<NetworkStatusService>(
  (ref) => NetworkStatusService(),
);
//==============================================================================
// User and Profile Providers
//==============================================================================

/// Stream provider for the current Firebase [User].
///
/// Emits a new value whenever the authentication state changes.
final authStateChangesProvider = StreamProvider<User?>((ref) {
  final userService = ref.watch(userServiceProvider);
  return userService.authStateChanges;
});

/// Provider for the current user's profile data.
///
/// Fetches the [UserProfile] from Firestore for the currently authenticated
/// user.
final userProfileProvider = FutureProvider<UserProfile?>((ref) async {
  final authState = ref.watch(authStateChangesProvider);
  final user = authState.asData?.value;

  if (user != null) {
    final firestoreService = ref.watch(firestoreServiceProvider);
    final doc = await firestoreService.getUser(user.uid);
    if (doc.exists) {
      return UserProfile.fromJson(doc.data()!);
    }
  }
  return null;
});

/// Provider to check if the user is authenticated.
final isAuthenticatedProvider = Provider<bool>((ref) {
  final authState = ref.watch(authStateChangesProvider);
  return authState.asData?.value != null;
});

//==============================================================================
// Local Storage and Caching
//==============================================================================

final localStorageServiceProvider = Provider<LocalStorageService>((ref) {
  final sharedPreferences = ref.watch(sharedPreferencesProvider).asData?.value;
  if (sharedPreferences == null) {
    // Or handle this case more gracefully, maybe by returning a non-functional
    // service until shared preferences are available.
    throw Exception('SharedPreferences not available');
  }
  return LocalStorageService(sharedPreferences);
});

//==============================================================================
// A/B Testing and Feature Flags
//
// These providers would be used to control feature rollouts and experiments.
//==============================================================================

// final abTestingServiceProvider = Provider<ABTestingService>((ref) {
//   // Implementation would depend on the A/B testing framework being used.
//   // Example: return FirebaseRemoteConfigABTestingService();
//   return ABTestingService();
// });

//==============================================================================
// Health and Fitness Data Integration
//==============================================================================

// This is a placeholder for a provider that would integrate with a health
// data service (e.g., Google Fit, Apple HealthKit).

// final healthDataServiceProvider = Provider<HealthDataService>((ref) {
//   // Implementation would depend on the specific health data plugin used.
//   return HealthDataService();
// });

//==============================================================================
// Gamification and User Engagement
//==============================================================================

// These providers manage the logic related to gamification features like
// quests, challenges, and leaderboards.

// final questServiceProvider = Provider<QuestService>((ref) {
//   final firestoreService = ref.watch(firestoreServiceProvider);
//   return QuestService(firestoreService);
// });

// final challengeServiceProvider = Provider<ChallengeService>((ref) {
//   final firestoreService = ref.watch(firestoreServiceProvider);
//   return ChallengeService(firestoreService);
// });

// final leaderboardServiceProvider = Provider<LeaderboardService>((ref) {
//   final firestoreService = ref.watch(firestoreServiceProvider);
//   return LeaderboardService(firestoreService);
// });

//==============================================================================
// Offline Support and Synchronization
//==============================================================================

// Providers for services that enable offline functionality and data sync.

// final syncQueueManagerProvider = Provider<SyncQueueManager>((ref) {
//   // Manages a queue of operations to be synced with the backend.
//   return SyncQueueManager();
// });

// final offlineStorageServiceProvider = Provider<OfflineStorageService>((ref) {
//   // Provides access to data stored locally for offline use.
//   return OfflineStorageService();
// });

//==============================================================================
// Data Export and Sharing
//==============================================================================

// final dataExportServiceProvider = Provider<DataExportService>((ref) {
//   // Service to handle exporting user data to different formats (e.g., CSV).
//   return DataExportService();
// });

//==============================================================================
// AI and Machine Learning Features
//==============================================================================

// final aiModelServiceProvider = Provider<AIModelService>((ref) {
//   // Manages interactions with a local or cloud-based AI model.
//   return AIModelService();
// });

//==============================================================================
// Social and Community Features
//==============================================================================

// final socialGraphServiceProvider = Provider<SocialGraphService>((ref) {
//   // Manages user relationships (e.g., friends, followers).
//   return SocialGraphService();
// });

// final contentSharingServiceProvider = Provider<ContentSharingService>((ref) {
//   // Handles sharing content to other platforms or users.
//   return ContentSharingService();
// });

//==============================================================================
// E-commerce and In-App Purchases
//==============================================================================

// final iapServiceProvider = Provider<InAppPurchaseService>((ref) {
//   // Manages in-app purchases and subscriptions.
//   return InAppPurchaseService();
// });

//==============================================================================
// App Configuration and Theming
//==============================================================================

// final appConfigServiceProvider = Provider<AppConfigService>((ref) {
//   // Service to fetch and manage remote app configuration.
//   return AppConfigService();
// });

//==============================================================================
// User Support and Feedback
//==============================================================================

// final supportTicketServiceProvider = Provider<SupportTicketService>((ref) {
//   // Service to handle user support tickets and feedback submissions.
//   return SupportTicketService();
// });

//==============================================================================
// Third-Party Integrations
//==============================================================================

// final thirdPartyIntegrationServiceProvider =
//     Provider<ThirdPartyIntegrationService>((ref) {
//   // A generic service for managing integrations with various third-party APIs.
//   return ThirdPartyIntegrationService();
// });

//==============================================================================
// Search and Discovery
//==============================================================================

// final searchServiceProvider = Provider<SearchService>((ref) {
//   // A service to provide search functionality across the app's content.
//   return SearchService();
// });

//==============================================================================
// Location-Based Services
//==============================================================================

// final locationServiceProvider = Provider<LocationService>((ref) {
//   // A service for accessing the device's location.
//   return LocationService();
// });

//==============================================================================
// Deprecated or Mocked Providers (for reference or testing)
//==============================================================================

// This section can be used to keep track of providers that are no longer in
// use or are replaced by mocks in test environments.

/// A provider for a service that is currently under development or mocked.
// final mockedServiceProvider = Provider<MockedService>((ref) {
//   return MockedService();
// });

// class MockedService {}

//
//==============================================================================
// Push Notification Service Providers
//==============================================================================

final localNotificationsProvider =
    Provider<FlutterLocalNotificationsPlugin>(
        (ref) => FlutterLocalNotificationsPlugin());

final notificationAnalyticsServiceProvider =
    Provider<NotificationAnalyticsService>((ref) {
  return NotificationAnalyticsService(
    prefs: ref.watch(sharedPreferencesProvider).value!,
    isar: ref.watch(isarProvider).value!,
  );
});
final behaviorLearningServiceProvider = Provider<BehaviorLearningService>(
    (ref) => BehaviorLearningService(
        prefs: ref.watch(sharedPreferencesProvider).value!));

final advancedNotificationServiceProvider =
    Provider<AdvancedNotificationService>((ref) {
  return AdvancedNotificationService(
    localNotifications: ref.watch(localNotificationsProvider),
    firebaseMessaging: ref.watch(firebaseMessagingProvider),
    prefs: ref.watch(sharedPreferencesProvider).value!,
    analyticsService: ref.watch(notificationAnalyticsServiceProvider),
    behaviorService: ref.watch(behaviorLearningServiceProvider),
  );
});
