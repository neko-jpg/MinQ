import 'package:flutter_test/flutter_test.dart';
import 'package:minq/core/ai/dynamic_prompt_engine.dart';
import 'package:minq/core/ai/user_progress_service.dart';
import 'package:minq/domain/home/home_view_data.dart';
import 'package:minq/domain/quest/quest.dart';
import 'package:minq/domain/user/user.dart';

void main() {
  group('DynamicPromptEngine', () {
    late DynamicPromptEngine promptEngine;

    setUp(() {
      promptEngine = DynamicPromptEngine.instance;
    });

    test('システムプロンプトが正しく生成される', () {
      final user = User()
        ..uid = 'test-user'
        ..displayName = 'テストユーザー'
        ..currentLevel = 5
        ..totalPoints = 1000
        ..focusTags = ['健康', '学習'];

      final context = UserProgressContext(
        user: user,
        streak: 7,
        completionsToday: 2,
        activeQuests: [],
        recentLogs: [],
        timestamp: DateTime.now(),
      );

      final systemPrompt = promptEngine.generateSystemPrompt(context);

      expect(systemPrompt, contains('MinQアプリの専属AIコーチ'));
      expect(systemPrompt, contains('テストユーザー'));
      expect(systemPrompt, contains('現在のレベル: 5'));
      expect(systemPrompt, contains('現在のストリーク: 7日連続'));
      expect(systemPrompt, contains('今日の完了数: 2件'));
      expect(systemPrompt, contains('関心分野: 健康, 学習'));
    });

    test('クイックアクションが適切に生成される', () {
      final user = User()
        ..uid = 'test-user'
        ..displayName = 'テストユーザー';

      final quest = Quest()
        ..id = 1
        ..title = 'テストクエスト'
        ..category = 'health'
        ..status = QuestStatus.active;

      final context = UserProgressContext(
        user: user,
        streak: 0,
        completionsToday: 0,
        activeQuests: [quest],
        recentLogs: [],
        timestamp: DateTime.now(),
      );

      final quickActions = promptEngine.generateQuickActions(context);

      expect(quickActions, isNotEmpty);
      expect(quickActions.any((action) => action.id == 'create_quest'), isTrue);
      expect(quickActions.any((action) => action.id == 'start_timer'), isTrue);
    });

    test('文脈プロンプトが正しく生成される', () {
      final user = User()
        ..uid = 'test-user'
        ..displayName = 'テストユーザー';

      final context = UserProgressContext(
        user: user,
        streak: 3,
        completionsToday: 1,
        activeQuests: [],
        recentLogs: [],
        timestamp: DateTime.now(),
      );

      final contextualPrompt = promptEngine.generateContextualPrompt(
        'やる気が出ません',
        context,
        ['USER: こんにちは', 'AI: こんにちは！'],
      );

      expect(contextualPrompt, contains('現在の状況'));
      expect(contextualPrompt, contains('最近の会話'));
      expect(contextualPrompt, contains('ユーザー: やる気が出ません'));
    });
  });

  group('UserProgressContext', () {
    test('モチベーションレベルが正しく計算される', () {
      final user = User()..uid = 'test-user';

      // 高いモチベーション
      final highMotivationContext = UserProgressContext(
        user: user,
        streak: 30,
        completionsToday: 5,
        activeQuests: [],
        recentLogs: [],
        timestamp: DateTime.now(),
      );

      expect(highMotivationContext.motivationLevel, MotivationLevel.high);

      // 低いモチベーション
      final lowMotivationContext = UserProgressContext(
        user: user,
        streak: 0,
        completionsToday: 0,
        activeQuests: [],
        recentLogs: [],
        timestamp: DateTime.now(),
      );

      expect(lowMotivationContext.motivationLevel, MotivationLevel.starting);
    });

    test('習慣化段階が正しく判定される', () {
      final user = User()..uid = 'test-user';

      // 初期段階
      final initialContext = UserProgressContext(
        user: user,
        streak: 0,
        completionsToday: 0,
        activeQuests: [],
        recentLogs: [],
        timestamp: DateTime.now(),
      );

      expect(initialContext.habitStage, HabitStage.initial);

      // 形成期
      final formingContext = UserProgressContext(
        user: user,
        streak: 5,
        completionsToday: 1,
        activeQuests: [],
        recentLogs: [],
        timestamp: DateTime.now(),
      );

      expect(formingContext.habitStage, HabitStage.forming);

      // 習慣化完了
      final masteredContext = UserProgressContext(
        user: user,
        streak: 70,
        completionsToday: 3,
        activeQuests: [],
        recentLogs: [],
        timestamp: DateTime.now(),
      );

      expect(masteredContext.habitStage, HabitStage.mastered);
    });
  });

  group('QuickAction', () {
    test('JSONシリアライゼーションが正しく動作する', () {
      final action = QuickAction(
        id: 'test_action',
        title: 'テストアクション',
        description: 'テスト用のアクション',
        icon: 'test_icon',
        route: '/test',
        priority: 10,
        parameters: {'param1': 'value1'},
      );

      final json = action.toJson();

      expect(json['id'], 'test_action');
      expect(json['title'], 'テストアクション');
      expect(json['description'], 'テスト用のアクション');
      expect(json['icon'], 'test_icon');
      expect(json['route'], '/test');
      expect(json['priority'], 10);
      expect(json['parameters'], {'param1': 'value1'});
    });
  });

  group('HabitAnalysis', () {
    test('初心者向け分析が正しく生成される', () {
      final analysis = HabitAnalysis.beginner();

      expect(analysis.stage, HabitStage.initial);
      expect(analysis.motivationLevel, MotivationLevel.starting);
      expect(analysis.strengths, isNotEmpty);
      expect(analysis.challenges, isNotEmpty);
      expect(analysis.recommendations, isNotEmpty);
    });
  });

  group('DailyGoalStatus', () {
    test('目標達成状況が正しく計算される', () {
      final status = DailyGoalStatus(
        completed: 2,
        target: 3,
        percentage: 2.0 / 3.0,
        isAchieved: false,
      );

      expect(status.completed, 2);
      expect(status.target, 3);
      expect(status.percentage, closeTo(0.67, 0.01));
      expect(status.isAchieved, false);

      final achievedStatus = DailyGoalStatus(
        completed: 3,
        target: 3,
        percentage: 1.0,
        isAchieved: true,
      );

      expect(achievedStatus.isAchieved, true);
    });
  });

  group('WeeklyPattern', () {
    test('週間パターンが正しく分析される', () {
      final pattern = WeeklyPattern(
        weekdayActivity: [3, 2, 4, 1, 5, 2, 1], // 月-日
        mostActiveDay: 4, // 金曜日
        leastActiveDay: 3, // 木曜日
        totalActivity: 18,
      );

      expect(pattern.mostActiveDayName, '金');
      expect(pattern.leastActiveDayName, '木');
      expect(pattern.totalActivity, 18);
    });

    test('空のパターンが正しく作成される', () {
      final emptyPattern = WeeklyPattern.empty();

      expect(emptyPattern.weekdayActivity, [0, 0, 0, 0, 0, 0, 0]);
      expect(emptyPattern.totalActivity, 0);
    });
  });
}