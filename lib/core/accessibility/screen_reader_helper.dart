import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';

/// スクリーンリーダー最適化ヘルパー
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

/// アクセシビリティ設定
class AccessibilitySettings {
  final bool reduceMotion;
  final bool highContrast;
  final bool largeText;
  final TextScaler textScaler;
  final bool boldText;

  const AccessibilitySettings({
    this.reduceMotion = false,
    this.highContrast = false,
    this.largeText = false,
    this.textScaler = TextScaler.noScaling,
    this.boldText = false,
  });

  /// システム設定から取得
  factory AccessibilitySettings.fromMediaQuery(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final platformDispatcher = WidgetsBinding.instance.platformDispatcher;

    return AccessibilitySettings(
      reduceMotion: platformDispatcher.accessibilityFeatures.disableAnimations,
      highContrast: platformDispatcher.accessibilityFeatures.highContrast,
      largeText: mediaQuery.textScaler.scale(1) > 1.3,
      textScaler: mediaQuery.textScaler,
      boldText: platformDispatcher.accessibilityFeatures.boldText,
    );
  }

  /// アニメーション時間を調整
  Duration adjustDuration(Duration duration) {
    return reduceMotion ? Duration.zero : duration;
  }

  /// テキストスタイルを調整
  TextStyle adjustTextStyle(TextStyle style) {
    if (boldText && style.fontWeight != FontWeight.bold) {
      return style.copyWith(fontWeight: FontWeight.w600);
    }
    return style;
  }
}

/// 読み上げ順序を制御するウィジェット
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
