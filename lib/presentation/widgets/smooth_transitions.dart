import 'package:flutter/material.dart';

/// スムーズな画面遷移ウィジェット集
class SmoothTransitions {
  SmoothTransitions._();

  /// フェードトランジション
  static Widget fade({
    required Widget child,
    Duration duration = const Duration(milliseconds: 300),
    Curve curve = Curves.easeInOut,
  }) {
    return _FadeTransition(duration: duration, curve: curve, child: child);
  }

  /// スライドトランジション
  static Widget slide({
    required Widget child,
    Offset begin = const Offset(1.0, 0.0),
    Offset end = Offset.zero,
    Duration duration = const Duration(milliseconds: 300),
    Curve curve = Curves.easeInOut,
  }) {
    return _SlideTransition(
      begin: begin,
      end: end,
      duration: duration,
      curve: curve,
      child: child,
    );
  }

  /// スケールトランジション
  static Widget scale({
    required Widget child,
    double begin = 0.0,
    double end = 1.0,
    Duration duration = const Duration(milliseconds: 300),
    Curve curve = Curves.elasticOut,
  }) {
    return _ScaleTransition(
      begin: begin,
      end: end,
      duration: duration,
      curve: curve,
      child: child,
    );
  }

  /// 回転トランジション
  static Widget rotation({
    required Widget child,
    double begin = 0.0,
    double end = 1.0,
    Duration duration = const Duration(milliseconds: 500),
    Curve curve = Curves.easeInOut,
  }) {
    return _RotationTransition(
      begin: begin,
      end: end,
      duration: duration,
      curve: curve,
      child: child,
    );
  }

  /// 共有要素トランジション
  static Widget sharedElement({
    required String tag,
    required Widget child,
    Duration duration = const Duration(milliseconds: 400),
  }) {
    return Hero(
      tag: tag,
      flightShuttleBuilder: (
        context,
        animation,
        direction,
        fromContext,
        toContext,
      ) {
        return AnimatedBuilder(
          animation: animation,
          builder: (context, child) {
            return Transform.scale(
              scale: 1.0 + (animation.value * 0.1),
              child: Material(
                color: Colors.transparent,
                child: toContext.widget,
              ),
            );
          },
        );
      },
      child: child,
    );
  }

  /// カスタムページルート
  static PageRoute<T> customRoute<T>({
    required Widget page,
    TransitionType type = TransitionType.slide,
    Duration duration = const Duration(milliseconds: 300),
    Curve curve = Curves.easeInOut,
    Offset? slideBegin,
  }) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return _buildTransition(
          type: type,
          animation: animation,
          secondaryAnimation: secondaryAnimation,
          child: child,
          curve: curve,
          slideBegin: slideBegin,
        );
      },
    );
  }

  static Widget _buildTransition({
    required TransitionType type,
    required Animation<double> animation,
    required Animation<double> secondaryAnimation,
    required Widget child,
    required Curve curve,
    Offset? slideBegin,
  }) {
    final curvedAnimation = CurvedAnimation(parent: animation, curve: curve);

    switch (type) {
      case TransitionType.fade:
        return FadeTransition(opacity: curvedAnimation, child: child);

      case TransitionType.slide:
        return SlideTransition(
          position: Tween<Offset>(
            begin: slideBegin ?? const Offset(1.0, 0.0),
            end: Offset.zero,
          ).animate(curvedAnimation),
          child: child,
        );

      case TransitionType.scale:
        return ScaleTransition(scale: curvedAnimation, child: child);

      case TransitionType.rotation:
        return RotationTransition(turns: curvedAnimation, child: child);

      case TransitionType.slideUp:
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.0, 1.0),
            end: Offset.zero,
          ).animate(curvedAnimation),
          child: child,
        );

      case TransitionType.slideDown:
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.0, -1.0),
            end: Offset.zero,
          ).animate(curvedAnimation),
          child: child,
        );

      case TransitionType.scaleRotate:
        return ScaleTransition(
          scale: curvedAnimation,
          child: RotationTransition(
            turns: Tween<double>(
              begin: 0.0,
              end: 0.125,
            ).animate(curvedAnimation),
            child: child,
          ),
        );

      case TransitionType.slideScale:
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1.0, 0.0),
            end: Offset.zero,
          ).animate(curvedAnimation),
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.8, end: 1.0).animate(curvedAnimation),
            child: child,
          ),
        );
    }
  }
}

/// フェードトランジション
class _FadeTransition extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Curve curve;

  const _FadeTransition({
    required this.child,
    required this.duration,
    required this.curve,
  });

  @override
  State<_FadeTransition> createState() => _FadeTransitionState();
}

class _FadeTransitionState extends State<_FadeTransition>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);
    _animation = CurvedAnimation(parent: _controller, curve: widget.curve);
    _controller.forward();
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

/// スライドトランジション
class _SlideTransition extends StatefulWidget {
  final Widget child;
  final Offset begin;
  final Offset end;
  final Duration duration;
  final Curve curve;

  const _SlideTransition({
    required this.child,
    required this.begin,
    required this.end,
    required this.duration,
    required this.curve,
  });

  @override
  State<_SlideTransition> createState() => _SlideTransitionState();
}

class _SlideTransitionState extends State<_SlideTransition>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);
    _animation = Tween<Offset>(
      begin: widget.begin,
      end: widget.end,
    ).animate(CurvedAnimation(parent: _controller, curve: widget.curve));
    _controller.forward();
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

/// スケールトランジション
class _ScaleTransition extends StatefulWidget {
  final Widget child;
  final double begin;
  final double end;
  final Duration duration;
  final Curve curve;

  const _ScaleTransition({
    required this.child,
    required this.begin,
    required this.end,
    required this.duration,
    required this.curve,
  });

  @override
  State<_ScaleTransition> createState() => _ScaleTransitionState();
}

class _ScaleTransitionState extends State<_ScaleTransition>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);
    _animation = Tween<double>(
      begin: widget.begin,
      end: widget.end,
    ).animate(CurvedAnimation(parent: _controller, curve: widget.curve));
    _controller.forward();
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

/// 回転トランジション
class _RotationTransition extends StatefulWidget {
  final Widget child;
  final double begin;
  final double end;
  final Duration duration;
  final Curve curve;

  const _RotationTransition({
    required this.child,
    required this.begin,
    required this.end,
    required this.duration,
    required this.curve,
  });

  @override
  State<_RotationTransition> createState() => _RotationTransitionState();
}

class _RotationTransitionState extends State<_RotationTransition>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);
    _animation = Tween<double>(
      begin: widget.begin,
      end: widget.end,
    ).animate(CurvedAnimation(parent: _controller, curve: widget.curve));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(turns: _animation, child: widget.child);
  }
}

/// ステージングアニメーション - 複数要素の順次アニメーション
class StagedAnimation extends StatefulWidget {
  final List<Widget> children;
  final Duration staggerDelay;
  final Duration itemDuration;
  final Curve curve;
  final Axis direction;

  const StagedAnimation({
    super.key,
    required this.children,
    this.staggerDelay = const Duration(milliseconds: 100),
    this.itemDuration = const Duration(milliseconds: 300),
    this.curve = Curves.easeOut,
    this.direction = Axis.vertical,
  });

  @override
  State<StagedAnimation> createState() => _StagedAnimationState();
}

class _StagedAnimationState extends State<StagedAnimation>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimations();
  }

  void _initializeAnimations() {
    _controllers = List.generate(
      widget.children.length,
      (index) =>
          AnimationController(duration: widget.itemDuration, vsync: this),
    );

    _animations =
        _controllers.map((controller) {
          return CurvedAnimation(parent: controller, curve: widget.curve);
        }).toList();
  }

  void _startAnimations() {
    for (int i = 0; i < _controllers.length; i++) {
      Future.delayed(widget.staggerDelay * i, () {
        if (mounted) {
          _controllers[i].forward();
        }
      });
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.direction == Axis.vertical
        ? Column(children: _buildAnimatedChildren())
        : Row(children: _buildAnimatedChildren());
  }

  List<Widget> _buildAnimatedChildren() {
    return List.generate(widget.children.length, (index) {
      return AnimatedBuilder(
        animation: _animations[index],
        builder: (context, child) {
          return Transform.translate(
            offset:
                widget.direction == Axis.vertical
                    ? Offset(0, 50 * (1 - _animations[index].value))
                    : Offset(50 * (1 - _animations[index].value), 0),
            child: Opacity(
              opacity: _animations[index].value,
              child: widget.children[index],
            ),
          );
        },
      );
    });
  }
}

/// モーフィングコンテナ - 形状変化アニメーション
class MorphingContainer extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final BorderRadius? borderRadius;
  final Color? color;
  final double? width;
  final double? height;
  final EdgeInsets? padding;
  final EdgeInsets? margin;

  const MorphingContainer({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 400),
    this.borderRadius,
    this.color,
    this.width,
    this.height,
    this.padding,
    this.margin,
  });

  @override
  State<MorphingContainer> createState() => _MorphingContainerState();
}

class _MorphingContainerState extends State<MorphingContainer> {
  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: widget.duration,
      curve: Curves.easeInOut,
      width: widget.width,
      height: widget.height,
      padding: widget.padding,
      margin: widget.margin,
      decoration: BoxDecoration(
        color: widget.color,
        borderRadius: widget.borderRadius,
      ),
      child: widget.child,
    );
  }
}

/// パララックス効果
class ParallaxWidget extends StatefulWidget {
  final Widget child;
  final double speed;
  final Axis direction;

  const ParallaxWidget({
    super.key,
    required this.child,
    this.speed = 0.5,
    this.direction = Axis.vertical,
  });

  @override
  State<ParallaxWidget> createState() => _ParallaxWidgetState();
}

class _ParallaxWidgetState extends State<ParallaxWidget> {
  late ScrollController _scrollController;
  double _offset = 0.0;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_updateOffset);
  }

  void _updateOffset() {
    setState(() {
      _offset = _scrollController.offset * widget.speed;
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_updateOffset);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset:
          widget.direction == Axis.vertical
              ? Offset(0, -_offset)
              : Offset(-_offset, 0),
      child: widget.child,
    );
  }
}

/// トランジションタイプ
enum TransitionType {
  fade,
  slide,
  scale,
  rotation,
  slideUp,
  slideDown,
  scaleRotate,
  slideScale,
}
