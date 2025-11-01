import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:minq/core/ai/ai_integration_manager.dart';
import 'package:minq/core/ai/habit_story_generator.dart';
import 'package:minq/core/ai/personality_diagnosis_service.dart' as pd;
import 'package:minq/core/ai/tflite_unified_ai_service.dart';
import 'package:minq/core/ai/weekly_report_service.dart';
import 'package:minq/presentation/controllers/ai_concierge_chat_controller.dart';

void main() {
  group('AIFeatureIntegrationTest', () {
    late AIIntegrationManager manager;
    late TFLiteUnifiedAIService unifiedAIService;

    setUpAll(() async {
      unifiedAIService = TFLiteUnifiedAIService.instance;
      await unifiedAIService.initialize();

      manager = AIIntegrationManager.instance;
      await manager.initialize(userId: 'test_user');
    });

    test(
      'TFLiteUnifiedAIService initializes and performs basic operations',
      () async {
        final diagnostics = await unifiedAIService.getDiagnosticInfo();
        expect(diagnostics['isInitialized'], isTrue);

        final chatResponse = await unifiedAIService.generateChatResponse(
          'こんにちは',
        );
        expect(chatResponse, isNotEmpty);

        final sentiment = await unifiedAIService.analyzeSentiment(
          '今日はとても良い気分です！',
        );
        expect(sentiment.positive, greaterThan(0));

        final recommendations = await unifiedAIService.recommendHabits(
          userHabits: ['朝の瞑想'],
          completedHabits: ['読書'],
          preferences: {'focus': 0.8, 'wellness': 0.6},
          limit: 3,
        );
        expect(recommendations, isNotEmpty);

        final prediction = await unifiedAIService.predictFailure(
          habitId: 'test_habit',
          history: [
            CompletionRecord(
              completedAt: DateTime.now().subtract(const Duration(days: 1)),
              habitId: 'test_habit',
            ),
          ],
          targetDate: DateTime.now().add(const Duration(days: 1)),
        );
        expect(prediction.riskScore, inInclusiveRange(0, 1));
      },
    );

    test('AIIntegrationManager performs integrated operations', () async {
      final chatResponse = await manager.generateChatResponse(
        'モチベーションが下がっています',
      );
      expect(chatResponse, isNotEmpty);

      final recommendations = await manager.generateHabitRecommendations(
        userHabits: ['朝の散歩'],
        completedHabits: ['日記'],
        preferences: {'health': 0.9, 'productivity': 0.7},
      );
      expect(recommendations, isNotEmpty);

      final prediction = await manager.predictHabitFailure(
        habitId: 'morning_exercise',
        history: [
          CompletionRecord(
            completedAt: DateTime.now().subtract(const Duration(days: 1)),
            habitId: 'morning_exercise',
          ),
        ],
        targetDate: DateTime.now().add(const Duration(days: 1)),
      );
      expect(prediction.riskScore, greaterThanOrEqualTo(0));

      final diagnosis = await manager.performPersonalityDiagnosis(
        habitHistory: [],
        completionPatterns: [],
        preferences: pd.UserPreferences(
          difficultyPreference: 3,
          preferredDuration: const Duration(minutes: 15),
          preferredTimes: const [pd.TimeOfDay.morning],
          socialPreference: false,
        ),
      );
      expect(diagnosis, isA<pd.PersonalityDiagnosis>());

      final report = await manager.generateWeeklyReport(userId: 'test_user');
      expect(report, isA<WeeklyReport>());

      final story = await manager.generateHabitStory(
        type: StoryType.dailyAchievement,
        progressData: HabitProgressData(
          habitTitle: 'Morning Routine',
          category: 'Health',
          currentStreak: 7,
          totalCompletions: 30,
          weeklyCompletionRate: 0.85,
          startDate: DateTime.now(),
          achievements: [],
          activeHabits: 1,
          averageWeeklyMood: 4.0,
          todayMood: 5,
        ),
      );
      expect(story, isA<HabitStory>());
    });

    test(
      'AIConciergeChatController initializes and handles messages',
      () async {
        final container = ProviderContainer();
        addTearDown(container.dispose);

        // The controller initializes automatically.
        final initialState = await container.read(
          aiConciergeChatControllerProvider.future,
        );
        expect(initialState, isNotEmpty);
        expect(initialState.first.isUser, isFalse);

        await container
            .read(aiConciergeChatControllerProvider.notifier)
            .sendUserMessage('今日のモチベーションを上げてください');
        final afterMessageState = await container.read(
          aiConciergeChatControllerProvider.future,
        );
        expect(afterMessageState.length, greaterThanOrEqualTo(3));
        expect(afterMessageState.last.isUser, isFalse);

        await container
            .read(aiConciergeChatControllerProvider.notifier)
            .resetConversation();
        final resetState = await container.read(
          aiConciergeChatControllerProvider.future,
        );
        expect(resetState.length, 1);
      },
    );

    tearDownAll(() async {
      await manager.shutdown();
    });
  });
}
