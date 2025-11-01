import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:minq/core/animations/animation_system.dart';

/// パーティクルシステム（要件46、47、48）
class ParticleSystem extends StatefulWidget {
  final ParticleConfig config;
  final bool isActive;
  final Widget? child;

  const ParticleSystem({
    super.key,
    required this.config,
    this.isActive = true,
    this.child,
  });

  @override
  State<ParticleSystem> createState() => _ParticleSystemState();
}

class _ParticleSystemState extends State<ParticleSystem>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  final List<Particle> _particles = [];
  final math.Random _random = math.Random();

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: widget.config.duration,
      vsync: this,
    );

    _initializeParticles();

    if (widget.isActive && AnimationSystem.instance.animationsEnabled) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(ParticleSystem oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isActive != oldWidget.isActive) {
      if (widget.isActive && AnimationSystem.instance.animationsEnabled) {
        _controller.repeat();
      } else {
        _controller.stop();
      }
    }
  }

  void _initializeParticles() {
    _particles.clear();

    for (int i = 0; i < widget.config.particleCount; i++) {
      _particles.add(_createParticle());
    }
  }

  Particle _createParticle() {
    final angle = _random.nextDouble() * 2 * math.pi;
    final speed =
        widget.config.minSpeed +
        _random.nextDouble() *
            (widget.config.maxSpeed - widget.config.minSpeed);
    final size =
        widget.config.minSize +
        _random.nextDouble() * (widget.config.maxSize - widget.config.minSize);
    final life =
        widget.config.minLife +
        _random.nextDouble() * (widget.config.maxLife - widget.config.minLife);

    return Particle(
      position: Offset.zero,
      velocity: Offset(math.cos(angle) * speed, math.sin(angle) * speed),
      size: size,
      color: widget.config.colors[_random.nextInt(widget.config.colors.length)],
      life: life,
      maxLife: life,
      shape: widget.config.shapes[_random.nextInt(widget.config.shapes.length)],
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!AnimationSystem.instance.animationsEnabled) {
      return widget.child ?? const SizedBox.shrink();
    }

    return Stack(
      children: [
        if (widget.child != null) widget.child!,
        Positioned.fill(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return CustomPaint(
                painter: ParticlePainter(
                  particles: _particles,
                  progress: _controller.value,
                  config: widget.config,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

/// パーティクル設定
class ParticleConfig {
  final int particleCount;
  final double minSpeed;
  final double maxSpeed;
  final double minSize;
  final double maxSize;
  final double minLife;
  final double maxLife;
  final List<Color> colors;
  final List<ParticleShape> shapes;
  final Duration duration;
  final ParticleEmissionType emissionType;
  final Offset emissionPoint;
  final double emissionRadius;
  final bool fadeOut;
  final bool gravity;
  final double gravityStrength;

  const ParticleConfig({
    this.particleCount = 50,
    this.minSpeed = 20.0,
    this.maxSpeed = 100.0,
    this.minSize = 2.0,
    this.maxSize = 8.0,
    this.minLife = 1.0,
    this.maxLife = 3.0,
    this.colors = const [Colors.blue, Colors.cyan, Colors.lightBlue],
    this.shapes = const [ParticleShape.circle],
    this.duration = const Duration(seconds: 2),
    this.emissionType = ParticleEmissionType.burst,
    this.emissionPoint = Offset.zero,
    this.emissionRadius = 0.0,
    this.fadeOut = true,
    this.gravity = false,
    this.gravityStrength = 50.0,
  });

  /// XP獲得用のパーティクル設定
  static ParticleConfig xpGain() => const ParticleConfig(
    particleCount: 30,
    minSpeed: 30.0,
    maxSpeed: 80.0,
    minSize: 3.0,
    maxSize: 6.0,
    minLife: 1.5,
    maxLife: 2.5,
    colors: [
      Color(0xFFFFD700), // Gold
      Color(0xFFFFA500), // Orange
      Color(0xFFFF6B35), // Red-Orange
    ],
    shapes: [ParticleShape.star, ParticleShape.circle],
    duration: Duration(milliseconds: 2000),
    emissionType: ParticleEmissionType.burst,
    fadeOut: true,
  );

  /// レベルアップ用のパーティクル設定
  static ParticleConfig levelUp() => const ParticleConfig(
    particleCount: 100,
    minSpeed: 50.0,
    maxSpeed: 150.0,
    minSize: 4.0,
    maxSize: 12.0,
    minLife: 2.0,
    maxLife: 4.0,
    colors: [
      Color(0xFFFFD700), // Gold
      Color(0xFFFFE55C), // Light Gold
      Color(0xFFFFF8DC), // Cornsilk
      Color(0xFFFFFFFF), // White
    ],
    shapes: [ParticleShape.star, ParticleShape.diamond, ParticleShape.circle],
    duration: Duration(milliseconds: 3000),
    emissionType: ParticleEmissionType.fountain,
    fadeOut: true,
    gravity: true,
    gravityStrength: 30.0,
  );

  /// 成功時のパーティクル設定
  static ParticleConfig success() => const ParticleConfig(
    particleCount: 40,
    minSpeed: 40.0,
    maxSpeed: 100.0,
    minSize: 2.0,
    maxSize: 8.0,
    minLife: 1.0,
    maxLife: 2.0,
    colors: [
      Color(0xFF10B981), // Success Green
      Color(0xFF34D399), // Light Green
      Color(0xFF6EE7B7), // Very Light Green
    ],
    shapes: [ParticleShape.circle, ParticleShape.heart],
    duration: Duration(milliseconds: 1500),
    emissionType: ParticleEmissionType.burst,
    fadeOut: true,
  );

  /// 祝福用のパーティクル設定
  static ParticleConfig celebration() => const ParticleConfig(
    particleCount: 80,
    minSpeed: 60.0,
    maxSpeed: 120.0,
    minSize: 3.0,
    maxSize: 10.0,
    minLife: 2.0,
    maxLife: 3.5,
    colors: [
      Color(0xFFFF6B6B), // Red
      Color(0xFF4ECDC4), // Teal
      Color(0xFF45B7D1), // Blue
      Color(0xFF96CEB4), // Green
      Color(0xFFFECA57), // Yellow
      Color(0xFFFF9FF3), // Pink
    ],
    shapes: [
      ParticleShape.circle,
      ParticleShape.star,
      ParticleShape.diamond,
      ParticleShape.heart,
    ],
    duration: Duration(milliseconds: 4000),
    emissionType: ParticleEmissionType.continuous,
    fadeOut: true,
    gravity: true,
    gravityStrength: 20.0,
  );
}

/// パーティクルクラス
class Particle {
  Offset position;
  Offset velocity;
  double size;
  Color color;
  double life;
  double maxLife;
  ParticleShape shape;

  Particle({
    required this.position,
    required this.velocity,
    required this.size,
    required this.color,
    required this.life,
    required this.maxLife,
    required this.shape,
  });

  void update(double deltaTime, ParticleConfig config) {
    // 位置の更新
    position += velocity * deltaTime;

    // 重力の適用
    if (config.gravity) {
      velocity = Offset(
        velocity.dx,
        velocity.dy + config.gravityStrength * deltaTime,
      );
    }

    // ライフの減少
    life -= deltaTime;
  }

  bool get isAlive => life > 0;

  double get opacity {
    if (life <= 0) return 0.0;
    return (life / maxLife).clamp(0.0, 1.0);
  }
}

/// パーティクル形状
enum ParticleShape { circle, star, diamond, heart, square }

/// パーティクル放出タイプ
enum ParticleEmissionType {
  burst, // 一度に全て放出
  fountain, // 噴水のように上向きに放出
  continuous, // 継続的に放出
}

/// パーティクルペインター
class ParticlePainter extends CustomPainter {
  final List<Particle> particles;
  final double progress;
  final ParticleConfig config;
  final math.Random _random = math.Random();

  ParticlePainter({
    required this.particles,
    required this.progress,
    required this.config,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;

    // パーティクルの更新と描画
    for (int i = 0; i < particles.length; i++) {
      final particle = particles[i];

      // パーティクルの初期化（放出タイプに応じて）
      if (particle.position == Offset.zero) {
        _initializeParticlePosition(particle, centerX, centerY);
      }

      // パーティクルの更新
      particle.update(1.0 / 60.0, config); // 60FPS想定

      // パーティクルが死んだら再生成
      if (!particle.isAlive) {
        particles[i] = _createNewParticle(centerX, centerY);
        continue;
      }

      // パーティクルの描画
      _drawParticle(canvas, particle);
    }
  }

  void _initializeParticlePosition(
    Particle particle,
    double centerX,
    double centerY,
  ) {
    switch (config.emissionType) {
      case ParticleEmissionType.burst:
        particle.position = Offset(centerX, centerY);
        break;

      case ParticleEmissionType.fountain:
        final offsetX = (_random.nextDouble() - 0.5) * 20;
        particle.position = Offset(centerX + offsetX, centerY);
        // 上向きの速度に調整
        particle.velocity = Offset(
          particle.velocity.dx * 0.3,
          -particle.velocity.dy.abs(),
        );
        break;

      case ParticleEmissionType.continuous:
        final angle = _random.nextDouble() * 2 * math.pi;
        final radius = _random.nextDouble() * config.emissionRadius;
        particle.position = Offset(
          centerX + radius * math.cos(angle),
          centerY + radius * math.sin(angle),
        );
        break;
    }
  }

  Particle _createNewParticle(double centerX, double centerY) {
    final angle = _random.nextDouble() * 2 * math.pi;
    final speed =
        config.minSpeed +
        _random.nextDouble() * (config.maxSpeed - config.minSpeed);
    final size =
        config.minSize +
        _random.nextDouble() * (config.maxSize - config.minSize);
    final life =
        config.minLife +
        _random.nextDouble() * (config.maxLife - config.minLife);

    final particle = Particle(
      position: Offset.zero,
      velocity: Offset(math.cos(angle) * speed, math.sin(angle) * speed),
      size: size,
      color: config.colors[_random.nextInt(config.colors.length)],
      life: life,
      maxLife: life,
      shape: config.shapes[_random.nextInt(config.shapes.length)],
    );

    _initializeParticlePosition(particle, centerX, centerY);
    return particle;
  }

  void _drawParticle(Canvas canvas, Particle particle) {
    final paint =
        Paint()
          ..color = particle.color.withOpacity(
            config.fadeOut ? particle.opacity : 1.0,
          )
          ..style = PaintingStyle.fill;

    switch (particle.shape) {
      case ParticleShape.circle:
        canvas.drawCircle(particle.position, particle.size, paint);
        break;

      case ParticleShape.star:
        _drawStar(canvas, particle.position, particle.size, paint);
        break;

      case ParticleShape.diamond:
        _drawDiamond(canvas, particle.position, particle.size, paint);
        break;

      case ParticleShape.heart:
        _drawHeart(canvas, particle.position, particle.size, paint);
        break;

      case ParticleShape.square:
        canvas.drawRect(
          Rect.fromCenter(
            center: particle.position,
            width: particle.size * 2,
            height: particle.size * 2,
          ),
          paint,
        );
        break;
    }
  }

  void _drawStar(Canvas canvas, Offset center, double size, Paint paint) {
    final path = Path();
    const numPoints = 5;
    const outerRadius = 1.0;
    const innerRadius = 0.4;

    for (int i = 0; i < numPoints * 2; i++) {
      final angle = (i * math.pi) / numPoints - math.pi / 2;
      final radius = (i % 2 == 0) ? outerRadius : innerRadius;
      final x = center.dx + size * radius * math.cos(angle);
      final y = center.dy + size * radius * math.sin(angle);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();

    canvas.drawPath(path, paint);
  }

  void _drawDiamond(Canvas canvas, Offset center, double size, Paint paint) {
    final path =
        Path()
          ..moveTo(center.dx, center.dy - size)
          ..lineTo(center.dx + size, center.dy)
          ..lineTo(center.dx, center.dy + size)
          ..lineTo(center.dx - size, center.dy)
          ..close();

    canvas.drawPath(path, paint);
  }

  void _drawHeart(Canvas canvas, Offset center, double size, Paint paint) {
    final path = Path();

    // ハート形状の描画
    final heartSize = size * 0.8;
    path.moveTo(center.dx, center.dy + heartSize * 0.3);

    // 左の曲線
    path.cubicTo(
      center.dx - heartSize * 0.5,
      center.dy - heartSize * 0.3,
      center.dx - heartSize,
      center.dy - heartSize * 0.1,
      center.dx - heartSize * 0.5,
      center.dy + heartSize * 0.1,
    );

    // 中央下部
    path.lineTo(center.dx, center.dy + heartSize * 0.7);

    // 右の曲線
    path.lineTo(center.dx + heartSize * 0.5, center.dy + heartSize * 0.1);
    path.cubicTo(
      center.dx + heartSize,
      center.dy - heartSize * 0.1,
      center.dx + heartSize * 0.5,
      center.dy - heartSize * 0.3,
      center.dx,
      center.dy + heartSize * 0.3,
    );

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(ParticlePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

/// パーティクルエフェクトウィジェット
class ParticleEffect extends StatefulWidget {
  final ParticleConfig config;
  final bool autoStart;
  final VoidCallback? onComplete;

  const ParticleEffect({
    super.key,
    required this.config,
    this.autoStart = true,
    this.onComplete,
  });

  @override
  State<ParticleEffect> createState() => _ParticleEffectState();
}

class _ParticleEffectState extends State<ParticleEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: widget.config.duration,
      vsync: this,
    );

    if (widget.autoStart) {
      start();
    }
  }

  void start() {
    if (AnimationSystem.instance.animationsEnabled) {
      _controller.forward().then((_) {
        if (widget.onComplete != null) {
          widget.onComplete!();
        }
      });
    } else if (widget.onComplete != null) {
      widget.onComplete!();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ParticleSystem(
      config: widget.config,
      isActive: _controller.isAnimating,
    );
  }
}
