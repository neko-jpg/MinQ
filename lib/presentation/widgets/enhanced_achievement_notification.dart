import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:minq/core/audio/sound_effects_service.dart';
import 'package:minq/domain/gamification/badge.dart' as gamification;
import 'package:minq/presentation/theme/haptics_system.dart';
import 'package:minq/presentation/theme/minq_theme.dart';

/// Enhanced achievement notification with sophisticated animations and feedback
class EnhancedAchievementNotification extends StatefulWidget {
  const EnhancedAchievementNotification({
    super.key,
    required this.badge,
    required this.onDismiss,
    this.duration = const Duration(seconds: 5),
    this.showConfetti = true,
  });

  final gamification.Badge badge;
  final VoidCallback onDismiss;
  final Duration duration;
  final bool showConfetti;

  @override
  State<EnhancedAchievementNotification> createState() =>
      _EnhancedAchievementNotificationState();
}

class _EnhancedAchievementNotificationState
    extends State<EnhancedAchievementNotification>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _scaleController;
  late AnimationController _confettiController;
  late AnimationController _glowController;
  late AnimationController _textController;

  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _confettiAnimation;
  late Animation<double> _glowAnimation;
  late Animation<double> _textAnimation;

  @override
  void initState() {
    super.initState();

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _confettiController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _glowController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _textController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.elasticOut),
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 1.3),
        weight: 60,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.3, end: 1.0),
        weight: 40,
      ),
    ]).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );

    _confettiAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _confettiController, curve: Curves.easeOut),
    );

    _glowAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    _textAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _textController,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
      ),
    );

    _startAnimation();
  }

  void _startAnimation() async {
    // Enhanced haptic feedback sequence
    await HapticsSystem.customPattern([
      const HapticEvent(type: HapticType.medium),
      const HapticEvent(type: HapticType.light, delay: Duration(milliseconds: 100)),
      const HapticEvent(type: HapticType.heavy, delay: Duration(milliseconds: 200)),
    ]);

    // Play achievement sound
    await SoundEffectsService.instance.play(SoundType.achievement);

    // Start animations in sequence
    _slideController.forward();
    
    await Future.delayed(const Duration(milliseconds: 200));
    _scaleController.forward();
    _textController.forward();
    
    if (widget.showConfetti) {
      _confettiController.forward();
    }
    
    _glowController.repeat(reverse: true);

    // Auto dismiss timer
    Future.delayed(widget.duration, () {
      if (mounted) {
        _dismiss();
      }
    });
  }

  void _dismiss() async {
    _glowController.stop();
    await _slideController.reverse();
    widget.onDismiss();
  }

  @override
  void dispose() {
    _slideController.dispose();
    _scaleController.dispose();
    _confettiController.dispose();
    _glowController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<MinqTheme>()!;

    return SlideTransition(
      position: _slideAnimation,
      child: Container(
        margin: EdgeInsets.all(tokens.spacing.lg),
        child: Material(
          elevation: 16,
          borderRadius: BorderRadius.circular(tokens.radius.xl),
          child: AnimatedBuilder(
            animation: _glowAnimation,
            builder: (context, child) {
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      tokens.brandPrimary,
                      tokens.brandSecondary,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(tokens.radius.xl),
                  boxShadow: [
                    BoxShadow(
                      color: tokens.brandPrimary.withAlpha(
                        (128 + 64 * _glowAnimation.value).round(),
                      ),
                      blurRadius: 20 + 10 * _glowAnimation.value,
                      spreadRadius: 2 + 4 * _glowAnimation.value,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    // Confetti effect
                    if (widget.showConfetti)
                      Positioned.fill(
                        child: AnimatedBuilder(
                          animation: _confettiAnimation,
                          builder: (context, child) {
                            return CustomPaint(
                              painter: EnhancedConfettiPainter(
                                animation: _confettiAnimation.value,
                                colors: [
                                  Colors.white,
                                  Colors.yellow.shade300,
                                  Colors.orange.shade300,
                                  Colors.pink.shade300,
                                ],
                              ),
                            );
                          },
                        ),
                      ),

                    // Main content
                    Padding(
                      padding: EdgeInsets.all(tokens.spacing.lg),
                      child: Row(
                        children: [
                          // Badge icon with scale animation
                          ScaleTransition(
                            scale: _scaleAnimation,
                            child: Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: Colors.white.withAlpha(51),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white.withAlpha(102),
                                  width: 3,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.white.withAlpha(77),
                                    blurRadius: 12,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: Stack(
                                children: [
                                  Center(
                                    child: _getBadgeIcon(widget.badge.id),
                                  ),
                                  // Sparkle overlay
                                  AnimatedBuilder(
                                    animation: _glowAnimation,
                                    builder: (context, child) {
                                      return CustomPaint(
                                        size: const Size(80, 80),
                                        painter: SparkleOverlayPainter(
                                          animation: _glowAnimation.value,
                                          color: Colors.white.withAlpha(128),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),

                          SizedBox(width: tokens.spacing.lg),

                          // Text content with fade animation
                          Expanded(
                            child: FadeTransition(
                              opacity: _textAnimation,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    '🎉 バッジ獲得！',
                                    style: tokens.typography.caption.copyWith(
                                      color: Colors.white.withAlpha(230),
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  SizedBox(height: tokens.spacing.xs),
                                  Text(
                                    widget.badge.name,
                                    style: tokens.typography.h3.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      height: 1.2,
                                    ),
                                  ),
                                  SizedBox(height: tokens.spacing.xs),
                                  Text(
                                    widget.badge.description,
                                    style: tokens.typography.body.copyWith(
                                      color: Colors.white.withAlpha(204),
                                      height: 1.3,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // Close button
                          GestureDetector(
                            onTap: () async {
                              await HapticsSystem.lightImpact();
                              _dismiss();
                            },
                            child: Container(
                              padding: EdgeInsets.all(tokens.spacing.sm),
                              decoration: BoxDecoration(
                                color: Colors.white.withAlpha(51),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.close,
                                color: Colors.white.withAlpha(204),
                                size: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _getBadgeIcon(String badgeId) {
    IconData iconData;
    Color iconColor = Colors.white;

    switch (badgeId) {
      case 'quest_master_1':
        iconData = Icons.star;
        break;
      case 'quest_master_5':
        iconData = Icons.local_florist;
        break;
      case 'quest_master_10':
        iconData = Icons.eco;
        break;
      case 'quest_master_25':
        iconData = Icons.park;
        break;
      case 'quest_master_50':
        iconData = Icons.forest;
        break;
      case 'quest_master_100':
        iconData = Icons.nature;
        break;
      case 'streak_master_3':
        iconData = Icons.local_fire_department;
        break;
      case 'streak_master_7':
        iconData = Icons.whatshot;
        break;
      case 'streak_master_14':
        iconData = Icons.fireplace;
        break;
      case 'streak_master_30':
        iconData = Icons.flare;
        break;
      case 'streak_master_100':
        iconData = Icons.auto_awesome;
        break;
      case 'early_bird':
        iconData = Icons.wb_sunny;
        break;
      case 'night_owl':
        iconData = Icons.nightlight;
        break;
      case 'comeback_hero':
        iconData = Icons.trending_up;
        break;
      case 'weekend_warrior':
        iconData = Icons.weekend;
        break;
      default:
        iconData = Icons.military_tech;
    }

    return Icon(iconData, color: iconColor, size: 40);
  }
}

/// Enhanced confetti painter with multiple particle types
class EnhancedConfettiPainter extends CustomPainter {
  final double animation;
  final List<Color> colors;
  final List<ConfettiParticle> particles;

  EnhancedConfettiPainter({
    required this.animation,
    required this.colors,
  }) : particles = _generateParticles(colors);

  static List<ConfettiParticle> _generateParticles(List<Color> colors) {
    final random = math.Random();
    final particles = <ConfettiParticle>[];

    for (int i = 0; i < 60; i++) {
      particles.add(
        ConfettiParticle(
          x: random.nextDouble(),
          y: -0.1 - random.nextDouble() * 0.2,
          vx: (random.nextDouble() - 0.5) * 3,
          vy: 2 + random.nextDouble() * 3,
          rotation: random.nextDouble() * math.pi * 2,
          rotationSpeed: (random.nextDouble() - 0.5) * 8,
          color: colors[random.nextInt(colors.length)],
          size: 3 + random.nextDouble() * 6,
          shape: ParticleShape.values[random.nextInt(ParticleShape.values.length)],
        ),
      );
    }

    return particles;
  }

  @override
  void paint(Canvas canvas, Size size) {
    for (final particle in particles) {
      particle.paint(canvas, size, animation);
    }
  }

  @override
  bool shouldRepaint(covariant EnhancedConfettiPainter oldDelegate) {
    return oldDelegate.animation != animation;
  }
}

/// Sparkle overlay painter for badge icon
class SparkleOverlayPainter extends CustomPainter {
  final double animation;
  final Color color;

  SparkleOverlayPainter({required this.animation, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withAlpha((255 * animation * 0.8).round())
      ..style = PaintingStyle.fill;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Draw rotating sparkles
    for (int i = 0; i < 6; i++) {
      final angle = (animation * math.pi * 2) + (i * math.pi / 3);
      final sparkleRadius = radius * 0.7;
      final sparkleCenter = Offset(
        center.dx + sparkleRadius * math.cos(angle),
        center.dy + sparkleRadius * math.sin(angle),
      );

      final sparkleSize = 3 + 2 * math.sin(animation * math.pi * 4 + i);
      _drawSparkle(canvas, sparkleCenter, sparkleSize, paint);
    }
  }

  void _drawSparkle(Canvas canvas, Offset center, double size, Paint paint) {
    final path = Path();

    // Draw a 4-pointed star
    for (int i = 0; i < 8; i++) {
      final angle = (i * 45) * (math.pi / 180);
      final radius = (i % 2 == 0) ? size : size * 0.4;
      final x = center.dx + radius * math.cos(angle);
      final y = center.dy + radius * math.sin(angle);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant SparkleOverlayPainter oldDelegate) {
    return oldDelegate.animation != animation;
  }
}

/// Enhanced confetti particle with different shapes
class ConfettiParticle {
  final double x;
  final double y;
  final double vx;
  final double vy;
  final double rotation;
  final double rotationSpeed;
  final Color color;
  final double size;
  final ParticleShape shape;

  ConfettiParticle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.rotation,
    required this.rotationSpeed,
    required this.color,
    required this.size,
    required this.shape,
  });

  void paint(Canvas canvas, Size size, double progress) {
    final currentX = size.width * (x + vx * progress * 0.1);
    final currentY = size.height * (y + vy * progress * 0.1);
    final currentRotation = rotation + rotationSpeed * progress;

    // Don't draw particles that are off screen
    if (currentY > size.height + 20) return;

    final paint = Paint()
      ..color = color.withAlpha(((1.0 - progress * 0.7) * 255).round())
      ..style = PaintingStyle.fill;

    canvas.save();
    canvas.translate(currentX, currentY);
    canvas.rotate(currentRotation);

    switch (shape) {
      case ParticleShape.rectangle:
        canvas.drawRect(
          Rect.fromCenter(
            center: Offset.zero,
            width: this.size,
            height: this.size * 1.5,
          ),
          paint,
        );
        break;
      case ParticleShape.circle:
        canvas.drawCircle(Offset.zero, this.size / 2, paint);
        break;
      case ParticleShape.triangle:
        final path = Path();
        path.moveTo(0, -this.size / 2);
        path.lineTo(-this.size / 2, this.size / 2);
        path.lineTo(this.size / 2, this.size / 2);
        path.close();
        canvas.drawPath(path, paint);
        break;
      case ParticleShape.star:
        _drawStar(canvas, this.size / 2, paint);
        break;
    }

    canvas.restore();
  }

  void _drawStar(Canvas canvas, double radius, Paint paint) {
    final path = Path();
    for (int i = 0; i < 10; i++) {
      final angle = (i * 36) * (math.pi / 180);
      final r = (i % 2 == 0) ? radius : radius * 0.5;
      final x = r * math.cos(angle - math.pi / 2);
      final y = r * math.sin(angle - math.pi / 2);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }
}

enum ParticleShape { rectangle, circle, triangle, star }

/// Enhanced achievement notification overlay
class EnhancedAchievementOverlay {
  static OverlayEntry? _currentEntry;

  /// Show enhanced achievement notification
  static void show(
    BuildContext context,
    gamification.Badge badge, {
    bool showConfetti = true,
  }) {
    // Remove existing notification
    hide();

    _currentEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).padding.top + 16,
        left: 0,
        right: 0,
        child: EnhancedAchievementNotification(
          badge: badge,
          onDismiss: hide,
          showConfetti: showConfetti,
        ),
      ),
    );

    Overlay.of(context).insert(_currentEntry!);
  }

  /// Hide achievement notification
  static void hide() {
    _currentEntry?.remove();
    _currentEntry = null;
  }
}