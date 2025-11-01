import 'package:flutter/material.dart';
import 'package:minq/core/accessibility/accessibility_service.dart';

/// Widget that respects user's motion preferences and provides alternatives
class MotionAwareWidget extends StatelessWidget {
  final Widget child;
  final Widget? reducedMotionChild;
  final Duration? animationDuration;
  final Curve animationCurve;

  const MotionAwareWidget({
    super.key,
    required this.child,
    this.reducedMotionChild,
    this.animationDuration,
    this.animationCurve = Curves.easeInOut,
  });

  @override
  Widget build(BuildContext context) {
    final accessibilityService = AccessibilityService.instance;
    final settings = accessibilityService.getCurrentSettings(context);

    if (settings.reduceMotion) {
      return reducedMotionChild ?? _buildReducedMotionAlternative();
    }

    return child;
  }

  Widget _buildReducedMotionAlternative() {
    // Provide a static alternative when motion is reduced
    return AnimatedSwitcher(duration: Duration.zero, child: child);
  }
}

/// Animated container that respects motion preferences
class AccessibleAnimatedContainer extends StatelessWidget {
  final Widget child;
  final Duration duration;
  final Curve curve;
  final AlignmentGeometry? alignment;
  final EdgeInsetsGeometry? padding;
  final Color? color;
  final Decoration? decoration;
  final Decoration? foregroundDecoration;
  final double? width;
  final double? height;
  final BoxConstraints? constraints;
  final EdgeInsetsGeometry? margin;
  final Matrix4? transform;
  final AlignmentGeometry? transformAlignment;
  final Clip clipBehavior;

  const AccessibleAnimatedContainer({
    super.key,
    required this.child,
    required this.duration,
    this.curve = Curves.linear,
    this.alignment,
    this.padding,
    this.color,
    this.decoration,
    this.foregroundDecoration,
    this.width,
    this.height,
    this.constraints,
    this.margin,
    this.transform,
    this.transformAlignment,
    this.clipBehavior = Clip.none,
  });

  @override
  Widget build(BuildContext context) {
    final accessibilityService = AccessibilityService.instance;
    final adjustedDuration = accessibilityService.getAccessibleDuration(
      context,
      duration,
    );

    return AnimatedContainer(
      duration: adjustedDuration,
      curve: curve,
      alignment: alignment,
      padding: padding,
      color: color,
      decoration: decoration,
      foregroundDecoration: foregroundDecoration,
      width: width,
      height: height,
      constraints: constraints,
      margin: margin,
      transform: transform,
      transformAlignment: transformAlignment,
      clipBehavior: clipBehavior,
      child: child,
    );
  }
}

/// Animated opacity that respects motion preferences
class AccessibleAnimatedOpacity extends StatelessWidget {
  final Widget child;
  final double opacity;
  final Duration duration;
  final Curve curve;
  final VoidCallback? onEnd;
  final bool alwaysIncludeSemantics;

  const AccessibleAnimatedOpacity({
    super.key,
    required this.child,
    required this.opacity,
    required this.duration,
    this.curve = Curves.linear,
    this.onEnd,
    this.alwaysIncludeSemantics = false,
  });

  @override
  Widget build(BuildContext context) {
    final accessibilityService = AccessibilityService.instance;
    final adjustedDuration = accessibilityService.getAccessibleDuration(
      context,
      duration,
    );

    return AnimatedOpacity(
      opacity: opacity,
      duration: adjustedDuration,
      curve: curve,
      onEnd: onEnd,
      alwaysIncludeSemantics: alwaysIncludeSemantics,
      child: child,
    );
  }
}

/// Scale transition that respects motion preferences
class AccessibleScaleTransition extends StatelessWidget {
  final Widget child;
  final Animation<double> scale;
  final Alignment alignment;

  const AccessibleScaleTransition({
    super.key,
    required this.child,
    required this.scale,
    this.alignment = Alignment.center,
  });

  @override
  Widget build(BuildContext context) {
    final settings = AccessibilityService.instance.getCurrentSettings(context);

    if (settings.reduceMotion) {
      // Show final state without animation
      return Transform.scale(
        scale: scale.value,
        alignment: alignment,
        child: child,
      );
    }

    return ScaleTransition(scale: scale, alignment: alignment, child: child);
  }
}

/// Slide transition that respects motion preferences
class AccessibleSlideTransition extends StatelessWidget {
  final Widget child;
  final Animation<Offset> position;
  final TextDirection? textDirection;
  final bool transformHitTests;

  const AccessibleSlideTransition({
    super.key,
    required this.child,
    required this.position,
    this.textDirection,
    this.transformHitTests = true,
  });

  @override
  Widget build(BuildContext context) {
    final settings = AccessibilityService.instance.getCurrentSettings(context);

    if (settings.reduceMotion) {
      // Show final position without animation
      return FractionalTranslation(
        translation: position.value,
        transformHitTests: transformHitTests,
        child: child,
      );
    }

    return SlideTransition(
      position: position,
      textDirection: textDirection,
      transformHitTests: transformHitTests,
      child: child,
    );
  }
}

/// Fade transition that respects motion preferences
class AccessibleFadeTransition extends StatelessWidget {
  final Widget child;
  final Animation<double> opacity;
  final bool alwaysIncludeSemantics;

  const AccessibleFadeTransition({
    super.key,
    required this.child,
    required this.opacity,
    this.alwaysIncludeSemantics = false,
  });

  @override
  Widget build(BuildContext context) {
    final settings = AccessibilityService.instance.getCurrentSettings(context);

    if (settings.reduceMotion) {
      // Show final opacity without animation
      return Opacity(
        opacity: opacity.value,
        alwaysIncludeSemantics: alwaysIncludeSemantics,
        child: child,
      );
    }

    return FadeTransition(
      opacity: opacity,
      alwaysIncludeSemantics: alwaysIncludeSemantics,
      child: child,
    );
  }
}

/// Page transition that respects motion preferences
class AccessiblePageTransition extends PageRouteBuilder {
  final Widget child;
  final Duration duration;
  final Duration reverseDuration;

  AccessiblePageTransition({
    required this.child,
    this.duration = const Duration(milliseconds: 300),
    this.reverseDuration = const Duration(milliseconds: 300),
    super.settings,
  }) : super(
         pageBuilder: (context, animation, secondaryAnimation) => child,
         transitionDuration: duration,
         reverseTransitionDuration: reverseDuration,
         transitionsBuilder: (context, animation, secondaryAnimation, child) {
           final accessibilityService = AccessibilityService.instance;
           final accessibilitySettings = accessibilityService
               .getCurrentSettings(context);

           if (accessibilitySettings.reduceMotion) {
             // No transition animation
             return child;
           }

           // Standard slide transition
           return SlideTransition(
             position: Tween<Offset>(
               begin: const Offset(1.0, 0.0),
               end: Offset.zero,
             ).animate(
               CurvedAnimation(parent: animation, curve: Curves.easeInOut),
             ),
             child: child,
           );
         },
       );
}

/// Hero animation that respects motion preferences
class AccessibleHero extends StatelessWidget {
  final Object tag;
  final Widget child;
  final CreateRectTween? createRectTween;
  final HeroFlightShuttleBuilder? flightShuttleBuilder;
  final HeroPlaceholderBuilder? placeholderBuilder;
  final bool transitionOnUserGestures;

  const AccessibleHero({
    super.key,
    required this.tag,
    required this.child,
    this.createRectTween,
    this.flightShuttleBuilder,
    this.placeholderBuilder,
    this.transitionOnUserGestures = false,
  });

  @override
  Widget build(BuildContext context) {
    final settings = AccessibilityService.instance.getCurrentSettings(context);

    if (settings.reduceMotion) {
      // Skip hero animation
      return child;
    }

    return Hero(
      tag: tag,
      createRectTween: createRectTween,
      flightShuttleBuilder: flightShuttleBuilder,
      placeholderBuilder: placeholderBuilder,
      transitionOnUserGestures: transitionOnUserGestures,
      child: child,
    );
  }
}

/// Animated list that respects motion preferences
class AccessibleAnimatedList extends StatelessWidget {
  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;
  final Duration duration;
  final Axis scrollDirection;
  final bool reverse;
  final ScrollController? controller;
  final bool? primary;
  final ScrollPhysics? physics;
  final bool shrinkWrap;
  final EdgeInsetsGeometry? padding;

  const AccessibleAnimatedList({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.duration = const Duration(milliseconds: 300),
    this.scrollDirection = Axis.vertical,
    this.reverse = false,
    this.controller,
    this.primary,
    this.physics,
    this.shrinkWrap = false,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final settings = AccessibilityService.instance.getCurrentSettings(context);

    if (settings.reduceMotion) {
      // Use regular ListView without animations
      return ListView.builder(
        itemCount: itemCount,
        itemBuilder: itemBuilder,
        scrollDirection: scrollDirection,
        reverse: reverse,
        controller: controller,
        primary: primary,
        physics: physics,
        shrinkWrap: shrinkWrap,
        padding: padding,
      );
    }

    // Use AnimatedList for motion-enabled users
    return ListView.builder(
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return AccessibleAnimatedContainer(
          duration: Duration(milliseconds: 150 + (index * 50)),
          curve: Curves.easeOut,
          child: itemBuilder(context, index),
        );
      },
      scrollDirection: scrollDirection,
      reverse: reverse,
      controller: controller,
      primary: primary,
      physics: physics,
      shrinkWrap: shrinkWrap,
      padding: padding,
    );
  }
}
