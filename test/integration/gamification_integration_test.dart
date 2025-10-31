import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:isar/isar.dart';
import 'package:minq/core/gamification/xp_system.dart';
import 'package:minq/core/gamification/league_system.dart';
import 'package:minq/data/local/models/local_quest.dart';
import 'package:minq/main.dart' as app;
import 'package:mocktail/mocktail.dart';

class MockXPSystem extends Mock implements XPSystem {}
class MockLeagueSystem extends Mock implements LeagueSystem {}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Gamification Integration Tests', () {
    late Isar isar;
    late MockXPSystem mockXPSystem;
    late MockLeagueSystem mockLeagueSystem;

    setUpAll(() async {
      await Isar.initializeIsarCore(download: true);
    });

    setUp(() async {
      isar = await Isar.open([
        LocalQuestSchema,
        LocalUserSchema,
        LocalChallengeSchema,
        LocalQuestLogSchema,
      ], directory: '');

      mockXPSystem = MockXPSystem();
      mockLeagueSystem = MockLeagueSystem();

      // Setup default mock behaviors
      when(() => mockXPSystem.awardXP(
        userId: any(named: 'userId'),
        action: any(named: 'action'),
        context: any(named: 'context'),
      )).thenAnswer((_) async => XPGainResult(
        xpGained: 25,
        newTotalXP: 125,
        leveledUp: false,
        newLevel: 1,
        rewards: [],
      ));

      when(() => mockLeagueSystem.checkPromotion(any()))
          .thenAnswer((_) async => null);
    });

    tearDown(() async {
      await isar.close(deleteFromDisk: true);
    });

    testWidgets('XP gain and level up integration', (tester) async {
      // Setup user close to level up
      final user = LocalUser()
        ..uid = 'test-user'
        ..displayName = 'Test User'
        ..currentXP = 95
        ..totalXP = 95
        ..currentLevel = 1
        ..createdAt = DateTime.now()
        ..updatedAt = DateTime.now();

      await isar.writeTxn(() => isar.localUsers.put(user));

      // Mock level up scenario
      when(() => mockXPSystem.awardXP(
        userId: 'test-user',
        action: 'quest_complete',
        context: any(named: 'context'),
      )).thenAnswer((_) async => XPGainResult(
        xpGained: 25,
        newTotalXP: 120,
        leveledUp: true,
        newLevel: 2,
        rewards: ['new_theme_unlocked', 'bonus_xp_multiplier'],
      ));

      await tester.pumpWidget(app.MinQApp(skipOnboarding: true));
      await tester.pumpAndSettle();

      // Complete a quest to trigger XP gain
      await tester.tap(find.byKey(const Key('create_quest_fab')));
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key('quest_title_field')), 'Level Up Quest');
      await tester.tap(find.byKey(const Key('save_quest_button')));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Level Up Quest'));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('complete_quest_button')));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('confirm_completion_button')));
      await tester.pumpAndSettle();

      // Verify XP gain animation
      expect(find.byKey(const Key('xp_gain_animation')), findsOneWidget);
      expect(find.text('+25 XP'), findsOneWidget);

      // Wait for XP animation to complete
      await tester.pump(const Duration(seconds: 2));

      // Verify level up animation
      expect(find.byKey(const Key('level_up_animation')), findsOneWidget);
      expect(find.text('Level 2 Achieved!'), findsOneWidget);
      expect(find.byIcon(Icons.emoji_events), findsOneWidget);

      // Verify rewards display
      expect(find.text('New Rewards Unlocked!'), findsOneWidget);
      expect(find.text('New Theme Unlocked'), findsOneWidget);
      expect(find.text('Bonus XP Multiplier'), findsOneWidget);

      // Wait for level up animation to complete
      await tester.pump(const Duration(seconds: 4));

      // Verify updated user stats
      expect(find.text('Level 2'), findsOneWidget);
      expect(find.text('120 XP'), findsOneWidget);

      // Verify XP system was called
      verify(() => mockXPSystem.awardXP(
        userId: 'test-user',
        action: 'quest_complete',
        context: any(named: 'context'),
      )).called(1);
    });

    testWidgets('League promotion integration', (tester) async {
      // Setup user eligible for promotion
      final user = LocalUser()
        ..uid = 'test-user'
        ..displayName = 'Test User'
        ..currentXP = 800
        ..totalXP = 1200
        ..weeklyXP = 850
        ..currentLevel = 3
        ..currentLeague = 'bronze'
        ..createdAt = DateTime.now()
        ..updatedAt = DateTime.now();

      await isar.writeTxn(() => isar.localUsers.put(user));

      // Mock promotion scenario
      when(() => mockLeagueSystem.checkPromotion('test-user'))
          .thenAnswer((_) async => LeaguePromotion(
        userId: 'test-user',
        fromLeague: 'bronze',
        toLeague: 'silver',
        xpEarned: 850,
        totalXP: 1200,
        rewards: LeagueRewards(
          weeklyXP: 100,
          badges: ['silver_champion'],
          unlocks: ['advanced_themes', 'priority_support'],
        ),
        achievedAt: DateTime.now(),
      ));

      await tester.pumpWidget(app.MinQApp(skipOnboarding: true));
      await tester.pumpAndSettle();

      // Navigate to league screen
      await tester.tap(find.byKey(const Key('league_tab')));
      await tester.pumpAndSettle();

      // Verify current league
      expect(find.text('Bronze League'), findsOneWidget);
      expect(find.byKey(const Key('bronze_league_badge')), findsOneWidget);

      // Trigger weekly league update
      await tester.tap(find.byKey(const Key('check_promotion_button')));
      await tester.pumpAndSettle();

      // Verify promotion animation
      expect(find.byKey(const Key('league_promotion_animation')), findsOneWidget);
      expect(find.text('Congratulations!'), findsOneWidget);
      expect(find.text('Promoted to Silver League!'), findsOneWidget);

      // Verify promotion effects (particles, confetti, etc.)
      expect(find.byKey(const Key('promotion_particles')), findsOneWidget);
      expect(find.byKey(const Key('confetti_animation')), findsOneWidget);

      // Verify rewards display
      expect(find.text('League Rewards'), findsOneWidget);
      expect(find.text('Silver Champion Badge'), findsOneWidget);
      expect(find.text('Advanced Themes Unlocked'), findsOneWidget);
      expect(find.text('Priority Support Access'), findsOneWidget);
      expect(find.text('+100 Bonus XP'), findsOneWidget);

      // Wait for promotion animation to complete
      await tester.pump(const Duration(seconds: 5));

      // Verify league update
      expect(find.text('Silver League'), findsOneWidget);
      expect(find.byKey(const Key('silver_league_badge')), findsOneWidget);
      expect(find.text('Bronze League'), findsNothing);

      // Verify league system was called
      verify(() => mockLeagueSystem.checkPromotion('test-user')).called(1);
    });

    testWidgets('Streak milestone and bonus XP integration', (tester) async {
      // Setup user with streak
      final user = LocalUser()
        ..uid = 'test-user'
        ..displayName = 'Test User'
        ..currentXP = 200
        ..totalXP = 500
        ..currentLevel = 2
        ..currentStreak = 6 // Close to 7-day milestone
        ..createdAt = DateTime.now()
        ..updatedAt = DateTime.now();

      await isar.writeTxn(() => isar.localUsers.put(user));

      // Mock streak milestone XP
      when(() => mockXPSystem.awardXP(
        userId: 'test-user',
        action: 'quest_complete',
        context: any(named: 'context'),
      )).thenAnswer((_) async => XPGainResult(
        xpGained: 45, // Base 25 + 20 streak bonus
        newTotalXP: 545,
        leveledUp: false,
        newLevel: 2,
        rewards: ['7_day_streak_badge'],
      ));

      await tester.pumpWidget(app.MinQApp(skipOnboarding: true));
      await tester.pumpAndSettle();

      // Complete quest to extend streak to 7 days
      await tester.tap(find.byKey(const Key('create_quest_fab')));
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key('quest_title_field')), 'Streak Quest');
      await tester.tap(find.byKey(const Key('save_quest_button')));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Streak Quest'));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('complete_quest_button')));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('confirm_completion_button')));
      await tester.pumpAndSettle();

      // Verify enhanced XP gain animation with streak bonus
      expect(find.byKey(const Key('xp_gain_animation')), findsOneWidget);
      expect(find.text('+45 XP'), findsOneWidget);
      expect(find.text('Streak Bonus: +20 XP'), findsOneWidget);

      // Verify streak milestone celebration
      expect(find.byKey(const Key('streak_milestone_animation')), findsOneWidget);
      expect(find.text('7-Day Streak Achieved!'), findsOneWidget);
      expect(find.byIcon(Icons.local_fire_department), findsOneWidget);

      // Verify streak badge reward
      expect(find.text('New Badge Earned!'), findsOneWidget);
      expect(find.text('7-Day Streak Master'), findsOneWidget);

      // Wait for animations to complete
      await tester.pump(const Duration(seconds: 4));

      // Verify updated streak display
      expect(find.text('7 Day Streak'), findsOneWidget);
      expect(find.byKey(const Key('streak_fire_icon')), findsOneWidget);

      // Verify XP system was called with streak context
      verify(() => mockXPSystem.awardXP(
        userId: 'test-user',
        action: 'quest_complete',
        context: argThat(
          contains('streak'),
          named: 'context',
        ),
      )).called(1);
    });

    testWidgets('Challenge completion and league impact integration', (tester) async {
      // Setup user and challenge
      final user = LocalUser()
        ..uid = 'test-user'
        ..displayName = 'Test User'
        ..currentXP = 300
        ..totalXP = 800
        ..weeklyXP = 600
        ..currentLevel = 3
        ..currentLeague = 'bronze'
        ..createdAt = DateTime.now()
        ..updatedAt = DateTime.now();

      final challenge = LocalChallenge()
        ..challengeId = 'fitness-challenge'
        ..title = '30-Day Fitness Challenge'
        ..description = 'Complete 30 days of exercise'
        ..startDate = DateTime.now().subtract(const Duration(days: 29))
        ..endDate = DateTime.now().add(const Duration(days: 1))
        ..isActive = true
        ..progress = 29
        ..targetValue = 30
        ..xpReward = 200
        ..participants = ['test-user']
        ..updatedAt = DateTime.now();

      await isar.writeTxn(() async {
        await isar.localUsers.put(user);
        await isar.localChallenges.put(challenge);
      });

      // Mock challenge completion XP
      when(() => mockXPSystem.awardXP(
        userId: 'test-user',
        action: 'challenge_complete',
        context: any(named: 'context'),
      )).thenAnswer((_) async => XPGainResult(
        xpGained: 200,
        newTotalXP: 1000,
        leveledUp: false,
        newLevel: 3,
        rewards: ['fitness_master_badge'],
      ));

      // Mock league promotion after challenge completion
      when(() => mockLeagueSystem.checkPromotion('test-user'))
          .thenAnswer((_) async => LeaguePromotion(
        userId: 'test-user',
        fromLeague: 'bronze',
        toLeague: 'silver',
        xpEarned: 800, // Weekly XP after challenge
        totalXP: 1000,
        rewards: LeagueRewards(
          weeklyXP: 50,
          badges: ['silver_league_member'],
          unlocks: ['premium_challenges'],
        ),
        achievedAt: DateTime.now(),
      ));

      await tester.pumpWidget(app.MinQApp(skipOnboarding: true));
      await tester.pumpAndSettle();

      // Navigate to challenges
      await tester.tap(find.byKey(const Key('challenges_tab')));
      await tester.pumpAndSettle();

      // Find and complete the challenge
      await tester.tap(find.text('30-Day Fitness Challenge'));
      await tester.pumpAndSettle();

      // Verify challenge is almost complete
      expect(find.text('29/30 Days Complete'), findsOneWidget);
      expect(find.byKey(const Key('challenge_progress_bar')), findsOneWidget);

      // Complete final day
      await tester.tap(find.byKey(const Key('update_progress_button')));
      await tester.pumpAndSettle();

      // Verify challenge completion celebration
      expect(find.byKey(const Key('challenge_completion_animation')), findsOneWidget);
      expect(find.text('Challenge Complete!'), findsOneWidget);
      expect(find.text('30-Day Fitness Challenge'), findsOneWidget);

      // Verify massive XP gain
      expect(find.byKey(const Key('xp_gain_animation')), findsOneWidget);
      expect(find.text('+200 XP'), findsOneWidget);
      expect(find.text('Challenge Bonus!'), findsOneWidget);

      // Verify challenge badge
      expect(find.text('Fitness Master Badge Earned!'), findsOneWidget);

      // Wait for challenge animation to complete
      await tester.pump(const Duration(seconds: 3));

      // Verify league promotion triggered
      expect(find.byKey(const Key('league_promotion_animation')), findsOneWidget);
      expect(find.text('League Promotion!'), findsOneWidget);
      expect(find.text('Welcome to Silver League!'), findsOneWidget);

      // Wait for all animations to complete
      await tester.pump(const Duration(seconds: 6));

      // Verify final state
      expect(find.text('Silver League'), findsOneWidget);
      expect(find.text('1000 XP'), findsOneWidget);

      // Verify both systems were called
      verify(() => mockXPSystem.awardXP(
        userId: 'test-user',
        action: 'challenge_complete',
        context: any(named: 'context'),
      )).called(1);

      verify(() => mockLeagueSystem.checkPromotion('test-user')).called(1);
    });

    testWidgets('Gamification statistics and leaderboard integration', (tester) async {
      // Setup multiple users for leaderboard
      final users = [
        LocalUser()
          ..uid = 'user-1'
          ..displayName = 'Top Player'
          ..currentXP = 500
          ..totalXP = 2000
          ..weeklyXP = 500
          ..currentLevel = 5
          ..currentLeague = 'gold'
          ..currentStreak = 15
          ..createdAt = DateTime.now()
          ..updatedAt = DateTime.now(),
        LocalUser()
          ..uid = 'test-user'
          ..displayName = 'Test User'
          ..currentXP = 300
          ..totalXP = 1200
          ..weeklyXP = 300
          ..currentLevel = 3
          ..currentLeague = 'silver'
          ..currentStreak = 7
          ..createdAt = DateTime.now()
          ..updatedAt = DateTime.now(),
        LocalUser()
          ..uid = 'user-3'
          ..displayName = 'Beginner'
          ..currentXP = 100
          ..totalXP = 400
          ..weeklyXP = 100
          ..currentLevel = 1
          ..currentLeague = 'bronze'
          ..currentStreak = 3
          ..createdAt = DateTime.now()
          ..updatedAt = DateTime.now(),
      ];

      await isar.writeTxn(() => isar.localUsers.putAll(users));

      await tester.pumpWidget(app.MinQApp(skipOnboarding: true));
      await tester.pumpAndSettle();

      // Navigate to league leaderboard
      await tester.tap(find.byKey(const Key('league_tab')));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('leaderboard_tab')));
      await tester.pumpAndSettle();

      // Verify leaderboard display
      expect(find.byKey(const Key('leaderboard_screen')), findsOneWidget);

      // Verify podium for top 3
      expect(find.byKey(const Key('podium_widget')), findsOneWidget);
      expect(find.text('Top Player'), findsOneWidget);
      expect(find.text('Test User'), findsOneWidget);
      expect(find.text('Beginner'), findsOneWidget);

      // Verify ranking positions
      expect(find.text('1st'), findsOneWidget);
      expect(find.text('2nd'), findsOneWidget);
      expect(find.text('3rd'), findsOneWidget);

      // Verify XP display
      expect(find.text('500 XP'), findsOneWidget);
      expect(find.text('300 XP'), findsOneWidget);
      expect(find.text('100 XP'), findsOneWidget);

      // Test league filter
      await tester.tap(find.byKey(const Key('league_filter_dropdown')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Silver League'));
      await tester.pumpAndSettle();

      // Verify filtered results
      expect(find.text('Test User'), findsOneWidget);
      expect(find.text('Top Player'), findsNothing);
      expect(find.text('Beginner'), findsNothing);

      // Navigate to personal stats
      await tester.tap(find.byKey(const Key('my_stats_tab')));
      await tester.pumpAndSettle();

      // Verify personal gamification stats
      expect(find.byKey(const Key('personal_stats_screen')), findsOneWidget);
      expect(find.text('Level 3'), findsOneWidget);
      expect(find.text('Silver League'), findsOneWidget);
      expect(find.text('7 Day Streak'), findsOneWidget);
      expect(find.text('1200 Total XP'), findsOneWidget);

      // Verify progress charts
      expect(find.byKey(const Key('xp_progress_chart')), findsOneWidget);
      expect(find.byKey(const Key('level_progress_bar')), findsOneWidget);
      expect(find.byKey(const Key('league_progress_indicator')), findsOneWidget);

      // Test achievements section
      await tester.tap(find.byKey(const Key('achievements_tab')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('achievements_grid')), findsOneWidget);
      expect(find.byKey(const Key('achievement_badge')), findsAtLeastNWidgets(1));
    });

    testWidgets('Gamification settings and preferences integration', (tester) async {
      await tester.pumpWidget(app.MinQApp(skipOnboarding: true));
      await tester.pumpAndSettle();

      // Navigate to settings
      await tester.tap(find.byKey(const Key('settings_tab')));
      await tester.pumpAndSettle();

      // Navigate to gamification settings
      await tester.tap(find.byKey(const Key('gamification_settings_tile')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('gamification_settings_screen')), findsOneWidget);

      // Test XP notifications toggle
      expect(find.byKey(const Key('xp_notifications_switch')), findsOneWidget);
      await tester.tap(find.byKey(const Key('xp_notifications_switch')));
      await tester.pumpAndSettle();

      // Test level up animations toggle
      expect(find.byKey(const Key('level_up_animations_switch')), findsOneWidget);
      await tester.tap(find.byKey(const Key('level_up_animations_switch')));
      await tester.pumpAndSettle();

      // Test league notifications toggle
      expect(find.byKey(const Key('league_notifications_switch')), findsOneWidget);
      await tester.tap(find.byKey(const Key('league_notifications_switch')));
      await tester.pumpAndSettle();

      // Test streak reminders
      expect(find.byKey(const Key('streak_reminders_switch')), findsOneWidget);
      await tester.tap(find.byKey(const Key('streak_reminders_switch')));
      await tester.pumpAndSettle();

      // Test challenge notifications
      expect(find.byKey(const Key('challenge_notifications_switch')), findsOneWidget);
      await tester.tap(find.byKey(const Key('challenge_notifications_switch')));
      await tester.pumpAndSettle();

      // Save settings
      await tester.tap(find.byKey(const Key('save_settings_button')));
      await tester.pumpAndSettle();

      // Verify settings saved confirmation
      expect(find.text('Settings Saved'), findsOneWidget);

      // Navigate back and test that settings are applied
      await tester.tap(find.byKey(const Key('back_button')));
      await tester.pumpAndSettle();

      // Complete a quest to test disabled animations
      await tester.tap(find.byKey(const Key('quests_tab')));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('create_quest_fab')));
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key('quest_title_field')), 'Settings Test');
      await tester.tap(find.byKey(const Key('save_quest_button')));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Settings Test'));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('complete_quest_button')));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('confirm_completion_button')));
      await tester.pumpAndSettle();

      // Verify animations are disabled (should not find animation widgets)
      expect(find.byKey(const Key('xp_gain_animation')), findsNothing);
      expect(find.byKey(const Key('level_up_animation')), findsNothing);

      // But XP should still be awarded (just without animation)
      expect(find.text('+25 XP'), findsOneWidget);
    });
  });
}

// Mock data classes for testing
class XPGainResult {
  final int xpGained;
  final int newTotalXP;
  final bool leveledUp;
  final int newLevel;
  final List<String> rewards;

  XPGainResult({
    required this.xpGained,
    required this.newTotalXP,
    required this.leveledUp,
    required this.newLevel,
    required this.rewards,
  });
}

class LeaguePromotion {
  final String userId;
  final String fromLeague;
  final String toLeague;
  final int xpEarned;
  final int totalXP;
  final LeagueRewards rewards;
  final DateTime achievedAt;

  LeaguePromotion({
    required this.userId,
    required this.fromLeague,
    required this.toLeague,
    required this.xpEarned,
    required this.totalXP,
    required this.rewards,
    required this.achievedAt,
  });
}

class LeagueRewards {
  final int weeklyXP;
  final List<String> badges;
  final List<String> unlocks;

  LeagueRewards({
    required this.weeklyXP,
    required this.badges,
    required this.unlocks,
  });
}