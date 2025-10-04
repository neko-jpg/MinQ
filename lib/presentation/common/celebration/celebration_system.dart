import 'dart:math';

import 'package:flutter/material.dart';
import 'package:minq/presentation/common/feedback/audio_feedback_manager.dart';
import 'package:minq/presentation/common/feedback/haptic_manager.dart';

/// 逾晉ｦ乗ｼ泌・縺ｮ遞ｮ鬘・
enum CelebrationType {
  confetti,
  fireworks,
  sparkles,
  trophy,
  mascot,
  golden,
}

/// 逾晉ｦ乗ｼ泌・縺ｮ險ｭ螳・
class CelebrationConfig {
  final CelebrationType type;
  final Duration duration;
  final String? message;
  final Color primaryColor;
  final Color secondaryColor;
  final bool playSound;
  final bool hapticFeedback;

  const CelebrationConfig({
    required this.type,
    this.duration = const Duration(seconds: 3),
    this.message,
    this.primaryColor = const Color(0xFFFFD700),
    this.secondaryColor = const Color(0xFFFF6B6B),
    this.playSound = true,
    this.hapticFeedback = true,
  });
}

/// 繝ｩ繝ｳ繝繝逾晉ｦ乗ｼ泌・繧ｷ繧ｹ繝・Β
class CelebrationSystem {
  static final Random _random = Random();
  
  /// 蛻ｩ逕ｨ蜿ｯ閭ｽ縺ｪ逾晉ｦ乗ｼ泌・縺ｮ繝ｪ繧ｹ繝・
  static const List<CelebrationConfig> _celebrations = [
    CelebrationConfig(
      type: CelebrationType.confetti,
      message: '邏譎ｴ繧峨＠縺・ｼÅ沁・,
      primaryColor: Color(0xFFFFD700),
      secondaryColor: Color(0xFFFF6B6B),
    ),
    CelebrationConfig(
      type: CelebrationType.fireworks,
      message: '繧・▲縺溘・・Å沁・,
      primaryColor: Color(0xFF4ECDC4),
      secondaryColor: Color(0xFFFFD700),
    ),
    CelebrationConfig(
      type: CelebrationType.sparkles,
      message: '繧ｭ繝ｩ繧ｭ繝ｩ笨ｨ',
      primaryColor: Color(0xFFFFD700),
      secondaryColor: Color(0xFFFFA726),
    ),
    CelebrationConfig(
      type: CelebrationType.trophy,
      message: '繝√Ε繝ｳ繝斐が繝ｳ・Å沛・,
      primaryColor: Color(0xFFFFD700),
      secondaryColor: Color(0xFFFF8F00),
    ),
    CelebrationConfig(
      type: CelebrationType.mascot,
      message: '縺後ｓ縺ｰ縺｣縺溘・・Å汾ｱ',
      primaryColor: Color(0xFFFF6B6B),
      secondaryColor: Color(0xFFFFD700),
    ),
    CelebrationConfig(
      type: CelebrationType.golden,
      message: '繧ｴ繝ｼ繝ｫ繝蛾＃謌撰ｼ≫ｭ・,
      primaryColor: Color(0xFFFFD700),
      secondaryColor: Color(0xFFFFC107),
    ),
  ];

  /// 繝ｩ繝ｳ繝繝縺ｪ逾晉ｦ乗ｼ泌・繧貞叙蠕・
  static CelebrationConfig getRandomCelebration() {
    return _celebrations[_random.nextInt(_celebrations.length)];
  }

  /// 迚ｹ螳壹・遞ｮ鬘槭・逾晉ｦ乗ｼ泌・繧貞叙蠕・
  static CelebrationConfig getCelebration(CelebrationType type) {
    return _celebrations.firstWhere(
      (config) => config.type == type,
      orElse: () => _celebrations.first,
    );
  }

  /// 逾晉ｦ乗ｼ泌・繧定｡ｨ遉ｺ
  static void showCelebration(
    BuildContext context, {
    CelebrationConfig? config,
    VoidCallback? onComplete,
  }) {
    final celebrationConfig = config ?? getRandomCelebration();
    
    // 繝上・繝・ぅ繝・け繝輔ぅ繝ｼ繝峨ヰ繝・け
    if (celebrationConfig.hapticFeedback) {
      HapticManager.success();
    }

    // 髻ｳ螢ｰ繝輔ぅ繝ｼ繝峨ヰ繝・け
    if (celebrationConfig.playSound) {
      AudioFeedbackManager.playSuccess();
    }

    // 逾晉ｦ乗ｼ泌・繧ｪ繝ｼ繝舌・繝ｬ繧､繧定｡ｨ遉ｺ
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.transparent,
      builder: (context) => CelebrationOverlay(
        config: celebrationConfig,
        onComplete: () {
          Navigator.of(context).pop();
          onComplete?.call();
        },
      ),
    );
  }

  /// 騾｣邯夐＃謌占ｨ倬鹸縺ｫ蠢懊§縺溽音蛻･縺ｪ逾晉ｦ乗ｼ泌・
  static CelebrationConfig getStreakCelebration(int streak) {
    if (streak >= 100) {
      return const CelebrationConfig(
        type: CelebrationType.golden,
        message: '100譌･驕疲・・∽ｼ晁ｪｬ縺ｮ邯咏ｶ夊・沍・,
        duration: Duration(seconds: 5),
      );
    } else if (streak >= 50) {
      return const CelebrationConfig(
        type: CelebrationType.trophy,
        message: '50譌･驕疲・・∫ｶ咏ｶ壹・繧ｹ繧ｿ繝ｼ醇',
        duration: Duration(seconds: 4),
      );
    } else if (streak >= 30) {
      return const CelebrationConfig(
        type: CelebrationType.fireworks,
        message: '30譌･驕疲・・∫ｿ呈・蛹匁・蜉溟沁・,
        duration: Duration(seconds: 4),
      );
    } else if (streak >= 7) {
      return const CelebrationConfig(
        type: CelebrationType.confetti,
        message: '1騾ｱ髢馴＃謌撰ｼ∫ｴ譎ｴ繧峨＠縺・沁・,
        duration: Duration(seconds: 3),
      );
    } else {
      return getRandomCelebration();
    }
  }
}

/// 逾晉ｦ乗ｼ泌・繧ｪ繝ｼ繝舌・繝ｬ繧､
class CelebrationOverlay extends StatefulWidget {
  final CelebrationConfig config;
  final VoidCallback onComplete;

  const CelebrationOverlay({
    super.key,
    required this.config,
    required this.onComplete,
  });

  @override
  State<CelebrationOverlay> createState() => _CelebrationOverlayState();
}

class _CelebrationOverlayState extends State<CelebrationOverlay>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.config.duration,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    ),);

    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.3),
    ),);

    _controller.forward().then((_) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          widget.onComplete();
        }
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Stack(
            children: [
              // 閭梧勹繧ｨ繝輔ぉ繧ｯ繝・
              _buildBackgroundEffect(),
              
              // 繝｡繧､繝ｳ繝｡繝・そ繝ｼ繧ｸ
              Center(
                child: Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Opacity(
                    opacity: _opacityAnimation.value,
                    child: _buildMainMessage(),
                  ),
                ),
              ),
              
              // 繝代・繝・ぅ繧ｯ繝ｫ繧ｨ繝輔ぉ繧ｯ繝・
              _buildParticleEffect(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBackgroundEffect() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.center,
          radius: 1.0,
          colors: [
            widget.config.primaryColor.withOpacity(0.1 * _opacityAnimation.value),
            Colors.transparent,
          ],
        ),
      ),
    );
  }

  Widget _buildMainMessage() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: widget.config.primaryColor.withValues(alpha: 0.3),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildCelebrationIcon(),
          const SizedBox(height: 16),
          Text(
            widget.config.message ?? '邏譎ｴ繧峨＠縺・ｼ・,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: widget.config.primaryColor,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildCelebrationIcon() {
    switch (widget.config.type) {
      case CelebrationType.confetti:
        return const Text('脂', style: TextStyle(fontSize: 48));
      case CelebrationType.fireworks:
        return const Text('紙', style: TextStyle(fontSize: 48));
      case CelebrationType.sparkles:
        return const Text('笨ｨ', style: TextStyle(fontSize: 48));
      case CelebrationType.trophy:
        return const Text('醇', style: TextStyle(fontSize: 48));
      case CelebrationType.mascot:
        return const Text('棲', style: TextStyle(fontSize: 48));
      case CelebrationType.golden:
        return const Text('箝・, style: TextStyle(fontSize: 48));
    }
  }

  Widget _buildParticleEffect() {
    return Positioned.fill(
      child: CustomPaint(
        painter: ParticleEffectPainter(
          animation: _controller,
          config: widget.config,
        ),
      ),
    );
  }
}

/// 繝代・繝・ぅ繧ｯ繝ｫ繧ｨ繝輔ぉ繧ｯ繝医・繧､繝ｳ繧ｿ繝ｼ
class ParticleEffectPainter extends CustomPainter {
  final Animation<double> animation;
  final CelebrationConfig config;
  final List<Particle> particles;

  ParticleEffectPainter({
    required this.animation,
    required this.config,
  }) : particles = _generateParticles(config) {
    animation.addListener(() {
      // 繧｢繝九Γ繝ｼ繧ｷ繝ｧ繝ｳ縺ｮ譖ｴ譁ｰ譎ゅ↓繝代・繝・ぅ繧ｯ繝ｫ繧呈峩譁ｰ
    });
  }

  static List<Particle> _generateParticles(CelebrationConfig config) {
    final random = Random();
    final particles = <Particle>[];
    
    for (int i = 0; i < 50; i++) {
      particles.add(Particle(
        x: random.nextDouble(),
        y: random.nextDouble(),
        vx: (random.nextDouble() - 0.5) * 2,
        vy: (random.nextDouble() - 0.5) * 2,
        color: i % 2 == 0 ? config.primaryColor : config.secondaryColor,
        size: random.nextDouble() * 4 + 2,
      ),);
    }
    
    return particles;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final progress = animation.value;
    
    for (final particle in particles) {
      final paint = Paint()
        ..color = particle.color.withOpacity((1 - progress) * 0.8)
        ..style = PaintingStyle.fill;

      final x = (particle.x + particle.vx * progress) * size.width;
      final y = (particle.y + particle.vy * progress) * size.height;

      canvas.drawCircle(
        Offset(x, y),
        particle.size * (1 - progress * 0.5),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/// 繝代・繝・ぅ繧ｯ繝ｫ
class Particle {
  final double x;
  final double y;
  final double vx;
  final double vy;
  final Color color;
  final double size;

  Particle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.color,
    required this.size,
  });
}