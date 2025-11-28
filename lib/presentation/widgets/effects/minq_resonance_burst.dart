import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:minq/presentation/theme/minq_theme.dart';

class MinqResonanceBurst extends StatefulWidget {
  const MinqResonanceBurst({
    super.key,
    required this.onComplete,
    this.size = 300.0,
  });

  final VoidCallback onComplete;
  final double size;

  @override
  State<MinqResonanceBurst> createState() => _MinqResonanceBurstState();
}

class _MinqResonanceBurstState extends State<MinqResonanceBurst>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<_Particle> _particles;
  final math.Random _random = math.Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onComplete();
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _initializeParticles();
    _controller.forward();
  }

  void _initializeParticles() {
    final tokens = context.tokens;
    final colors = [
      tokens.joyAccent,
      tokens.encouragement,
      tokens.brandPrimary,
    ];

    _particles = List.generate(24, (index) {
      final angle = (index / 24) * 2 * math.pi;
      final speed = 2.0 + _random.nextDouble() * 3.0;
      // Add some randomness to angle
      final randomAngle = angle + (_random.nextDouble() - 0.5) * 0.5;

      return _Particle(
        color: colors[_random.nextInt(colors.length)],
        angle: randomAngle,
        speed: speed,
        size: 4.0 + _random.nextDouble() * 4.0,
        type: _random.nextBool() ? _ParticleType.circle : _ParticleType.cross,
        initialDistance: 20.0,
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
    return IgnorePointer(
      child: Center(
        child: SizedBox(
          width: widget.size,
          height: widget.size,
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return CustomPaint(
                painter: _BurstPainter(
                  progress: _controller.value,
                  particles: _particles,
                  rippleColor: context.tokens.brandPrimary,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

enum _ParticleType { circle, cross }

class _Particle {
  _Particle({
    required this.color,
    required this.angle,
    required this.speed,
    required this.size,
    required this.type,
    required this.initialDistance,
  });

  final Color color;
  final double angle;
  final double speed;
  final double size;
  final _ParticleType type;
  final double initialDistance;
}

class _BurstPainter extends CustomPainter {
  _BurstPainter({
    required this.progress,
    required this.particles,
    required this.rippleColor,
  });

  final double progress;
  final List<_Particle> particles;
  final Color rippleColor;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = size.width / 2;

    // 1. Draw Resonance Ripple (Shockwave)
    // Easing for ripple: expand fast then slow
    final rippleProgress = CurveTween(curve: Curves.easeOutQuart).transform(progress);
    final rippleOpacity = 1.0 - rippleProgress;

    if (rippleOpacity > 0) {
      final ripplePaint = Paint()
        ..color = rippleColor.withOpacity(rippleOpacity * 0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4.0 * (1.0 - rippleProgress);

      canvas.drawCircle(center, maxRadius * rippleProgress, ripplePaint);

      // Secondary ripple (smaller, faster)
      if (progress > 0.1) {
         final secondaryProgress = (progress - 0.1) / 0.9;
         final secondaryEase = CurveTween(curve: Curves.easeOutCirc).transform(secondaryProgress);
         final secondaryOpacity = 1.0 - secondaryProgress;

         final secondaryPaint = Paint()
           ..color = rippleColor.withOpacity(secondaryOpacity * 0.2)
           ..style = PaintingStyle.stroke
           ..strokeWidth = 2.0;

         canvas.drawCircle(center, (maxRadius * 0.7) * secondaryEase, secondaryPaint);
      }
    }

    // 2. Draw Particles
    // Easing for particles: explode out
    final particleProgress = CurveTween(curve: Curves.easeOutBack).transform(progress);

    for (final particle in particles) {
      final distance = particle.initialDistance + (maxRadius * 0.8 * particleProgress * particle.speed * 0.3);
      final dx = center.dx + math.cos(particle.angle) * distance;
      final dy = center.dy + math.sin(particle.angle) * distance;

      // Fade out particles at the end
      final particleOpacity = (1.0 - progress).clamp(0.0, 1.0);
      if (particleOpacity <= 0) continue;

      final paint = Paint()
        ..color = particle.color.withOpacity(particleOpacity)
        ..style = PaintingStyle.fill;

      canvas.save();
      canvas.translate(dx, dy);

      // Rotate particles slightly as they fly
      canvas.rotate(progress * math.pi);

      if (particle.type == _ParticleType.circle) {
        canvas.drawCircle(Offset.zero, particle.size / 2, paint);
      } else {
        // Draw Cross
        final crossSize = particle.size;
        final strokePaint = Paint()
          ..color = particle.color.withOpacity(particleOpacity)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0
          ..strokeCap = StrokeCap.round;

        canvas.drawLine(
          Offset(-crossSize / 2, 0),
          Offset(crossSize / 2, 0),
          strokePaint,
        );
        canvas.drawLine(
          Offset(0, -crossSize / 2),
          Offset(0, crossSize / 2),
          strokePaint,
        );
      }

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_BurstPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
