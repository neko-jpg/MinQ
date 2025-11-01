import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:minq/core/analytics/services/behavior_analysis_service.dart';
import 'package:minq/core/analytics/dashboard_service.dart';
import 'package:minq/core/analytics/database_service.dart';
import 'package:minq/core/analytics/insights_engine.dart';
import 'package:minq/domain/analytics/analytics_insight.dart';
import 'package:minq/domain/analytics/behavior_pattern.dart';
import 'package:minq/domain/analytics/dashboard_config.dart';

final insightsEngineProvider = Provider<InsightsEngine>((ref) {
  final behaviorAnalysisService = ref.watch(behaviorAnalysisServiceProvider);
  return InsightsEngine(behaviorAnalysisService);
});

final dashboardServiceProvider = Provider<DashboardService>((ref) {
  final databaseService = ref.watch(databaseServiceProvider);
  return DashboardService(databaseService);
});

// Data Providers
final userDashboardsProvider = FutureProvider<List<CustomDashboardConfig>>((
  ref,
) async {
  final dashboardService = ref.watch(dashboardServiceProvider);
  return await dashboardService.getUserDashboards(
    'current_user',
  ); // TODO: 実際のユーザーIDを使用
});

final selectedDashboardProvider =
    FutureProvider.family<CustomDashboardConfig, String>((
      ref,
      dashboardId,
    ) async {
      final dashboards = await ref.watch(userDashboardsProvider.future);
      return dashboards.firstWhere(
        (dashboard) => dashboard.id == dashboardId,
        orElse: () => DefaultDashboardConfigs.overview,
      );
    });

final analyticsInsightsProvider = FutureProvider<List<AnalyticsInsight>>((
  ref,
) async {
  final insightsEngine = ref.watch(insightsEngineProvider);
  return await insightsEngine.generateAllInsights();
});

final timePatternProvider = FutureProvider<List<TimePattern>>((ref) async {
  final behaviorAnalysisService = ref.watch(behaviorAnalysisServiceProvider);
  return await behaviorAnalysisService.analyzeTimePatterns();
});

final dayOfWeekPatternProvider = FutureProvider<List<DayOfWeekPattern>>((
  ref,
) async {
  final behaviorAnalysisService = ref.watch(behaviorAnalysisServiceProvider);
  return await behaviorAnalysisService.analyzeDayOfWeekPatterns();
});

final seasonalPatternProvider = FutureProvider<List<SeasonalPattern>>((
  ref,
) async {
  final behaviorAnalysisService = ref.watch(behaviorAnalysisServiceProvider);
  return await behaviorAnalysisService.analyzeSeasonalPatterns();
});

final failurePatternsProvider = FutureProvider<List<BehaviorPattern>>((
  ref,
) async {
  final behaviorAnalysisService = ref.watch(behaviorAnalysisServiceProvider);
  return await behaviorAnalysisService.analyzeFailurePatterns();
});

final goalPredictionsProvider = FutureProvider<List<GoalPrediction>>((
  ref,
) async {
  final behaviorAnalysisService = ref.watch(behaviorAnalysisServiceProvider);
  return await behaviorAnalysisService.generateGoalPredictions();
});

final riskWarningsProvider = FutureProvider<List<AnalyticsInsight>>((
  ref,
) async {
  final behaviorAnalysisService = ref.watch(behaviorAnalysisServiceProvider);
  return await behaviorAnalysisService.generateRiskWarnings();
});

// Habit Continuity Rate Provider
final habitContinuityRateProvider = FutureProvider.family<double, DateRange>((
  ref,
  dateRange,
) async {
  final behaviorAnalysisService = ref.watch(behaviorAnalysisServiceProvider);
  return await behaviorAnalysisService.analyzeHabitContinuityRate(
    startDate: dateRange.startDate,
    endDate: dateRange.endDate,
  );
});

// Current Period Continuity Rate (last 30 days)
final currentContinuityRateProvider = FutureProvider<double>((ref) async {
  final endDate = DateTime.now();
  final startDate = endDate.subtract(const Duration(days: 30));
  final dateRange = DateRange(startDate: startDate, endDate: endDate);
  return await ref.watch(habitContinuityRateProvider(dateRange).future);
});

// Weekly Continuity Rate (last 7 days)
final weeklyContinuityRateProvider = FutureProvider<double>((ref) async {
  final endDate = DateTime.now();
  final startDate = endDate.subtract(const Duration(days: 7));
  final dateRange = DateRange(startDate: startDate, endDate: endDate);
  return await ref.watch(habitContinuityRateProvider(dateRange).future);
});

// Monthly Continuity Rate (last 30 days)
final monthlyContinuityRateProvider = FutureProvider<double>((ref) async {
  final endDate = DateTime.now();
  final startDate = endDate.subtract(const Duration(days: 30));
  final dateRange = DateRange(startDate: startDate, endDate: endDate);
  return await ref.watch(habitContinuityRateProvider(dateRange).future);
});

// Dashboard State Providers
final selectedDashboardIdProvider = StateProvider<String>((ref) => 'overview');

final isEditModeProvider = StateProvider<bool>((ref) => false);

// Analytics Filters
final analyticsDateRangeProvider = StateProvider<DateRange>((ref) {
  final endDate = DateTime.now();
  final startDate = endDate.subtract(const Duration(days: 30));
  return DateRange(startDate: startDate, endDate: endDate);
});

final analyticsFilterProvider = StateProvider<AnalyticsFilter>((ref) {
  return AnalyticsFilter(
    categories: [],
    timeRange: TimeRange.month,
    includeFailures: true,
    includeSuccesses: true,
  );
});

// Helper Classes
class DateRange {
  final DateTime startDate;
  final DateTime endDate;

  DateRange({required this.startDate, required this.endDate});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DateRange &&
        other.startDate == startDate &&
        other.endDate == endDate;
  }

  @override
  int get hashCode => Object.hash(startDate, endDate);
}

class AnalyticsFilter {
  final List<String> categories;
  final TimeRange timeRange;
  final bool includeFailures;
  final bool includeSuccesses;

  AnalyticsFilter({
    required this.categories,
    required this.timeRange,
    required this.includeFailures,
    required this.includeSuccesses,
  });

  AnalyticsFilter copyWith({
    List<String>? categories,
    TimeRange? timeRange,
    bool? includeFailures,
    bool? includeSuccesses,
  }) {
    return AnalyticsFilter(
      categories: categories ?? this.categories,
      timeRange: timeRange ?? this.timeRange,
      includeFailures: includeFailures ?? this.includeFailures,
      includeSuccesses: includeSuccesses ?? this.includeSuccesses,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AnalyticsFilter &&
        other.categories == categories &&
        other.timeRange == timeRange &&
        other.includeFailures == includeFailures &&
        other.includeSuccesses == includeSuccesses;
  }

  @override
  int get hashCode =>
      Object.hash(categories, timeRange, includeFailures, includeSuccesses);
}

enum TimeRange { week, month, quarter, year }

extension TimeRangeExtension on TimeRange {
  String get displayName {
    switch (this) {
      case TimeRange.week:
        return '週間';
      case TimeRange.month:
        return '月間';
      case TimeRange.quarter:
        return '四半期';
      case TimeRange.year:
        return '年間';
    }
  }

  Duration get duration {
    switch (this) {
      case TimeRange.week:
        return const Duration(days: 7);
      case TimeRange.month:
        return const Duration(days: 30);
      case TimeRange.quarter:
        return const Duration(days: 90);
      case TimeRange.year:
        return const Duration(days: 365);
    }
  }
}
