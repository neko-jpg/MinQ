import 'dart:math' as math;

import 'package:flutter/material.dart';

/// 繧ｳ繝ｳ繝医Λ繧ｹ繝域､懆ｨｼ繝・・繝ｫ
/// WCAG 2.1貅匁侠縺ｮ繧ｳ繝ｳ繝医Λ繧ｹ繝域ｯ斐メ繧ｧ繝・け
class ContrastValidator {
  const ContrastValidator._();

  // ========================================
  // WCAG蝓ｺ貅・
  // ========================================

  /// WCAG AA 騾壼ｸｸ繝・く繧ｹ繝・ 4.5:1
  static const double wcagAA = 4.5;

  /// WCAG AA 螟ｧ縺阪↑繝・く繧ｹ繝・ 3:1
  static const double wcagAALarge = 3.0;

  /// WCAG AAA 騾壼ｸｸ繝・く繧ｹ繝・ 7:1
  static const double wcagAAA = 7.0;

  /// WCAG AAA 螟ｧ縺阪↑繝・く繧ｹ繝・ 4.5:1
  static const double wcagAAALarge = 4.5;

  // ========================================
  // 繧ｳ繝ｳ繝医Λ繧ｹ繝域ｯ碑ｨ育ｮ・
  // ========================================

  /// 逶ｸ蟇ｾ霈晏ｺｦ繧定ｨ育ｮ・
  static double _relativeLuminance(Color color) {
    final r = _linearize(color.red / 255.0);
    final g = _linearize(color.green / 255.0);
    final b = _linearize(color.blue / 255.0);

    return 0.2126 * r + 0.7152 * g + 0.0722 * b;
  }

  /// sRGB蛟､繧堤ｷ壼ｽ｢蛹・
  static double _linearize(double channel) {
    if (channel <= 0.03928) {
      return channel / 12.92;
    }
    return math.pow((channel + 0.055) / 1.055, 2.4).toDouble();
  }

  /// 繧ｳ繝ｳ繝医Λ繧ｹ繝域ｯ斐ｒ險育ｮ・
  static double calculateContrastRatio(Color foreground, Color background) {
    final fgLuminance = _relativeLuminance(foreground);
    final bgLuminance = _relativeLuminance(background);

    final lighter = math.max(fgLuminance, bgLuminance);
    final darker = math.min(fgLuminance, bgLuminance);

    return (lighter + 0.05) / (darker + 0.05);
  }

  // ========================================
  // WCAG貅匁侠繝√ぉ繝・け
  // ========================================

  /// WCAG AA貅匁侠・磯壼ｸｸ繝・く繧ｹ繝茨ｼ・
  static bool meetsWCAGAA(Color foreground, Color background) {
    return calculateContrastRatio(foreground, background) >= wcagAA;
  }

  /// WCAG AA貅匁侠・亥､ｧ縺阪↑繝・く繧ｹ繝茨ｼ・
  static bool meetsWCAGAALarge(Color foreground, Color background) {
    return calculateContrastRatio(foreground, background) >= wcagAALarge;
  }

  /// WCAG AAA貅匁侠・磯壼ｸｸ繝・く繧ｹ繝茨ｼ・
  static bool meetsWCAGAAA(Color foreground, Color background) {
    return calculateContrastRatio(foreground, background) >= wcagAAA;
  }

  /// WCAG AAA貅匁侠・亥､ｧ縺阪↑繝・く繧ｹ繝茨ｼ・
  static bool meetsWCAGAAALarge(Color foreground, Color background) {
    return calculateContrastRatio(foreground, background) >= wcagAAALarge;
  }

  // ========================================
  // 濶ｲ縺ｮ隱ｿ謨ｴ
  // ========================================

  /// 謖・ｮ壹＠縺溘さ繝ｳ繝医Λ繧ｹ繝域ｯ斐ｒ貅縺溘☆繧医≧縺ｫ濶ｲ繧定ｪｿ謨ｴ
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

    // 閭梧勹縺梧・繧九＞蝣ｴ蜷医・證励￥縲∵囓縺・ｴ蜷医・譏弱ｋ縺剰ｪｿ謨ｴ
    Color adjusted = foreground;
    for (int i = 0; i < maxIterations; i++) {
      if (calculateContrastRatio(adjusted, background) >= minContrast) {
        return adjusted;
      }

      if (isBackgroundLight) {
        // 證励￥縺吶ｋ
        adjusted = _darken(adjusted, 0.05);
      } else {
        // 譏弱ｋ縺上☆繧・
        adjusted = _lighten(adjusted, 0.05);
      }
    }

    // 譛邨よ焔谿ｵ: 鮟偵∪縺溘・逋ｽ
    return isBackgroundLight ? Colors.black : Colors.white;
  }

  /// 濶ｲ繧呈・繧九￥縺吶ｋ
  static Color _lighten(Color color, double amount) {
    final hsl = HSLColor.fromColor(color);
    final lightness = math.min(1.0, hsl.lightness + amount);
    return hsl.withLightness(lightness).toColor();
  }

  /// 濶ｲ繧呈囓縺上☆繧・
  static Color _darken(Color color, double amount) {
    final hsl = HSLColor.fromColor(color);
    final lightness = math.max(0.0, hsl.lightness - amount);
    return hsl.withLightness(lightness).toColor();
  }

  // ========================================
  // 繝・く繧ｹ繝医し繧､繧ｺ蛻､螳・
  // ========================================

  /// 螟ｧ縺阪↑繝・く繧ｹ繝医°縺ｩ縺・°・・8pt莉･荳翫√∪縺溘・14pt螟ｪ蟄嶺ｻ･荳奇ｼ・
  static bool isLargeText(double fontSize, FontWeight fontWeight) {
    // 18pt = 24px (1pt = 1.333px)
    if (fontSize >= 24) return true;

    // 14pt螟ｪ蟄・= 18.67px
    if (fontSize >= 18.67 && fontWeight.index >= FontWeight.w700.index) {
      return true;
    }

    return false;
  }

  // ========================================
  // 繝ｬ繝昴・繝育函謌・
  // ========================================

  /// 繧ｳ繝ｳ繝医Λ繧ｹ繝医Ξ繝昴・繝医ｒ逕滓・
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
  // 繝舌ャ繝∵､懆ｨｼ
  // ========================================

  /// 隍・焚縺ｮ濶ｲ縺ｮ邨・∩蜷医ｏ縺帙ｒ讀懆ｨｼ
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

  /// 繝・・繝槫・菴薙・繧ｳ繝ｳ繝医Λ繧ｹ繝医ｒ讀懆ｨｼ
  static ThemeContrastReport validateTheme(ThemeData theme) {
    final reports = <String, ContrastReport>{};

    // 繝励Λ繧､繝槭Μ繝・く繧ｹ繝・
    reports['primary_on_background'] = generateReport(
      theme.colorScheme.onSurface,
      theme.colorScheme.surface,
    );

    reports['primary_on_surface'] = generateReport(
      theme.colorScheme.onSurface,
      theme.colorScheme.surface,
    );

    // 繝懊ち繝ｳ
    reports['primary_button'] = generateReport(
      theme.colorScheme.onPrimary,
      theme.colorScheme.primary,
    );

    // 繧ｨ繝ｩ繝ｼ
    reports['error_text'] = generateReport(
      theme.colorScheme.onError,
      theme.colorScheme.error,
    );

    // 繧ｻ繧ｫ繝ｳ繝繝ｪ
    reports['secondary_text'] = generateReport(
      theme.colorScheme.onSecondary,
      theme.colorScheme.secondary,
    );

    return ThemeContrastReport(reports: reports);
  }
}

/// 濶ｲ縺ｮ繝壹い
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

/// 繧ｳ繝ｳ繝医Λ繧ｹ繝医Ξ繝昴・繝・
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

  /// 繝ｬ繝昴・繝医ｒ譁・ｭ怜・縺ｨ縺励※蜃ｺ蜉・
  String toReadableString() {
    final buffer = StringBuffer();
    buffer.writeln('Contrast Ratio: ${contrastRatio.toStringAsFixed(2)}:1');
    buffer.writeln('Text Size: ${isLargeText ? "Large" : "Normal"}');
    buffer.writeln('WCAG AA: ${meetsAA ? "笨・Pass" : "笨・Fail"}');
    buffer.writeln('WCAG AAA: ${meetsAAA ? "笨・Pass" : "笨・Fail"}');
    return buffer.toString();
  }

  /// 蜷域ｼ繝ｬ繝吶Ν繧貞叙蠕・
  String get complianceLevel {
    if (meetsAAA) return 'AAA';
    if (meetsAA) return 'AA';
    return 'Fail';
  }
}

/// 繝・・繝槭さ繝ｳ繝医Λ繧ｹ繝医Ξ繝昴・繝・
class ThemeContrastReport {
  final Map<String, ContrastReport> reports;

  const ThemeContrastReport({required this.reports});

  /// 縺吶∋縺ｦAA貅匁侠縺・
  bool get allMeetAA {
    return reports.values.every((report) => report.meetsAA);
  }

  /// 縺吶∋縺ｦAAA貅匁侠縺・
  bool get allMeetAAA {
    return reports.values.every((report) => report.meetsAAA);
  }

  /// 荳榊粋譬ｼ縺ｮ鬆・岼
  List<String> get failedItems {
    return reports.entries
        .where((entry) => !entry.value.meetsAA)
        .map((entry) => entry.key)
        .toList();
  }

  /// 繝ｬ繝昴・繝医ｒ譁・ｭ怜・縺ｨ縺励※蜃ｺ蜉・
  String toReadableString() {
    final buffer = StringBuffer();
    buffer.writeln('=== Theme Contrast Report ===');
    buffer.writeln('Overall AA Compliance: ${allMeetAA ? "笨・Pass" : "笨・Fail"}');
    buffer.writeln(
        'Overall AAA Compliance: ${allMeetAAA ? "笨・Pass" : "笨・Fail"}',);
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

/// 繧ｳ繝ｳ繝医Λ繧ｹ繝医メ繧ｧ繝・き繝ｼ繧ｦ繧｣繧ｸ繧ｧ繝・ヨ・医ョ繝舌ャ繧ｰ逕ｨ・・
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
            'AA: ${report.meetsAA ? "笨・ : "笨・} | AAA: ${report.meetsAAA ? "笨・ : "笨・}',
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }
}

/// Color諡｡蠑ｵ
extension ContrastExtension on Color {
  /// 謖・ｮ壹＠縺溯レ譎ｯ濶ｲ縺ｫ蟇ｾ縺吶ｋ繧ｳ繝ｳ繝医Λ繧ｹ繝域ｯ斐ｒ險育ｮ・
  double contrastWith(Color background) {
    return ContrastValidator.calculateContrastRatio(this, background);
  }

  /// 謖・ｮ壹＠縺溯レ譎ｯ濶ｲ縺ｫ蟇ｾ縺励※WCAG AA貅匁侠縺・
  bool meetsWCAGAA(Color background) {
    return ContrastValidator.meetsWCAGAA(this, background);
  }

  /// 謖・ｮ壹＠縺溯レ譎ｯ濶ｲ縺ｫ蟇ｾ縺励※WCAG AAA貅匁侠縺・
  bool meetsWCAGAAA(Color background) {
    return ContrastValidator.meetsWCAGAAA(this, background);
  }

  /// 謖・ｮ壹＠縺溯レ譎ｯ濶ｲ縺ｫ蟇ｾ縺励※驕ｩ蛻・↑繧ｳ繝ｳ繝医Λ繧ｹ繝医↓縺ｪ繧九ｈ縺・ｪｿ謨ｴ
  Color ensureContrastWith(Color background, {double minContrast = 4.5}) {
    return ContrastValidator.ensureContrast(
      this,
      background,
      minContrast: minContrast,
    );
  }
}
