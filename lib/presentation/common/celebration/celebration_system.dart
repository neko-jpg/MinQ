import 'dart:math';

import 'package:flutter/material.dart';
import 'package:minq/presentation/common/feedback/audio_feedback_manager.dart';
import 'package:minq/presentation/common/feedback/haptic_manager.dart';

/// 祝福演�Eの種顁E
enum CelebrationType {
  confetti,
  fireworks,
  sparkles,
  trophy,
  mascot,
  golden,
}

/// 祝福演�Eの設宁E
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

/// ランダム祝福演�EシスチE��
class CelebrationSystem {
  static final Random _random = Random();
  
  /// 利用可能な祝福演�EのリスチE
  static const List<CelebrationConfig> _celebrations = [
    CelebrationConfig(
      type: CelebrationType.confetti,
      message: '素晴らしぁE��🎁E,
      primaryColor: Color(0xFFFFD700),
      secondaryColor: Color(0xFFFF6B6B),
    ),
    CelebrationConfig(
      type: CelebrationType.fireworks,
      message: 'めE��た�E�E�🎁E,
      primaryColor: Color(0xFF4ECDC4),
      secondaryColor: Color(0xFFFFD700),
    ),
    CelebrationConfig(
      type: CelebrationType.sparkles,
      message: 'キラキラ✨',
      primaryColor: Color(0xFFFFD700),
      secondaryColor: Color(0xFFFFA726),
    ),
    CelebrationConfig(
      type: CelebrationType.trophy,
      message: 'チャンピオン�E�🏁E,
      primaryColor: Color(0xFFFFD700),
      secondaryColor: Color(0xFFFF8F00),
    ),
    CelebrationConfig(
      type: CelebrationType.mascot,
      message: 'がんばった�E�E�🐱',
      primaryColor: Color(0xFFFF6B6B),
      secondaryColor: Color(0xFFFFD700),
    ),
    CelebrationConfig(
      type: CelebrationType.golden,
      message: 'ゴールド達成！⭁E,
      primaryColor: Color(0xFFFFD700),
      secondaryColor: Color(0xFFFFC107),
    ),
  ];

  /// ランダムな祝福演�Eを取征E
  static CelebrationConfig getRandomCelebration() {
    return _celebrations[_random.nextInt(_celebrations.length)];
  }

  /// 特定�E種類�E祝福演�Eを取征E
  static CelebrationConfig getCelebration(CelebrationType type) {
    return _celebrations.firstWhere(
      (config) => config.type == type,
      orElse: () => _celebrations.first,
    );
  }

  /// 祝福演�Eを表示
  static void showCelebration(
    BuildContext context, {
    CelebrationConfig? config,
    VoidCallback? onComplete,
  }) {
    final celebrationConfig = config ?? getRandomCelebration();
    
    // ハ�EチE��チE��フィードバチE��
    if (celebrationConfig.hapticFeedback) {
      HapticManager.success();
    }

    // 音声フィードバチE��
    if (celebrationConfig.playSound) {
      AudioFeedbackManager.playSuccess();
    }

    // 祝福演�Eオーバ�Eレイを表示
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

  /// 連続達成記録に応じた特別な祝福演�E
  static CelebrationConfig getStreakCelebration(int streak) {
    if (streak >= 100) {
      return const CelebrationConfig(
        type: CelebrationType.golden,
        message: '100日達�E�E�伝説の継続老E���E,
        duration: Duration(seconds: 5),
      );
    } else if (streak >= 50) {
      return const CelebrationConfig(
        type: CelebrationType.trophy,
        message: '50日達�E�E�継続�Eスター🏆',
        duration: Duration(seconds: 4),
      );
    } else if (streak >= 30) {
      return const CelebrationConfig(
        type: CelebrationType.fireworks,
        message: '30日達�E�E�習�E化�E功🎁E,
        duration: Duration(seconds: 4),
      );
    } else if (streak >= 7) {
      return const CelebrationConfig(
        type: CelebrationType.confetti,
        message: '1週間達成！素晴らしぁE���E,
        duration: Duration(seconds: 3),
      );
    } else {
      return getRandomCelebration();
    }
  }
}

/// 祝福演�Eオーバ�Eレイ
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
              // 背景エフェクチE
              _buildBackgroundEffect(),
              
              // メインメチE��ージ
              Center(
                child: Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Opacity(
                    opacity: _opacityAnimation.value,
                    child: _buildMainMessage(),
                  ),
                ),
              ),
              
              // パ�EチE��クルエフェクチE
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
            widget.config.message ?? '素晴らしぁE��E,
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
        return const Text('🎉', style: TextStyle(fontSize: 48));
      case CelebrationType.fireworks:
        return const Text('🎆', style: TextStyle(fontSize: 48));
      case CelebrationType.sparkles:
        return const Text('✨', style: TextStyle(fontSize: 48));
      case CelebrationType.trophy:
        return const Text('🏆', style: TextStyle(fontSize: 48));
      case CelebrationType.mascot:
        return const Text('🐱', style: TextStyle(fontSize: 48));
      case CelebrationType.golden:
        return const Text('⭁E, style: TextStyle(fontSize: 48));
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

/// パ�EチE��クルエフェクト�Eインター
class ParticleEffectPainter extends CustomPainter {
  final Animation<double> animation;
  final CelebrationConfig config;
  final List<Particle> particles;

  ParticleEffectPainter({
    required this.animation,
    required this.config,
  }) : particles = _generateParticles(config) {
    animation.addListener(() {
      // アニメーションの更新時にパ�EチE��クルを更新
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

/// パ�EチE��クル
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