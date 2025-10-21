import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:minq/presentation/theme/color_tokens.dart';

class MinqTheme extends ThemeExtension<MinqTheme> {
  const MinqTheme({
    required this.brightness,
    required this.brandPrimary,
    required this.primaryHover,
    required this.accentSecondary,
    required this.background,
    required this.surface,
    required this.surfaceAlt,
    required this.divider,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.accentSuccess,
    required this.border,
    required this.primaryForeground,
    required this.surfaceForeground,
    required this.secondaryForeground,
    // Emotional colors
    required this.joyAccent,
    required this.encouragement,
    required this.serenity,
    required this.warmth,
    // State colors
    required this.progressActive,
    required this.progressComplete,
    required this.progressPending,
    // Interaction colors
    required this.tapFeedback,
    required this.hoverState,
    // Error and warning colors
    required this.accentError,
    required this.accentWarning,
    // Accessibility colors
    required this.highContrastText,
    required this.highContrastBackground,
    required this.highContrastPrimary,
    required this.radiusSmall,
    required this.radiusMedium,
    required this.radiusLarge,
    required this.radiusXLarge,
    required this.spaceBase,
    required this.spaceSM,
    required this.spaceMD,
    required this.spaceLG,
    required this.spaceXL,
    // Enhanced spacing system
    required this.breathingSpace,
    required this.intimateSpace,
    required this.respectfulSpace,
    required this.dramaticSpace,
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
    // Emotional typography
    required this.celebrationText,
    required this.encouragementText,
    required this.guidanceText,
    required this.whisperText,
    // Animation curves
    required this.easeInOutCubic,
    required this.easeOutBack,
    required this.easeInOutQuart,
    required this.bounceOut,
  });

  final Brightness brightness;
  final Color brandPrimary;
  final Color primaryHover;
  final Color accentSecondary;
  final Color background;
  final Color surface;
  final Color surfaceAlt;
  final Color divider;
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;
  final Color accentSuccess;
  final Color border;
  final Color primaryForeground;
  final Color surfaceForeground;
  final Color secondaryForeground;

  // Emotional colors
  final Color joyAccent;
  final Color encouragement;
  final Color serenity;
  final Color warmth;

  // State colors
  final Color progressActive;
  final Color progressComplete;
  final Color progressPending;

  // Interaction colors
  final Color tapFeedback;
  final Color hoverState;

  // Error and warning colors
  final Color accentError;
  final Color accentWarning;

  // Accessibility colors
  final Color highContrastText;
  final Color highContrastBackground;
  final Color highContrastPrimary;

  final double radiusSmall;
  final double radiusMedium;
  final double radiusLarge;
  final double radiusXLarge;
  final double spaceBase;
  final double spaceSM;
  final double spaceMD;
  final double spaceLG;
  final double spaceXL;

  // Enhanced spacing system
  final double breathingSpace;
  final double intimateSpace;
  final double respectfulSpace;
  final double dramaticSpace;

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

  // Emotional typography
  final TextStyle celebrationText;
  final TextStyle encouragementText;
  final TextStyle guidanceText;
  final TextStyle whisperText;

  // Animation curves
  final Curve easeInOutCubic;
  final Curve easeOutBack;
  final Curve easeInOutQuart;
  final Curve bounceOut;

  // Additional computed properties
  Color get surfaceVariant =>
      brightness == Brightness.light
          ? Color.lerp(surface, background, 0.5) ?? surface
          : Color.lerp(surface, divider, 0.2) ?? surface;

  Color get onPrimary => primaryForeground;

  Color get onSecondary => secondaryForeground;

  Color get onSurface => surfaceForeground;

  TextStyle get labelMedium =>
      bodyMedium.copyWith(fontSize: 12, fontWeight: FontWeight.w500);

  double spacing(double units) => spaceBase * units;

  double radius(double units) => radiusSmall * units;

  BorderRadius cornerSmall() => BorderRadius.circular(radiusSmall);
  BorderRadius cornerMedium() => BorderRadius.circular(radiusMedium);
  BorderRadius cornerLarge() => BorderRadius.circular(radiusLarge);
  BorderRadius cornerXLarge() => BorderRadius.circular(radiusXLarge);
  BorderRadius cornerFull() => BorderRadius.circular(999);

  // Enhanced spacing helpers for emotional design
  EdgeInsets get breathingPadding => EdgeInsets.all(breathingSpace);
  EdgeInsets get intimatePadding => EdgeInsets.all(intimateSpace);
  EdgeInsets get respectfulPadding => EdgeInsets.all(respectfulSpace);
  EdgeInsets get dramaticPadding => EdgeInsets.all(dramaticSpace);

  // Accessibility helpers
  bool isHighContrastMode(BuildContext context) {
    return MediaQuery.of(context).highContrast;
  }

  Color getAccessibleTextColor(BuildContext context) {
    return isHighContrastMode(context) ? highContrastText : textPrimary;
  }

  Color getAccessibleBackgroundColor(BuildContext context) {
    return isHighContrastMode(context) ? highContrastBackground : background;
  }

  /// Returns a version of [base] that meets WCAG AA contrast on [background].
  /// If the original color is already accessible it is returned as-is.
  Color ensureAccessibleOnBackground(
    Color base,
    Color background, {
    double minContrast = 4.5,
  }) {
    if (meetsWCAGAA(base, background)) {
      return base;
    }

    final bool isBackgroundLight = background.computeLuminance() >= 0.5;
    final Color target = isBackgroundLight ? textPrimary : surfaceForeground;

    Color candidate = base;
    for (double step = 0.1; step <= 1.0; step += 0.1) {
      candidate = Color.lerp(base, target, step)!;
      if (meetsWCAGAA(candidate, background)) {
        return candidate;
      }
    }

    return target;
  }

  // Animation duration helpers based on accessibility settings
  Duration getAnimationDuration(BuildContext context, Duration baseDuration) {
    final reduceMotion = MediaQuery.of(context).disableAnimations;
    return reduceMotion ? Duration.zero : baseDuration;
  }

  // Minimum touch target size for accessibility (44pt iOS, 48dp Android)
  static const double minTouchTargetSize = 44.0;

  // Color contrast ratio checker (WCAG AA compliance)
  static double calculateContrastRatio(Color foreground, Color background) {
    final fgLuminance = foreground.computeLuminance();
    final bgLuminance = background.computeLuminance();
    final lighter = fgLuminance > bgLuminance ? fgLuminance : bgLuminance;
    final darker = fgLuminance > bgLuminance ? bgLuminance : fgLuminance;
    return (lighter + 0.05) / (darker + 0.05);
  }

  // Check if color combination meets WCAG AA standards
  bool meetsWCAGAA(Color foreground, Color background) {
    return calculateContrastRatio(foreground, background) >= 4.5;
  }

  // Check if color combination meets WCAG AAA standards
  bool meetsWCAGAAA(Color foreground, Color background) {
    return calculateContrastRatio(foreground, background) >= 7.0;
  }

  static MinqTheme of(BuildContext context) {
    return Theme.of(context).extension<MinqTheme>() ?? MinqTheme.light();
  }

  static MinqTheme light() {
    const base = 4.0;
    const palette = ColorTokens.light;
    final muted = Color.lerp(palette.textSecondary, palette.divider, 0.35)!;
    final pending = Color.lerp(palette.textSecondary, palette.divider, 0.45)!;
    final joyAccent = Color.lerp(palette.primary, palette.secondary, 0.35)!;
    final serenity = Color.lerp(palette.secondary, palette.primary, 0.15)!;
    final warmth = Color.lerp(palette.warning, palette.primary, 0.25)!;

    return MinqTheme(
      brightness: Brightness.light,
      brandPrimary: palette.primary,
      primaryHover: palette.primaryHover,
      accentSecondary: palette.secondary,
      background: palette.background,
      surface: palette.surface,
      surfaceAlt: palette.surfaceAlt,
      divider: palette.divider,
      textPrimary: palette.textPrimary,
      textSecondary: palette.textSecondary,
      textMuted: muted,
      accentSuccess: palette.success,
      border: palette.border,
      primaryForeground: palette.onPrimary,
      surfaceForeground: palette.onSurface,
      secondaryForeground: palette.onSecondary,

      // Emotional colors
      joyAccent: joyAccent,
      encouragement: palette.warning,
      serenity: serenity,
      warmth: warmth,
      // State colors
      progressActive: palette.primary,
      progressComplete: palette.success,
      progressPending: pending,
      // Interaction colors
      tapFeedback: palette.primary.withOpacity(0.12),
      hoverState: palette.primaryHover.withOpacity(0.08),
      // Error and warning colors
      accentError: palette.error,
      accentWarning: palette.warning,
      // Accessibility colors (WCAG AA compliant)
      highContrastText: palette.highContrastOnPrimary,
      highContrastBackground: palette.highContrastPrimary,
      highContrastPrimary: palette.highContrastPrimary,

      radiusSmall: 8,
      radiusMedium: 12,
      radiusLarge: 16,
      radiusXLarge: 28,
      spaceBase: base,
      spaceSM: base * 2,
      spaceMD: base * 3,
      spaceLG: base * 5,
      spaceXL: base * 6,

      // Enhanced spacing system for emotional design
      breathingSpace: base * 4, // 16px - comfortable breathing room
      intimateSpace: base * 1.5, // 6px - close, intimate spacing
      respectfulSpace: base * 8, // 32px - respectful distance between sections
      dramaticSpace: base * 12, // 48px - dramatic spacing for emphasis

      shadowSoft: [
        BoxShadow(
          color: palette.textPrimary.withOpacity(0.08),
          blurRadius: 18,
          offset: const Offset(0, 8),
        ),
      ],
      shadowStrong: [
        BoxShadow(
          color: palette.textPrimary.withOpacity(0.12),
          blurRadius: 24,
          offset: const Offset(0, 14),
        ),
      ],
      displayMedium: GoogleFonts.plusJakartaSans(
        fontSize: 32,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.5,
      ),
      displaySmall: GoogleFonts.plusJakartaSans(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.3,
      ),
      titleLarge: GoogleFonts.plusJakartaSans(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.2,
      ),
      titleMedium: GoogleFonts.plusJakartaSans(
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
      titleSmall: GoogleFonts.plusJakartaSans(
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: GoogleFonts.plusJakartaSans(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        height: 1.5,
      ),
      bodyMedium: GoogleFonts.plusJakartaSans(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        height: 1.5,
      ),
      bodySmall: GoogleFonts.plusJakartaSans(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        height: 1.4,
      ),
      labelSmall: GoogleFonts.plusJakartaSans(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      ),

      // Emotional typography styles
      celebrationText: GoogleFonts.plusJakartaSans(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        height: 1.3,
        color: joyAccent,
      ),
      encouragementText: GoogleFonts.plusJakartaSans(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        height: 1.4,
        color: palette.warning,
      ),
      guidanceText: GoogleFonts.plusJakartaSans(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        height: 1.5,
        color: serenity,
      ),
      whisperText: GoogleFonts.plusJakartaSans(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        height: 1.4,
        color: muted,
      ),

      // Animation curves for delightful interactions
      easeInOutCubic: Curves.easeInOutCubic,
      easeOutBack: Curves.easeOutBack,
      easeInOutQuart: Curves.easeInOutQuart,
      bounceOut: Curves.bounceOut,
    );
  }

  static MinqTheme dark() {
    const base = 4.0;
    const palette = ColorTokens.dark;
    final muted = Color.lerp(palette.textSecondary, palette.divider, 0.3)!;
    final pending = Color.lerp(palette.textSecondary, palette.divider, 0.45)!;
    final joyAccent = Color.lerp(palette.primary, palette.secondary, 0.25)!;
    final serenity = Color.lerp(palette.secondary, palette.surface, 0.2)!;
    final warmth = Color.lerp(palette.warning, palette.primary, 0.35)!;
    final encouragement =
        Color.lerp(palette.warning, palette.textPrimary, 0.35)!;

    return MinqTheme(
      brightness: Brightness.dark,
      brandPrimary: palette.primary,
      primaryHover: palette.primaryHover,
      accentSecondary: palette.secondary,
      background: palette.background,
      surface: palette.surface,
      surfaceAlt: palette.surfaceAlt,
      divider: palette.divider,
      textPrimary: palette.textPrimary,
      textSecondary: palette.textSecondary,
      textMuted: muted,
      accentSuccess: palette.success,
      border: palette.border,
      primaryForeground: palette.onPrimary,
      surfaceForeground: palette.onSurface,
      secondaryForeground: palette.onSecondary,

      // Emotional colors (adjusted for dark theme)
      joyAccent: joyAccent,
      encouragement: encouragement,
      serenity: serenity,
      warmth: warmth,
      // State colors
      progressActive: palette.primary,
      progressComplete: palette.success,
      progressPending: pending,
      // Interaction colors
      tapFeedback: palette.primary.withOpacity(0.22),
      hoverState: palette.primaryHover.withOpacity(0.16),
      // Error and warning colors
      accentError: palette.error,
      accentWarning: palette.warning,
      // Accessibility colors (WCAG AA compliant for dark theme)
      highContrastText: palette.highContrastOnPrimary,
      highContrastBackground: palette.highContrastPrimary,
      highContrastPrimary: palette.highContrastPrimary,

      radiusSmall: 8,
      radiusMedium: 12,
      radiusLarge: 16,
      radiusXLarge: 28,
      spaceBase: base,
      spaceSM: base * 2,
      spaceMD: base * 3,
      spaceLG: base * 5,
      spaceXL: base * 6,

      // Enhanced spacing system for emotional design
      breathingSpace: base * 4,
      intimateSpace: base * 1.5,
      respectfulSpace: base * 8,
      dramaticSpace: base * 12,

      shadowSoft: [
        BoxShadow(
          color: palette.onSurface.withOpacity(0.18),
          blurRadius: 20,
          offset: const Offset(0, 6),
        ),
      ],
      shadowStrong: [
        BoxShadow(
          color: palette.onSurface.withOpacity(0.22),
          blurRadius: 28,
          offset: const Offset(0, 16),
        ),
      ],
      displayMedium: GoogleFonts.plusJakartaSans(
        fontSize: 32,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.5,
      ),
      displaySmall: GoogleFonts.plusJakartaSans(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.3,
      ),
      titleLarge: GoogleFonts.plusJakartaSans(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.2,
      ),
      titleMedium: GoogleFonts.plusJakartaSans(
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
      titleSmall: GoogleFonts.plusJakartaSans(
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: GoogleFonts.plusJakartaSans(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        height: 1.5,
      ),
      bodyMedium: GoogleFonts.plusJakartaSans(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        height: 1.5,
      ),
      bodySmall: GoogleFonts.plusJakartaSans(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        height: 1.4,
      ),
      labelSmall: GoogleFonts.plusJakartaSans(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      ),

      // Emotional typography styles (adjusted for dark theme)
      celebrationText: GoogleFonts.plusJakartaSans(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        height: 1.3,
        color: joyAccent,
      ),
      encouragementText: GoogleFonts.plusJakartaSans(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        height: 1.4,
        color: encouragement,
      ),
      guidanceText: GoogleFonts.plusJakartaSans(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        height: 1.5,
        color: serenity,
      ),
      whisperText: GoogleFonts.plusJakartaSans(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        height: 1.4,
        color: muted,
      ),

      // Animation curves for delightful interactions
      easeInOutCubic: Curves.easeInOutCubic,
      easeOutBack: Curves.easeOutBack,
      easeInOutQuart: Curves.easeInOutQuart,
      bounceOut: Curves.bounceOut,
    );
  }

  @override
  MinqTheme copyWith({
    Brightness? brightness,
    Color? brandPrimary,
    Color? primaryHover,
    Color? accentSecondary,
    Color? background,
    Color? surface,
    Color? surfaceAlt,
    Color? divider,
    Color? textPrimary,
    Color? textSecondary,
    Color? textMuted,
    Color? accentSuccess,
    Color? border,
    Color? primaryForeground,
    Color? surfaceForeground,
    Color? secondaryForeground,
    Color? joyAccent,
    Color? encouragement,
    Color? serenity,
    Color? warmth,
    Color? progressActive,
    Color? progressComplete,
    Color? progressPending,
    Color? tapFeedback,
    Color? hoverState,
    Color? accentError,
    Color? accentWarning,
    Color? highContrastText,
    Color? highContrastBackground,
    Color? highContrastPrimary,
    double? radiusSmall,
    double? radiusMedium,
    double? radiusLarge,
    double? radiusXLarge,
    double? spaceBase,
    double? spaceSM,
    double? spaceMD,
    double? spaceLG,
    double? spaceXL,
    double? breathingSpace,
    double? intimateSpace,
    double? respectfulSpace,
    double? dramaticSpace,
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
    TextStyle? celebrationText,
    TextStyle? encouragementText,
    TextStyle? guidanceText,
    TextStyle? whisperText,
    Curve? easeInOutCubic,
    Curve? easeOutBack,
    Curve? easeInOutQuart,
    Curve? bounceOut,
  }) {
    return MinqTheme(
      brightness: brightness ?? this.brightness,
      brandPrimary: brandPrimary ?? this.brandPrimary,
      primaryHover: primaryHover ?? this.primaryHover,
      accentSecondary: accentSecondary ?? this.accentSecondary,
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surfaceAlt: surfaceAlt ?? this.surfaceAlt,
      divider: divider ?? this.divider,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textMuted: textMuted ?? this.textMuted,
      accentSuccess: accentSuccess ?? this.accentSuccess,
      border: border ?? this.border,
      primaryForeground: primaryForeground ?? this.primaryForeground,
      surfaceForeground: surfaceForeground ?? this.surfaceForeground,
      secondaryForeground: secondaryForeground ?? this.secondaryForeground,
      joyAccent: joyAccent ?? this.joyAccent,
      encouragement: encouragement ?? this.encouragement,
      serenity: serenity ?? this.serenity,
      warmth: warmth ?? this.warmth,
      progressActive: progressActive ?? this.progressActive,
      progressComplete: progressComplete ?? this.progressComplete,
      progressPending: progressPending ?? this.progressPending,
      tapFeedback: tapFeedback ?? this.tapFeedback,
      hoverState: hoverState ?? this.hoverState,
      accentError: accentError ?? this.accentError,
      accentWarning: accentWarning ?? this.accentWarning,
      highContrastText: highContrastText ?? this.highContrastText,
      highContrastBackground:
          highContrastBackground ?? this.highContrastBackground,
      highContrastPrimary: highContrastPrimary ?? this.highContrastPrimary,
      radiusSmall: radiusSmall ?? this.radiusSmall,
      radiusMedium: radiusMedium ?? this.radiusMedium,
      radiusLarge: radiusLarge ?? this.radiusLarge,
      radiusXLarge: radiusXLarge ?? this.radiusXLarge,
      spaceBase: spaceBase ?? this.spaceBase,
      spaceSM: spaceSM ?? this.spaceSM,
      spaceMD: spaceMD ?? this.spaceMD,
      spaceLG: spaceLG ?? this.spaceLG,
      spaceXL: spaceXL ?? this.spaceXL,
      breathingSpace: breathingSpace ?? this.breathingSpace,
      intimateSpace: intimateSpace ?? this.intimateSpace,
      respectfulSpace: respectfulSpace ?? this.respectfulSpace,
      dramaticSpace: dramaticSpace ?? this.dramaticSpace,
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
      celebrationText: celebrationText ?? this.celebrationText,
      encouragementText: encouragementText ?? this.encouragementText,
      guidanceText: guidanceText ?? this.guidanceText,
      whisperText: whisperText ?? this.whisperText,
      easeInOutCubic: easeInOutCubic ?? this.easeInOutCubic,
      easeOutBack: easeOutBack ?? this.easeOutBack,
      easeInOutQuart: easeInOutQuart ?? this.easeInOutQuart,
      bounceOut: bounceOut ?? this.bounceOut,
    );
  }

  @override
  MinqTheme lerp(ThemeExtension<MinqTheme>? other, double t) {
    if (other is! MinqTheme) {
      return this;
    }

    return MinqTheme(
      brightness: t < 0.5 ? brightness : other.brightness,
      brandPrimary:
          Color.lerp(brandPrimary, other.brandPrimary, t) ?? brandPrimary,
      primaryHover:
          Color.lerp(primaryHover, other.primaryHover, t) ?? primaryHover,
      accentSecondary:
          Color.lerp(accentSecondary, other.accentSecondary, t) ??
          accentSecondary,
      background: Color.lerp(background, other.background, t) ?? background,
      surface: Color.lerp(surface, other.surface, t) ?? surface,
      surfaceAlt: Color.lerp(surfaceAlt, other.surfaceAlt, t) ?? surfaceAlt,
      divider: Color.lerp(divider, other.divider, t) ?? divider,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t) ?? textPrimary,
      textSecondary:
          Color.lerp(textSecondary, other.textSecondary, t) ?? textSecondary,
      textMuted: Color.lerp(textMuted, other.textMuted, t) ?? textMuted,
      accentSuccess:
          Color.lerp(accentSuccess, other.accentSuccess, t) ?? accentSuccess,
      border: Color.lerp(border, other.border, t) ?? border,
      primaryForeground:
          Color.lerp(primaryForeground, other.primaryForeground, t) ??
          primaryForeground,
      surfaceForeground:
          Color.lerp(surfaceForeground, other.surfaceForeground, t) ??
          surfaceForeground,
      secondaryForeground:
          Color.lerp(secondaryForeground, other.secondaryForeground, t) ??
          secondaryForeground,
      joyAccent: Color.lerp(joyAccent, other.joyAccent, t) ?? joyAccent,
      encouragement:
          Color.lerp(encouragement, other.encouragement, t) ?? encouragement,
      serenity: Color.lerp(serenity, other.serenity, t) ?? serenity,
      warmth: Color.lerp(warmth, other.warmth, t) ?? warmth,
      progressActive:
          Color.lerp(progressActive, other.progressActive, t) ?? progressActive,
      progressComplete:
          Color.lerp(progressComplete, other.progressComplete, t) ??
          progressComplete,
      progressPending:
          Color.lerp(progressPending, other.progressPending, t) ??
          progressPending,
      tapFeedback: Color.lerp(tapFeedback, other.tapFeedback, t) ?? tapFeedback,
      hoverState: Color.lerp(hoverState, other.hoverState, t) ?? hoverState,
      accentError: Color.lerp(accentError, other.accentError, t) ?? accentError,
      accentWarning:
          Color.lerp(accentWarning, other.accentWarning, t) ?? accentWarning,
      highContrastText:
          Color.lerp(highContrastText, other.highContrastText, t) ??
          highContrastText,
      highContrastBackground:
          Color.lerp(highContrastBackground, other.highContrastBackground, t) ??
          highContrastBackground,
      highContrastPrimary:
          Color.lerp(highContrastPrimary, other.highContrastPrimary, t) ??
          highContrastPrimary,
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
      breathingSpace:
          lerpDouble(breathingSpace, other.breathingSpace, t) ?? breathingSpace,
      intimateSpace:
          lerpDouble(intimateSpace, other.intimateSpace, t) ?? intimateSpace,
      respectfulSpace:
          lerpDouble(respectfulSpace, other.respectfulSpace, t) ??
          respectfulSpace,
      dramaticSpace:
          lerpDouble(dramaticSpace, other.dramaticSpace, t) ?? dramaticSpace,
      shadowSoft: t < 0.5 ? shadowSoft : other.shadowSoft,
      shadowStrong: t < 0.5 ? shadowStrong : other.shadowStrong,
      displayMedium:
          TextStyle.lerp(displayMedium, other.displayMedium, t) ??
          displayMedium,
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
      celebrationText:
          TextStyle.lerp(celebrationText, other.celebrationText, t) ??
          celebrationText,
      encouragementText:
          TextStyle.lerp(encouragementText, other.encouragementText, t) ??
          encouragementText,
      guidanceText:
          TextStyle.lerp(guidanceText, other.guidanceText, t) ?? guidanceText,
      whisperText:
          TextStyle.lerp(whisperText, other.whisperText, t) ?? whisperText,
      easeInOutCubic: t < 0.5 ? easeInOutCubic : other.easeInOutCubic,
      easeOutBack: t < 0.5 ? easeOutBack : other.easeOutBack,
      easeInOutQuart: t < 0.5 ? easeInOutQuart : other.easeInOutQuart,
      bounceOut: t < 0.5 ? bounceOut : other.bounceOut,
    );
  }
}

class MinqTypeScale {
  const MinqTypeScale({
    required this.h1,
    required this.h2,
    required this.h3,
    required this.h4,
    required this.h5,
    required this.bodyLarge,
    required this.bodyMedium,
    required this.bodySmall,
    required this.button,
    required this.caption,
  });

  final TextStyle h1;
  final TextStyle h2;
  final TextStyle h3;
  final TextStyle h4;
  final TextStyle h5;
  final TextStyle bodyLarge;
  final TextStyle bodyMedium;
  final TextStyle bodySmall;
  final TextStyle button;
  final TextStyle caption;
}

extension MinqThemeTypography on MinqTheme {
  MinqTypeScale get typeScale => MinqTypeScale(
    h1: displayMedium,
    h2: displaySmall,
    h3: titleLarge,
    h4: titleMedium,
    h5: titleSmall,
    bodyLarge: bodyLarge,
    bodyMedium: bodyMedium,
    bodySmall: bodySmall,
    button: titleSmall.copyWith(letterSpacing: 0.2),
    caption: labelSmall,
  );
}

extension MinqThemeGetter on BuildContext {
  MinqTheme get tokens =>
      Theme.of(this).extension<MinqTheme>() ?? MinqTheme.light();
}
