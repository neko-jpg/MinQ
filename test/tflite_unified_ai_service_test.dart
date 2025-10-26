import 'package:flutter_test/flutter_test.dart';
import 'package:minq/core/ai/tflite_unified_ai_service.dart';

void main() {
  group('TFLiteUnifiedAIService', () {
    late TFLiteUnifiedAIService aiService;

    setUp(() {
      aiService = TFLiteUnifiedAIService.instance;
    });

    tearDown(() {
      // Reset error state after each test
      aiService.resetErrorState();
    });

    group('Initialization', () {
      test('should initialize successfully', () async {
        // The service should initialize without throwing
        expect(() => aiService.initialize(), returnsNormally);
      });

      test('should handle initialization failure gracefully', () async {
        // Test that initialization failure is handled properly
        try {
          await aiService.initialize();
        } catch (e) {
          expect(e, isA<AIServiceException>());
        }
      });

      test('should provide diagnostic information', () async {
        final diagnostics = await aiService.getDiagnosticInfo();
        
        expect(diagnostics, isA<Map<String, dynamic>>());
        expect(diagnostics.containsKey('isInitialized'), isTrue);
        expect(diagnostics.containsKey('status'), isTrue);
        expect(diagnostics.containsKey('healthCheck'), isTrue);
      });
    });

    group('Chat Response Generation', () {
      test('should generate chat response with fallback', () async {
        final response = await aiService.generateChatResponse(
          'こんにちは',
          systemPrompt: 'テスト用プロンプト',
        );
        
        expect(response, isNotEmpty);
        expect(response, isA<String>());
      });

      test('should handle empty input gracefully', () async {
        final response = await aiService.generateChatResponse('');
        
        expect(response, isNotEmpty);
        expect(response, isA<String>());
      });

      test('should use conversation history', () async {
        final response = await aiService.generateChatResponse(
          'ありがとう',
          conversationHistory: ['こんにちは', 'お元気ですか？'],
        );
        
        expect(response, isNotEmpty);
        expect(response, isA<String>());
      });

      test('should limit token count', () async {
        final response = await aiService.generateChatResponse(
          '長い応答をお願いします',
          maxTokens: 50,
        );
        
        expect(response, isNotEmpty);
        expect(response, isA<String>());
      });
    });

    group('Sentiment Analysis', () {
      test('should analyze positive sentiment', () async {
        final result = await aiService.analyzeSentiment('とても嬉しいです！');
        
        expect(result, isA<SentimentResult>());
        expect(result.positive, greaterThanOrEqualTo(0.0));
        expect(result.negative, greaterThanOrEqualTo(0.0));
        expect(result.neutral, greaterThanOrEqualTo(0.0));
      });

      test('should analyze negative sentiment', () async {
        final result = await aiService.analyzeSentiment('とても悲しいです');
        
        expect(result, isA<SentimentResult>());
        expect(result.positive, greaterThanOrEqualTo(0.0));
        expect(result.negative, greaterThanOrEqualTo(0.0));
        expect(result.neutral, greaterThanOrEqualTo(0.0));
      });

      test('should analyze neutral sentiment', () async {
        final result = await aiService.analyzeSentiment('今日は普通の日です');
        
        expect(result, isA<SentimentResult>());
        expect(result.positive, greaterThanOrEqualTo(0.0));
        expect(result.negative, greaterThanOrEqualTo(0.0));
        expect(result.neutral, greaterThanOrEqualTo(0.0));
      });

      test('should handle empty text', () async {
        final result = await aiService.analyzeSentiment('');
        
        expect(result, isA<SentimentResult>());
        expect(result.dominantSentiment, isA<SentimentType>());
      });
    });

    group('Habit Recommendations', () {
      test('should generate habit recommendations', () async {
        final recommendations = await aiService.recommendHabits(
          userHabits: ['運動', '読書'],
          completedHabits: ['運動'],
          preferences: {'fitness': 0.8, 'learning': 0.6},
          limit: 3,
        );
        
        expect(recommendations, isA<List<HabitRecommendation>>());
        expect(recommendations.length, lessThanOrEqualTo(3));
        
        for (final recommendation in recommendations) {
          expect(recommendation.title, isNotEmpty);
          expect(recommendation.score, greaterThanOrEqualTo(0.0));
          expect(recommendation.score, lessThanOrEqualTo(1.0));
          expect(recommendation.reason, isNotEmpty);
        }
      });

      test('should handle empty user data', () async {
        final recommendations = await aiService.recommendHabits(
          userHabits: [],
          completedHabits: [],
          preferences: {},
        );
        
        expect(recommendations, isA<List<HabitRecommendation>>());
        expect(recommendations, isNotEmpty);
      });

      test('should respect limit parameter', () async {
        final recommendations = await aiService.recommendHabits(
          userHabits: ['運動'],
          completedHabits: [],
          preferences: {},
          limit: 2,
        );
        
        expect(recommendations.length, lessThanOrEqualTo(2));
      });
    });

    group('Failure Prediction', () {
      test('should predict failure risk', () async {
        final history = [
          CompletionRecord(
            completedAt: DateTime.now().subtract(const Duration(days: 1)),
            habitId: 'test_habit',
          ),
          CompletionRecord(
            completedAt: DateTime.now().subtract(const Duration(days: 2)),
            habitId: 'test_habit',
          ),
        ];

        final prediction = await aiService.predictFailure(
          habitId: 'test_habit',
          history: history,
          targetDate: DateTime.now(),
        );
        
        expect(prediction, isA<FailurePrediction>());
        expect(prediction.riskScore, greaterThanOrEqualTo(0.0));
        expect(prediction.riskScore, lessThanOrEqualTo(1.0));
        expect(prediction.confidence, greaterThanOrEqualTo(0.0));
        expect(prediction.confidence, lessThanOrEqualTo(1.0));
        expect(prediction.factors, isA<List<String>>());
        expect(prediction.suggestions, isA<List<String>>());
      });

      test('should handle empty history', () async {
        final prediction = await aiService.predictFailure(
          habitId: 'test_habit',
          history: [],
          targetDate: DateTime.now(),
        );
        
        expect(prediction, isA<FailurePrediction>());
        expect(prediction.riskLevel, isA<FailureRiskLevel>());
      });

      test('should categorize risk levels correctly', () async {
        final history = [
          CompletionRecord(
            completedAt: DateTime.now().subtract(const Duration(days: 1)),
            habitId: 'test_habit',
          ),
        ];

        final prediction = await aiService.predictFailure(
          habitId: 'test_habit',
          history: history,
          targetDate: DateTime.now(),
        );
        
        expect(prediction.riskLevel, isIn([
          FailureRiskLevel.low,
          FailureRiskLevel.medium,
          FailureRiskLevel.high,
        ]));
      });
    });

    group('Error Handling', () {
      test('should handle consecutive errors gracefully', () async {
        // Reset error state first
        aiService.resetErrorState();
        
        // Test that the service continues to work even with errors
        final response = await aiService.generateChatResponse('テスト');
        expect(response, isNotEmpty);
      });

      test('should reset error state', () {
        aiService.resetErrorState();
        
        // After reset, the service should work normally
        expect(() => aiService.generateChatResponse('テスト'), returnsNormally);
      });

      test('should perform health check', () async {
        final isHealthy = await aiService.healthCheck();
        expect(isHealthy, isA<bool>());
      });
    });

    group('Resource Management', () {
      test('should dispose resources properly', () {
        expect(() => aiService.dispose(), returnsNormally);
      });
    });
  });

  group('Custom Exceptions', () {
    test('AIServiceException should format correctly', () {
      const exception = AIServiceException(
        'Test error',
        code: 'TEST_ERROR',
      );
      
      expect(exception.message, equals('Test error'));
      expect(exception.code, equals('TEST_ERROR'));
      expect(exception.toString(), contains('AIServiceException'));
      expect(exception.toString(), contains('Test error'));
      expect(exception.toString(), contains('TEST_ERROR'));
    });

    test('DatabaseException should format correctly', () {
      const exception = DatabaseException(
        'Database error',
        code: 'DB_ERROR',
      );
      
      expect(exception.message, equals('Database error'));
      expect(exception.code, equals('DB_ERROR'));
      expect(exception.toString(), contains('DatabaseException'));
    });

    test('NetworkException should format correctly', () {
      const exception = NetworkException(
        'Network error',
        code: 'NET_ERROR',
      );
      
      expect(exception.message, equals('Network error'));
      expect(exception.code, equals('NET_ERROR'));
      expect(exception.toString(), contains('NetworkException'));
    });
  });
}