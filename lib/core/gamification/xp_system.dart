import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:minq/data/local/models/local_quest.dart';
import 'package:minq/data/providers.dart';
import 'package:minq/domain/gamification/xp_transaction.dart';
import 'package:minq/domain/gamification/xp_transaction_isar.dart';

/// XP (Experience Points) system for gamification.
///
/// Persists transactions in Isar, keeps `LocalUser` XP totals in sync, and
/// exposes light-weight analytics derived from stored history.
class XPSystem {
  XPSystem(this._isar);

  final Isar _isar;

  /// Award XP for the provided [action].
  ///
  /// The [context] map can supply optional modifiers:
  /// - `multiplier` (double/int) to scale [baseXP]
  /// - `bonus` (int) for additional flat XP
  /// - `streakBonus` / `difficultyBonus` (int)
  /// - `source` (String) to override the derived [XPSource]
  Future<XPGainResult> awardXP({
    required String userId,
    required String action,
    required int baseXP,
    Map<String, dynamic>? context,
  }) async {
    assert(baseXP >= 0, 'baseXP must be non-negative');

    return _isar.writeTxn<XPGainResult>(() async {
      final user =
          await _isar
              .collection<LocalUser>()
              .filter()
              .uidEqualTo(userId)
              .findFirst();
      if (user == null) {
        throw StateError('LocalUser($userId) not found');
      }

      final now = DateTime.now();
      final multiplier =
          ((context?['multiplier'] as num?)?.toDouble() ?? 1.0)
              .clamp(0.0, 10.0);
      final bonus = (context?['bonus'] as num?)?.round() ?? 0;
      final streakBonus = context?['streakBonus'] as int?;
      final difficultyBonus = context?['difficultyBonus'] as int?;
      final metadata = Map<String, dynamic>.from(context ?? const {});

      final computedXP =
          math.max(0, (baseXP * multiplier).round() + bonus.toInt());
      if (computedXP == 0) {
        return XPGainResult(
          xpGained: 0,
          newTotalXP: user.totalXP,
          previousLevel: user.currentLevel,
          newLevel: user.currentLevel,
          leveledUp: false,
          newRewards: const [],
          transaction: XPTransaction(
            id: 0,
            userId: userId,
            xpAmount: 0,
            reason: action,
            source: _resolveSource(action, metadata['source']),
            createdAt: now,
            metadata: metadata.isEmpty ? null : metadata,
            multiplier: multiplier != 1.0 ? multiplier : null,
            streakBonus: streakBonus,
            difficultyBonus: difficultyBonus,
          ),
        );
      }

      final previousLevelInfo = _levelInfoForXP(user.totalXP);
      final newTotalXP = user.totalXP + computedXP;
      user.totalXP = newTotalXP;
      user.currentXP = newTotalXP;
      user.weeklyXP += computedXP;
      user.updatedAt = now;
      user.needsSync = true;
      user.currentLevel = _levelInfoForXP(newTotalXP).level;
      await _isar.collection<LocalUser>().put(user);

      final transaction = XPTransaction(
        id: 0,
        userId: userId,
        xpAmount: computedXP,
        reason: action,
        source: _resolveSource(action, metadata['source']),
        createdAt: now,
        metadata: metadata.isEmpty ? null : metadata,
        multiplier: multiplier != 1.0 ? multiplier : null,
        streakBonus: streakBonus,
        difficultyBonus: difficultyBonus,
      );

      final isarTxn = XPTransactionIsar.fromDomain(transaction);
      final generatedId =
          await _isar.collection<XPTransactionIsar>().put(isarTxn);
      final storedTransaction = transaction.copyWith(id: generatedId);

      final newLevelInfo = _levelInfoForXP(newTotalXP);
      final leveledUp = newLevelInfo.level > previousLevelInfo.level;

      return XPGainResult(
        xpGained: computedXP,
        newTotalXP: newTotalXP,
        previousLevel: previousLevelInfo.level,
        newLevel: newLevelInfo.level,
        leveledUp: leveledUp,
        newRewards: leveledUp ? newLevelInfo.rewards : const [],
        transaction: storedTransaction,
      );
    });
  }

  /// Return the current level progress for the given [userId].
  Future<UserLevelProgress> getUserProgress(String userId) async {
    final user =
        await _isar
            .collection<LocalUser>()
            .filter()
            .uidEqualTo(userId)
            .findFirst();
    if (user == null) {
      throw StateError('LocalUser($userId) not found');
    }

    final currentLevelInfo = _levelInfoForXP(user.totalXP);
    final nextLevelInfo = _levelInfoForLevel(currentLevelInfo.level + 1);
    final xpIntoLevel = user.totalXP - currentLevelInfo.minXP;
    final xpToNextLevel = math.max(0, nextLevelInfo.minXP - user.totalXP);
    final levelRange = math.max(1, nextLevelInfo.minXP - currentLevelInfo.minXP);
    final progressToNext =
        levelRange == 0 ? 1.0 : xpIntoLevel.clamp(0, levelRange) / levelRange;

    return UserLevelProgress(
      currentLevel: currentLevelInfo.level,
      currentLevelName: currentLevelInfo.name,
      currentXP: user.totalXP,
      xpToNextLevel: xpToNextLevel,
      progressToNextLevel: progressToNext,
      isMaxLevel: nextLevelInfo.minXP == currentLevelInfo.minXP,
      currentLevelInfo: currentLevelInfo,
      nextLevelInfo:
          nextLevelInfo.minXP == currentLevelInfo.minXP ? null : nextLevelInfo,
    );
  }

  /// Fetch recent XP transactions for [userId].
  Future<List<XPTransaction>> getXPHistory(
    String userId, {
    int limit = 50,
  }) async {
    final records =
        await _isar
            .collection<XPTransactionIsar>()
            .filter()
            .userIdEqualTo(userId)
            .sortByCreatedAtDesc()
            .limit(limit)
            .findAll();
    return records.map((record) => record.toDomain()).toList();
  }

  /// Compute lightweight analytics for the player.
  Future<XPAnalytics> getXPAnalytics(String userId) async {
    final records =
        await _isar
            .collection<XPTransactionIsar>()
            .filter()
            .userIdEqualTo(userId)
            .findAll();

    if (records.isEmpty) {
      final now = DateTime.now();
      final empty = XPAnalytics.empty();
      return empty.copyWith(firstActivity: now, lastActivity: now);
    }

    final now = DateTime.now();
    final sorted =
        List<XPTransactionIsar>.from(records)
          ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

    final totalXP =
        records.fold<int>(0, (sum, txn) => sum + txn.xpAmount);
    final totalTransactions = records.length;

    final todayStart = DateTime(now.year, now.month, now.day);
    final weekStart = now.subtract(const Duration(days: 7));
    final monthStart = now.subtract(const Duration(days: 30));

    int sumSince(DateTime threshold) => records
        .where((txn) => txn.createdAt.isAfter(threshold))
        .fold<int>(0, (sum, txn) => sum + txn.xpAmount);

    final todayXP =
        records
            .where((txn) => !txn.createdAt.isBefore(todayStart))
            .fold<int>(0, (sum, txn) => sum + txn.xpAmount);
    final weeklyXP = sumSince(weekStart);
    final monthlyXP = sumSince(monthStart);

    final firstActivity = sorted.first.createdAt;
    final lastActivity = sorted.last.createdAt;
    final activeDays = math.max(
      1,
      lastActivity.difference(firstActivity).inDays + 1,
    );
    final averageDailyXP = totalXP / activeDays;
    final averagePerTransaction =
        totalTransactions == 0 ? 0.0 : totalXP / totalTransactions;

    final hourlyDistribution = <int, int>{};
    final weekdayDistribution = <int, int>{};
    final sourceTotals = <XPSource, List<XPTransactionIsar>>{};
    var totalStreakBonus = 0;
    var streakBonusTransactions = 0;

    for (final txn in records) {
      hourlyDistribution.update(
        txn.createdAt.hour,
        (value) => value + txn.xpAmount,
        ifAbsent: () => txn.xpAmount,
      );
      weekdayDistribution.update(
        txn.createdAt.weekday,
        (value) => value + txn.xpAmount,
        ifAbsent: () => txn.xpAmount,
      );
      sourceTotals.putIfAbsent(txn.source, () => []).add(txn);

      if (txn.streakBonus != null) {
        totalStreakBonus += txn.streakBonus!;
        streakBonusTransactions++;
      }
    }

    final mostActiveHour =
        hourlyDistribution.entries.isEmpty
            ? 0
            : hourlyDistribution.entries.reduce(
              (a, b) => a.value >= b.value ? a : b,
            ).key;
    final mostActiveWeekday =
        weekdayDistribution.entries.isEmpty
            ? 1
            : weekdayDistribution.entries.reduce(
              (a, b) => a.value >= b.value ? a : b,
            ).key;

    final sourceAnalysis = <XPSource, SourceAnalytics>{};
    XPSource? topSource;
    var topSourceXP = 0;

    sourceTotals.forEach((source, txns) {
      final sourceXP = txns.fold<int>(0, (sum, txn) => sum + txn.xpAmount);
      if (sourceXP > topSourceXP) {
        topSourceXP = sourceXP;
        topSource = source;
      }
      final avgXP =
          txns.isEmpty ? 0.0 : sourceXP / txns.length;
      sourceAnalysis[source] = SourceAnalytics(
        totalXP: sourceXP,
        transactionCount: txns.length,
        averageXP: avgXP,
        lastActivity: txns.last.createdAt,
      );
    });

    final weeklyXPPrev = records
        .where((txn) =>
            txn.createdAt.isAfter(weekStart.subtract(const Duration(days: 7))) &&
            txn.createdAt.isBefore(weekStart))
        .fold<int>(0, (sum, txn) => sum + txn.xpAmount);
    final growthTrend = _resolveGrowthTrend(weeklyXPPrev, weeklyXP);

    return XPAnalytics(
      totalXP: totalXP,
      totalTransactions: totalTransactions,
      todayXP: todayXP,
      weeklyXP: weeklyXP,
      monthlyXP: monthlyXP,
      averageXPPerDay: averageDailyXP,
      averageXPPerTransaction: averagePerTransaction,
      hourlyDistribution: hourlyDistribution,
      weekdayDistribution: weekdayDistribution,
      sourceAnalysis: sourceAnalysis,
      totalStreakBonus: totalStreakBonus,
      streakBonusTransactions: streakBonusTransactions,
      growthTrend: growthTrend,
      mostActiveHour: mostActiveHour,
      mostActiveWeekday: mostActiveWeekday,
      topSource: topSource,
      firstActivity: firstActivity,
      lastActivity: lastActivity,
    );
  }

  XPSource _resolveSource(String action, dynamic override) {
    if (override is String) {
      return XPSource.values.firstWhere(
        (source) => source.name == override,
        orElse: () => XPSource.specialEvent,
      );
    }
    final normalised = action.toLowerCase();
    if (normalised.contains('quest')) {
      return XPSource.questComplete;
    }
    if (normalised.contains('mini')) {
      return XPSource.miniQuestComplete;
    }
    if (normalised.contains('streak')) {
      return XPSource.streakMilestone;
    }
    if (normalised.contains('challenge')) {
      return XPSource.challengeComplete;
    }
    if (normalised.contains('weekly')) {
      return XPSource.weeklyGoal;
    }
    if (normalised.contains('monthly')) {
      return XPSource.monthlyGoal;
    }
    if (normalised.contains('comeback')) {
      return XPSource.comebackBonus;
    }
    if (normalised.contains('weekend')) {
      return XPSource.weekendActivity;
    }
    return XPSource.specialEvent;
  }

  LevelInfo _levelInfoForXP(int xp) {
    final level = _levelForXP(xp);
    return _levelInfoForLevel(level);
  }

  int _levelForXP(int xp) {
    var level = 1;
    while (true) {
      final required = _xpRequiredForLevel(level + 1);
      if (xp < required) {
        break;
      }
      level++;
      if (level >= _maxLevel) {
        break;
      }
    }
    return level;
  }

  LevelInfo _levelInfoForLevel(int level) {
    final clampedLevel = level.clamp(1, _maxLevel).toInt();
    final minXP = _xpRequiredForLevel(clampedLevel);
    final nextRequired =
        clampedLevel >= _maxLevel
            ? minXP
            : _xpRequiredForLevel(clampedLevel + 1);

    return LevelInfo(
      level: clampedLevel,
      name: 'Level $clampedLevel',
      description: 'Earn XP to unlock new rewards and features.',
      minXP: minXP,
      maxXP: clampedLevel >= _maxLevel ? minXP : nextRequired - 1,
      rewards: clampedLevel % 5 == 0 ? ['badge_level_$clampedLevel'] : const [],
      unlockedFeatures:
          clampedLevel >= _maxLevel ? const [] : ['feature_tier_$clampedLevel'],
    );
  }

  int _xpRequiredForLevel(int level) {
    if (level <= 1) return 0;
    // Quadratic progression keeps mid/late game meaningful.
    return (100 * math.pow(level - 1, 2)).round();
  }

  GrowthTrend _resolveGrowthTrend(int previous, int current) {
    if (previous == 0 && current == 0) {
      return GrowthTrend.stable;
    }
    if (current >= previous * 1.1) {
      return GrowthTrend.increasing;
    }
    if (current <= previous * 0.9) {
      return GrowthTrend.decreasing;
    }
    return GrowthTrend.stable;
  }

  static const int _maxLevel = 100;
}

/// Provider for the XP system backed by the shared Isar instance.
final xpSystemProvider = Provider<XPSystem>((ref) {
  final isarAsync = ref.watch(isarProvider);
  return isarAsync.when(
    data: XPSystem.new,
    loading: () => throw StateError('Isar instance is not yet initialised'),
    error: (error, _) => throw error,
  );
});
