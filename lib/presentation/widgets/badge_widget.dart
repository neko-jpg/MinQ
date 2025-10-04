import 'package:flutter/material.dart';
import 'package:minq/presentation/theme/spacing_system.dart';
import 'package:minq/presentation/theme/typography_system.dart';

/// バッジの種顁E
enum BadgeType {
  /// 数値バッジ�E�E, 2, 3...�E�E
  numeric,

  /// ドットバチE���E�通知点�E�E
  dot,

  /// チE��ストバチE���E�EEW, HOTなど�E�E
  text,
}

/// バッジのサイズ
enum BadgeSize {
  /// 小（ドチE��用�E�E
  small,

  /// 中�E�数値1桁用�E�E
  medium,

  /// 大�E�数値2桁以上用�E�E
  large,
}

/// バッジウィジェチE��
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

  /// 数値バッジを作�E
  const BadgeWidget.numeric({
    super.key,
    required int count,
    BadgeSize size = BadgeSize.medium,
    Color? backgroundColor,
    Color? textColor,
    bool show = true,
  })  : type = BadgeType.numeric,
        count = count,
        text = null,
        size = size,
        backgroundColor = backgroundColor,
        textColor = textColor,
        show = show;

  /// ドットバチE��を作�E
  const BadgeWidget.dot({
    super.key,
    Color? backgroundColor,
    bool show = true,
  })  : type = BadgeType.dot,
        count = null,
        text = null,
        size = BadgeSize.small,
        backgroundColor = backgroundColor,
        textColor = null,
        show = show;

  /// チE��ストバチE��を作�E
  const BadgeWidget.text({
    super.key,
    required String text,
    BadgeSize size = BadgeSize.medium,
    Color? backgroundColor,
    Color? textColor,
    bool show = true,
  })  : type = BadgeType.text,
        count = null,
        text = text,
        size = size,
        backgroundColor = backgroundColor,
        textColor = textColor,
        show = show;

  @override
  Widget build(BuildContext context) {
    if (!show) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final bgColor = backgroundColor ?? theme.colorScheme.error;
    final fgColor = textColor ?? theme.colorScheme.onError;

    switch (type) {
      case BadgeType.dot:
        return _buildDotBadge(bgColor);
      case BadgeType.numeric:
        return _buildNumericBadge(context, bgColor, fgColor);
      case BadgeType.text:
        return _buildTextBadge(context, bgColor, fgColor);
    }
  }

  Widget _buildDotBadge(Color color) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white,
          width: 1.5,
        ),
      ),
    );
  }

  Widget _buildNumericBadge(
    BuildContext context,
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
        minWidth: isLarge ? 20 : 16,
        minHeight: isLarge ? 20 : 16,
      ),
      padding: EdgeInsets.symmetric(
        horizontal: isLarge ? Spacing.xs : Spacing.xxs,
        vertical: Spacing.xxs,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(isLarge ? 10 : 8),
        border: Border.all(
          color: Colors.white,
          width: 1.5,
        ),
      ),
      child: Center(
        child: Text(
          displayText,
          style: TextStyle(
            fontSize: isLarge ? 10 : 9,
            fontWeight: FontWeight.bold,
            color: fgColor,
            height: 1.0,
          ),
        ),
      ),
    );
  }

  Widget _buildTextBadge(
    BuildContext context,
    Color bgColor,
    Color fgColor,
  ) {
    if (text == null || text!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: Spacing.xs,
        vertical: Spacing.xxs,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.white,
          width: 1.5,
        ),
      ),
      child: Text(
        text!,
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.bold,
          color: fgColor,
          height: 1.0,
        ),
      ),
    );
  }
}

/// バッジ付きウィジェチE��
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
          top: alignment == Alignment.topRight || alignment == Alignment.topLeft
              ? offset.top
              : null,
          bottom:
              alignment == Alignment.bottomRight || alignment == Alignment.bottomLeft
                  ? offset.bottom
                  : null,
          right:
              alignment == Alignment.topRight || alignment == Alignment.bottomRight
                  ? offset.right
                  : null,
          left: alignment == Alignment.topLeft || alignment == Alignment.bottomLeft
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
      badge: showDot
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
        SizedBox(width: Spacing.xs),
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
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.elasticOut,
      ),
    );

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
    return ScaleTransition(
      scale: _scaleAnimation,
      child: widget.badge,
    );
  }
}
