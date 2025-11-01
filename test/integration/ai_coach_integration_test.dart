import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:isar/isar.dart';
import 'package:minq/core/ai/ai_coach_engine.dart';
import 'package:minq/core/ai/dynamic_prompt_generator.dart';
import 'package:minq/data/local/models/local_quest.dart';
import 'package:minq/main.dart' as app;
import 'package:mocktail/mocktail.dart';

class MockAiCoachEngine extends Mock implements AiCoachEngine {}

class MockDynamicPromptGenerator extends Mock
    implements DynamicPromptGenerator {}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('AI Coach Integration Tests', () {
    late Isar isar;
    late MockAiCoachEngine mockAiCoachEngine;
    late MockDynamicPromptGenerator mockPromptGenerator;

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

      mockAiCoachEngine = MockAiCoachEngine();
      mockPromptGenerator = MockDynamicPromptGenerator();

      // Setup default mock behaviors
      when(
        () => mockPromptGenerator.generateSystemPrompt(any()),
      ).thenReturn('You are MinQ AI Coach. Help users with habit formation.');

      when(() => mockAiCoachEngine.generateResponse(any())).thenAnswer(
        (_) async => AiCoachResponse(
          message: 'Great job! Keep up the good work with your habits.',
          quickActions: [
            QuickAction(
              id: 'create_quest',
              title: 'Create New Quest',
              icon: Icons.add_task,
              route: '/create-quest',
            ),
          ],
          encouragementLevel: EncouragementLevel.positive,
          suggestions: ['Try setting a specific time for your habit'],
        ),
      );
    });

    tearDown(() async {
      await isar.close(deleteFromDisk: true);
    });

    testWidgets('AI Coach contextual response based on user progress', (
      tester,
    ) async {
      // Setup user with specific progress
      final user =
          LocalUser()
            ..uid = 'test-user'
            ..displayName = 'Test User'
            ..currentXP = 150
            ..totalXP = 500
            ..currentLevel = 2
            ..currentStreak = 5
            ..focusTags = ['health', 'fitness']
            ..createdAt = DateTime.now()
            ..updatedAt = DateTime.now();

      // Setup recent quest completions
      final recentQuests = [
        LocalQuestLog()
          ..logId = 'log-1'
          ..uid = 'test-user'
          ..questId = 'quest-1'
          ..questTitle = 'Morning Exercise'
          ..proofType = ProofType.check
          ..xpEarned = 25
          ..timestamp = DateTime.now().subtract(const Duration(hours: 2))
          ..createdAt = DateTime.now(),
        LocalQuestLog()
          ..logId = 'log-2'
          ..uid = 'test-user'
          ..questId = 'quest-2'
          ..questTitle = 'Drink Water'
          ..proofType = ProofType.check
          ..xpEarned = 15
          ..timestamp = DateTime.now().subtract(const Duration(days: 1))
          ..createdAt = DateTime.now(),
      ];

      await isar.writeTxn(() async {
        await isar.localUsers.put(user);
        await isar.localQuestLogs.putAll(recentQuests);
      });

      // Mock contextual AI response
      when(() => mockAiCoachEngine.generateResponse(any())).thenAnswer(
        (_) async => AiCoachResponse(
          message:
              'Excellent work on your 5-day streak! I see you completed "Morning Exercise" today and "Drink Water" yesterday. Your focus on health and fitness is paying off. Keep building these healthy habits!',
          quickActions: [
            QuickAction(
              id: 'create_health_quest',
              title: 'Add Health Quest',
              icon: Icons.favorite,
              route: '/create-quest?category=health',
            ),
            QuickAction(
              id: 'view_streak',
              title: 'View Streak Stats',
              icon: Icons.local_fire_department,
              route: '/stats?focus=streak',
            ),
          ],
          encouragementLevel: EncouragementLevel.motivational,
          suggestions: [
            'Consider adding a nutrition quest to complement your exercise',
            'Try setting reminders for consistent timing',
          ],
        ),
      );

      await tester.pumpWidget(app.MinQApp(skipOnboarding: true));
      await tester.pumpAndSettle();

      // Navigate to AI Coach
      await tester.tap(find.byKey(const Key('ai_coach_tab')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('ai_coach_screen')), findsOneWidget);

      // Send contextual message
      await tester.enterText(
        find.byKey(const Key('ai_chat_input')),
        'How am I doing with my habits?',
      );
      await tester.tap(find.byKey(const Key('send_message_button')));
      await tester.pumpAndSettle();

      // Wait for AI response
      await tester.pump(const Duration(seconds: 2));

      // Verify contextual response
      expect(find.text('Excellent work on your 5-day streak!'), findsOneWidget);
      expect(find.text('Morning Exercise'), findsOneWidget);
      expect(find.text('Drink Water'), findsOneWidget);
      expect(find.text('health and fitness'), findsOneWidget);

      // Verify quick actions are displayed
      expect(find.byKey(const Key('quick_actions_section')), findsOneWidget);
      expect(find.text('Add Health Quest'), findsOneWidget);
      expect(find.text('View Streak Stats'), findsOneWidget);

      // Verify suggestions
      expect(find.byKey(const Key('suggestions_section')), findsOneWidget);
      expect(find.text('Consider adding a nutrition quest'), findsOneWidget);
      expect(find.text('Try setting reminders'), findsOneWidget);

      // Test quick action
      await tester.tap(find.text('Add Health Quest'));
      await tester.pumpAndSettle();

      // Verify navigation to quest creation with category pre-filled
      expect(find.byKey(const Key('quest_creation_screen')), findsOneWidget);
      expect(
        find.text('Health'),
        findsOneWidget,
      ); // Category should be pre-selected
    });

    testWidgets('AI Coach offline fallback responses', (tester) async {
      // Setup user data
      final user =
          LocalUser()
            ..uid = 'test-user'
            ..displayName = 'Test User'
            ..currentXP = 50
            ..totalXP = 200
            ..currentLevel = 1
            ..currentStreak = 0
            ..createdAt = DateTime.now()
            ..updatedAt = DateTime.now();

      await isar.writeTxn(() => isar.localUsers.put(user));

      // Mock offline scenario - AI service throws exception
      when(
        () => mockAiCoachEngine.generateResponse(any()),
      ).thenThrow(NetworkException('No internet connection'));

      // Mock offline fallback response
      when(() => mockAiCoachEngine.generateOfflineFallback(any())).thenReturn(
        AiCoachResponse(
          message:
              'I\'m currently offline, but here are some general tips: Start small, be consistent, and celebrate your progress!',
          quickActions: [
            QuickAction(
              id: 'create_quest',
              title: 'Create Quest',
              icon: Icons.add,
              route: '/create-quest',
            ),
          ],
          encouragementLevel: EncouragementLevel.neutral,
          suggestions: ['Focus on one habit at a time'],
        ),
      );

      await tester.pumpWidget(app.MinQApp(skipOnboarding: true));
      await tester.pumpAndSettle();

      // Navigate to AI Coach
      await tester.tap(find.byKey(const Key('ai_coach_tab')));
      await tester.pumpAndSettle();

      // Verify offline indicator
      expect(find.byKey(const Key('offline_banner')), findsOneWidget);

      // Send message while offline
      await tester.enterText(
        find.byKey(const Key('ai_chat_input')),
        'I need motivation',
      );
      await tester.tap(find.byKey(const Key('send_message_button')));
      await tester.pumpAndSettle();

      // Wait for fallback response
      await tester.pump(const Duration(seconds: 1));

      // Verify offline fallback response
      expect(find.text('I\'m currently offline'), findsOneWidget);
      expect(find.text('Start small, be consistent'), findsOneWidget);
      expect(
        find.byKey(const Key('offline_response_indicator')),
        findsOneWidget,
      );

      // Verify limited quick actions
      expect(find.text('Create Quest'), findsOneWidget);

      // Verify offline fallback was called
      verify(() => mockAiCoachEngine.generateOfflineFallback(any())).called(1);
    });

    testWidgets('AI Coach progressive onboarding integration', (tester) async {
      // Setup new user
      final user =
          LocalUser()
            ..uid = 'new-user'
            ..displayName = 'New User'
            ..currentXP = 0
            ..totalXP = 0
            ..currentLevel = 1
            ..currentStreak = 0
            ..isFirstTime = true
            ..createdAt = DateTime.now()
            ..updatedAt = DateTime.now();

      await isar.writeTxn(() => isar.localUsers.put(user));

      // Mock onboarding AI responses
      when(() => mockAiCoachEngine.generateResponse('Hello')).thenAnswer(
        (_) async => AiCoachResponse(
          message:
              'Welcome to MinQ! I\'m your AI coach, here to help you build lasting habits. Let\'s start by creating your first quest. What habit would you like to work on?',
          quickActions: [
            QuickAction(
              id: 'create_first_quest',
              title: 'Create My First Quest',
              icon: Icons.rocket_launch,
              route: '/create-quest?first=true',
            ),
            QuickAction(
              id: 'browse_templates',
              title: 'Browse Quest Templates',
              icon: Icons.template_outlined,
              route: '/quest-templates',
            ),
          ],
          encouragementLevel: EncouragementLevel.welcoming,
          suggestions: [
            'Start with something small and achievable',
            'Choose a habit you\'re already motivated to do',
          ],
        ),
      );

      await tester.pumpWidget(app.MinQApp(skipOnboarding: true));
      await tester.pumpAndSettle();

      // Navigate to AI Coach
      await tester.tap(find.byKey(const Key('ai_coach_tab')));
      await tester.pumpAndSettle();

      // Verify welcome message for new user
      expect(find.byKey(const Key('ai_welcome_message')), findsOneWidget);
      expect(find.text('Hi there! I\'m your AI coach'), findsOneWidget);

      // Send greeting
      await tester.enterText(find.byKey(const Key('ai_chat_input')), 'Hello');
      await tester.tap(find.byKey(const Key('send_message_button')));
      await tester.pumpAndSettle();

      // Wait for response
      await tester.pump(const Duration(seconds: 2));

      // Verify onboarding response
      expect(find.text('Welcome to MinQ!'), findsOneWidget);
      expect(
        find.text('Let\'s start by creating your first quest'),
        findsOneWidget,
      );

      // Verify onboarding-specific quick actions
      expect(find.text('Create My First Quest'), findsOneWidget);
      expect(find.text('Browse Quest Templates'), findsOneWidget);

      // Test first quest creation
      await tester.tap(find.text('Create My First Quest'));
      await tester.pumpAndSettle();

      // Verify navigation to guided quest creation
      expect(
        find.byKey(const Key('guided_quest_creation_screen')),
        findsOneWidget,
      );
      expect(find.text('Let\'s create your first quest!'), findsOneWidget);
    });

    testWidgets('AI Coach habit analysis and recommendations', (tester) async {
      // Setup user with varied quest history
      final user =
          LocalUser()
            ..uid = 'test-user'
            ..displayName = 'Test User'
            ..currentXP = 300
            ..totalXP = 800
            ..currentLevel = 3
            ..currentStreak = 3
            ..createdAt = DateTime.now()
            ..updatedAt = DateTime.now();

      // Setup quest logs with patterns
      final questLogs = [
        // Successful morning routine
        ...List.generate(
          7,
          (i) =>
              LocalQuestLog()
                ..logId = 'morning-$i'
                ..uid = 'test-user'
                ..questId = 'morning-exercise'
                ..questTitle = 'Morning Exercise'
                ..proofType = ProofType.check
                ..xpEarned = 25
                ..timestamp = DateTime.now().subtract(Duration(days: i))
                ..createdAt = DateTime.now(),
        ),

        // Inconsistent evening routine
        LocalQuestLog()
          ..logId = 'evening-1'
          ..uid = 'test-user'
          ..questId = 'evening-reading'
          ..questTitle = 'Evening Reading'
          ..proofType = ProofType.check
          ..xpEarned = 15
          ..timestamp = DateTime.now().subtract(const Duration(days: 1))
          ..createdAt = DateTime.now(),
        LocalQuestLog()
          ..logId = 'evening-2'
          ..uid = 'test-user'
          ..questId = 'evening-reading'
          ..questTitle = 'Evening Reading'
          ..proofType = ProofType.check
          ..xpEarned = 15
          ..timestamp = DateTime.now().subtract(const Duration(days: 4))
          ..createdAt = DateTime.now(),
      ];

      await isar.writeTxn(() async {
        await isar.localUsers.put(user);
        await isar.localQuestLogs.putAll(questLogs);
      });

      // Mock analytical AI response
      when(
        () => mockAiCoachEngine.generateResponse('Analyze my habits'),
      ).thenAnswer(
        (_) async => AiCoachResponse(
          message:
              'I\'ve analyzed your habit patterns! Your morning exercise routine is fantastic - you\'ve completed it 7 days in a row! However, I notice your evening reading is inconsistent (only 2 out of 7 days). Consider linking it to your successful morning routine or setting a specific time.',
          quickActions: [
            QuickAction(
              id: 'improve_evening_routine',
              title: 'Improve Evening Routine',
              icon: Icons.nightlight,
              route: '/quest-edit/evening-reading',
            ),
            QuickAction(
              id: 'view_patterns',
              title: 'View Habit Patterns',
              icon: Icons.analytics,
              route: '/analytics?view=patterns',
            ),
          ],
          encouragementLevel: EncouragementLevel.analytical,
          suggestions: [
            'Try habit stacking: read after dinner',
            'Set a phone reminder for 8 PM reading time',
            'Start with just 10 minutes to build consistency',
          ],
        ),
      );

      await tester.pumpWidget(app.MinQApp(skipOnboarding: true));
      await tester.pumpAndSettle();

      // Navigate to AI Coach
      await tester.tap(find.byKey(const Key('ai_coach_tab')));
      await tester.pumpAndSettle();

      // Request habit analysis
      await tester.enterText(
        find.byKey(const Key('ai_chat_input')),
        'Analyze my habits',
      );
      await tester.tap(find.byKey(const Key('send_message_button')));
      await tester.pumpAndSettle();

      // Wait for analysis
      await tester.pump(const Duration(seconds: 3));

      // Verify analytical response
      expect(find.text('I\'ve analyzed your habit patterns!'), findsOneWidget);
      expect(
        find.text('morning exercise routine is fantastic'),
        findsOneWidget,
      );
      expect(find.text('7 days in a row'), findsOneWidget);
      expect(find.text('evening reading is inconsistent'), findsOneWidget);
      expect(find.text('only 2 out of 7 days'), findsOneWidget);

      // Verify analytical quick actions
      expect(find.text('Improve Evening Routine'), findsOneWidget);
      expect(find.text('View Habit Patterns'), findsOneWidget);

      // Verify specific suggestions
      expect(find.text('Try habit stacking'), findsOneWidget);
      expect(find.text('Set a phone reminder'), findsOneWidget);
      expect(find.text('Start with just 10 minutes'), findsOneWidget);

      // Test improvement action
      await tester.tap(find.text('Improve Evening Routine'));
      await tester.pumpAndSettle();

      // Verify navigation to quest editing
      expect(find.byKey(const Key('quest_edit_screen')), findsOneWidget);
      expect(find.text('Evening Reading'), findsOneWidget);
    });

    testWidgets('AI Coach motivation and streak recovery', (tester) async {
      // Setup user with broken streak
      final user =
          LocalUser()
            ..uid = 'test-user'
            ..displayName = 'Test User'
            ..currentXP = 200
            ..totalXP = 600
            ..currentLevel = 2
            ..currentStreak = 0
            ..longestStreak = 12
            ..lastActiveDate = DateTime.now().subtract(const Duration(days: 3))
            ..createdAt = DateTime.now()
            ..updatedAt = DateTime.now();

      await isar.writeTxn(() => isar.localUsers.put(user));

      // Mock motivational response for streak recovery
      when(
        () => mockAiCoachEngine.generateResponse('I broke my streak'),
      ).thenAnswer(
        (_) async => AiCoachResponse(
          message:
              'Don\'t worry about breaking your streak! You had an amazing 12-day streak before - that shows you have the ability to build strong habits. Missing a few days doesn\'t erase your progress. Let\'s get back on track today!',
          quickActions: [
            QuickAction(
              id: 'restart_streak',
              title: 'Start New Streak',
              icon: Icons.refresh,
              route: '/quests?action=complete',
            ),
            QuickAction(
              id: 'easy_quest',
              title: 'Create Easy Quest',
              icon: Icons.sentiment_satisfied,
              route: '/create-quest?difficulty=easy',
            ),
          ],
          encouragementLevel: EncouragementLevel.supportive,
          suggestions: [
            'Start with something very small today',
            'Remember: progress, not perfection',
            'Your 12-day streak proves you can do this',
          ],
        ),
      );

      await tester.pumpWidget(app.MinQApp(skipOnboarding: true));
      await tester.pumpAndSettle();

      // Navigate to AI Coach
      await tester.tap(find.byKey(const Key('ai_coach_tab')));
      await tester.pumpAndSettle();

      // Express frustration about broken streak
      await tester.enterText(
        find.byKey(const Key('ai_chat_input')),
        'I broke my streak',
      );
      await tester.tap(find.byKey(const Key('send_message_button')));
      await tester.pumpAndSettle();

      // Wait for supportive response
      await tester.pump(const Duration(seconds: 2));

      // Verify supportive and motivational response
      expect(
        find.text('Don\'t worry about breaking your streak!'),
        findsOneWidget,
      );
      expect(find.text('amazing 12-day streak'), findsOneWidget);
      expect(find.text('doesn\'t erase your progress'), findsOneWidget);
      expect(find.text('Let\'s get back on track today!'), findsOneWidget);

      // Verify recovery-focused quick actions
      expect(find.text('Start New Streak'), findsOneWidget);
      expect(find.text('Create Easy Quest'), findsOneWidget);

      // Verify encouraging suggestions
      expect(find.text('Start with something very small'), findsOneWidget);
      expect(find.text('progress, not perfection'), findsOneWidget);
      expect(find.text('Your 12-day streak proves'), findsOneWidget);

      // Test streak restart
      await tester.tap(find.text('Start New Streak'));
      await tester.pumpAndSettle();

      // Verify navigation to quest completion
      expect(find.byKey(const Key('quest_list_screen')), findsOneWidget);
      expect(find.byKey(const Key('complete_quest_prompt')), findsOneWidget);
    });

    testWidgets('AI Coach conversation history and context retention', (
      tester,
    ) async {
      // Setup user
      final user =
          LocalUser()
            ..uid = 'test-user'
            ..displayName = 'Test User'
            ..currentXP = 100
            ..totalXP = 300
            ..currentLevel = 2
            ..createdAt = DateTime.now()
            ..updatedAt = DateTime.now();

      await isar.writeTxn(() => isar.localUsers.put(user));

      // Mock conversation flow
      when(
        () => mockAiCoachEngine.generateResponse('I want to exercise more'),
      ).thenAnswer(
        (_) async => AiCoachResponse(
          message:
              'That\'s a great goal! What type of exercise interests you most? Running, strength training, yoga, or something else?',
          quickActions: [],
          encouragementLevel: EncouragementLevel.inquisitive,
          suggestions: [],
        ),
      );

      when(
        () => mockAiCoachEngine.generateResponse('I like running'),
      ).thenAnswer(
        (_) async => AiCoachResponse(
          message:
              'Perfect! Running is excellent for building cardiovascular health. Since you mentioned wanting to exercise more and you like running, let\'s create a running quest. How many days per week would you like to start with?',
          quickActions: [
            QuickAction(
              id: 'create_running_quest',
              title: 'Create Running Quest',
              icon: Icons.directions_run,
              route: '/create-quest?category=fitness&type=running',
            ),
          ],
          encouragementLevel: EncouragementLevel.encouraging,
          suggestions: ['Start with 2-3 days per week for beginners'],
        ),
      );

      await tester.pumpWidget(app.MinQApp(skipOnboarding: true));
      await tester.pumpAndSettle();

      // Navigate to AI Coach
      await tester.tap(find.byKey(const Key('ai_coach_tab')));
      await tester.pumpAndSettle();

      // Start conversation
      await tester.enterText(
        find.byKey(const Key('ai_chat_input')),
        'I want to exercise more',
      );
      await tester.tap(find.byKey(const Key('send_message_button')));
      await tester.pumpAndSettle();

      // Wait for first response
      await tester.pump(const Duration(seconds: 2));

      // Verify first response
      expect(find.text('That\'s a great goal!'), findsOneWidget);
      expect(find.text('What type of exercise interests you'), findsOneWidget);

      // Continue conversation
      await tester.enterText(
        find.byKey(const Key('ai_chat_input')),
        'I like running',
      );
      await tester.tap(find.byKey(const Key('send_message_button')));
      await tester.pumpAndSettle();

      // Wait for contextual response
      await tester.pump(const Duration(seconds: 2));

      // Verify context retention
      expect(find.text('Perfect! Running is excellent'), findsOneWidget);
      expect(
        find.text('Since you mentioned wanting to exercise more'),
        findsOneWidget,
      );
      expect(find.text('you like running'), findsOneWidget);

      // Verify conversation history is visible
      expect(find.text('I want to exercise more'), findsOneWidget);
      expect(find.text('I like running'), findsOneWidget);

      // Verify contextual quick action
      expect(find.text('Create Running Quest'), findsOneWidget);

      // Test conversation persistence across app restarts
      await tester.pumpWidget(app.MinQApp(skipOnboarding: true));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('ai_coach_tab')));
      await tester.pumpAndSettle();

      // Verify conversation history is restored
      expect(find.text('I want to exercise more'), findsOneWidget);
      expect(find.text('I like running'), findsOneWidget);
      expect(find.text('Perfect! Running is excellent'), findsOneWidget);
    });
  });
}

// Mock data classes for testing
class AiCoachResponse {
  final String message;
  final List<QuickAction> quickActions;
  final EncouragementLevel encouragementLevel;
  final List<String> suggestions;

  AiCoachResponse({
    required this.message,
    required this.quickActions,
    required this.encouragementLevel,
    required this.suggestions,
  });
}

class QuickAction {
  final String id;
  final String title;
  final IconData icon;
  final String route;

  QuickAction({
    required this.id,
    required this.title,
    required this.icon,
    required this.route,
  });
}

enum EncouragementLevel {
  positive,
  neutral,
  motivational,
  welcoming,
  analytical,
  supportive,
  inquisitive,
  encouraging,
}

class NetworkException implements Exception {
  final String message;
  NetworkException(this.message);
}
