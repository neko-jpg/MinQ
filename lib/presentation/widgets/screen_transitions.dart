import 'package:flutter/material.dart';

/// Enhanced screen transitions for smooth navigation
/// Provides polished page transitions and route animations

/// Custom page route with enhanced transitions
class PolishedPageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;
  final TransitionType transitionType;
  final Duration duration;
  final Duration reverseDuration;
  final Curve curve;
  final Curve reverseCurve;

  PolishedPageRoute({
    required this.page,
    this.transitionType = TransitionType.slideFromRight,
    this.duration = const Duration(milliseconds: 300),
    this.reverseDuration = const Duration(milliseconds: 250),
    this.curve = Curves.easeOutCubic,
    this.reverseCurve = Curves.easeInCubic,
    super.settings,
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionDuration: duration,
          reverseTransitionDuration: reverseDuration,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return _buildTransition(
              child: child,
              animation: animation,
              secondaryAnimation: secondaryAnimation,
              type: transitionType,
              curve: curve,
              reverseCurve: reverseCurve,
            );
          },
        );

  static Widget _buildTransition({
    required Widget child,
    required Animation<double> animation,
    required Animation<double> secondaryAnimation,
    required TransitionType type,
    required Curve curve,
    required Curve reverseCurve,
  }) {
    final curvedAnimation = CurvedAnimation(
      parent: animation,
      curve: curve,
      reverseCurve: reverseCurve,
    );

    switch (type) {
      case TransitionType.fade:
        return FadeTransition(
          opacity: curvedAnimation,
          child: child,
        );

      case TransitionType.slideFromRight:
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1.0, 0.0),
            end: Offset.zero,
          ).animate(curvedAnimation),
          child: child,
        );

      case TransitionType.slideFromLeft:
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(-1.0, 0.0),
            end: Offset.zero,
          ).animate(curvedAnimation),
          child: child,
        );

      case TransitionType.slideFromBottom:
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.0, 1.0),
            end: Offset.zero,
          ).animate(curvedAnimation),
          child: child,
        );

      case TransitionType.slideFromTop:
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.0, -1.0),
            end: Offset.zero,
          ).animate(curvedAnimation),
          child: child,
        );

      case TransitionType.scale:
        return ScaleTransition(
          scale: Tween<double>(
            begin: 0.8,
            end: 1.0,
          ).animate(curvedAnimation),
          child: FadeTransition(
            opacity: curvedAnimation,
            child: child,
          ),
        );

      case TransitionType.scaleFromCenter:
        return ScaleTransition(
          scale: curvedAnimation,
          child: child,
        );

      case TransitionType.rotation:
        return RotationTransition(
          turns: Tween<double>(
            begin: 0.0,
            end: 1.0,
          ).animate(curvedAnimation),
          child: child,
        );

      case TransitionType.slideAndFade:
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.3, 0.0),
            end: Offset.zero,
          ).animate(curvedAnimation),
          child: FadeTransition(
            opacity: curvedAnimation,
            child: child,
          ),
        );

      case TransitionType.scaleAndRotate:
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

      case TransitionType.morphing:
        return _MorphingTransition(
          animation: curvedAnimation,
          child: child,
        );
    }
  }
}

/// Morphing transition with shape changes
class _MorphingTransition extends StatelessWidget {
  final Animation<double> animation;
  final Widget child;

  const _MorphingTransition({
    required this.animation,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final progress = animation.value;
        
        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateY(progress * 0.5)
            // ignore: deprecated_member_use
            ..scale(0.8 + (0.2 * progress)),
          child: Opacity(
            opacity: progress,
            child: this.child,
          ),
        );
      },
    );
  }
}

/// Shared element transition for hero animations
class SharedElementTransition extends StatelessWidget {
  final String tag;
  final Widget child;
  final Duration duration;

  const SharedElementTransition({
    super.key,
    required this.tag,
    required this.child,
    this.duration = const Duration(milliseconds: 400),
  });

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: tag,
      transitionOnUserGestures: true,
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
            return Transform(
              // ignore: deprecated_member_use
              transform: Matrix4.identity()..scale(1.0 + (animation.value * 0.1)),
              alignment: Alignment.center,
              child: Material(
                color: Colors.transparent,
                child: direction == HeroFlightDirection.push
                    ? toContext.widget
                    : fromContext.widget,
              ),
            );
          },
        );
      },
      child: child,
    );
  }
}

/// Modal transition for bottom sheets and dialogs
class ModalTransition extends StatelessWidget {
  final Widget child;
  final ModalType type;
  final Duration duration;

  const ModalTransition({
    super.key,
    required this.child,
    this.type = ModalType.bottomSheet,
    this.duration = const Duration(milliseconds: 300),
  });

  @override
  Widget build(BuildContext context) {
    switch (type) {
      case ModalType.bottomSheet:
        return _BottomSheetTransition(
          duration: duration,
          child: child,
        );
      case ModalType.dialog:
        return _DialogTransition(
          duration: duration,
          child: child,
        );
      case ModalType.fullScreen:
        return _FullScreenTransition(
          duration: duration,
          child: child,
        );
    }
  }
}

class _BottomSheetTransition extends StatefulWidget {
  final Widget child;
  final Duration duration;

  const _BottomSheetTransition({
    required this.child,
    required this.duration,
  });

  @override
  State<_BottomSheetTransition> createState() => _BottomSheetTransitionState();
}

class _BottomSheetTransitionState extends State<_BottomSheetTransition>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 1.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Stack(
          children: [
            // Background overlay
            FadeTransition(
              opacity: _fadeAnimation,
              child: Container(
                color: Colors.black54,
              ),
            ),
            // Bottom sheet content
            SlideTransition(
              position: _slideAnimation,
              child: widget.child,
            ),
          ],
        );
      },
    );
  }
}

class _DialogTransition extends StatefulWidget {
  final Widget child;
  final Duration duration;

  const _DialogTransition({
    required this.child,
    required this.duration,
  });

  @override
  State<_DialogTransition> createState() => _DialogTransitionState();
}

class _DialogTransitionState extends State<_DialogTransition>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Stack(
          children: [
            // Background overlay
            FadeTransition(
              opacity: _fadeAnimation,
              child: Container(
                color: Colors.black54,
              ),
            ),
            // Dialog content
            Center(
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: widget.child,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _FullScreenTransition extends StatefulWidget {
  final Widget child;
  final Duration duration;

  const _FullScreenTransition({
    required this.child,
    required this.duration,
  });

  @override
  State<_FullScreenTransition> createState() => _FullScreenTransitionState();
}

class _FullScreenTransitionState extends State<_FullScreenTransition>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.9,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ScaleTransition(
          scale: _scaleAnimation,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: widget.child,
          ),
        );
      },
    );
  }
}

/// Page transition wrapper for easy usage
class PageTransition extends StatelessWidget {
  final Widget child;
  final TransitionType type;
  final Duration duration;
  final Curve curve;

  const PageTransition({
    super.key,
    required this.child,
    this.type = TransitionType.slideFromRight,
    this.duration = const Duration(milliseconds: 300),
    this.curve = Curves.easeOutCubic,
  });

  @override
  Widget build(BuildContext context) {
    return child;
  }

  /// Create a route with this transition
  static Route<T> createRoute<T>({
    required Widget page,
    TransitionType type = TransitionType.slideFromRight,
    Duration duration = const Duration(milliseconds: 300),
    Curve curve = Curves.easeOutCubic,
    RouteSettings? settings,
  }) {
    return PolishedPageRoute<T>(
      page: page,
      transitionType: type,
      duration: duration,
      curve: curve,
      settings: settings,
    );
  }
}

/// Transition types enum
enum TransitionType {
  fade,
  slideFromRight,
  slideFromLeft,
  slideFromBottom,
  slideFromTop,
  scale,
  scaleFromCenter,
  rotation,
  slideAndFade,
  scaleAndRotate,
  morphing,
}

/// Modal types enum
enum ModalType {
  bottomSheet,
  dialog,
  fullScreen,
}

/// Navigation extensions for easy usage
extension NavigatorTransitions on NavigatorState {
  /// Push with custom transition
  Future<T?> pushWithTransition<T extends Object?>(
    Widget page, {
    TransitionType type = TransitionType.slideFromRight,
    Duration duration = const Duration(milliseconds: 300),
    Curve curve = Curves.easeOutCubic,
  }) {
    return push<T>(
      PageTransition.createRoute<T>(
        page: page,
        type: type,
        duration: duration,
        curve: curve,
      ),
    );
  }

  /// Push replacement with custom transition
  Future<T?> pushReplacementWithTransition<T extends Object?, TO extends Object?>(
    Widget page, {
    TransitionType type = TransitionType.slideFromRight,
    Duration duration = const Duration(milliseconds: 300),
    Curve curve = Curves.easeOutCubic,
    TO? result,
  }) {
    return pushReplacement<T, TO>(
      PageTransition.createRoute<T>(
        page: page,
        type: type,
        duration: duration,
        curve: curve,
      ),
      result: result,
    );
  }
}