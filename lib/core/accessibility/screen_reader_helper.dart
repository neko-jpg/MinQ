import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';

/// Enhanced screen reader and accessibility helper
/// Provides comprehensive WCAG AA compliant accessibility features
class ScreenReaderHelper {
  /// セマンティクスラベルを生成
  static String generateLabel({
    required String text,
    String? hint,
    String? value,
  }) {
    final parts = <String>[text];
    if (value != null) parts.add(value);
    if (hint != null) parts.add(hint);
    return parts.join('、');
  }

  /// ボタンのセマンティクス
  static Semantics button({
    required Widget child,
    required String label,
    String? hint,
    VoidCallback? onTap,
    bool enabled = true,
  }) {
    return Semantics(
      button: true,
      enabled: enabled,
      label: label,
      hint: hint,
      onTap: onTap,
      child: child,
    );
  }

  /// リストアイテムのセマンティクス
  static Semantics listItem({
    required Widget child,
    required String label,
    required int index,
    required int total,
    String? hint,
    VoidCallback? onTap,
  }) {
    return Semantics(
      label: '$label、${index + 1}件目、全$total件中',
      hint: hint,
      onTap: onTap,
      child: child,
    );
  }

  /// 進捗のセマンティクス
  static Semantics progress({
    required Widget child,
    required double value,
    String? label,
  }) {
    final percentage = (value * 100).toInt();
    return Semantics(
      label: label != null ? '$label、$percentage%完了' : '$percentage%完了',
      value: '$percentage',
      child: child,
    );
  }

  /// 画像のセマンティクス
  static Semantics image({
    required Widget child,
    required String description,
  }) {
    return Semantics(
      image: true,
      label: description,
      child: child,
    );
  }

  /// ヘッダーのセマンティクス
  static Semantics header({
    required Widget child,
    required String text,
    int level = 1,
  }) {
    return Semantics(
      header: true,
      label: 'レベル$level見出し、$text',
      child: child,
    );
  }

  /// リンクのセマンティクス
  static Semantics link({
    required Widget child,
    required String label,
    VoidCallback? onTap,
  }) {
    return Semantics(
      link: true,
      label: '$label、リンク',
      onTap: onTap,
      child: child,
    );
  }

  /// フォームフィールドのセマンティクス
  static Semantics textField({
    required Widget child,
    required String label,
    String? hint,
    String? value,
    bool isPassword = false,
  }) {
    return Semantics(
      textField: true,
      label: label,
      hint: hint,
      value: value,
      obscured: isPassword,
      child: child,
    );
  }

  /// チェックボックスのセマンティクス
  static Semantics checkbox({
    required Widget child,
    required String label,
    required bool checked,
    ValueChanged<bool>? onChanged,
  }) {
    return Semantics(
      label: '$label、チェックボックス、${checked ? "選択済み" : "未選択"}',
      checked: checked,
      onTap: onChanged != null ? () => onChanged(!checked) : null,
      child: child,
    );
  }

  /// ラジオボタンのセマンティクス
  static Semantics radio({
    required Widget child,
    required String label,
    required bool selected,
    VoidCallback? onTap,
  }) {
    return Semantics(
      label: '$label、ラジオボタン、${selected ? "選択済み" : "未選択"}',
      selected: selected,
      inMutuallyExclusiveGroup: true,
      onTap: onTap,
      child: child,
    );
  }

  /// スライダーのセマンティクス
  static Semantics slider({
    required Widget child,
    required String label,
    required double value,
    required double min,
    required double max,
    ValueChanged<double>? onChanged,
  }) {
    return Semantics(
      label: '$label、スライダー',
      value: value.toStringAsFixed(1),
      increasedValue: (value + 1).clamp(min, max).toStringAsFixed(1),
      decreasedValue: (value - 1).clamp(min, max).toStringAsFixed(1),
      onIncrease: onChanged != null ? () => onChanged((value + 1).clamp(min, max)) : null,
      onDecrease: onChanged != null ? () => onChanged((value - 1).clamp(min, max)) : null,
      child: child,
    );
  }

  /// タブのセマンティクス
  static Semantics tab({
    required Widget child,
    required String label,
    required bool selected,
    required int index,
    required int total,
    VoidCallback? onTap,
  }) {
    return Semantics(
      label: '$label、タブ、${index + 1}件目、全$total件中、${selected ? "選択済み" : "未選択"}',
      selected: selected,
      onTap: onTap,
      child: child,
    );
  }

  /// ダイアログのセマンティクス
  static Semantics dialog({
    required Widget child,
    required String title,
  }) {
    return Semantics(
      label: '$title、ダイアログ',
      scopesRoute: true,
      namesRoute: true,
      child: child,
    );
  }

  /// アラートのセマンティクス
  static Semantics alert({
    required Widget child,
    required String message,
    bool isError = false,
  }) {
    return Semantics(
      label: '${isError ? "エラー" : "通知"}、$message',
      liveRegion: true,
      child: child,
    );
  }

  /// ローディングのセマンティクス
  static Semantics loading({
    required Widget child,
    String? message,
  }) {
    return Semantics(
      label: message ?? '読み込み中',
      liveRegion: true,
      child: child,
    );
  }

  /// カードのセマンティクス
  static Semantics card({
    required Widget child,
    required String title,
    String? description,
    VoidCallback? onTap,
  }) {
    final label = description != null ? '$title、$description' : title;
    return Semantics(
      label: label,
      button: onTap != null,
      onTap: onTap,
      child: child,
    );
  }

  /// バッジのセマンティクス
  static Semantics badge({
    required Widget child,
    required String label,
    int? count,
  }) {
    final badgeLabel = count != null ? '$label、$count件' : label;
    return Semantics(
      label: badgeLabel,
      child: child,
    );
  }

  /// ツールチップのセマンティクス
  static Semantics tooltip({
    required Widget child,
    required String message,
  }) {
    return Semantics(
      tooltip: message,
      child: child,
    );
  }
}

/// Enhanced accessibility settings with WCAG AA compliance
class AccessibilitySettings {
  final bool reduceMotion;
  final bool highContrast;
  final bool largeText;
  final TextScaler textScaler;
  final bool boldText;
  final bool invertColors;
  final bool onOffSwitchLabels;
  final bool accessibleNavigation;

  const AccessibilitySettings({
    this.reduceMotion = false,
    this.highContrast = false,
    this.largeText = false,
    this.textScaler = TextScaler.noScaling,
    this.boldText = false,
    this.invertColors = false,
    this.onOffSwitchLabels = false,
    this.accessibleNavigation = false,
  });

  /// Get accessibility settings from system
  factory AccessibilitySettings.fromMediaQuery(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final platformDispatcher = WidgetsBinding.instance.platformDispatcher;

    return AccessibilitySettings(
      reduceMotion: platformDispatcher.accessibilityFeatures.disableAnimations,
      highContrast: platformDispatcher.accessibilityFeatures.highContrast,
      largeText: mediaQuery.textScaler.scale(1) > 1.3,
      textScaler: mediaQuery.textScaler,
      boldText: platformDispatcher.accessibilityFeatures.boldText,
      invertColors: platformDispatcher.accessibilityFeatures.invertColors,
      onOffSwitchLabels: platformDispatcher.accessibilityFeatures.onOffSwitchLabels,
      accessibleNavigation: platformDispatcher.accessibilityFeatures.accessibleNavigation,
    );
  }

  /// Adjust animation duration based on motion preferences
  Duration adjustDuration(Duration duration) {
    return reduceMotion ? Duration.zero : duration;
  }

  /// Adjust text style for accessibility
  TextStyle adjustTextStyle(TextStyle style) {
    var adjustedStyle = style;
    
    if (boldText && (style.fontWeight == null || style.fontWeight!.index < FontWeight.w600.index)) {
      adjustedStyle = adjustedStyle.copyWith(fontWeight: FontWeight.w600);
    }
    
    // Ensure minimum font size for accessibility
    final fontSize = adjustedStyle.fontSize ?? 14.0;
    if (largeText && fontSize < 16.0) {
      adjustedStyle = adjustedStyle.copyWith(fontSize: 16.0);
    }
    
    return adjustedStyle;
  }

  /// Get accessible color based on contrast requirements
  Color getAccessibleColor(Color original, Color background) {
    if (!highContrast) return original;
    
    final contrastRatio = _calculateContrastRatio(original, background);
    if (contrastRatio >= 4.5) return original;
    
    // Adjust color to meet WCAG AA standards
    final isBackgroundLight = background.computeLuminance() > 0.5;
    return isBackgroundLight ? const Color(0xFF000000) : const Color(0xFFFFFFFF);
  }

  /// Calculate contrast ratio between two colors
  double _calculateContrastRatio(Color foreground, Color background) {
    final fgLuminance = foreground.computeLuminance();
    final bgLuminance = background.computeLuminance();
    final lighter = fgLuminance > bgLuminance ? fgLuminance : bgLuminance;
    final darker = fgLuminance > bgLuminance ? bgLuminance : fgLuminance;
    return (lighter + 0.05) / (darker + 0.05);
  }
}

/// Widget to control reading order for screen readers
class ReadingOrderGroup extends StatelessWidget {
  final List<Widget> children;
  final Axis direction;

  const ReadingOrderGroup({
    super.key,
    required this.children,
    this.direction = Axis.vertical,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      sortKey: const OrdinalSortKey(0),
      child: direction == Axis.vertical
          ? Column(children: children)
          : Row(children: children),
    );
  }
}

/// Accessible button widget with minimum touch target size
class AccessibleButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final String? semanticLabel;
  final String? tooltip;
  final bool enabled;
  final EdgeInsets? padding;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final BorderRadius? borderRadius;

  const AccessibleButton({
    super.key,
    required this.child,
    this.onPressed,
    this.semanticLabel,
    this.tooltip,
    this.enabled = true,
    this.padding,
    this.backgroundColor,
    this.foregroundColor,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final accessibilitySettings = AccessibilitySettings.fromMediaQuery(context);
    
    Widget button = Material(
      color: backgroundColor ?? Theme.of(context).colorScheme.primary,
      borderRadius: borderRadius ?? BorderRadius.circular(8),
      child: InkWell(
        onTap: enabled ? onPressed : null,
        borderRadius: borderRadius ?? BorderRadius.circular(8),
        child: Container(
          constraints: const BoxConstraints(
            minWidth: 44.0, // WCAG AA minimum touch target
            minHeight: 44.0,
          ),
          padding: padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Center(child: child),
        ),
      ),
    );

    if (tooltip != null) {
      button = Tooltip(
        message: tooltip!,
        child: button,
      );
    }

    return Semantics(
      button: true,
      enabled: enabled,
      label: semanticLabel,
      onTap: enabled ? onPressed : null,
      child: button,
    );
  }
}

/// Focus management helper for keyboard navigation
class FocusHelper {
  /// Announce text to screen readers
  static void announce(String message, {bool assertive = false}) {
    SemanticsService.announce(
      message,
      assertive ? Assertiveness.assertive : Assertiveness.polite,
    );
  }

  /// Move focus to next focusable element
  static void focusNext(BuildContext context) {
    FocusScope.of(context).nextFocus();
  }

  /// Move focus to previous focusable element
  static void focusPrevious(BuildContext context) {
    FocusScope.of(context).previousFocus();
  }

  /// Request focus for a specific node
  static void requestFocus(FocusNode node) {
    node.requestFocus();
  }

  /// Create accessible focus node with semantic label
  static FocusNode createAccessibleFocusNode({
    String? debugLabel,
    bool canRequestFocus = true,
  }) {
    return FocusNode(
      debugLabel: debugLabel,
      canRequestFocus: canRequestFocus,
    );
  }
}

/// Contrast ratio validator for WCAG compliance
class ContrastValidator {
  /// Check if color combination meets WCAG AA standards (4.5:1)
  static bool meetsWCAGAA(Color foreground, Color background) {
    return calculateContrastRatio(foreground, background) >= 4.5;
  }

  /// Check if color combination meets WCAG AAA standards (7:1)
  static bool meetsWCAGAAA(Color foreground, Color background) {
    return calculateContrastRatio(foreground, background) >= 7.0;
  }

  /// Calculate contrast ratio between two colors
  static double calculateContrastRatio(Color foreground, Color background) {
    final fgLuminance = foreground.computeLuminance();
    final bgLuminance = background.computeLuminance();
    final lighter = fgLuminance > bgLuminance ? fgLuminance : bgLuminance;
    final darker = fgLuminance > bgLuminance ? bgLuminance : fgLuminance;
    return (lighter + 0.05) / (darker + 0.05);
  }

  /// Get accessible text color for given background
  static Color getAccessibleTextColor(Color background, {bool preferDark = true}) {
    final lightText = const Color(0xFFFFFFFF);
    final darkText = const Color(0xFF000000);
    
    final lightContrast = calculateContrastRatio(lightText, background);
    final darkContrast = calculateContrastRatio(darkText, background);
    
    if (preferDark && darkContrast >= 4.5) {
      return darkText;
    } else if (lightContrast >= 4.5) {
      return lightText;
    } else {
      return darkContrast > lightContrast ? darkText : lightText;
    }
  }

  /// Adjust color to meet minimum contrast ratio
  static Color adjustColorForContrast(
    Color original,
    Color background, {
    double minContrast = 4.5,
  }) {
    if (calculateContrastRatio(original, background) >= minContrast) {
      return original;
    }

    final isBackgroundLight = background.computeLuminance() > 0.5;
    final targetLuminance = isBackgroundLight ? 0.0 : 1.0;
    
    // Gradually adjust towards target luminance
    Color adjusted = original;
    for (double factor = 0.1; factor <= 1.0; factor += 0.1) {
      adjusted = Color.lerp(
        original,
        Color.fromARGB(
          original.alpha,
          (targetLuminance * 255).round(),
          (targetLuminance * 255).round(),
          (targetLuminance * 255).round(),
        ),
        factor,
      )!;
      
      if (calculateContrastRatio(adjusted, background) >= minContrast) {
        return adjusted;
      }
    }
    
    return adjusted;
  }
}

/// Accessibility announcement helper
class AccessibilityAnnouncer {
  /// Announce success message
  static void announceSuccess(String message) {
    FocusHelper.announce('成功: $message', assertive: true);
  }

  /// Announce error message
  static void announceError(String message) {
    FocusHelper.announce('エラー: $message', assertive: true);
  }

  /// Announce navigation change
  static void announceNavigation(String destination) {
    FocusHelper.announce('$destinationに移動しました');
  }

  /// Announce loading state
  static void announceLoading(String? message) {
    FocusHelper.announce(message ?? '読み込み中です');
  }

  /// Announce completion
  static void announceCompletion(String message) {
    FocusHelper.announce('完了: $message', assertive: true);
  }
}
