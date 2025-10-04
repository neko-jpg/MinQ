import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// タイポグラフィシスチE��完�E定義
/// H1-H6、Body、Caption、Monoの階層を提侁E
class TypographySystem {
  const TypographySystem._();

  // ========================================
  // Display Styles (最大見�EぁE
  // ========================================

  /// H1 - 最大の見�Eし（ランチE��ングペ�Eジ、E��要な画面タイトル�E�E
  static TextStyle h1({Color? color}) => GoogleFonts.plusJakartaSans(
        fontSize: 40,
        fontWeight: FontWeight.w800,
        letterSpacing: -1.0,
        height: 1.2,
        color: color,
      );

  /// H2 - 大きな見�Eし（セクションタイトル�E�E
  static TextStyle h2({Color? color}) => GoogleFonts.plusJakartaSans(
        fontSize: 32,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.5,
        height: 1.25,
        color: color,
      );

  /// H3 - 中見�Eし（カードタイトル、画面サブタイトル�E�E
  static TextStyle h3({Color? color}) => GoogleFonts.plusJakartaSans(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.3,
        height: 1.3,
        color: color,
      );

  // ========================================
  // Title Styles (タイトル)
  // ========================================

  /// H4 - 小見�Eし（セクション冁E�Eタイトル�E�E
  static TextStyle h4({Color? color}) => GoogleFonts.plusJakartaSans(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.2,
        height: 1.35,
        color: color,
      );

  /// H5 - 最小見�Eし（リストアイチE��タイトル�E�E
  static TextStyle h5({Color? color}) => GoogleFonts.plusJakartaSans(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        height: 1.4,
        color: color,
      );

  /// H6 - 極小見�Eし（インラインタイトル�E�E
  static TextStyle h6({Color? color}) => GoogleFonts.plusJakartaSans(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        height: 1.5,
        color: color,
      );

  // ========================================
  // Body Styles (本斁E
  // ========================================

  /// Body Large - 大きな本斁E��重要な説明文�E�E
  static TextStyle bodyLarge({Color? color}) => GoogleFonts.plusJakartaSans(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        height: 1.5,
        letterSpacing: 0,
        color: color,
      );

  /// Body Medium - 標準本斁E��通常の説明文�E�E
  static TextStyle bodyMedium({Color? color}) => GoogleFonts.plusJakartaSans(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        height: 1.5,
        letterSpacing: 0,
        color: color,
      );

  /// Body Small - 小さな本斁E��補足説明！E
  static TextStyle bodySmall({Color? color}) => GoogleFonts.plusJakartaSans(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        height: 1.4,
        letterSpacing: 0,
        color: color,
      );

  // ========================================
  // Caption Styles (キャプション)
  // ========================================

  /// Caption - キャプション�E�画像説明、メタ惁E���E�E
  static TextStyle caption({Color? color}) => GoogleFonts.plusJakartaSans(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        height: 1.4,
        letterSpacing: 0.2,
        color: color,
      );

  /// Overline - オーバ�Eライン�E�ラベル、カチE��リ�E�E
  static TextStyle overline({Color? color}) => GoogleFonts.plusJakartaSans(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        height: 1.3,
        letterSpacing: 0.5,
        color: color,
      );

  // ========================================
  // Button Styles (ボタン)
  // ========================================

  /// Button Large - 大きなボタン
  static TextStyle buttonLarge({Color? color}) => GoogleFonts.plusJakartaSans(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.2,
        height: 1.2,
        color: color,
      );

  /// Button Medium - 標準�Eタン
  static TextStyle buttonMedium({Color? color}) => GoogleFonts.plusJakartaSans(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.2,
        height: 1.2,
        color: color,
      );

  /// Button Small - 小さなボタン
  static TextStyle buttonSmall({Color? color}) => GoogleFonts.plusJakartaSans(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.3,
        height: 1.2,
        color: color,
      );

  // ========================================
  // Monospace Styles (等幁E��ォンチE
  // ========================================

  /// Mono Large - 大きな等幁E��コード、数値�E�E
  static TextStyle monoLarge({Color? color}) => GoogleFonts.robotoMono(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        height: 1.5,
        letterSpacing: 0,
        color: color,
      );

  /// Mono Medium - 標準等幁E
  static TextStyle monoMedium({Color? color}) => GoogleFonts.robotoMono(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        height: 1.5,
        letterSpacing: 0,
        color: color,
      );

  /// Mono Small - 小さな等幁E
  static TextStyle monoSmall({Color? color}) => GoogleFonts.robotoMono(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        height: 1.4,
        letterSpacing: 0,
        color: color,
      );

  // ========================================
  // Emotional Styles (感情皁E��スタイル)
  // ========================================

  /// Celebration - 祝福テキスチE
  static TextStyle celebration({Color? color}) => GoogleFonts.plusJakartaSans(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        height: 1.3,
        letterSpacing: -0.2,
        color: color ?? const Color(0xFFFFD700),
      );

  /// Encouragement - 励ましテキスチE
  static TextStyle encouragement({Color? color}) => GoogleFonts.plusJakartaSans(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        height: 1.4,
        letterSpacing: 0,
        color: color ?? const Color(0xFFFF6B6B),
      );

  /// Guidance - ガイダンスチE��スチE
  static TextStyle guidance({Color? color}) => GoogleFonts.plusJakartaSans(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        height: 1.5,
        letterSpacing: 0,
        color: color ?? const Color(0xFF4ECDC4),
      );

  /// Whisper - ささめE��チE��スト（控えめなヒント！E
  static TextStyle whisper({Color? color}) => GoogleFonts.plusJakartaSans(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        height: 1.4,
        letterSpacing: 0.1,
        color: color ?? const Color(0xFF94A3B8),
      );

  // ========================================
  // Numeric Styles (数値表示)
  // ========================================

  /// Numeric Large - 大きな数値�E�統計、カウンター�E�E
  static TextStyle numericLarge({Color? color}) => GoogleFonts.plusJakartaSans(
        fontSize: 48,
        fontWeight: FontWeight.w800,
        height: 1.1,
        letterSpacing: -1.0,
        fontFeatures: [const FontFeature.tabularFigures()],
        color: color,
      );

  /// Numeric Medium - 標準数値
  static TextStyle numericMedium({Color? color}) => GoogleFonts.plusJakartaSans(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        height: 1.2,
        letterSpacing: -0.5,
        fontFeatures: [const FontFeature.tabularFigures()],
        color: color,
      );

  /// Numeric Small - 小さな数値
  static TextStyle numericSmall({Color? color}) => GoogleFonts.plusJakartaSans(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        height: 1.3,
        letterSpacing: 0,
        fontFeatures: [const FontFeature.tabularFigures()],
        color: color,
      );
}

/// タイポグラフィヘルパ�E拡張
extension TypographyExtension on TextStyle {
  /// 太字にする
  TextStyle get bold => copyWith(fontWeight: FontWeight.w700);

  /// 半太字にする
  TextStyle get semiBold => copyWith(fontWeight: FontWeight.w600);

  /// 通常の太さにする
  TextStyle get regular => copyWith(fontWeight: FontWeight.w400);

  /// イタリチE��体にする
  TextStyle get italic => copyWith(fontStyle: FontStyle.italic);

  /// 下線を追加
  TextStyle get underline => copyWith(decoration: TextDecoration.underline);

  /// 取り消し線を追加
  TextStyle get lineThrough => copyWith(decoration: TextDecoration.lineThrough);

  /// 色を変更
  TextStyle withColor(Color color) => copyWith(color: color);

  /// 不透�E度を変更
  TextStyle withOpacity(double opacity) =>
      copyWith(color: color?.withOpacity(opacity));

  /// 行�E高さを変更
  TextStyle withHeight(double height) => copyWith(height: height);

  /// 斁E��間隔を変更
  TextStyle withLetterSpacing(double spacing) =>
      copyWith(letterSpacing: spacing);
}

/// タイポグラフィスケール定数
class TypographyScale {
  const TypographyScale._();

  // フォントサイズスケール�E�Epxベ�Eス�E�E
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

  // フォントウェイチE
  static const FontWeight thin = FontWeight.w100;
  static const FontWeight extraLight = FontWeight.w200;
  static const FontWeight light = FontWeight.w300;
  static const FontWeight regular = FontWeight.w400;
  static const FontWeight medium = FontWeight.w500;
  static const FontWeight semiBold = FontWeight.w600;
  static const FontWeight bold = FontWeight.w700;
  static const FontWeight extraBold = FontWeight.w800;
  static const FontWeight black = FontWeight.w900;

  // 行�E高さ
  static const double tightHeight = 1.2;
  static const double normalHeight = 1.5;
  static const double relaxedHeight = 1.75;
  static const double looseHeight = 2.0;

  // 斁E��間隁E
  static const double tightSpacing = -0.5;
  static const double normalSpacing = 0.0;
  static const double wideSpacing = 0.5;
  static const double extraWideSpacing = 1.0;
}

/// レスポンシブタイポグラフィ
class ResponsiveTypography {
  const ResponsiveTypography._();

  /// 画面サイズに応じたフォントサイズを取征E
  static double getResponsiveFontSize(
    BuildContext context,
    double baseSize,
  ) {
    final width = MediaQuery.of(context).size.width;

    if (width < 360) {
      // 小型端末
      return baseSize * 0.9;
    } else if (width > 600) {
      // タブレチE��
      return baseSize * 1.1;
    }

    return baseSize;
  }

  /// レスポンシブH1
  static TextStyle h1(BuildContext context, {Color? color}) {
    final baseSize = getResponsiveFontSize(context, 40);
    return TypographySystem.h1(color: color).copyWith(fontSize: baseSize);
  }

  /// レスポンシブH2
  static TextStyle h2(BuildContext context, {Color? color}) {
    final baseSize = getResponsiveFontSize(context, 32);
    return TypographySystem.h2(color: color).copyWith(fontSize: baseSize);
  }

  /// レスポンシブH3
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
