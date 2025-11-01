import 'package:flutter/material.dart';
import 'package:minq/l10n/app_localizations.dart';
import 'package:minq/presentation/theme/minq_tokens.dart';

/// Enhanced visual hierarchy components for consistent spacing and layout
/// Provides proper visual organization and information architecture with polished design

/// Section header with consistent styling and spacing
class SectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? action;
  final EdgeInsets? padding;
  final bool showDivider;
  final IconData? icon;

  const SectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.action,
    this.padding,
    this.showDivider = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          padding ??
          EdgeInsets.symmetric(
            horizontal: MinqTokens.spacing(6),
            vertical: MinqTokens.spacing(4),
          ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Icon(icon, color: MinqTokens.brandPrimary, size: 20),
                SizedBox(width: MinqTokens.spacing(2)),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: MinqTokens.titleMedium.copyWith(
                        color: MinqTokens.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (subtitle != null) ...[
                      SizedBox(height: MinqTokens.spacing(1)),
                      Text(
                        subtitle!,
                        style: MinqTokens.bodyMedium.copyWith(
                          color: MinqTokens.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (action != null) action!,
            ],
          ),
          if (showDivider) ...[
            SizedBox(height: MinqTokens.spacing(4)),
            const Divider(color: Color(0xFFE5E7EB), height: 1),
          ],
        ],
      ),
    );
  }
}

/// Content section with proper spacing and visual grouping
class ContentSection extends StatelessWidget {
  final String? title;
  final List<Widget> children;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final Color? backgroundColor;
  final bool showBorder;
  final BorderRadius? borderRadius;

  const ContentSection({
    super.key,
    this.title,
    required this.children,
    this.padding,
    this.margin,
    this.backgroundColor,
    this.showBorder = false,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin ?? EdgeInsets.only(bottom: MinqTokens.spacing(6)),
      padding: padding ?? EdgeInsets.all(MinqTokens.spacing(6)),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: borderRadius ?? MinqTokens.cornerLarge(),
        border:
            showBorder
                ? Border.all(color: const Color(0xFFE5E7EB), width: 1)
                : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Text(
              title!,
              style: MinqTokens.titleLarge.copyWith(
                color: MinqTokens.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: MinqTokens.spacing(4)),
          ],
          ...children.map((child) {
            final index = children.indexOf(child);
            return Column(
              children: [
                child,
                if (index < children.length - 1)
                  SizedBox(height: MinqTokens.spacing(4)),
              ],
            );
          }),
        ],
      ),
    );
  }
}

/// Information hierarchy with primary and secondary content
class InfoHierarchy extends StatelessWidget {
  final String primary;
  final String? secondary;
  final String? tertiary;
  final Widget? leading;
  final Widget? trailing;
  final CrossAxisAlignment alignment;
  final EdgeInsets? padding;

  const InfoHierarchy({
    super.key,
    required this.primary,
    this.secondary,
    this.tertiary,
    this.leading,
    this.trailing,
    this.alignment = CrossAxisAlignment.start,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? EdgeInsets.zero,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (leading != null) ...[
            leading!,
            SizedBox(width: MinqTokens.spacing(4)),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: alignment,
              children: [
                Text(
                  primary,
                  style: MinqTokens.titleMedium.copyWith(
                    color: MinqTokens.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (secondary != null) ...[
                  SizedBox(height: MinqTokens.spacing(1)),
                  Text(
                    secondary!,
                    style: MinqTokens.bodyMedium.copyWith(
                      color: MinqTokens.textSecondary,
                    ),
                  ),
                ],
                if (tertiary != null) ...[
                  SizedBox(height: MinqTokens.spacing(1)),
                  Text(
                    tertiary!,
                    style: MinqTokens.bodySmall.copyWith(
                      color: MinqTokens.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (trailing != null) ...[
            SizedBox(width: MinqTokens.spacing(4)),
            trailing!,
          ],
        ],
      ),
    );
  }
}

/// Metric display with proper visual emphasis
class MetricDisplay extends StatelessWidget {
  final String value;
  final String label;
  final String? unit;
  final IconData? icon;
  final Color? accentColor;
  final bool isPositive;
  final String? changeText;
  final EdgeInsets? padding;

  const MetricDisplay({
    super.key,
    required this.value,
    required this.label,
    this.unit,
    this.icon,
    this.accentColor,
    this.isPositive = true,
    this.changeText,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final accent = accentColor ?? MinqTokens.brandPrimary;

    return Container(
      padding: padding ?? EdgeInsets.all(MinqTokens.spacing(6)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: accent.withAlpha(25),
                borderRadius: MinqTokens.cornerSmall(),
              ),
              child: Icon(icon, color: accent, size: 18),
            ),
            SizedBox(height: MinqTokens.spacing(4)),
          ],
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: MinqTokens.titleLarge.copyWith(
                  color: MinqTokens.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (unit != null) ...[
                SizedBox(width: MinqTokens.spacing(1)),
                Text(
                  unit!,
                  style: MinqTokens.titleMedium.copyWith(
                    color: MinqTokens.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ],
          ),
          SizedBox(height: MinqTokens.spacing(2)),
          Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: MinqTokens.bodyMedium.copyWith(
                    color: MinqTokens.textSecondary,
                  ),
                ),
              ),
              if (changeText != null) ...[
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: MinqTokens.spacing(2),
                    vertical: MinqTokens.spacing(1),
                  ),
                  decoration: BoxDecoration(
                    color:
                        isPositive
                            ? const Color(0xFF10B981).withAlpha(25)
                            : const Color(0xFFEF4444).withAlpha(25),
                    borderRadius: MinqTokens.cornerSmall(),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isPositive ? Icons.trending_up : Icons.trending_down,
                        color:
                            isPositive
                                ? const Color(0xFF10B981)
                                : const Color(0xFFEF4444),
                        size: 14,
                      ),
                      SizedBox(width: MinqTokens.spacing(1)),
                      Text(
                        changeText!,
                        style: MinqTokens.bodySmall.copyWith(
                          color:
                              isPositive
                                  ? const Color(0xFF10B981)
                                  : const Color(0xFFEF4444),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

/// Status indicator with consistent visual treatment
class StatusIndicator extends StatelessWidget {
  final String text;
  final StatusType type;
  final IconData? icon;
  final bool showIcon;
  final EdgeInsets? padding;

  const StatusIndicator({
    super.key,
    required this.text,
    required this.type,
    this.icon,
    this.showIcon = true,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color textColor;
    IconData defaultIcon;

    switch (type) {
      case StatusType.success:
        backgroundColor = const Color(0xFF10B981).withAlpha(25);
        textColor = const Color(0xFF10B981);
        defaultIcon = Icons.check_circle;
        break;
      case StatusType.warning:
        backgroundColor = const Color(0xFFF59E0B).withAlpha(25);
        textColor = const Color(0xFFF59E0B);
        defaultIcon = Icons.warning;
        break;
      case StatusType.error:
        backgroundColor = const Color(0xFFEF4444).withAlpha(25);
        textColor = const Color(0xFFEF4444);
        defaultIcon = Icons.error;
        break;
      case StatusType.info:
        backgroundColor = MinqTokens.brandPrimary.withAlpha(25);
        textColor = MinqTokens.brandPrimary;
        defaultIcon = Icons.info;
        break;
      case StatusType.neutral:
        backgroundColor = const Color(0xFF9CA3AF).withAlpha(25);
        textColor = MinqTokens.textSecondary;
        defaultIcon = Icons.circle;
        break;
    }

    return Container(
      padding:
          padding ??
          EdgeInsets.symmetric(
            horizontal: MinqTokens.spacing(4),
            vertical: MinqTokens.spacing(2),
          ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: MinqTokens.cornerSmall(),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showIcon) ...[
            Icon(icon ?? defaultIcon, color: textColor, size: 16),
            SizedBox(width: MinqTokens.spacing(2)),
          ],
          Text(
            text,
            style: MinqTokens.bodySmall.copyWith(
              color: textColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// Priority indicator with visual emphasis
class PriorityIndicator extends StatelessWidget {
  final PriorityLevel level;
  final String? text;
  final bool showText;

  const PriorityIndicator({
    super.key,
    required this.level,
    this.text,
    this.showText = true,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    Color color;
    String defaultText;
    IconData icon;

    switch (level) {
      case PriorityLevel.high:
        color = const Color(0xFFEF4444);
        defaultText = l10n.priorityHigh;
        icon = Icons.keyboard_arrow_up;
        break;
      case PriorityLevel.medium:
        color = const Color(0xFFF59E0B);
        defaultText = l10n.priorityMedium;
        icon = Icons.remove;
        break;
      case PriorityLevel.low:
        color = const Color(0xFF10B981);
        defaultText = l10n.priorityLow;
        icon = Icons.keyboard_arrow_down;
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: MinqTokens.spacing(2),
        vertical: MinqTokens.spacing(1),
      ),
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        borderRadius: MinqTokens.cornerSmall(),
        border: Border.all(color: color.withAlpha(76), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          if (showText) ...[
            SizedBox(width: MinqTokens.spacing(1)),
            Text(
              text ?? defaultText,
              style: MinqTokens.bodySmall.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Callout box for important information
class CalloutBox extends StatelessWidget {
  final String title;
  final String content;
  final CalloutType type;
  final IconData? icon;
  final Widget? action;
  final bool isDismissible;
  final VoidCallback? onDismiss;

  const CalloutBox({
    super.key,
    required this.title,
    required this.content,
    this.type = CalloutType.info,
    this.icon,
    this.action,
    this.isDismissible = false,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color borderColor;
    Color iconColor;
    IconData defaultIcon;

    switch (type) {
      case CalloutType.info:
        backgroundColor = MinqTokens.brandPrimary.withAlpha(15);
        borderColor = MinqTokens.brandPrimary.withAlpha(76);
        iconColor = MinqTokens.brandPrimary;
        defaultIcon = Icons.info_outline;
        break;
      case CalloutType.success:
        backgroundColor = const Color(0xFF10B981).withAlpha(15);
        borderColor = const Color(0xFF10B981).withAlpha(76);
        iconColor = const Color(0xFF10B981);
        defaultIcon = Icons.check_circle_outline;
        break;
      case CalloutType.warning:
        backgroundColor = const Color(0xFFF59E0B).withAlpha(15);
        borderColor = const Color(0xFFF59E0B).withAlpha(76);
        iconColor = const Color(0xFFF59E0B);
        defaultIcon = Icons.warning_amber_outlined;
        break;
      case CalloutType.error:
        backgroundColor = const Color(0xFFEF4444).withAlpha(15);
        borderColor = const Color(0xFFEF4444).withAlpha(76);
        iconColor = const Color(0xFFEF4444);
        defaultIcon = Icons.error_outline;
        break;
    }

    return Container(
      padding: EdgeInsets.all(MinqTokens.spacing(6)),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: MinqTokens.cornerMedium(),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon ?? defaultIcon, color: iconColor, size: 20),
          SizedBox(width: MinqTokens.spacing(4)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: MinqTokens.bodyLarge.copyWith(
                    color: MinqTokens.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: MinqTokens.spacing(2)),
                Text(
                  content,
                  style: MinqTokens.bodyMedium.copyWith(
                    color: MinqTokens.textSecondary,
                    height: 1.4,
                  ),
                ),
                if (action != null) ...[
                  SizedBox(height: MinqTokens.spacing(4)),
                  action!,
                ],
              ],
            ),
          ),
          if (isDismissible) ...[
            SizedBox(width: MinqTokens.spacing(2)),
            GestureDetector(
              onTap: onDismiss,
              child: Icon(
                Icons.close,
                color: MinqTokens.textSecondary,
                size: 18,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Enums for component variants
enum StatusType { success, warning, error, info, neutral }

enum PriorityLevel { high, medium, low }

enum CalloutType { info, success, warning, error }
