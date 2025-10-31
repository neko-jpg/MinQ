import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:minq/core/gamification/league_system.dart';
import 'package:minq/domain/gamification/league.dart';

/// Full-screen league promotion animation
class LeaguePromotionAnimation extends StatefulWidget {
  final LeaguePromotion promotion;
  final VoidCallback? onComplete;

  const LeaguePromotionAnimation({
    super.key,
    required this.promotion,
    this.onComplete,
  });

  @override
  State<LeaguePromotionAnimation> createState() => _LeaguePromotionAnimationState();
}

class _LeaguePromotionAnimationState extends State<LeaguePromotionAnimation>
    with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _particleController;
  late AnimationController _textController;
  
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _particleAnimation;

  @override
  void initState() {
    super.initState();
    
    _mainController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );
    
    _particleController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    _textController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _setupAnimations();
    _startAnimation();
  }

  void _setupAnimations() {
    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _mainController,
      curve: const Interval(0.0, 0.4, curve: Curves.elasticOut),
    ));

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 2 * math.pi,
    ).animate(CurvedAnimation(
      parent: _mainController,
      curve: const Interval(0.2, 0.8, curve: Curves.easeInOut),
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _textController,
      curve: Curves.easeIn,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _textController,
      curve: Curves.elasticOut,
    ));

    _particleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _particleController,
      curve: Curves.easeOut,
    ));
  }

  void _startAnimation() async {
    // Haptic feedback
    HapticFeedback.heavyImpact();
    
    // Start main animation
    _mainController.forward();
    
    // Start particle animation after a delay
    await Future.delayed(const Duration(milliseconds: 500));
    _particleController.forward();
    
    // Start text animation
    await Future.delayed(const Duration(milliseconds: 800));
    _textController.forward();
    
    // Complete after all animations
    await Future.delayed(const Duration(milliseconds: 4000));
    if (widget.onComplete != null) {
      widget.onComplete!();
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
    final fromLeague = LeagueSystem.leagues[widget.promotion.fromLeague];
    final toLeague = LeagueSystem.leagues[widget.promotion.toLeague];

    if (fromLeague == null || toLeague == null) {
      return const SizedBox.shrink();
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 1.0,
                colors: [
                  toLeague.color.withOpacity(0.3),
                  Colors.black,
                ],
              ),
            ),
          ),

          // Particle effects
          AnimatedBuilder(
            animation: _particleAnimation,
            builder: (context, child) {
              return CustomPaint(
                painter: ParticlesPainter(
                  animation: _particleAnimation,
                  color: toLeague.color,
                ),
                size: Size.infinite,
              );
            },
          ),

          // Main content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // League badge animation
                AnimatedBuilder(
                  animation: _mainController,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _scaleAnimation.value,
                      child: Transform.rotate(
                        angle: _rotationAnimation.value,
                        child: Container(
                          width: 150,
                          height: 150,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: toLeague.gradientColors,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: toLeague.color.withOpacity(0.5),
                                blurRadius: 30,
                                spreadRadius: 10,
                              ),
                            ],
                          ),
                          child: Icon(
                            toLeague.icon,
                            size: 80,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 40),

                // Promotion text
                AnimatedBuilder(
                  animation: _textController,
                  builder: (context, child) {
                    return SlideTransition(
                      position: _slideAnimation,
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: Column(
                          children: [
                            Text(
                              'おめでとうございます！',
                              style: context.textTheme.headlineMedium?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            
                            const SizedBox(height: 16),
                            
                            RichText(
                              textAlign: TextAlign.center,
                              text: TextSpan(
                                style: context.textTheme.titleLarge?.copyWith(
                                  color: Colors.white,
                                ),
                                children: [
                                  TextSpan(text: fromLeague.name),
                                  const TextSpan(text: ' から '),
                                  TextSpan(
                                    text: toLeague.name,
                                    style: TextStyle(
                                      color: toLeague.color,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const TextSpan(text: ' に昇格しました！'),
                                ],
                              ),
                            ),
                            
                            const SizedBox(height: 24),
                            
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: toLeague.color.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: toLeague.color,
                                  width: 2,
                                ),
                              ),
                              child: Text(
                                '獲得XP: ${widget.promotion.xpEarned}',
                                style: context.textTheme.titleMedium?.copyWith(
                                  color: toLeague.color,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 60),

                // Rewards section
                AnimatedBuilder(
                  animation: _textController,
                  builder: (context, child) {
                    return FadeTransition(
                      opacity: _fadeAnimation,
                      child: _buildRewardsSection(context, toLeague),
                    );
                  },
                ),
              ],
            ),
          ),

          // Skip button
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            right: 16,
            child: IconButton(
              onPressed: widget.onComplete,
              icon: const Icon(
                Icons.close,
                color: Colors.white,
                size: 28,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRewardsSection(BuildContext context, LeagueConfig league) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 32),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          Text(
            '新しい特典',
            style: context.textTheme.titleMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 12),
          
          ...league.rewards.unlocks.map((unlock) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                Icon(
                  Icons.check_circle,
                  color: league.color,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _getUnlockDescription(unlock),
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  String _getUnlockDescription(String unlock) {
    switch (unlock) {
      case 'basic_customization':
        return '基本カスタマイズ機能';
      case 'advanced_themes':
        return '高度なテーマ設定';
      case 'priority_support':
        return '優先サポート';
      case 'premium_analytics':
        return 'プレミアム分析機能';
      case 'exclusive_challenges':
        return '限定チャレンジ';
      case 'ai_coach_priority':
        return 'AIコーチ優先アクセス';
      case 'custom_animations':
        return 'カスタムアニメーション';
      case 'all_features':
        return '全機能アクセス';
      case 'beta_access':
        return 'ベータ機能アクセス';
      case 'exclusive_events':
        return '限定イベント参加権';
      default:
        return unlock;
    }
  }
}

/// Custom painter for particle effects
class ParticlesPainter extends CustomPainter {
  final Animation<double> animation;
  final Color color;
  final List<Particle> particles;

  ParticlesPainter({
    required this.animation,
    required this.color,
  }) : particles = List.generate(50, (index) => Particle()) {
    animation.addListener(() {
      for (final particle in particles) {
        particle.update(animation.value);
      }
    });
  }

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(0.7)
      ..style = PaintingStyle.fill;

    for (final particle in particles) {
      final opacity = (1.0 - particle.life) * 0.8;
      paint.color = color.withOpacity(opacity);
      
      canvas.drawCircle(
        Offset(
          particle.x * size.width,
          particle.y * size.height,
        ),
        particle.size,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/// Particle class for animation effects
class Particle {
  double x;
  double y;
  double vx;
  double vy;
  double life;
  double size;

  Particle()
      : x = math.Random().nextDouble(),
        y = math.Random().nextDouble(),
        vx = (math.Random().nextDouble() - 0.5) * 0.02,
        vy = (math.Random().nextDouble() - 0.5) * 0.02,
        life = 0.0,
        size = math.Random().nextDouble() * 4 + 1;

  void update(double animationValue) {
    life = animationValue;
    x += vx;
    y += vy;
    
    // Wrap around edges
    if (x < 0) x = 1;
    if (x > 1) x = 0;
    if (y < 0) y = 1;
    if (y > 1) y = 0;
  }
}