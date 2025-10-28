import 'package:flutter/material.dart';
import 'package:minq/l10n/app_localizations.dart';
import 'package:minq/presentation/theme/design_tokens.dart';

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
    final tokens = MinqDesignTokens.of(context);

    return Container(
      padding: padding ?? EdgeInsets.symmetric(
        horizontal: tokens.spacing.lg,
        vertical: tokens.spacing.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  color: tokens.colors.primary,
                  size: 20,
                ),
                SizedBox(width: tokens.spacing.sm),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: tokens.typography.headlineSmall.copyWith(
                        color: tokens.colors.onSurface,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (subtitle != null) ...[
                      SizedBox(height: tokens.spacing.xs),
                      Text(
                        subtitle!,
                        style: tokens.typography.bodyMedium.copyWith(
                          color: tokens.colors.onSurfaceVariant,
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
            SizedBox(height: tokens.spacing.md),
            Divider(
              color: tokens.colors.outlineVariant,
              height: 1,
            ),
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
    final tokens = MinqDesignTokens.of(context);

    return Container(
      margin: margin ?? EdgeInsets.only(bottom: tokens.spacing.lg),
      padding: padding ?? EdgeInsets.all(tokens.spacing.lg),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: borderRadius ?? tokens.radius.lgRadius,
        border: showBorder
            ? Border.all(
                color: tokens.colors.outlineVariant,
                width: 1,
              )
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Text(
              title!,
              style: tokens.typography.titleLarge.copyWith(
                color: tokens.colors.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: tokens.spacing.md),
          ],
          ...children.map((child) {
            final index = children.indexOf(child);
            return Column(
              children: [
                child,
                if (index < children.length - 1)
                  SizedBox(height: tokens.spacing.md),
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
    final tokens = MinqDesignTokens.of(context);

    return Padding(
      padding: padding ?? EdgeInsets.zero,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (leading != null) ...[
            leading!,
            SizedBox(width: tokens.spacing.md),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: alignment,
              children: [
                Text(
                  primary,
                  style: tokens.typography.titleMedium.copyWith(
                    color: tokens.colors.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (secondary != null) ...[
                  SizedBox(height: tokens.spacing.xs),
                  Text(
                    secondary!,
                    style: tokens.typography.bodyMedium.copyWith(
                      color: tokens.colors.onSurfaceVariant,
                    ),
                  ),
                ],
                if (tertiary != null) ...[
                  SizedBox(height: tokens.spacing.xs),
                  Text(
                    tertiary!,
                    style: tokens.typography.bodySmall.copyWith(
                      color: tokens.colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (trailing != null) ...[
            SizedBox(width: tokens.spacing.md),
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
    final tokens = MinqDesignTokens.of(context);
    final accent = accentColor ?? tokens.colors.primary;

    return Container(
      padding: padding ?? EdgeInsets.all(tokens.spacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: accent.withAlpha(25),
                borderRadius: tokens.radius.smRadius,
              ),
              child: Icon(
                icon,
                color: accent,
                size: 18,
              ),
            ),
            SizedBox(height: tokens.spacing.md),
          ],
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: tokens.typography.displaySmall.copyWith(
                  color: tokens.colors.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (unit != null) ...[
                SizedBox(width: tokens.spacing.xs),
                Text(
                  unit!,
                  style: tokens.typography.titleMedium.copyWith(
                    color: tokens.colors.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ],
          ),
          SizedBox(height: tokens.spacing.sm),
          Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: tokens.typography.bodyMedium.copyWith(
                    color: tokens.colors.onSurfaceVariant,
                  ),
                ),
              ),
              if (changeText != null) ...[
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: tokens.spacing.sm,
                    vertical: tokens.spacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: isPositive
                        ? tokens.colors.success.withAlpha(25)
                        : tokens.colors.error.withAlpha(25),
                    borderRadius: tokens.radius.smRadius,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isPositive ? Icons.trending_up : Icons.trending_down,
                        color: isPositive
                            ? tokens.colors.success
                            : tokens.colors.error,
                        size: 14,
                      ),
                      SizedBox(width: tokens.spacing.xs),
                      Text(
                        changeText!,
                        style: tokens.typography.bodySmall.copyWith(
                          color: isPositive
                              ? tokens.colors.success
                              : tokens.colors.error,
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
    final tokens = MinqDesignTokens.of(context);

    Color backgroundColor;
    Color textColor;
    IconData defaultIcon;

    switch (type) {
      case StatusType.success:
        backgroundColor = tokens.colors.success.withAlpha(25);
        textColor = tokens.colors.success;
        defaultIcon = Icons.check_circle;
        break;
      case StatusType.warning:
        backgroundColor = tokens.colors.warning.withAlpha(25);
        textColor = tokens.colors.warning;
        defaultIcon = Icons.warning;
        break;
      case StatusType.error:
        backgroundColor = tokens.colors.error.withAlpha(25);
        textColor = tokens.colors.error;
        defaultIcon = Icons.error;
        break;
      case StatusType.info:
        backgroundColor = tokens.colors.primary.withAlpha(25);
        textColor = tokens.colors.primary;
        defaultIcon = Icons.info;
        break;
      case StatusType.neutral:
        backgroundColor = tokens.colors.outline.withAlpha(25);
        textColor = tokens.colors.onSurfaceVariant;
        defaultIcon = Icons.circle;
        break;
    }

    return Container(
      padding: padding ?? EdgeInsets.symmetric(
        horizontal: tokens.spacing.md,
        vertical: tokens.spacing.sm,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: tokens.radius.smRadius,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showIcon) ...[
            Icon(
              icon ?? defaultIcon,
              color: textColor,
              size: 16,
            ),
            SizedBox(width: tokens.spacing.sm),
          ],
          Text(
            text,
            style: tokens.typography.bodySmall.copyWith(
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
    final tokens = MinqDesignTokens.of(context);
    final l10n = AppLocalizations.of(context)!;

    Color color;
    String defaultText;
    IconData icon;

    switch (level) {
      case PriorityLevel.high:
        color = tokens.colors.error;
        defaultText = l10n.priorityHigh;
        icon = Icons.keyboard_arrow_up;
        break;
      case PriorityLevel.medium:
        color = tokens.colors.warning;
        defaultText = l10n.priorityMedium;
        icon = Icons.remove;
        break;
      case PriorityLevel.low:
        color = tokens.colors.success;
        defaultText = l10n.priorityLow;
        icon = Icons.keyboard_arrow_down;
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: tokens.spacing.sm,
        vertical: tokens.spacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        borderRadius: tokens.radius.smRadius,
        border: Border.all(
          color: color.withAlpha(76),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: color,
            size: 14,
          ),
          if (showText) ...[
            SizedBox(width: tokens.spacing.xs),
            Text(
              text ?? defaultText,
              style: tokens.typography.bodySmall.copyWith(
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
    final tokens = MinqDesignTokens.of(context);

    Color backgroundColor;
    Color borderColor;
    Color iconColor;
    IconData defaultIcon;

    switch (type) {
      case CalloutType.info:
        backgroundColor = tokens.colors.primary.withAlpha(15);
        borderColor = tokens.colors.primary.withAlpha(76);
        iconColor = tokens.colors.primary;
        defaultIcon = Icons.info_outline;
        break;
      case CalloutType.success:
        backgroundColor = tokens.colors.success.withAlpha(15);
        borderColor = tokens.colors.success.withAlpha(76);
        iconColor = tokens.colors.success;
        defaultIcon = Icons.check_circle_outline;
        break;
      case CalloutType.warning:
        backgroundColor = tokens.colors.warning.withAlpha(15);
        borderColor = tokens.colors.warning.withAlpha(76);
        iconColor = tokens.colors.warning;
        defaultIcon = Icons.warning_amber_outlined;
        break;
      case CalloutType.error:
        backgroundColor = tokens.colors.error.withAlpha(15);
        borderColor = tokens.colors.error.withAlpha(76);
        iconColor = tokens.colors.error;
        defaultIcon = Icons.error_outline;
        break;
    }

    return Container(
      padding: EdgeInsets.all(tokens.spacing.lg),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: tokens.radius.mdRadius,
        border: Border.all(
          color: borderColor,
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon ?? defaultIcon,
            color: iconColor,
            size: 20,
          ),
          SizedBox(width: tokens.spacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: tokens.typography.titleSmall.copyWith(
                    color: tokens.colors.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: tokens.spacing.sm),
                Text(
                  content,
                  style: tokens.typography.bodyMedium.copyWith(
                    color: tokens.colors.onSurfaceVariant,
                    height: 1.4,
                  ),
                ),
                if (action != null) ...[
                  SizedBox(height: tokens.spacing.md),
                  action!,
                ],
              ],
            ),
          ),
          if (isDismissible) ...[
            SizedBox(width: tokens.spacing.sm),
            GestureDetector(
              onTap: onDismiss,
              child: Icon(
                Icons.close,
                color: tokens.colors.onSurfaceVariant,
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
enum StatusType {
  success,
  warning,
  error,
  info,
  neutral,
}

enum PriorityLevel {
  high,
  medium,
  low,
}

enum CalloutType {
  info,
  success,
  warning,
  error,
}