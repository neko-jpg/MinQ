import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:minq/core/onboarding/progressive_onboarding_integration.dart';
import 'package:minq/presentation/widgets/progressive_onboarding_widget.dart';

/// プログレッシブオンボーディング統合の使用例
/// 既存の画面にプログレッシブオンボーディングを統合する方法を示す
class ExampleProgressiveOnboardingScreen extends ConsumerStatefulWidget {
  const ExampleProgressiveOnboardingScreen({super.key});

  @override
  ConsumerState<ExampleProgressiveOnboardingScreen> createState() =>
      _ExampleProgressiveOnboardingScreenState();
}

class _ExampleProgressiveOnboardingScreenState
    extends ConsumerState<ExampleProgressiveOnboardingScreen> {
  int _questCount = 0;
  int _completedCount = 0;
  int _currentStreak = 0;

  @override
  void initState() {
    super.initState();
    
    // 画面表示時にヒントをチェック
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ProgressiveOnboardingIntegration.onScreenDisplayed(
        context,
        ref,
        'home',
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return ProgressiveOnboardingWidget(
      screenId: 'home',
      child: Scaffold(
        appBar: AppBar(
          title: const Text('プログレッシブオンボーディング例'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 統計表示
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '現在の統計',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text('作成したクエスト: $_questCount'),
                      Text('完了したクエスト: $_completedCount'),
                      Text('現在のストリーク: $_currentStreak日'),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // アクションボタン
              ElevatedButton(
                onPressed: _createQuest,
                child: const Text('クエストを作成'),
              ),
              
              const SizedBox(height: 8),
              
              ElevatedButton(
                onPressed: _questCount > 0 ? _completeQuest : null,
                child: const Text('クエストを完了'),
              ),
              
              const SizedBox(height: 16),
              
              // 機能ロック例
              _buildFeatureLockExample(),
              
              const SizedBox(height: 16),
              
              // デバッグボタン
              if (kDebugMode) ...[
                const Divider(),
                const Text('デバッグ機能'),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: _resetHints,
                  child: const Text('ヒントをリセット'),
                ),
                ElevatedButton(
                  onPressed: _showQuickHint,
                  child: const Text('クイックヒントを表示'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureLockExample() {
    final isPairLocked = ref.watch(featureLockStateProvider('pair_feature'));
    final lockMessage = ref.watch(featureLockMessageProvider('pair_feature'));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ペア機能',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            if (isPairLocked) ...[
              Icon(
                Icons.lock,
                color: Theme.of(context).colorScheme.outline,
              ),
              const SizedBox(height: 4),
              Text(
                lockMessage,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
              ),
            ] else ...[
              Icon(
                Icons.people,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 4),
              const Text('ペア機能が利用できます！'),
              ElevatedButton(
                onPressed: () {
                  // ペア機能を開く
                },
                child: const Text('ペアを探す'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _createQuest() {
    setState(() {
      _questCount++;
    });

    // 初回クエスト作成時のヒント表示
    ProgressiveOnboardingIntegration.onQuestCreated(
      context,
      ref,
      isFirstQuest: _questCount == 1,
    );
  }

  void _completeQuest() {
    setState(() {
      _completedCount++;
      _currentStreak++;
    });

    // クエスト完了時のヒント表示
    ProgressiveOnboardingIntegration.onQuestCompleted(
      context,
      ref,
      totalCompleted: _completedCount,
      currentStreak: _currentStreak,
    );

    // 週次目標達成チェック（例：7個完了で週次目標達成）
    if (_completedCount == 7) {
      ProgressiveOnboardingIntegration.onWeeklyGoalAchieved(context, ref);
    }
  }

  void _resetHints() async {
    await ProgressiveOnboardingIntegration.resetAllHints();
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('全てのヒントをリセットしました'),
        ),
      );
    }
  }

  void _showQuickHint() {
    ProgressiveOnboardingIntegration.showQuickHint(
      context,
      'これはクイックヒントの例です',
      icon: Icons.info,
    );
  }
}

