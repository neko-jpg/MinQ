import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:minq/presentation/theme/color_tokens.dart';

class MinqRadius {
  const MinqRadius({
    required this.sm,
    required this.md,
    required this.lg,
    required this.xl,
  });
  final double sm;
  final double md;
  final double lg;
  final double xl;
}

class MinqSpacing {
  const MinqSpacing({
    required this.xxs,
    required this.xs,
    required this.sm,
    required this.md,
    required this.lg,
    required this.xl,
    required this.xxl,
  });
  final double xxs;
  final double xs;
  final double sm;
  final double md;
  final double lg;
  final double xl;
  final double xxl;
}

class MinqShadow {
  const MinqShadow({required this.soft, required this.strong});
  final List<BoxShadow> soft;
  final List<BoxShadow> strong;
}

class MinqTypography {
  const MinqTypography({
    required this.h1,
    required this.h2,
    required this.h3,
    required this.h4,
    required this.h5,
    required this.body,
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
  final TextStyle body;
  final TextStyle bodyLarge;
  final TextStyle bodyMedium;
  final TextStyle bodySmall;
  final TextStyle button;
  final TextStyle caption;
  
  // Additional computed properties
  TextStyle get titleMedium => h4;
}

class MinqTheme extends ThemeExtension<MinqTheme> {
  MinqTheme({
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
    required this.radius,
    required this.spacing,
    required this.shadow,
    required this.typography,
    // Animation curves
    required this.easeInOutCubic,
    required this.easeOutBack,
    required this.easeInOutQuart,
    required this.bounceOut,
  }) : tokens = MinqColorTokens(
         primary: brandPrimary,
         primaryHover: primaryHover,
         primaryContainer: surface,
         background: background,
         onBackground: textPrimary,
         surfaceContainer: surfaceAlt,
         surfaceContainerHigh: divider,
         onPrimary: primaryForeground,
         onPrimaryContainer: textPrimary,
         secondary: accentSecondary,
         secondaryContainer: surfaceAlt,
         onSecondary: secondaryForeground,
         onSecondaryContainer: textSecondary,
         tertiary: joyAccent,
         tertiaryContainer: surface,
         onTertiary: primaryForeground,
         onTertiaryContainer: textPrimary,
         error: accentError,
         errorContainer: surface,
         onError: primaryForeground,
         onErrorContainer: textPrimary,
         warning: accentWarning,
         warningContainer: surface,
         onWarning: primaryForeground,
         onWarningContainer: textPrimary,
         success: accentSuccess,
         successContainer: surface,
         onSuccess: primaryForeground,
         onSuccessContainer: textPrimary,
         surface: surface,
         onSurface: textPrimary,
         surfaceVariant: surfaceAlt,
         onSurfaceVariant: textSecondary,
         outline: border,
         outlineVariant: divider,
         shadow: const Color(0x1A000000),
         scrim: const Color(0x80000000),
         inverseSurface: textPrimary,
         onInverseSurface: surface,
         inversePrimary: surface,
       );

  final Brightness brightness;
  final MinqColorTokens tokens;
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

  final MinqRadius radius;
  final MinqSpacing spacing;
  final MinqShadow shadow;
  final MinqTypography typography;

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
      typography.body.copyWith(fontSize: 12, fontWeight: FontWeight.w500);

  // Additional color getters for backward compatibility
  Color get success => accentSuccess;
  Color get error => accentError;
  Color get warning => accentWarning;
  Color get info => accentSecondary;
  Color get brandSecondary => accentSecondary;

  BorderRadius cornerSmall() => BorderRadius.circular(radius.sm);
  BorderRadius cornerMedium() => BorderRadius.circular(radius.md);
  BorderRadius cornerLarge() => BorderRadius.circular(radius.lg);
  BorderRadius cornerXLarge() => BorderRadius.circular(radius.xl);
  BorderRadius cornerFull() => BorderRadius.circular(999);

  // Enhanced spacing helpers for emotional design
  EdgeInsets get breathingPadding => EdgeInsets.all(spacing.lg);
  EdgeInsets get intimatePadding => EdgeInsets.all(spacing.sm);
  EdgeInsets get respectfulPadding => EdgeInsets.all(spacing.md);
  EdgeInsets get dramaticPadding => EdgeInsets.all(spacing.xl);

  // Enhanced accessibility helpers
  bool isHighContrastMode(BuildContext context) {
    return MediaQuery.of(context).highContrast;
  }

  Color getAccessibleTextColor(BuildContext context) {
    return isHighContrastMode(context) ? highContrastText : textPrimary;
  }

  Color getAccessibleBackgroundColor(BuildContext context) {
    return isHighContrastMode(context) ? highContrastBackground : background;
  }

  /// Ensure minimum touch target size for accessibility (44pt)
  BoxConstraints get minTouchTargetConstraints => const BoxConstraints(
    minWidth: minTouchTargetSize,
    minHeight: minTouchTargetSize,
  );

  /// Get accessible button padding that ensures minimum touch target
  EdgeInsets getAccessibleButtonPadding({
    EdgeInsets? basePadding,
    required Size contentSize,
  }) {
    final base =
        basePadding ??
        EdgeInsets.symmetric(horizontal: spacing.md, vertical: spacing.sm);

    final totalWidth = contentSize.width + base.horizontal;
    final totalHeight = contentSize.height + base.vertical;

    final additionalHorizontal =
        (minTouchTargetSize - totalWidth).clamp(0.0, double.infinity) / 2;
    final additionalVertical =
        (minTouchTargetSize - totalHeight).clamp(0.0, double.infinity) / 2;

    return EdgeInsets.symmetric(
      horizontal: base.horizontal / 2 + additionalHorizontal,
      vertical: base.vertical / 2 + additionalVertical,
    );
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
    final muted = palette.textMuted;
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
      tapFeedback: palette.primary.withAlpha(31),
      hoverState: palette.primaryHover.withAlpha(20),
      // Error and warning colors
      accentError: palette.error,
      accentWarning: palette.warning,
      // Accessibility colors (WCAG AA compliant)
      highContrastText: palette.highContrastText,
      highContrastBackground: palette.highContrastBackground,
      highContrastPrimary: palette.highContrastPrimary,
      radius: const MinqRadius(sm: 8, md: 12, lg: 16, xl: 28),
      spacing: const MinqSpacing(
        xxs: base / 2,
        xs: base,
        sm: base * 2,
        md: base * 3,
        lg: base * 5,
        xl: base * 6,
        xxl: base * 8,
      ),
      shadow: MinqShadow(
        soft: [
          BoxShadow(
            color: palette.textPrimary.withAlpha(20),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
        strong: [
          BoxShadow(
            color: palette.textPrimary.withAlpha(31),
            blurRadius: 24,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      typography: MinqTypography(
        h1: GoogleFonts.plusJakartaSans(
          fontSize: 32,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.5,
        ),
        h2: GoogleFonts.plusJakartaSans(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
        ),
        h3: GoogleFonts.plusJakartaSans(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.2,
        ),
        h4: GoogleFonts.plusJakartaSans(
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
        h5: GoogleFonts.plusJakartaSans(
          fontSize: 16,
          fontWeight: FontWeight.w700,
        ),
        body: GoogleFonts.plusJakartaSans(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          height: 1.5,
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
          height: 1.5,
        ),
        button: GoogleFonts.plusJakartaSans(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
        caption: GoogleFonts.plusJakartaSans(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
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
    final muted = palette.textMuted;
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
      tapFeedback: palette.primary.withAlpha(56),
      hoverState: palette.primaryHover.withAlpha(41),
      // Error and warning colors
      accentError: palette.error,
      accentWarning: palette.warning,
      // Accessibility colors (WCAG AA compliant for dark theme)
      highContrastText: palette.highContrastText,
      highContrastBackground: palette.highContrastBackground,
      highContrastPrimary: palette.highContrastPrimary,
      radius: const MinqRadius(sm: 8, md: 12, lg: 16, xl: 28),
      spacing: const MinqSpacing(
        xxs: base / 2,
        xs: base,
        sm: base * 2,
        md: base * 3,
        lg: base * 5,
        xl: base * 6,
        xxl: base * 8,
      ),
      shadow: MinqShadow(
        soft: [
          BoxShadow(
            color: palette.onSurface.withAlpha(46),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
        strong: [
          BoxShadow(
            color: palette.onSurface.withAlpha(56),
            blurRadius: 28,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      typography: MinqTypography(
        h1: GoogleFonts.plusJakartaSans(
          fontSize: 32,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.5,
        ),
        h2: GoogleFonts.plusJakartaSans(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
        ),
        h3: GoogleFonts.plusJakartaSans(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.2,
        ),
        h4: GoogleFonts.plusJakartaSans(
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
        h5: GoogleFonts.plusJakartaSans(
          fontSize: 16,
          fontWeight: FontWeight.w700,
        ),
        body: GoogleFonts.plusJakartaSans(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          height: 1.5,
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
          height: 1.5,
        ),
        button: GoogleFonts.plusJakartaSans(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
        caption: GoogleFonts.plusJakartaSans(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
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
    MinqRadius? radius,
    MinqSpacing? spacing,
    MinqShadow? shadow,
    MinqTypography? typography,
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
      radius: radius ?? this.radius,
      spacing: spacing ?? this.spacing,
      shadow: shadow ?? this.shadow,
      typography: typography ?? this.typography,
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
      radius: t < 0.5 ? radius : other.radius,
      spacing: t < 0.5 ? spacing : other.spacing,
      shadow: t < 0.5 ? shadow : other.shadow,
      typography: t < 0.5 ? typography : other.typography,
      easeInOutCubic: t < 0.5 ? easeInOutCubic : other.easeInOutCubic,
      easeOutBack: t < 0.5 ? easeOutBack : other.easeOutBack,
      easeInOutQuart: t < 0.5 ? easeInOutQuart : other.easeInOutQuart,
      bounceOut: t < 0.5 ? bounceOut : other.bounceOut,
    );
  }
}

extension MinqThemeGetter on BuildContext {
  MinqTheme get tokens =>
      Theme.of(this).extension<MinqTheme>() ?? MinqTheme.light();
}
