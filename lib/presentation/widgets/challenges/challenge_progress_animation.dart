import 'package:flutter/material.dart';

/// Animated progress bar for challenges with smooth transitions and effects
class ChallengeProgressAnimation extends StatefulWidget {
  const ChallengeProgressAnimation({
    super.key,
    required this.progress,
    this.isCompleted = false,
    this.height = 8.0,
    this.backgroundColor,
    this.progressColor,
    this.completedColor,
    this.animationDuration = const Duration(milliseconds: 800),
    this.showShimmer = true,
  });

  final double progress; // 0.0 to 1.0
  final bool isCompleted;
  final double height;
  final Color? backgroundColor;
  final Color? progressColor;
  final Color? completedColor;
  final Duration animationDuration;
  final bool showShimmer;

  @override
  State<ChallengeProgressAnimation> createState() =>
      _ChallengeProgressAnimationState();
}

class _ChallengeProgressAnimationState extends State<ChallengeProgressAnimation>
    with TickerProviderStateMixin {
  late AnimationController _progressController;
  late AnimationController _shimmerController;
  late Animation<double> _progressAnimation;
  late Animation<double> _shimmerAnimation;

  @override
  void initState() {
    super.initState();

    _progressController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: widget.progress.clamp(0.0, 1.0),
    ).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeOutCubic),
    );

    _shimmerAnimation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _shimmerController, curve: Curves.easeInOut),
    );

    // Start animations
    _progressController.forward();

    if (widget.showShimmer && !widget.isCompleted) {
      _shimmerController.repeat();
    }
  }

  @override
  void didUpdateWidget(ChallengeProgressAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.progress != widget.progress) {
      _progressAnimation = Tween<double>(
        begin: _progressAnimation.value,
        end: widget.progress.clamp(0.0, 1.0),
      ).animate(
        CurvedAnimation(
          parent: _progressController,
          curve: Curves.easeOutCubic,
        ),
      );

      _progressController.reset();
      _progressController.forward();
    }

    if (widget.showShimmer &&
        !widget.isCompleted &&
        !_shimmerController.isAnimating) {
      _shimmerController.repeat();
    } else if (!widget.showShimmer || widget.isCompleted) {
      _shimmerController.stop();
    }
  }

  @override
  void dispose() {
    _progressController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final backgroundColor =
        widget.backgroundColor ?? Colors.white.withOpacity(0.3);
    final progressColor = widget.progressColor ?? Colors.white;
    final completedColor = widget.completedColor ?? Colors.green.shade200;

    return AnimatedBuilder(
      animation: Listenable.merge([_progressAnimation, _shimmerAnimation]),
      builder: (context, child) {
        return Container(
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.height / 2),
            color: backgroundColor,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(widget.height / 2),
            child: Stack(
              children: [
                // Progress bar
                FractionallySizedBox(
                  widthFactor: _progressAnimation.value,
                  child: Container(
                    height: widget.height,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors:
                            widget.isCompleted
                                ? [
                                  completedColor,
                                  completedColor.withOpacity(0.8),
                                ]
                                : [
                                  progressColor,
                                  progressColor.withOpacity(0.8),
                                ],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                    ),
                  ),
                ),

                // Shimmer effect
                if (widget.showShimmer &&
                    !widget.isCompleted &&
                    _progressAnimation.value > 0)
                  _buildShimmerEffect(progressColor),

                // Completion glow effect
                if (widget.isCompleted) _buildCompletionGlow(completedColor),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildShimmerEffect(Color baseColor) {
    return Positioned.fill(
      child: Transform.translate(
        offset: Offset(_shimmerAnimation.value * 200, 0),
        child: Container(
          width: 50,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.transparent,
                baseColor.withOpacity(0.4),
                Colors.transparent,
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCompletionGlow(Color glowColor) {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(widget.height / 2),
          boxShadow: [
            BoxShadow(
              color: glowColor.withOpacity(0.6),
              blurRadius: 8,
              spreadRadius: 2,
            ),
          ],
        ),
      ),
    );
  }
}

/// Circular progress indicator for challenges
class ChallengeCircularProgress extends StatefulWidget {
  const ChallengeCircularProgress({
    super.key,
    required this.progress,
    this.size = 60.0,
    this.strokeWidth = 6.0,
    this.backgroundColor,
    this.progressColor,
    this.completedColor,
    this.showPercentage = true,
    this.animationDuration = const Duration(milliseconds: 1000),
  });

  final double progress; // 0.0 to 1.0
  final double size;
  final double strokeWidth;
  final Color? backgroundColor;
  final Color? progressColor;
  final Color? completedColor;
  final bool showPercentage;
  final Duration animationDuration;

  @override
  State<ChallengeCircularProgress> createState() =>
      _ChallengeCircularProgressState();
}

class _ChallengeCircularProgressState extends State<ChallengeCircularProgress>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    _animation = Tween<double>(
      begin: 0.0,
      end: widget.progress.clamp(0.0, 1.0),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _controller.forward();
  }

  @override
  void didUpdateWidget(ChallengeCircularProgress oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.progress != widget.progress) {
      _animation = Tween<double>(
        begin: _animation.value,
        end: widget.progress.clamp(0.0, 1.0),
      ).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
      );

      _controller.reset();
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final backgroundColor =
        widget.backgroundColor ?? Colors.grey.withOpacity(0.3);
    final progressColor =
        widget.progressColor ?? Theme.of(context).primaryColor;
    final completedColor = widget.completedColor ?? Colors.green;
    final isCompleted = widget.progress >= 1.0;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return SizedBox(
          width: widget.size,
          height: widget.size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Background circle
              SizedBox(
                width: widget.size,
                height: widget.size,
                child: CircularProgressIndicator(
                  value: 1.0,
                  strokeWidth: widget.strokeWidth,
                  valueColor: AlwaysStoppedAnimation(backgroundColor),
                ),
              ),

              // Progress circle
              SizedBox(
                width: widget.size,
                height: widget.size,
                child: CircularProgressIndicator(
                  value: _animation.value,
                  strokeWidth: widget.strokeWidth,
                  valueColor: AlwaysStoppedAnimation(
                    isCompleted ? completedColor : progressColor,
                  ),
                ),
              ),

              // Center content
              if (widget.showPercentage)
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isCompleted)
                      Icon(
                        Icons.check,
                        color: completedColor,
                        size: widget.size * 0.3,
                      )
                    else
                      Text(
                        '${(_animation.value * 100).toInt()}%',
                        style: TextStyle(
                          fontSize: widget.size * 0.2,
                          fontWeight: FontWeight.bold,
                          color: isCompleted ? completedColor : progressColor,
                        ),
                      ),
                  ],
                ),
            ],
          ),
        );
      },
    );
  }
}
