import 'package:flutter/material.dart';

/// オンボーディング用のオーバーレイコンポーネント
class OnboardingOverlay extends StatefulWidget {
  final String title;
  final String description;
  final String? targetKey;
  final VoidCallback onDismiss;
  final Widget? customContent;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;

  const OnboardingOverlay({
    super.key,
    required this.title,
    required this.description,
    required this.onDismiss,
    this.targetKey,
    this.customContent,
    this.padding,
    this.borderRadius,
  });

  @override
  State<OnboardingOverlay> createState() => _OnboardingOverlayState();
}

class _OnboardingOverlayState extends State<OnboardingOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _animationController.forward();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeInOut),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 0.8, curve: Curves.elasticOut),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOutBack),
      ),
    );
  }

  void _dismiss() {
    _animationController.reverse().then((_) {
      widget.onDismiss();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mediaQuery = MediaQuery.of(context);

    return Material(
      color: Colors.transparent,
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Stack(
            children: [
              // 背景オーバーレイ
              FadeTransition(
                opacity: _fadeAnimation,
                child: GestureDetector(
                  onTap: _dismiss,
                  child: Container(
                    width: double.infinity,
                    height: double.infinity,
                    color: Colors.black.withAlpha(179),
                  ),
                ),
              ),

              // メインコンテンツ
              Center(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: _buildContent(theme, mediaQuery),
                    ),
                  ),
                ),
              ),

              // スポットライト効果（ターゲットがある場合）
              if (widget.targetKey != null) _buildSpotlight(theme),
            ],
          );
        },
      ),
    );
  }

  Widget _buildContent(ThemeData theme, MediaQueryData mediaQuery) {
    return Container(
      margin: const EdgeInsets.all(24.0),
      padding: widget.padding ?? const EdgeInsets.all(24.0),
      constraints: BoxConstraints(
        maxWidth: mediaQuery.size.width * 0.9,
        maxHeight: mediaQuery.size.height * 0.8,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: widget.borderRadius ?? BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(77),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ヘッダー
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  widget.title,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ),
              IconButton(
                onPressed: _dismiss,
                icon: Icon(
                  Icons.close,
                  color: theme.colorScheme.onSurface.withAlpha(179),
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // 説明文
          Text(
            widget.description,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface.withAlpha(204),
              height: 1.5,
            ),
          ),

          const SizedBox(height: 24),

          // カスタムコンテンツ
          if (widget.customContent != null) ...[
            widget.customContent!,
            const SizedBox(height: 24),
          ],

          // アクションボタン
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(onPressed: _dismiss, child: const Text('スキップ')),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: _dismiss,
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
                child: const Text('わかりました'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSpotlight(ThemeData theme) {
    // 実際の実装では、targetKeyを使用してターゲット要素の位置を特定し、
    // その周りにスポットライト効果を作成する
    return Positioned.fill(
      child: CustomPaint(
        painter: SpotlightPainter(
          spotlightRect: const Rect.fromLTWH(100, 200, 200, 100),
          color: Colors.black.withAlpha(204),
        ),
      ),
    );
  }
}

/// スポットライト効果を描画するカスタムペインター
class SpotlightPainter extends CustomPainter {
  final Rect spotlightRect;
  final Color color;
  final double blurRadius;

  SpotlightPainter({
    required this.spotlightRect,
    required this.color,
    this.blurRadius = 20.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = color
          ..style = PaintingStyle.fill;

    final path =
        Path()
          ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
          ..addRRect(
            RRect.fromRectAndRadius(spotlightRect, const Radius.circular(8)),
          )
          ..fillType = PathFillType.evenOdd;

    canvas.drawPath(path, paint);

    // スポットライト周りのグロー効果
    final glowPaint =
        Paint()
          ..color = Colors.white.withAlpha(26)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, blurRadius);

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        spotlightRect.inflate(blurRadius / 2),
        Radius.circular(8 + blurRadius / 2),
      ),
      glowPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return oldDelegate != this;
  }
}

/// ステップバイステップガイド用のオーバーレイ
class StepByStepOverlay extends StatefulWidget {
  final List<GuideStep> steps;
  final VoidCallback? onComplete;

  const StepByStepOverlay({super.key, required this.steps, this.onComplete});

  @override
  State<StepByStepOverlay> createState() => _StepByStepOverlayState();
}

class _StepByStepOverlayState extends State<StepByStepOverlay> {
  int _currentStepIndex = 0;

  void _nextStep() {
    if (_currentStepIndex < widget.steps.length - 1) {
      setState(() {
        _currentStepIndex++;
      });
    } else {
      widget.onComplete?.call();
      Navigator.of(context).pop();
    }
  }

  void _previousStep() {
    if (_currentStepIndex > 0) {
      setState(() {
        _currentStepIndex--;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentStep = widget.steps[_currentStepIndex];

    return OnboardingOverlay(
      title: currentStep.title,
      description: currentStep.description,
      targetKey: currentStep.targetKey,
      onDismiss: _nextStep,
      customContent: Column(
        children: [
          // ステップインジケーター
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              widget.steps.length,
              (index) => Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color:
                      index <= _currentStepIndex
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(
                            context,
                          ).colorScheme.outline.withAlpha(77),
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // ナビゲーションボタン
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (_currentStepIndex > 0)
                TextButton.icon(
                  onPressed: _previousStep,
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('戻る'),
                )
              else
                const SizedBox.shrink(),

              Text(
                '${_currentStepIndex + 1} / ${widget.steps.length}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withAlpha(179),
                ),
              ),

              TextButton.icon(
                onPressed: _nextStep,
                icon: Icon(
                  _currentStepIndex == widget.steps.length - 1
                      ? Icons.check
                      : Icons.arrow_forward,
                ),
                label: Text(
                  _currentStepIndex == widget.steps.length - 1 ? '完了' : '次へ',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// ガイドステップの定義
class GuideStep {
  final String title;
  final String description;
  final String? targetKey;
  final Widget? customWidget;

  const GuideStep({
    required this.title,
    required this.description,
    this.targetKey,
    this.customWidget,
  });
}
