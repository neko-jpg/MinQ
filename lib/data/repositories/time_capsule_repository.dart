import 'package:isar/isar.dart';
import 'package:minq/domain/time_capsule/time_capsule.dart';

/// Repository for managing time capsules with real Isar database integration
class TimeCapsuleRepository {
  TimeCapsuleRepository(this._isar);

  final Isar _isar;

  /// Get all time capsules for a user
  Future<List<TimeCapsule>> getTimeCapsules(String userId) async {
    return _isar.timeCapsules
        .filter()
        .userIdEqualTo(userId)
        .sortByCreatedAtDesc()
        .findAll();
  }

  /// Get delivered time capsules for a user
  Future<List<TimeCapsule>> getDeliveredTimeCapsules(String userId) async {
    final now = DateTime.now();
    return _isar.timeCapsules
        .filter()
        .userIdEqualTo(userId)
        .deliveryDateLessThan(now)
        .sortByDeliveryDateDesc()
        .findAll();
  }

  /// Get pending time capsules for a user
  Future<List<TimeCapsule>> getPendingTimeCapsules(String userId) async {
    final now = DateTime.now();
    return _isar.timeCapsules
        .filter()
        .userIdEqualTo(userId)
        .deliveryDateGreaterThan(now)
        .sortByDeliveryDate()
        .findAll();
  }

  /// Create a new time capsule
  Future<void> createTimeCapsule(TimeCapsule timeCapsule) async {
    await _isar.writeTxn(() async {
      await _isar.timeCapsules.put(timeCapsule);
    });
  }

  /// Update an existing time capsule
  Future<void> updateTimeCapsule(TimeCapsule timeCapsule) async {
    await _isar.writeTxn(() async {
      await _isar.timeCapsules.put(timeCapsule);
    });
  }

  /// Delete a time capsule
  Future<void> deleteTimeCapsule(int id) async {
    await _isar.writeTxn(() async {
      await _isar.timeCapsules.delete(id);
    });
  }

  /// Get time capsule by ID
  Future<TimeCapsule?> getTimeCapsuleById(int id) async {
    return _isar.timeCapsules.get(id);
  }

  /// Get statistics for time capsules
  Future<TimeCapsuleStats> getStats(String userId) async {
    final all = await getTimeCapsules(userId);
    final delivered = await getDeliveredTimeCapsules(userId);
    final pending = await getPendingTimeCapsules(userId);

    return TimeCapsuleStats(
      total: all.length,
      delivered: delivered.length,
      pending: pending.length,
    );
  }

  /// Seed initial time capsules for new users
  Future<void> seedInitialTimeCapsules(String userId) async {
    final existing = await getTimeCapsules(userId);
    if (existing.isNotEmpty) return;

    final now = DateTime.now();
    final initialCapsules = [
      TimeCapsule()
        ..userId = userId
        ..message = 'MinQで習慣化の旅を始めました。継続の力を信じて頑張ります！'
        ..prediction = 'あなたの努力が実を結び、素晴らしい成果を上げていることでしょう。'
        ..createdAt = now
        ..deliveryDate = now.add(const Duration(days: 30)),
    ];

    await _isar.writeTxn(() async {
      await _isar.timeCapsules.putAll(initialCapsules);
    });
  }
}

/// Statistics for time capsules
class TimeCapsuleStats {
  final int total;
  final int delivered;
  final int pending;

  const TimeCapsuleStats({
    required this.total,
    required this.delivered,
    required this.pending,
  });
}