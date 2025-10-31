import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:minq/main.dart' as app;
import 'package:minq/core/gamification/xp_system.dart';
import 'package:minq/core/gamification/league_system.dart';
import 'package:minq/core/ai/ai_coach_engine.dart';
import 'package:mocktail/mocktail.dart';

class MockXPSystem extends Mock implements XPSystem {}
class MockLeagueSystem extends Mock implements LeagueSystem {}
class MockAiCoachEngine extends Mock implements AiCoachEngine {}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('User Journey Integration Tests', () {
    late MockXPSystem mockXPSystem;
    late MockLeagueSystem mockLeagueSystem;
    late MockAiCoachEngine mockAiCoachEngine;

    setUp(() {
      mockXPSystem = MockXPSystem();
      mockLeagueSystem = MockLeagueSystem();
      mockAiCoachEngine = MockAiCoachEngine();

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

      when(() => mockAiCoachEngine.generateResponse(any()))
          .thenAnswer((_) async => AiCoachResponse(
        message: 'Great job completing your first quest!',
        quickActions: [],
        encouragementLevel: EncouragementLevel.positive,
        suggestions: ['Keep up the good work!'],
      ));
    });

    testWidgets('Complete new user onboarding journey', (tester) async {
      await tester.pumpWidget(app.MinQApp());
      await tester.pumpAndSettle();

      // Verify onboarding screen is shown for new user
      expect(find.byKey(const Key('onboarding_screen')), findsOneWidget);
      expect(find.text('Welcome to MinQ'), findsOneWidget);

      // Navigate through onboarding screens
      for (int i = 0; i < 3; i++) {
        await tester.tap(find.byKey(const Key('next_button')));
        await tester.pumpAndSettle();
      }

      // Setup profile
      expect(find.byKey(const Key('profile_setup_screen')), findsOneWidget);
      
      await tester.enterText(
        find.byKey(const Key('display_name_field')), 
        'Test User'
      );
      
      // Select focus tags
      await tester.tap(find.byKey(const Key('tag_health')));
      await tester.tap(find.byKey(const Key('tag_fitness')));
      await tester.pumpAndSettle();

      // Complete onboarding
      await tester.tap(find.byKey(const Key('complete_onboarding_button')));
      await tester.pumpAndSettle();

      // Verify main app screen is shown
      expect(find.byKey(const Key('main_app_screen')), findsOneWidget);
      expect(find.byKey(const Key('onboarding_screen')), findsNothing);

      // Verify progressive hint is shown for first quest creation
      expect(find.byKey(const Key('progressive_hint')), findsOneWidget);
      expect(find.text('Create your first quest to get started!'), findsOneWidget);
    });

    testWidgets('First quest creation and completion journey', (tester) async {
      // Skip onboarding for this test
      await tester.pumpWidget(app.MinQApp(skipOnboarding: true));
      await tester.pumpAndSettle();

      // Create first quest
      await tester.tap(find.byKey(const Key('create_quest_fab')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('quest_creation_screen')), findsOneWidget);

      // Fill quest form
      await tester.enterText(
        find.byKey(const Key('quest_title_field')), 
        'Morning Walk'
      );
      await tester.enterText(
        find.byKey(const Key('quest_description_field')), 
        'Take a 30-minute walk every morning'
      );

      // Select category
      await tester.tap(find.byKey(const Key('category_dropdown')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Health'));
      await tester.pumpAndSettle();

      // Set difficulty
      await tester.tap(find.byKey(const Key('difficulty_normal')));
      await tester.pumpAndSettle();

      // Save quest
      await tester.tap(find.byKey(const Key('save_quest_button')));
      await tester.pumpAndSettle();

      // Verify quest was created and appears in list
      expect(find.byKey(const Key('quest_list_screen')), findsOneWidget);
      expect(find.text('Morning Walk'), findsOneWidget);

      // Verify progressive hint for first completion
      expect(find.byKey(const Key('progressive_hint')), findsOneWidget);
      expect(find.text('Tap on your quest to complete it!'), findsOneWidget);

      // Complete the quest
      await tester.tap(find.text('Morning Walk'));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('quest_detail_screen')), findsOneWidget);

      await tester.tap(find.byKey(const Key('complete_quest_button')));
      await tester.pumpAndSettle();

      // Verify completion flow
      expect(find.byKey(const Key('quest_completion_screen')), findsOneWidget);

      // Add proof (check completion)
      await tester.tap(find.byKey(const Key('proof_check_button')));
      await tester.pumpAndSettle();

      // Confirm completion
      await tester.tap(find.byKey(const Key('confirm_completion_button')));
      await tester.pumpAndSettle();

      // Verify XP gain animation
      expect(find.byKey(const Key('xp_gain_animation')), findsOneWidget);
      expect(find.text('+25 XP'), findsOneWidget);

      // Wait for animation to complete
      await tester.pump(const Duration(seconds: 3));

      // Verify quest is marked as completed
      expect(find.byKey(const Key('quest_list_screen')), findsOneWidget);
      expect(find.byKey(const Key('completed_quest_indicator')), findsOneWidget);

      // Verify XP system was called
      verify(() => mockXPSystem.awardXP(
        userId: any(named: 'userId'),
        action: 'quest_complete',
        context: any(named: 'context'),
      )).called(1);
    });

    testWidgets('AI Coach interaction journey', (tester) async {
      await tester.pumpWidget(app.MinQApp(skipOnboarding: true));
      await tester.pumpAndSettle();

      // Navigate to AI Coach
      await tester.tap(find.byKey(const Key('ai_coach_tab')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('ai_coach_screen')), findsOneWidget);

      // Send message to AI Coach
      await tester.enterText(
        find.byKey(const Key('ai_chat_input')), 
        'I need motivation to exercise'
      );
      await tester.tap(find.byKey(const Key('send_message_button')));
      await tester.pumpAndSettle();

      // Verify message was sent
      expect(find.text('I need motivation to exercise'), findsOneWidget);

      // Wait for AI response
      await tester.pump(const Duration(seconds: 2));

      // Verify AI response
      expect(find.text('Great job completing your first quest!'), findsOneWidget);

      // Verify AI coach was called with user message
      verify(() => mockAiCoachEngine.generateResponse('I need motivation to exercise'))
          .called(1);

      // Test quick action
      if (find.byKey(const Key('quick_action_create_quest')).evaluate().isNotEmpty) {
        await tester.tap(find.byKey(const Key('quick_action_create_quest')));
        await tester.pumpAndSettle();

        // Verify navigation to quest creation
        expect(find.byKey(const Key('quest_creation_screen')), findsOneWidget);
      }
    });

    testWidgets('League progression journey', (tester) async {
      // Setup user with high XP for league promotion
      when(() => mockLeagueSystem.checkPromotion(any()))
          .thenAnswer((_) async => LeaguePromotion(
        userId: 'test-user',
        fromLeague: 'bronze',
        toLeague: 'silver',
        xpEarned: 1000,
        totalXP: 1200,
        rewards: LeagueRewards(
          weeklyXP: 100,
          badges: ['silver_champion'],
          unlocks: ['advanced_themes'],
        ),
        achievedAt: DateTime.now(),
      ));

      await tester.pumpWidget(app.MinQApp(skipOnboarding: true));
      await tester.pumpAndSettle();

      // Navigate to league screen
      await tester.tap(find.byKey(const Key('league_tab')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('league_screen')), findsOneWidget);

      // Verify current league display
      expect(find.text('Bronze League'), findsOneWidget);

      // Simulate weekly league update
      await tester.tap(find.byKey(const Key('check_promotion_button')));
      await tester.pumpAndSettle();

      // Verify promotion animation
      expect(find.byKey(const Key('league_promotion_animation')), findsOneWidget);
      expect(find.text('Promoted to Silver League!'), findsOneWidget);

      // Wait for animation to complete
      await tester.pump(const Duration(seconds: 4));

      // Verify new league is displayed
      expect(find.text('Silver League'), findsOneWidget);
      expect(find.text('Bronze League'), findsNothing);

      // Verify league system was called
      verify(() => mockLeagueSystem.checkPromotion(any())).called(1);
    });

    testWidgets('Challenge participation journey', (tester) async {
      await tester.pumpWidget(app.MinQApp(skipOnboarding: true));
      await tester.pumpAndSettle();

      // Navigate to challenges
      await tester.tap(find.byKey(const Key('challenges_tab')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('challenges_screen')), findsOneWidget);

      // Find and join a challenge
      expect(find.text('7-Day Fitness Challenge'), findsOneWidget);
      await tester.tap(find.text('7-Day Fitness Challenge'));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('challenge_detail_screen')), findsOneWidget);

      // Join challenge
      await tester.tap(find.byKey(const Key('join_challenge_button')));
      await tester.pumpAndSettle();

      // Verify join confirmation
      expect(find.text('Challenge Joined!'), findsOneWidget);
      expect(find.byKey(const Key('challenge_progress_indicator')), findsOneWidget);

      // Update progress
      await tester.tap(find.byKey(const Key('update_progress_button')));
      await tester.pumpAndSettle();

      // Verify progress update
      expect(find.byKey(const Key('progress_update_animation')), findsOneWidget);

      // Navigate back to challenges list
      await tester.tap(find.byKey(const Key('back_button')));
      await tester.pumpAndSettle();

      // Verify challenge appears in "My Challenges" section
      expect(find.byKey(const Key('my_challenges_section')), findsOneWidget);
      expect(find.text('7-Day Fitness Challenge'), findsOneWidget);
    });

    testWidgets('Settings customization journey', (tester) async {
      await tester.pumpWidget(app.MinQApp(skipOnboarding: true));
      await tester.pumpAndSettle();

      // Navigate to settings
      await tester.tap(find.byKey(const Key('settings_tab')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('settings_screen')), findsOneWidget);

      // Test theme customization
      await tester.tap(find.byKey(const Key('theme_settings_tile')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('theme_settings_screen')), findsOneWidget);

      // Switch to dark mode
      await tester.tap(find.byKey(const Key('dark_mode_switch')));
      await tester.pumpAndSettle();

      // Verify theme change
      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(materialApp.theme?.brightness, equals(Brightness.dark));

      // Test accent color change
      await tester.tap(find.byKey(const Key('accent_color_purple')));
      await tester.pumpAndSettle();

      // Verify color change in preview
      expect(find.byKey(const Key('theme_preview')), findsOneWidget);

      // Save theme settings
      await tester.tap(find.byKey(const Key('save_theme_button')));
      await tester.pumpAndSettle();

      // Navigate back to main screen
      await tester.tap(find.byKey(const Key('back_button')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('back_button')));
      await tester.pumpAndSettle();

      // Verify theme persisted
      expect(find.byKey(const Key('main_app_screen')), findsOneWidget);
    });

    testWidgets('Statistics and analytics journey', (tester) async {
      await tester.pumpWidget(app.MinQApp(skipOnboarding: true));
      await tester.pumpAndSettle();

      // Navigate to statistics
      await tester.tap(find.byKey(const Key('stats_tab')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('stats_screen')), findsOneWidget);

      // Verify dashboard widgets
      expect(find.byKey(const Key('completion_rate_widget')), findsOneWidget);
      expect(find.byKey(const Key('streak_counter_widget')), findsOneWidget);
      expect(find.byKey(const Key('xp_progress_widget')), findsOneWidget);

      // Test time period filter
      await tester.tap(find.byKey(const Key('time_period_dropdown')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('This Month'));
      await tester.pumpAndSettle();

      // Verify charts update
      expect(find.byKey(const Key('monthly_chart')), findsOneWidget);

      // Test category filter
      await tester.tap(find.byKey(const Key('category_filter_button')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('category_filter_sheet')), findsOneWidget);

      await tester.tap(find.byKey(const Key('category_health')));
      await tester.tap(find.byKey(const Key('apply_filter_button')));
      await tester.pumpAndSettle();

      // Verify filtered data
      expect(find.text('Health Category'), findsOneWidget);

      // Test insights
      await tester.tap(find.byKey(const Key('insights_tab')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('insights_list')), findsOneWidget);
      expect(find.byKey(const Key('insight_card')), findsAtLeastNWidgets(1));
    });

    testWidgets('Error handling and recovery journey', (tester) async {
      await tester.pumpWidget(app.MinQApp(skipOnboarding: true));
      await tester.pumpAndSettle();

      // Simulate network error during quest creation
      await tester.tap(find.byKey(const Key('create_quest_fab')));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('quest_title_field')), 
        'Test Quest'
      );

      // Simulate save failure
      await tester.tap(find.byKey(const Key('save_quest_button')));
      await tester.pumpAndSettle();

      // Verify error handling
      expect(find.byKey(const Key('error_snackbar')), findsOneWidget);
      expect(find.text('Failed to save quest. Saved locally.'), findsOneWidget);

      // Verify retry option
      expect(find.byKey(const Key('retry_button')), findsOneWidget);

      await tester.tap(find.byKey(const Key('retry_button')));
      await tester.pumpAndSettle();

      // Verify quest was saved locally
      expect(find.byKey(const Key('quest_list_screen')), findsOneWidget);
      expect(find.text('Test Quest'), findsOneWidget);
      expect(find.byKey(const Key('offline_indicator')), findsOneWidget);
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

class AiCoachResponse {
  final String message;
  final List<String> quickActions;
  final EncouragementLevel encouragementLevel;
  final List<String> suggestions;

  AiCoachResponse({
    required this.message,
    required this.quickActions,
    required this.encouragementLevel,
    required this.suggestions,
  });
}

enum EncouragementLevel { positive, neutral, motivational }

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