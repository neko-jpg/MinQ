import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MinqTheme extends ThemeExtension<MinqTheme> {
  const MinqTheme({
    required this.brightness,
    required this.brandPrimary,
    required this.background,
    required this.surface,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.accentSuccess,
    required this.border,
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
  final Color background;
  final Color surface;
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;
  final Color accentSuccess;
  final Color border;

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
  Color get surfaceVariant => brightness == Brightness.light
      ? surface.withValues(alpha: 0.8)
      : Color.lerp(surface, Colors.white, 0.05)!;
  
  Color get onPrimary => brightness == Brightness.light
      ? Colors.white
      : Colors.black;
  
  TextStyle get labelMedium => bodyMedium.copyWith(
    fontSize: 12,
    fontWeight: FontWeight.w500,
  );

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
    final Color target = isBackgroundLight ? Colors.black : Colors.white;

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
    return MinqTheme(
      brightness: Brightness.light,
      brandPrimary: const Color(0xFF37CBFA),
      background: const Color(0xFFF6F8F8),
      surface: Colors.white,
      textPrimary: const Color(0xFF101D22),
      textSecondary: const Color(0xFF1F2933),
      textMuted: const Color(0xFF64748B),
      accentSuccess: const Color(0xFF10B981),
      border: const Color(0xFFE5E7EB),

      // Emotional colors
      joyAccent: const Color(0xFFFFD700), // Golden joy
      encouragement: const Color(0xFFFF6B6B), // Warm encouragement
      serenity: const Color(0xFF4ECDC4), // Calming serenity
      warmth: const Color(0xFFFFA726), // Warm orange
      // State colors
      progressActive: const Color(0xFF13B6EC), // Active blue
      progressComplete: const Color(0xFF10B981), // Success green
      progressPending: const Color(0xFF94A3B8), // Muted gray
      // Interaction colors
      tapFeedback: const Color(0xFFE3F2FD), // Light blue feedback
      hoverState: const Color(0xFFF5F5F5), // Light gray hover
      // Error and warning colors
      accentError: const Color(0xFFEF4444), // Clear red for errors
      accentWarning: const Color(0xFFF59E0B), // Amber for warnings
      // Accessibility colors (WCAG AA compliant)
      highContrastText: const Color(0xFF000000), // Pure black for high contrast
      highContrastBackground: const Color(0xFFFFFFFF), // Pure white background

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
        color: const Color(0xFFFFD700), // Joy accent color
      ),
      encouragementText: GoogleFonts.plusJakartaSans(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        height: 1.4,
        color: const Color(0xFFFF6B6B), // Encouragement color
      ),
      guidanceText: GoogleFonts.plusJakartaSans(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        height: 1.5,
        color: const Color(0xFF4ECDC4), // Serenity color
      ),
      whisperText: GoogleFonts.plusJakartaSans(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        height: 1.4,
        color: const Color(0xFF94A3B8), // Muted color for subtle hints
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
    return MinqTheme(
      brightness: Brightness.dark,
      brandPrimary: const Color(0xFF37CBFA),
      background: const Color(0xFF0F172A),
      surface: const Color(0xFF3D444D), // RGB(61,68,77)
      textPrimary: Colors.white,
      textSecondary: const Color(0xFFCBD5F5),
      textMuted: const Color(0xFF94A3B8),
      accentSuccess: const Color(0xFF22D3A0),
      border: const Color(0xFF334155),

      // Emotional colors (adjusted for dark theme)
      joyAccent: const Color(0xFFFFC107), // Slightly muted gold for dark theme
      encouragement: const Color(0xFFFF8A80), // Softer red for dark theme
      serenity: const Color(0xFF80CBC4), // Muted teal for dark theme
      warmth: const Color(0xFFFFB74D), // Warm orange for dark theme
      // State colors
      progressActive: const Color(0xFF38CFFE), // Brand primary
      progressComplete: const Color(0xFF22D3A0), // Success green
      progressPending: const Color(0xFF64748B), // Darker muted gray
      // Interaction colors
      tapFeedback: const Color(0xFF1E293B), // Dark blue feedback
      hoverState: const Color(0xFF1F2937), // Dark gray hover
      // Error and warning colors
      accentError: const Color(0xFFFF5252), // Bright red for dark theme
      accentWarning: const Color(0xFFFFB74D), // Amber for warnings
      // Accessibility colors (WCAG AA compliant for dark theme)
      highContrastText: const Color(0xFFFFFFFF), // Pure white for high contrast
      highContrastBackground: const Color(0xFF000000), // Pure black background

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
        color: const Color(0xFFFFC107), // Joy accent color
      ),
      encouragementText: GoogleFonts.plusJakartaSans(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        height: 1.4,
        color: const Color(0xFFFF8A80), // Encouragement color
      ),
      guidanceText: GoogleFonts.plusJakartaSans(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        height: 1.5,
        color: const Color(0xFF80CBC4), // Serenity color
      ),
      whisperText: GoogleFonts.plusJakartaSans(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        height: 1.4,
        color: const Color(0xFF64748B), // Muted color for subtle hints
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
    Color? background,
    Color? surface,
    Color? textPrimary,
    Color? textSecondary,
    Color? textMuted,
    Color? accentSuccess,
    Color? border,
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
      background: background ?? this.background,
      surface: surface ?? this.surface,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textMuted: textMuted ?? this.textMuted,
      accentSuccess: accentSuccess ?? this.accentSuccess,
      border: border ?? this.border,
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
      background: Color.lerp(background, other.background, t) ?? background,
      surface: Color.lerp(surface, other.surface, t) ?? surface,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t) ?? textPrimary,
      textSecondary:
          Color.lerp(textSecondary, other.textSecondary, t) ?? textSecondary,
      textMuted: Color.lerp(textMuted, other.textMuted, t) ?? textMuted,
      accentSuccess:
          Color.lerp(accentSuccess, other.accentSuccess, t) ?? accentSuccess,
      border: Color.lerp(border, other.border, t) ?? border,
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
  
  // Additional typography access
  MinqTypeScale get typography => typeScale;
}

extension MinqThemeColors on MinqTheme {
  // Color shortcuts
  Color get primary => brandPrimary;
  Color get success => accentSuccess;
  Color get error => accentError;
}

extension MinqThemeSpacing on MinqTheme {
  // Spacing shortcuts
  double get xs => spaceSM / 2; // 8
  double get sm => spaceSM; // 8
  double get md => spaceMD; // 12
  double get lg => spaceLG; // 20
  double get xl => spaceXL; // 24
  double get xxs => spaceBase; // 4
  double get full => double.infinity;
}

extension MinqThemeGetter on BuildContext {
  MinqTheme get tokens =>
      Theme.of(this).extension<MinqTheme>() ?? MinqTheme.light();
}
