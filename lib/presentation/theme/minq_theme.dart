import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MinqTheme extends ThemeExtension<MinqTheme> {
  const MinqTheme({
    required this.brandPrimary,
    required this.background,
    required this.surface,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.accentSuccess,
    required this.border,
    required this.radiusSmall,
    required this.radiusMedium,
    required this.radiusLarge,
    required this.radiusXLarge,
    required this.spaceBase,
    required this.spaceSM,
    required this.spaceMD,
    required this.spaceLG,
    required this.spaceXL,
    required this.shadowSoft,
    required this.shadowStrong,
    required this.displayMedium,
    required this.displaySmall,
    required this.titleLarge,
    required this.titleMedium,
    required this.titleSmall,
    required this.bodyLarge,
    required this.bodyMedium,
    required this.bodySmall,
    required this.labelSmall,
  });

  final Color brandPrimary;
  final Color background;
  final Color surface;
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;
  final Color accentSuccess;
  final Color border;
  final double radiusSmall;
  final double radiusMedium;
  final double radiusLarge;
  final double radiusXLarge;
  final double spaceBase;
  final double spaceSM;
  final double spaceMD;
  final double spaceLG;
  final double spaceXL;
  final List<BoxShadow> shadowSoft;
  final List<BoxShadow> shadowStrong;
  final TextStyle displayMedium;
  final TextStyle displaySmall;
  final TextStyle titleLarge;
  final TextStyle titleMedium;
  final TextStyle titleSmall;
  final TextStyle bodyLarge;
  final TextStyle bodyMedium;
  final TextStyle bodySmall;
  final TextStyle labelSmall;

  double spacing(double units) => spaceBase * units;

  BorderRadius cornerSmall() => BorderRadius.circular(radiusSmall);
  BorderRadius cornerMedium() => BorderRadius.circular(radiusMedium);
  BorderRadius cornerLarge() => BorderRadius.circular(radiusLarge);
  BorderRadius cornerXLarge() => BorderRadius.circular(radiusXLarge);
  BorderRadius cornerFull() => BorderRadius.circular(999);

  static MinqTheme light() {
    const base = 4.0;
    return MinqTheme(
      brandPrimary: const Color(0xFF13B6EC),
      background: const Color(0xFFF6F8F8),
      surface: Colors.white,
      textPrimary: const Color(0xFF101D22),
      textSecondary: const Color(0xFF1F2933),
      textMuted: const Color(0xFF64748B),
      accentSuccess: const Color(0xFF10B981),
      border: const Color(0xFFE5E7EB),
      radiusSmall: 8,
      radiusMedium: 12,
      radiusLarge: 16,
      radiusXLarge: 28,
      spaceBase: base,
      spaceSM: base * 2,
      spaceMD: base * 3,
      spaceLG: base * 5,
      spaceXL: base * 6,
      shadowSoft: const [
        BoxShadow(
          color: Color(0x14000000),
          blurRadius: 18,
          offset: Offset(0, 8),
        ),
      ],
      shadowStrong: const [
        BoxShadow(
          color: Color(0x1A000000),
          blurRadius: 24,
          offset: Offset(0, 14),
        ),
      ],
      displayMedium: GoogleFonts.plusJakartaSans(
        fontSize: 42,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.5,
      ),
      displaySmall: GoogleFonts.plusJakartaSans(
        fontSize: 36,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.4,
      ),
      titleLarge: GoogleFonts.plusJakartaSans(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.2,
      ),
      titleMedium: GoogleFonts.plusJakartaSans(
        fontSize: 22,
        fontWeight: FontWeight.w600,
      ),
      titleSmall: GoogleFonts.plusJakartaSans(
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: GoogleFonts.plusJakartaSans(
        fontSize: 18,
        fontWeight: FontWeight.w500,
        height: 1.5,
      ),
      bodyMedium: GoogleFonts.plusJakartaSans(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        height: 1.4,
      ),
      bodySmall: GoogleFonts.plusJakartaSans(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        height: 1.4,
      ),
      labelSmall: GoogleFonts.plusJakartaSans(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.4,
      ),
    );
  }

  static MinqTheme dark() {
    const base = 4.0;
    return MinqTheme(
      brandPrimary: const Color(0xFF38CFFE),
      background: const Color(0xFF0F172A),
      surface: const Color(0xFF111C2E),
      textPrimary: Colors.white,
      textSecondary: const Color(0xFFCBD5F5),
      textMuted: const Color(0xFF94A3B8),
      accentSuccess: const Color(0xFF22D3A0),
      border: const Color(0xFF334155),
      radiusSmall: 8,
      radiusMedium: 12,
      radiusLarge: 16,
      radiusXLarge: 28,
      spaceBase: base,
      spaceSM: base * 2,
      spaceMD: base * 3,
      spaceLG: base * 5,
      spaceXL: base * 6,
      shadowSoft: const [
        BoxShadow(
          color: Color(0x33000000),
          blurRadius: 20,
          offset: Offset(0, 6),
        ),
      ],
      shadowStrong: const [
        BoxShadow(
          color: Color(0x3D000000),
          blurRadius: 28,
          offset: Offset(0, 16),
        ),
      ],
      displayMedium: GoogleFonts.plusJakartaSans(
        fontSize: 42,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.5,
      ),
      displaySmall: GoogleFonts.plusJakartaSans(
        fontSize: 36,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.4,
      ),
      titleLarge: GoogleFonts.plusJakartaSans(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.2,
      ),
      titleMedium: GoogleFonts.plusJakartaSans(
        fontSize: 22,
        fontWeight: FontWeight.w600,
      ),
      titleSmall: GoogleFonts.plusJakartaSans(
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: GoogleFonts.plusJakartaSans(
        fontSize: 18,
        fontWeight: FontWeight.w500,
        height: 1.5,
      ),
      bodyMedium: GoogleFonts.plusJakartaSans(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        height: 1.4,
      ),
      bodySmall: GoogleFonts.plusJakartaSans(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        height: 1.4,
      ),
      labelSmall: GoogleFonts.plusJakartaSans(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.4,
      ),
    );
  }

  @override
  MinqTheme copyWith({
    Color? brandPrimary,
    Color? background,
    Color? surface,
    Color? textPrimary,
    Color? textSecondary,
    Color? textMuted,
    Color? accentSuccess,
    Color? border,
    double? radiusSmall,
    double? radiusMedium,
    double? radiusLarge,
    double? radiusXLarge,
    double? spaceBase,
    double? spaceSM,
    double? spaceMD,
    double? spaceLG,
    double? spaceXL,
    List<BoxShadow>? shadowSoft,
    List<BoxShadow>? shadowStrong,
    TextStyle? displayMedium,
    TextStyle? displaySmall,
    TextStyle? titleLarge,
    TextStyle? titleMedium,
    TextStyle? titleSmall,
    TextStyle? bodyLarge,
    TextStyle? bodyMedium,
    TextStyle? bodySmall,
    TextStyle? labelSmall,
  }) {
    return MinqTheme(
      brandPrimary: brandPrimary ?? this.brandPrimary,
      background: background ?? this.background,
      surface: surface ?? this.surface,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textMuted: textMuted ?? this.textMuted,
      accentSuccess: accentSuccess ?? this.accentSuccess,
      border: border ?? this.border,
      radiusSmall: radiusSmall ?? this.radiusSmall,
      radiusMedium: radiusMedium ?? this.radiusMedium,
      radiusLarge: radiusLarge ?? this.radiusLarge,
      radiusXLarge: radiusXLarge ?? this.radiusXLarge,
      spaceBase: spaceBase ?? this.spaceBase,
      spaceSM: spaceSM ?? this.spaceSM,
      spaceMD: spaceMD ?? this.spaceMD,
      spaceLG: spaceLG ?? this.spaceLG,
      spaceXL: spaceXL ?? this.spaceXL,
      shadowSoft: shadowSoft ?? this.shadowSoft,
      shadowStrong: shadowStrong ?? this.shadowStrong,
      displayMedium: displayMedium ?? this.displayMedium,
      displaySmall: displaySmall ?? this.displaySmall,
      titleLarge: titleLarge ?? this.titleLarge,
      titleMedium: titleMedium ?? this.titleMedium,
      titleSmall: titleSmall ?? this.titleSmall,
      bodyLarge: bodyLarge ?? this.bodyLarge,
      bodyMedium: bodyMedium ?? this.bodyMedium,
      bodySmall: bodySmall ?? this.bodySmall,
      labelSmall: labelSmall ?? this.labelSmall,
    );
  }

  @override
  MinqTheme lerp(ThemeExtension<MinqTheme>? other, double t) {
    if (other is! MinqTheme) {
      return this;
    }

    return MinqTheme(
      brandPrimary:
          Color.lerp(brandPrimary, other.brandPrimary, t) ?? brandPrimary,
      background: Color.lerp(background, other.background, t) ?? background,
      surface: Color.lerp(surface, other.surface, t) ?? surface,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t) ?? textPrimary,
      textSecondary:
          Color.lerp(textSecondary, other.textSecondary, t) ?? textSecondary,
      textMuted: Color.lerp(textMuted, other.textMuted, t) ?? textMuted,
      accentSuccess:
          Color.lerp(accentSuccess, other.accentSuccess, t) ?? accentSuccess,
      border: Color.lerp(border, other.border, t) ?? border,
      radiusSmall: lerpDouble(radiusSmall, other.radiusSmall, t) ?? radiusSmall,
      radiusMedium:
          lerpDouble(radiusMedium, other.radiusMedium, t) ?? radiusMedium,
      radiusLarge: lerpDouble(radiusLarge, other.radiusLarge, t) ?? radiusLarge,
      radiusXLarge:
          lerpDouble(radiusXLarge, other.radiusXLarge, t) ?? radiusXLarge,
      spaceBase: lerpDouble(spaceBase, other.spaceBase, t) ?? spaceBase,
      spaceSM: lerpDouble(spaceSM, other.spaceSM, t) ?? spaceSM,
      spaceMD: lerpDouble(spaceMD, other.spaceMD, t) ?? spaceMD,
      spaceLG: lerpDouble(spaceLG, other.spaceLG, t) ?? spaceLG,
      spaceXL: lerpDouble(spaceXL, other.spaceXL, t) ?? spaceXL,
      shadowSoft: t < 0.5 ? shadowSoft : other.shadowSoft,
      shadowStrong: t < 0.5 ? shadowStrong : other.shadowStrong,
      displayMedium:
          TextStyle.lerp(displayMedium, other.displayMedium, t) ?? displayMedium,
      displaySmall:
          TextStyle.lerp(displaySmall, other.displaySmall, t) ?? displaySmall,
      titleLarge: TextStyle.lerp(titleLarge, other.titleLarge, t) ?? titleLarge,
      titleMedium:
          TextStyle.lerp(titleMedium, other.titleMedium, t) ?? titleMedium,
      titleSmall: TextStyle.lerp(titleSmall, other.titleSmall, t) ?? titleSmall,
      bodyLarge: TextStyle.lerp(bodyLarge, other.bodyLarge, t) ?? bodyLarge,
      bodyMedium: TextStyle.lerp(bodyMedium, other.bodyMedium, t) ?? bodyMedium,
      bodySmall: TextStyle.lerp(bodySmall, other.bodySmall, t) ?? bodySmall,
      labelSmall: TextStyle.lerp(labelSmall, other.labelSmall, t) ?? labelSmall,
    );
  }
}

extension MinqThemeGetter on BuildContext {
  MinqTheme get tokens =>
      Theme.of(this).extension<MinqTheme>() ?? MinqTheme.light();
}