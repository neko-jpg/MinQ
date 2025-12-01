import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:isar/isar.dart';
import 'package:just_audio/just_audio.dart';
import 'package:miinq_integrations/miinq_integrations.dart';
import 'package:minq/config/stripe_config.dart';
import 'package:minq/core/challenges/challenge_service.dart';
import 'package:minq/core/export/data_export_service.dart';
import 'package:minq/core/gamification/gamification_engine.dart';
import 'package:minq/core/gamification/reward_system.dart';
import 'package:minq/core/logging/app_logger.dart';
import 'package:minq/core/network/network_status_service.dart';
import 'package:minq/core/notifications/re_engagement_service.dart';
import 'package:minq/core/reminders/multiple_reminder_service.dart';
import 'package:minq/core/sharing/ai_share_banner_service.dart';
import 'package:minq/core/sharing/ogp_image_generator.dart';
import 'package:minq/core/sharing/share_service.dart';
import 'package:minq/data/repositories/community_board_repository.dart';
import 'package:minq/data/repositories/contact_link_repository.dart';
import 'package:minq/data/repositories/firebase_auth_repository.dart';
import 'package:minq/data/repositories/pair_repository.dart';
import 'package:minq/data/repositories/quest_log_repository.dart';
import 'package:minq/data/repositories/quest_repository.dart';
import 'package:minq/data/repositories/user_repository.dart';
import 'package:minq/data/services/analytics_service.dart';
import 'package:minq/data/services/app_locale_controller.dart';
import 'package:minq/data/services/connectivity_service.dart';
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
import 'package:minq/data/services/time_consistency_service.dart';
import 'package:minq/data/services/usage_limit_service.dart';
import 'package:minq/data/services/webhook_dispatch_service.dart';
import 'package:minq/domain/log/quest_log.dart';
import 'package:minq/domain/notification/notification_sound_profile.dart';
import 'package:minq/domain/pair/pair.dart' as minq_pair;
import 'package:minq/domain/quest/quest.dart';
import 'package:minq/domain/recommendation/daily_focus_service.dart';
import 'package:minq/domain/recommendation/habit_ai_suggestion_service.dart';
import 'package:minq/domain/user/user.dart' as minq_user;
import 'package:speech_to_text/speech_to_text.dart';

final httpClientProvider = Provider<http.Client>((ref) {
  final client = http.Client();
  ref.onDispose(client.close);
  return client;
});

final appLoggerProvider = Provider<AppLogger>((ref) {
  final logger = AppLogger();
  logger.initialize();
  return logger;
});

final remoteConfigServiceProvider = Provider<RemoteConfigService>((ref) {
  return RemoteConfigService(ref.watch(remoteConfigProvider));
});

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

final localPreferencesServiceProvider = Provider<LocalPreferencesService>(
  (_) => LocalPreferencesService(),
);

final connectivityServiceProvider = Provider<ConnectivityService>((ref) {
  return ConnectivityService();
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

// TODO: Fix integrations package
final aiShareBannerServiceProvider = Provider<AIShareBannerService>((ref) {
  return AIShareBannerService(generator: const AIBannerGenerator());
});

final shareServiceProvider = Provider<ShareService>((ref) {
  return ShareService(
    ogpGenerator: ref.watch(ogpImageGeneratorProvider),
    aiBannerService: ref.watch(aiShareBannerServiceProvider),
  );
});

final appLocaleControllerProvider =
    StateNotifierProvider<AppLocaleController, Locale?>((ref) {
      return AppLocaleController(ref.watch(localPreferencesServiceProvider));
    });

final firebaseAvailabilityProvider = Provider<bool>((_) => true);

final firebaseAuthProvider = Provider<FirebaseAuth?>(
  (ref) =>
      ref.watch(firebaseAvailabilityProvider) ? FirebaseAuth.instance : null,
);
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

final analyticsServiceProvider = Provider<AnalyticsService>((ref) {
  return AnalyticsService(ref.watch(firebaseAnalyticsProvider));
});

final referralServiceProvider = Provider<ReferralService>((ref) {
  return ReferralService(
    analytics: ref.watch(analyticsServiceProvider),
  );
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

// TODO: Implement FeatureFlagsNotifier
// final featureFlagsProvider =
//     StateNotifierProvider<FeatureFlagsNotifier, FeatureFlags>((ref) {
//   return FeatureFlagsNotifier(ref.watch(remoteConfigProvider));
// });

final isarProvider = FutureProvider<Isar>((ref) async {
  final isarService = IsarService();
  return isarService.init();
});

final authRepositoryProvider = Provider<IAuthRepository>((ref) {
  return FirebaseAuthRepository(ref.watch(firebaseAuthProvider));
});

final guestUserIdProvider = StateProvider<String?>((ref) => null);

QuestRepository _buildQuestRepository(Ref ref) {
  final isar = ref.watch(isarProvider).value;
  if (isar == null) {
    throw StateError('Isar instance is not yet initialised');
  }
  return QuestRepository(isar);
}

QuestLogRepository _buildQuestLogRepository(Ref ref) {
  final isar = ref.watch(isarProvider).value;
  if (isar == null) {
    throw StateError('Isar instance is not yet initialised');
  }
  return QuestLogRepository(isar);
}

UserRepository _buildUserRepository(Ref ref) {
  final isar = ref.watch(isarProvider).value;
  if (isar == null) {
    throw StateError('Isar instance is not yet initialised');
  }
  final authRepository = ref.watch(authRepositoryProvider);
  return UserRepository(isar, authRepository);
}

final questRepositoryProvider = Provider<QuestRepository>(
  _buildQuestRepository,
);
final questLogRepositoryProvider = Provider<QuestLogRepository>(
  _buildQuestLogRepository,
);
final userRepositoryProvider = Provider<UserRepository>(_buildUserRepository);

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

final appStartupProvider = FutureProvider<void>((ref) async {
  try {
    final localPrefs = ref.read(localPreferencesServiceProvider);
    final isDummyMode = await localPrefs.isDummyDataModeEnabled();
    ref.read(dummyDataModeProvider.notifier).state = isDummyMode;
    final notifications = ref.read(notificationServiceProvider);
    final permissionGranted = await notifications.init();
    ref.read(notificationPermissionProvider.notifier).state = permissionGranted;

    await ref.read(remoteConfigServiceProvider).initialize();

    await ref.watch(isarProvider.future);
    await ref.read(questRepositoryProvider).seedInitialQuests();

    final firebaseAvailable = ref.watch(firebaseAvailabilityProvider);
    if (!firebaseAvailable) {
      return;
    }

    final firebaseUser =
        await ref.read(authRepositoryProvider).signInAnonymously();

    if (firebaseUser == null) {
      return;
    }

    final userRepo = ref.read(userRepositoryProvider);
    var localUser = await userRepo.getUserById(firebaseUser.uid);
    if (localUser == null) {
      localUser =
          minq_user.User()
            ..uid = firebaseUser.uid
            ..createdAt = DateTime.now()
            ..notificationTimes = List.of(
              NotificationService.defaultReminderTimes,
            )
            ..privacy = 'private'
            ..longestStreak = 0
            ..currentStreak = 0;
      await userRepo.saveLocalUser(localUser);
    } else if (localUser.notificationTimes.isEmpty) {
      localUser.notificationTimes = List.of(
        NotificationService.defaultReminderTimes,
      );
      await userRepo.saveLocalUser(localUser);
    }

    final pairRepository = ref.read(pairRepositoryProvider);
    if (pairRepository != null) {
      final assignment = await pairRepository.fetchAssignment(firebaseUser.uid);
      final assignedPairId = assignment?['pairId'] as String?;
      if (assignedPairId != null && assignedPairId.isNotEmpty) {
        if (localUser.pairId != assignedPairId) {
          localUser.pairId = assignedPairId;
          await userRepo.saveLocalUser(localUser);
        }
      }
    }

    final logRepo = ref.read(questLogRepositoryProvider);
    final currentStreak = await logRepo.calculateStreak(localUser.uid);
    final longestStreak = await logRepo.calculateLongestStreak(localUser.uid);
    final previousLongest = localUser.longestStreak;
    if (localUser.currentStreak != currentStreak ||
        localUser.longestStreak != longestStreak) {
      await userRepo.updateStreaks(
        localUser.uid,
        currentStreak: currentStreak,
        longestStreak: longestStreak,
        longestStreakReachedAt:
            longestStreak > previousLongest
                ? DateTime.now()
                : localUser.longestStreakReachedAt,
      );
      localUser.currentStreak = currentStreak;
      localUser.longestStreak = longestStreak;
      if (longestStreak > previousLongest) {
        localUser.longestStreakReachedAt = DateTime.now();
      }
    }

    final reminderTimes = List<String>.from(localUser.notificationTimes);
    final recurringTimes = reminderTimes.take(2).toList();
    final auxiliaryTime = reminderTimes.length > 2 ? reminderTimes[2] : null;

    if (permissionGranted) {
      await notifications.ensureTimezoneConsistency(
        fallbackRecurring: recurringTimes,
        fallbackAuxiliary: auxiliaryTime,
      );
      if (recurringTimes.isNotEmpty) {
        await notifications.scheduleRecurringReminders(recurringTimes);
      }

      if (auxiliaryTime != null) {
        final hasCompleted = await ref
            .read(questLogRepositoryProvider)
            .hasCompletedDailyGoal(localUser.uid);
        if (hasCompleted) {
          await notifications.cancelAuxiliaryReminder();
        } else {
          await notifications.scheduleAuxiliaryReminder(auxiliaryTime);
        }
      } else {
        await notifications.cancelAuxiliaryReminder();
      }
      await notifications.resumeFromTimeDrift();
    }
    if (!permissionGranted) {
      await notifications.ensureTimezoneConsistency(
        fallbackRecurring: const <String>[],
        fallbackAuxiliary: null,
      );
      await notifications.cancelAll();
    }

    try {
      final timeConsistent =
          await ref
              .read(timeConsistencyServiceProvider)
              .isDeviceTimeConsistent();
      final hasDrift = !timeConsistent;
      ref.read(timeDriftDetectedProvider.notifier).state = hasDrift;
      if (hasDrift) {
        await notifications.suspendForTimeDrift();
      }
    } on SocketException catch (error) {
      debugPrint('Time consistency probe failed: $error');
    }

    final syncService = ref.read(firestoreSyncServiceProvider);
    if (syncService != null) {
      try {
        await syncService.syncQuestLogs(firebaseUser.uid);
      } on FirebaseException catch (error) {
        debugPrint('Quest log sync failed: ${error.code}');
      }
    }

    // TODO: Implement featureFlagsProvider
    // await ref.read(featureFlagsProvider.notifier).ensureLoaded();
  } catch (e) {
    ref.read(initializationErrorProvider.notifier).state = e;
  }
});

final authStateChangesProvider = StreamProvider<User?>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges;
});

final localUserProvider = FutureProvider<minq_user.User?>((ref) async {
  final authState = ref.watch(authStateChangesProvider);
  final guestUid = ref.watch(guestUserIdProvider);
  return authState.when(
    data: (firebaseUser) async {
      final uid = firebaseUser?.uid ?? guestUid;
      if (uid == null) {
        return null;
      }
      return ref.watch(userRepositoryProvider).getUserById(uid);
    },
    error: (_, __) => Future.value(null),
    loading: () => Future.value(null),
  );
});

final uidProvider = Provider<String?>((ref) {
  final guestUid = ref.watch(guestUserIdProvider);
  if (guestUid != null) {
    return guestUid;
  }
  final authState = ref.watch(authStateChangesProvider);
  return authState.value?.uid;
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

Future<void> _ensureStartup(Ref ref) async {
  await ref.watch(appStartupProvider.future);
}

final allQuestsProvider = FutureProvider<List<Quest>>((ref) async {
  await _ensureStartup(ref);
  return ref.read(questRepositoryProvider).getAllQuests();
});

final templateQuestsProvider = FutureProvider<List<Quest>>((ref) async {
  await _ensureStartup(ref);
  return ref.read(questRepositoryProvider).getTemplateQuests();
});

final userQuestsProvider = FutureProvider<List<Quest>>((ref) async {
  await _ensureStartup(ref);
  final user = await ref.watch(localUserProvider.future);
  if (user == null) {
    return [];
  }
  return ref.read(questRepositoryProvider).getQuestsForOwner(user.uid);
});
final questByIdProvider = FutureProvider.family<Quest?, int>((ref, id) async {
  await _ensureStartup(ref);
  return ref.read(questRepositoryProvider).getQuestById(id);
});

final questContactLinkProvider = FutureProvider.family<String?, int>((
  ref,
  questId,
) async {
  return ref.watch(contactLinkRepositoryProvider).getLink(questId);
});

final streakProvider = FutureProvider<int>((ref) async {
  await _ensureStartup(ref);
  final user = await ref.watch(localUserProvider.future);
  if (user == null) {
    return 0;
  }
  return ref.read(questLogRepositoryProvider).calculateStreak(user.uid);
});

final longestStreakProvider = FutureProvider<int>((ref) async {
  await _ensureStartup(ref);
  final user = await ref.watch(localUserProvider.future);
  if (user == null) {
    return 0;
  }
  return ref.read(questLogRepositoryProvider).calculateLongestStreak(user.uid);
});

final todayCompletionCountProvider = FutureProvider<int>((ref) async {
  await _ensureStartup(ref);
  final user = await ref.watch(localUserProvider.future);
  if (user == null) {
    return 0;
  }
  return ref
      .read(questLogRepositoryProvider)
      .countLogsForDay(user.uid, DateTime.now());
});

final recentLogsProvider = FutureProvider<List<QuestLog>>((ref) async {
  await _ensureStartup(ref);
  final user = await ref.watch(localUserProvider.future);
  if (user == null) {
    return [];
  }
  final logs = await ref
      .read(questLogRepositoryProvider)
      .getLogsForUser(user.uid);
  return logs.take(30).toList();
});

final habitAiSuggestionServiceProvider = Provider<HabitAiSuggestionService>(
  (ref) {
    return HabitAiSuggestionService();
  },
);

// UID provider removed - already exists above

// Network status provider
final networkStatusProvider = Provider<NetworkStatusService>((ref) {
  return NetworkStatusService();
});

final dailyFocusServiceProvider = Provider<DailyFocusService>(
  (ref) => DailyFocusService(),
);

final habitAiSuggestionsProvider = FutureProvider<List<HabitAiSuggestion>>((
  ref,
) async {
  await _ensureStartup(ref);
  final logs = await ref.watch(recentLogsProvider.future);
  final quests = await ref.watch(userQuestsProvider.future);
  final service = ref.watch(habitAiSuggestionServiceProvider);
  return await service.generateSuggestions(
    userQuests: quests,
    logs: logs,
    now: DateTime.now(),
  );
});
final heatmapDataProvider = FutureProvider<Map<DateTime, int>>((ref) async {
  await _ensureStartup(ref);
  final user = await ref.watch(localUserProvider.future);
  if (user == null) {
    return {};
  }
  return ref.read(questLogRepositoryProvider).getHeatmapData(user.uid);
});

// Gamification providers
final gamificationEngineProvider = Provider<GamificationEngine>((ref) {
  final firestore = ref.watch(firestoreProvider);
  if (firestore == null) {
    throw StateError('Firestore is not available');
  }
  return GamificationEngine(firestore);
});

final rewardSystemProvider = Provider<RewardSystem>((ref) {
  final firestore = ref.watch(firestoreProvider);
  if (firestore == null) {
    throw StateError('Firestore is not available');
  }
  return RewardSystem(firestore);
});

final challengeServiceProvider = Provider<ChallengeService>((ref) {
  final firestore = ref.watch(firestoreProvider);
  if (firestore == null) {
    throw StateError('Firestore is not available');
  }
  final gamificationEngine = ref.watch(gamificationEngineProvider);
  return ChallengeService(firestore, gamificationEngine);
});

// AI providers - 既にgemma_ai_service.dartで定義されているので削除
