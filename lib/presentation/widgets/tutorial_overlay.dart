import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/animation_system.dart';
import '../theme/spacing_system.dart';

/// チュートリアルステップ
class TutorialStep {
  final String id;
  final String title;
  final String description;
  final GlobalKey targetKey;
  final TutorialPosition position;
  final IconData? icon;
  final VoidCallback? onNext;
  final VoidCallback? onSkip;

  const TutorialStep({
    required this.id,
    required this.title,
    required this.description,
    required this.targetKey,
    this.position = TutorialPosition.bottom,
    this.icon,
    this.onNext,
    this.onSkip,
  });
}

/// チュートリアル位置
enum TutorialPosition {
  top,
  bottom,
  left,
  right,
  center,
}

/// チュートリアルオーバーレイ
class TutorialOverlay extends StatefulWidget {
  final List<TutorialStep> steps;
  final VoidCallback onComplete;
  final VoidCallback? onSkip;

  const TutorialOverlay({
    super.key,
    required this.steps,
    required this.onComplete,
    this.onSkip,
  });

  @override
  State<TutorialOverlay> createState() => _TutorialOverlayState();

  /// チュートリアルを表示
  static Future<void> show({
    required BuildContext context,
    required List<TutorialStep> steps,
    required VoidCallback onComplete,
    VoidCallback? onSkip,
  }) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black54,
      builder: (context) => TutorialOverlay(
        steps: steps,
        onComplete: onComplete,
        onSkip: onSkip,
      ),
    );
  }
}

class _TutorialOverlayState extends State<TutorialOverlay>
    with SingleTickerProviderStateMixin {
  int _currentStep = 0;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: AnimationSystem.fadeIn,
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: AnimationSystem.fadeInCurve,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_currentStep >= widget.steps.length) {
      return const SizedBox.shrink();
    }

    final step = widget.steps[_currentStep];
    final targetContext = step.targetKey.currentContext;

    if (targetContext == null) {
      return const SizedBox.shrink();
    }

    final renderBox = targetContext.findRenderObject() as RenderBox;
    final targetPosition = renderBox.localToGlobal(Offset.zero);
    final targetSize = renderBox.size;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Stack(
        children: [
          // 背景オーバーレイ
          GestureDetector(
            onTap: () {}, // タップを無効化
            child: Container(
              color: Colors.black54,
            ),
          ),

          // ターゲットのハイライト
          Positioned(
            left: targetPosition.dx - 8,
            top: targetPosition.dy - 8,
            child: Container(
              width: targetSize.width + 16,
              height: targetSize.height + 16,
              decoration: BoxDecoration(
                color: Colors.transparent,
                border: Border.all(
                  color: Theme.of(context).colorScheme.primary,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
            ),
          ),

          // 説明カード
          _buildDescriptionCard(
            context,
            step,
            targetPosition,
            targetSize,
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionCard(
    BuildContext context,
    TutorialStep step,
    Offset targetPosition,
    Size targetSize,
  ) {
    final theme = Theme.of(context);
    final screenSize = MediaQuery.of(context).size;

    // カードの位置を計算
    Offset cardPosition;
    switch (step.position) {
      case TutorialPosition.top:
        cardPosition = Offset(
          targetPosition.dx,
          targetPosition.dy - 200,
        );
        break;
      case TutorialPosition.bottom:
        cardPosition = Offset(
          targetPosition.dx,
          targetPosition.dy + targetSize.height + 16,
        );
        break;
      case TutorialPosition.left:
        cardPosition = Offset(
          targetPosition.dx - 300,
          targetPosition.dy,
        );
        break;
      case TutorialPosition.right:
        cardPosition = Offset(
          targetPosition.dx + targetSize.width + 16,
          targetPosition.dy,
        );
        break;
      case TutorialPosition.center:
        cardPosition = Offset(
          (screenSize.width - 300) / 2,
          (screenSize.height - 200) / 2,
        );
        break;
    }

    // 画面外に出ないように調整
    cardPosition = Offset(
      cardPosition.dx.clamp(16.0, screenSize.width - 316),
      cardPosition.dy.clamp(16.0, screenSize.height - 216),
    );

    return Positioned(
      left: cardPosition.dx,
      top: cardPosition.dy,
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: 300,
          padding: EdgeInsets.all(Spacing.md),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // アイコンとタイトル
              Row(
                children: [
                  if (step.icon != null) ...[
                    Icon(
                      step.icon,
                      color: theme.colorScheme.primary,
                      size: 24,
                    ),
                    SizedBox(width: Spacing.sm),
                  ],
                  Expanded(
                    child: Text(
                      step.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: Spacing.sm),

              // 説明
              Text(
                step.description,
                style: theme.textTheme.bodyMedium,
              ),

              SizedBox(height: Spacing.md),

              // 進捗インジケータ
              Row(
                children: List.generate(
                  widget.steps.length,
                  (index) => Container(
                    width: 8,
                    height: 8,
                    margin: EdgeInsets.only(right: Spacing.xxs),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: index == _currentStep
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurface.withOpacity(0.3),
                    ),
                  ),
                ),
              ),

              SizedBox(height: Spacing.md),

              // ボタン
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // スキップボタン
                  TextButton(
                    onPressed: _onSkip,
                    child: const Text('スキップ'),
                  ),

                  // 次へボタン
                  ElevatedButton(
                    onPressed: _onNext,
                    child: Text(
                      _currentStep == widget.steps.length - 1
                          ? '完了'
                          : '次へ',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onNext() {
    final step = widget.steps[_currentStep];
    step.onNext?.call();

    if (_currentStep < widget.steps.length - 1) {
      setState(() {
        _currentStep++;
      });
      _animationController.reset();
      _animationController.forward();
    } else {
      widget.onComplete();
      Navigator.of(context).pop();
    }
  }

  void _onSkip() {
    final step = widget.steps[_currentStep];
    step.onSkip?.call();
    widget.onSkip?.call();
    Navigator.of(context).pop();
  }
}

/// チュートリアルマネージャー
class TutorialManager {
  static const String _keyPrefix = 'tutorial_completed_';

  /// チュートリアルが完了しているかチェック
  static Future<bool> isCompleted(String tutorialId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('$_keyPrefix$tutorialId') ?? false;
  }

  /// チュートリアルを完了としてマーク
  static Future<void> markAsCompleted(String tutorialId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('$_keyPrefix$tutorialId', true);
  }

  /// チュートリアルをリセット
  static Future<void> reset(String tutorialId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('$_keyPrefix$tutorialId');
  }

  /// 全てのチュートリアルをリセット
  static Future<void> resetAll() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();
    for (final key in keys) {
      if (key.startsWith(_keyPrefix)) {
        await prefs.remove(key);
      }
    }
  }

  /// チュートリアルを表示すべきかチェック
  static Future<bool> shouldShow(String tutorialId) async {
    return !await isCompleted(tutorialId);
  }
}

/// チュートリアルID
class TutorialIds {
  const TutorialIds._();

  static const String home = 'home';
  static const String createQuest = 'create_quest';
  static const String recordQuest = 'record_quest';
  static const String stats = 'stats';
  static const String pair = 'pair';
  static const String settings = 'settings';
}

/// コーチマーク
class CoachMark extends StatelessWidget {
  final String message;
  final Widget child;
  final bool show;
  final CoachMarkPosition position;

  const CoachMark({
    super.key,
    required this.message,
    required this.child,
    this.show = true,
    this.position = CoachMarkPosition.top,
  });

  @override
  Widget build(BuildContext context) {
    if (!show) {
      return child;
    }

    return Stack(
      clipBehavior: Clip.none,
      children: [
        child,
        Positioned(
          top: position == CoachMarkPosition.top ? -60 : null,
          bottom: position == CoachMarkPosition.bottom ? -60 : null,
          left: position == CoachMarkPosition.left ? -200 : null,
          right: position == CoachMarkPosition.right ? -200 : null,
          child: _buildCoachMarkBubble(context),
        ),
      ],
    );
  }

  Widget _buildCoachMarkBubble(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.all(Spacing.sm),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.lightbulb_outline,
            color: theme.colorScheme.onPrimaryContainer,
            size: 20,
          ),
          SizedBox(width: Spacing.xs),
          Flexible(
            child: Text(
              message,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// コーチマーク位置
enum CoachMarkPosition {
  top,
  bottom,
  left,
  right,
}

/// ツールチップ
class CustomTooltip extends StatelessWidget {
  final String message;
  final Widget child;
  final TooltipTriggerMode triggerMode;

  const CustomTooltip({
    super.key,
    required this.message,
    required this.child,
    this.triggerMode = TooltipTriggerMode.longPress,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: message,
      triggerMode: triggerMode,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.inverseSurface,
        borderRadius: BorderRadius.circular(8),
      ),
      textStyle: TextStyle(
        color: Theme.of(context).colorScheme.onInverseSurface,
      ),
      child: child,
    );
  }
}
