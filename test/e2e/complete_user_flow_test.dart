import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:minq/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Complete User Flow E2E Tests', () {
    testWidgets('New user complete journey: onboarding to first achievement', (
      tester,
    ) async {
      await tester.pumpWidget(app.MinQApp());
      await tester.pumpAndSettle();

      // === ONBOARDING FLOW ===

      // Verify onboarding screen
      expect(find.byKey(const Key('onboarding_screen')), findsOneWidget);
      expect(find.text('Welcome to MinQ'), findsOneWidget);

      // Navigate through onboarding screens
      for (int i = 0; i < 3; i++) {
        await tester.tap(find.byKey(const Key('next_button')));
        await tester.pumpAndSettle();
      }

      // Profile setup
      expect(find.byKey(const Key('profile_setup_screen')), findsOneWidget);

      await tester.enterText(
        find.byKey(const Key('display_name_field')),
        'E2E Test User',
      );

      // Select focus tags
      await tester.tap(find.byKey(const Key('tag_health')));
      await tester.tap(find.byKey(const Key('tag_productivity')));
      await tester.pumpAndSettle();

      // Complete onboarding
      await tester.tap(find.byKey(const Key('complete_onboarding_button')));
      await tester.pumpAndSettle();

      // === MAIN APP FLOW ===

      // Verify main app screen
      expect(find.byKey(const Key('main_app_screen')), findsOneWidget);
      expect(find.byKey(const Key('bottom_navigation')), findsOneWidget);

      // Verify progressive hint for first quest
      expect(find.byKey(const Key('progressive_hint')), findsOneWidget);
      expect(
        find.text('Create your first quest to get started!'),
        findsOneWidget,
      );

      // === QUEST CREATION FLOW ===

      // Create first quest
      await tester.tap(find.byKey(const Key('create_quest_fab')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('quest_creation_screen')), findsOneWidget);

      // Fill quest form
      await tester.enterText(
        find.byKey(const Key('quest_title_field')),
        'Daily Morning Walk',
      );
      await tester.enterText(
        find.byKey(const Key('quest_description_field')),
        'Take a 20-minute walk every morning to start the day right',
      );

      // Select category
      await tester.tap(find.byKey(const Key('category_dropdown')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Health'));
      await tester.pumpAndSettle();

      // Set difficulty
      await tester.tap(find.byKey(const Key('difficulty_normal')));
      await tester.pumpAndSettle();

      // Set reminder
      await tester.tap(find.byKey(const Key('reminder_switch')));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('reminder_time_picker')));
      await tester.pumpAndSettle();

      // Select 7:00 AM
      await tester.tap(find.text('7'));
      await tester.tap(find.text('00'));
      await tester.tap(find.text('AM'));
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      // Save quest
      await tester.tap(find.byKey(const Key('save_quest_button')));
      await tester.pumpAndSettle();

      // === QUEST COMPLETION FLOW ===

      // Verify quest appears in list
      expect(find.byKey(const Key('quest_list_screen')), findsOneWidget);
      expect(find.text('Daily Morning Walk'), findsOneWidget);

      // Verify progressive hint for completion
      expect(find.text('Tap on your quest to complete it!'), findsOneWidget);

      // Complete the quest
      await tester.tap(find.text('Daily Morning Walk'));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('quest_detail_screen')), findsOneWidget);

      await tester.tap(find.byKey(const Key('complete_quest_button')));
      await tester.pumpAndSettle();

      // Quest completion screen
      expect(find.byKey(const Key('quest_completion_screen')), findsOneWidget);

      // Add proof (photo)
      await tester.tap(find.byKey(const Key('proof_photo_button')));
      await tester.pumpAndSettle();

      // Mock camera/gallery selection
      await tester.tap(find.byKey(const Key('mock_photo_selection')));
      await tester.pumpAndSettle();

      // Add completion note
      await tester.enterText(
        find.byKey(const Key('completion_note_field')),
        'Great morning walk in the park!',
      );

      // Confirm completion
      await tester.tap(find.byKey(const Key('confirm_completion_button')));
      await tester.pumpAndSettle();

      // === XP AND GAMIFICATION FLOW ===

      // Verify XP gain animation
      expect(find.byKey(const Key('xp_gain_animation')), findsOneWidget);
      expect(find.text('+25 XP'), findsOneWidget);

      // Wait for animation to complete
      await tester.pump(const Duration(seconds: 3));

      // Verify first completion achievement
      expect(
        find.byKey(const Key('achievement_unlock_animation')),
        findsOneWidget,
      );
      expect(find.text('First Quest Complete!'), findsOneWidget);
      expect(find.text('Achievement Unlocked'), findsOneWidget);

      // Wait for achievement animation
      await tester.pump(const Duration(seconds: 3));

      // === AI COACH INTERACTION ===

      // Navigate to AI Coach
      await tester.tap(find.byKey(const Key('ai_coach_tab')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('ai_coach_screen')), findsOneWidget);

      // Verify congratulatory message for first completion
      expect(
        find.text('Congratulations on completing your first quest!'),
        findsOneWidget,
      );

      // Send message to AI Coach
      await tester.enterText(
        find.byKey(const Key('ai_chat_input')),
        'I completed my first quest!',
      );
      await tester.tap(find.byKey(const Key('send_message_button')));
      await tester.pumpAndSettle();

      // Wait for AI response
      await tester.pump(const Duration(seconds: 2));

      // Verify AI response
      expect(
        find.text('Excellent work on your first quest completion!'),
        findsOneWidget,
      );

      // Verify quick actions
      expect(find.byKey(const Key('quick_actions_section')), findsOneWidget);
      expect(find.text('Create Another Quest'), findsOneWidget);

      // === STATISTICS AND PROGRESS ===

      // Navigate to statistics
      await tester.tap(find.byKey(const Key('stats_tab')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('stats_screen')), findsOneWidget);

      // Verify initial statistics
      expect(find.text('1'), findsOneWidget); // Completed quests
      expect(find.text('25 XP'), findsOneWidget); // Total XP
      expect(find.text('Level 1'), findsOneWidget); // Current level
      expect(find.text('1 Day'), findsOneWidget); // Current streak

      // Verify completion rate widget
      expect(find.byKey(const Key('completion_rate_widget')), findsOneWidget);
      expect(find.text('100%'), findsOneWidget); // 1/1 completed

      // === LEAGUE AND RANKING ===

      // Navigate to league
      await tester.tap(find.byKey(const Key('league_tab')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('league_screen')), findsOneWidget);

      // Verify initial league placement
      expect(find.text('Bronze League'), findsOneWidget);
      expect(find.byKey(const Key('bronze_league_badge')), findsOneWidget);

      // Verify league progress
      expect(find.byKey(const Key('league_progress_bar')), findsOneWidget);
      expect(find.text('25 / 800 XP'), findsOneWidget); // Progress to silver

      // === SETTINGS AND CUSTOMIZATION ===

      // Navigate to settings
      await tester.tap(find.byKey(const Key('settings_tab')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('settings_screen')), findsOneWidget);

      // Test theme customization
      await tester.tap(find.byKey(const Key('theme_settings_tile')));
      await tester.pumpAndSettle();

      // Switch to dark mode
      await tester.tap(find.byKey(const Key('dark_mode_switch')));
      await tester.pumpAndSettle();

      // Verify theme change
      expect(find.byKey(const Key('dark_theme_indicator')), findsOneWidget);

      // Change accent color
      await tester.tap(find.byKey(const Key('accent_color_purple')));
      await tester.pumpAndSettle();

      // Save theme settings
      await tester.tap(find.byKey(const Key('save_theme_button')));
      await tester.pumpAndSettle();

      // Navigate back to main screen
      await tester.tap(find.byKey(const Key('back_button')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('back_button')));
      await tester.pumpAndSettle();

      // === SECOND QUEST CREATION (BUILDING HABITS) ===

      // Create second quest to build streak
      await tester.tap(find.byKey(const Key('create_quest_fab')));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('quest_title_field')),
        'Evening Reading',
      );
      await tester.enterText(
        find.byKey(const Key('quest_description_field')),
        'Read for 30 minutes before bed',
      );

      // Select productivity category
      await tester.tap(find.byKey(const Key('category_dropdown')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Productivity'));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('save_quest_button')));
      await tester.pumpAndSettle();

      // Complete second quest
      await tester.tap(find.text('Evening Reading'));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('complete_quest_button')));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('proof_check_button')));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('confirm_completion_button')));
      await tester.pumpAndSettle();

      // Verify XP gain and streak continuation
      expect(find.text('+25 XP'), findsOneWidget);

      await tester.pump(const Duration(seconds: 3));

      // === CHALLENGE PARTICIPATION ===

      // Navigate to challenges
      await tester.tap(find.byKey(const Key('challenges_tab')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('challenges_screen')), findsOneWidget);

      // Find and join a beginner challenge
      expect(find.text('7-Day Habit Builder'), findsOneWidget);
      await tester.tap(find.text('7-Day Habit Builder'));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('challenge_detail_screen')), findsOneWidget);

      // Join challenge
      await tester.tap(find.byKey(const Key('join_challenge_button')));
      await tester.pumpAndSettle();

      // Verify challenge joined
      expect(find.text('Challenge Joined!'), findsOneWidget);
      expect(
        find.byKey(const Key('challenge_progress_indicator')),
        findsOneWidget,
      );

      // === FINAL VERIFICATION ===

      // Navigate back to main screen
      await tester.tap(find.byKey(const Key('back_button')));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('quests_tab')));
      await tester.pumpAndSettle();

      // Verify both quests are completed
      expect(find.text('Daily Morning Walk'), findsOneWidget);
      expect(find.text('Evening Reading'), findsOneWidget);
      expect(
        find.byKey(const Key('completed_quest_indicator')),
        findsNWidgets(2),
      );

      // Verify streak display
      expect(find.text('2 Day Streak'), findsOneWidget);
      expect(find.byKey(const Key('streak_fire_icon')), findsOneWidget);

      // Check final statistics
      await tester.tap(find.byKey(const Key('stats_tab')));
      await tester.pumpAndSettle();

      expect(find.text('2'), findsOneWidget); // Completed quests
      expect(find.text('50 XP'), findsOneWidget); // Total XP
      expect(find.text('2 Day'), findsOneWidget); // Current streak

      // Verify user has successfully completed the full onboarding journey
      // and is ready to continue building habits
      expect(
        find.byKey(const Key('user_journey_complete_indicator')),
        findsOneWidget,
      );
    });

    testWidgets('Returning user daily routine flow', (tester) async {
      // This test simulates a returning user's daily routine
      await tester.pumpWidget(
        app.MinQApp(
          skipOnboarding: true,
          mockUserData: MockUserData.returningUser(),
        ),
      );
      await tester.pumpAndSettle();

      // === DAILY CHECK-IN ===

      // Verify daily check-in prompt
      expect(find.byKey(const Key('daily_checkin_prompt')), findsOneWidget);
      expect(
        find.text('Good morning! Ready for another great day?'),
        findsOneWidget,
      );

      // View today's quests
      expect(find.byKey(const Key('todays_quests_section')), findsOneWidget);
      expect(find.text('3 quests for today'), findsOneWidget);

      // === MORNING ROUTINE ===

      // Complete morning exercise quest
      await tester.tap(find.text('Morning Exercise'));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('quick_complete_button')));
      await tester.pumpAndSettle();

      // Verify quick completion (no proof required for trusted user)
      expect(find.text('Quest completed!'), findsOneWidget);

      await tester.pump(const Duration(seconds: 1));

      // Complete morning meditation
      await tester.tap(find.text('Morning Meditation'));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('quick_complete_button')));
      await tester.pumpAndSettle();

      // === STREAK MILESTONE ===

      // Verify streak milestone achievement (30 days)
      expect(
        find.byKey(const Key('streak_milestone_animation')),
        findsOneWidget,
      );
      expect(find.text('30-Day Streak Achieved!'), findsOneWidget);
      expect(find.text('Consistency Master Badge Unlocked'), findsOneWidget);

      await tester.pump(const Duration(seconds: 4));

      // === AI COACH DAILY INSIGHT ===

      // Navigate to AI Coach for daily insight
      await tester.tap(find.byKey(const Key('ai_coach_tab')));
      await tester.pumpAndSettle();

      // Verify daily insight is automatically provided
      expect(find.byKey(const Key('daily_insight_card')), findsOneWidget);
      expect(find.text('Your 30-day streak is incredible!'), findsOneWidget);

      // === CHALLENGE PROGRESS ===

      // Check challenge progress
      await tester.tap(find.byKey(const Key('challenges_tab')));
      await tester.pumpAndSettle();

      // Verify active challenge progress
      expect(find.text('Mindfulness March'), findsOneWidget);
      expect(find.text('15/31 days complete'), findsOneWidget);

      // === EVENING ROUTINE ===

      // Navigate back to quests for evening routine
      await tester.tap(find.byKey(const Key('quests_tab')));
      await tester.pumpAndSettle();

      // Complete evening reading quest
      await tester.tap(find.text('Evening Reading'));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('quick_complete_button')));
      await tester.pumpAndSettle();

      // === DAILY SUMMARY ===

      // Verify daily completion summary
      expect(find.byKey(const Key('daily_summary_card')), findsOneWidget);
      expect(find.text('Perfect day! All 3 quests completed'), findsOneWidget);
      expect(find.text('+75 XP earned today'), findsOneWidget);

      // === LEAGUE PROGRESSION ===

      // Check league status
      await tester.tap(find.byKey(const Key('league_tab')));
      await tester.pumpAndSettle();

      // Verify league progression
      expect(find.text('Gold League'), findsOneWidget);
      expect(find.text('Rank #5'), findsOneWidget);
      expect(find.text('1,250 weekly XP'), findsOneWidget);

      // === STATISTICS REVIEW ===

      // Review progress statistics
      await tester.tap(find.byKey(const Key('stats_tab')));
      await tester.pumpAndSettle();

      // Verify comprehensive statistics
      expect(find.text('Level 8'), findsOneWidget);
      expect(find.text('2,450 Total XP'), findsOneWidget);
      expect(find.text('30 Day Streak'), findsOneWidget);
      expect(find.text('92% Completion Rate'), findsOneWidget);

      // Check monthly progress
      await tester.tap(find.byKey(const Key('monthly_view_tab')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('monthly_heatmap')), findsOneWidget);
      expect(find.text('28/31 days active this month'), findsOneWidget);

      // Verify the returning user has maintained their habit momentum
      expect(find.byKey(const Key('habit_momentum_indicator')), findsOneWidget);
    });

    testWidgets('Power user advanced features flow', (tester) async {
      // This test covers advanced features for experienced users
      await tester.pumpWidget(
        app.MinQApp(
          skipOnboarding: true,
          mockUserData: MockUserData.powerUser(),
        ),
      );
      await tester.pumpAndSettle();

      // === ADVANCED QUEST MANAGEMENT ===

      // Navigate to quest management
      await tester.tap(find.byKey(const Key('quest_management_button')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('advanced_quest_screen')), findsOneWidget);

      // Test bulk operations
      await tester.tap(find.byKey(const Key('select_all_checkbox')));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('bulk_actions_button')));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Mark as Complete'));
      await tester.pumpAndSettle();

      // Verify bulk completion
      expect(find.text('5 quests completed'), findsOneWidget);

      // === CUSTOM CHALLENGE CREATION ===

      // Navigate to challenges
      await tester.tap(find.byKey(const Key('challenges_tab')));
      await tester.pumpAndSettle();

      // Create custom challenge
      await tester.tap(find.byKey(const Key('create_challenge_fab')));
      await tester.pumpAndSettle();

      expect(
        find.byKey(const Key('challenge_creation_screen')),
        findsOneWidget,
      );

      await tester.enterText(
        find.byKey(const Key('challenge_title_field')),
        'Ultimate Productivity Challenge',
      );
      await tester.enterText(
        find.byKey(const Key('challenge_description_field')),
        'Complete 50 productivity tasks in 30 days',
      );

      // Set challenge parameters
      await tester.tap(find.byKey(const Key('duration_dropdown')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('30 days'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key('target_value_field')), '50');

      // Set rewards
      await tester.tap(find.byKey(const Key('add_reward_button')));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('reward_name_field')),
        'Productivity Master Badge',
      );

      await tester.tap(find.byKey(const Key('save_challenge_button')));
      await tester.pumpAndSettle();

      // Verify challenge created
      expect(find.text('Challenge created successfully!'), findsOneWidget);

      // === ADVANCED ANALYTICS ===

      // Navigate to advanced analytics
      await tester.tap(find.byKey(const Key('stats_tab')));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('advanced_analytics_button')));
      await tester.pumpAndSettle();

      expect(
        find.byKey(const Key('advanced_analytics_screen')),
        findsOneWidget,
      );

      // Test custom date range
      await tester.tap(find.byKey(const Key('date_range_picker')));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Last 90 days'));
      await tester.pumpAndSettle();

      // Verify advanced charts
      expect(find.byKey(const Key('trend_analysis_chart')), findsOneWidget);
      expect(
        find.byKey(const Key('category_performance_chart')),
        findsOneWidget,
      );
      expect(find.byKey(const Key('time_pattern_heatmap')), findsOneWidget);

      // Test data export
      await tester.tap(find.byKey(const Key('export_data_button')));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Export as CSV'));
      await tester.pumpAndSettle();

      expect(find.text('Data exported successfully'), findsOneWidget);

      // === AUTOMATION RULES ===

      // Navigate to automation settings
      await tester.tap(find.byKey(const Key('settings_tab')));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('automation_settings_tile')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('automation_screen')), findsOneWidget);

      // Create automation rule
      await tester.tap(find.byKey(const Key('create_rule_button')));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('rule_name_field')),
        'Auto-complete morning routine',
      );

      // Set trigger
      await tester.tap(find.byKey(const Key('trigger_dropdown')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Time-based'));
      await tester.pumpAndSettle();

      // Set action
      await tester.tap(find.byKey(const Key('action_dropdown')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Complete quest'));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('save_rule_button')));
      await tester.pumpAndSettle();

      // === API INTEGRATION ===

      // Test third-party integrations
      await tester.tap(find.byKey(const Key('integrations_tile')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('integrations_screen')), findsOneWidget);

      // Connect fitness tracker
      await tester.tap(find.byKey(const Key('connect_fitness_tracker')));
      await tester.pumpAndSettle();

      expect(find.text('Fitness tracker connected'), findsOneWidget);

      // Verify power user features are fully functional
      expect(
        find.byKey(const Key('power_user_features_active')),
        findsOneWidget,
      );
    });
  });
}

// Mock data classes for testing different user types
class MockUserData {
  static Map<String, dynamic> returningUser() => {
    'uid': 'returning-user',
    'displayName': 'Returning User',
    'currentXP': 450,
    'totalXP': 2450,
    'currentLevel': 8,
    'currentStreak': 29,
    'longestStreak': 45,
    'currentLeague': 'gold',
    'completedQuests': 98,
    'totalQuests': 106,
    'joinDate': DateTime.now().subtract(const Duration(days: 120)),
  };

  static Map<String, dynamic> powerUser() => {
    'uid': 'power-user',
    'displayName': 'Power User',
    'currentXP': 800,
    'totalXP': 5200,
    'currentLevel': 15,
    'currentStreak': 67,
    'longestStreak': 89,
    'currentLeague': 'diamond',
    'completedQuests': 245,
    'totalQuests': 267,
    'isPremium': true,
    'joinDate': DateTime.now().subtract(const Duration(days: 365)),
  };
}
