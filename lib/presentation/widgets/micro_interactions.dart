import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:minq/presentation/theme/minq_theme.dart';

/// マイクロインタラクション集
///
/// アプリ全体で使用する小さなアニメーションとフィードバック
class MicroInteractions {
  MicroInteractions._();

  /// タップ時の触覚フィードバック
  static void tapFeedback() {
    HapticFeedback.lightImpact();
  }

  /// 成功時の触覚フィードバック
  static void successFeedback() {
    HapticFeedback.mediumImpact();
  }

  /// エラー時の触覚フィードバック
  static void errorFeedback() {
    HapticFeedback.heavyImpact();
  }

  /// 選択時の触覚フィードバック
  static void selectionFeedback() {
    HapticFeedback.selectionClick();
  }
}

/// バウンスボタン - タップ時にバウンスアニメーション
class BounceButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final Duration duration;
  final double scaleFactor;
  final bool enableHaptics;

  const BounceButton({
    super.key,
    required this.child,
    this.onTap,
    this.duration = const Duration(milliseconds: 150),
    this.scaleFactor = 0.95,
    this.enableHaptics = true,
  });

  @override
  State<BounceButton> createState() => _BounceButtonState();
}

class _BounceButtonState extends State<BounceButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: widget.scaleFactor,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _controller.forward();
    if (widget.enableHaptics) {
      MicroInteractions.tapFeedback();
    }
  }

  void _onTapUp(TapUpDetails details) {
    _controller.reverse();
  }

  void _onTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: widget.child,
          );
        },
      ),
    );
  }
}

/// リップルエフェクト - タップ位置から広がる波紋
class RippleEffect extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final Color? rippleColor;
  final Duration duration;

  const RippleEffect({
    super.key,
    required this.child,
    this.onTap,
    this.rippleColor,
    this.duration = const Duration(milliseconds: 600),
  });

  @override
  State<RippleEffect> createState() => _RippleEffectState();
}

class _RippleEffectState extends State<RippleEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _radiusAnimation;
  late Animation<double> _opacityAnimation;

  Offset? _tapPosition;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);

    _radiusAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _opacityAnimation = Tween<double>(begin: 0.5, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    setState(() {
      _tapPosition = details.localPosition;
    });
    _controller.forward(from: 0.0);
    MicroInteractions.tapFeedback();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTap: widget.onTap,
      child: CustomPaint(
        painter: _RipplePainter(
          animation: _controller,
          radiusAnimation: _radiusAnimation,
          opacityAnimation: _opacityAnimation,
          tapPosition: _tapPosition,
          color: widget.rippleColor ??
              Theme.of(context).extension<MinqTheme>()!.brandPrimary,
        ),
        child: widget.child,
      ),
    );
  }
}

class _RipplePainter extends CustomPainter {
  final Animation<double> animation;
  final Animation<double> radiusAnimation;
  final Animation<double> opacityAnimation;
  final Offset? tapPosition;
  final Color color;

  _RipplePainter({
    required this.animation,
    required this.radiusAnimation,
    required this.opacityAnimation,
    required this.tapPosition,
    required this.color,
  }) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    if (tapPosition == null || animation.value == 0.0) return;

    final paint = Paint()
      ..color = color.withAlpha((255 * opacityAnimation.value).round())
      ..style = PaintingStyle.fill;

    final maxRadius = math.sqrt(
      size.width * size.width + size.height * size.height,
    );
    final radius = maxRadius * radiusAnimation.value;

    canvas.drawCircle(tapPosition!, radius, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/// 紙吹雪エフェクト - 成功時のお祝いアニメーション
class ConfettiEffect extends StatefulWidget {
  final Widget child;
  final bool isActive;
  final Duration duration;
  final int particleCount;

  const ConfettiEffect({
    super.key,
    required this.child,
    required this.isActive,
    this.duration = const Duration(milliseconds: 2000),
    this.particleCount = 50,
  });

  @override
  State<ConfettiEffect> createState() => _ConfettiEffectState();
}

class _ConfettiEffectState extends State<ConfettiEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<ConfettiParticle> _particles;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);

    _generateParticles();
  }

  @override
  void didUpdateWidget(ConfettiEffect oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      _generateParticles();
      _controller.forward(from: 0.0);
      MicroInteractions.successFeedback();
    }
  }

  void _generateParticles() {
    final random = math.Random();
    _particles = List.generate(widget.particleCount, (index) {
      return ConfettiParticle(
        x: random.nextDouble(),
        y: random.nextDouble() * 0.3,
        velocityX: (random.nextDouble() - 0.5) * 2,
        velocityY: random.nextDouble() * -5 - 2,
        color: _getRandomColor(random),
        size: random.nextDouble() * 8 + 4,
        rotation: random.nextDouble() * math.pi * 2,
        rotationSpeed: (random.nextDouble() - 0.5) * 10,
      );
    });
  }

  Color _getRandomColor(math.Random random) {
    final colors = [
      Colors.red,
      Colors.blue,
      Colors.green,
      Colors.yellow,
      Colors.purple,
      Colors.orange,
      Colors.pink,
      Colors.cyan,
    ];
    return colors[random.nextInt(colors.length)];
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (widget.isActive)
          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return CustomPaint(
                    painter: ConfettiPainter(
                      animation: _controller,
                      particles: _particles,
                    ),
                    size: Size.infinite,
                  );
                },
              ),
            ),
          ),
      ],
    );
  }
}

class ConfettiParticle {
  final double x;
  final double y;
  final double velocityX;
  final double velocityY;
  final Color color;
  final double size;
  final double rotation;
  final double rotationSpeed;

  ConfettiParticle({
    required this.x,
    required this.y,
    required this.velocityX,
    required this.velocityY,
    required this.color,
    required this.size,
    required this.rotation,
    required this.rotationSpeed,
  });
}

class ConfettiPainter extends CustomPainter {
  final Animation<double> animation;
  final List<ConfettiParticle> particles;

  ConfettiPainter({required this.animation, required this.particles})
    : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    for (final particle in particles) {
      final progress = animation.value;
      final gravity = 9.8 * progress * progress;

      final x = size.width * (particle.x + particle.velocityX * progress * 0.1);
      final y =
          size.height *
          (particle.y + particle.velocityY * progress * 0.1 + gravity * 0.1);

      // 画面外に出たら描画しない
      if (x < -particle.size ||
          x > size.width + particle.size ||
          y > size.height + particle.size) {
        continue;
      }

      paint.color = particle.color.withAlpha((255 * (1.0 - progress)).round());

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(particle.rotation + particle.rotationSpeed * progress);

      // 長方形の紙吹雪
      canvas.drawRect(
        Rect.fromCenter(
          center: Offset.zero,
          width: particle.size,
          height: particle.size * 0.6,
        ),
        paint,
      );

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/// カウントアップアニメーション - 数値が増加するアニメーション
class CountUpAnimation extends StatefulWidget {
  final int begin;
  final int end;
  final Duration duration;
  final TextStyle? style;
  final String? suffix;
  final String? prefix;

  const CountUpAnimation({
    super.key,
    required this.begin,
    required this.end,
    this.duration = const Duration(milliseconds: 1000),
    this.style,
    this.suffix,
    this.prefix,
  });

  @override
  State<CountUpAnimation> createState() => _CountUpAnimationState();
}

class _CountUpAnimationState extends State<CountUpAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);

    _animation = Tween<double>(
      begin: widget.begin.toDouble(),
      end: widget.end.toDouble(),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();
  }

  @override
  void didUpdateWidget(CountUpAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.end != oldWidget.end) {
      _animation = Tween<double>(
        begin: _animation.value,
        end: widget.end.toDouble(),
      ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
      _controller.forward(from: 0.0);
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
      animation: _animation,
      builder: (context, child) {
        final value = _animation.value.round();
        return Text(
          '${widget.prefix ?? ''}$value${widget.suffix ?? ''}',
          style: widget.style,
        );
      },
    );
  }
}

/// スパークルエフェクト - キラキラ光るアニメーション
class SparkleEffect extends StatefulWidget {
  final Widget child;
  final bool isActive;
  final Duration duration;
  final int sparkleCount;

  const SparkleEffect({
    super.key,
    required this.child,
    required this.isActive,
    this.duration = const Duration(milliseconds: 1500),
    this.sparkleCount = 8,
  });

  @override
  State<SparkleEffect> createState() => _SparkleEffectState();
}

class _SparkleEffectState extends State<SparkleEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<SparkleParticle> _sparkles;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);

    _generateSparkles();

    if (widget.isActive) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(SparkleEffect oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      _controller.repeat();
    } else if (!widget.isActive && oldWidget.isActive) {
      _controller.stop();
    }
  }

  void _generateSparkles() {
    final random = math.Random();
    _sparkles = List.generate(widget.sparkleCount, (index) {
      return SparkleParticle(
        x: random.nextDouble(),
        y: random.nextDouble(),
        delay: random.nextDouble(),
        size: random.nextDouble() * 8 + 4,
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (widget.isActive)
          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return CustomPaint(
                    painter: SparklePainter(
                      animation: _controller,
                      sparkles: _sparkles,
                    ),
                    size: Size.infinite,
                  );
                },
              ),
            ),
          ),
      ],
    );
  }
}

class SparkleParticle {
  final double x;
  final double y;
  final double delay;
  final double size;

  SparkleParticle({
    required this.x,
    required this.y,
    required this.delay,
    required this.size,
  });
}

class SparklePainter extends CustomPainter {
  final Animation<double> animation;
  final List<SparkleParticle> sparkles;

  SparklePainter({required this.animation, required this.sparkles})
    : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.fill;

    for (final sparkle in sparkles) {
      final progress = (animation.value + sparkle.delay) % 1.0;
      final opacity = math.sin(progress * math.pi);

      if (opacity <= 0) continue;

      paint.color = Colors.white.withAlpha((255 * opacity * 0.8).round());

      final x = size.width * sparkle.x;
      final y = size.height * sparkle.y;

      _drawSparkle(canvas, Offset(x, y), sparkle.size, paint);
    }
  }

  void _drawSparkle(Canvas canvas, Offset center, double size, Paint paint) {
    final path = Path();

    // 4方向の星形
    path.moveTo(center.dx, center.dy - size);
    path.lineTo(center.dx + size * 0.3, center.dy - size * 0.3);
    path.lineTo(center.dx + size, center.dy);
    path.lineTo(center.dx + size * 0.3, center.dy + size * 0.3);
    path.lineTo(center.dx, center.dy + size);
    path.lineTo(center.dx - size * 0.3, center.dy + size * 0.3);
    path.lineTo(center.dx - size, center.dy);
    path.lineTo(center.dx - size * 0.3, center.dy - size * 0.3);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
