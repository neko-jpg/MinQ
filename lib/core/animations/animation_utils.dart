import 'package:flutter/material.dart';
import 'package:minq/core/animations/animation_system.dart';
import 'package:minq/core/animations/fluid_animations.dart';
import 'package:minq/core/animations/micro_interactions.dart';
import 'package:minq/core/animations/particle_system.dart';

/// アニメーションユーティリティクラス（要件46、47、48）
class AnimationUtils {
  static final AnimationSystem _animationSystem = AnimationSystem.instance;

  /// 成功アニメーション（XP獲得、レベルアップ等）
  static void showSuccessAnimation(
    BuildContext context, {
    required String message,
    int? xpGained,
    ParticleConfig? particleConfig,
  }) {
    if (!_animationSystem.animationsEnabled) {
      // アニメーション無効時はスナックバーで代替
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
      return;
    }

    final overlay = Overlay.of(context);
    late OverlayEntry entry;

    entry = OverlayEntry(
      builder:
          (context) => Positioned.fill(
            child: Material(
              color: Colors.transparent,
              child: Stack(
                children: [
                  // パーティクルエフェクト
                  if (particleConfig != null)
                    ParticleSystem(config: particleConfig, isActive: true),

                  // メッセージ表示
                  Center(
                    child: FluidAnimations.elasticScale(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 16,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.green.withOpacity(0.3),
                              blurRadius: 8,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.check_circle,
                              color: Colors.white,
                              size: 32,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              message,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            if (xpGained != null) ...[
                              const SizedBox(height: 4),
                              Text(
                                '+$xpGained XP',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
    );

    overlay.insert(entry);

    // ハプティックフィードバック
    _animationSystem.playSuccessHaptic();

    // 自動削除
    Future.delayed(const Duration(milliseconds: 2500), () {
      entry.remove();
    });
  }

  /// エラーアニメーション
  static void showErrorAnimation(
    BuildContext context, {
    required String message,
    IconData? icon,
  }) {
    if (!_animationSystem.animationsEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
      return;
    }

    final overlay = Overlay.of(context);
    late OverlayEntry entry;

    entry = OverlayEntry(
      builder:
          (context) => Positioned.fill(
            child: Material(
              color: Colors.transparent,
              child: Center(
                child: FluidAnimations.elasticScale(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.red.withOpacity(0.3),
                          blurRadius: 8,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          icon ?? Icons.error,
                          color: Colors.white,
                          size: 32,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          message,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
    );

    overlay.insert(entry);

    // エラー用ハプティックフィードバック
    _animationSystem.playErrorHaptic();

    // 自動削除
    Future.delayed(const Duration(milliseconds: 2000), () {
      entry.remove();
    });
  }

  /// ローディングアニメーション
  static OverlayEntry showLoadingAnimation(
    BuildContext context, {
    String? message,
  }) {
    final overlay = Overlay.of(context);

    final entry = OverlayEntry(
      builder:
          (context) => Positioned.fill(
            child: Material(
              color: Colors.black.withOpacity(0.5),
              child: Center(
                child: FluidAnimations.fadeIn(
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_animationSystem.animationsEnabled)
                          MicroInteractions.loadingDots()
                        else
                          const CircularProgressIndicator(),
                        if (message != null) ...[
                          const SizedBox(height: 16),
                          Text(
                            message,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
    );

    overlay.insert(entry);
    return entry;
  }

  /// カスタムページトランジション
  static PageRouteBuilder createPageTransition({
    required Widget page,
    TransitionType type = TransitionType.slideUp,
    Duration? duration,
  }) {
    return FluidPageTransition(
      child: page,
      transitionType: type,
      duration: duration ?? const Duration(milliseconds: 300),
    );
  }

  /// リストアイテムのスタガードアニメーション
  static Widget buildStaggeredList({
    required List<Widget> children,
    Duration? duration,
    double? delay,
  }) {
    if (!_animationSystem.animationsEnabled) {
      return Column(children: children);
    }

    return Column(
      children:
          children.asMap().entries.map((entry) {
            final index = entry.key;
            final child = entry.value;

            return FluidAnimations.staggeredList(
              index: index,
              duration: duration,
              delay: delay,
              child: child,
            );
          }).toList(),
    );
  }

  /// グリッドアイテムのスタガードアニメーション
  static Widget buildStaggeredGrid({
    required List<Widget> children,
    int columnCount = 2,
    Duration? duration,
    double? delay,
  }) {
    if (!_animationSystem.animationsEnabled) {
      return Wrap(children: children);
    }

    return Wrap(
      children:
          children.asMap().entries.map((entry) {
            final index = entry.key;
            final child = entry.value;

            return FluidAnimations.staggeredGrid(
              index: index,
              columnCount: columnCount,
              duration: duration,
              delay: delay,
              child: child,
            );
          }).toList(),
    );
  }

  /// ボタンのプレスアニメーション
  static Widget buildAnimatedButton({
    required Widget child,
    required VoidCallback onPressed,
    double scaleDown = 0.95,
    Duration? duration,
  }) {
    return MicroInteractions.buttonPress(
      onPressed: onPressed,
      scaleDown: scaleDown,
      duration: duration,
      child: child,
    );
  }

  /// カードのホバーアニメーション
  static Widget buildHoverCard({
    required Widget child,
    VoidCallback? onTap,
    double elevation = 2.0,
    double hoverElevation = 8.0,
  }) {
    return FluidAnimations.hoverCard(
      onTap: onTap,
      elevation: elevation,
      hoverElevation: hoverElevation,
      child: child,
    );
  }

  /// プログレスバーのアニメーション
  static Widget buildAnimatedProgress({
    required double progress,
    Color? backgroundColor,
    Color? progressColor,
    Duration? duration,
    double height = 4.0,
  }) {
    return FluidAnimations.animatedProgress(
      progress: progress,
      backgroundColor: backgroundColor,
      progressColor: progressColor,
      duration: duration,
      height: height,
    );
  }

  /// FABのアニメーション
  static Widget buildAnimatedFAB({
    required Widget child,
    required VoidCallback onPressed,
    bool isVisible = true,
    Duration? duration,
  }) {
    return FluidAnimations.animatedFAB(
      onPressed: onPressed,
      isVisible: isVisible,
      duration: duration,
      child: child,
    );
  }

  /// 拡張FAB
  static Widget buildExpandingFAB({
    required List<FABAction> actions,
    required Widget mainIcon,
    Color? backgroundColor,
    Color? foregroundColor,
  }) {
    return MicroInteractions.expandingFAB(
      actions: actions,
      mainIcon: mainIcon,
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
    );
  }

  /// ハートライクアニメーション
  static Widget buildHeartLike({
    required bool isLiked,
    required ValueChanged<bool> onChanged,
    Color? likedColor,
    Color? unlikedColor,
    double size = 24.0,
  }) {
    return MicroInteractions.heartLike(
      isLiked: isLiked,
      onChanged: onChanged,
      likedColor: likedColor,
      unlikedColor: unlikedColor,
      size: size,
    );
  }

  /// スワイプアクション
  static Widget buildSwipeAction({
    required Widget child,
    List<SwipeAction>? leftActions,
    List<SwipeAction>? rightActions,
  }) {
    return MicroInteractions.swipeAction(
      child: child,
      leftActions: leftActions,
      rightActions: rightActions,
    );
  }

  /// パーティクルエフェクトの表示
  static void showParticleEffect(
    BuildContext context, {
    required ParticleConfig config,
    Duration? duration,
    VoidCallback? onComplete,
  }) {
    if (!_animationSystem.animationsEnabled) {
      onComplete?.call();
      return;
    }

    final overlay = Overlay.of(context);
    late OverlayEntry entry;

    entry = OverlayEntry(
      builder:
          (context) => Positioned.fill(
            child: IgnorePointer(
              child: ParticleEffect(
                config: config,
                onComplete: () {
                  entry.remove();
                  onComplete?.call();
                },
              ),
            ),
          ),
    );

    overlay.insert(entry);
  }

  /// レベルアップ祝福アニメーション
  static void showLevelUpCelebration(
    BuildContext context, {
    required int newLevel,
    required String levelName,
    List<String> rewards = const [],
  }) {
    // パーティクルエフェクト
    showParticleEffect(context, config: ParticleConfig.levelUp());

    // ハプティックフィードバック
    _animationSystem.playSuccessHaptic();

    // 遅延してもう一度ハプティック
    Future.delayed(const Duration(milliseconds: 500), () {
      _animationSystem.playSuccessHaptic();
    });
  }

  /// XP獲得祝福アニメーション
  static void showXPGainCelebration(
    BuildContext context, {
    required int xpGained,
    required String reason,
  }) {
    showParticleEffect(context, config: ParticleConfig.xpGain());

    _animationSystem.playSuccessHaptic();
  }

  /// 成功祝福アニメーション
  static void showSuccessCelebration(BuildContext context, {String? message}) {
    showParticleEffect(context, config: ParticleConfig.success());

    _animationSystem.playSuccessHaptic();

    if (message != null) {
      showSuccessAnimation(context, message: message);
    }
  }

  /// 一般的な祝福アニメーション
  static void showCelebration(BuildContext context, {String? message}) {
    showParticleEffect(context, config: ParticleConfig.celebration());

    _animationSystem.playSuccessHaptic();

    if (message != null) {
      showSuccessAnimation(context, message: message);
    }
  }
}
