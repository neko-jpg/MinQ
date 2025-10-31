import 'dart:async';
import 'dart:math' as math;

import 'package:isar/isar.dart';
import 'package:minq/core/sync/sync_queue_manager.dart';
import 'package:minq/data/logging/minq_logger.dart';
import 'package:minq/domain/user/user.dart';
import 'package:minq/domain/user/user_profile.dart';

/// Service for managing user profile operations with offline-first support
class ProfileService {
  ProfileService({
    required Isar isar,
    required SyncQueueManager syncQueueManager,
  }) : _isar = isar, _syncQueueManager = syncQueueManager;

  final Isar _isar;
  final SyncQueueManager _syncQueueManager;

  /// Get user profile by UID
  Future<UserProfile?> getProfile(String uid) async {
    final user = await _isar.users.filter().uidEqualTo(uid).findFirst();
    if (user == null) return null;
    
    return _userToProfile(user);
  }

  /// Watch user profile changes
  Stream<UserProfile?> watchProfile(String uid) {
    return _isar.users
        .filter()
        .uidEqualTo(uid)
        .watch(fireImmediately: true)
        .map((users) => users.isEmpty ? null : _userToProfile(users.first));
  }

  /// Update user profile with validation and sync
  Future<ProfileValidationResult> updateProfile(
    String uid,
    ProfileUpdateRequest request,
  ) async {
    // Validate the update request
    final validation = _validateProfileUpdate(request);
    if (!validation.isValid) {
      return validation;
    }

    try {
      await _isar.writeTxn(() async {
        final user = await _isar.users.filter().uidEqualTo(uid).findFirst();
        if (user == null) {
          throw Exception('User not found');
        }

        // Apply updates
        if (request.displayName != null) {
          user.displayName = request.displayName!.trim();
        }
        if (request.handle != null) {
          final trimmed = request.handle!.trim();
          user.handle = trimmed.isEmpty ? null : trimmed.toLowerCase();
        }
        if (request.bio != null) {
          user.bio = request.bio!.trim();
        }
        if (request.avatarSeed != null) {
          user.avatarSeed = request.avatarSeed!;
        }
        if (request.focusTags != null) {
          user.focusTags = request.focusTags!
              .map((tag) => tag.trim())
              .where((tag) => tag.isNotEmpty)
              .take(5)
              .toList();
        }
        if (request.notificationTimes != null) {
          user.notificationTimes = List.from(request.notificationTimes!);
        }
        if (request.privacy != null) {
          user.privacy = request.privacy!;
        }

        await _isar.users.put(user);

        // Enqueue sync job
        await _enqueueSyncJob(user);
      });

      MinqLogger.info('Profile updated successfully', metadata: {
        'uid': uid,
        'fields': request.toJson().keys.toList(),
      });

      return ProfileValidationResult.valid();
    } catch (e, stackTrace) {
      MinqLogger.error('Failed to update profile', 
          error: e, stackTrace: stackTrace, metadata: {'uid': uid});
      
      return ProfileValidationResult.invalid({
        'general': 'Failed to update profile. Please try again.',
      });
    }
  }

  /// Generate a new avatar seed
  String generateAvatarSeed() {
    final random = math.Random();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final randomValue = random.nextInt(999999);
    return 'seed-$timestamp-$randomValue';
  }

  /// Get avatar URL from seed
  String getAvatarUrl(String seed) {
    return 'https://api.dicebear.com/7.x/avataaars/svg?seed=$seed';
  }

  /// Get available avatar seeds for selection
  List<String> getAvailableAvatarSeeds() {
    return [
      'seed-01',
      'seed-02', 
      'seed-03',
      'seed-04',
      'seed-05',
      'seed-06',
      'seed-07',
      'seed-08',
      'seed-09',
      'seed-10',
    ];
  }

  /// Get available focus tags
  List<String> getAvailableFocusTags() {
    return [
      'Productivity',
      'Health',
      'Learning',
      'Reading',
      'Languages',
      'Creative',
      'Fitness',
      'Mindfulness',
      'Home',
      'Career',
      'Cooking',
      'Music',
      'Art',
      'Writing',
      'Technology',
      'Nature',
      'Travel',
      'Social',
      'Finance',
      'Spirituality',
    ];
  }

  /// Validate profile update request
  ProfileValidationResult _validateProfileUpdate(ProfileUpdateRequest request) {
    final errors = <String, String>{};

    // Validate display name
    if (request.displayName != null) {
      final displayName = request.displayName!.trim();
      if (displayName.isEmpty) {
        errors['displayName'] = 'Display name is required';
      } else if (displayName.length > 30) {
        errors['displayName'] = 'Display name must be 30 characters or fewer';
      } else if (displayName.length < 2) {
        errors['displayName'] = 'Display name must be at least 2 characters';
      }
    }

    // Validate handle
    if (request.handle != null && request.handle!.isNotEmpty) {
      final handle = request.handle!.trim();
      final handlePattern = RegExp(r'^[a-zA-Z0-9_]{3,20}$');
      if (!handlePattern.hasMatch(handle)) {
        errors['handle'] = 'Handle must be 3-20 characters (letters, numbers, underscore only)';
      }
    }

    // Validate bio
    if (request.bio != null && request.bio!.length > 160) {
      errors['bio'] = 'Bio must be 160 characters or fewer';
    }

    // Validate focus tags
    if (request.focusTags != null && request.focusTags!.length > 5) {
      errors['focusTags'] = 'You can select up to 5 focus tags';
    }

    // Validate privacy setting
    if (request.privacy != null) {
      final validPrivacySettings = ['public', 'friends', 'private'];
      if (!validPrivacySettings.contains(request.privacy)) {
        errors['privacy'] = 'Invalid privacy setting';
      }
    }

    return errors.isEmpty
        ? ProfileValidationResult.valid()
        : ProfileValidationResult.invalid(errors);
  }

  /// Convert User entity to UserProfile
  UserProfile _userToProfile(User user) {
    return UserProfile(
      id: user.id.toString(),
      uid: user.uid,
      displayName: user.displayName,
      email: '', // Email is handled separately in auth
      handle: user.handle,
      bio: user.bio,
      avatarSeed: user.avatarSeed,
      focusTags: List.from(user.focusTags),
      notificationTimes: List.from(user.notificationTimes),
      privacy: user.privacy,
      longestStreak: user.longestStreak,
      currentStreak: user.currentStreak,
      longestStreakReachedAt: user.longestStreakReachedAt,
      pairId: user.pairId,
      onboardingCompleted: user.onboardingCompleted,
      onboardingLevel: user.onboardingLevel,
      currentLevel: user.currentLevel,
      totalPoints: user.totalPoints,
      createdAt: user.createdAt,
      updatedAt: DateTime.now(),
      needsSync: false, // Computed based on sync status
      syncStatus: 'synced', // Default to synced
    );
  }

  /// Enqueue sync job for profile update
  Future<void> _enqueueSyncJob(User user) async {
    final syncJob = SyncJob()
      ..entityType = 'user'
      ..entityId = user.uid
      ..operation = 'update'
      ..data = {
        'uid': user.uid,
        'displayName': user.displayName,
        'handle': user.handle,
        'bio': user.bio,
        'avatarSeed': user.avatarSeed,
        'focusTags': user.focusTags,
        'notificationTimes': user.notificationTimes,
        'privacy': user.privacy,
        'longestStreak': user.longestStreak,
        'currentStreak': user.currentStreak,
        'longestStreakReachedAt': user.longestStreakReachedAt?.toIso8601String(),
        'pairId': user.pairId,
        'onboardingCompleted': user.onboardingCompleted,
        'onboardingLevel': user.onboardingLevel,
        'currentLevel': user.currentLevel,
        'totalPoints': user.totalPoints,
        'createdAt': user.createdAt.toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      }
      ..createdAt = DateTime.now()
      ..priority = 2; // High priority for user updates

    await _syncQueueManager.enqueueSyncJob(syncJob);
  }
}