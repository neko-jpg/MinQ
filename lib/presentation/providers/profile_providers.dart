import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:minq/core/profile/profile_service.dart';
import 'package:minq/core/sync/sync_queue_manager.dart';
import 'package:minq/core/sync/sync_providers.dart';
import 'package:minq/data/providers.dart';
import 'package:minq/domain/user/user_profile.dart';

/// Provider for ProfileService
final profileServiceProvider = Provider<ProfileService>((ref) {
  return ProfileService(
    isar: ref.watch(isarProvider).asData!.value,
    syncQueueManager: ref.watch(syncQueueManagerProvider),
  );
});

/// Provider for current user profile
final userProfileProvider = StreamProvider<UserProfile?>((ref) {
  final uid = ref.watch(uidProvider);
  if (uid == null) return Stream.value(null);

  final profileService = ref.watch(profileServiceProvider);
  return profileService.watchProfile(uid);
});

/// Provider for profile update operations
final profileUpdateProvider =
    StateNotifierProvider<ProfileUpdateNotifier, AsyncValue<void>>((ref) {
      return ProfileUpdateNotifier(ref.watch(profileServiceProvider));
    });

/// Notifier for handling profile updates
class ProfileUpdateNotifier extends StateNotifier<AsyncValue<void>> {
  ProfileUpdateNotifier(this._profileService)
    : super(const AsyncValue.data(null));

  final ProfileService _profileService;

  /// Update user profile
  Future<ProfileValidationResult> updateProfile(
    String uid,
    ProfileUpdateRequest request,
  ) async {
    state = const AsyncValue.loading();

    try {
      final result = await _profileService.updateProfile(uid, request);

      if (result.isValid) {
        state = const AsyncValue.data(null);
      } else {
        state = AsyncValue.error(
          ProfileUpdateException(result.errors),
          StackTrace.current,
        );
      }

      return result;
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      return ProfileValidationResult.invalid({'general': 'プロフィールの更新に失敗しました'});
    }
  }

  /// Generate new avatar seed
  String generateAvatarSeed() {
    return _profileService.generateAvatarSeed();
  }

  /// Get available focus tags
  List<String> getAvailableFocusTags() {
    return _profileService.getAvailableFocusTags();
  }

  /// Get available avatar seeds
  List<String> getAvailableAvatarSeeds() {
    return _profileService.getAvailableAvatarSeeds();
  }
}

/// Exception for profile update errors
class ProfileUpdateException implements Exception {
  final Map<String, String> errors;

  const ProfileUpdateException(this.errors);

  @override
  String toString() {
    return 'ProfileUpdateException: ${errors.values.join(', ')}';
  }
}

/// Provider for sync queue status related to profile
final profileSyncStatusProvider = StreamProvider<SyncQueueStatus>((ref) {
  final syncQueueManager = ref.watch(syncQueueManagerProvider);
  return syncQueueManager.statusStream
      .map((_) async {
        return await syncQueueManager.getStatus();
      })
      .asyncMap((future) => future);
});
