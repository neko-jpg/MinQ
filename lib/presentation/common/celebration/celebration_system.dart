import 'dart:math';

import 'package:flutter/material.dart';
import 'package:minq/presentation/common/feedback/audio_feedback_manager.dart';
import 'package:minq/presentation/common/feedback/haptic_manager.dart';
import 'package:minq/presentation/theme/minq_theme.dart';

/// 祝福演出の種類
enum CelebrationType { confetti, fireworks, sparkles, trophy, mascot, golden }

/// 祝福演出の設定
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
    required this.primaryColor,
    required this.secondaryColor,
    this.playSound = true,
    this.hapticFeedback = true,
  });
}

/// ランダム祝福演出システム
class CelebrationSystem {
  static final Random _random = Random();

  /// 利用可能な祝福演出のリストを生成（デザイントークンを使用）
  static List<CelebrationConfig> _getCelebrations(MinqTheme theme) => [
    CelebrationConfig(
      type: CelebrationType.confetti,
      message: '素晴らしい！🎉',
      primaryColor: theme.tokens.warning, // Golden color
      secondaryColor: theme.tokens.error,
    ),
    CelebrationConfig(
      type: CelebrationType.fireworks,
      message: 'やったね！🎆',
      primaryColor: theme.tokens.secondary,
      secondaryColor: theme.tokens.warning,
    ),
    CelebrationConfig(
      type: CelebrationType.sparkles,
      message: 'キラキラ✨',
      primaryColor: theme.tokens.warning,
      secondaryColor: theme.tokens.tertiary,
    ),
    CelebrationConfig(
      type: CelebrationType.trophy,
      message: 'チャンピオン！🏆',
      primaryColor: theme.tokens.warning,
      secondaryColor: theme.tokens.success,
    ),
    CelebrationConfig(
      type: CelebrationType.mascot,
      message: 'がんばったね！🐱',
      primaryColor: theme.tokens.error,
      secondaryColor: theme.tokens.warning,
    ),
    CelebrationConfig(
      type: CelebrationType.golden,
      message: 'ゴールド達成！⭐',
      primaryColor: theme.tokens.warning,
      secondaryColor: theme.tokens.primary,
    ),
  ];

  /// ランダムな祝福演出を取得（デザイントークンを使用）
  static CelebrationConfig getRandomCelebration(MinqTheme theme) {
    final celebrations = _getCelebrations(theme);
    return celebrations[_random.nextInt(celebrations.length)];
  }

  /// 特定の祝福演出を取得（デザイントークンを使用）
  static CelebrationConfig getCelebration(
    CelebrationType type,
    MinqTheme theme,
  ) {
    final celebrations = _getCelebrations(theme);
    return celebrations.firstWhere(
      (config) => config.type == type,
      orElse: () => celebrations.first,
    );
  }

  /// 祝福演出を表示
  static void showCelebration(
    BuildContext context, {
    CelebrationConfig? config,
    VoidCallback? onComplete,
  }) {
    final theme = Theme.of(context).extension<MinqTheme>()!;
    final celebrationConfig = config ?? getRandomCelebration(theme);

    // ハプティックフィードバック
    if (celebrationConfig.hapticFeedback) {
      HapticManager.success();
    }

    // 音声フィードバック
    if (celebrationConfig.playSound) {
      AudioFeedbackManager.playSuccess();
    }

    // 祝福演出オーバーレイを表示
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.transparent,
      builder:
          (context) => CelebrationOverlay(
            config: celebrationConfig,
            onComplete: () {
              Navigator.of(context).pop();
              onComplete?.call();
            },
          ),
    );
  }

  /// 連続達成記録に応じた特別な祝福演出
  static CelebrationConfig getStreakCelebration(int streak, MinqTheme theme) {
    if (streak >= 100) {
      return CelebrationConfig(
        type: CelebrationType.golden,
        message: '100日達成！伝説の継続者🌟',
        duration: const Duration(seconds: 5),
        primaryColor: theme.tokens.primary,
        secondaryColor: theme.tokens.secondary,
      );
    } else if (streak >= 50) {
      return CelebrationConfig(
        type: CelebrationType.trophy,
        message: '50日達成！継続マスター🏆',
        duration: const Duration(seconds: 4),
        primaryColor: theme.tokens.primary,
        secondaryColor: theme.tokens.secondary,
      );
    } else if (streak >= 30) {
      return CelebrationConfig(
        type: CelebrationType.fireworks,
        message: '30日達成！習慣化成功🎆',
        duration: const Duration(seconds: 4),
        primaryColor: theme.tokens.primary,
        secondaryColor: theme.tokens.secondary,
      );
    } else if (streak >= 7) {
      return CelebrationConfig(
        type: CelebrationType.confetti,
        message: '1週間達成！素晴らしい🎉',
        duration: const Duration(seconds: 3),
        primaryColor: theme.tokens.primary,
        secondaryColor: theme.tokens.secondary,
      );
    } else {
      return getRandomCelebration(theme);
    }
  }
}

/// 祝福演出オーバーレイ
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
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.3)),
    );

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
              // 背景エフェクト
              _buildBackgroundEffect(),

              // メインメッセージ
              Center(
                child: Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Opacity(
                    opacity: _opacityAnimation.value,
                    child: _buildMainMessage(),
                  ),
                ),
              ),

              // パーティクルエフェクト
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
            widget.config.primaryColor.withAlpha(
              (25.5 * _opacityAnimation.value).round(),
            ),
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
            color: widget.config.primaryColor.withAlpha(77),
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
            widget.config.message ?? '素晴らしい！',
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
        return const Text('⭐', style: TextStyle(fontSize: 48));
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

/// パーティクルエフェクトペインター
class ParticleEffectPainter extends CustomPainter {
  final Animation<double> animation;
  final CelebrationConfig config;
  final List<Particle> particles;

  ParticleEffectPainter({required this.animation, required this.config})
    : particles = _generateParticles(config) {
    animation.addListener(() {
      // アニメーションの更新時にパーティクルを更新
    });
  }

  static List<Particle> _generateParticles(CelebrationConfig config) {
    final random = Random();
    final particles = <Particle>[];

    for (int i = 0; i < 50; i++) {
      particles.add(
        Particle(
          x: random.nextDouble(),
          y: random.nextDouble(),
          vx: (random.nextDouble() - 0.5) * 2,
          vy: (random.nextDouble() - 0.5) * 2,
          color: i % 2 == 0 ? config.primaryColor : config.secondaryColor,
          size: random.nextDouble() * 4 + 2,
        ),
      );
    }

    return particles;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final progress = animation.value;

    for (final particle in particles) {
      final paint =
          Paint()
            ..color = particle.color.withAlpha(((1 - progress) * 204).round())
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

/// パーティクル
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
