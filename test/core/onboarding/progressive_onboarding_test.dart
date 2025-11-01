import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:minq/core/onboarding/progressive_hint_service.dart';
import 'package:minq/core/onboarding/progressive_onboarding.dart';

void main() {
  group('Progressive Onboarding System Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    group('ProgressiveHintService', () {
      testWidgets('shows first quest hint when not shown before', (
        tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) {
                return Scaffold(
                  body: ElevatedButton(
                    onPressed:
                        () =>
                            ProgressiveHintService.showFirstQuestHint(context),
                    child: const Text('Show Hint'),
                  ),
                );
              },
            ),
          ),
        );

        // タップしてヒントを表示
        await tester.tap(find.text('Show Hint'));
        await tester.pumpAndSettle();

        // ヒントダイアログが表示されることを確認
        expect(find.text('最初のクエストを作成しましょう！'), findsOneWidget);
        expect(find.text('了解'), findsOneWidget);
      });

      testWidgets('does not show hint when already shown', (tester) async {
        // ヒントを表示済みとしてマーク
        await ProgressiveHintService.markHintShown(
          ProgressiveHintService.hintFirstQuest,
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) {
                return Scaffold(
                  body: ElevatedButton(
                    onPressed:
                        () =>
                            ProgressiveHintService.showFirstQuestHint(context),
                    child: const Text('Show Hint'),
                  ),
                );
              },
            ),
          ),
        );

        // タップしてヒントを表示を試行
        await tester.tap(find.text('Show Hint'));
        await tester.pumpAndSettle();

        // ヒントダイアログが表示されないことを確認
        expect(find.text('最初のクエストを作成しましょう！'), findsNothing);
      });

      test('manages hint state correctly', () async {
        const hintId = ProgressiveHintService.hintFirstQuest;

        // 初期状態では表示されていない
        expect(await ProgressiveHintService.hasShownHint(hintId), false);

        // 表示済みとしてマーク
        await ProgressiveHintService.markHintShown(hintId);
        expect(await ProgressiveHintService.hasShownHint(hintId), true);

        // リセット
        await ProgressiveHintService.resetHint(hintId);
        expect(await ProgressiveHintService.hasShownHint(hintId), false);
      });

      test('resets all hints correctly', () async {
        // 複数のヒントを表示済みとしてマーク
        await ProgressiveHintService.markHintShown(
          ProgressiveHintService.hintFirstQuest,
        );
        await ProgressiveHintService.markHintShown(
          ProgressiveHintService.hintFirstCompletion,
        );
        await ProgressiveHintService.markHintShown(
          ProgressiveHintService.hintStreak,
        );

        // 全て表示済み状態を確認
        expect(
          await ProgressiveHintService.hasShownHint(
            ProgressiveHintService.hintFirstQuest,
          ),
          true,
        );
        expect(
          await ProgressiveHintService.hasShownHint(
            ProgressiveHintService.hintFirstCompletion,
          ),
          true,
        );
        expect(
          await ProgressiveHintService.hasShownHint(
            ProgressiveHintService.hintStreak,
          ),
          true,
        );

        // 全てリセット
        await ProgressiveHintService.resetAllHints();

        // 全て未表示状態を確認
        expect(
          await ProgressiveHintService.hasShownHint(
            ProgressiveHintService.hintFirstQuest,
          ),
          false,
        );
        expect(
          await ProgressiveHintService.hasShownHint(
            ProgressiveHintService.hintFirstCompletion,
          ),
          false,
        );
        expect(
          await ProgressiveHintService.hasShownHint(
            ProgressiveHintService.hintStreak,
          ),
          false,
        );
      });
    });

    group('ProgressiveOnboarding', () {
      test('initializes with correct levels', () {
        final onboarding = ProgressiveOnboarding();

        expect(onboarding.currentLevel, 1);
        expect(onboarding.getAllLevels().length, 4);

        final level1 = onboarding.getLevel(1);
        expect(level1?.title, 'ビギナー');
        expect(level1?.unlockedFeatures, contains('quest_create'));
      });

      test('checks level up requirements correctly', () {
        final onboarding = ProgressiveOnboarding();

        // レベル1からレベル2への要件チェック
        expect(
          onboarding.canLevelUp(
            questsCompleted: 3,
            daysUsed: 2,
            currentStreak: 0,
          ),
          false, // まだ要件を満たしていない
        );

        expect(
          onboarding.canLevelUp(
            questsCompleted: 5,
            daysUsed: 3,
            currentStreak: 0,
          ),
          true, // 要件を満たしている
        );
      });

      test('levels up correctly', () {
        final onboarding = ProgressiveOnboarding();

        expect(onboarding.currentLevel, 1);

        onboarding.levelUp();
        expect(onboarding.currentLevel, 2);

        onboarding.levelUp();
        expect(onboarding.currentLevel, 3);
      });

      test('checks feature unlock correctly', () {
        final onboarding = ProgressiveOnboarding();

        // レベル1の機能は解放されている
        expect(onboarding.isFeatureUnlocked('quest_create'), true);
        expect(onboarding.isFeatureUnlocked('quest_complete'), true);

        // レベル2の機能はまだ解放されていない
        expect(onboarding.isFeatureUnlocked('notifications'), false);
        expect(onboarding.isFeatureUnlocked('streak_tracking'), false);

        // レベルアップ
        onboarding.levelUp();

        // レベル2の機能が解放される
        expect(onboarding.isFeatureUnlocked('notifications'), true);
        expect(onboarding.isFeatureUnlocked('streak_tracking'), true);

        // レベル3の機能はまだ解放されていない
        expect(onboarding.isFeatureUnlocked('pair_feature'), false);
      });

      test('calculates progress correctly', () {
        final onboarding = ProgressiveOnboarding();

        // レベル2への進捗を計算
        final progress = onboarding.getProgress(
          questsCompleted: 3, // 5必要
          daysUsed: 2, // 3必要
          currentStreak: 0,
        );

        expect(progress.currentLevel, 1);
        expect(progress.nextLevel, 2);
        expect(progress.isMaxLevel, false);
        expect(progress.progress, lessThan(1.0));

        // 最大レベルでの進捗
        onboarding.levelUp();
        onboarding.levelUp();
        onboarding.levelUp(); // レベル4（最大）

        final maxProgress = onboarding.getProgress(
          questsCompleted: 100,
          daysUsed: 100,
          currentStreak: 100,
        );

        expect(maxProgress.currentLevel, 4);
        expect(maxProgress.nextLevel, null);
        expect(maxProgress.isMaxLevel, true);
        expect(maxProgress.progress, 1.0);
      });
    });

    group('Feature Lock Messages', () {
      test('returns correct messages for features', () {
        expect(
          FeatureLockMessages.getMessage('pair_feature', 3),
          'この機能はレベル3で解放されます',
        );

        expect(
          FeatureLockMessages.getUnlockHint('pair_feature'),
          'クエストを15個完了して7日間使用すると解放されます',
        );

        expect(
          FeatureLockMessages.getUnlockHint('achievements'),
          'クエストを30個完了して14日間使用すると解放されます',
        );
      });
    });
  });
}
