import 'package:flutter/material.dart';

/// League configuration with thresholds and rewards
class LeagueConfig {
  final String id;
  final String name;
  final String nameEn;
  final Color color;
  final int minXP;
  final int maxXP;
  final int promotionThreshold;
  final int relegationThreshold;
  final int weeklyXPRequirement;
  final int maxParticipants;
  final LeagueRewards rewards;

  const LeagueConfig({
    required this.id,
    required this.name,
    required this.nameEn,
    required this.color,
    required this.minXP,
    required this.maxXP,
    required this.promotionThreshold,
    required this.relegationThreshold,
    required this.weeklyXPRequirement,
    required this.maxParticipants,
    required this.rewards,
  });

  /// Get league icon based on league type
  IconData get icon {
    switch (id) {
      case 'bronze':
        return Icons.workspace_premium;
      case 'silver':
        return Icons.military_tech;
      case 'gold':
        return Icons.emoji_events;
      case 'platinum':
        return Icons.diamond;
      case 'diamond':
        return Icons.auto_awesome;
      default:
        return Icons.workspace_premium;
    }
  }

  /// Get league gradient colors
  List<Color> get gradientColors {
    switch (id) {
      case 'bronze':
        return [const Color(0xFFB45309), const Color(0xFFD97706)];
      case 'silver':
        return [const Color(0xFF6B7280), const Color(0xFF9CA3AF)];
      case 'gold':
        return [const Color(0xFFF59E0B), const Color(0xFFFBBF24)];
      case 'platinum':
        return [const Color(0xFF7C3AED), const Color(0xFF8B5CF6)];
      case 'diamond':
        return [const Color(0xFF0D9488), const Color(0xFF14B8A6)];
      default:
        return [color, color];
    }
  }
}

/// League rewards configuration
class LeagueRewards {
  final int weeklyXP;
  final List<String> badges;
  final List<String> unlocks;

  const LeagueRewards({
    required this.weeklyXP,
    required this.badges,
    required this.unlocks,
  });

  Map<String, dynamic> toJson() => {
    'weeklyXP': weeklyXP,
    'badges': badges,
    'unlocks': unlocks,
  };

  factory LeagueRewards.fromJson(Map<String, dynamic> json) => LeagueRewards(
    weeklyXP: json['weeklyXP'] ?? 0,
    badges: List<String>.from(json['badges'] ?? []),
    unlocks: List<String>.from(json['unlocks'] ?? []),
  );
}

/// League promotion event
class LeaguePromotion {
  final String userId;
  final String fromLeague;
  final String toLeague;
  final int xpEarned;
  final int totalXP;
  final LeagueRewards rewards;
  final DateTime achievedAt;

  const LeaguePromotion({
    required this.userId,
    required this.fromLeague,
    required this.toLeague,
    required this.xpEarned,
    required this.totalXP,
    required this.rewards,
    required this.achievedAt,
  });
}

/// League relegation event
class LeagueRelegation {
  final String userId;
  final String fromLeague;
  final String toLeague;
  final int weeklyXP;
  final int threshold;
  final DateTime relegatedAt;

  const LeagueRelegation({
    required this.userId,
    required this.fromLeague,
    required this.toLeague,
    required this.weeklyXP,
    required this.threshold,
    required this.relegatedAt,
  });
}

/// League ranking entry
class LeagueRanking {
  final String userId;
  final String displayName;
  final String? avatarSeed;
  final int rank;
  final int weeklyXP;
  final int totalXP;
  final String league;
  final int streakDays;
  final DateTime lastActive;

  const LeagueRanking({
    required this.userId,
    required this.displayName,
    this.avatarSeed,
    required this.rank,
    required this.weeklyXP,
    required this.totalXP,
    required this.league,
    required this.streakDays,
    required this.lastActive,
  });

  /// Get avatar URL from seed
  String get avatarUrl {
    if (avatarSeed != null) {
      return 'https://api.dicebear.com/7.x/avataaars/svg?seed=$avatarSeed';
    }
    return 'https://api.dicebear.com/7.x/avataaars/svg?seed=$userId';
  }

  /// Check if user is in top 3
  bool get isTopThree => rank <= 3;

  /// Get rank suffix (1st, 2nd, 3rd, etc.)
  String get rankSuffix {
    switch (rank) {
      case 1:
        return '1st';
      case 2:
        return '2nd';
      case 3:
        return '3rd';
      default:
        return '${rank}th';
    }
  }

  /// Get rank color based on position
  Color get rankColor {
    switch (rank) {
      case 1:
        return const Color(0xFFF59E0B); // Gold
      case 2:
        return const Color(0xFF9CA3AF); // Silver
      case 3:
        return const Color(0xFFB45309); // Bronze
      default:
        return const Color(0xFF6B7280); // Gray
    }
  }
}

/// Weekly league update result
class WeeklyLeagueUpdate {
  final DateTime processedAt;
  final List<LeaguePromotion> promotions;
  final List<LeagueRelegation> relegations;
  final int totalUsersProcessed;

  const WeeklyLeagueUpdate({
    required this.processedAt,
    required this.promotions,
    required this.relegations,
    required this.totalUsersProcessed,
  });

  int get totalPromotions => promotions.length;
  int get totalRelegations => relegations.length;
  int get totalChanges => totalPromotions + totalRelegations;
}

/// League statistics
class LeagueStatistics {
  final int totalUsers;
  final Map<String, int> leagueDistribution;
  final DateTime lastUpdated;

  const LeagueStatistics({
    required this.totalUsers,
    required this.leagueDistribution,
    required this.lastUpdated,
  });

  /// Get percentage distribution
  Map<String, double> get percentageDistribution {
    if (totalUsers == 0) return {};

    return leagueDistribution.map(
      (league, count) => MapEntry(league, (count / totalUsers) * 100),
    );
  }

  /// Get most populated league
  String? get mostPopulatedLeague {
    if (leagueDistribution.isEmpty) return null;

    return leagueDistribution.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
  }
}
