import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:minq/core/analytics/behavior_analysis_service.dart';
import 'package:minq/core/analytics/insights_engine.dart';
import 'package:minq/core/analytics/dashboard_service.dart';
import 'package:minq/core/analytics/database_service.dart';
import 'package:minq/domain/analytics/behavior_pattern.dart';
import 'package:minq/domain/analytics/analytics_insight.dart';
import 'package:minq/domain/analytics/dashboard_config.dart';
import 'package:minq/domain/quest/quest.dart';

import 'analytics_system_test.mocks.dart';

@GenerateMocks([DatabaseService])
void main() {
  group('Analytics System Tests', () {
    late MockDatabaseService mockDatabaseService;
    late BehaviorAnalysisService behaviorAnalysisService;
    late InsightsEngine insightsEngine;
    late DashboardService dashboardService;

    setUp(() {
      mockDatabaseService = MockDatabaseService();
      behaviorAnalysisService = BehaviorAnalysisService(mockDatabaseService);
      insightsEngine = InsightsEngine(behaviorAnalysisService);
      dashboardService = DashboardService(mockDatabaseService);
    });

    group('BehaviorAnalysisService', () {
      test('should calculate habit continuity rate correctly', () async {
        // Arrange
        final startDate = DateTime(2024, 1, 1);
        final endDate = DateTime(2024, 1, 7);
        final mockQuests = [
          _createMockQuest(DateTime(2024, 1, 1)),
          _createMockQuest(DateTime(2024, 1, 2)),
          _createMockQuest(DateTime(2024, 1, 4)),
        ];

        when(mockDatabaseService.getQuestsInDateRange(startDate, endDate))
            .thenAnswer((_) async => mockQuests);

        // Act
        final continuityRate = await behaviorAnalysisService.analyzeHabitContinuityRate(
          startDate: startDate,
          endDate: endDate,
        );

        // Assert
        expect(continuityRate, closeTo(0.43, 0.01)); // 3 active days out of 7 total days
        verify(mockDatabaseService.getQuestsInDateRange(startDate, endDate)).called(1);
      });

      test('should return zero continuity rate for empty quest list', () async {
        // Arrange
        final startDate = DateTime(2024, 1, 1);
        final endDate = DateTime(2024, 1, 7);

        when(mockDatabaseService.getQuestsInDateRange(startDate, endDate))
            .thenAnswer((_) async => []);

        // Act
        final continuityRate = await behaviorAnalysisService.analyzeHabitContinuityRate(
          startDate: startDate,
          endDate: endDate,
        );

        // Assert
        expect(continuityRate, equals(0.0));
      });

      test('should analyze time patterns correctly', () async {
        // Arrange
        final mockQuests = [
          _createMockQuest(DateTime(2024, 1, 1, 9, 0)), // 9 AM
          _createMockQuest(DateTime(2024, 1, 2, 9, 30)), // 9 AM
          _createMockQuest(DateTime(2024, 1, 3, 14, 0)), // 2 PM
        ];

        when(mockDatabaseService.getAllCompletedQuests())
            .thenAnswer((_) async => mockQuests);

        // Act
        final timePatterns = await behaviorAnalysisService.analyzeTimePatterns();

        // Assert
        expect(timePatterns, isNotEmpty);
        final morningPattern = timePatterns.firstWhere((p) => p.hour == 9);
        expect(morningPattern.completionCount, equals(2));
        expect(morningPattern.successRate, equals(1.0)); // All completed quests are successful
      });

      test('should analyze day of week patterns correctly', () async {
        // Arrange
        final mockQuests = [
          _createMockQuest(DateTime(2024, 1, 1)), // Monday
          _createMockQuest(DateTime(2024, 1, 2)), // Tuesday
          _createMockQuest(DateTime(2024, 1, 8)), // Monday
        ];

        when(mockDatabaseService.getAllCompletedQuests())
            .thenAnswer((_) async => mockQuests);

        // Act
        final dayPatterns = await behaviorAnalysisService.analyzeDayOfWeekPatterns();

        // Assert
        expect(dayPatterns, isNotEmpty);
        final mondayPattern = dayPatterns.firstWhere((p) => p.dayOfWeek == 1);
        expect(mondayPattern.completionCount, equals(2));
        expect(mondayPattern.dayName, equals('月'));
      });

      test('should analyze seasonal patterns correctly', () async {
        // Arrange
        final mockQuests = [
          _createMockQuestWithCategory(DateTime(2024, 3, 15), '健康'), // Spring
          _createMockQuestWithCategory(DateTime(2024, 6, 15), '学習'), // Summer
          _createMockQuestWithCategory(DateTime(2024, 3, 20), '健康'), // Spring
        ];

        when(mockDatabaseService.getAllCompletedQuests())
            .thenAnswer((_) async => mockQuests);

        // Act
        final seasonalPatterns = await behaviorAnalysisService.analyzeSeasonalPatterns();

        // Assert
        expect(seasonalPatterns, isNotEmpty);
        final springPattern = seasonalPatterns.firstWhere((p) => p.season == Season.spring);
        expect(springPattern.completionCount, equals(2));
        expect(springPattern.popularCategories, contains('健康'));
      });
    });

    group('InsightsEngine', () {
      test('should generate insights for high continuity rate', () async {
        // Arrange
        when(mockDatabaseService.getQuestsInDateRange(any, any))
            .thenAnswer((_) async => List.generate(25, (i) => _createMockQuest(DateTime.now().subtract(Duration(days: i)))));

        // Act
        final insights = await insightsEngine.generateAllInsights();

        // Assert
        expect(insights, isNotEmpty);
        final continuityInsight = insights.firstWhere(
          (insight) => insight.type == InsightType.habitContinuity,
          orElse: () => throw StateError('No continuity insight found'),
        );
        expect(continuityInsight.title, contains('素晴らしい継続率'));
        expect(continuityInsight.priority, equals(InsightPriority.medium));
      });

      test('should generate insights for low continuity rate', () async {
        // Arrange
        when(mockDatabaseService.getQuestsInDateRange(any, any))
            .thenAnswer((_) async => List.generate(5, (i) => _createMockQuest(DateTime.now().subtract(Duration(days: i * 3)))));

        // Act
        final insights = await insightsEngine.generateAllInsights();

        // Assert
        expect(insights, isNotEmpty);
        final continuityInsight = insights.firstWhere(
          (insight) => insight.type == InsightType.habitContinuity,
          orElse: () => throw StateError('No continuity insight found'),
        );
        expect(continuityInsight.title, contains('継続率の改善が必要'));
        expect(continuityInsight.priority, equals(InsightPriority.high));
      });

      test('should generate optimization insights for best time patterns', () async {
        // Arrange
        final mockQuests = List.generate(10, (i) => _createMockQuest(DateTime(2024, 1, 1, 9, 0))); // All at 9 AM
        when(mockDatabaseService.getAllCompletedQuests())
            .thenAnswer((_) async => mockQuests);
        when(mockDatabaseService.getQuestsInDateRange(any, any))
            .thenAnswer((_) async => mockQuests);

        // Act
        final insights = await insightsEngine.generateAllInsights();

        // Assert
        final optimizationInsights = insights.where((insight) => insight.type == InsightType.optimization).toList();
        expect(optimizationInsights, isNotEmpty);
        final timeOptimization = optimizationInsights.firstWhere(
          (insight) => insight.title.contains('最適な時間帯'),
          orElse: () => throw StateError('No time optimization insight found'),
        );
        expect(timeOptimization.description, contains('9時台'));
      });
    });

    group('DashboardService', () {
      test('should return default dashboards for new user', () async {
        // Arrange
        when(mockDatabaseService.getUserDashboards('test_user'))
            .thenAnswer((_) async => []);

        // Act
        final dashboards = await dashboardService.getUserDashboards('test_user');

        // Assert
        expect(dashboards, hasLength(2)); // overview and detailed
        expect(dashboards.first.id, equals('overview'));
        expect(dashboards.last.id, equals('detailed'));
      });

      test('should return existing dashboards for user', () async {
        // Arrange
        final existingDashboards = [DefaultDashboardConfigs.overview];
        when(mockDatabaseService.getUserDashboards('test_user'))
            .thenAnswer((_) async => existingDashboards);

        // Act
        final dashboards = await dashboardService.getUserDashboards('test_user');

        // Assert
        expect(dashboards, equals(existingDashboards));
        verify(mockDatabaseService.getUserDashboards('test_user')).called(1);
      });

      test('should add widget to dashboard', () async {
        // Arrange
        final dashboard = DefaultDashboardConfigs.overview;
        when(mockDatabaseService.getUserDashboards('test_user'))
            .thenAnswer((_) async => [dashboard]);

        final newWidget = DashboardWidgetConfig(
          id: 'test_widget',
          type: DashboardWidgetType.streakCounter,
          title: 'Test Widget',
          position: WidgetPosition(row: 0, column: 0),
          size: WidgetSize(width: 2, height: 1),
          isVisible: true,
          settings: {},
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        // Act
        await dashboardService.addWidget('test_user', 'overview', newWidget);

        // Assert
        verify(mockDatabaseService.saveDashboardConfig('test_user', any)).called(1);
      });

      test('should get available widget types', () {
        // Act
        final widgetTypes = dashboardService.getAvailableWidgetTypes();

        // Assert
        expect(widgetTypes, equals(DashboardWidgetType.values));
      });

      test('should get widget type descriptions', () {
        // Act & Assert
        expect(dashboardService.getWidgetTypeDescription(DashboardWidgetType.streakCounter), 
               equals('ストリーク数を表示'));
        expect(dashboardService.getWidgetTypeDescription(DashboardWidgetType.completionRate), 
               equals('完了率を表示'));
        expect(dashboardService.getWidgetTypeDescription(DashboardWidgetType.insights), 
               equals('AIインサイト'));
      });
    });

    group('Domain Models', () {
      test('BehaviorPattern should be created correctly', () {
        // Arrange & Act
        final pattern = BehaviorPattern(
          type: PatternType.timeOfDay,
          name: 'Morning Pattern',
          description: 'User is most active in the morning',
          confidence: 0.85,
          frequency: 10,
          impact: 0.7,
          suggestions: ['Schedule more tasks in the morning'],
          metadata: {'hour': 9},
          detectedAt: DateTime.now(),
        );

        // Assert
        expect(pattern.type, equals(PatternType.timeOfDay));
        expect(pattern.name, equals('Morning Pattern'));
        expect(pattern.confidence, equals(0.85));
        expect(pattern.suggestions, contains('Schedule more tasks in the morning'));
      });

      test('AnalyticsInsight should be created correctly', () {
        // Arrange & Act
        final insight = AnalyticsInsight(
          id: 'test_insight',
          type: InsightType.optimization,
          priority: InsightPriority.high,
          title: 'Test Insight',
          description: 'This is a test insight',
          actionItems: [],
          confidence: 0.9,
          relatedPatterns: [],
          metadata: {},
          generatedAt: DateTime.now(),
        );

        // Assert
        expect(insight.id, equals('test_insight'));
        expect(insight.type, equals(InsightType.optimization));
        expect(insight.priority, equals(InsightPriority.high));
        expect(insight.confidence, equals(0.9));
        expect(insight.isExpired, isFalse);
      });

      test('CustomDashboardConfig should be created correctly', () {
        // Arrange & Act
        final config = CustomDashboardConfig(
          id: 'test_dashboard',
          name: 'Test Dashboard',
          description: 'A test dashboard',
          widgets: [],
          layout: DashboardLayout(columns: 4, rowHeight: 120, spacing: 16),
          isDefault: false,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        // Assert
        expect(config.id, equals('test_dashboard'));
        expect(config.name, equals('Test Dashboard'));
        expect(config.layout.columns, equals(4));
        expect(config.isDefault, isFalse);
      });
    });
  });
}

// Helper functions for creating mock objects
Quest _createMockQuest(DateTime createdAt) {
  return Quest()
    ..owner = 'test_user'
    ..title = 'Test Quest'
    ..category = 'テスト'
    ..status = QuestStatus.active
    ..createdAt = createdAt;
}

Quest _createMockQuestWithCategory(DateTime createdAt, String category) {
  return Quest()
    ..owner = 'test_user'
    ..title = 'Test Quest'
    ..category = category
    ..status = QuestStatus.active
    ..createdAt = createdAt;
}