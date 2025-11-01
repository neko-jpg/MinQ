import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:minq/core/ai/dynamic_prompt_engine.dart';
import 'package:minq/data/providers.dart';
import 'package:minq/domain/home/home_view_data.dart';
import 'package:minq/domain/quest/quest.dart';
import 'package:minq/domain/user/user.dart';
import 'package:minq/presentation/controllers/home_data_controller.dart';

/// ユーザー進捗サービス
/// AIコーチが使用するユーザーの現在の状況を収集・分析
class UserProgressService {
  final Ref _ref;

  UserProgressService(this._ref);

  /// 現在のユーザー進捗コンテキストを取得
  Future<UserProgressContext?> getCurrentProgress() async {
    try {
      // ユーザー情報を取得
      final user = await _ref.read(localUserProvider.future);
      if (user == null) {
        log('UserProgressService: ユーザー情報が見つかりません');
        return null;
      }

      // ホームデータを取得
      final homeDataAsync = _ref.read(homeDataProvider);
      final homeData = homeDataAsync.valueOrNull;
      if (homeData == null) {
        log('UserProgressService: ホームデータが見つかりません');
        return _createEmptyContext(user);
      }

      // アクティブなクエストを取得
      final questRepo = _ref.read(questRepositoryProvider);
      final activeQuests = await questRepo.getQuestsForOwner(user.uid);
      final activeQuestList =
          activeQuests
              .where((quest) => quest.status == QuestStatus.active)
              .toList();

      // フォーカスクエストの変換
      HomeQuestItem? focusQuest;
      if (homeData.focus != null) {
        focusQuest = HomeQuestItem(
          id: homeData.focus!.questId,
          title: homeData.focus!.questTitle,
          category: 'focus',
          estimatedMinutes: 15,
        );
      }

      return UserProgressContext(
        user: user,
        streak: homeData.streak,
        completionsToday: homeData.completionsToday,
        activeQuests: activeQuestList,
        recentLogs: homeData.recentLogs,
        focusQuest: focusQuest,
        timestamp: DateTime.now(),
      );
    } catch (e, stackTrace) {
      log('UserProgressService: 進捗取得エラー', error: e, stackTrace: stackTrace);
      return null;
    }
  }

  /// 空のコンテキストを作成（フォールバック用）
  UserProgressContext _createEmptyContext(User user) {
    return UserProgressContext(
      user: user,
      streak: 0,
      completionsToday: 0,
      activeQuests: [],
      recentLogs: [],
      focusQuest: null,
      timestamp: DateTime.now(),
    );
  }

  /// ユーザーの習慣化レベルを分析
  Future<HabitAnalysis> analyzeHabitLevel() async {
    final context = await getCurrentProgress();
    if (context == null) {
      return HabitAnalysis.beginner();
    }

    return HabitAnalysis(
      stage: context.habitStage,
      motivationLevel: context.motivationLevel,
      strengths: _identifyStrengths(context),
      challenges: _identifyChallenges(context),
      recommendations: _generateRecommendations(context),
    );
  }

  /// ユーザーの強みを特定
  List<String> _identifyStrengths(UserProgressContext context) {
    final strengths = <String>[];

    if (context.streak >= 7) {
      strengths.add('継続力が身についています');
    }

    if (context.completionsToday >= 3) {
      strengths.add('今日は積極的に活動しています');
    }

    if (context.activeQuests.length >= 3) {
      strengths.add('複数の習慣に取り組む意欲があります');
    }

    if (context.user.focusTags.isNotEmpty) {
      strengths.add('明確な関心分野を持っています');
    }

    if (context.user.pairId != null) {
      strengths.add('仲間と一緒に取り組んでいます');
    }

    if (strengths.isEmpty) {
      strengths.add('新しいことに挑戦する勇気があります');
    }

    return strengths;
  }

  /// 課題を特定
  List<String> _identifyChallenges(UserProgressContext context) {
    final challenges = <String>[];

    if (context.streak == 0 && context.recentLogs.isNotEmpty) {
      challenges.add('継続が途切れがちです');
    }

    if (context.completionsToday == 0 && DateTime.now().hour > 18) {
      challenges.add('今日はまだ活動していません');
    }

    if (context.activeQuests.isEmpty) {
      challenges.add('取り組むクエストが設定されていません');
    }

    final recentActivity =
        context.recentLogs
            .where(
              (log) => DateTime.now().difference(log.timestamp).inDays <= 7,
            )
            .length;

    if (recentActivity < 3) {
      challenges.add('最近の活動頻度が低下しています');
    }

    return challenges;
  }

  /// 推奨事項を生成
  List<String> _generateRecommendations(UserProgressContext context) {
    final recommendations = <String>[];

    // ストリーク状況に応じた推奨
    if (context.streak == 0) {
      recommendations.add('小さなクエストから始めて継続の習慣を作りましょう');
    } else if (context.streak < 7) {
      recommendations.add('素晴らしいスタートです。この調子で1週間を目指しましょう');
    } else if (context.streak < 21) {
      recommendations.add('継続力が身についています。質の向上を意識してみましょう');
    } else {
      recommendations.add('習慣化のマスターです。新しいチャレンジを検討してみましょう');
    }

    // 今日の活動状況に応じた推奨
    if (context.completionsToday == 0) {
      recommendations.add('今日の最初の一歩を踏み出しましょう');
    } else if (context.completionsToday < 3) {
      recommendations.add('良いスタートです。もう1つクエストに挑戦してみませんか');
    }

    // クエスト数に応じた推奨
    if (context.activeQuests.isEmpty) {
      recommendations.add('新しいクエストを作成して目標を設定しましょう');
    } else if (context.activeQuests.length == 1) {
      recommendations.add('もう1つ別のカテゴリのクエストを追加してみましょう');
    }

    // ペア機能の推奨
    if (context.user.pairId == null && context.streak >= 3) {
      recommendations.add('ペア機能で仲間と一緒に取り組むとより継続しやすくなります');
    }

    return recommendations;
  }

  /// 最近の完了したクエスト名を取得
  Future<List<String>> getRecentCompletedQuests({int limit = 5}) async {
    final context = await getCurrentProgress();
    if (context == null) return [];

    final questTitles = <String>[];
    final questRepo = _ref.read(questRepositoryProvider);

    for (final progressLog in context.recentLogs.take(limit)) {
      try {
        final quest = await questRepo.getQuestById(progressLog.questId);
        if (quest != null) {
          questTitles.add(quest.title);
        }
      } catch (e) {
        log('UserProgressService: クエスト取得エラー - ${progressLog.questId}');
      }
    }

    return questTitles.toSet().toList(); // 重複を除去
  }

  /// 今日の目標達成状況を取得
  Future<DailyGoalStatus> getDailyGoalStatus() async {
    final context = await getCurrentProgress();
    if (context == null) {
      return const DailyGoalStatus(
        completed: 0,
        target: 3,
        percentage: 0.0,
        isAchieved: false,
      );
    }

    const target = 3; // デフォルトの1日目標
    final percentage = (context.completionsToday / target).clamp(0.0, 1.0);

    return DailyGoalStatus(
      completed: context.completionsToday,
      target: target,
      percentage: percentage,
      isAchieved: context.completionsToday >= target,
    );
  }

  /// 週間の活動パターンを分析
  Future<WeeklyPattern> analyzeWeeklyPattern() async {
    final context = await getCurrentProgress();
    if (context == null || context.recentLogs.isEmpty) {
      return WeeklyPattern.empty();
    }

    final weekdayActivity = List.filled(7, 0);
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));

    for (final progressLog in context.recentLogs) {
      final daysSinceWeekStart =
          progressLog.timestamp.difference(weekStart).inDays;
      if (daysSinceWeekStart >= 0 && daysSinceWeekStart < 7) {
        weekdayActivity[daysSinceWeekStart]++;
      }
    }

    final mostActiveDay = weekdayActivity.indexOf(
      weekdayActivity.reduce((a, b) => a > b ? a : b),
    );
    final leastActiveDay = weekdayActivity.indexOf(
      weekdayActivity.reduce((a, b) => a < b ? a : b),
    );

    return WeeklyPattern(
      weekdayActivity: weekdayActivity,
      mostActiveDay: mostActiveDay,
      leastActiveDay: leastActiveDay,
      totalActivity: weekdayActivity.reduce((a, b) => a + b),
    );
  }
}

/// 習慣分析結果
class HabitAnalysis {
  final HabitStage stage;
  final MotivationLevel motivationLevel;
  final List<String> strengths;
  final List<String> challenges;
  final List<String> recommendations;

  const HabitAnalysis({
    required this.stage,
    required this.motivationLevel,
    required this.strengths,
    required this.challenges,
    required this.recommendations,
  });

  factory HabitAnalysis.beginner() {
    return const HabitAnalysis(
      stage: HabitStage.initial,
      motivationLevel: MotivationLevel.starting,
      strengths: ['新しいことに挑戦する意欲があります'],
      challenges: ['まだ習慣が形成されていません'],
      recommendations: ['小さなクエストから始めて継続の基盤を作りましょう'],
    );
  }
}

/// 1日の目標達成状況
class DailyGoalStatus {
  final int completed;
  final int target;
  final double percentage;
  final bool isAchieved;

  const DailyGoalStatus({
    required this.completed,
    required this.target,
    required this.percentage,
    required this.isAchieved,
  });
}

/// 週間活動パターン
class WeeklyPattern {
  final List<int> weekdayActivity;
  final int mostActiveDay;
  final int leastActiveDay;
  final int totalActivity;

  const WeeklyPattern({
    required this.weekdayActivity,
    required this.mostActiveDay,
    required this.leastActiveDay,
    required this.totalActivity,
  });

  factory WeeklyPattern.empty() {
    return const WeeklyPattern(
      weekdayActivity: [0, 0, 0, 0, 0, 0, 0],
      mostActiveDay: 0,
      leastActiveDay: 0,
      totalActivity: 0,
    );
  }

  String get mostActiveDayName => _getDayName(mostActiveDay);
  String get leastActiveDayName => _getDayName(leastActiveDay);

  String _getDayName(int dayIndex) {
    const dayNames = ['月', '火', '水', '木', '金', '土', '日'];
    return dayNames[dayIndex % 7];
  }
}

/// プロバイダー定義
final userProgressServiceProvider = Provider<UserProgressService>((ref) {
  return UserProgressService(ref);
});

/// 課題を特定（実装）
List<String> _identifyChallenges(UserProgressContext context) {
  final challenges = <String>[];

  if (context.streak == 0 && context.recentLogs.isNotEmpty) {
    challenges.add('継続が途切れがちです');
  }

  if (context.completionsToday == 0 && DateTime.now().hour > 18) {
    challenges.add('今日はまだ活動していません');
  }

  if (context.activeQuests.isEmpty) {
    challenges.add('取り組むクエストが設定されていません');
  }

  final recentActivity =
      context.recentLogs
          .where((log) => DateTime.now().difference(log.timestamp).inDays <= 7)
          .length;

  if (recentActivity < 3) {
    challenges.add('最近の活動頻度が低下しています');
  }

  return challenges;
}
