import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:minq/data/local/models/local_quest.dart';
import 'package:minq/data/providers.dart';
import 'package:minq/domain/gamification/league.dart';

/// Manages league configuration, promotions, relegations, and rankings.
class LeagueSystem {
  LeagueSystem(this._isar);

  final Isar _isar;

  /// Static league catalogue shared across the application.
  static const Map<String, LeagueConfig> leagues = {
    'bronze': LeagueConfig(
      id: 'bronze',
      name: 'Bronze League',
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
      name: 'Silver League',
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
      name: 'Gold League',
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
      name: 'Platinum League',
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
      name: 'Diamond League',
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

  /// Determine whether the user qualifies for a promotion.
  Future<LeaguePromotion?> checkPromotion(String userId) async {
    final user = await _getUserById(userId);
    if (user == null) return null;

    final config = leagues[user.currentLeague];
    if (config == null) return null;

    final meetsWeekly = user.weeklyXP >= config.promotionThreshold;
    final meetsTotal = user.totalXP >= config.maxXP;
    if (!meetsWeekly || !meetsTotal) return null;

    final nextLeague = _getNextLeague(user.currentLeague);
    if (nextLeague == null) return null;

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

  /// Determine whether the user should be relegated.
  Future<LeagueRelegation?> checkRelegation(String userId) async {
    final user = await _getUserById(userId);
    if (user == null) return null;

    final config = leagues[user.currentLeague];
    if (config == null || config.id == 'bronze') return null;

    if (user.weeklyXP >= config.relegationThreshold) return null;

    final previousLeague = _getPreviousLeague(user.currentLeague);
    if (previousLeague == null) return null;

    return LeagueRelegation(
      userId: userId,
      fromLeague: user.currentLeague,
      toLeague: previousLeague,
      weeklyXP: user.weeklyXP,
      threshold: config.relegationThreshold,
      relegatedAt: DateTime.now(),
    );
  }

  /// Persist a promotion and keep an auditable history.
  Future<void> executePromotion(LeaguePromotion promotion) async {
    await _isar.writeTxn(() async {
      final user = await _getUserById(promotion.userId);
      if (user == null) return;

      user.currentLeague = promotion.toLeague;
      user.weeklyXP = 0;
      user.updatedAt = DateTime.now();
      user.needsSync = true;
      await _isar.collection<LocalUser>().put(user);

    });
  }

  /// Persist a relegation and log the decision.
  Future<void> executeRelegation(LeagueRelegation relegation) async {
    await _isar.writeTxn(() async {
      final user = await _getUserById(relegation.userId);
      if (user == null) return;

      user.currentLeague = relegation.toLeague;
      user.weeklyXP = 0;
      user.updatedAt = DateTime.now();
      user.needsSync = true;
      await _isar.collection<LocalUser>().put(user);

    });
  }

  /// Fetch the rankings for a league ordered by weekly XP.
  Future<List<LeagueRanking>> getLeagueRankings(
    String league, {
    int limit = 50,
  }) async {
    final users = await _isar
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

  /// Obtain the ranking snapshot for a single user.
  Future<LeagueRanking?> getUserRanking(String userId) async {
    final user = await _getUserById(userId);
    if (user == null) return null;

    final rankings = await getLeagueRankings(user.currentLeague);
    return rankings.firstWhere(
      (ranking) => ranking.userId == userId,
      orElse: () => LeagueRanking(
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

  /// Recalculate promotions and relegations for every user.
  Future<WeeklyLeagueUpdate> processWeeklyUpdate() async {
    final promotions = <LeaguePromotion>[];
    final relegations = <LeagueRelegation>[];

    final allUsers = await _isar.collection<LocalUser>().where().findAll();
    for (final user in allUsers) {
      final promotion = await checkPromotion(user.uid);
      if (promotion != null) {
        await executePromotion(promotion);
        promotions.add(promotion);
        continue;
      }

      final relegation = await checkRelegation(user.uid);
      if (relegation != null) {
        await executeRelegation(relegation);
        relegations.add(relegation);
      }
    }

    return WeeklyLeagueUpdate(
      processedAt: DateTime.now(),
      promotions: promotions,
      relegations: relegations,
      totalUsersProcessed: allUsers.length,
    );
  }

  /// Aggregate overall league statistics.
  Future<LeagueStatistics> getLeagueStatistics() async {
    final distribution = <String, int>{};
    for (final leagueId in leagues.keys) {
      final count = await _isar
          .collection<LocalUser>()
          .filter()
          .currentLeagueEqualTo(leagueId)
          .count();
      distribution[leagueId] = count;
    }

    final totalUsers =
        distribution.values.fold<int>(0, (sum, count) => sum + count);

    return LeagueStatistics(
      totalUsers: totalUsers,
      leagueDistribution: distribution,
      lastUpdated: DateTime.now(),
    );
  }

  Future<LocalUser?> _getUserById(String userId) {
    return _isar
        .collection<LocalUser>()
        .filter()
        .uidEqualTo(userId)
        .findFirst();
  }

  String? _getNextLeague(String currentLeague) {
    const order = ['bronze', 'silver', 'gold', 'platinum', 'diamond'];
    final index = order.indexOf(currentLeague);
    if (index < 0 || index >= order.length - 1) return null;
    return order[index + 1];
  }

  String? _getPreviousLeague(String currentLeague) {
    const order = ['bronze', 'silver', 'gold', 'platinum', 'diamond'];
    final index = order.indexOf(currentLeague);
    if (index <= 0) return null;
    return order[index - 1];
  }

  LeagueRewards _calculatePromotionRewards(String leagueId) {
    return leagues[leagueId]?.rewards ??
        const LeagueRewards(weeklyXP: 0, badges: [], unlocks: []);
  }
}

/// Riverpod provider exposing the league system.
final leagueSystemProvider = Provider<LeagueSystem>((ref) {
  final isarAsync = ref.watch(isarProvider);
  return isarAsync.when(
    data: LeagueSystem.new,
    loading: () =>
        throw StateError('Isar instance is not yet initialised'),
    error: (error, _) => throw error,
  );
});
