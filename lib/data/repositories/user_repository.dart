﻿import 'package:isar/isar.dart';
import 'package:minq/domain/user/user.dart';

class UserRepository {
  UserRepository(this._isar);

  final Isar _isar;

  Future<User?> getLocalUser(String uid) async {
    return _isar.users.filter().uidEqualTo(uid).findFirst();
  }

  Future<void> saveLocalUser(User user) async {
    await _isar.writeTxn(() async {
      await _isar.users.put(user);
    });
  }

  Future<void> updateNotificationTimes(String uid, List<String> times) async {
    await _isar.writeTxn(() async {
      final user = await getLocalUser(uid);
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
      final user = await getLocalUser(uid);
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
      final user = await getLocalUser(uid);
      if (user == null) {
        return;
      }
      user.pairId = pairId;
      await _isar.users.put(user);
    });
  }
}


