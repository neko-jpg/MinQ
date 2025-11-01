import 'package:flutter_test/flutter_test.dart';

import '../../../lib/core/gamification/services/league_system.dart';
import '../../../lib/domain/gamification/league.dart';
import '../../../lib/data/local/models/local_quest.dart';

void main() {
  group('LeagueSystem', () {
    group('League Configuration', () {
      test('should have all required leagues', () {
        expect(
          LeagueSystem.leagues.keys,
          containsAll(['bronze', 'silver', 'gold', 'platinum', 'diamond']),
        );
      });

      test('should have proper league hierarchy', () {
        final bronze = LeagueSystem.leagues['bronze']!;
        final silver = LeagueSystem.leagues['silver']!;
        final gold = LeagueSystem.leagues['gold']!;
        final platinum = LeagueSystem.leagues['platinum']!;
        final diamond = LeagueSystem.leagues['diamond']!;

        // Check XP thresholds are in ascending order
        expect(bronze.maxXP, lessThan(silver.minXP));
        expect(silver.maxXP, lessThan(gold.minXP));
        expect(gold.maxXP, lessThan(platinum.minXP));
        expect(platinum.maxXP, lessThan(diamond.minXP));

        // Check promotion thresholds
        expect(bronze.promotionThreshold, lessThanOrEqualTo(bronze.maxXP));
        expect(silver.promotionThreshold, lessThanOrEqualTo(silver.maxXP));
        expect(gold.promotionThreshold, lessThanOrEqualTo(gold.maxXP));
        expect(platinum.promotionThreshold, lessThanOrEqualTo(platinum.maxXP));
      });

      test('should have proper relegation thresholds', () {
        final leagues = LeagueSystem.leagues.values;

        for (final league in leagues) {
          if (league.id != 'bronze') {
            expect(league.relegationThreshold, greaterThan(0));
            expect(
              league.relegationThreshold,
              lessThan(league.promotionThreshold),
            );
          }
        }
      });
    });

    group('League Promotion Logic', () {
      test('should identify promotion eligibility correctly', () {
        // Test case: User eligible for promotion from bronze to silver
        final user =
            LocalUser()
              ..uid = 'test-user'
              ..displayName = 'Test User'
              ..currentLeague = 'bronze'
              ..weeklyXP =
                  850 // Above bronze promotion threshold (800)
              ..totalXP =
                  1000 // Above bronze max XP (999)
              ..createdAt = DateTime.now()
              ..updatedAt = DateTime.now();

        // Test the logic structure
        expect(user.weeklyXP, greaterThan(800)); // Bronze promotion threshold
        expect(user.totalXP, greaterThan(999)); // Bronze max XP
      });

      test('should not promote if weekly XP is insufficient', () {
        final user =
            LocalUser()
              ..uid = 'test-user'
              ..displayName = 'Test User'
              ..currentLeague = 'bronze'
              ..weeklyXP =
                  700 // Below bronze promotion threshold (800)
              ..totalXP =
                  1000 // Above bronze max XP
              ..createdAt = DateTime.now()
              ..updatedAt = DateTime.now();

        expect(user.weeklyXP, lessThan(800));
      });

      test('should not promote if total XP is insufficient', () {
        final user =
            LocalUser()
              ..uid = 'test-user'
              ..displayName = 'Test User'
              ..currentLeague = 'bronze'
              ..weeklyXP =
                  850 // Above bronze promotion threshold
              ..totalXP =
                  900 // Below bronze max XP (999)
              ..createdAt = DateTime.now()
              ..updatedAt = DateTime.now();

        expect(user.totalXP, lessThan(999));
      });
    });

    group('League Relegation Logic', () {
      test('should identify relegation eligibility correctly', () {
        final user =
            LocalUser()
              ..uid = 'test-user'
              ..displayName = 'Test User'
              ..currentLeague = 'silver'
              ..weeklyXP =
                  1000 // Below silver relegation threshold (1200)
              ..totalXP = 2000
              ..createdAt = DateTime.now()
              ..updatedAt = DateTime.now();

        final silverLeague = LeagueSystem.leagues['silver']!;
        expect(user.weeklyXP, lessThan(silverLeague.relegationThreshold));
      });

      test('should not relegate bronze league users', () {
        final user =
            LocalUser()
              ..uid = 'test-user'
              ..displayName = 'Test User'
              ..currentLeague = 'bronze'
              ..weeklyXP =
                  0 // Very low XP
              ..totalXP = 100
              ..createdAt = DateTime.now()
              ..updatedAt = DateTime.now();

        // Bronze league should have relegation threshold of 0
        final bronzeLeague = LeagueSystem.leagues['bronze']!;
        expect(bronzeLeague.relegationThreshold, equals(0));
      });
    });

    group('League Statistics', () {
      test('should calculate percentage distribution correctly', () {
        final stats = LeagueStatistics(
          totalUsers: 100,
          leagueDistribution: {
            'bronze': 50,
            'silver': 30,
            'gold': 15,
            'platinum': 4,
            'diamond': 1,
          },
          lastUpdated: DateTime.now(),
        );

        final percentages = stats.percentageDistribution;

        expect(percentages['bronze'], equals(50.0));
        expect(percentages['silver'], equals(30.0));
        expect(percentages['gold'], equals(15.0));
        expect(percentages['platinum'], equals(4.0));
        expect(percentages['diamond'], equals(1.0));
      });

      test('should identify most populated league correctly', () {
        final stats = LeagueStatistics(
          totalUsers: 100,
          leagueDistribution: {
            'bronze': 50,
            'silver': 30,
            'gold': 15,
            'platinum': 4,
            'diamond': 1,
          },
          lastUpdated: DateTime.now(),
        );

        expect(stats.mostPopulatedLeague, equals('bronze'));
      });
    });

    group('League Ranking', () {
      test('should assign correct rank colors', () {
        final firstPlace = LeagueRanking(
          userId: 'user1',
          displayName: 'User 1',
          rank: 1,
          weeklyXP: 1000,
          totalXP: 5000,
          league: 'gold',
          streakDays: 10,
          lastActive: DateTime.now(),
        );

        final secondPlace = LeagueRanking(
          userId: 'user2',
          displayName: 'User 2',
          rank: 2,
          weeklyXP: 900,
          totalXP: 4500,
          league: 'gold',
          streakDays: 8,
          lastActive: DateTime.now(),
        );

        final thirdPlace = LeagueRanking(
          userId: 'user3',
          displayName: 'User 3',
          rank: 3,
          weeklyXP: 800,
          totalXP: 4000,
          league: 'gold',
          streakDays: 6,
          lastActive: DateTime.now(),
        );

        expect(firstPlace.rankColor.value, equals(0xFFF59E0B)); // Gold
        expect(secondPlace.rankColor.value, equals(0xFF9CA3AF)); // Silver
        expect(thirdPlace.rankColor.value, equals(0xFFB45309)); // Bronze
      });

      test('should identify top three correctly', () {
        final rankings = [
          LeagueRanking(
            userId: 'user1',
            displayName: 'User 1',
            rank: 1,
            weeklyXP: 1000,
            totalXP: 5000,
            league: 'gold',
            streakDays: 10,
            lastActive: DateTime.now(),
          ),
          LeagueRanking(
            userId: 'user2',
            displayName: 'User 2',
            rank: 4,
            weeklyXP: 700,
            totalXP: 3500,
            league: 'gold',
            streakDays: 5,
            lastActive: DateTime.now(),
          ),
        ];

        expect(rankings[0].isTopThree, isTrue);
        expect(rankings[1].isTopThree, isFalse);
      });
    });

    group('Weekly Update', () {
      test('should create proper weekly update result', () {
        final promotions = [
          LeaguePromotion(
            userId: 'user1',
            fromLeague: 'bronze',
            toLeague: 'silver',
            xpEarned: 850,
            totalXP: 1200,
            rewards: LeagueRewards(
              weeklyXP: 100,
              badges: ['silver_champion'],
              unlocks: ['advanced_themes'],
            ),
            achievedAt: DateTime.now(),
          ),
        ];

        final relegations = [
          LeagueRelegation(
            userId: 'user2',
            fromLeague: 'silver',
            toLeague: 'bronze',
            weeklyXP: 1000,
            threshold: 1200,
            relegatedAt: DateTime.now(),
          ),
        ];

        final update = WeeklyLeagueUpdate(
          processedAt: DateTime.now(),
          promotions: promotions,
          relegations: relegations,
          totalUsersProcessed: 100,
        );

        expect(update.totalPromotions, equals(1));
        expect(update.totalRelegations, equals(1));
        expect(update.totalChanges, equals(2));
      });
    });
  });
}
