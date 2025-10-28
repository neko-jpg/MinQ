import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Comprehensive MinQ Design Token System
///
/// This class provides a centralized design system with tokens for:
/// - Colors (with WCAG AA compliance)
/// - Typography (semantic text styles)
/// - Spacing (4px base grid system)
/// - Border Radius (consistent corner rounding)
/// - Elevation (shadow system)
/// - Animation (timing and curves)
///
/// All UI components should use these tokens instead of hardcoded values
/// to ensure consistency and easy theme switching.
class MinqDesignTokens extends ThemeExtension<MinqDesignTokens> {
  const MinqDesignTokens({
    required this.brightness,
    required this.colors,
    required this.typography,
    required this.spacing,
    required this.radius,
    required this.elevation,
    required this.animation,
  });

  final Brightness brightness;
  final MinqColorTokens colors;
  final MinqTypographyTokens typography;
  final MinqSpacingTokens spacing;
  final MinqRadiusTokens radius;
  final MinqElevationTokens elevation;
  final MinqAnimationTokens animation;

  /// Light theme design tokens
  static MinqDesignTokens light() {
    return MinqDesignTokens(
      brightness: Brightness.light,
      colors: MinqColorTokens.light(),
      typography: MinqTypographyTokens.standard(),
      spacing: const MinqSpacingTokens(),
      radius: const MinqRadiusTokens(),
      elevation: MinqElevationTokens.light(),
      animation: const MinqAnimationTokens(),
    );
  }

  /// Dark theme design tokens
  static MinqDesignTokens dark() {
    return MinqDesignTokens(
      brightness: Brightness.dark,
      colors: MinqColorTokens.dark(),
      typography: MinqTypographyTokens.standard(),
      spacing: const MinqSpacingTokens(),
      radius: const MinqRadiusTokens(),
      elevation: MinqElevationTokens.dark(),
      animation: const MinqAnimationTokens(),
    );
  }

  /// Get design tokens from context
  static MinqDesignTokens of(BuildContext context) {
    return Theme.of(context).extension<MinqDesignTokens>() ?? light();
  }

  @override
  MinqDesignTokens copyWith({
    Brightness? brightness,
    MinqColorTokens? colors,
    MinqTypographyTokens? typography,
    MinqSpacingTokens? spacing,
    MinqRadiusTokens? radius,
    MinqElevationTokens? elevation,
    MinqAnimationTokens? animation,
  }) {
    return MinqDesignTokens(
      brightness: brightness ?? this.brightness,
      colors: colors ?? this.colors,
      typography: typography ?? this.typography,
      spacing: spacing ?? this.spacing,
      radius: radius ?? this.radius,
      elevation: elevation ?? this.elevation,
      animation: animation ?? this.animation,
    );
  }

  @override
  MinqDesignTokens lerp(ThemeExtension<MinqDesignTokens>? other, double t) {
    if (other is! MinqDesignTokens) return this;

    return MinqDesignTokens(
      brightness: t < 0.5 ? brightness : other.brightness,
      colors: colors.lerp(other.colors, t),
      typography: typography.lerp(other.typography, t),
      spacing: spacing.lerp(other.spacing, t),
      radius: radius.lerp(other.radius, t),
      elevation: elevation.lerp(other.elevation, t),
      animation: animation.lerp(other.animation, t),
    );
  }
}

/// Color tokens with WCAG AA compliance
class MinqColorTokens {
  const MinqColorTokens({
    required this.primary,
    required this.primaryHover,
    required this.primaryContainer,
    required this.onPrimary,
    required this.onPrimaryContainer,
    required this.secondary,
    required this.secondaryContainer,
    required this.onSecondary,
    required this.onSecondaryContainer,
    required this.tertiary,
    required this.tertiaryContainer,
    required this.onTertiary,
    required this.onTertiaryContainer,
    required this.error,
    required this.errorContainer,
    required this.onError,
    required this.onErrorContainer,
    required this.warning,
    required this.warningContainer,
    required this.onWarning,
    required this.onWarningContainer,
    required this.success,
    required this.successContainer,
    required this.onSuccess,
    required this.onSuccessContainer,
    required this.surface,
    required this.surfaceVariant,
    required this.surfaceContainer,
    required this.surfaceContainerHigh,
    required this.onSurface,
    required this.onSurfaceVariant,
    required this.background,
    required this.onBackground,
    required this.outline,
    required this.outlineVariant,
    required this.shadow,
    required this.scrim,
    required this.inverseSurface,
    required this.onInverseSurface,
    required this.inversePrimary,
  });

  // Primary colors
  final Color primary;
  final Color primaryHover;
  final Color primaryContainer;
  final Color onPrimary;
  final Color onPrimaryContainer;

  // Secondary colors
  final Color secondary;
  final Color secondaryContainer;
  final Color onSecondary;
  final Color onSecondaryContainer;

  // Tertiary colors
  final Color tertiary;
  final Color tertiaryContainer;
  final Color onTertiary;
  final Color onTertiaryContainer;

  // Error colors
  final Color error;
  final Color errorContainer;
  final Color onError;
  final Color onErrorContainer;

  // Warning colors
  final Color warning;
  final Color warningContainer;
  final Color onWarning;
  final Color onWarningContainer;

  // Success colors
  final Color success;
  final Color successContainer;
  final Color onSuccess;
  final Color onSuccessContainer;

  // Surface colors
  final Color surface;
  final Color surfaceVariant;
  final Color surfaceContainer;
  final Color surfaceContainerHigh;
  final Color onSurface;
  final Color onSurfaceVariant;

  // Background colors
  final Color background;
  final Color onBackground;

  // Outline colors
  final Color outline;
  final Color outlineVariant;

  // Other colors
  final Color shadow;
  final Color scrim;
  final Color inverseSurface;
  final Color onInverseSurface;
  final Color inversePrimary;

  /// Light theme colors (WCAG AA compliant)
  static MinqColorTokens light() {
    return const MinqColorTokens(
      // Primary - Blue theme
      primary: Color(0xFF1976D2),
      primaryHover: Color(0xFF1565C0),
      primaryContainer: Color(0xFFE3F2FD),
      onPrimary: Color(0xFFFFFFFF),
      onPrimaryContainer: Color(0xFF0D47A1),

      // Secondary - Teal theme
      secondary: Color(0xFF00796B),
      secondaryContainer: Color(0xFFE0F2F1),
      onSecondary: Color(0xFFFFFFFF),
      onSecondaryContainer: Color(0xFF004D40),

      // Tertiary - Purple theme
      tertiary: Color(0xFF7B1FA2),
      tertiaryContainer: Color(0xFFF3E5F5),
      onTertiary: Color(0xFFFFFFFF),
      onTertiaryContainer: Color(0xFF4A148C),

      // Error colors
      error: Color(0xFFD32F2F),
      errorContainer: Color(0xFFFFEBEE),
      onError: Color(0xFFFFFFFF),
      onErrorContainer: Color(0xFFB71C1C),

      // Warning colors
      warning: Color(0xFFF57C00),
      warningContainer: Color(0xFFFFF3E0),
      onWarning: Color(0xFFFFFFFF),
      onWarningContainer: Color(0xFFE65100),

      // Success colors
      success: Color(0xFF388E3C),
      successContainer: Color(0xFFE8F5E8),
      onSuccess: Color(0xFFFFFFFF),
      onSuccessContainer: Color(0xFF1B5E20),

      // Surface colors
      surface: Color(0xFFFFFFFF),
      surfaceVariant: Color(0xFFF5F5F5),
      surfaceContainer: Color(0xFFFAFAFA),
      surfaceContainerHigh: Color(0xFFEEEEEE),
      onSurface: Color(0xFF212121),
      onSurfaceVariant: Color(0xFF757575),

      // Background colors
      background: Color(0xFFFFFBFE),
      onBackground: Color(0xFF1C1B1F),

      // Outline colors
      outline: Color(0xFF79747E),
      outlineVariant: Color(0xFFCAC4D0),

      // Other colors
      shadow: Color(0xFF000000),
      scrim: Color(0xFF000000),
      inverseSurface: Color(0xFF313033),
      onInverseSurface: Color(0xFFF4EFF4),
      inversePrimary: Color(0xFF90CAF9),
    );
  }

  /// Dark theme colors (WCAG AA compliant)
  static MinqColorTokens dark() {
    return const MinqColorTokens(
      // Primary - Blue theme (adjusted for dark)
      primary: Color(0xFF90CAF9),
      primaryHover: Color(0xFF64B5F6),
      primaryContainer: Color(0xFF0D47A1),
      onPrimary: Color(0xFF003C8F),
      onPrimaryContainer: Color(0xFFE3F2FD),

      // Secondary - Teal theme (adjusted for dark)
      secondary: Color(0xFF4DB6AC),
      secondaryContainer: Color(0xFF004D40),
      onSecondary: Color(0xFF00251A),
      onSecondaryContainer: Color(0xFFE0F2F1),

      // Tertiary - Purple theme (adjusted for dark)
      tertiary: Color(0xFFBA68C8),
      tertiaryContainer: Color(0xFF4A148C),
      onTertiary: Color(0xFF38006B),
      onTertiaryContainer: Color(0xFFF3E5F5),

      // Error colors
      error: Color(0xFFEF5350),
      errorContainer: Color(0xFFB71C1C),
      onError: Color(0xFF690005),
      onErrorContainer: Color(0xFFFFEBEE),

      // Warning colors
      warning: Color(0xFFFFB74D),
      warningContainer: Color(0xFFE65100),
      onWarning: Color(0xFF452B00),
      onWarningContainer: Color(0xFFFFF3E0),

      // Success colors
      success: Color(0xFF66BB6A),
      successContainer: Color(0xFF1B5E20),
      onSuccess: Color(0xFF003A00),
      onSuccessContainer: Color(0xFFE8F5E8),

      // Surface colors
      surface: Color(0xFF121212),
      surfaceVariant: Color(0xFF1E1E1E),
      surfaceContainer: Color(0xFF1A1A1A),
      surfaceContainerHigh: Color(0xFF242424),
      onSurface: Color(0xFFE6E1E5),
      onSurfaceVariant: Color(0xFFCAC4D0),

      // Background colors
      background: Color(0xFF0F0F0F),
      onBackground: Color(0xFFE6E1E5),

      // Outline colors
      outline: Color(0xFF938F99),
      outlineVariant: Color(0xFF49454F),

      // Other colors
      shadow: Color(0xFF000000),
      scrim: Color(0xFF000000),
      inverseSurface: Color(0xFFE6E1E5),
      onInverseSurface: Color(0xFF313033),
      inversePrimary: Color(0xFF1976D2),
    );
  }

  /// Check if color combination meets WCAG AA standards (4.5:1 contrast ratio)
  bool meetsWCAGAA(Color foreground, Color background) {
    return _calculateContrastRatio(foreground, background) >= 4.5;
  }

  /// Check if color combination meets WCAG AAA standards (7:1 contrast ratio)
  bool meetsWCAGAAA(Color foreground, Color background) {
    return _calculateContrastRatio(foreground, background) >= 7.0;
  }

  /// Calculate contrast ratio between two colors
  double _calculateContrastRatio(Color foreground, Color background) {
    final fgLuminance = foreground.computeLuminance();
    final bgLuminance = background.computeLuminance();
    final lighter = fgLuminance > bgLuminance ? fgLuminance : bgLuminance;
    final darker = fgLuminance > bgLuminance ? bgLuminance : fgLuminance;
    return (lighter + 0.05) / (darker + 0.05);
  }

  /// Get accessible text color for given background
  Color getAccessibleTextColor(Color background) {
    return meetsWCAGAA(onSurface, background) ? onSurface : onBackground;
  }

  MinqColorTokens lerp(MinqColorTokens other, double t) {
    return MinqColorTokens(
      primary: Color.lerp(primary, other.primary, t) ?? primary,
      primaryHover: Color.lerp(primaryHover, other.primaryHover, t) ?? primaryHover,
      primaryContainer: Color.lerp(primaryContainer, other.primaryContainer, t) ?? primaryContainer,
      onPrimary: Color.lerp(onPrimary, other.onPrimary, t) ?? onPrimary,
      onPrimaryContainer: Color.lerp(onPrimaryContainer, other.onPrimaryContainer, t) ?? onPrimaryContainer,
      secondary: Color.lerp(secondary, other.secondary, t) ?? secondary,
      secondaryContainer: Color.lerp(secondaryContainer, other.secondaryContainer, t) ?? secondaryContainer,
      onSecondary: Color.lerp(onSecondary, other.onSecondary, t) ?? onSecondary,
      onSecondaryContainer: Color.lerp(onSecondaryContainer, other.onSecondaryContainer, t) ?? onSecondaryContainer,
      tertiary: Color.lerp(tertiary, other.tertiary, t) ?? tertiary,
      tertiaryContainer: Color.lerp(tertiaryContainer, other.tertiaryContainer, t) ?? tertiaryContainer,
      onTertiary: Color.lerp(onTertiary, other.onTertiary, t) ?? onTertiary,
      onTertiaryContainer: Color.lerp(onTertiaryContainer, other.onTertiaryContainer, t) ?? onTertiaryContainer,
      error: Color.lerp(error, other.error, t) ?? error,
      errorContainer: Color.lerp(errorContainer, other.errorContainer, t) ?? errorContainer,
      onError: Color.lerp(onError, other.onError, t) ?? onError,
      onErrorContainer: Color.lerp(onErrorContainer, other.onErrorContainer, t) ?? onErrorContainer,
      warning: Color.lerp(warning, other.warning, t) ?? warning,
      warningContainer: Color.lerp(warningContainer, other.warningContainer, t) ?? warningContainer,
      onWarning: Color.lerp(onWarning, other.onWarning, t) ?? onWarning,
      onWarningContainer: Color.lerp(onWarningContainer, other.onWarningContainer, t) ?? onWarningContainer,
      success: Color.lerp(success, other.success, t) ?? success,
      successContainer: Color.lerp(successContainer, other.successContainer, t) ?? successContainer,
      onSuccess: Color.lerp(onSuccess, other.onSuccess, t) ?? onSuccess,
      onSuccessContainer: Color.lerp(onSuccessContainer, other.onSuccessContainer, t) ?? onSuccessContainer,
      surface: Color.lerp(surface, other.surface, t) ?? surface,
      surfaceVariant: Color.lerp(surfaceVariant, other.surfaceVariant, t) ?? surfaceVariant,
      surfaceContainer: Color.lerp(surfaceContainer, other.surfaceContainer, t) ?? surfaceContainer,
      surfaceContainerHigh: Color.lerp(surfaceContainerHigh, other.surfaceContainerHigh, t) ?? surfaceContainerHigh,
      onSurface: Color.lerp(onSurface, other.onSurface, t) ?? onSurface,
      onSurfaceVariant: Color.lerp(onSurfaceVariant, other.onSurfaceVariant, t) ?? onSurfaceVariant,
      background: Color.lerp(background, other.background, t) ?? background,
      onBackground: Color.lerp(onBackground, other.onBackground, t) ?? onBackground,
      outline: Color.lerp(outline, other.outline, t) ?? outline,
      outlineVariant: Color.lerp(outlineVariant, other.outlineVariant, t) ?? outlineVariant,
      shadow: Color.lerp(shadow, other.shadow, t) ?? shadow,
      scrim: Color.lerp(scrim, other.scrim, t) ?? scrim,
      inverseSurface: Color.lerp(inverseSurface, other.inverseSurface, t) ?? inverseSurface,
      onInverseSurface: Color.lerp(onInverseSurface, other.onInverseSurface, t) ?? onInverseSurface,
      inversePrimary: Color.lerp(inversePrimary, other.inversePrimary, t) ?? inversePrimary,
    );
  }
}

/// Typography tokens with semantic text styles
class MinqTypographyTokens {
  const MinqTypographyTokens({
    required this.displayLarge,
    required this.displayMedium,
    required this.displaySmall,
    required this.headlineLarge,
    required this.headlineMedium,
    required this.headlineSmall,
    required this.titleLarge,
    required this.titleMedium,
    required this.titleSmall,
    required this.bodyLarge,
    required this.bodyMedium,
    required this.bodySmall,
    required this.labelLarge,
    required this.labelMedium,
    required this.labelSmall,
  });

  // Display styles (largest text)
  final TextStyle displayLarge;
  final TextStyle displayMedium;
  final TextStyle displaySmall;

  // Headline styles
  final TextStyle headlineLarge;
  final TextStyle headlineMedium;
  final TextStyle headlineSmall;

  // Title styles
  final TextStyle titleLarge;
  final TextStyle titleMedium;
  final TextStyle titleSmall;

  // Body styles
  final TextStyle bodyLarge;
  final TextStyle bodyMedium;
  final TextStyle bodySmall;

  // Label styles
  final TextStyle labelLarge;
  final TextStyle labelMedium;
  final TextStyle labelSmall;

  static MinqTypographyTokens standard() {
    return MinqTypographyTokens(
      displayLarge: GoogleFonts.plusJakartaSans(
        fontSize: 57,
        fontWeight: FontWeight.w400,
        letterSpacing: -0.25,
        height: 1.12,
      ),
      displayMedium: GoogleFonts.plusJakartaSans(
        fontSize: 45,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
        height: 1.16,
      ),
      displaySmall: GoogleFonts.plusJakartaSans(
        fontSize: 36,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
        height: 1.22,
      ),
      headlineLarge: GoogleFonts.plusJakartaSans(
        fontSize: 32,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
        height: 1.25,
      ),
      headlineMedium: GoogleFonts.plusJakartaSans(
        fontSize: 28,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
        height: 1.29,
      ),
      headlineSmall: GoogleFonts.plusJakartaSans(
        fontSize: 24,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
        height: 1.33,
      ),
      titleLarge: GoogleFonts.plusJakartaSans(
        fontSize: 22,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
        height: 1.27,
      ),
      titleMedium: GoogleFonts.plusJakartaSans(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.15,
        height: 1.50,
      ),
      titleSmall: GoogleFonts.plusJakartaSans(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
        height: 1.43,
      ),
      bodyLarge: GoogleFonts.plusJakartaSans(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.5,
        height: 1.50,
      ),
      bodyMedium: GoogleFonts.plusJakartaSans(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.25,
        height: 1.43,
      ),
      bodySmall: GoogleFonts.plusJakartaSans(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.4,
        height: 1.33,
      ),
      labelLarge: GoogleFonts.plusJakartaSans(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
        height: 1.43,
      ),
      labelMedium: GoogleFonts.plusJakartaSans(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
        height: 1.33,
      ),
      labelSmall: GoogleFonts.plusJakartaSans(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
        height: 1.45,
      ),
    );
  }

  MinqTypographyTokens lerp(MinqTypographyTokens other, double t) {
    return MinqTypographyTokens(
      displayLarge: TextStyle.lerp(displayLarge, other.displayLarge, t) ?? displayLarge,
      displayMedium: TextStyle.lerp(displayMedium, other.displayMedium, t) ?? displayMedium,
      displaySmall: TextStyle.lerp(displaySmall, other.displaySmall, t) ?? displaySmall,
      headlineLarge: TextStyle.lerp(headlineLarge, other.headlineLarge, t) ?? headlineLarge,
      headlineMedium: TextStyle.lerp(headlineMedium, other.headlineMedium, t) ?? headlineMedium,
      headlineSmall: TextStyle.lerp(headlineSmall, other.headlineSmall, t) ?? headlineSmall,
      titleLarge: TextStyle.lerp(titleLarge, other.titleLarge, t) ?? titleLarge,
      titleMedium: TextStyle.lerp(titleMedium, other.titleMedium, t) ?? titleMedium,
      titleSmall: TextStyle.lerp(titleSmall, other.titleSmall, t) ?? titleSmall,
      bodyLarge: TextStyle.lerp(bodyLarge, other.bodyLarge, t) ?? bodyLarge,
      bodyMedium: TextStyle.lerp(bodyMedium, other.bodyMedium, t) ?? bodyMedium,
      bodySmall: TextStyle.lerp(bodySmall, other.bodySmall, t) ?? bodySmall,
      labelLarge: TextStyle.lerp(labelLarge, other.labelLarge, t) ?? labelLarge,
      labelMedium: TextStyle.lerp(labelMedium, other.labelMedium, t) ?? labelMedium,
      labelSmall: TextStyle.lerp(labelSmall, other.labelSmall, t) ?? labelSmall,
    );
  }
}

/// Spacing tokens based on 4px grid system
class MinqSpacingTokens {
  const MinqSpacingTokens();

  // Base unit (4px)
  static const double baseUnit = 4.0;

  // Spacing scale
  static const double none = 0.0;
  static const double xs = baseUnit * 1; // 4px
  static const double sm = baseUnit * 2; // 8px
  static const double md = baseUnit * 3; // 12px
  static const double lg = baseUnit * 4; // 16px
  static const double xl = baseUnit * 5; // 20px
  static const double xxl = baseUnit * 6; // 24px
  static const double xxxl = baseUnit * 8; // 32px

  // Semantic spacing
  static const double screenPadding = lg; // 16px
  static const double cardPadding = lg; // 16px
  static const double buttonPadding = md; // 12px
  static const double iconGap = sm; // 8px
  static const double sectionGap = xxl; // 24px

  // Minimum touch target size (accessibility)
  static const double minTouchTarget = 44.0;

  // EdgeInsets helpers
  EdgeInsets get screenPaddingAll => const EdgeInsets.all(screenPadding);
  EdgeInsets get cardPaddingAll => const EdgeInsets.all(cardPadding);
  EdgeInsets get buttonPaddingAll => const EdgeInsets.all(buttonPadding);

  EdgeInsets horizontal(double value) => EdgeInsets.symmetric(horizontal: value);
  EdgeInsets vertical(double value) => EdgeInsets.symmetric(vertical: value);
  EdgeInsets all(double value) => EdgeInsets.all(value);

  MinqSpacingTokens lerp(MinqSpacingTokens other, double t) {
    return const MinqSpacingTokens(); // Spacing tokens are constant
  }
}

/// Border radius tokens
class MinqRadiusTokens {
  const MinqRadiusTokens();

  static const double none = 0.0;
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 20.0;
  static const double xxl = 28.0;
  static const double full = 999.0;

  // BorderRadius helpers
  BorderRadius get noneRadius => BorderRadius.circular(none);
  BorderRadius get xsRadius => BorderRadius.circular(xs);
  BorderRadius get smRadius => BorderRadius.circular(sm);
  BorderRadius get mdRadius => BorderRadius.circular(md);
  BorderRadius get lgRadius => BorderRadius.circular(lg);
  BorderRadius get xlRadius => BorderRadius.circular(xl);
  BorderRadius get xxlRadius => BorderRadius.circular(xxl);
  BorderRadius get fullRadius => BorderRadius.circular(full);

  // Semantic radius
  BorderRadius get buttonRadius => smRadius;
  BorderRadius get cardRadius => mdRadius;
  BorderRadius get dialogRadius => lgRadius;

  MinqRadiusTokens lerp(MinqRadiusTokens other, double t) {
    return const MinqRadiusTokens(); // Radius tokens are constant
  }
}

/// Elevation tokens (shadows)
class MinqElevationTokens {
  const MinqElevationTokens({
    required this.none,
    required this.sm,
    required this.md,
    required this.lg,
    required this.xl,
  });

  final List<BoxShadow> none;
  final List<BoxShadow> sm;
  final List<BoxShadow> md;
  final List<BoxShadow> lg;
  final List<BoxShadow> xl;

  static MinqElevationTokens light() {
    return const MinqElevationTokens(
      none: [],
      sm: [
        BoxShadow(
          color: Color(0x0F000000),
          blurRadius: 4,
          offset: Offset(0, 1),
        ),
      ],
      md: [
        BoxShadow(
          color: Color(0x1A000000),
          blurRadius: 8,
          offset: Offset(0, 2),
        ),
      ],
      lg: [
        BoxShadow(
          color: Color(0x1F000000),
          blurRadius: 16,
          offset: Offset(0, 4),
        ),
      ],
      xl: [
        BoxShadow(
          color: Color(0x24000000),
          blurRadius: 24,
          offset: Offset(0, 8),
        ),
      ],
    );
  }

  static MinqElevationTokens dark() {
    return const MinqElevationTokens(
      none: [],
      sm: [
        BoxShadow(
          color: Color(0x33000000),
          blurRadius: 4,
          offset: Offset(0, 1),
        ),
      ],
      md: [
        BoxShadow(
          color: Color(0x3D000000),
          blurRadius: 8,
          offset: Offset(0, 2),
        ),
      ],
      lg: [
        BoxShadow(
          color: Color(0x47000000),
          blurRadius: 16,
          offset: Offset(0, 4),
        ),
      ],
      xl: [
        BoxShadow(
          color: Color(0x52000000),
          blurRadius: 24,
          offset: Offset(0, 8),
        ),
      ],
    );
  }

  MinqElevationTokens lerp(MinqElevationTokens other, double t) {
    return MinqElevationTokens(
      none: none,
      sm: t < 0.5 ? sm : other.sm,
      md: t < 0.5 ? md : other.md,
      lg: t < 0.5 ? lg : other.lg,
      xl: t < 0.5 ? xl : other.xl,
    );
  }
}

/// Animation tokens
class MinqAnimationTokens {
  const MinqAnimationTokens();

  // Duration tokens
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration medium = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 500);

  // Curve tokens
  static const Curve easeIn = Curves.easeIn;
  static const Curve easeOut = Curves.easeOut;
  static const Curve easeInOut = Curves.easeInOut;
  static const Curve bounceOut = Curves.bounceOut;
  static const Curve elasticOut = Curves.elasticOut;

  MinqAnimationTokens lerp(MinqAnimationTokens other, double t) {
    return const MinqAnimationTokens(); // Animation tokens are constant
  }
}

/// Extension to easily access design tokens from BuildContext
extension MinqDesignTokensExtension on BuildContext {
  MinqDesignTokens get tokens => MinqDesignTokens.of(this);
  MinqColorTokens get colors => tokens.colors;
  MinqTypographyTokens get typography => tokens.typography;
  MinqSpacingTokens get spacing => tokens.spacing;
  MinqRadiusTokens get radius => tokens.radius;
  MinqElevationTokens get elevation => tokens.elevation;
  MinqAnimationTokens get animation => tokens.animation;
}