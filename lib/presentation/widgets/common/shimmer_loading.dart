import 'package:flutter/material.dart';

/// Shimmer loading effect widget for skeleton screens
class ShimmerLoading extends StatefulWidget {
  const ShimmerLoading({
    super.key,
    required this.child,
    this.baseColor,
    this.highlightColor,
    this.period = const Duration(milliseconds: 1500),
    this.direction = ShimmerDirection.ltr,
  });

  final Widget child;
  final Color? baseColor;
  final Color? highlightColor;
  final Duration period;
  final ShimmerDirection direction;

  @override
  State<ShimmerLoading> createState() => _ShimmerLoadingState();
}

class _ShimmerLoadingState extends State<ShimmerLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.period, vsync: this);

    _animation = Tween<double>(
      begin: -1.0,
      end: 2.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final baseColor =
        widget.baseColor ??
        Theme.of(context).colorScheme.surface.withAlpha((255 * 0.3).round());
    final highlightColor =
        widget.highlightColor ??
        Theme.of(context).colorScheme.surface.withAlpha((255 * 0.1).round());

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              colors: [baseColor, highlightColor, baseColor],
              stops: const [0.0, 0.5, 1.0],
              begin: _getBeginAlignment(),
              end: _getEndAlignment(),
              transform: _SlideGradientTransform(_animation.value),
            ).createShader(bounds);
          },
          child: widget.child,
        );
      },
    );
  }

  Alignment _getBeginAlignment() {
    switch (widget.direction) {
      case ShimmerDirection.ltr:
        return Alignment.centerLeft;
      case ShimmerDirection.rtl:
        return Alignment.centerRight;
      case ShimmerDirection.ttb:
        return Alignment.topCenter;
      case ShimmerDirection.btt:
        return Alignment.bottomCenter;
    }
  }

  Alignment _getEndAlignment() {
    switch (widget.direction) {
      case ShimmerDirection.ltr:
        return Alignment.centerRight;
      case ShimmerDirection.rtl:
        return Alignment.centerLeft;
      case ShimmerDirection.ttb:
        return Alignment.bottomCenter;
      case ShimmerDirection.btt:
        return Alignment.topCenter;
    }
  }
}

class _SlideGradientTransform extends GradientTransform {
  const _SlideGradientTransform(this.slidePercent);

  final double slidePercent;

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    return Matrix4.translationValues(bounds.width * slidePercent, 0.0, 0.0);
  }
}

enum ShimmerDirection {
  ltr, // Left to right
  rtl, // Right to left
  ttb, // Top to bottom
  btt, // Bottom to top
}

/// Pre-built shimmer skeleton widgets
class ShimmerSkeletons {
  /// Text line skeleton
  static Widget textLine({
    double? width,
    double height = 16.0,
    BorderRadius? borderRadius,
  }) {
    return ShimmerLoading(
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: borderRadius ?? BorderRadius.circular(4),
        ),
      ),
    );
  }

  /// Avatar skeleton
  static Widget avatar({double size = 40.0, bool isCircular = true}) {
    return ShimmerLoading(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: isCircular ? BoxShape.circle : BoxShape.rectangle,
          borderRadius: isCircular ? null : BorderRadius.circular(8),
        ),
      ),
    );
  }

  /// Card skeleton
  static Widget card({
    double? width,
    double height = 120.0,
    EdgeInsets? margin,
    BorderRadius? borderRadius,
  }) {
    return ShimmerLoading(
      child: Container(
        width: width,
        height: height,
        margin: margin ?? const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: borderRadius ?? BorderRadius.circular(12),
        ),
      ),
    );
  }

  /// List tile skeleton
  static Widget listTile({
    bool showAvatar = true,
    bool showTrailing = false,
    EdgeInsets? padding,
  }) {
    return Container(
      padding: padding ?? const EdgeInsets.all(16),
      child: Row(
        children: [
          if (showAvatar) ...[avatar(), const SizedBox(width: 16)],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                textLine(width: double.infinity),
                const SizedBox(height: 8),
                textLine(width: 200),
              ],
            ),
          ),
          if (showTrailing) ...[const SizedBox(width: 16), textLine(width: 60)],
        ],
      ),
    );
  }

  /// Challenge card skeleton
  static Widget challengeCard() {
    return ShimmerLoading(
      child: Container(
        height: 200,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  avatar(size: 48, isCircular: false),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        textLine(width: double.infinity, height: 20),
                        const SizedBox(height: 8),
                        textLine(width: 150, height: 14),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              textLine(width: double.infinity, height: 14),
              const SizedBox(height: 8),
              textLine(width: 250, height: 14),
              const Spacer(),
              Row(
                children: [
                  textLine(
                    width: 80,
                    height: 24,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  const Spacer(),
                  textLine(width: 60, height: 14),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
