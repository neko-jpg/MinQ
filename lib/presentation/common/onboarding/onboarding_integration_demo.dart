import 'package:flutter/material.dart';
import 'package:minq/presentation/common/onboarding/onboarding.dart';

/// Progressive Onboarding System の統合デモ画面
/// 要件6.1-6.6の実装を統合的にテストするためのデモ
class OnboardingIntegrationDemo extends StatefulWidget {
  const OnboardingIntegrationDemo({super.key});

  @override
  State<OnboardingIntegrationDemo> createState() =>
      _OnboardingIntegrationDemoState();
}

class _OnboardingIntegrationDemoState extends State<OnboardingIntegrationDemo> {
  bool _hasCompletedOnboarding = false;
  int _questCount = 0;
  int _completedQuests = 0;
  int _currentStreak = 0;

  @override
  void initState() {
    super.initState();
    _loadOnboardingState();
    _showInitialOnboarding();
  }

  Future<void> _loadOnboardingState() async {
    final completed = await OnboardingEngine.hasCompletedOnboarding();
    setState(() {
      _hasCompletedOnboarding = completed;
    });
  }

  Future<void> _showInitialOnboarding() async {
    // 初回ユーザー向けのステップバイステップガイド（要件6.4）
    if (!await OnboardingEngine.hasCompletedOnboarding()) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _startInteractiveTour();
      });
    }
  }

  void _startInteractiveTour() {
    final steps = TourStepBuilder.buildDefaultTour();
    OnboardingEngine.startInteractiveTour(context, steps);
  }

  void _simulateUserProgress() {
    setState(() {
      if (_questCount == 0) {
        _questCount = 1;
      } else if (_completedQuests < _questCount) {
        _completedQuests++;
        _currentStreak++;
      } else {
        _questCount++;
      }
    });

    // ユーザーの進捗に応じたヒント表示（要件6.2）
    final progress = UserProgress(
      totalQuests: _questCount,
      completedQuests: _completedQuests,
      currentStreak: _currentStreak,
      bestStreak: _currentStreak,
    );
    OnboardingEngine.showProgressiveHint(progress);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Progressive Onboarding Demo'),
        backgroundColor: theme.colorScheme.primaryContainer,
        actions: [
          IconButton(
            onPressed: _startInteractiveTour,
            icon: const Icon(Icons.tour),
            tooltip: 'ツアーを再開',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // オンボーディング状態表示
            _buildStatusCard(theme),

            const SizedBox(height: 24),

            // コンテキスト依存のガイド表示デモ（要件6.1）
            _buildContextualGuideDemo(theme),

            const SizedBox(height: 24),

            // スマートツールチップデモ（要件6.2）
            _buildSmartTooltipDemo(theme),

            const SizedBox(height: 24),

            // プログレッシブヒントデモ（要件6.2）
            _buildProgressiveHintDemo(theme),

            const SizedBox(height: 24),

            // インタラクティブツアーデモ（要件6.3）
            _buildInteractiveTourDemo(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'オンボーディング状態',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  _hasCompletedOnboarding
                      ? Icons.check_circle
                      : Icons.radio_button_unchecked,
                  color: _hasCompletedOnboarding ? Colors.green : Colors.grey,
                ),
                const SizedBox(width: 8),
                Text(
                  _hasCompletedOnboarding ? '完了済み' : '未完了',
                  style: theme.textTheme.bodyLarge,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'クエスト数: $_questCount, 完了数: $_completedQuests, 連続記録: $_currentStreak',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContextualGuideDemo(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'コンテキスト依存ガイド',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '画面に応じた適切なガイドを表示',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton(
                  onPressed:
                      () =>
                          OnboardingEngine.showContextualGuide('home', context),
                  child: const Text('ホーム画面へ移動する'),
                ),
                ElevatedButton(
                  onPressed:
                      () => OnboardingEngine.showContextualGuide(
                        'quest_creation',
                        context,
                      ),
                  child: const Text('クエストを作成する'),
                ),
                ElevatedButton(
                  onPressed:
                      () => OnboardingEngine.showContextualGuide(
                        'stats',
                        context,
                      ),
                  child: const Text('統計画面を見る'),
                ),
                ElevatedButton(
                  onPressed:
                      () =>
                          OnboardingEngine.showContextualGuide('pair', context),
                  child: const Text('ペア画面へ移動する'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSmartTooltipDemo(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'スマートツールチップ',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '一度だけ表示されるユーザー固有のツールチップ',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                SmartTooltip(
                  message: 'これは長押しで表示されるツールチップです。一度表示されると次回は表示されません。',
                  tooltipId: 'demo_longpress_tooltip',
                  child: ElevatedButton(
                    onPressed: () {},
                    child: const Text('長押しで表示する'),
                  ),
                ),
                const SizedBox(width: 16),
                SmartTooltip(
                  message: 'これはタップで表示されるツールチップです。',
                  tooltipId: 'demo_tap_tooltip',
                  trigger: TooltipTrigger.tap,
                  child: ElevatedButton(
                    onPressed: () {},
                    child: const Text('タップで表示する'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            AutoSmartTooltip(
              message: '自動表示されるツールチップ',
              tooltipId: 'demo_auto_tooltip',
              delay: const Duration(seconds: 2),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text('2秒後に自動でツールチップが表示されます'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressiveHintDemo(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'プログレッシブヒント',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'ユーザーの進捗に応じたヒント表示',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _simulateUserProgress,
              icon: const Icon(Icons.trending_up),
              label: const Text('進捗をシミュレート'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInteractiveTourDemo(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'インタラクティブツアー',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'ステップバイステップのガイドツアー',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: _startInteractiveTour,
                  icon: const Icon(Icons.tour),
                  label: const Text('デフォルトツアー'),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: () => _startCustomTour(),
                  icon: const Icon(Icons.assistant),
                  label: const Text('カスタムツアー'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _startCustomTour() {
    final customSteps = [
      const TourStep(
        title: 'カスタムツアーへようこそ',
        description:
            'これはカスタマイズされたツアーの例です。'
            'アプリの特定の機能に焦点を当てたガイドを作成できます。',
      ),
      const TourStep(
        title: 'Progressive Onboarding の特徴',
        description:
            'コンテキスト依存のガイド表示により、'
            'ユーザーが必要な時に必要な情報だけを提供します。',
      ),
      const TourStep(
        title: 'スマートツールチップ',
        description:
            '一度だけ表示される仕組みにより、'
            'ユーザーを煩わせることなく適切なタイミングでヒントを提供します。',
      ),
      const TourStep(
        title: 'ツアー完了',
        description:
            'Progressive Onboarding System により、'
            'ユーザーは段階的にアプリの使い方を学習できます。',
      ),
    ];

    OnboardingEngine.startInteractiveTour(context, customSteps);
  }
}
