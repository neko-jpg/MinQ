import 'package:flutter/material.dart';
import 'package:minq/presentation/common/onboarding/onboarding.dart';

/// Progressive Onboarding System の統合デモ画面
/// 要件6.1-6.6の実裁E��統合的にチE��トするため�EチE��
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
    // 初回ユーザー向けのスチE��プバイスチE��プガイド（要件6.4�E�E
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

    // ユーザーの進捗に応じたヒント表示�E�要件6.2�E�E
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
            tooltip: 'チE��ーを�E閁E,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // オンボ�EチE��ング状態表示
            _buildStatusCard(theme),

            const SizedBox(height: 24),

            // コンチE��スト依存�Eガイド表示チE���E�要件6.1�E�E
            _buildContextualGuideDemo(theme),

            const SizedBox(height: 24),

            // スマ�Eトツールチップデモ�E�要件6.2�E�E
            _buildSmartTooltipDemo(theme),

            const SizedBox(height: 24),

            // プログレチE��ブヒントデモ�E�要件6.2�E�E
            _buildProgressiveHintDemo(theme),

            const SizedBox(height: 24),

            // インタラクチE��ブツアーチE���E�要件6.3�E�E
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
              'オンボ�EチE��ング状慁E,
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
                  _hasCompletedOnboarding ? '完亁E��み' : '未完亁E,
                  style: theme.textTheme.bodyLarge,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'クエスト数: $_questCount, 完亁E��: $_completedQuests, 連続記録: $_currentStreak',
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
              'コンチE��スト依存ガイチE,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '画面に応じた適刁E��ガイドを表示',
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
                  child: const Text('ホ�Eム画面へ移動すめE),
                ),
                ElevatedButton(
                  onPressed:
                      () => OnboardingEngine.showContextualGuide(
                        'quest_creation',
                        context,
                      ),
                  child: const Text('クエストを作�Eする'),
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
                  child: const Text('ペア画面へ移動すめE),
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
              'スマ�EトツールチッチE,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '一度だけ表示されるユーザー固有�EチE�EルチッチE,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                SmartTooltip(
                  message: 'これは長押しで表示されるツールチップです。一度表示されると次回�E表示されません、E,
                  tooltipId: 'demo_longpress_tooltip',
                  child: ElevatedButton(
                    onPressed: () {},
                    child: const Text('長押しで表示する'),
                  ),
                ),
                const SizedBox(width: 16),
                SmartTooltip(
                  message: 'これはタチE�Eで表示されるツールチップです、E,
                  tooltipId: 'demo_tap_tooltip',
                  trigger: TooltipTrigger.tap,
                  child: ElevatedButton(
                    onPressed: () {},
                    child: const Text('タチE�Eで表示する'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            AutoSmartTooltip(
              message: '自動表示されるツールチッチE,
              tooltipId: 'demo_auto_tooltip',
              delay: const Duration(seconds: 2),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text('2秒後に自動でチE�Eルチップが表示されまぁE),
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
              'プログレチE��ブヒンチE,
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
              label: const Text('進捗をシミュレーチE),
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
              'インタラクチE��ブツアー',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'スチE��プバイスチE��プ�Eガイドツアー',
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
                  label: const Text('チE��ォルトツアー'),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: () => _startCustomTour(),
                  icon: const Icon(Icons.assistant),
                  label: const Text('カスタムチE��ー'),
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
        title: 'カスタムチE��ーへようこそ',
        description:
            'これはカスタマイズされたツアーの例です、E
            'アプリの特定�E機�Eに焦点を当てたガイドを作�Eできます、E,
      ),
      const TourStep(
        title: 'Progressive Onboarding の特徴',
        description:
            'コンチE��スト依存�Eガイド表示により、E
            'ユーザーが忁E��な時に忁E��な惁E��だけを提供します、E,
      ),
      const TourStep(
        title: 'スマ�EトツールチッチE,
        description:
            '一度だけ表示される仕絁E��により、E
            'ユーザーを�Eわせることなく適刁E��タイミングでヒントを提供します、E,
      ),
      const TourStep(
        title: 'チE��ー完亁E,
        description:
            'Progressive Onboarding System により、E
            'ユーザーは段階的にアプリの使ぁE��を学習できます、E,
      ),
    ];

    OnboardingEngine.startInteractiveTour(context, customSteps);
  }
}
