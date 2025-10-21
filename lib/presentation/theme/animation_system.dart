import 'package:flutter/material.dart';

/// アニメーションシステム - Duration、Curve、パターンの統一規格
class AnimationSystem {
  const AnimationSystem._();

  // ========================================
  // Duration（継続時間）
  // ========================================

  /// 瞬時 - 50ms
  static const Duration instant = Duration(milliseconds: 50);

  /// 極短 - 100ms
  static const Duration veryFast = Duration(milliseconds: 100);

  /// 短 - 150ms
  static const Duration fast = Duration(milliseconds: 150);

  /// 標準 - 200ms
  static const Duration normal = Duration(milliseconds: 200);

  /// やや長 - 300ms
  static const Duration moderate = Duration(milliseconds: 300);

  /// 長 - 400ms
  static const Duration slow = Duration(milliseconds: 400);

  /// 極長 - 600ms
  static const Duration verySlow = Duration(milliseconds: 600);

  /// 劇的 - 1000ms
  static const Duration dramatic = Duration(milliseconds: 1000);

  // ========================================
  // Curve（イージング）
  // ========================================

  /// 標準イージング
  static const Curve standard = Curves.easeInOut;

  /// 加速
  static const Curve accelerate = Curves.easeIn;

  /// 減速
  static const Curve decelerate = Curves.easeOut;

  /// 強調
  static const Curve emphasized = Curves.easeInOutCubic;

  /// バウンス
  static const Curve bounce = Curves.bounceOut;

  /// エラスティック
  static const Curve elastic = Curves.elasticOut;

  /// オーバーシュート
  static const Curve overshoot = Curves.easeOutBack;

  /// スムーズ
  static const Curve smooth = Curves.easeInOutQuart;

  /// シャープ
  static const Curve sharp = Curves.easeInOutExpo;

  // ========================================
  // セマンティックアニメーション
  // ========================================

  /// ページ遷移
  static const Duration pageTransition = normal;
  static const Curve pageTransitionCurve = emphasized;

  /// モーダル表示
  static const Duration modalPresent = moderate;
  static const Curve modalPresentCurve = decelerate;

  /// モーダル閉じる
  static const Duration modalDismiss = fast;
  static const Curve modalDismissCurve = accelerate;

  /// ボタンタップ
  static const Duration buttonTap = veryFast;
  static const Curve buttonTapCurve = standard;

  /// リスト展開
  static const Duration listExpand = moderate;
  static const Curve listExpandCurve = emphasized;

  /// フェードイン
  static const Duration fadeIn = normal;
  static const Curve fadeInCurve = decelerate;

  /// フェードアウト
  static const Duration fadeOut = fast;
  static const Curve fadeOutCurve = accelerate;

  /// スケールアップ
  static const Duration scaleUp = normal;
  static const Curve scaleUpCurve = overshoot;

  /// スケールダウン
  static const Duration scaleDown = fast;
  static const Curve scaleDownCurve = accelerate;

  /// スライドイン
  static const Duration slideIn = moderate;
  static const Curve slideInCurve = decelerate;

  /// スライドアウト
  static const Duration slideOut = fast;
  static const Curve slideOutCurve = accelerate;

  // ========================================
  // アプリ固有のアニメーション
  // ========================================

  /// クエスト完了
  static const Duration questComplete = slow;
  static const Curve questCompleteCurve = bounce;

  /// ペアマッチング
  static const Duration pairMatch = dramatic;
  static const Curve pairMatchCurve = elastic;

  /// 統計更新
  static const Duration statsUpdate = moderate;
  static const Curve statsUpdateCurve = emphasized;

  /// 祝福エフェクト
  static const Duration celebration = dramatic;
  static const Curve celebrationCurve = bounce;

  // ========================================
  // Hero/Implicitアニメーション規格
  // ========================================

  /// Hero遷移
  static const Duration heroTransition = moderate;
  static const Curve heroTransitionCurve = emphasized;

  /// ImplicitアニメーションのデフォルトDuration
  static const Duration implicitDefault = normal;
  static const Curve implicitDefaultCurve = standard;

  /// AnimatedContainer
  static const Duration animatedContainer = normal;
  static const Curve animatedContainerCurve = emphasized;

  /// AnimatedOpacity
  static const Duration animatedOpacity = fast;
  static const Curve animatedOpacityCurve = decelerate;

  /// AnimatedPositioned
  static const Duration animatedPositioned = moderate;
  static const Curve animatedPositionedCurve = emphasized;

  /// AnimatedSize
  static const Duration animatedSize = moderate;
  static const Curve animatedSizeCurve = emphasized;

  /// AnimatedPadding
  static const Duration animatedPadding = normal;
  static const Curve animatedPaddingCurve = standard;

  /// AnimatedAlign
  static const Duration animatedAlign = normal;
  static const Curve animatedAlignCurve = emphasized;

  /// AnimatedCrossFade
  static const Duration animatedCrossFade = moderate;
  static const Curve animatedCrossFadeCurve = decelerate;

  /// AnimatedSwitcher
  static const Duration animatedSwitcher = fast;
  static const Curve animatedSwitcherCurve = standard;

  /// Shimmerアニメーション（Skeletonローディング用）
  static const Duration shimmer = Duration(milliseconds: 1400);

  // ========================================
  // ヘルパーメソッド
  // ========================================

  /// Reduce Motion設定を考慮すべきかどうか
  static bool shouldReduceMotion(BuildContext context) {
    final mediaQuery = MediaQuery.maybeOf(context);
    if (mediaQuery == null) {
      return false;
    }

    return mediaQuery.disableAnimations || mediaQuery.accessibleNavigation;
  }

  /// Reduce Motion設定を考慮したDurationを取得
  static Duration getDuration(BuildContext context, Duration baseDuration) {
    return shouldReduceMotion(context) ? Duration.zero : baseDuration;
  }

  /// Reduce Motion時に利用するCurveを選択
  static Curve getCurve(BuildContext context, Curve baseCurve) {
    return shouldReduceMotion(context) ? Curves.linear : baseCurve;
  }

  /// Reduce Motion設定に応じてアニメーションコントローラーを制御
  static void syncControllerWithAccessibility(
    AnimationController controller,
    BuildContext context, {
    bool repeat = false,
    Duration? repeatDuration,
  }) {
    if (shouldReduceMotion(context)) {
      if (controller.isAnimating) {
        controller.stop();
      }
      controller.value = repeat ? 1.0 : controller.lowerBound;
    } else if (repeat && !controller.isAnimating) {
      controller.repeat(period: repeatDuration);
    }
  }

  /// アニメーションコントローラーを作成
  static AnimationController createController({
    required TickerProvider vsync,
    Duration duration = normal,
    Duration? reverseDuration,
    double initialValue = 0.0,
  }) {
    return AnimationController(
      vsync: vsync,
      duration: duration,
      reverseDuration: reverseDuration,
      value: initialValue,
    );
  }

  /// Tweenアニメーションを作成
  static Animation<T> createTween<T>({
    required AnimationController controller,
    required T begin,
    required T end,
    Curve curve = standard,
  }) {
    return Tween<T>(
      begin: begin,
      end: end,
    ).animate(CurvedAnimation(parent: controller, curve: curve));
  }
}

/// アニメーションビルダー
class AnimatedBuilder2 extends StatelessWidget {
  final Animation<double> animation;
  final Widget Function(BuildContext, double) builder;

  const AnimatedBuilder2({
    super.key,
    required this.animation,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) => builder(context, animation.value),
    );
  }
}

/// フェードインアニメーション
class FadeInAnimation extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Curve curve;
  final Duration delay;

  const FadeInAnimation({
    super.key,
    required this.child,
    this.duration = AnimationSystem.fadeIn,
    this.curve = AnimationSystem.fadeInCurve,
    this.delay = Duration.zero,
  });

  @override
  State<FadeInAnimation> createState() => _FadeInAnimationState();
}

class _FadeInAnimationState extends State<FadeInAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);
    _animation = CurvedAnimation(parent: _controller, curve: widget.curve);

    if (widget.delay == Duration.zero) {
      _controller.forward();
    } else {
      Future.delayed(widget.delay, () {
        if (mounted) _controller.forward();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(opacity: _animation, child: widget.child);
  }
}

/// スライドインアニメーション
class SlideInAnimation extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Curve curve;
  final Offset begin;
  final Duration delay;

  const SlideInAnimation({
    super.key,
    required this.child,
    this.duration = AnimationSystem.slideIn,
    this.curve = AnimationSystem.slideInCurve,
    this.begin = const Offset(0, 0.3),
    this.delay = Duration.zero,
  });

  @override
  State<SlideInAnimation> createState() => _SlideInAnimationState();
}

class _SlideInAnimationState extends State<SlideInAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);
    _animation = Tween<Offset>(
      begin: widget.begin,
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: widget.curve));

    if (widget.delay == Duration.zero) {
      _controller.forward();
    } else {
      Future.delayed(widget.delay, () {
        if (mounted) _controller.forward();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(position: _animation, child: widget.child);
  }
}

/// スケールアニメーション
class ScaleAnimation extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Curve curve;
  final double begin;
  final Duration delay;

  const ScaleAnimation({
    super.key,
    required this.child,
    this.duration = AnimationSystem.scaleUp,
    this.curve = AnimationSystem.scaleUpCurve,
    this.begin = 0.0,
    this.delay = Duration.zero,
  });

  @override
  State<ScaleAnimation> createState() => _ScaleAnimationState();
}

class _ScaleAnimationState extends State<ScaleAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);
    _animation = Tween<double>(
      begin: widget.begin,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: widget.curve));

    if (widget.delay == Duration.zero) {
      _controller.forward();
    } else {
      Future.delayed(widget.delay, () {
        if (mounted) _controller.forward();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(scale: _animation, child: widget.child);
  }
}

/// 組み合わせアニメーション（フェード+スライド）
class FadeSlideAnimation extends StatelessWidget {
  final Widget child;
  final Duration duration;
  final Curve curve;
  final Offset slideBegin;
  final Duration delay;

  const FadeSlideAnimation({
    super.key,
    required this.child,
    this.duration = AnimationSystem.normal,
    this.curve = AnimationSystem.emphasized,
    this.slideBegin = const Offset(0, 0.2),
    this.delay = Duration.zero,
  });

  @override
  Widget build(BuildContext context) {
    return FadeInAnimation(
      duration: duration,
      curve: curve,
      delay: delay,
      child: SlideInAnimation(
        duration: duration,
        curve: curve,
        begin: slideBegin,
        delay: delay,
        child: child,
      ),
    );
  }
}

/// リスト用スタガーアニメーション
class StaggeredListAnimation extends StatelessWidget {
  final List<Widget> children;
  final Duration itemDelay;
  final Duration itemDuration;
  final Axis scrollDirection;

  const StaggeredListAnimation({
    super.key,
    required this.children,
    this.itemDelay = const Duration(milliseconds: 50),
    this.itemDuration = AnimationSystem.normal,
    this.scrollDirection = Axis.vertical,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      scrollDirection: scrollDirection,
      itemCount: children.length,
      itemBuilder: (context, index) {
        return FadeSlideAnimation(
          duration: itemDuration,
          delay: itemDelay * index,
          slideBegin:
              scrollDirection == Axis.vertical
                  ? const Offset(0, 0.2)
                  : const Offset(0.2, 0),
          child: children[index],
        );
      },
    );
  }
}

/// Reduce Motion対応アニメーション
class AccessibleAnimation extends StatelessWidget {
  final Widget child;
  final Widget Function(BuildContext, Widget) animationBuilder;

  const AccessibleAnimation({
    super.key,
    required this.child,
    required this.animationBuilder,
  });

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.of(context).disableAnimations;

    if (reduceMotion) {
      return child;
    }

    return animationBuilder(context, child);
  }
}

/// アニメーション拡張
extension AnimationExtension on Widget {
  /// フェードインを追加
  Widget fadeIn({
    Duration duration = AnimationSystem.fadeIn,
    Curve curve = AnimationSystem.fadeInCurve,
    Duration delay = Duration.zero,
  }) {
    return FadeInAnimation(
      duration: duration,
      curve: curve,
      delay: delay,
      child: this,
    );
  }

  /// スライドインを追加
  Widget slideIn({
    Duration duration = AnimationSystem.slideIn,
    Curve curve = AnimationSystem.slideInCurve,
    Offset begin = const Offset(0, 0.3),
    Duration delay = Duration.zero,
  }) {
    return SlideInAnimation(
      duration: duration,
      curve: curve,
      begin: begin,
      delay: delay,
      child: this,
    );
  }

  /// スケールアニメーションを追加
  Widget scale({
    Duration duration = AnimationSystem.scaleUp,
    Curve curve = AnimationSystem.scaleUpCurve,
    double begin = 0.0,
    Duration delay = Duration.zero,
  }) {
    return ScaleAnimation(
      duration: duration,
      curve: curve,
      begin: begin,
      delay: delay,
      child: this,
    );
  }

  /// フェード+スライドを追加
  Widget fadeSlide({
    Duration duration = AnimationSystem.normal,
    Curve curve = AnimationSystem.emphasized,
    Offset slideBegin = const Offset(0, 0.2),
    Duration delay = Duration.zero,
  }) {
    return FadeSlideAnimation(
      duration: duration,
      curve: curve,
      slideBegin: slideBegin,
      delay: delay,
      child: this,
    );
  }

  /// Reduce Motion対応
  Widget withAccessibleAnimation(
    Widget Function(BuildContext, Widget) animationBuilder,
  ) {
    return AccessibleAnimation(animationBuilder: animationBuilder, child: this);
  }
}
