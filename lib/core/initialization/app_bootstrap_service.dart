import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:minq/core/network/network_providers.dart';
import 'package:minq/core/providers/core_providers.dart';
import 'package:minq/data/services/notification_service.dart';
import 'package:minq/domain/user/user.dart' as minq_user;
import 'package:minq/features/auth/data/auth_providers.dart';
import 'package:minq/features/quest/data/quest_providers.dart';

class AppBootstrapService {
  final Ref _ref;

  AppBootstrapService(this._ref);

  Future<void> initialize() async {
    try {
      final localPrefs = _ref.read(localPreferencesServiceProvider);
      final isDummyMode = await localPrefs.isDummyDataModeEnabled();
      _ref.read(dummyDataModeProvider.notifier).state = isDummyMode;
      final notifications = _ref.read(notificationServiceProvider);
      final permissionGranted = await notifications.init();
      _ref.read(notificationPermissionProvider.notifier).state =
          permissionGranted;

      await _ref.read(remoteConfigServiceProvider).initialize();

      await _ref.read(connectivityServiceProvider).initialize();
      _ref.read(syncWorkerProvider).initialize();

      await _ref.watch(isarProvider.future);
      await _ref.read(questRepositoryProvider).seedInitialQuests();

      final firebaseAvailable = _ref.watch(firebaseAvailabilityProvider);
      if (!firebaseAvailable) {
        return;
      }

      final firebaseUser =
          await _ref.read(authRepositoryProvider).signInAnonymously();

      if (firebaseUser == null) {
        return;
      }

      final userRepo = _ref.read(userRepositoryProvider);
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

      final pairRepository = _ref.read(pairRepositoryProvider);
      if (pairRepository != null) {
        final assignment = await pairRepository.fetchAssignment(
          firebaseUser.uid,
        );
        final assignedPairId = assignment?['pairId'] as String?;
        if (assignedPairId != null && assignedPairId.isNotEmpty) {
          if (localUser.pairId != assignedPairId) {
            localUser.pairId = assignedPairId;
            await userRepo.saveLocalUser(localUser);
          }
        }
      }

      final logRepo = _ref.read(questLogRepositoryProvider);
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
          final hasCompleted = await _ref
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
            await _ref
                .read(timeConsistencyServiceProvider)
                .isDeviceTimeConsistent();
        final hasDrift = !timeConsistent;
        _ref.read(timeDriftDetectedProvider.notifier).state = hasDrift;
        if (hasDrift) {
          await notifications.suspendForTimeDrift();
        }
      } on SocketException catch (error) {
        debugPrint('Time consistency probe failed: $error');
      }

      final syncService = _ref.read(firestoreSyncServiceProvider);
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
      _ref.read(initializationErrorProvider.notifier).state = e;
    }
  }
}

final appBootstrapServiceProvider = Provider<AppBootstrapService>((ref) {
  return AppBootstrapService(ref);
});
