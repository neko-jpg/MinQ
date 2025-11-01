import 'dart:async';
import 'package:flutter/material.dart';
import 'package:minq/presentation/common/onboarding/onboarding_engine.dart';

/// 一度だけ表示されるユーザー固有のスマートツールチップ
class SmartTooltip extends StatefulWidget {
  final Widget child;
  final String message;
  final String tooltipId;
  final TooltipTrigger trigger;
  final String? userId;
  final Duration showDuration;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final TextStyle? textStyle;
  final Decoration? decoration;
  final double? height;
  final bool preferBelow;
  final bool showOnce;

  const SmartTooltip({
    super.key,
    required this.child,
    required this.message,
    required this.tooltipId,
    this.trigger = TooltipTrigger.longPress,
    this.userId,
    this.showDuration = const Duration(seconds: 3),
    this.margin,
    this.padding,
    this.textStyle,
    this.decoration,
    this.height,
    this.preferBelow = true,
    this.showOnce = true,
  });

  @override
  State<SmartTooltip> createState() => _SmartTooltipState();
}

class _SmartTooltipState extends State<SmartTooltip>
    with SingleTickerProviderStateMixin {
  bool _shouldShow = true;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  Timer? _hideTimer;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _checkShouldShow();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );
  }

  Future<void> _checkShouldShow() async {
    if (widget.showOnce) {
      final hasSeenTooltip = await OnboardingEngine.hasSeenTooltip(
        widget.tooltipId,
      );
      setState(() {
        _shouldShow = !hasSeenTooltip;
      });
    }
  }

  Future<void> _markAsSeen() async {
    if (widget.showOnce) {
      await OnboardingEngine.markTooltipSeen(widget.tooltipId);
      setState(() {
        _shouldShow = false;
      });
    }
  }

  void _showTooltip() {
    if (!_shouldShow) return;

    _animationController.forward();

    // 自動的に非表示にする
    _hideTimer?.cancel();
    _hideTimer = Timer(widget.showDuration, () {
      if (mounted && _animationController.isCompleted) {
        _hideTooltip();
      }
    });
  }

  void _hideTooltip() {
    _hideTimer?.cancel();
    _animationController.reverse().then((_) {
      _markAsSeen();
    });
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_shouldShow) {
      return widget.child;
    }

    return GestureDetector(
      onTap: widget.trigger == TooltipTrigger.tap ? _showTooltip : null,
      onLongPress:
          widget.trigger == TooltipTrigger.longPress ? _showTooltip : null,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          widget.child,
          AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              if (_animationController.value == 0) {
                return const SizedBox.shrink();
              }

              return Positioned(
                top: widget.preferBelow ? null : -60,
                bottom: widget.preferBelow ? -60 : null,
                left: 0,
                right: 0,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: _buildTooltipContent(),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTooltipContent() {
    final theme = Theme.of(context);

    return Container(
      margin: widget.margin ?? const EdgeInsets.symmetric(horizontal: 16),
      padding: widget.padding ?? const EdgeInsets.all(12),
      height: widget.height,
      decoration:
          widget.decoration ??
          BoxDecoration(
            color: theme.colorScheme.inverseSurface,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha((255 * 0.1).round()),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: Text(
              widget.message,
              style:
                  widget.textStyle ??
                  theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onInverseSurface,
                  ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: _hideTooltip,
            child: Icon(
              Icons.close,
              size: 16,
              color: theme.colorScheme.onInverseSurface.withAlpha(
                (255 * 0.7).round(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// ツールチップのトリガー方法
enum TooltipTrigger { tap, longPress, manual }

/// 自動表示されるスマートツールチップ
class AutoSmartTooltip extends StatefulWidget {
  final Widget child;
  final String message;
  final String tooltipId;
  final Duration delay;
  final Duration showDuration;
  final bool showOnce;

  const AutoSmartTooltip({
    super.key,
    required this.child,
    required this.message,
    required this.tooltipId,
    this.delay = const Duration(milliseconds: 500),
    this.showDuration = const Duration(seconds: 3),
    this.showOnce = true,
  });

  @override
  State<AutoSmartTooltip> createState() => _AutoSmartTooltipState();
}

class _AutoSmartTooltipState extends State<AutoSmartTooltip>
    with SingleTickerProviderStateMixin {
  bool _shouldShow = true;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  Timer? _delayTimer;
  Timer? _hideTimer;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _checkAndShow();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  Future<void> _checkAndShow() async {
    if (widget.showOnce) {
      final hasSeenTooltip = await OnboardingEngine.hasSeenTooltip(
        widget.tooltipId,
      );
      if (hasSeenTooltip) {
        if (mounted) {
          setState(() {
            _shouldShow = false;
          });
        }
        return;
      }
    }

    // 遅延後に表示
    _delayTimer = Timer(widget.delay, () {
      if (mounted && _shouldShow) {
        _showTooltip();
      }
    });
  }

  void _showTooltip() {
    if (mounted) {
      _animationController.forward();

      // 自動的に非表示にする
      _hideTimer?.cancel();
      _hideTimer = Timer(widget.showDuration, () {
        if (mounted && _animationController.isCompleted) {
          _hideTooltip();
        }
      });
    }
  }

  void _hideTooltip() {
    if (mounted) {
      _hideTimer?.cancel();
      _animationController.reverse().then((_) {
        if (widget.showOnce) {
          OnboardingEngine.markTooltipSeen(widget.tooltipId);
        }
        if (mounted) {
          setState(() {
            _shouldShow = false;
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _delayTimer?.cancel();
    _hideTimer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        widget.child,
        if (_shouldShow)
          AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              if (_animationController.value == 0) {
                return const SizedBox.shrink();
              }

              return Positioned(
                top: -50,
                right: -10,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    child: _buildPulsingDot(),
                  ),
                ),
              );
            },
          ),
      ],
    );
  }

  Widget _buildPulsingDot() {
    return GestureDetector(
      onTap: _hideTooltip,
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Theme.of(
                context,
              ).colorScheme.primary.withAlpha((255 * 0.3).round()),
              blurRadius: 8,
              spreadRadius: 2,
            ),
          ],
        ),
        child: const Icon(Icons.help_outline, color: Colors.white, size: 16),
      ),
    );
  }
}
