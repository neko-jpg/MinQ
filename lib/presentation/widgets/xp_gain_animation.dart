import 'package:flutter/material.dart';
import 'package:minq/core/animations/animation_system.dart';
import 'package:minq/core/animations/particle_system.dart';
import 'package:minq/presentation/theme/minq_theme.dart';
import 'package:minq/presentation/theme/theme_extensions.dart';

/// XP獲得時のアニメーションウィジェット（要件48）
class XPGainAnimation extends StatefulWidget {
  final int xpGained;
  final String reason;
  final VoidCallback? onComplete;
  
  const XPGainAnimation({
    super.key,
    required this.xpGained,
    required this.reason,
    this.onComplete,
  });

  @override
  State<XPGainAnimation> createState() => _XPGainAnimationState();
}

class _XPGainAnimationState extends State<XPGainAnimation>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _particleController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<int> _countAnimation;
  
  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: AnimationSystem.instance.getDuration(const Duration(milliseconds: 2000)),
      vsync: this,
    );
    
    _particleController = AnimationController(
      duration: AnimationSystem.instance.getDuration(const Duration(milliseconds: 1500)),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Interval(0.0, 0.3, curve: AnimationSystem.instance.getCurve(Curves.elasticOut)),
    ));
    
    _opacityAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Interval(0.7, 1.0, curve: AnimationSystem.instance.getCurve(Curves.easeOut)),
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0, -2),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: AnimationSystem.instance.getCurve(Curves.easeOut),
    ));
    
    _countAnimation = IntTween(
      begin: 0,
      end: widget.xpGained,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Interval(0.1, 0.6, curve: AnimationSystem.instance.getCurve(Curves.easeOutCubic)),
    ));
    
    _startAnimation();
  }
  
  void _startAnimation() async {
    // ハプティックフィードバック
    AnimationSystem.instance.playSuccessHaptic();
    
    if (AnimationSystem.instance.animationsEnabled) {
      await _controller.forward();
      _particleController.forward();
    }
    
    if (widget.onComplete != null) {
      widget.onComplete!();
    }
  }
  
  @override
  void dispose() {
    _controller.dispose();
    _particleController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return SlideTransition(
          position: _slideAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: FadeTransition(
              opacity: _opacityAnimation,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // パーティクルエフェクト
                  if (AnimationSystem.instance.animationsEnabled)
                    ParticleSystem(
                      config: ParticleConfig.xpGain(),
                      isActive: _particleController.isAnimating,
                    ),
                  
                  // メインXP表示
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: tokens.spacing.md,
                      vertical: tokens.spacing.sm,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          tokens.success,
                          tokens.success.withOpacity(0.8),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(tokens.radius.lg),
                      boxShadow: [
                        BoxShadow(
                          color: tokens.success.withOpacity(0.3),
                          blurRadius: 8,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.stars,
                          color: Colors.white,
                          size: tokens.spacing.lg,
                        ),
                        SizedBox(width: tokens.spacing.sm),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AnimatedBuilder(
                              animation: _countAnimation,
                              builder: (context, child) {
                                return Text(
                                  '+${_countAnimation.value} XP',
                                  style: tokens.typography.h3.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                );
                              },
                            ),
                            Text(
                              widget.reason,
                              style: tokens.typography.bodySmall.copyWith(
                                color: Colors.white.withOpacity(0.9),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
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



/// XP獲得オーバーレイ
class XPGainOverlay {
  static void show(BuildContext context, int xpGained, String reason) {
    final overlay = Overlay.of(context);
    late OverlayEntry entry;
    
    entry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).size.height * 0.3,
        left: 0,
        right: 0,
        child: Center(
          child: XPGainAnimation(
            xpGained: xpGained,
            reason: reason,
            onComplete: () {
              Future.delayed(const Duration(milliseconds: 500), () {
                entry.remove();
              });
            },
          ),
        ),
      ),
    );
    
    overlay.insert(entry);
  }
}

/// レベルアップアニメーション
class LevelUpAnimation extends StatefulWidget {
  final int newLevel;
  final String levelName;
  final List<String> rewards;
  final VoidCallback? onComplete;
  
  const LevelUpAnimation({
    super.key,
    required this.newLevel,
    required this.levelName,
    this.rewards = const [],
    this.onComplete,
  });

  @override
  State<LevelUpAnimation> createState() => _LevelUpAnimationState();
}

class _LevelUpAnimationState extends State<LevelUpAnimation>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _glowAnimation;
  
  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: AnimationSystem.instance.getDuration(const Duration(milliseconds: 3000)),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Interval(0.0, 0.4, curve: AnimationSystem.instance.getCurve(Curves.elasticOut)),
    ));
    
    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 2.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Interval(0.2, 0.8, curve: AnimationSystem.instance.getCurve(Curves.easeInOut)),
    ));
    
    _glowAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: AnimationSystem.instance.getCurve(Curves.easeInOut),
    ));
    
    // ハプティックフィードバック
    AnimationSystem.instance.playSuccessHaptic();
    
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
    final tokens = context.tokens;
    
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          width: double.infinity,
          height: double.infinity,
          color: Colors.black.withOpacity(0.8),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // レベルアップアイコン
                Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Transform.rotate(
                    angle: _rotationAnimation.value * 3.14159,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const RadialGradient(
                          colors: [
                            Colors.amber,
                            Colors.orange,
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.amber.withOpacity(_glowAnimation.value * 0.8),
                            blurRadius: 30 * _glowAnimation.value,
                            spreadRadius: 10 * _glowAnimation.value,
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
                ),
                
                SizedBox(height: tokens.spacing.xl),
                
                // レベルアップテキスト
                FadeTransition(
                  opacity: _scaleAnimation,
                  child: Column(
                    children: [
                      Text(
                        'LEVEL UP!',
                        style: tokens.typography.h1.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                      ),
                      SizedBox(height: tokens.spacing.md),
                      Text(
                        'レベル ${widget.newLevel}',
                        style: tokens.typography.h2.copyWith(
                          color: Colors.amber,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: tokens.spacing.sm),
                      Text(
                        widget.levelName,
                        style: tokens.typography.h3.copyWith(
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                      if (widget.rewards.isNotEmpty) ...[
                        SizedBox(height: tokens.spacing.lg),
                        Text(
                          '新しい報酬',
                          style: tokens.typography.h4.copyWith(
                            color: Colors.white.withOpacity(0.9),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: tokens.spacing.sm),
                        ...widget.rewards.take(3).map((reward) => Padding(
                          padding: EdgeInsets.only(bottom: tokens.spacing.xs),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.star,
                                color: Colors.amber,
                                size: 16,
                              ),
                              SizedBox(width: tokens.spacing.xs),
                              Text(
                                reward,
                                style: tokens.typography.bodySmall.copyWith(
                                  color: Colors.white.withOpacity(0.8),
                                ),
                              ),
                            ],
                          ),
                        )),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// レベルアップオーバーレイ
class LevelUpOverlay {
  static void show(BuildContext context, int newLevel, String levelName, {List<String> rewards = const []}) {
    final overlay = Overlay.of(context);
    late OverlayEntry entry;
    
    entry = OverlayEntry(
      builder: (context) => LevelUpAnimation(
        newLevel: newLevel,
        levelName: levelName,
        rewards: rewards,
        onComplete: () {
          Future.delayed(const Duration(milliseconds: 1000), () {
            entry.remove();
          });
        },
      ),
    );
    
    overlay.insert(entry);
  }
}