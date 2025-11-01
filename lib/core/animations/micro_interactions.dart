import 'package:flutter/material.dart';
import 'package:minq/core/animations/animation_system.dart';

/// マイクロインタラクションシステム（要件46、47、48）
class MicroInteractions {
  static final AnimationSystem _animationSystem = AnimationSystem.instance;

  /// ボタンプレスエフェクト
  static Widget buttonPress({
    required Widget child,
    required VoidCallback onPressed,
    double scaleDown = 0.95,
    Duration? duration,
    Color? splashColor,
    Color? highlightColor,
  }) {
    return _PressableWidget(
      onPressed: onPressed,
      scaleDown: scaleDown,
      duration: duration ?? const Duration(milliseconds: 100),
      splashColor: splashColor,
      highlightColor: highlightColor,
      child: child,
    );
  }

  /// ハートアニメーション（いいね機能）
  static Widget heartLike({
    required bool isLiked,
    required ValueChanged<bool> onChanged,
    Color? likedColor,
    Color? unlikedColor,
    double size = 24.0,
    Duration? duration,
  }) {
    return _HeartLikeWidget(
      isLiked: isLiked,
      onChanged: onChanged,
      likedColor: likedColor ?? Colors.red,
      unlikedColor: unlikedColor ?? Colors.grey,
      size: size,
      duration: duration ?? const Duration(milliseconds: 300),
    );
  }

  /// フローティングアクションボタンの拡張アニメーション
  static Widget expandingFAB({
    required List<FABAction> actions,
    required Widget mainIcon,
    Color? backgroundColor,
    Color? foregroundColor,
    Duration? duration,
  }) {
    return _ExpandingFABWidget(
      actions: actions,
      mainIcon: mainIcon,
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      duration: duration ?? const Duration(milliseconds: 300),
    );
  }

  /// プルトゥリフレッシュインジケーター
  static Widget pullToRefresh({
    required Widget child,
    required Future<void> Function() onRefresh,
    Color? color,
    Color? backgroundColor,
  }) {
    return RefreshIndicator(
      onRefresh: () async {
        await _animationSystem.playMicroInteractionHaptic();
        await onRefresh();
        await _animationSystem.playSuccessHaptic();
      },
      color: color,
      backgroundColor: backgroundColor,
      child: child,
    );
  }

  /// スワイプアクション
  static Widget swipeAction({
    required Widget child,
    List<SwipeAction>? leftActions,
    List<SwipeAction>? rightActions,
    double threshold = 0.3,
  }) {
    return _SwipeActionWidget(
      leftActions: leftActions ?? [],
      rightActions: rightActions ?? [],
      threshold: threshold,
      child: child,
    );
  }

  /// ローディングドット
  static Widget loadingDots({
    int dotCount = 3,
    Color? color,
    double size = 8.0,
    Duration? duration,
  }) {
    return _LoadingDotsWidget(
      dotCount: dotCount,
      color: color ?? Colors.blue,
      size: size,
      duration: duration ?? const Duration(milliseconds: 1200),
    );
  }

  /// 波紋エフェクト
  static Widget ripple({
    required Widget child,
    required VoidCallback onTap,
    Color? rippleColor,
    BorderRadius? borderRadius,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          _animationSystem.playMicroInteractionHaptic();
          onTap();
        },
        splashColor: rippleColor?.withOpacity(0.3),
        highlightColor: rippleColor?.withOpacity(0.1),
        borderRadius: borderRadius,
        child: child,
      ),
    );
  }

  /// 長押しエフェクト
  static Widget longPress({
    required Widget child,
    required VoidCallback onLongPress,
    Duration? duration,
    double scaleDown = 0.9,
  }) {
    return _LongPressWidget(
      onLongPress: onLongPress,
      duration: duration ?? const Duration(milliseconds: 500),
      scaleDown: scaleDown,
      child: child,
    );
  }

  /// ドラッグアンドドロップ
  static Widget draggable({
    required Widget child,
    required Widget feedback,
    Widget? childWhenDragging,
    VoidCallback? onDragStarted,
    VoidCallback? onDragEnd,
    dynamic data,
  }) {
    return Draggable(
      data: data,
      feedback: feedback,
      childWhenDragging: childWhenDragging,
      onDragStarted: () {
        _animationSystem.playMicroInteractionHaptic();
        onDragStarted?.call();
      },
      onDragEnd: (details) {
        _animationSystem.playMicroInteractionHaptic();
        onDragEnd?.call();
      },
      child: child,
    );
  }
}

/// プレス可能ウィジェット
class _PressableWidget extends StatefulWidget {
  final Widget child;
  final VoidCallback onPressed;
  final double scaleDown;
  final Duration duration;
  final Color? splashColor;
  final Color? highlightColor;

  const _PressableWidget({
    required this.child,
    required this.onPressed,
    required this.scaleDown,
    required this.duration,
    this.splashColor,
    this.highlightColor,
  });

  @override
  State<_PressableWidget> createState() => _PressableWidgetState();
}

class _PressableWidgetState extends State<_PressableWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(duration: widget.duration, vsync: this);

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: widget.scaleDown,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        if (AnimationSystem.instance.animationsEnabled) {
          _controller.forward();
        }
      },
      onTapUp: (_) {
        if (AnimationSystem.instance.animationsEnabled) {
          _controller.reverse();
        }
        AnimationSystem.instance.playMicroInteractionHaptic();
        widget.onPressed();
      },
      onTapCancel: () {
        if (AnimationSystem.instance.animationsEnabled) {
          _controller.reverse();
        }
      },
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: widget.child,
          );
        },
      ),
    );
  }
}

/// ハートライクウィジェット
class _HeartLikeWidget extends StatefulWidget {
  final bool isLiked;
  final ValueChanged<bool> onChanged;
  final Color likedColor;
  final Color unlikedColor;
  final double size;
  final Duration duration;

  const _HeartLikeWidget({
    required this.isLiked,
    required this.onChanged,
    required this.likedColor,
    required this.unlikedColor,
    required this.size,
    required this.duration,
  });

  @override
  State<_HeartLikeWidget> createState() => _HeartLikeWidgetState();
}

class _HeartLikeWidgetState extends State<_HeartLikeWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(duration: widget.duration, vsync: this);

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    _rotationAnimation = Tween<double>(begin: 0.0, end: 0.1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.3, curve: Curves.easeInOut),
      ),
    );

    if (widget.isLiked) {
      _controller.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(_HeartLikeWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isLiked != oldWidget.isLiked) {
      if (widget.isLiked) {
        _controller.forward();
        AnimationSystem.instance.playSuccessHaptic();
      } else {
        _controller.reverse();
        AnimationSystem.instance.playMicroInteractionHaptic();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        widget.onChanged(!widget.isLiked);
      },
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Transform.rotate(
              angle: _rotationAnimation.value,
              child: Icon(
                widget.isLiked ? Icons.favorite : Icons.favorite_border,
                color: widget.isLiked ? widget.likedColor : widget.unlikedColor,
                size: widget.size,
              ),
            ),
          );
        },
      ),
    );
  }
}

/// FABアクション
class FABAction {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final Color? backgroundColor;
  final Color? foregroundColor;

  const FABAction({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.backgroundColor,
    this.foregroundColor,
  });
}

/// 拡張FABウィジェット
class _ExpandingFABWidget extends StatefulWidget {
  final List<FABAction> actions;
  final Widget mainIcon;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final Duration duration;

  const _ExpandingFABWidget({
    required this.actions,
    required this.mainIcon,
    this.backgroundColor,
    this.foregroundColor,
    required this.duration,
  });

  @override
  State<_ExpandingFABWidget> createState() => _ExpandingFABWidgetState();
}

class _ExpandingFABWidgetState extends State<_ExpandingFABWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _expandAnimation;
  late Animation<double> _rotationAnimation;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(duration: widget.duration, vsync: this);

    _expandAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 0.75, // 3/4 rotation
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() {
      _isExpanded = !_isExpanded;
    });

    if (_isExpanded) {
      _controller.forward();
    } else {
      _controller.reverse();
    }

    AnimationSystem.instance.playMicroInteractionHaptic();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // アクションボタン
        ...widget.actions.asMap().entries.map((entry) {
          final index = entry.key;
          final action = entry.value;

          return AnimatedBuilder(
            animation: _expandAnimation,
            builder: (context, child) {
              final delay = index * 0.1;
              final animationValue = (_expandAnimation.value - delay).clamp(
                0.0,
                1.0,
              );

              return Transform.scale(
                scale: animationValue,
                child: Opacity(
                  opacity: animationValue,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // ラベル
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black87,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            action.label,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        // アクションボタン
                        FloatingActionButton(
                          mini: true,
                          backgroundColor: action.backgroundColor,
                          foregroundColor: action.foregroundColor,
                          onPressed: () {
                            action.onPressed();
                            _toggle();
                          },
                          child: Icon(action.icon),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        }),

        // メインFAB
        FloatingActionButton(
          backgroundColor: widget.backgroundColor,
          foregroundColor: widget.foregroundColor,
          onPressed: _toggle,
          child: AnimatedBuilder(
            animation: _rotationAnimation,
            builder: (context, child) {
              return Transform.rotate(
                angle: _rotationAnimation.value * 2 * 3.14159,
                child: _isExpanded ? const Icon(Icons.close) : widget.mainIcon,
              );
            },
          ),
        ),
      ],
    );
  }
}

/// スワイプアクション
class SwipeAction {
  final IconData icon;
  final String label;
  final Color backgroundColor;
  final Color foregroundColor;
  final VoidCallback onPressed;

  const SwipeAction({
    required this.icon,
    required this.label,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.onPressed,
  });
}

/// スワイプアクションウィジェット
class _SwipeActionWidget extends StatefulWidget {
  final Widget child;
  final List<SwipeAction> leftActions;
  final List<SwipeAction> rightActions;
  final double threshold;

  const _SwipeActionWidget({
    required this.child,
    required this.leftActions,
    required this.rightActions,
    required this.threshold,
  });

  @override
  State<_SwipeActionWidget> createState() => _SwipeActionWidgetState();
}

class _SwipeActionWidgetState extends State<_SwipeActionWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  double _dragExtent = 0.0;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: Offset.zero,
    ).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragUpdate: (details) {
        setState(() {
          _dragExtent += details.delta.dx;
        });
      },
      onHorizontalDragEnd: (details) {
        final screenWidth = MediaQuery.of(context).size.width;
        final threshold = screenWidth * widget.threshold;

        if (_dragExtent.abs() > threshold) {
          // アクションを実行
          if (_dragExtent > 0 && widget.leftActions.isNotEmpty) {
            widget.leftActions.first.onPressed();
          } else if (_dragExtent < 0 && widget.rightActions.isNotEmpty) {
            widget.rightActions.first.onPressed();
          }

          AnimationSystem.instance.playSuccessHaptic();
        } else {
          AnimationSystem.instance.playMicroInteractionHaptic();
        }

        // 元の位置に戻す
        setState(() {
          _dragExtent = 0.0;
        });
      },
      child: Transform.translate(
        offset: Offset(_dragExtent, 0),
        child: widget.child,
      ),
    );
  }
}

/// ローディングドットウィジェット
class _LoadingDotsWidget extends StatefulWidget {
  final int dotCount;
  final Color color;
  final double size;
  final Duration duration;

  const _LoadingDotsWidget({
    required this.dotCount,
    required this.color,
    required this.size,
    required this.duration,
  });

  @override
  State<_LoadingDotsWidget> createState() => _LoadingDotsWidgetState();
}

class _LoadingDotsWidgetState extends State<_LoadingDotsWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(duration: widget.duration, vsync: this);

    if (AnimationSystem.instance.animationsEnabled) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(widget.dotCount, (index) {
        return AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final delay = index * 0.2;
            final animationValue = (_controller.value - delay) % 1.0;
            final scale =
                0.5 +
                0.5 * (1 - (animationValue - 0.5).abs() * 2).clamp(0.0, 1.0);

            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 2),
              child: Transform.scale(
                scale: scale,
                child: Container(
                  width: widget.size,
                  height: widget.size,
                  decoration: BoxDecoration(
                    color: widget.color,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}

/// 長押しウィジェット
class _LongPressWidget extends StatefulWidget {
  final Widget child;
  final VoidCallback onLongPress;
  final Duration duration;
  final double scaleDown;

  const _LongPressWidget({
    required this.child,
    required this.onLongPress,
    required this.duration,
    required this.scaleDown,
  });

  @override
  State<_LongPressWidget> createState() => _LongPressWidgetState();
}

class _LongPressWidgetState extends State<_LongPressWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(duration: widget.duration, vsync: this);

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: widget.scaleDown,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPressStart: (_) {
        if (AnimationSystem.instance.animationsEnabled) {
          _controller.forward();
        }
      },
      onLongPressEnd: (_) {
        if (AnimationSystem.instance.animationsEnabled) {
          _controller.reverse();
        }
        AnimationSystem.instance.playSuccessHaptic();
        widget.onLongPress();
      },
      onLongPressCancel: () {
        if (AnimationSystem.instance.animationsEnabled) {
          _controller.reverse();
        }
      },
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: widget.child,
          );
        },
      ),
    );
  }
}
