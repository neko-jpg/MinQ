import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:minq/presentation/common/onboarding/onboarding.dart';

/// オンボーディングシステムのデモ画面
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
        content: Text('オンボーディング状態をリセットしました'),
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
        title: const Text('オンボーディングシステム デモ'),
        backgroundColor: theme.colorScheme.primaryContainer,
        actions: [
          IconButton(
            onPressed: _resetOnboarding,
            icon: const Icon(Icons.refresh),
            tooltip: 'リセット',
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
            
            // インタラクティブツアー
            _buildSectionCard(
              theme,
              'インタラクティブツアー',
              'ステップバイステップのガイドツアー',
              [
                ElevatedButton.icon(
                  onPressed: _startInteractiveTour,
                  icon: const Icon(Icons.tour),
                  label: const Text('ツアーを開始'),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // コンテキスト依存ガイド
            _buildSectionCard(
              theme,
              'コンテキスト依存ガイド',
              '画面に応じたガイドを表示',
              [
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ElevatedButton(
                      onPressed: () => _showContextualGuide('home'),
                      child: const Text('ホームへ移動する'),
                    ),
                    ElevatedButton(
                      onPressed: () => _showContextualGuide('quest_creation'),
                      child: const Text('クエストを作成する'),
                    ),
                    ElevatedButton(
                      onPressed: () => _showContextualGuide('stats'),
                      child: const Text('統計を見る'),
                    ),
                    ElevatedButton(
                      onPressed: () => _showContextualGuide('pair'),
                      child: const Text('ペアを探す'),
                    ),
                  ],
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // スマートツールチップ
            _buildSectionCard(
              theme,
              'スマートツールチップ',
              '一度だけ表示されるツールチップ',
              [
                Row(
                  children: [
                    SmartTooltip(
                      message: 'これは長押しで表示されるツールチップです',
                      tooltipId: 'demo_longpress_tooltip',
                      child: ElevatedButton(
                        onPressed: () {},
                        child: const Text('長押しで表示する'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    SmartTooltip(
                      message: 'これはタップで表示されるツールチップです',
                      tooltipId: 'demo_tap_tooltip',
                      trigger: TooltipTrigger.tap,
                      child: ElevatedButton(
                        onPressed: () {},
                        child: const Text('タップで表示する'),
                      ),
                    ),
                  ],
                const SizedBox(height: 16),
                AutoSmartTooltip(
                  message: '自動表示されるツールチップ',
                  tooltipId: 'demo_auto_tooltip',
                  delay: const Duration(seconds: 1),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.secondaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text('自動ツールチップ付きコンテナ'),
                  ),
                ),
              ],
            ),
            
            _buildSectionCard(
              theme,
              'プログレッシブヒント',
              'ユーザーの進捗に応じたヒント',
              [
                ElevatedButton.icon(
                  onPressed: _showProgressiveHint,
                  icon: const Icon(Icons.lightbulb_outline),
                  label: const Text('ヒントを表示する'),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // オンボーディングオーバーレイ
            _buildSectionCard(
              theme,
              'オンボーディングオーバーレイ',
              'カスタムオーバーレイガイド',
              [
                ElevatedButton.icon(
                  onPressed: () => _showCustomOverlay(context),
                  icon: const Icon(Icons.info_outline),
                  label: const Text('オーバーレイを表示する'),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: () => _showStepByStepGuide(context),
                  icon: const Icon(Icons.assistant),
                  label: const Text('ガイドを開始する'),
                ),
              ],
            ),
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
                  _hasCompletedOnboarding ? Icons.check_circle : Icons.radio_button_unchecked,
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
              '現在のステップ: $_currentStep',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
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
                color: theme.colorScheme.onSurface.withOpacity(0.7),
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
      builder: (context) => OnboardingOverlay(
        title: 'カスタムオーバーレイ',
        description: 'これはカスタムオーバーレイの例です。'
            'ユーザーに重要な情報を伝えるために使用できます。',
        onDismiss: () => Navigator.of(context).pop(),
        customContent: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(
                Icons.star,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text('カスタムコンテンツを追加できます'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showStepByStepGuide(BuildContext context) {
    final steps = [
      const GuideStep(
        title: 'ステップ 1',
        description: 'これは最初のステップです。基本的な操作を説明します。',
      ),
      const GuideStep(
        title: 'ステップ 2',
        description: 'これは2番目のステップです。より詳細な機能を説明します。',
      ),
      const GuideStep(
        title: 'ステップ 3',
        description: 'これは最後のステップです。高度な機能を説明します。',
      ),
    ];

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StepByStepOverlay(
        steps: steps,
        onComplete: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('ステップバイステップガイドが完了しました！'),
              backgroundColor: Colors.green,
            ),
          );
        },
      ),
    );
  }
}