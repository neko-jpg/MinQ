import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// 繧ｿ繧､繝昴げ繝ｩ繝輔ぅ繧ｷ繧ｹ繝・Β螳悟・螳夂ｾｩ
/// H1-H6縲。ody縲，aption縲｀ono縺ｮ髫主ｱ､繧呈署萓・
class TypographySystem {
  const TypographySystem._();

  // ========================================
  // Display Styles (譛螟ｧ隕句・縺・
  // ========================================

  /// H1 - 譛螟ｧ縺ｮ隕句・縺暦ｼ医Λ繝ｳ繝・ぅ繝ｳ繧ｰ繝壹・繧ｸ縲・㍾隕√↑逕ｻ髱｢繧ｿ繧､繝医Ν・・
  static TextStyle h1({Color? color}) => GoogleFonts.plusJakartaSans(
        fontSize: 40,
        fontWeight: FontWeight.w800,
        letterSpacing: -1.0,
        height: 1.2,
        color: color,
      );

  /// H2 - 螟ｧ縺阪↑隕句・縺暦ｼ医そ繧ｯ繧ｷ繝ｧ繝ｳ繧ｿ繧､繝医Ν・・
  static TextStyle h2({Color? color}) => GoogleFonts.plusJakartaSans(
        fontSize: 32,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.5,
        height: 1.25,
        color: color,
      );

  /// H3 - 荳ｭ隕句・縺暦ｼ医き繝ｼ繝峨ち繧､繝医Ν縲∫判髱｢繧ｵ繝悶ち繧､繝医Ν・・
  static TextStyle h3({Color? color}) => GoogleFonts.plusJakartaSans(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.3,
        height: 1.3,
        color: color,
      );

  // ========================================
  // Title Styles (繧ｿ繧､繝医Ν)
  // ========================================

  /// H4 - 蟆剰ｦ句・縺暦ｼ医そ繧ｯ繧ｷ繝ｧ繝ｳ蜀・・繧ｿ繧､繝医Ν・・
  static TextStyle h4({Color? color}) => GoogleFonts.plusJakartaSans(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.2,
        height: 1.35,
        color: color,
      );

  /// H5 - 譛蟆剰ｦ句・縺暦ｼ医Μ繧ｹ繝医い繧､繝・Β繧ｿ繧､繝医Ν・・
  static TextStyle h5({Color? color}) => GoogleFonts.plusJakartaSans(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        height: 1.4,
        color: color,
      );

  /// H6 - 讌ｵ蟆剰ｦ句・縺暦ｼ医う繝ｳ繝ｩ繧､繝ｳ繧ｿ繧､繝医Ν・・
  static TextStyle h6({Color? color}) => GoogleFonts.plusJakartaSans(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        height: 1.5,
        color: color,
      );

  // ========================================
  // Body Styles (譛ｬ譁・
  // ========================================

  /// Body Large - 螟ｧ縺阪↑譛ｬ譁・ｼ磯㍾隕√↑隱ｬ譏取枚・・
  static TextStyle bodyLarge({Color? color}) => GoogleFonts.plusJakartaSans(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        height: 1.5,
        letterSpacing: 0,
        color: color,
      );

  /// Body Medium - 讓呎ｺ匁悽譁・ｼ磯壼ｸｸ縺ｮ隱ｬ譏取枚・・
  static TextStyle bodyMedium({Color? color}) => GoogleFonts.plusJakartaSans(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        height: 1.5,
        letterSpacing: 0,
        color: color,
      );

  /// Body Small - 蟆上＆縺ｪ譛ｬ譁・ｼ郁｣懆ｶｳ隱ｬ譏趣ｼ・
  static TextStyle bodySmall({Color? color}) => GoogleFonts.plusJakartaSans(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        height: 1.4,
        letterSpacing: 0,
        color: color,
      );

  // ========================================
  // Caption Styles (繧ｭ繝｣繝励す繝ｧ繝ｳ)
  // ========================================

  /// Caption - 繧ｭ繝｣繝励す繝ｧ繝ｳ・育判蜒剰ｪｬ譏弱√Γ繧ｿ諠・ｱ・・
  static TextStyle caption({Color? color}) => GoogleFonts.plusJakartaSans(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        height: 1.4,
        letterSpacing: 0.2,
        color: color,
      );

  /// Overline - 繧ｪ繝ｼ繝舌・繝ｩ繧､繝ｳ・医Λ繝吶Ν縲√き繝・ざ繝ｪ・・
  static TextStyle overline({Color? color}) => GoogleFonts.plusJakartaSans(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        height: 1.3,
        letterSpacing: 0.5,
        color: color,
      );

  // ========================================
  // Button Styles (繝懊ち繝ｳ)
  // ========================================

  /// Button Large - 螟ｧ縺阪↑繝懊ち繝ｳ
  static TextStyle buttonLarge({Color? color}) => GoogleFonts.plusJakartaSans(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.2,
        height: 1.2,
        color: color,
      );

  /// Button Medium - 讓呎ｺ悶・繧ｿ繝ｳ
  static TextStyle buttonMedium({Color? color}) => GoogleFonts.plusJakartaSans(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.2,
        height: 1.2,
        color: color,
      );

  /// Button Small - 蟆上＆縺ｪ繝懊ち繝ｳ
  static TextStyle buttonSmall({Color? color}) => GoogleFonts.plusJakartaSans(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.3,
        height: 1.2,
        color: color,
      );

  // ========================================
  // Monospace Styles (遲牙ｹ・ヵ繧ｩ繝ｳ繝・
  // ========================================

  /// Mono Large - 螟ｧ縺阪↑遲牙ｹ・ｼ医さ繝ｼ繝峨∵焚蛟､・・
  static TextStyle monoLarge({Color? color}) => GoogleFonts.robotoMono(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        height: 1.5,
        letterSpacing: 0,
        color: color,
      );

  /// Mono Medium - 讓呎ｺ也ｭ牙ｹ・
  static TextStyle monoMedium({Color? color}) => GoogleFonts.robotoMono(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        height: 1.5,
        letterSpacing: 0,
        color: color,
      );

  /// Mono Small - 蟆上＆縺ｪ遲牙ｹ・
  static TextStyle monoSmall({Color? color}) => GoogleFonts.robotoMono(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        height: 1.4,
        letterSpacing: 0,
        color: color,
      );

  // ========================================
  // Emotional Styles (諢滓ュ逧・↑繧ｹ繧ｿ繧､繝ｫ)
  // ========================================

  /// Celebration - 逾晉ｦ上ユ繧ｭ繧ｹ繝・
  static TextStyle celebration({Color? color}) => GoogleFonts.plusJakartaSans(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        height: 1.3,
        letterSpacing: -0.2,
        color: color ?? const Color(0xFFFFD700),
      );

  /// Encouragement - 蜉ｱ縺ｾ縺励ユ繧ｭ繧ｹ繝・
  static TextStyle encouragement({Color? color}) => GoogleFonts.plusJakartaSans(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        height: 1.4,
        letterSpacing: 0,
        color: color ?? const Color(0xFFFF6B6B),
      );

  /// Guidance - 繧ｬ繧､繝繝ｳ繧ｹ繝・く繧ｹ繝・
  static TextStyle guidance({Color? color}) => GoogleFonts.plusJakartaSans(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        height: 1.5,
        letterSpacing: 0,
        color: color ?? const Color(0xFF4ECDC4),
      );

  /// Whisper - 縺輔＆繧・″繝・く繧ｹ繝茨ｼ域而縺医ａ縺ｪ繝偵Φ繝茨ｼ・
  static TextStyle whisper({Color? color}) => GoogleFonts.plusJakartaSans(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        height: 1.4,
        letterSpacing: 0.1,
        color: color ?? const Color(0xFF94A3B8),
      );

  // ========================================
  // Numeric Styles (謨ｰ蛟､陦ｨ遉ｺ)
  // ========================================

  /// Numeric Large - 螟ｧ縺阪↑謨ｰ蛟､・育ｵｱ險医√き繧ｦ繝ｳ繧ｿ繝ｼ・・
  static TextStyle numericLarge({Color? color}) => GoogleFonts.plusJakartaSans(
        fontSize: 48,
        fontWeight: FontWeight.w800,
        height: 1.1,
        letterSpacing: -1.0,
        fontFeatures: [const FontFeature.tabularFigures()],
        color: color,
      );

  /// Numeric Medium - 讓呎ｺ匁焚蛟､
  static TextStyle numericMedium({Color? color}) => GoogleFonts.plusJakartaSans(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        height: 1.2,
        letterSpacing: -0.5,
        fontFeatures: [const FontFeature.tabularFigures()],
        color: color,
      );

  /// Numeric Small - 蟆上＆縺ｪ謨ｰ蛟､
  static TextStyle numericSmall({Color? color}) => GoogleFonts.plusJakartaSans(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        height: 1.3,
        letterSpacing: 0,
        fontFeatures: [const FontFeature.tabularFigures()],
        color: color,
      );
}

/// 繧ｿ繧､繝昴げ繝ｩ繝輔ぅ繝倥Ν繝代・諡｡蠑ｵ
extension TypographyExtension on TextStyle {
  /// 螟ｪ蟄励↓縺吶ｋ
  TextStyle get bold => copyWith(fontWeight: FontWeight.w700);

  /// 蜊雁､ｪ蟄励↓縺吶ｋ
  TextStyle get semiBold => copyWith(fontWeight: FontWeight.w600);

  /// 騾壼ｸｸ縺ｮ螟ｪ縺輔↓縺吶ｋ
  TextStyle get regular => copyWith(fontWeight: FontWeight.w400);

  /// 繧､繧ｿ繝ｪ繝・け菴薙↓縺吶ｋ
  TextStyle get italic => copyWith(fontStyle: FontStyle.italic);

  /// 荳狗ｷ壹ｒ霑ｽ蜉
  TextStyle get underline => copyWith(decoration: TextDecoration.underline);

  /// 蜿悶ｊ豸医＠邱壹ｒ霑ｽ蜉
  TextStyle get lineThrough => copyWith(decoration: TextDecoration.lineThrough);

  /// 濶ｲ繧貞､画峩
  TextStyle withColor(Color color) => copyWith(color: color);

  /// 荳埼乗・蠎ｦ繧貞､画峩
  TextStyle withOpacity(double opacity) =>
      copyWith(color: color?.withOpacity(opacity));

  /// 陦後・鬮倥＆繧貞､画峩
  TextStyle withHeight(double height) => copyWith(height: height);

  /// 譁・ｭ鈴俣髫斐ｒ螟画峩
  TextStyle withLetterSpacing(double spacing) =>
      copyWith(letterSpacing: spacing);
}

/// 繧ｿ繧､繝昴げ繝ｩ繝輔ぅ繧ｹ繧ｱ繝ｼ繝ｫ螳壽焚
class TypographyScale {
  const TypographyScale._();

  // 繝輔か繝ｳ繝医し繧､繧ｺ繧ｹ繧ｱ繝ｼ繝ｫ・・px繝吶・繧ｹ・・
  static const double xs = 11.0; // Extra Small
  static const double sm = 12.0; // Small
  static const double base = 14.0; // Base
  static const double md = 16.0; // Medium
  static const double lg = 18.0; // Large
  static const double xl = 20.0; // Extra Large
  static const double xxl = 24.0; // 2X Large
  static const double xxxl = 28.0; // 3X Large
  static const double xxxxl = 32.0; // 4X Large
  static const double xxxxxl = 40.0; // 5X Large
  static const double xxxxxxl = 48.0; // 6X Large

  // 繝輔か繝ｳ繝医え繧ｧ繧､繝・
  static const FontWeight thin = FontWeight.w100;
  static const FontWeight extraLight = FontWeight.w200;
  static const FontWeight light = FontWeight.w300;
  static const FontWeight regular = FontWeight.w400;
  static const FontWeight medium = FontWeight.w500;
  static const FontWeight semiBold = FontWeight.w600;
  static const FontWeight bold = FontWeight.w700;
  static const FontWeight extraBold = FontWeight.w800;
  static const FontWeight black = FontWeight.w900;

  // 陦後・鬮倥＆
  static const double tightHeight = 1.2;
  static const double normalHeight = 1.5;
  static const double relaxedHeight = 1.75;
  static const double looseHeight = 2.0;

  // 譁・ｭ鈴俣髫・
  static const double tightSpacing = -0.5;
  static const double normalSpacing = 0.0;
  static const double wideSpacing = 0.5;
  static const double extraWideSpacing = 1.0;
}

/// 繝ｬ繧ｹ繝昴Φ繧ｷ繝悶ち繧､繝昴げ繝ｩ繝輔ぅ
class ResponsiveTypography {
  const ResponsiveTypography._();

  /// 逕ｻ髱｢繧ｵ繧､繧ｺ縺ｫ蠢懊§縺溘ヵ繧ｩ繝ｳ繝医し繧､繧ｺ繧貞叙蠕・
  static double getResponsiveFontSize(
    BuildContext context,
    double baseSize,
  ) {
    final width = MediaQuery.of(context).size.width;

    if (width < 360) {
      // 蟆丞梛遶ｯ譛ｫ
      return baseSize * 0.9;
    } else if (width > 600) {
      // 繧ｿ繝悶Ξ繝・ヨ
      return baseSize * 1.1;
    }

    return baseSize;
  }

  /// 繝ｬ繧ｹ繝昴Φ繧ｷ繝蓬1
  static TextStyle h1(BuildContext context, {Color? color}) {
    final baseSize = getResponsiveFontSize(context, 40);
    return TypographySystem.h1(color: color).copyWith(fontSize: baseSize);
  }

  /// 繝ｬ繧ｹ繝昴Φ繧ｷ繝蓬2
  static TextStyle h2(BuildContext context, {Color? color}) {
    final baseSize = getResponsiveFontSize(context, 32);
    return TypographySystem.h2(color: color).copyWith(fontSize: baseSize);
  }

  /// 繝ｬ繧ｹ繝昴Φ繧ｷ繝蓬3
  static TextStyle h3(BuildContext context, {Color? color}) {
    final baseSize = getResponsiveFontSize(context, 28);
    return TypographySystem.h3(color: color).copyWith(fontSize: baseSize);
  }
}

/// Legacy typography shim mirroring the previous `AppTypography` API.
class AppTypography {
  const AppTypography._();

  static TextStyle get h1 => TypographySystem.h1();
  static TextStyle get h2 => TypographySystem.h2();
  static TextStyle get h3 => TypographySystem.h3();
  static TextStyle get h4 => TypographySystem.h4();
  static TextStyle get h5 => TypographySystem.h5();
  static TextStyle get h6 => TypographySystem.h6();

  static TextStyle get bodyLarge => TypographySystem.bodyLarge();
  static TextStyle get body => TypographySystem.bodyMedium();
  static TextStyle get bodyMedium => TypographySystem.bodyMedium();
  static TextStyle get bodySmall => TypographySystem.bodySmall();

  static TextStyle get caption => TypographySystem.caption();
  static TextStyle get overline => TypographySystem.overline();

  static TextStyle get buttonLarge => TypographySystem.buttonLarge();
  static TextStyle get buttonMedium => TypographySystem.buttonMedium();
  static TextStyle get buttonSmall => TypographySystem.buttonSmall();

  static TextStyle get monoLarge => TypographySystem.monoLarge();
  static TextStyle get monoMedium => TypographySystem.monoMedium();
  static TextStyle get monoSmall => TypographySystem.monoSmall();
}
