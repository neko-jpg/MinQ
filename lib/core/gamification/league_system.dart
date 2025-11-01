import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:minq/data/local/models/local_quest.dart';
import 'package:minq/domain/gamification/league.dart';

/// League management engine that handles league operations, promotions, and rankings
class LeagueSystem {
  final Isar _isar;
  final Ref _ref;

  LeagueSystem(this._isar, this._ref);

  /// League configurations with thresholds and rewards
  static const Map<String, LeagueConfig> leagues = {
    'bronze': LeagueConfig(
      id: 'bronze',
      name: 'ブロンズリーグ',
      nameEn: 'Bronze League',
      color: Color(0xFFB45309),
      minXP: 0,
      maxXP: 999,
      promotionThreshold: 800,
      relegationThreshold: 0,
      weeklyXPRequirement: 100,
      maxParticipants: 50,
      rewards: LeagueRewards(
        weeklyXP: 50,
        badges: ['bronze_warrior'],
        unlocks: ['basic_customization'],
      ),
    ),
    'silver': LeagueConfig(
      id: 'silver',
      name: 'シルバ�Eリーグ',
      nameEn: 'Silver League',
      color: Color(0xFF9CA3AF),
      minXP: 1000,
      maxXP: 2999,
      promotionThreshold: 2500,
      relegationThreshold: 1200,
      weeklyXPRequirement: 200,
      maxParticipants: 40,
      rewards: LeagueRewards(
        weeklyXP: 100,
        badges: ['silver_champion'],
        unlocks: ['advanced_themes', 'priority_support'],
      ),
    ),
    'gold': LeagueConfig(
      id: 'gold',
      name: 'ゴールドリーグ',
      nameEn: 'Gold League',
      color: Color(0xFFF59E0B),
      minXP: 3000,
      maxXP: 6999,
      promotionThreshold: 6000,
      relegationThreshold: 3500,
      weeklyXPRequirement: 350,
      maxParticipants: 30,
      rewards: LeagueRewards(
        weeklyXP: 200,
        badges: ['gold_master'],
        unlocks: ['premium_analytics', 'exclusive_challenges'],
      ),
    ),
    'platinum': LeagueConfig(
      id: 'platinum',
      name: 'プラチナリーグ',
      nameEn: 'Platinum League',
      color: Color(0xFF8B5CF6),
      minXP: 7000,
      maxXP: 14999,
      promotionThreshold: 13000,
      relegationThreshold: 8000,
      weeklyXPRequirement: 500,
      maxParticipants: 20,
      rewards: LeagueRewards(
        weeklyXP: 350,
        badges: ['platinum_legend'],
        unlocks: ['ai_coach_priority', 'custom_animations'],
      ),
    ),
    'diamond': LeagueConfig(
      id: 'diamond',
      name: 'ダイヤモンドリーグ',
      nameEn: 'Diamond League',
      color: Color(0xFF14B8A6),
      minXP: 15000,
      maxXP: 999999,
      promotionThreshold: 999999,
      relegationThreshold: 16000,
      weeklyXPRequirement: 750,
      maxParticipants: 10,
      rewards: LeagueRewards(
        weeklyXP: 500,
        badges: ['diamond_elite', 'hall_of_fame'],
        unlocks: ['all_features', 'beta_access', 'exclusive_events'],
      ),
    ),
  };

  /// Check if user is eligible for promotion
  Future<LeaguePromotion?> checkPromotion(String userId) async {
    final user = await _getUserById(userId);
    if (user == null) return null;

    final currentLeague = leagues[user.currentLeague];
    if (currentLeague == null) return null;

    // Check promotion eligibility
    if (user.weeklyXP >= currentLeague.promotionThreshold &&
        user.totalXP >= currentLeague.maxXP) {
      final nextLeague = _getNextLeague(user.currentLeague);
      if (nextLeague != null) {
        return LeaguePromotion(
          userId: userId,
          fromLeague: user.currentLeague,
          toLeague: nextLeague,
          xpEarned: user.weeklyXP,
          totalXP: user.totalXP,
          rewards: _calculatePromotionRewards(nextLeague),
          achievedAt: DateTime.now(),
        );
      }
    }

    return null;
  }

  /// Check if user should be relegated
  Future<LeagueRelegation?> checkRelegation(String userId) async {
    final user = await _getUserById(userId);
    if (user == null) return null;

    final currentLeague = leagues[user.currentLeague];
    if (currentLeague == null || currentLeague.id == 'bronze') return null;

    // Check relegation conditions
    if (user.weeklyXP < currentLeague.relegationThreshold) {
      final previousLeague = _getPreviousLeague(user.currentLeague);
      if (previousLeague != null) {
        return LeagueRelegation(
          userId: userId,
          fromLeague: user.currentLeague,
          toLeague: previousLeague,
          weeklyXP: user.weeklyXP,
          threshold: currentLeague.relegationThreshold,
          relegatedAt: DateTime.now(),
        );
      }
    }

    return null;
  }

  /// Execute promotion for user
  Future<void> executePromotion(LeaguePromotion promotion) async {
    await _isar.writeTxn(() async {
      final user = await _getUserById(promotion.userId);
      if (user != null) {
        user.currentLeague = promotion.toLeague;
        user.weeklyXP = 0; // Reset weekly XP for new league
        user.updatedAt = DateTime.now();
        user.needsSync = true;
        await _isar.collection<LocalUser>().put(user);

        // Record promotion history
        final promotionRecord =
            LeaguePromotionRecord()
              ..userId = promotion.userId
              ..fromLeague = promotion.fromLeague
              ..toLeague = promotion.toLeague
              ..xpEarned = promotion.xpEarned
              ..totalXP = promotion.totalXP
              ..achievedAt = promotion.achievedAt
              ..rewards = promotion.rewards.toJson().toString();

        await _isar.collection<LeaguePromotionRecord>().put(promotionRecord);
      }
    });
  }

  /// Execute relegation for user
  Future<void> executeRelegation(LeagueRelegation relegation) async {
    await _isar.writeTxn(() async {
      final user = await _getUserById(relegation.userId);
      if (user != null) {
        user.currentLeague = relegation.toLeague;
        user.weeklyXP = 0; // Reset weekly XP
        user.updatedAt = DateTime.now();
        user.needsSync = true;
        await _isar.collection<LocalUser>().put(user);

        // Record relegation history
        final relegationRecord =
            LeagueRelegationRecord()
              ..userId = relegation.userId
              ..fromLeague = relegation.fromLeague
              ..toLeague = relegation.toLeague
              ..weeklyXP = relegation.weeklyXP
              ..threshold = relegation.threshold
              ..relegatedAt = relegation.relegatedAt;

        await _isar.collection<LeagueRelegationRecord>().put(relegationRecord);
      }
    });
  }

  /// Get league rankings for specific league
  Future<List<LeagueRanking>> getLeagueRankings(
    String league, {
    int limit = 50,
  }) async {
    final users =
        await _isar
            .collection<LocalUser>()
            .filter()
            .currentLeagueEqualTo(league)
            .sortByWeeklyXPDesc()
            .limit(limit)
            .findAll();

    return users.asMap().entries.map((entry) {
      final index = entry.key;
      final user = entry.value;

      return LeagueRanking(
        userId: user.uid,
        displayName: user.displayName,
        avatarSeed: user.avatarSeed,
        rank: index + 1,
        weeklyXP: user.weeklyXP,
        totalXP: user.totalXP,
        league: league,
        streakDays: user.currentStreak,
        lastActive: user.updatedAt,
      );
    }).toList();
  }

  /// Get user's current ranking in their league
  Future<LeagueRanking?> getUserRanking(String userId) async {
    final user = await _getUserById(userId);
    if (user == null) return null;

    final rankings = await getLeagueRankings(user.currentLeague);
    return rankings.firstWhere(
      (ranking) => ranking.userId == userId,
      orElse:
          () => LeagueRanking(
            userId: userId,
            displayName: user.displayName,
            avatarSeed: user.avatarSeed,
            rank: rankings.length + 1,
            weeklyXP: user.weeklyXP,
            totalXP: user.totalXP,
            league: user.currentLeague,
            streakDays: user.currentStreak,
            lastActive: user.updatedAt,
          ),
    );
  }

  /// Process weekly league updates (promotions/relegations)
  Future<WeeklyLeagueUpdate> processWeeklyUpdate() async {
    final promotions = <LeaguePromotion>[];
    final relegations = <LeagueRelegation>[];

    // Get all users
    final allUsers = await _isar.collection<LocalUser>().where().findAll();

    for (final user in allUsers) {
      // Check for promotion
      final promotion = await checkPromotion(user.uid);
      if (promotion != null) {
        await executePromotion(promotion);
        promotions.add(promotion);
      } else {
        // Check for relegation if no promotion
        final relegation = await checkRelegation(user.uid);
        if (relegation != null) {
          await executeRelegation(relegation);
          relegations.add(relegation);
        }
      }
    }

    return WeeklyLeagueUpdate(
      processedAt: DateTime.now(),
      promotions: promotions,
      relegations: relegations,
      totalUsersProcessed: allUsers.length,
    );
  }

  /// Get league statistics
  Future<LeagueStatistics> getLeagueStatistics() async {
    final stats = <String, int>{};

    for (final leagueId in leagues.keys) {
      final count =
          await _isar
              .collection<LocalUser>()
              .filter()
              .currentLeagueEqualTo(leagueId)
              .count();
      stats[leagueId] = count;
    }

    final totalUsers = stats.values.fold(0, (sum, count) => sum + count);

    return LeagueStatistics(
      totalUsers: totalUsers,
      leagueDistribution: stats,
      lastUpdated: DateTime.now(),
    );
  }

  // Helper methods
  Future<LocalUser?> _getUserById(String userId) async {
    return await _isar
        .collection<LocalUser>()
        .filter()
        .uidEqualTo(userId)
        .findFirst();
  }

  String? _getNextLeague(String currentLeague) {
    const leagueOrder = ['bronze', 'silver', 'gold', 'platinum', 'diamond'];
    final currentIndex = leagueOrder.indexOf(currentLeague);
    if (currentIndex >= 0 && currentIndex < leagueOrder.length - 1) {
      return leagueOrder[currentIndex + 1];
    }
    return null;
  }

  String? _getPreviousLeague(String currentLeague) {
    const leagueOrder = ['bronze', 'silver', 'gold', 'platinum', 'diamond'];
    final currentIndex = leagueOrder.indexOf(currentLeague);
    if (currentIndex > 0) {
      return leagueOrder[currentIndex - 1];
    }
    return null;
  }

  LeagueRewards _calculatePromotionRewards(String league) {
    final config = leagues[league];
    return config?.rewards ??
        const LeagueRewards(weeklyXP: 0, badges: [], unlocks: []);
  }
}

// Isar collections for league data
@collection
class LeaguePromotionRecord {
  Id id = Isar.autoIncrement;
  late String userId;
  late String fromLeague;
  late String toLeague;
  late int xpEarned;
  late int totalXP;
  late DateTime achievedAt;
  late String rewards; // JSON string
}

@collection
class LeagueRelegationRecord {
  Id id = Isar.autoIncrement;
  late String userId;
  late String fromLeague;
  late String toLeague;
  late int weeklyXP;
  late int threshold;
  late DateTime relegatedAt;
}

// Provider
final leagueSystemProvider = Provider<LeagueSystem>((ref) {
  // This would need to be implemented with proper Isar instance
  // For now, using a placeholder
  throw UnimplementedError('LeagueSystem provider needs proper Isar setup');
});

final leagueRankingsProvider =
    FutureProvider.family<List<LeagueRanking>, String>((ref, league) {
      final leagueSystem = ref.watch(leagueSystemProvider);
      return leagueSystem.getLeagueRankings(league);
    });

final userRankingProvider = FutureProvider.family<LeagueRanking?, String>((
  ref,
  userId,
) {
  final leagueSystem = ref.watch(leagueSystemProvider);
  return leagueSystem.getUserRanking(userId);
});

final leagueStatisticsProvider = FutureProvider<LeagueStatistics>((ref) {
  final leagueSystem = ref.watch(leagueSystemProvider);
  return leagueSystem.getLeagueStatistics();
});
