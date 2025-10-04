import 'dart:math' as math;

import 'package:flutter/material.dart';

/// コントラスト検証チE�Eル
/// WCAG 2.1準拠のコントラスト比チェチE��
class ContrastValidator {
  const ContrastValidator._();

  // ========================================
  // WCAG基溁E
  // ========================================

  /// WCAG AA 通常チE��スチE 4.5:1
  static const double wcagAA = 4.5;

  /// WCAG AA 大きなチE��スチE 3:1
  static const double wcagAALarge = 3.0;

  /// WCAG AAA 通常チE��スチE 7:1
  static const double wcagAAA = 7.0;

  /// WCAG AAA 大きなチE��スチE 4.5:1
  static const double wcagAAALarge = 4.5;

  // ========================================
  // コントラスト比計箁E
  // ========================================

  /// 相対輝度を計箁E
  static double _relativeLuminance(Color color) {
    final r = _linearize(color.red / 255.0);
    final g = _linearize(color.green / 255.0);
    final b = _linearize(color.blue / 255.0);

    return 0.2126 * r + 0.7152 * g + 0.0722 * b;
  }

  /// sRGB値を線形匁E
  static double _linearize(double channel) {
    if (channel <= 0.03928) {
      return channel / 12.92;
    }
    return math.pow((channel + 0.055) / 1.055, 2.4).toDouble();
  }

  /// コントラスト比を計箁E
  static double calculateContrastRatio(Color foreground, Color background) {
    final fgLuminance = _relativeLuminance(foreground);
    final bgLuminance = _relativeLuminance(background);

    final lighter = math.max(fgLuminance, bgLuminance);
    final darker = math.min(fgLuminance, bgLuminance);

    return (lighter + 0.05) / (darker + 0.05);
  }

  // ========================================
  // WCAG準拠チェチE��
  // ========================================

  /// WCAG AA準拠�E�通常チE��スト！E
  static bool meetsWCAGAA(Color foreground, Color background) {
    return calculateContrastRatio(foreground, background) >= wcagAA;
  }

  /// WCAG AA準拠�E�大きなチE��スト！E
  static bool meetsWCAGAALarge(Color foreground, Color background) {
    return calculateContrastRatio(foreground, background) >= wcagAALarge;
  }

  /// WCAG AAA準拠�E�通常チE��スト！E
  static bool meetsWCAGAAA(Color foreground, Color background) {
    return calculateContrastRatio(foreground, background) >= wcagAAA;
  }

  /// WCAG AAA準拠�E�大きなチE��スト！E
  static bool meetsWCAGAAALarge(Color foreground, Color background) {
    return calculateContrastRatio(foreground, background) >= wcagAAALarge;
  }

  // ========================================
  // 色の調整
  // ========================================

  /// 持E��したコントラスト比を満たすように色を調整
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

    // 背景が�Eるい場合�E暗く、暗ぁE��合�E明るく調整
    Color adjusted = foreground;
    for (int i = 0; i < maxIterations; i++) {
      if (calculateContrastRatio(adjusted, background) >= minContrast) {
        return adjusted;
      }

      if (isBackgroundLight) {
        // 暗くする
        adjusted = _darken(adjusted, 0.05);
      } else {
        // 明るくすめE
        adjusted = _lighten(adjusted, 0.05);
      }
    }

    // 最終手段: 黒また�E白
    return isBackgroundLight ? Colors.black : Colors.white;
  }

  /// 色を�Eるくする
  static Color _lighten(Color color, double amount) {
    final hsl = HSLColor.fromColor(color);
    final lightness = math.min(1.0, hsl.lightness + amount);
    return hsl.withLightness(lightness).toColor();
  }

  /// 色を暗くすめE
  static Color _darken(Color color, double amount) {
    final hsl = HSLColor.fromColor(color);
    final lightness = math.max(0.0, hsl.lightness - amount);
    return hsl.withLightness(lightness).toColor();
  }

  // ========================================
  // チE��ストサイズ判宁E
  // ========================================

  /// 大きなチE��ストかどぁE���E�E8pt以上、また�E14pt太字以上！E
  static bool isLargeText(double fontSize, FontWeight fontWeight) {
    // 18pt = 24px (1pt = 1.333px)
    if (fontSize >= 24) return true;

    // 14pt太孁E= 18.67px
    if (fontSize >= 18.67 && fontWeight.index >= FontWeight.w700.index) {
      return true;
    }

    return false;
  }

  // ========================================
  // レポ�Eト生戁E
  // ========================================

  /// コントラストレポ�Eトを生�E
  static ContrastReport generateReport(
    Color foreground,
    Color background, {
    double? fontSize,
    FontWeight? fontWeight,
  }) {
    final ratio = calculateContrastRatio(foreground, background);
    final isLarge = fontSize != null && fontWeight != null
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

  /// 褁E��の色の絁E��合わせを検証
  static List<ContrastReport> validateColorPairs(
    List<ColorPair> pairs,
  ) {
    return pairs.map((pair) {
      return generateReport(
        pair.foreground,
        pair.background,
        fontSize: pair.fontSize,
        fontWeight: pair.fontWeight,
      );
    }).toList();
  }

  /// チE�Eマ�E体�Eコントラストを検証
  static ThemeContrastReport validateTheme(ThemeData theme) {
    final reports = <String, ContrastReport>{};

    // プライマリチE��スチE
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

/// コントラストレポ�EチE
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

  /// レポ�Eトを斁E���Eとして出劁E
  String toReadableString() {
    final buffer = StringBuffer();
    buffer.writeln('Contrast Ratio: ${contrastRatio.toStringAsFixed(2)}:1');
    buffer.writeln('Text Size: ${isLargeText ? "Large" : "Normal"}');
    buffer.writeln('WCAG AA: ${meetsAA ? "✁EPass" : "✁EFail"}');
    buffer.writeln('WCAG AAA: ${meetsAAA ? "✁EPass" : "✁EFail"}');
    return buffer.toString();
  }

  /// 合格レベルを取征E
  String get complianceLevel {
    if (meetsAAA) return 'AAA';
    if (meetsAA) return 'AA';
    return 'Fail';
  }
}

/// チE�Eマコントラストレポ�EチE
class ThemeContrastReport {
  final Map<String, ContrastReport> reports;

  const ThemeContrastReport({required this.reports});

  /// すべてAA準拠ぁE
  bool get allMeetAA {
    return reports.values.every((report) => report.meetsAA);
  }

  /// すべてAAA準拠ぁE
  bool get allMeetAAA {
    return reports.values.every((report) => report.meetsAAA);
  }

  /// 不合格の頁E��
  List<String> get failedItems {
    return reports.entries
        .where((entry) => !entry.value.meetsAA)
        .map((entry) => entry.key)
        .toList();
  }

  /// レポ�Eトを斁E���Eとして出劁E
  String toReadableString() {
    final buffer = StringBuffer();
    buffer.writeln('=== Theme Contrast Report ===');
    buffer.writeln('Overall AA Compliance: ${allMeetAA ? "✁EPass" : "✁EFail"}');
    buffer.writeln(
        'Overall AAA Compliance: ${allMeetAAA ? "✁EPass" : "✁EFail"}',);
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

/// コントラストチェチE��ーウィジェチE���E�デバッグ用�E�E
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
            'AA: ${report.meetsAA ? "✁E : "✁E} | AAA: ${report.meetsAAA ? "✁E : "✁E}',
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }
}

/// Color拡張
extension ContrastExtension on Color {
  /// 持E��した背景色に対するコントラスト比を計箁E
  double contrastWith(Color background) {
    return ContrastValidator.calculateContrastRatio(this, background);
  }

  /// 持E��した背景色に対してWCAG AA準拠ぁE
  bool meetsWCAGAA(Color background) {
    return ContrastValidator.meetsWCAGAA(this, background);
  }

  /// 持E��した背景色に対してWCAG AAA準拠ぁE
  bool meetsWCAGAAA(Color background) {
    return ContrastValidator.meetsWCAGAAA(this, background);
  }

  /// 持E��した背景色に対して適刁E��コントラストになるよぁE��整
  Color ensureContrastWith(Color background, {double minContrast = 4.5}) {
    return ContrastValidator.ensureContrast(
      this,
      background,
      minContrast: minContrast,
    );
  }
}
