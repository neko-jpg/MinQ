import 'package:flutter/material.dart';
import 'dart:math' as math;

/// ペア成立時の祝アニメーション
/// 軽量で視覚的に楽しい演出
class CelebrationAnimation extends StatefulWidget {
  final Widget child;
  final VoidCallback? onComplete;
  final Duration duration;

  const CelebrationAnimation({
    super.key,
    required this.child,
    this.onComplete,
    this.duration = const Duration(milliseconds: 1500),
  });

  @override
  State<CelebrationAnimation> createState() => _CelebrationAnimationState();
}

class _CelebrationAnimationState extends State<CelebrationAnimation>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _confettiController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _confettiController = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 1.2)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.2, end: 1.0)
            .chain(CurveTween(curve: Curves.elasticOut)),
        weight: 60,
      ),
    ]).animate(_controller);

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.3, curve: Curves.easeIn),
      ),
    );

    _controller.forward().then((_) {
      widget.onComplete?.call();
    });

    _confettiController.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 紙吹雪エフェクト
        Positioned.fill(
          child: AnimatedBuilder(
            animation: _confettiController,
            builder: (context, child) {
              return CustomPaint(
                painter: ConfettiPainter(
                  progress: _confettiController.value,
                ),
              );
            },
          ),
        ),
        // メインコンテンツ
        Center(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimation.value,
                child: Opacity(
                  opacity: _fadeAnimation.value,
                  child: widget.child,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

/// 紙吹雪描画
class ConfettiPainter extends CustomPainter {
  final double progress;
  final List<ConfettiParticle> particles;

  ConfettiPainter({required this.progress})
      : particles = List.generate(30, (index) => ConfettiParticle(index));

  @override
  void paint(Canvas canvas, Size size) {
    for (final particle in particles) {
      particle.paint(canvas, size, progress);
    }
  }

  @override
  bool shouldRepaint(ConfettiPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

/// 紙吹雪パーティクル
class ConfettiParticle {
  final int seed;
  late final double startX;
  late final double startY;
  late final double velocityX;
  late final double velocityY;
  late final double rotation;
  late final Color color;
  late final double size;

  ConfettiParticle(this.seed) {
    final random = math.Random(seed);
    startX = random.nextDouble();
    startY = -0.1;
    velocityX = (random.nextDouble() - 0.5) * 0.5;
    velocityY = 0.3 + random.nextDouble() * 0.5;
    rotation = random.nextDouble() * math.pi * 2;
    size = 4 + random.nextDouble() * 6;

    // カラフルな色
    final colors = [
      const Color(0xFFFF6B6B),
      const Color(0xFF4ECDC4),
      const Color(0xFFFFE66D),
      const Color(0xFF95E1D3),
      const Color(0xFFF38181),
      const Color(0xFFAA96DA),
    ];
    color = colors[random.nextInt(colors.length)];
  }

  void paint(Canvas canvas, Size size, double progress) {
    final x = size.width * (startX + velocityX * progress);
    final y = size.height * (startY + velocityY * progress);

    // 画面外は描画しない
    if (y > size.height) return;

    final paint = Paint()
      ..color = color.withOpacity(1.0 - progress * 0.5)
      ..style = PaintingStyle.fill;

    canvas.save();
    canvas.translate(x, y);
    canvas.rotate(rotation + progress * math.pi * 4);

    // 長方形の紙吹雪
    canvas.drawRect(
      Rect.fromCenter(
        center: Offset.zero,
        width: this.size,
        height: this.size * 1.5,
      ),
      paint,
    );

    canvas.restore();
  }
}

/// シンプルな成功アニメーション（チェックマーク）
class SuccessCheckAnimation extends StatefulWidget {
  final double size;
  final Color? color;
  final VoidCallback? onComplete;

  const SuccessCheckAnimation({
    super.key,
    this.size = 80,
    this.color,
    this.onComplete,
  });

  @override
  State<SuccessCheckAnimation> createState() => _SuccessCheckAnimationState();
}

class _SuccessCheckAnimationState extends State<SuccessCheckAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _checkAnimation;
  late Animation<double> _circleAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _circleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    _checkAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
      ),
    );

    _controller.forward().then((_) {
      widget.onComplete?.call();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? Theme.of(context).colorScheme.primary;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          size: Size(widget.size, widget.size),
          painter: CheckMarkPainter(
            circleProgress: _circleAnimation.value,
            checkProgress: _checkAnimation.value,
            color: color,
          ),
        );
      },
    );
  }
}

/// チェックマーク描画
class CheckMarkPainter extends CustomPainter {
  final double circleProgress;
  final double checkProgress;
  final Color color;

  CheckMarkPainter({
    required this.circleProgress,
    required this.checkProgress,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // 円の描画
    final circlePaint = Paint()
      ..color = color.withOpacity(0.2)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      center,
      radius * circleProgress,
      circlePaint,
    );

    // 円の枠線
    final strokePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    canvas.drawCircle(
      center,
      radius * circleProgress,
      strokePaint,
    );

    // チェックマーク
    if (checkProgress > 0) {
      final checkPaint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;

      final path = Path();
      final checkSize = size.width * 0.3;
      final startX = center.dx - checkSize * 0.5;
      final startY = center.dy;

      path.moveTo(startX, startY);
      
      // 短い線
      final midX = startX + checkSize * 0.4;
      final midY = startY + checkSize * 0.4;
      
      if (checkProgress < 0.5) {
        final progress = checkProgress * 2;
        path.lineTo(
          startX + (midX - startX) * progress,
          startY + (midY - startY) * progress,
        );
      } else {
        path.lineTo(midX, midY);
        
        // 長い線
        final endX = startX + checkSize * 1.2;
        final endY = startY - checkSize * 0.6;
        final progress = (checkProgress - 0.5) * 2;
        
        path.lineTo(
          midX + (endX - midX) * progress,
          midY + (endY - midY) * progress,
        );
      }

      canvas.drawPath(path, checkPaint);
    }
  }

  @override
  bool shouldRepaint(CheckMarkPainter oldDelegate) {
    return oldDelegate.circleProgress != circleProgress ||
        oldDelegate.checkProgress != checkProgress;
  }
}

/// パルスアニメーション（ハート等に使用）
class PulseAnimation extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final int pulseCount;

  const PulseAnimation({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 800),
    this.pulseCount = 2,
  });

  @override
  State<PulseAnimation> createState() => _PulseAnimationState();
}

class _PulseAnimationState extends State<PulseAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.3)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.3, end: 1.0)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 50,
      ),
    ]).animate(_controller);

    _controller.repeat(count: widget.pulseCount);
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
          child: widget.child,
        );
      },
    );
  }
}
