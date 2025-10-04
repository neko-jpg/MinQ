import 'package:flutter/material.dart';

/// 繧｢繝九Γ繝ｼ繧ｷ繝ｧ繝ｳ繧ｷ繧ｹ繝・Β - Duration縲，urve縲√ヱ繧ｿ繝ｼ繝ｳ縺ｮ邨ｱ荳隕乗ｼ
class AnimationSystem {
  const AnimationSystem._();

  // ========================================
  // Duration・育ｶ咏ｶ壽凾髢難ｼ・
  // ========================================

  /// 迸ｬ譎・- 50ms
  static const Duration instant = Duration(milliseconds: 50);

  /// 讌ｵ遏ｭ - 100ms
  static const Duration veryFast = Duration(milliseconds: 100);

  /// 遏ｭ - 150ms
  static const Duration fast = Duration(milliseconds: 150);

  /// 讓呎ｺ・- 200ms
  static const Duration normal = Duration(milliseconds: 200);

  /// 繧・ｄ髟ｷ - 300ms
  static const Duration moderate = Duration(milliseconds: 300);

  /// 髟ｷ - 400ms
  static const Duration slow = Duration(milliseconds: 400);

  /// 讌ｵ髟ｷ - 600ms
  static const Duration verySlow = Duration(milliseconds: 600);

  /// 蜉・噪 - 1000ms
  static const Duration dramatic = Duration(milliseconds: 1000);

  // ========================================
  // Curve・医う繝ｼ繧ｸ繝ｳ繧ｰ・・
  // ========================================

  /// 讓呎ｺ悶う繝ｼ繧ｸ繝ｳ繧ｰ
  static const Curve standard = Curves.easeInOut;

  /// 蜉騾・
  static const Curve accelerate = Curves.easeIn;

  /// 貂幃・
  static const Curve decelerate = Curves.easeOut;

  /// 蠑ｷ隱ｿ
  static const Curve emphasized = Curves.easeInOutCubic;

  /// 繝舌え繝ｳ繧ｹ
  static const Curve bounce = Curves.bounceOut;

  /// 繧ｨ繝ｩ繧ｹ繝・ぅ繝・け
  static const Curve elastic = Curves.elasticOut;

  /// 繧ｪ繝ｼ繝舌・繧ｷ繝･繝ｼ繝・
  static const Curve overshoot = Curves.easeOutBack;

  /// 繧ｹ繝繝ｼ繧ｺ
  static const Curve smooth = Curves.easeInOutQuart;

  /// 繧ｷ繝｣繝ｼ繝・
  static const Curve sharp = Curves.easeInOutExpo;

  // ========================================
  // 繧ｻ繝槭Φ繝・ぅ繝・け繧｢繝九Γ繝ｼ繧ｷ繝ｧ繝ｳ
  // ========================================

  /// 繝壹・繧ｸ驕ｷ遘ｻ
  static const Duration pageTransition = normal;
  static const Curve pageTransitionCurve = emphasized;

  /// 繝｢繝ｼ繝繝ｫ陦ｨ遉ｺ
  static const Duration modalPresent = moderate;
  static const Curve modalPresentCurve = decelerate;

  /// 繝｢繝ｼ繝繝ｫ髢峨§繧・
  static const Duration modalDismiss = fast;
  static const Curve modalDismissCurve = accelerate;

  /// 繝懊ち繝ｳ繧ｿ繝・・
  static const Duration buttonTap = veryFast;
  static const Curve buttonTapCurve = standard;

  /// 繝ｪ繧ｹ繝亥ｱ暮幕
  static const Duration listExpand = moderate;
  static const Curve listExpandCurve = emphasized;

  /// 繝輔ぉ繝ｼ繝峨う繝ｳ
  static const Duration fadeIn = normal;
  static const Curve fadeInCurve = decelerate;

  /// 繝輔ぉ繝ｼ繝峨い繧ｦ繝・
  static const Duration fadeOut = fast;
  static const Curve fadeOutCurve = accelerate;

  /// 繧ｹ繧ｱ繝ｼ繝ｫ繧｢繝・・
  static const Duration scaleUp = normal;
  static const Curve scaleUpCurve = overshoot;

  /// 繧ｹ繧ｱ繝ｼ繝ｫ繝繧ｦ繝ｳ
  static const Duration scaleDown = fast;
  static const Curve scaleDownCurve = accelerate;

  /// 繧ｹ繝ｩ繧､繝峨う繝ｳ
  static const Duration slideIn = moderate;
  static const Curve slideInCurve = decelerate;

  /// 繧ｹ繝ｩ繧､繝峨い繧ｦ繝・
  static const Duration slideOut = fast;
  static const Curve slideOutCurve = accelerate;

  // ========================================
  // 繧｢繝励Μ蝗ｺ譛峨・繧｢繝九Γ繝ｼ繧ｷ繝ｧ繝ｳ
  // ========================================

  /// 繧ｯ繧ｨ繧ｹ繝亥ｮ御ｺ・
  static const Duration questComplete = slow;
  static const Curve questCompleteCurve = bounce;

  /// 繝壹い繝槭ャ繝√Φ繧ｰ
  static const Duration pairMatch = dramatic;
  static const Curve pairMatchCurve = elastic;

  /// 邨ｱ險域峩譁ｰ
  static const Duration statsUpdate = moderate;
  static const Curve statsUpdateCurve = emphasized;

  /// 逾晉ｦ上お繝輔ぉ繧ｯ繝・
  static const Duration celebration = dramatic;
  static const Curve celebrationCurve = bounce;

  // ========================================
  // Hero/Implicit繧｢繝九Γ繝ｼ繧ｷ繝ｧ繝ｳ隕乗ｼ
  // ========================================

  /// Hero驕ｷ遘ｻ
  static const Duration heroTransition = moderate;
  static const Curve heroTransitionCurve = emphasized;

  /// Implicit繧｢繝九Γ繝ｼ繧ｷ繝ｧ繝ｳ縺ｮ繝・ヵ繧ｩ繝ｫ繝・uration
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

  /// Shimmer繧｢繝九Γ繝ｼ繧ｷ繝ｧ繝ｳ・・keleton繝ｭ繝ｼ繝・ぅ繝ｳ繧ｰ逕ｨ・・
  static const Duration shimmer = Duration(milliseconds: 1400);

  // ========================================
  // 繝倥Ν繝代・繝｡繧ｽ繝・ラ
  // ========================================

  /// Reduce Motion險ｭ螳壹ｒ閠・・縺吶∋縺阪°縺ｩ縺・°
  static bool shouldReduceMotion(BuildContext context) {
    final mediaQuery = MediaQuery.maybeOf(context);
    if (mediaQuery == null) {
      return false;
    }

    return mediaQuery.disableAnimations || mediaQuery.accessibleNavigation;
  }

  /// Reduce Motion險ｭ螳壹ｒ閠・・縺励◆Duration繧貞叙蠕・
  static Duration getDuration(
    BuildContext context,
    Duration baseDuration,
  ) {
    return shouldReduceMotion(context) ? Duration.zero : baseDuration;
  }

  /// Reduce Motion譎ゅ↓蛻ｩ逕ｨ縺吶ｋCurve繧帝∈謚・
  static Curve getCurve(BuildContext context, Curve baseCurve) {
    return shouldReduceMotion(context) ? Curves.linear : baseCurve;
  }

  /// Reduce Motion險ｭ螳壹↓蠢懊§縺ｦ繧｢繝九Γ繝ｼ繧ｷ繝ｧ繝ｳ繧ｳ繝ｳ繝医Ο繝ｼ繝ｩ繝ｼ繧貞宛蠕｡
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

  /// 繧｢繝九Γ繝ｼ繧ｷ繝ｧ繝ｳ繧ｳ繝ｳ繝医Ο繝ｼ繝ｩ繝ｼ繧剃ｽ懈・
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

  /// Tween繧｢繝九Γ繝ｼ繧ｷ繝ｧ繝ｳ繧剃ｽ懈・
  static Animation<T> createTween<T>({
    required AnimationController controller,
    required T begin,
    required T end,
    Curve curve = standard,
  }) {
    return Tween<T>(begin: begin, end: end).animate(
      CurvedAnimation(parent: controller, curve: curve),
    );
  }
}

/// 繧｢繝九Γ繝ｼ繧ｷ繝ｧ繝ｳ繝薙Ν繝繝ｼ
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

/// 繝輔ぉ繝ｼ繝峨う繝ｳ繧｢繝九Γ繝ｼ繧ｷ繝ｧ繝ｳ
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
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    );

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
    return FadeTransition(
      opacity: _animation,
      child: widget.child,
    );
  }
}

/// 繧ｹ繝ｩ繧､繝峨う繝ｳ繧｢繝九Γ繝ｼ繧ｷ繝ｧ繝ｳ
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
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _animation = Tween<Offset>(
      begin: widget.begin,
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    ),);

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
    return SlideTransition(
      position: _animation,
      child: widget.child,
    );
  }
}

/// 繧ｹ繧ｱ繝ｼ繝ｫ繧｢繝九Γ繝ｼ繧ｷ繝ｧ繝ｳ
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
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _animation = Tween<double>(
      begin: widget.begin,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    ),);

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
    return ScaleTransition(
      scale: _animation,
      child: widget.child,
    );
  }
}

/// 邨・∩蜷医ｏ縺帙い繝九Γ繝ｼ繧ｷ繝ｧ繝ｳ・医ヵ繧ｧ繝ｼ繝・繧ｹ繝ｩ繧､繝会ｼ・
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

/// 繝ｪ繧ｹ繝育畑繧ｹ繧ｿ繧ｬ繝ｼ繧｢繝九Γ繝ｼ繧ｷ繝ｧ繝ｳ
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
          slideBegin: scrollDirection == Axis.vertical
              ? const Offset(0, 0.2)
              : const Offset(0.2, 0),
          child: children[index],
        );
      },
    );
  }
}

/// Reduce Motion蟇ｾ蠢懊い繝九Γ繝ｼ繧ｷ繝ｧ繝ｳ
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

/// 繧｢繝九Γ繝ｼ繧ｷ繝ｧ繝ｳ諡｡蠑ｵ
extension AnimationExtension on Widget {
  /// 繝輔ぉ繝ｼ繝峨う繝ｳ繧定ｿｽ蜉
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

  /// 繧ｹ繝ｩ繧､繝峨う繝ｳ繧定ｿｽ蜉
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

  /// 繧ｹ繧ｱ繝ｼ繝ｫ繧｢繝九Γ繝ｼ繧ｷ繝ｧ繝ｳ繧定ｿｽ蜉
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

  /// 繝輔ぉ繝ｼ繝・繧ｹ繝ｩ繧､繝峨ｒ霑ｽ蜉
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

  /// Reduce Motion蟇ｾ蠢・
  Widget withAccessibleAnimation(
    Widget Function(BuildContext, Widget) animationBuilder,
  ) {
    return AccessibleAnimation(
      animationBuilder: animationBuilder,
      child: this,
    );
  }
}
