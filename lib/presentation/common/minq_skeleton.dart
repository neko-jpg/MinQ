import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:minq/presentation/theme/minq_theme.dart';

class MinqSkeleton extends StatefulWidget {
  const MinqSkeleton({
    super.key,
    this.width,
    this.height,
    this.borderRadius,
  });

  final double? width;
  final double? height;
  final BorderRadius? borderRadius;

  @override
  State<MinqSkeleton> createState() => _MinqSkeletonState();
}

class _MinqSkeletonState extends State<MinqSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final baseColor = Theme.of(context).brightness == Brightness.dark
        ? tokens.surface.withValues(alpha: 0.35)
        : tokens.surface.withValues(alpha: 0.6);
    final highlightColor = Theme.of(context).brightness == Brightness.dark
        ? Colors.white.withValues(alpha: 0.25)
        : Colors.white.withValues(alpha: 0.6);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final shimmerPosition = _controller.value * 2 - 1;
        return ClipRRect(
          borderRadius: widget.borderRadius ?? tokens.cornerLarge(),
          child: ShaderMask(
            shaderCallback: (Rect bounds) {
              return LinearGradient(
                begin: Alignment(-1 - shimmerPosition, 0),
                end: Alignment(1 - shimmerPosition, 0),
                colors: <Color>[
                  baseColor,
                  highlightColor,
                  baseColor,
                ],
                stops: const <double>[0.25, 0.5, 0.75],
              ).createShader(bounds);
            },
            blendMode: BlendMode.srcATop,
            child: Container(
              width: widget.width,
              height: widget.height,
              color: baseColor,
            ),
          ),
        );
      },
    );
  }
}

class MinqSkeletonLine extends StatelessWidget {
  const MinqSkeletonLine({
    super.key,
    this.width,
    this.height = 12,
  });

  final double? width;
  final double height;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final radius = tokens.cornerMedium();
    return MinqSkeleton(
      width: width,
      height: height,
      borderRadius: radius,
    );
  }
}

class MinqSkeletonAvatar extends StatelessWidget {
  const MinqSkeletonAvatar({
    super.key,
    this.size,
  });

  final double? size;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final resolvedSize = size ?? tokens.spacing(14);
    return MinqSkeleton(
      width: resolvedSize,
      height: resolvedSize,
      borderRadius: BorderRadius.circular(resolvedSize / 2),
    );
  }
}

class MinqSkeletonList extends StatelessWidget {
  const MinqSkeletonList({
    super.key,
    this.itemCount = 3,
    this.itemHeight,
  });

  final int itemCount;
  final double? itemHeight;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final height = itemHeight ?? tokens.spacing(18);
    return Column(
      children: List<Widget>.generate(itemCount, (int index) {
        return Padding(
          padding: EdgeInsets.only(bottom: index == itemCount - 1
              ? 0
              : tokens.spacing(3)),
          child: MinqSkeleton(
            height: height,
            borderRadius: tokens.cornerLarge(),
          ),
        );
      }),
    );
  }
}

class MinqSkeletonGrid extends StatelessWidget {
  const MinqSkeletonGrid({
    super.key,
    this.crossAxisCount = 2,
    this.itemCount = 4,
    this.itemAspectRatio = 1.4,
  });

  final int crossAxisCount;
  final int itemCount;
  final double itemAspectRatio;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return LayoutBuilder(
      builder: (context, constraints) {
        final spacing = tokens.spacing(3);
        final totalSpacing = spacing * (crossAxisCount - 1);
        final itemWidth = (constraints.maxWidth - totalSpacing) / crossAxisCount;
        final itemHeight = itemWidth * itemAspectRatio;
        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: List<Widget>.generate(
            math.min(itemCount, crossAxisCount * ((itemCount / crossAxisCount).ceil())),
            (int index) {
              return SizedBox(
                width: itemWidth,
                height: itemHeight,
                child: MinqSkeleton(borderRadius: tokens.cornerLarge()),
              );
            },
          ),
        );
      },
    );
  }
}
