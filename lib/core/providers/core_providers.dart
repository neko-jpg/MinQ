import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:isar/isar.dart';
import 'package:just_audio/just_audio.dart';
import 'package:minq/config/stripe_config.dart';
import 'package:minq/core/export/data_export_service.dart';
import 'package:minq/core/gamification/gamification_engine.dart';
import 'package:minq/core/logging/app_logger.dart';
import 'package:minq/core/network/network_providers.dart';
import 'package:minq/core/notifications/re_engagement_service.dart';
import 'package:minq/core/reminders/multiple_reminder_service.dart';
import 'package:minq/core/sharing/ogp_image_generator.dart';
import 'package:minq/core/sharing/share_service.dart';
import 'package:minq/data/repositories/community_board_repository.dart';
import 'package:minq/data/repositories/contact_link_repository.dart';
import 'package:minq/data/repositories/pair_repository.dart';

import 'package:minq/data/services/analytics_service.dart';
import 'package:minq/data/services/app_locale_controller.dart';
import 'package:minq/data/services/crash_recovery_store.dart';
import 'package:minq/data/services/deep_link_service.dart';
import 'package:minq/data/services/firestore_sync_service.dart';
import 'package:minq/data/services/focus_music_service.dart';
import 'package:minq/data/services/image_moderation_service.dart';
import 'package:minq/data/services/in_app_review_service.dart';
import 'package:minq/data/services/isar_service.dart';
import 'package:minq/data/services/local_preferences_service.dart';
import 'package:minq/data/services/marketing_attribution_service.dart';
import 'package:minq/data/services/notification_service.dart';
import 'package:minq/data/services/operations_metrics_service.dart';
import 'package:minq/data/services/photo_storage_service.dart';
import 'package:minq/data/services/referral_service.dart';
import 'package:minq/data/services/remote_config_service.dart';
import 'package:minq/data/services/speech_input_service.dart';
import 'package:minq/data/services/stripe_billing_service.dart';
import 'package:minq/data/services/sync_worker.dart';
import 'package:minq/data/services/time_consistency_service.dart';
import 'package:minq/data/services/usage_limit_service.dart';
import 'package:minq/data/services/webhook_dispatch_service.dart';
import 'package:minq/domain/notification/notification_sound_profile.dart';
import 'package:minq/domain/pair/pair.dart' as minq_pair;
import 'package:minq/features/auth/data/auth_providers.dart';
import 'package:minq/features/gamification/data/gamification_providers.dart';
import 'package:minq/features/quest/data/quest_providers.dart';
import 'package:speech_to_text/speech_to_text.dart';

// Firebase Availability
final firebaseAvailabilityProvider = Provider<bool>((_) => true);

final firestoreProvider = Provider<FirebaseFirestore?>(
  (ref) =>
      ref.watch(firebaseAvailabilityProvider)
          ? FirebaseFirestore.instance
          : null,
);

final firebaseStorageProvider = Provider<FirebaseStorage?>(
  (ref) =>
      ref.watch(firebaseAvailabilityProvider) ? FirebaseStorage.instance : null,
);

final remoteConfigProvider = Provider<FirebaseRemoteConfig?>((ref) {
  return ref.watch(firebaseAvailabilityProvider)
      ? FirebaseRemoteConfig.instance
      : null;
});

final firebaseAnalyticsProvider = Provider<FirebaseAnalytics?>((ref) {
  return ref.watch(firebaseAvailabilityProvider)
      ? FirebaseAnalytics.instance
      : null;
});

// Core Services
final appLoggerProvider = Provider<AppLogger>((ref) {
  final logger = AppLogger();
  logger.initialize();
  return logger;
});

final localPreferencesServiceProvider = Provider<LocalPreferencesService>(
  (_) => LocalPreferencesService(),
);

final remoteConfigServiceProvider = Provider<RemoteConfigService>((ref) {
  return RemoteConfigService(ref.watch(remoteConfigProvider));
});

final analyticsServiceProvider = Provider<AnalyticsService>((ref) {
  return AnalyticsService(ref.watch(firebaseAnalyticsProvider));
});

final isarProvider = FutureProvider<Isar>((ref) async {
  final isarService = IsarService();
  return isarService.init();
});

// Audio & Speech
final speechToTextProvider = Provider<SpeechToText>((ref) => SpeechToText());

final speechInputServiceProvider = Provider<SpeechInputService>((ref) {
  return SpeechInputService(ref.watch(speechToTextProvider));
});

final audioPlayerProvider = Provider<AudioPlayer>((ref) {
  final player = AudioPlayer();
  ref.onDispose(player.dispose);
  return player;
});

final focusMusicServiceProvider = Provider<FocusMusicService>((ref) {
  final service = FocusMusicService(ref.watch(audioPlayerProvider));
  ref.onDispose(() {
    // ignore: discarded_futures
    service.dispose();
  });
  return service;
});

final focusMusicPlayerStateProvider = StreamProvider<PlayerState>((ref) {
  return ref.watch(focusMusicServiceProvider).playerStateStream;
});

// Repositories & Services
final contactLinkRepositoryProvider = Provider<ContactLinkRepository>((ref) {
  return ContactLinkRepository(ref.watch(localPreferencesServiceProvider));
});

final communityBoardRepositoryProvider = Provider<CommunityBoardRepository?>((
  ref,
) {
  final firestore = ref.watch(firestoreProvider);
  if (firestore == null) {
    return null;
  }
  return CommunityBoardRepository(firestore);
});

final usageLimitServiceProvider = Provider<UsageLimitService>((ref) {
  return UsageLimitService(ref.watch(localPreferencesServiceProvider));
});

final webhookDispatchServiceProvider = Provider<WebhookDispatchService>((ref) {
  return WebhookDispatchService(
    client: ref.watch(httpClientProvider),
    preferences: ref.watch(localPreferencesServiceProvider),
    logger: ref.watch(appLoggerProvider),
  );
});

final stripeBillingServiceProvider = Provider<StripeBillingService?>((ref) {
  final config = StripeConfig.maybeFromRemoteConfig(
    ref.watch(remoteConfigServiceProvider),
  );
  if (config == null) {
    return null;
  }
  return StripeBillingService(
    client: ref.watch(httpClientProvider),
    config: config,
    logger: ref.watch(appLoggerProvider),
  );
});

final notificationServiceProvider = Provider<NotificationService>(
  (ref) => NotificationService(),
);

final multipleReminderServiceProvider = Provider<MultipleReminderService>((
  ref,
) {
  final firestore = ref.watch(firestoreProvider);
  return MultipleReminderService(firestore: firestore);
});

final notificationPermissionProvider = StateProvider<bool>((ref) => false);
final timeDriftDetectedProvider = StateProvider<bool>((ref) => false);
final initializationErrorProvider = StateProvider<Object?>((ref) => null);
final dummyDataModeProvider = StateProvider<bool>((ref) => false);

final notificationTapStreamProvider = StreamProvider<String>((ref) async* {
  final notifications = ref.watch(notificationServiceProvider);
  final initialPayload = await notifications.takeInitialPayload();
  if (initialPayload != null && initialPayload.isNotEmpty) {
    yield initialPayload;
  }
  yield* notifications.notificationTapStream;
});

final notificationSoundProfilesProvider =
    Provider<List<NotificationSoundProfile>>(
      (ref) => NotificationSoundProfile.presets,
    );

final selectedNotificationSoundProfileProvider =
    FutureProvider<NotificationSoundProfile>((ref) async {
      final service = ref.watch(notificationServiceProvider);
      final profileId = await service.getReminderSoundProfileId();
      return NotificationSoundProfile.byId(profileId);
    });

final webhookEndpointsProvider = FutureProvider<List<Uri>>((ref) {
  return ref.watch(webhookDispatchServiceProvider).loadEndpoints();
});

final stripeCustomerIdProvider = FutureProvider<String?>((ref) {
  return ref.watch(localPreferencesServiceProvider).getStripeCustomerId();
});

final deepLinkServiceProvider = Provider<DeepLinkService>((ref) {
  final service = DeepLinkService();
  ref.onDispose(service.dispose);
  return service;
});

final deepLinkStreamProvider = StreamProvider<Uri>((ref) {
  return ref.watch(deepLinkServiceProvider).linkStream;
});

final timeConsistencyServiceProvider = Provider<TimeConsistencyService>(
  (ref) => TimeConsistencyService(),
);

final imagePickerProvider = Provider<ImagePicker>((ref) => ImagePicker());
final photoStorageServiceProvider = Provider<PhotoStorageService>((ref) {
  return PhotoStorageService(
    imagePicker: ref.watch(imagePickerProvider),
    moderationService: const ImageModerationService(),
  );
});

final crashRecoveryStoreProvider = Provider<CrashRecoveryStore>((ref) {
  throw StateError('CrashRecoveryStore is not initialised');
});

final operationsMetricsServiceProvider = Provider<OperationsMetricsService>((
  ref,
) {
  throw StateError('OperationsMetricsService is not initialised');
});

final operationsSnapshotProvider = FutureProvider<OperationsSnapshot>((
  ref,
) async {
  final service = ref.watch(operationsMetricsServiceProvider);
  return service.loadSnapshot();
});

final marketingAttributionServiceProvider =
    Provider<MarketingAttributionService>((ref) {
      return MarketingAttributionService(
        ref.watch(localPreferencesServiceProvider),
      );
    });

final inAppReviewServiceProvider = Provider<InAppReviewService>((ref) {
  return InAppReviewService(ref.watch(localPreferencesServiceProvider));
});

final ogpImageGeneratorProvider = Provider<OgpImageGenerator>((ref) {
  return OgpImageGenerator(ref.watch(appLoggerProvider));
});

final shareServiceProvider = Provider<ShareService>((ref) {
  return ShareService(ogpGenerator: ref.watch(ogpImageGeneratorProvider));
});

final appLocaleControllerProvider =
    StateNotifierProvider<AppLocaleController, Locale?>((ref) {
      return AppLocaleController(ref.watch(localPreferencesServiceProvider));
    });

final referralServiceProvider = Provider<ReferralService>((ref) {
  return ReferralService(analytics: ref.watch(analyticsServiceProvider));
});

final reEngagementServiceProvider = Provider<ReEngagementService>((ref) {
  return ReEngagementService();
});

final dataExportServiceProvider = Provider<DataExportService?>((ref) {
  final firestore = ref.watch(firestoreProvider);
  if (firestore == null) {
    return null;
  }
  return DataExportService(firestore);
});

final pairRepositoryProvider = Provider<PairRepository?>((ref) {
  final firestore = ref.watch(firestoreProvider);
  final storage = ref.watch(firebaseStorageProvider);
  if (firestore == null || storage == null) {
    return null;
  }
  return PairRepository(firestore, storage);
});

final firestoreSyncServiceProvider = Provider<FirestoreSyncService?>((ref) {
  final firestore = ref.watch(firestoreProvider);
  if (firestore == null) {
    return null;
  }
  final isar = ref.watch(isarProvider).value;
  if (isar == null) {
    throw StateError('Isar instance is not yet initialised');
  }
  return FirestoreSyncService(
    firestore,
    ref.watch(questLogRepositoryProvider),
    isar,
  );
});

final syncWorkerProvider = Provider<SyncWorker>((ref) {
  final connectivity = ref.watch(connectivityServiceProvider);
  final gamificationEngine = ref.watch(gamificationEngineProvider);
  final worker = SyncWorker(connectivity, gamificationEngine);
  ref.onDispose(worker.dispose);
  return worker;
});

final pairAssignmentStreamProvider =
    StreamProvider<DocumentSnapshot<Map<String, dynamic>>?>((ref) {
      final firestore = ref.watch(firestoreProvider);
      if (firestore == null) {
        return const Stream.empty();
      }
      final authState = ref.watch(authStateChangesProvider);
      final firebaseUser = authState.value;
      if (firebaseUser == null) {
        return const Stream.empty();
      }
      return firestore
          .collection('pair_assignments')
          .doc(firebaseUser.uid)
          .snapshots();
    });

final pairStreamProvider =
    StreamProvider<DocumentSnapshot<Map<String, dynamic>>?>((ref) {
      final pairRepository = ref.watch(pairRepositoryProvider);
      if (pairRepository == null) {
        return const Stream.empty();
      }
      final asyncUser = ref.watch(localUserProvider);
      final localUser = asyncUser.value;
      final pairId = localUser?.pairId;
      if (pairId == null || pairId.isEmpty) {
        return Stream<DocumentSnapshot<Map<String, dynamic>>?>.value(null);
      }
      return pairRepository
          .getPairStream(pairId)
          .map<DocumentSnapshot<Map<String, dynamic>>?>((snapshot) => snapshot);
    });

final pairByIdProvider = FutureProvider.family<minq_pair.Pair?, String>((
  ref,
  pairId,
) async {
  final pairRepository = ref.watch(pairRepositoryProvider);
  if (pairRepository == null) return null;
  return pairRepository.getPairById(pairId);
});
