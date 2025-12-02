import 'dart:math' as math;

import 'package:flutter/material.dart';

/// コントラスト検証ツール
/// WCAG 2.1準拠のコントラスト比チェック
class ContrastValidator {
  const ContrastValidator._();

  // ========================================
  // WCAG基準
  // ========================================

  /// WCAG AA 通常テキスト: 4.5:1
  static const double wcagAA = 4.5;

  /// WCAG AA 大きなテキスト: 3:1
  static const double wcagAALarge = 3.0;

  /// WCAG AAA 通常テキスト: 7:1
  static const double wcagAAA = 7.0;

  /// WCAG AAA 大きなテキスト: 4.5:1
  static const double wcagAAALarge = 4.5;

  // ========================================
  // コントラスト比計算
  // ========================================

  /// 相対輝度を計算
  static double _relativeLuminance(Color color) {
    final r = _linearize(color.red / 255.0);
    final g = _linearize(color.green / 255.0);
    final b = _linearize(color.blue / 255.0);

    return 0.2126 * r + 0.7152 * g + 0.0722 * b;
  }

  /// sRGB値を線形化
  static double _linearize(double channel) {
    if (channel <= 0.03928) {
      return channel / 12.92;
    }
    return math.pow((channel + 0.055) / 1.055, 2.4).toDouble();
  }

  /// コントラスト比を計算
  static double calculateContrastRatio(Color foreground, Color background) {
    final fgLuminance = _relativeLuminance(foreground);
    final bgLuminance = _relativeLuminance(background);

    final lighter = math.max(fgLuminance, bgLuminance);
    final darker = math.min(fgLuminance, bgLuminance);

    return (lighter + 0.05) / (darker + 0.05);
  }

  // ========================================
  // WCAG準拠チェック
  // ========================================

  /// WCAG AA準拠（通常テキスト）
  static bool meetsWCAGAA(Color foreground, Color background) {
    return calculateContrastRatio(foreground, background) >= wcagAA;
  }

  /// WCAG AA準拠（大きなテキスト）
  static bool meetsWCAGAALarge(Color foreground, Color background) {
    return calculateContrastRatio(foreground, background) >= wcagAALarge;
  }

  /// WCAG AAA準拠（通常テキスト）
  static bool meetsWCAGAAA(Color foreground, Color background) {
    return calculateContrastRatio(foreground, background) >= wcagAAA;
  }

  /// WCAG AAA準拠（大きなテキスト）
  static bool meetsWCAGAAALarge(Color foreground, Color background) {
    return calculateContrastRatio(foreground, background) >= wcagAAALarge;
  }

  // ========================================
  // 色の調整
  // ========================================

  /// 指定したコントラスト比を満たすように色を調整
  static Color ensureContrast(
    Color foreground,
    Color background, {
    double minContrast = wcagAA,
    int maxIterations = 100,
  }) {
    if (calculateContrastRatio(foreground, background) >= minContrast) {
      return foreground;
    }

    final bgLuminance = _relativeLuminance(background);
    final isBackgroundLight = bgLuminance > 0.5;

    // 背景が明るい場合は暗く、暗い場合は明るく調整
    Color adjusted = foreground;
    for (int i = 0; i < maxIterations; i++) {
      if (calculateContrastRatio(adjusted, background) >= minContrast) {
        return adjusted;
      }

      if (isBackgroundLight) {
        // 暗くする
        adjusted = _darken(adjusted, 0.05);
      } else {
        // 明るくする
        adjusted = _lighten(adjusted, 0.05);
      }
    }

    // 最終手段: 黒または白
    return isBackgroundLight ? Colors.black : Colors.white;
  }

  /// 色を明るくする
  static Color _lighten(Color color, double amount) {
    final hsl = HSLColor.fromColor(color);
    final lightness = math.min(1.0, hsl.lightness + amount);
    return hsl.withLightness(lightness).toColor();
  }

  /// 色を暗くする
  static Color _darken(Color color, double amount) {
    final hsl = HSLColor.fromColor(color);
    final lightness = math.max(0.0, hsl.lightness - amount);
    return hsl.withLightness(lightness).toColor();
  }

  // ========================================
  // テキストサイズ判定
  // ========================================

  /// 大きなテキストかどうか（18pt以上、または14pt太字以上）
  static bool isLargeText(double fontSize, FontWeight fontWeight) {
    // 18pt = 24px (1pt = 1.333px)
    if (fontSize >= 24) return true;

    // 14pt太字 = 18.67px
    if (fontSize >= 18.67 && fontWeight.index >= FontWeight.w700.index) {
      return true;
    }

    return false;
  }

  // ========================================
  // レポート生成
  // ========================================

  /// コントラストレポートを生成
  static ContrastReport generateReport(
    Color foreground,
    Color background, {
    double? fontSize,
    FontWeight? fontWeight,
  }) {
    final ratio = calculateContrastRatio(foreground, background);
    final isLarge =
        fontSize != null && fontWeight != null
            ? isLargeText(fontSize, fontWeight)
            : false;

    return ContrastReport(
      foreground: foreground,
      background: background,
      contrastRatio: ratio,
      isLargeText: isLarge,
      meetsAA: isLarge ? ratio >= wcagAALarge : ratio >= wcagAA,
      meetsAAA: isLarge ? ratio >= wcagAAALarge : ratio >= wcagAAA,
    );
  }

  // ========================================
  // バッチ検証
  // ========================================

  /// 複数の色の組み合わせを検証
  static List<ContrastReport> validateColorPairs(List<ColorPair> pairs) {
    return pairs.map((pair) {
      return generateReport(
        pair.foreground,
        pair.background,
        fontSize: pair.fontSize,
        fontWeight: pair.fontWeight,
      );
    }).toList();
  }

  /// テーマ全体のコントラストを検証
  static ThemeContrastReport validateTheme(ThemeData theme) {
    final reports = <String, ContrastReport>{};

    // プライマリテキスト
    reports['primary_on_background'] = generateReport(
      theme.colorScheme.onSurface,
      theme.colorScheme.surface,
    );

    reports['primary_on_surface'] = generateReport(
      theme.colorScheme.onSurface,
      theme.colorScheme.surface,
    );

    // ボタン
    reports['primary_button'] = generateReport(
      theme.colorScheme.onPrimary,
      theme.colorScheme.primary,
    );

    // エラー
    reports['error_text'] = generateReport(
      theme.colorScheme.onError,
      theme.colorScheme.error,
    );

    // セカンダリ
    reports['secondary_text'] = generateReport(
      theme.colorScheme.onSecondary,
      theme.colorScheme.secondary,
    );

    return ThemeContrastReport(reports: reports);
  }
}

/// 色のペア
class ColorPair {
  final Color foreground;
  final Color background;
  final double? fontSize;
  final FontWeight? fontWeight;
  final String? label;

  const ColorPair({
    required this.foreground,
    required this.background,
    this.fontSize,
    this.fontWeight,
    this.label,
  });
}

/// コントラストレポート
class ContrastReport {
  final Color foreground;
  final Color background;
  final double contrastRatio;
  final bool isLargeText;
  final bool meetsAA;
  final bool meetsAAA;

  const ContrastReport({
    required this.foreground,
    required this.background,
    required this.contrastRatio,
    required this.isLargeText,
    required this.meetsAA,
    required this.meetsAAA,
  });

  /// レポートを文字列として出力
  String toReadableString() {
    final buffer = StringBuffer();
    buffer.writeln('Contrast Ratio: ${contrastRatio.toStringAsFixed(2)}:1');
    buffer.writeln('Text Size: ${isLargeText ? "Large" : "Normal"}');
    buffer.writeln('WCAG AA: ${meetsAA ? "✓ Pass" : "✗ Fail"}');
    buffer.writeln('WCAG AAA: ${meetsAAA ? "✓ Pass" : "✗ Fail"}');
    return buffer.toString();
  }

  /// 合格レベルを取得
  String get complianceLevel {
    if (meetsAAA) return 'AAA';
    if (meetsAA) return 'AA';
    return 'Fail';
  }
}

/// テーマコントラストレポート
class ThemeContrastReport {
  final Map<String, ContrastReport> reports;

  const ThemeContrastReport({required this.reports});

  /// すべてAA準拠か
  bool get allMeetAA {
    return reports.values.every((report) => report.meetsAA);
  }

  /// すべてAAA準拠か
  bool get allMeetAAA {
    return reports.values.every((report) => report.meetsAAA);
  }

  /// 不合格の項目
  List<String> get failedItems {
    return reports.entries
        .where((entry) => !entry.value.meetsAA)
        .map((entry) => entry.key)
        .toList();
  }

  /// レポートを文字列として出力
  String toReadableString() {
    final buffer = StringBuffer();
    buffer.writeln('=== Theme Contrast Report ===');
    buffer.writeln('Overall AA Compliance: ${allMeetAA ? "✓ Pass" : "✗ Fail"}');
    buffer.writeln(
      'Overall AAA Compliance: ${allMeetAAA ? "✓ Pass" : "✗ Fail"}',
    );
    buffer.writeln('');

    for (final entry in reports.entries) {
      buffer.writeln('${entry.key}:');
      buffer.writeln(entry.value.toReadableString());
      buffer.writeln('');
    }

    if (failedItems.isNotEmpty) {
      buffer.writeln('Failed Items:');
      for (final item in failedItems) {
        buffer.writeln('  - $item');
      }
    }

    return buffer.toString();
  }
}

/// コントラストチェッカーウィジェット（デバッグ用）
class ContrastChecker extends StatelessWidget {
  final Color foreground;
  final Color background;
  final String? label;
  final double? fontSize;
  final FontWeight? fontWeight;

  const ContrastChecker({
    super.key,
    required this.foreground,
    required this.background,
    this.label,
    this.fontSize,
    this.fontWeight,
  });

  @override
  Widget build(BuildContext context) {
    final report = ContrastValidator.generateReport(
      foreground,
      background,
      fontSize: fontSize,
      fontWeight: fontWeight,
    );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: background,
        border: Border.all(color: Colors.grey),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (label != null)
            Text(
              label!,
              style: TextStyle(
                color: foreground,
                fontSize: fontSize ?? 14,
                fontWeight: fontWeight ?? FontWeight.normal,
              ),
            ),
          const SizedBox(height: 8),
          Text(
            'Ratio: ${report.contrastRatio.toStringAsFixed(2)}:1',
            style: const TextStyle(fontSize: 12),
          ),
          Text(
            'AA: ${report.meetsAA ? "✓" : "✗"} | AAA: ${report.meetsAAA ? "✓" : "✗"}',
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }
}

/// Color拡張
extension ContrastExtension on Color {
  /// 指定した背景色に対するコントラスト比を計算
  double contrastWith(Color background) {
    return ContrastValidator.calculateContrastRatio(this, background);
  }

  /// 指定した背景色に対してWCAG AA準拠か
  bool meetsWCAGAA(Color background) {
    return ContrastValidator.meetsWCAGAA(this, background);
  }

  /// 指定した背景色に対してWCAG AAA準拠か
  bool meetsWCAGAAA(Color background) {
    return ContrastValidator.meetsWCAGAAA(this, background);
  }

  /// 指定した背景色に対して適切なコントラストになるよう調整
  Color ensureContrastWith(Color background, {double minContrast = 4.5}) {
    return ContrastValidator.ensureContrast(
      this,
      background,
      minContrast: minContrast,
    );
  }
}
