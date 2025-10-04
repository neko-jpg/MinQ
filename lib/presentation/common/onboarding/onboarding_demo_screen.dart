import 'package:flutter/material.dart';
import 'package:minq/presentation/common/onboarding/onboarding.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// オンボ�EチE��ングシスチE��のチE��画面
class OnboardingDemoScreen extends StatefulWidget {
  const OnboardingDemoScreen({super.key});

  @override
  State<OnboardingDemoScreen> createState() => _OnboardingDemoScreenState();
}

class _OnboardingDemoScreenState extends State<OnboardingDemoScreen> {
  bool _hasCompletedOnboarding = false;
  int _currentStep = 0;
  final List<String> _viewedTooltips = [];

  @override
  void initState() {
    super.initState();
    _loadOnboardingState();
  }

  Future<void> _loadOnboardingState() async {
    final completed = await OnboardingEngine.hasCompletedOnboarding();
    final step = await OnboardingEngine.getCurrentStep();

    setState(() {
      _hasCompletedOnboarding = completed;
      _currentStep = step;
    });
  }

  Future<void> _resetOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    await _loadOnboardingState();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('オンボ�EチE��ング状態をリセチE��しました'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _startInteractiveTour() {
    final steps = TourStepBuilder.buildDefaultTour();
    OnboardingEngine.startInteractiveTour(context, steps);
  }

  void _showContextualGuide(String screenId) {
    OnboardingEngine.showContextualGuide(screenId, context);
  }

  void _showProgressiveHint() {
    const progress = UserProgress(
      totalQuests: 0,
      completedQuests: 0,
      currentStreak: 0,
      bestStreak: 0,
    );
    OnboardingEngine.showProgressiveHint(progress);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('オンボ�EチE��ングシスチE�� チE��'),
        backgroundColor: theme.colorScheme.primaryContainer,
        actions: [
          IconButton(
            onPressed: _resetOnboarding,
            icon: const Icon(Icons.refresh),
            tooltip: 'リセチE��',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 状態表示
            _buildStatusCard(theme),

            const SizedBox(height: 24),

            // インタラクチE��ブツアー
            _buildSectionCard(theme, 'インタラクチE��ブツアー', 'スチE��プバイスチE��プ�Eガイドツアー', [
              ElevatedButton.icon(
                onPressed: _startInteractiveTour,
                icon: const Icon(Icons.tour),
                label: const Text('チE��ーを開姁E),
              ),
            ]),

            const SizedBox(height: 16),

            // コンチE��スト依存ガイチE
            _buildSectionCard(theme, 'コンチE��スト依存ガイチE, '画面に応じたガイドを表示', [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ElevatedButton(
                    onPressed: () => _showContextualGuide('home'),
                    child: const Text('ホ�Eムへ移動すめE),
                  ),
                  ElevatedButton(
                    onPressed: () => _showContextualGuide('quest_creation'),
                    child: const Text('クエストを作�Eする'),
                  ),
                  ElevatedButton(
                    onPressed: () => _showContextualGuide('stats'),
                    child: const Text('統計を見る'),
                  ),
                  ElevatedButton(
                    onPressed: () => _showContextualGuide('pair'),
                    child: const Text('ペアを探ぁE),
                  ),
                ],
              ),
            ]),

            const SizedBox(height: 16),

            // スマ�EトツールチッチE
            _buildSectionCard(theme, 'スマ�EトツールチッチE, '一度だけ表示されるツールチッチE, [
              Row(
                children: [
                  SmartTooltip(
                    message: 'これは長押しで表示されるツールチップでぁE,
                    tooltipId: 'demo_longpress_tooltip',
                    child: ElevatedButton(
                      onPressed: () {},
                      child: const Text('長押しで表示する'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  SmartTooltip(
                    message: 'これはタチE�Eで表示されるツールチップでぁE,
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
                delay: const Duration(seconds: 1),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text('自動ツールチップ付きコンチE��'),
                ),
              ),
            ]),

            _buildSectionCard(theme, 'プログレチE��ブヒンチE, 'ユーザーの進捗に応じたヒンチE, [
              ElevatedButton.icon(
                onPressed: _showProgressiveHint,
                icon: const Icon(Icons.lightbulb_outline),
                label: const Text('ヒントを表示する'),
              ),
            ]),

            const SizedBox(height: 16),

            // オンボ�EチE��ングオーバ�Eレイ
            _buildSectionCard(theme, 'オンボ�EチE��ングオーバ�Eレイ', 'カスタムオーバ�EレイガイチE, [
              ElevatedButton.icon(
                onPressed: () => _showCustomOverlay(context),
                icon: const Icon(Icons.info_outline),
                label: const Text('オーバ�Eレイを表示する'),
              ),
              const SizedBox(width: 16),
              ElevatedButton.icon(
                onPressed: () => _showStepByStepGuide(context),
                icon: const Icon(Icons.assistant),
                label: const Text('ガイドを開始すめE),
              ),
            ]),
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
              '現在のスチE��チE $_currentStep',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard(
    ThemeData theme,
    String title,
    String description,
    List<Widget> actions,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 16),
            ...actions,
          ],
        ),
      ),
    );
  }

  void _showCustomOverlay(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder:
          (context) => OnboardingOverlay(
            title: 'カスタムオーバ�Eレイ',
            description:
                'これはカスタムオーバ�Eレイの例です、E
                'ユーザーに重要な惁E��を伝えるために使用できます、E,
            onDismiss: () => Navigator.of(context).pop(),
            customContent: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.primaryContainer.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.star,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  const Expanded(child: Text('カスタムコンチE��チE��追加できまぁE)),
                ],
              ),
            ),
          ),
    );
  }

  void _showStepByStepGuide(BuildContext context) {
    final steps = [
      const GuideStep(
        title: 'スチE��チE1',
        description: 'これは最初�EスチE��プです。基本皁E��操作を説明します、E,
      ),
      const GuideStep(
        title: 'スチE��チE2',
        description: 'これは2番目のスチE��プです。より詳細な機�Eを説明します、E,
      ),
      const GuideStep(
        title: 'スチE��チE3',
        description: 'これは最後�EスチE��プです。高度な機�Eを説明します、E,
      ),
    ];

    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => StepByStepOverlay(
            steps: steps,
            onComplete: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('スチE��プバイスチE��プガイドが完亁E��ました�E�E),
                  backgroundColor: Colors.green,
                ),
              );
            },
          ),
    );
  }
}
