import 'package:isar/isar.dart';
import 'package:minq/data/repositories/firebase_auth_repository.dart';
import 'package:minq/domain/user/user.dart';

class UserRepository {
  UserRepository(this._isar, this._authRepository);

  final Isar _isar;
  final IAuthRepository _authRepository;

  Future<User?> getCurrentUser() async {
    final firebaseUser = _authRepository.getCurrentUser();
    if (firebaseUser == null) {
      return null;
    }
    return getUserById(firebaseUser.uid);
  }

  Future<User?> getUserById(String uid) async {
    return _isar.users.filter().uidEqualTo(uid).findFirst();
  }

  Future<void> saveLocalUser(User user) async {
    await _isar.writeTxn(() async {
      await _isar.users.put(user);
    });
  }

  Future<void> upsertProfile(
    String uid, {
    String? displayName,
    String? handle,
    String? bio,
    String? avatarSeed,
    List<String>? focusTags,
  }) async {
    await _isar.writeTxn(() async {
      final user = await getUserById(uid);
      if (user == null) {
        return;
      }
      if (displayName != null) {
        user.displayName = displayName.trim();
      }
      if (handle != null) {
        final trimmed = handle.trim();
        user.handle = trimmed.isEmpty ? null : trimmed.toLowerCase();
      }
      if (bio != null) {
        user.bio = bio.trim();
      }
      if (avatarSeed != null && avatarSeed.trim().isNotEmpty) {
        user.avatarSeed = avatarSeed.trim();
      }
      if (focusTags != null) {
        user.focusTags = focusTags.map((tag) => tag.trim()).toList();
      }
      await _isar.users.put(user);
    });
  }

  Future<void> updateNotificationTimes(String uid, List<String> times) async {
    await _isar.writeTxn(() async {
      final user = await getUserById(uid);
      if (user == null) {
        return;
      }
      user.notificationTimes = List.of(times);
      await _isar.users.put(user);
    });
  }

  Future<void> updateStreaks(
    String uid, {
    int? currentStreak,
    int? longestStreak,
    DateTime? longestStreakReachedAt,
  }) async {
    await _isar.writeTxn(() async {
      final user = await getUserById(uid);
      if (user == null) {
        return;
      }
      if (currentStreak != null) {
        user.currentStreak = currentStreak;
      }
      if (longestStreak != null) {
        user.longestStreak = longestStreak;
      }
      if (longestStreakReachedAt != null) {
        user.longestStreakReachedAt = longestStreakReachedAt;
      }
      await _isar.users.put(user);
    });
  }

  Future<void> updatePairId(String uid, String? pairId) async {
    await _isar.writeTxn(() async {
      final user = await getUserById(uid);
      if (user == null) {
        return;
      }
      user.pairId = pairId;
      await _isar.users.put(user);
    });
  }

  Future<User?> getUser(String uid) async {
    return getUserById(uid);
  }

  Future<void> updateUser(String uid, Map<String, dynamic> updates) async {
    await _isar.writeTxn(() async {
      final user = await getUserById(uid);
      if (user == null) {
        return;
      }

      // Apply updates based on the map
      if (updates.containsKey('onboardingCompleted')) {
        user.onboardingCompleted = updates['onboardingCompleted'] as bool;
      }
      if (updates.containsKey('currentLevel')) {
        user.currentLevel = updates['currentLevel'] as int;
      }
      if (updates.containsKey('totalPoints')) {
        user.totalPoints = updates['totalPoints'] as int;
      }

      await _isar.users.put(user);
    });
  }
}
