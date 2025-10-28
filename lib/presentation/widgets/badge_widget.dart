import 'package:flutter/material.dart';
import 'package:minq/presentation/theme/design_tokens.dart';

/// バッジの種類
enum BadgeType {
  /// 数値バッジ（1, 2, 3...）
  numeric,

  /// ドットバッジ（通知点）
  dot,

  /// テキストバッジ（NEW, HOTなど）
  text,
}

/// バッジのサイズ
enum BadgeSize {
  /// 小（ドット用）
  small,

  /// 中（数値1桁用）
  medium,

  /// 大（数値2桁以上用）
  large,
}

/// バッジウィジェット
class BadgeWidget extends StatelessWidget {
  final BadgeType type;
  final int? count;
  final String? text;
  final BadgeSize size;
  final Color? backgroundColor;
  final Color? textColor;
  final bool show;

  const BadgeWidget({
    super.key,
    this.type = BadgeType.numeric,
    this.count,
    this.text,
    this.size = BadgeSize.medium,
    this.backgroundColor,
    this.textColor,
    this.show = true,
  });

  /// 数値バッジを作成
  const BadgeWidget.numeric({
    super.key,
    required this.count,
    this.size = BadgeSize.medium,
    this.backgroundColor,
    this.textColor,
    this.show = true,
  }) : type = BadgeType.numeric,
       text = null;

  /// ドットバッジを作成
  const BadgeWidget.dot({super.key, this.backgroundColor, this.show = true})
    : type = BadgeType.dot,
      count = null,
      text = null,
      size = BadgeSize.small,
      textColor = null;

  /// テキストバッジを作成
  const BadgeWidget.text({
    super.key,
    required this.text,
    this.size = BadgeSize.medium,
    this.backgroundColor,
    this.textColor,
    this.show = true,
  }) : type = BadgeType.text,
       count = null;

  @override
  Widget build(BuildContext context) {
    if (!show) {
      return const SizedBox.shrink();
    }

    final tokens = context.tokens;
    final bgColor = backgroundColor ?? tokens.colors.error;
    final fgColor = textColor ?? tokens.colors.onError;

    switch (type) {
      case BadgeType.dot:
        return _buildDotBadge(tokens, bgColor);
      case BadgeType.numeric:
        return _buildNumericBadge(tokens, bgColor, fgColor);
      case BadgeType.text:
        return _buildTextBadge(tokens, bgColor, fgColor);
    }
  }

  Widget _buildDotBadge(MinqDesignTokens tokens, Color color) {
    return Container(
      width: MinqSpacingTokens.sm,
      height: MinqSpacingTokens.sm,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(
          color: tokens.colors.surface,
          width: 1.5,
        ),
      ),
    );
  }

  Widget _buildNumericBadge(
    MinqDesignTokens tokens,
    Color bgColor,
    Color fgColor,
  ) {
    if (count == null || count! <= 0) {
      return const SizedBox.shrink();
    }

    final displayText = count! > 99 ? '99+' : count.toString();
    final isLarge = count! > 9;

    return Container(
      constraints: BoxConstraints(
        minWidth: isLarge ? tokens.spacing.xl : tokens.spacing.lg,
        minHeight: isLarge ? tokens.spacing.xl : tokens.spacing.lg,
      ),
      padding: EdgeInsets.symmetric(
        horizontal: isLarge ? tokens.spacing.sm : tokens.spacing.xs,
        vertical: tokens.spacing.xs,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: tokens.radius.fullRadius,
        border: Border.all(
          color: tokens.colors.surface,
          width: 1.5,
        ),
      ),
      child: Center(
        child: Text(
          displayText,
          style: tokens.typography.labelSmall.copyWith(
            color: fgColor,
            fontWeight: FontWeight.bold,
            height: 1.0,
          ),
        ),
      ),
    );
  }

  Widget _buildTextBadge(MinqDesignTokens tokens, Color bgColor, Color fgColor) {
    if (text == null || text!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: tokens.spacing.sm,
        vertical: tokens.spacing.xs,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: tokens.radius.smRadius,
        border: Border.all(
          color: tokens.colors.surface,
          width: 1.5,
        ),
      ),
      child: Text(
        text!,
        style: tokens.typography.labelSmall.copyWith(
          color: fgColor,
          fontWeight: FontWeight.bold,
          height: 1.0,
        ),
      ),
    );
  }
}

/// バッジ付きウィジェット
class WidgetWithBadge extends StatelessWidget {
  final Widget child;
  final BadgeWidget badge;
  final Alignment alignment;
  final EdgeInsets offset;

  const WidgetWithBadge({
    super.key,
    required this.child,
    required this.badge,
    this.alignment = Alignment.topRight,
    this.offset = const EdgeInsets.all(0),
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        child,
        Positioned(
          top:
              alignment == Alignment.topRight || alignment == Alignment.topLeft
                  ? offset.top
                  : null,
          bottom:
              alignment == Alignment.bottomRight ||
                      alignment == Alignment.bottomLeft
                  ? offset.bottom
                  : null,
          right:
              alignment == Alignment.topRight ||
                      alignment == Alignment.bottomRight
                  ? offset.right
                  : null,
          left:
              alignment == Alignment.topLeft ||
                      alignment == Alignment.bottomLeft
                  ? offset.left
                  : null,
          child: badge,
        ),
      ],
    );
  }
}

/// BottomNavigationBarItem用のバッジ付きアイコン
class BadgedIcon extends StatelessWidget {
  final IconData icon;
  final int? badgeCount;
  final bool showDot;
  final Color? iconColor;
  final double iconSize;

  const BadgedIcon({
    super.key,
    required this.icon,
    this.badgeCount,
    this.showDot = false,
    this.iconColor,
    this.iconSize = 24,
  });

  @override
  Widget build(BuildContext context) {
    final hasBadge = (badgeCount != null && badgeCount! > 0) || showDot;

    if (!hasBadge) {
      return Icon(icon, color: iconColor, size: iconSize);
    }

    return WidgetWithBadge(
      badge:
          showDot
              ? const BadgeWidget.dot()
              : BadgeWidget.numeric(count: badgeCount ?? 0),
      offset: const EdgeInsets.only(top: -4, right: -4),
      child: Icon(icon, color: iconColor, size: iconSize),
    );
  }
}

/// タブ用のバッジ付きラベル
class BadgedLabel extends StatelessWidget {
  final String label;
  final int? badgeCount;
  final bool showDot;
  final TextStyle? textStyle;

  const BadgedLabel({
    super.key,
    required this.label,
    this.badgeCount,
    this.showDot = false,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    final hasBadge = (badgeCount != null && badgeCount! > 0) || showDot;

    if (!hasBadge) {
      return Text(label, style: textStyle);
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: textStyle),
        const SizedBox(width: 8),
        showDot
            ? const BadgeWidget.dot()
            : BadgeWidget.numeric(count: badgeCount ?? 0),
      ],
    );
  }
}

/// アニメーション付きバッジ
class AnimatedBadge extends StatefulWidget {
  final BadgeWidget badge;
  final Duration duration;

  const AnimatedBadge({
    super.key,
    required this.badge,
    this.duration = const Duration(milliseconds: 300),
  });

  @override
  State<AnimatedBadge> createState() => _AnimatedBadgeState();
}

class _AnimatedBadgeState extends State<AnimatedBadge>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);
    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));

    if (widget.badge.show) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(AnimatedBadge oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.badge.show != oldWidget.badge.show) {
      if (widget.badge.show) {
        _controller.forward();
      } else {
        _controller.reverse();
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
    return ScaleTransition(scale: _scaleAnimation, child: widget.badge);
  }
}
