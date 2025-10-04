import 'package:flutter/material.dart';
import 'package:minq/presentation/common/onboarding/onboarding_engine.dart';

/// インタラクチE��ブツアーを表示するスクリーン
class InteractiveTourScreen extends StatefulWidget {
  final List<TourStep> steps;
  final VoidCallback? onComplete;

  const InteractiveTourScreen({
    super.key,
    required this.steps,
    this.onComplete,
  });

  @override
  State<InteractiveTourScreen> createState() => _InteractiveTourScreenState();
}

class _InteractiveTourScreenState extends State<InteractiveTourScreen>
    with TickerProviderStateMixin {
  int _currentStepIndex = 0;
  late AnimationController _slideController;
  late AnimationController _fadeController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _fadeController.forward();
  }

  void _initializeAnimations() {
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeInOut,
    ),);

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ),);
  }

  void _nextStep() {
    if (_currentStepIndex < widget.steps.length - 1) {
      _slideController.forward().then((_) {
        setState(() {
          _currentStepIndex++;
        });
        _slideController.reset();
      });
      
      // カスタムアクションを実衁E
      widget.steps[_currentStepIndex].onNext?.call();
    } else {
      _completeTour();
    }
  }

  void _previousStep() {
    if (_currentStepIndex > 0) {
      _slideController.forward().then((_) {
        setState(() {
          _currentStepIndex--;
        });
        _slideController.reset();
      });
    }
  }

  void _completeTour() async {
    await OnboardingEngine.markOnboardingCompleted();
    widget.onComplete?.call();
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  void _skipTour() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('チE��ーをスキチE�Eしますか�E�E),
        content: const Text('後で設定画面からチE��ーを�E開できます、E),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _completeTour();
            },
            child: const Text('スキチE�E'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _slideController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentStep = widget.steps[_currentStepIndex];
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.black.withValues(alpha: 0.8),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SafeArea(
          child: Column(
            children: [
              // ヘッダー
              _buildHeader(theme),
              
              // メインコンチE��チE
              Expanded(
                child: SlideTransition(
                  position: _slideAnimation,
                  child: _buildStepContent(currentStep, theme),
                ),
              ),
              
              // フッター
              _buildFooter(theme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'MinQ チE��ー',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          TextButton(
            onPressed: _skipTour,
            child: Text(
              'スキチE�E',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepContent(TourStep step, ThemeData theme) {
    return Container(
      margin: const EdgeInsets.all(24.0),
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // スチE��プインジケーター
          _buildStepIndicator(theme),
          
          const SizedBox(height: 24),
          
          // タイトル
          Text(
            step.title,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          
          const SizedBox(height: 16),
          
          // 説昁E
          Text(
            step.description,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
              height: 1.5,
            ),
          ),
          
          const SizedBox(height: 24),
          
          // カスタムウィジェチE��
          if (step.customWidget != null) ...[
            step.customWidget!,
            const SizedBox(height: 24),
          ],
          
          // インタラクチE��ブ要素
          _buildInteractiveElement(step, theme),
        ],
      ),
    );
  }

  Widget _buildStepIndicator(ThemeData theme) {
    return Row(
      children: List.generate(
        widget.steps.length,
        (index) => Container(
          width: 8,
          height: 8,
          margin: const EdgeInsets.only(right: 8),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: index <= _currentStepIndex
                ? theme.colorScheme.primary
                : theme.colorScheme.outline.withValues(alpha: 0.3),
          ),
        ),
      ),
    );
  }

  Widget _buildInteractiveElement(TourStep step, ThemeData theme) {
    // スチE��プに応じたインタラクチE��ブ要素を表示
    switch (_currentStepIndex) {
      case 0:
        return _buildWelcomeInteraction(theme);
      case 1:
        return _buildQuestCreationDemo(theme);
      case 2:
        return _buildCompletionDemo(theme);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildWelcomeInteraction(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.waving_hand,
            color: theme.colorScheme.primary,
            size: 32,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              'MinQへようこそ�E�\n習�E化�E旁E��始めましょぁE,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestCreationDemo(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.secondaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'クエスト例！E,
            style: theme.textTheme.labelLarge?.copyWith(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          _buildQuestExample('毎朝ジョギング', Icons.directions_run, theme),
          _buildQuestExample('読書30刁E, Icons.book, theme),
          _buildQuestExample('水めEL飲む', Icons.local_drink, theme),
        ],
      ),
    );
  }

  Widget _buildQuestExample(String title, IconData icon, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompletionDemo(ThemeData theme) {
    return GestureDetector(
      onTap: () {
        // チE��用のチェチE��ボックスアニメーション
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('素晴らしぁE��クエスト完亁E��ぁE🎉'),
            backgroundColor: theme.colorScheme.primary,
            duration: const Duration(seconds: 2),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: theme.colorScheme.primary.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: theme.colorScheme.primary,
                  width: 2,
                ),
              ),
              child: const Icon(
                Icons.check,
                size: 16,
                color: Colors.transparent,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                'タチE�Eしてクエスト完亁E��体騁E,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ),
            Icon(
              Icons.touch_app,
              color: theme.colorScheme.primary.withValues(alpha: 0.7),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 戻る�Eタン
          if (_currentStepIndex > 0)
            TextButton.icon(
              onPressed: _previousStep,
              icon: const Icon(Icons.arrow_back),
              label: const Text('戻めE),
              style: TextButton.styleFrom(
                foregroundColor: Colors.white.withValues(alpha: 0.8),
              ),
            )
          else
            const SizedBox.shrink(),
          
          // 進捗表示
          Text(
            '${_currentStepIndex + 1} / ${widget.steps.length}',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 16,
            ),
          ),
          
          // 次へボタン
          ElevatedButton.icon(
            onPressed: _nextStep,
            icon: Icon(
              _currentStepIndex == widget.steps.length - 1
                  ? Icons.check
                  : Icons.arrow_forward,
            ),
            label: Text(
              _currentStepIndex == widget.steps.length - 1
                  ? '完亁E
                  : '次へ',
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// チE��ースチE��プ�Eビルダー
class TourStepBuilder {
  static List<TourStep> buildDefaultTour() {
    return [
      const TourStep(
        title: 'MinQへようこそ�E�E,
        description: 'MinQは習�E化を楽しく続けるため�Eアプリです、E
            'あなた�E目標達成をサポ�Eトし、継続する喜びを感じられるように設計されてぁE��す、E,
      ),
      const TourStep(
        title: 'クエストを作�EしましょぁE,
        description: '習�E化したいことを「クエスト」として登録します、E
            '「毎朝ジョギング」「読書30刁E��など、�E体的で実行しめE��ぁE�E容にしましょぁE��E,
      ),
      const TourStep(
        title: 'クエストを完亁E��ましょぁE,
        description: 'クエストを実行したら、チェチE��マ�EクをタチE�Eして完亁E��します、E
            '完亁E��には気持ちの良ぁE��ニメーションと効果音でお祝いします！E,
      ),
      const TourStep(
        title: '進捗を確認しましょぁE,
        description: '継続記録めE��成状況をグラフで確認できます、E
            '連続記録が伸びてぁE��様子を見ることで、モチ�Eーションを維持できます、E,
      ),
      const TourStep(
        title: 'ペアと一緒に頑張りましょぁE,
        description: '匿名�Eペアと励まし合ぁE��がら習�E化に取り絁E��ます、E
            'ひとりじめE��ぁE��忁E��で、三日坊主を防げます、E,
      ),
      const TourStep(
        title: '準備完亁E��す！E,
        description: 'これでMinQの基本皁E��使ぁE��がわかりました、E
            'さっそく最初�Eクエストを作�Eして、習�E化�E旁E��始めましょぁE��E,
      ),
    ];
  }
}