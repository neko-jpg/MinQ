import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/audio/sound_effects_service.dart';

/// エモーショナルフィードバックウィジェット集
class EmotionalFeedback {
  EmotionalFeedback._();

  /// 成功時のお祝いフィードバック
  static void celebrate(BuildContext context) {
    _showCelebrationOverlay(context);
    SoundEffectsService.instance.play(SoundType.achievement);
    HapticFeedback.mediumImpact();
  }

  /// 励ましフィードバック
  static void encourage(BuildContext context, String message) {
    _showEncouragementSnackBar(context, message);
    SoundEffectsService.instance.play(SoundType.chime);
    HapticFeedback.lightImpact();
  }

  /// 失敗時の優しいフィードバック
  static void comfort(BuildContext context, String message) {
    _showComfortDialog(context, message);
    SoundEffectsService.instance.play(SoundType.pop);
    HapticFeedback.selectionClick();
  }

  /// 達成時のエピックフィードバック
  static void epic(BuildContext context, String achievement) {
    _showEpicAchievement(context, achievement);
    SoundEffectsService.instance.play(SoundType.levelUp);
    HapticFeedback.heavyImpact();
  }

  static void _showCelebrationOverlay(BuildContext context) {
    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;
    
    overlayEntry = OverlayEntry(
      builder: (context) => _CelebrationOverlay(
        onComplete: () => overlayEntry.remove(),
      ),
    );
    
    overlay.insert(overlayEntry);
  }

  static void _showEncouragementSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.favorite, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.orange,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  static void _showComfortDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => _ComfortDialog(message: message),
    );
  }

  static void _showEpicAchievement(BuildContext context, String achievement) {
    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;
    
    overlayEntry = OverlayEntry(
      builder: (context) => _EpicAchievementOverlay(
        achievement: achievement,
        onComplete: () => overlayEntry.remove(),
      ),
    );
    
    overlay.insert(overlayEntry);
  }
}

/// お祝いオーバーレイ
class _CelebrationOverlay extends StatefulWidget {
  final VoidCallback onComplete;

  const _CelebrationOverlay({required this.onComplete});

  @override
  State<_CelebrationOverlay> createState() => _CelebrationOverlayState();
}

class _CelebrationOverlayState extends State<_CelebrationOverlay>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _confettiController;

  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    _confettiController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );
    
    _controller.forward();
    _confettiController.forward();
    
    // 自動で閉じる
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted) {
        widget.onComplete();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          // 背景
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Container(
                color: Colors.black.withOpacity(0.3 * _controller.value),
              );
            },
          ),
          
          // 紙吹雪
          AnimatedBuilder(
            animation: _confettiController,
            builder: (context, child) {
              return CustomPaint(
                painter: _ConfettiPainter(animation: _confettiController),
                size: Size.infinite,
              );
            },
          ),
          
          // メッセージ
          Center(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Transform.scale(
                  scale: _controller.value,
                  child: Opacity(
                    opacity: _controller.value,
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: const Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.celebration,
                            size: 48,
                            color: Colors.amber,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'おめでとうございます！',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            '素晴らしい成果です！',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ConfettiPainter extends CustomPainter {
  final Animation<double> animation;

  _ConfettiPainter({required this.animation}) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final random = math.Random(42); // 固定シードで一貫した動き

    for (int i = 0; i < 50; i++) {
      final progress = animation.value;
      final x = size.width * random.nextDouble();
      final y = -50 + (size.height + 100) * progress;
      final rotation = random.nextDouble() * math.pi * 2 * progress;
      
      paint.color = _getRandomColor(random);
      
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(rotation);
      canvas.drawRect(
        const Rect.fromLTWH(-4, -8, 8, 16),
        paint,
      );
      canvas.restore();
    }
  }

  Color _getRandomColor(math.Random random) {
    final colors = [
      Colors.red,
      Colors.blue,
      Colors.green,
      Colors.yellow,
      Colors.purple,
      Colors.orange,
    ];
    return colors[random.nextInt(colors.length)];
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/// 慰めダイアログ
class _ComfortDialog extends StatefulWidget {
  final String message;

  const _ComfortDialog({required this.message});

  @override
  State<_ComfortDialog> createState() => _ComfortDialogState();
}

class _ComfortDialogState extends State<_ComfortDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );
    
    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _opacityAnimation.value,
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.favorite,
                    size: 48,
                    color: Colors.pink,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    '大丈夫です',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.pink,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('ありがとう'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// エピック達成オーバーレイ
class _EpicAchievementOverlay extends StatefulWidget {
  final String achievement;
  final VoidCallback onComplete;

  const _EpicAchievementOverlay({
    required this.achievement,
    required this.onComplete,
  });

  @override
  State<_EpicAchievementOverlay> createState() => _EpicAchievementOverlayState();
}

class _EpicAchievementOverlayState extends State<_EpicAchievementOverlay>
    with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _particleController;
  late AnimationController _textController;

  @override
  void initState() {
    super.initState();
    
    _mainController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _particleController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );
    
    _textController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _startAnimationSequence();
  }

  void _startAnimationSequence() async {
    _particleController.forward();
    await Future.delayed(const Duration(milliseconds: 200));
    _mainController.forward();
    await Future.delayed(const Duration(milliseconds: 300));
    _textController.forward();
    
    // 自動で閉じる
    await Future.delayed(const Duration(milliseconds: 3000));
    if (mounted) {
      widget.onComplete();
    }
  }

  @override
  void dispose() {
    _mainController.dispose();
    _particleController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.purple.withOpacity(0.8),
              Colors.blue.withOpacity(0.8),
            ],
          ),
        ),
        child: Stack(
          children: [
            // パーティクルエフェクト
            AnimatedBuilder(
              animation: _particleController,
              builder: (context, child) {
                return CustomPaint(
                  painter: _EpicParticlePainter(animation: _particleController),
                  size: Size.infinite,
                );
              },
            ),
            
            // メインコンテンツ
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // トロフィーアイコン
                  AnimatedBuilder(
                    animation: _mainController,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _mainController.value,
                        child: Transform.rotate(
                          angle: _mainController.value * 0.1,
                          child: Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const LinearGradient(
                                colors: [Colors.amber, Colors.orange],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.amber.withOpacity(0.5),
                                  blurRadius: 20,
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.emoji_events,
                              size: 60,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // テキスト
                  AnimatedBuilder(
                    animation: _textController,
                    builder: (context, child) {
                      return Opacity(
                        opacity: _textController.value,
                        child: Transform.translate(
                          offset: Offset(0, 50 * (1 - _textController.value)),
                          child: Column(
                            children: [
                              const Text(
                                'EPIC ACHIEVEMENT!',
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: 2,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                widget.achievement,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 18,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EpicParticlePainter extends CustomPainter {
  final Animation<double> animation;

  _EpicParticlePainter({required this.animation}) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final random = math.Random(123);

    for (int i = 0; i < 100; i++) {
      final progress = animation.value;
      final x = size.width * random.nextDouble();
      final y = size.height * random.nextDouble();
      final scale = random.nextDouble() * progress;
      final opacity = (1.0 - progress) * random.nextDouble();
      
      paint.color = Colors.white.withOpacity(opacity);
      
      canvas.drawCircle(
        Offset(x, y),
        scale * 3,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/// エモーショナルボタン - 感情に応じて変化するボタン
class EmotionalButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final EmotionalState state;
  final Duration animationDuration;

  const EmotionalButton({
    super.key,
    required this.text,
    this.onPressed,
    this.state = EmotionalState.neutral,
    this.animationDuration = const Duration(milliseconds: 300),
  });

  @override
  State<EmotionalButton> createState() => _EmotionalButtonState();
}

class _EmotionalButtonState extends State<EmotionalButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    
    _updateColorAnimation();
    _controller.forward();
  }

  @override
  void didUpdateWidget(EmotionalButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.state != widget.state) {
      _updateColorAnimation();
      _controller.forward(from: 0.0);
    }
  }

  void _updateColorAnimation() {
    _colorAnimation = ColorTween(
      begin: _getStateColor(EmotionalState.neutral),
      end: _getStateColor(widget.state),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  Color _getStateColor(EmotionalState state) {
    switch (state) {
      case EmotionalState.happy:
        return Colors.green;
      case EmotionalState.excited:
        return Colors.orange;
      case EmotionalState.calm:
        return Colors.blue;
      case EmotionalState.motivated:
        return Colors.purple;
      case EmotionalState.neutral:
        return Colors.grey;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: ElevatedButton(
            onPressed: widget.onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: _colorAnimation.value,
              foregroundColor: Colors.white,
              elevation: 4 + (_controller.value * 4),
              shadowColor: _colorAnimation.value?.withOpacity(0.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(widget.text),
          ),
        );
      },
    );
  }
}

/// エモーショナルカード - 感情に応じて変化するカード
class EmotionalCard extends StatefulWidget {
  final Widget child;
  final EmotionalState state;
  final Duration animationDuration;

  const EmotionalCard({
    super.key,
    required this.child,
    this.state = EmotionalState.neutral,
    this.animationDuration = const Duration(milliseconds: 500),
  });

  @override
  State<EmotionalCard> createState() => _EmotionalCardState();
}

class _EmotionalCardState extends State<EmotionalCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    
    _glowAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    
    if (widget.state != EmotionalState.neutral) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(EmotionalCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.state != widget.state) {
      if (widget.state != EmotionalState.neutral) {
        _controller.repeat(reverse: true);
      } else {
        _controller.stop();
        _controller.reset();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: widget.state != EmotionalState.neutral ? [
              BoxShadow(
                color: _getStateColor(widget.state).withOpacity(0.3 * _glowAnimation.value),
                blurRadius: 10 + (10 * _glowAnimation.value),
                spreadRadius: 2 + (2 * _glowAnimation.value),
              ),
            ] : null,
          ),
          child: Card(
            elevation: 2 + (4 * _glowAnimation.value),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: _getStateColor(widget.state).withOpacity(0.3 * _glowAnimation.value),
                width: 1 + _glowAnimation.value,
              ),
            ),
            child: widget.child,
          ),
        );
      },
    );
  }

  Color _getStateColor(EmotionalState state) {
    switch (state) {
      case EmotionalState.happy:
        return Colors.green;
      case EmotionalState.excited:
        return Colors.orange;
      case EmotionalState.calm:
        return Colors.blue;
      case EmotionalState.motivated:
        return Colors.purple;
      case EmotionalState.neutral:
        return Colors.grey;
    }
  }
}

/// 感情状態
enum EmotionalState {
  neutral,
  happy,
  excited,
  calm,
  motivated,
}