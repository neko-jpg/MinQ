import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:minq/core/animations/animation_system.dart';

/// フルイドアニメーションライブラリ（要件46）
class FluidAnimations {
  static final AnimationSystem _animationSystem = AnimationSystem.instance;
  
  /// スムーズなフェードイン
  static Widget fadeIn({
    required Widget child,
    Duration? duration,
    Curve? curve,
    double? delay,
  }) {
    if (!_animationSystem.animationsEnabled) {
      return child;
    }
    
    return AnimationConfiguration.staggeredList(
      position: 0,
      delay: Duration(milliseconds: (delay ?? 0) * 1000 ~/ 1),
      child: FadeInAnimation(
        duration: _animationSystem.getDuration(duration ?? const Duration(milliseconds: 600)),
        curve: _animationSystem.getCurve(curve ?? Curves.easeOutCubic),
        child: child,
      ),
    );
  }
  
  /// スムーズなスライドイン
  static Widget slideIn({
    required Widget child,
    SlideDirection direction = SlideDirection.bottom,
    Duration? duration,
    Curve? curve,
    double? delay,
    double distance = 50.0,
  }) {
    if (!_animationSystem.animationsEnabled) {
      return child;
    }
    
    return AnimationConfiguration.staggeredList(
      position: 0,
      delay: Duration(milliseconds: (delay ?? 0) * 1000 ~/ 1),
      child: SlideAnimation(
        duration: _animationSystem.getDuration(duration ?? const Duration(milliseconds: 600)),
        curve: _animationSystem.getCurve(curve ?? Curves.easeOutCubic),
        verticalOffset: direction == SlideDirection.bottom ? distance : 
                       direction == SlideDirection.top ? -distance : 0,
        horizontalOffset: direction == SlideDirection.right ? distance :
                         direction == SlideDirection.left ? -distance : 0,
        child: child,
      ),
    );
  }
  
  /// エラスティックスケール
  static Widget elasticScale({
    required Widget child,
    Duration? duration,
    double? delay,
    double scale = 0.0,
  }) {
    if (!_animationSystem.animationsEnabled) {
      return child;
    }
    
    return AnimationConfiguration.staggeredList(
      position: 0,
      delay: Duration(milliseconds: (delay ?? 0) * 1000 ~/ 1),
      child: ScaleAnimation(
        duration: _animationSystem.getDuration(duration ?? const Duration(milliseconds: 800)),
        curve: _animationSystem.getCurve(Curves.elasticOut),
        scale: scale,
        child: child,
      ),
    );
  }
  
  /// リストアイテムのスタガードアニメーション
  static Widget staggeredList({
    required Widget child,
    required int index,
    Duration? duration,
    double? delay,
  }) {
    if (!_animationSystem.animationsEnabled) {
      return child;
    }
    
    return AnimationConfiguration.staggeredList(
      position: index,
      delay: Duration(milliseconds: (delay ?? 100) * 1000 ~/ 1),
      child: SlideAnimation(
        duration: _animationSystem.getDuration(duration ?? const Duration(milliseconds: 600)),
        curve: _animationSystem.getCurve(Curves.easeOutCubic),
        verticalOffset: 30.0,
        child: FadeInAnimation(
          duration: _animationSystem.getDuration(duration ?? const Duration(milliseconds: 600)),
          curve: _animationSystem.getCurve(Curves.easeOut),
          child: child,
        ),
      ),
    );
  }
  
  /// グリッドアイテムのスタガードアニメーション
  static Widget staggeredGrid({
    required Widget child,
    required int index,
    int columnCount = 2,
    Duration? duration,
    double? delay,
  }) {
    if (!_animationSystem.animationsEnabled) {
      return child;
    }
    
    return AnimationConfiguration.staggeredGrid(
      position: index,
      columnCount: columnCount,
      delay: Duration(milliseconds: (delay ?? 100) * 1000 ~/ 1),
      child: ScaleAnimation(
        duration: _animationSystem.getDuration(duration ?? const Duration(milliseconds: 600)),
        curve: _animationSystem.getCurve(Curves.easeOutBack),
        child: FadeInAnimation(
          duration: _animationSystem.getDuration(duration ?? const Duration(milliseconds: 600)),
          curve: _animationSystem.getCurve(Curves.easeOut),
          child: child,
        ),
      ),
    );
  }
  
  /// 波紋エフェクト
  static Widget rippleEffect({
    required Widget child,
    required VoidCallback onTap,
    Color? rippleColor,
    double? radius,
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
        borderRadius: BorderRadius.circular(radius ?? 12),
        child: child,
      ),
    );
  }
  
  /// フローティングアクションボタンのアニメーション
  static Widget animatedFAB({
    required Widget child,
    required VoidCallback onPressed,
    bool isVisible = true,
    Duration? duration,
  }) {
    return AnimatedScale(
      scale: isVisible ? 1.0 : 0.0,
      duration: _animationSystem.getDuration(duration ?? const Duration(milliseconds: 300)),
      curve: _animationSystem.getCurve(Curves.easeOutBack),
      child: AnimatedOpacity(
        opacity: isVisible ? 1.0 : 0.0,
        duration: _animationSystem.getDuration(duration ?? const Duration(milliseconds: 300)),
        child: FloatingActionButton(
          onPressed: () {
            _animationSystem.playMicroInteractionHaptic();
            onPressed();
          },
          child: child,
        ),
      ),
    );
  }
  
  /// カードのホバーエフェクト
  static Widget hoverCard({
    required Widget child,
    VoidCallback? onTap,
    double elevation = 2.0,
    double hoverElevation = 8.0,
    Duration? duration,
  }) {
    return StatefulBuilder(
      builder: (context, setState) {
        bool isHovered = false;
        
        return MouseRegion(
          onEnter: (_) => setState(() => isHovered = true),
          onExit: (_) => setState(() => isHovered = false),
          child: GestureDetector(
            onTap: onTap != null ? () {
              _animationSystem.playMicroInteractionHaptic();
              onTap();
            } : null,
            child: AnimatedContainer(
              duration: _animationSystem.getDuration(duration ?? const Duration(milliseconds: 200)),
              curve: _animationSystem.getCurve(Curves.easeOut),
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: isHovered ? hoverElevation : elevation,
                    spreadRadius: isHovered ? 2 : 0,
                    offset: Offset(0, isHovered ? 4 : 2),
                  ),
                ],
              ),
              child: child,
            ),
          ),
        );
      },
    );
  }
  
  /// プログレスバーのアニメーション
  static Widget animatedProgress({
    required double progress,
    Color? backgroundColor,
    Color? progressColor,
    Duration? duration,
    double height = 4.0,
    BorderRadius? borderRadius,
  }) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.grey.withOpacity(0.3),
        borderRadius: borderRadius ?? BorderRadius.circular(height / 2),
      ),
      child: AnimatedContainer(
        duration: _animationSystem.getDuration(duration ?? const Duration(milliseconds: 500)),
        curve: _animationSystem.getCurve(Curves.easeOutCubic),
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: borderRadius ?? BorderRadius.circular(height / 2),
        ),
        child: FractionallySizedBox(
          alignment: Alignment.centerLeft,
          widthFactor: progress.clamp(0.0, 1.0),
          child: Container(
            decoration: BoxDecoration(
              color: progressColor ?? Colors.blue,
              borderRadius: borderRadius ?? BorderRadius.circular(height / 2),
            ),
          ),
        ),
      ),
    );
  }
}

/// スライド方向
enum SlideDirection {
  top,
  bottom,
  left,
  right,
}

/// カスタムページトランジション
class FluidPageTransition extends PageRouteBuilder {
  final Widget child;
  final TransitionType transitionType;
  final Duration duration;
  
  FluidPageTransition({
    required this.child,
    this.transitionType = TransitionType.slideUp,
    this.duration = const Duration(milliseconds: 300),
  }) : super(
    pageBuilder: (context, animation, secondaryAnimation) => child,
    transitionDuration: AnimationSystem.instance.getDuration(duration),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return _buildTransition(
        animation,
        secondaryAnimation,
        child,
        transitionType,
      );
    },
  );
  
  static Widget _buildTransition(
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
    TransitionType type,
  ) {
    final curve = AnimationSystem.instance.getCurve(Curves.easeOutCubic);
    
    switch (type) {
      case TransitionType.slideUp:
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 1),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: animation, curve: curve)),
          child: child,
        );
      
      case TransitionType.slideRight:
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1, 0),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: animation, curve: curve)),
          child: child,
        );
      
      case TransitionType.fade:
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      
      case TransitionType.scale:
        return ScaleTransition(
          scale: Tween<double>(
            begin: 0.8,
            end: 1.0,
          ).animate(CurvedAnimation(parent: animation, curve: curve)),
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
    }
  }
}

/// トランジションタイプ
enum TransitionType {
  slideUp,
  slideRight,
  fade,
  scale,
}