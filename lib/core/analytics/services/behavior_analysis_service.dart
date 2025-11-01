import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:minq/core/database/database_service.dart';
import 'package:minq/data/local/models/local_quest.dart';
import 'package:minq/domain/analytics/analytics_insight.dart';
import 'package:minq/domain/analytics/behavior_pattern.dart';

/// Derives behavioural insights from quest activity stored in the local cache.
class BehaviorAnalysisService {
  BehaviorAnalysisService(this._databaseService);

  final DatabaseService _databaseService;

  /// Calculates the ratio of active days within a given date range.
  Future<double> analyzeHabitContinuityRate({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final quests = await _databaseService.getQuestsInDateRange(
      startDate,
      endDate,
    );
    if (quests.isEmpty) {
      return 0.0;
    }

    final activeDays =
        quests
            .map(
              (quest) => DateTime(
                quest.createdAt.year,
                quest.createdAt.month,
                quest.createdAt.day,
              ),
            )
            .toSet()
            .length;
    final totalDays = math.max(1, endDate.difference(startDate).inDays + 1);

    final continuity = activeDays / totalDays;
    return math.max(0.0, math.min(1.0, continuity));
  }

  /// Returns high-level failure patterns grouped by time, weekday and category.
  Future<List<BehaviorPattern>> analyzeFailurePatterns() async {
    final failedQuests = await _databaseService.getFailedQuests();
    if (failedQuests.isEmpty) {
      return const [];
    }

    return <BehaviorPattern>[
      ..._buildTimeFailurePatterns(failedQuests),
      ..._buildDayOfWeekFailurePatterns(failedQuests),
      ..._buildCategoryFailurePatterns(failedQuests),
    ];
  }

  /// Produces hourly completion statistics for finished quests.
  Future<List<TimePattern>> analyzeTimePatterns() async {
    final quests = await _databaseService.getAllCompletedQuests();
    if (quests.isEmpty) {
      return const [];
    }

    final hourlyBuckets = <int, List<LocalQuest>>{};
    for (final quest in quests) {
      final hour = quest.createdAt.hour;
      hourlyBuckets.putIfAbsent(hour, () => <LocalQuest>[]).add(quest);
    }

    final patterns = <TimePattern>[];
    for (final entry in hourlyBuckets.entries) {
      final questsInHour = entry.value;
      patterns.add(
        TimePattern(
          hour: entry.key,
          successRate: _calculateSuccessRate(questsInHour),
          completionCount: questsInHour.length,
          averageDuration: _calculateAverageDuration(questsInHour),
        ),
      );
    }
    patterns.sort((a, b) => a.hour.compareTo(b.hour));
    return patterns;
  }

  /// Produces weekday completion statistics for finished quests.
  Future<List<DayOfWeekPattern>> analyzeDayOfWeekPatterns() async {
    final quests = await _databaseService.getAllCompletedQuests();
    if (quests.isEmpty) {
      return const [];
    }

    final weekdayBuckets = <int, List<LocalQuest>>{};
    for (final quest in quests) {
      final weekday = quest.createdAt.weekday;
      weekdayBuckets.putIfAbsent(weekday, () => <LocalQuest>[]).add(quest);
    }

    final patterns = <DayOfWeekPattern>[];
    for (final entry in weekdayBuckets.entries) {
      final questsInDay = entry.value;
      patterns.add(
        DayOfWeekPattern(
          dayOfWeek: entry.key,
          successRate: _calculateSuccessRate(questsInDay),
          completionCount: questsInDay.length,
          averageQuestsPerDay: _calculateAverageQuestsPerDay(questsInDay),
        ),
      );
    }
    patterns.sort((a, b) => a.dayOfWeek.compareTo(b.dayOfWeek));
    return patterns;
  }

  /// Produces seasonal completion statistics for finished quests.
  Future<List<SeasonalPattern>> analyzeSeasonalPatterns() async {
    final quests = await _databaseService.getAllCompletedQuests();
    if (quests.isEmpty) {
      return const [];
    }

    final seasonalBuckets = <Season, List<LocalQuest>>{};
    for (final quest in quests) {
      final season = SeasonFromMonth.fromMonth(quest.createdAt.month);
      seasonalBuckets.putIfAbsent(season, () => <LocalQuest>[]).add(quest);
    }

    final patterns = <SeasonalPattern>[];
    for (final entry in seasonalBuckets.entries) {
      final questsInSeason = entry.value;
      patterns.add(
        SeasonalPattern(
          season: entry.key,
          successRate: _calculateSuccessRate(questsInSeason),
          completionCount: questsInSeason.length,
          popularCategories: _popularCategories(questsInSeason),
        ),
      );
    }
    patterns.sort((a, b) => a.season.index.compareTo(b.season.index));
    return patterns;
  }

  /// Estimates near-term goal completion using simple trend analysis.
  Future<List<GoalPrediction>> generateGoalPredictions() async {
    final quests = await _databaseService.getAllCompletedQuests();
    if (quests.isEmpty) {
      return [
        GoalPrediction(
          goalType: 'weekly_completion',
          targetValue: 7,
          currentValue: 0,
          predictedCompletionDate: DateTime.now().add(const Duration(days: 7)),
          confidence: 0.2,
          requiredDailyProgress: 1,
          riskFactors: const [],
          recommendations: const [
            'Complete at least one quest per day to build momentum.',
          ],
        ),
      ];
    }

    final sorted = quests.toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

    final firstDate = sorted.first.createdAt;
    final daysActive = math.max(
      1,
      DateTime.now().difference(firstDate).inDays,
    );
    final dailyAverage = quests.length / daysActive;
    final targetValue = 30.0;
    final remaining = math.max(0.0, targetValue - quests.length.toDouble());
    final requiredDaily = remaining == 0
        ? 0.0
        : math.max(0.5, remaining / math.max(1.0, dailyAverage * daysActive));
    final projectedDays =
        dailyAverage == 0 ? 30 : (remaining / dailyAverage).ceil();

    return [
      GoalPrediction(
        goalType: 'monthly_completion',
        targetValue: targetValue,
        currentValue: quests.length.toDouble(),
        predictedCompletionDate: DateTime.now().add(
          Duration(days: math.max(1, projectedDays)),
        ),
        confidence: math.max(0.2, math.min(0.9, dailyAverage / 4)),
        requiredDailyProgress: requiredDaily,
        riskFactors: [
          RiskFactor(
            name: 'Momentum dip',
            description:
                'Recent activity is inconsistent, which can delay the goal.',
            severity: RiskSeverity.medium,
            probability: dailyAverage < 1 ? 0.6 : 0.3,
            mitigationStrategies: const [
              'Schedule a repeating reminder for your preferred focus slot.',
              'Line up quick wins the night before to reduce friction.',
            ],
          ),
        ],
        recommendations: const [
          'Plan a deep-focus block at least twice a week.',
          'Tag your top three quests to revisit them sooner.',
        ],
      ),
    ];
  }

  /// Highlights significant risks detected from momentum trends.
  Future<List<AnalyticsInsight>> generateRiskWarnings() async {
    final now = DateTime.now();
    final lastWeek = now.subtract(const Duration(days: 6));

    final weeklyContinuity = await analyzeHabitContinuityRate(
      startDate: lastWeek,
      endDate: now,
    );

    final failedQuests = await _databaseService.getFailedQuests();
    final failurePatterns = failedQuests.isEmpty
        ? const <BehaviorPattern>[]
        : [
            ..._buildTimeFailurePatterns(failedQuests),
            ..._buildDayOfWeekFailurePatterns(failedQuests),
            ..._buildCategoryFailurePatterns(failedQuests),
          ];
    final warnings = <AnalyticsInsight>[];

    if (weeklyContinuity < 0.4) {
      warnings.add(
        AnalyticsInsight(
          id: 'risk_weekly_continuity_${now.millisecondsSinceEpoch}',
          type: InsightType.riskWarning,
          priority: InsightPriority.high,
          title: 'Weekly momentum is slipping',
          description:
              'Your activity rate dropped below 40% this week. A lighter'
              ' starter quest could help rebuild the streak.',
          actionItems: const [
            ActionItem(
              title: 'Schedule a quick quest',
              description: 'Pick a 5 minute quest for tomorrow morning.',
              actionType: ActionType.adjustSchedule,
            ),
            ActionItem(
              title: 'Enable reminders',
              description: 'Turn on evening check-ins to lock the habit.',
              actionType: ActionType.setReminder,
            ),
          ],
          confidence: 0.7,
          relatedPatterns: failurePatterns,
          metadata: {
            'weeklyContinuity': weeklyContinuity,
            'periodStart': lastWeek.toIso8601String(),
            'periodEnd': now.toIso8601String(),
          },
          generatedAt: now,
          expiresAt: now.add(const Duration(days: 3)),
        ),
      );
    }

    if (failedQuests.length >= 5) {
      warnings.add(
        AnalyticsInsight(
          id: 'risk_failure_volume_${now.millisecondsSinceEpoch}',
          type: InsightType.riskWarning,
          priority: InsightPriority.medium,
          title: 'Multiple quests were paused recently',
          description:
              'Five or more quests were paused in the last sync window. Review'
              ' them to keep your plan realistic.',
          actionItems: const [
            ActionItem(
              title: 'Review paused quests',
              description: 'Adjust scope or deadlines for paused items.',
              actionType: ActionType.adjustGoals,
            ),
          ],
          confidence: 0.6,
          relatedPatterns: failurePatterns,
          metadata: {
            'pausedCount': failedQuests.length,
          },
          generatedAt: now,
          expiresAt: now.add(const Duration(days: 2)),
        ),
      );
    }

    return warnings;
  }

  List<BehaviorPattern> _buildTimeFailurePatterns(
    List<LocalQuest> failedQuests,
  ) {
    final hourlyCounts = List<int>.filled(24, 0);
    for (final quest in failedQuests) {
      hourlyCounts[quest.createdAt.hour]++;
    }

    final total = failedQuests.length;
    final patterns = <BehaviorPattern>[];
    for (var hour = 0; hour < hourlyCounts.length; hour++) {
      final count = hourlyCounts[hour];
      if (count == 0) continue;
      final failureRate = count / total;
      if (failureRate < 0.15) continue;

      patterns.add(
        BehaviorPattern(
          type: PatternType.timeOfDay,
          name: 'Failures around ${hour.toString().padLeft(2, '0')}:00',
          description:
              'Quests scheduled around ${hour.toString().padLeft(2, '0')}:00 '
              'often fail. Consider moving them earlier in the day.',
          confidence: math.min(1.0, failureRate + 0.2),
          frequency: count,
          impact: -failureRate,
          suggestions: [
            'Experiment with a different time slot for demanding quests.',
            'Add a reminder 15 minutes before this window starts.',
          ],
          metadata: {
            'hour': hour,
            'failureRate': failureRate,
            'sampleSize': count,
          },
          detectedAt: DateTime.now(),
        ),
      );
    }
    return patterns;
  }

  List<BehaviorPattern> _buildDayOfWeekFailurePatterns(
    List<LocalQuest> failedQuests,
  ) {
    final dailyCounts = List<int>.filled(7, 0);
    for (final quest in failedQuests) {
      dailyCounts[quest.createdAt.weekday - 1]++;
    }

    final total = failedQuests.length;
    final patterns = <BehaviorPattern>[];
    for (var dayIndex = 0; dayIndex < dailyCounts.length; dayIndex++) {
      final count = dailyCounts[dayIndex];
      if (count == 0) continue;
      final failureRate = count / total;
      if (failureRate < 0.2) continue;

      final weekday = dayIndex + 1;
      patterns.add(
        BehaviorPattern(
          type: PatternType.dayOfWeek,
          name: 'Frequent failures on day $weekday',
          description:
              'Tasks scheduled on weekday $weekday show a high failure ratio.'
              ' Try batching easier quests or taking a recovery day.',
          confidence: math.min(1.0, failureRate + 0.1),
          frequency: count,
          impact: -failureRate,
          suggestions: [
            'Move complex quests away from this weekday.',
            'Plan a lighter workload or additional breaks.',
          ],
          metadata: {
            'weekday': weekday,
            'failureRate': failureRate,
            'sampleSize': count,
          },
          detectedAt: DateTime.now(),
        ),
      );
    }
    return patterns;
  }

  List<BehaviorPattern> _buildCategoryFailurePatterns(
    List<LocalQuest> failedQuests,
  ) {
    final categoryCounts = <String, int>{};
    for (final quest in failedQuests) {
      final key = quest.category;
      if (key.isEmpty) continue;
      categoryCounts[key] = (categoryCounts[key] ?? 0) + 1;
    }

    final total = failedQuests.length;
    final patterns = <BehaviorPattern>[];
    categoryCounts.forEach((category, count) {
      final failureRate = count / total;
      if (failureRate < 0.25) return;

      patterns.add(
        BehaviorPattern(
          type: PatternType.category,
          name: 'Difficulty with $category quests',
          description:
              'Quests labelled "$category" tend to stall. Break them into '
              'smaller milestones or adjust the estimated effort.',
          confidence: math.min(1.0, failureRate + 0.1),
          frequency: count,
          impact: -failureRate,
          suggestions: [
            'Split large tasks into smaller, timed checkpoints.',
            'Pair these quests with a motivating reward.',
            'Ask a teammate or coach for a quick review.',
          ],
          metadata: {
            'category': category,
            'failureRate': failureRate,
            'sampleSize': count,
          },
          detectedAt: DateTime.now(),
        ),
      );
    });
    return patterns;
  }

  double _calculateSuccessRate(List<LocalQuest> quests) {
    if (quests.isEmpty) {
      return 0.0;
    }
    final successful =
        quests.where((quest) => quest.status != QuestStatus.paused).length;
    return successful / quests.length;
  }

  Duration _calculateAverageDuration(List<LocalQuest> quests) {
    if (quests.isEmpty) {
      return Duration.zero;
    }
    final totalMinutes = quests.fold<int>(
      0,
      (sum, quest) => sum + quest.estimatedMinutes,
    );
    final average = totalMinutes ~/ quests.length;
    return Duration(minutes: math.max(1, average));
  }

  double _calculateAverageQuestsPerDay(List<LocalQuest> quests) {
    if (quests.isEmpty) {
      return 0.0;
    }
    final activeDays =
        quests
            .map(
              (quest) => DateTime(
                quest.createdAt.year,
                quest.createdAt.month,
                quest.createdAt.day,
              ),
            )
            .toSet()
            .length;
    if (activeDays == 0) {
      return quests.length.toDouble();
    }
    return quests.length / activeDays;
  }

  List<String> _popularCategories(List<LocalQuest> quests) {
    final counts = <String, int>{};
    for (final quest in quests) {
      if (quest.category.isEmpty) continue;
      counts[quest.category] = (counts[quest.category] ?? 0) + 1;
    }
    final sorted =
        counts.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));
    return sorted.take(3).map((entry) => entry.key).toList();
  }
}

final behaviorAnalysisServiceProvider = Provider<BehaviorAnalysisService>((ref) {
  final databaseService = ref.watch(databaseServiceProvider);
  return BehaviorAnalysisService(databaseService);
});
