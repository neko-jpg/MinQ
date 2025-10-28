import 'package:flutter_test/flutter_test.dart';
import 'package:minq/core/ai/ai_insights_service.dart';
import 'package:minq/data/repositories/quest_repository.dart';
import 'package:minq/data/repositories/quest_log_repository.dart';
import 'package:minq/domain/ai/ai_insights.dart';
import 'package:isar/isar.dart';

void main() {
  group('AI Insights Service', () {
    test('should generate fallback insights when no data available', () async {
      final service = AIInsightsService.instance;

      // Create mock repositories (simplified for test)
      final mockQuestRepo = MockQuestRepository();
      final mockLogRepo = MockQuestLogRepository();

      final insights = await service.generateInsights(
        userId: 'test_user',
        questRepository: mockQuestRepo,
        questLogRepository: mockLogRepo,
      );

      expect(insights.userId, equals('test_user'));
      expect(insights.recommendations, isNotEmpty);
      expect(insights.progressAnalysis.overallScore, greaterThanOrEqualTo(0.0));
      expect(insights.progressAnalysis.overallScore, lessThanOrEqualTo(1.0));
      expect(insights.trends.weeklyTrends, isNotEmpty);
    });

    test('should create valid recommendation types', () {
      const recommendation = PersonalizedRecommendation(
        id: 'test_1',
        type: RecommendationType.habitSuggestion,
        title: 'Test Recommendation',
        description: 'This is a test recommendation',
        confidence: 0.8,
        relatedHabits: ['habit1', 'habit2'],
        actionText: 'Take Action',
      );

      expect(recommendation.type, equals(RecommendationType.habitSuggestion));
      expect(recommendation.confidence, equals(0.8));
      expect(recommendation.relatedHabits.length, equals(2));
    });

    test('should create valid progress analysis', () {
      const analysis = ProgressAnalysis(
        currentStreak: 5.0,
        longestStreak: 10.0,
        weeklyCompletionRate: 0.7,
        monthlyCompletionRate: 0.6,
        totalHabitsCompleted: 25,
        categoryPerformance: {'学習': 0.8, '運動': 0.6},
        insights: [],
        overallScore: 0.75,
      );

      expect(analysis.currentStreak, equals(5.0));
      expect(analysis.overallScore, equals(0.75));
      expect(analysis.categoryPerformance['学習'], equals(0.8));
    });
  });
}

// Mock implementations for testing
class MockQuestRepository extends QuestRepository {
  MockQuestRepository() : super(null as Isar);

  @override
  Future<List<dynamic>> getQuestsForOwner(String owner) async {
    return [];
  }
}

class MockQuestLogRepository extends QuestLogRepository {
  MockQuestLogRepository() : super(null as Isar);

  @override
  Future<List<dynamic>> getLogsForUser(String uid) async {
    return [];
  }

  @override
  Future<int> calculateStreak(String uid) async {
    return 3;
  }

  @override
  Future<int> calculateLongestStreak(String uid) async {
    return 7;
  }

  @override
  Future<double> calculateWeeklyCompletionRate(String uid) async {
    return 0.7;
  }
}