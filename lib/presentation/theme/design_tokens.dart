import 'package:flutter/material.dart';
import 'package:minq/presentation/theme/color_tokens.dart';

class MinqSpacingTokens {
  const MinqSpacingTokens({
    required this.xxs,
    required this.xs,
    required this.sm,
    required this.md,
    required this.lg,
    required this.xl,
    required this.xxl,
  });

  const MinqSpacingTokens.base()
      : this(
          xxs: 2,
          xs: 4,
          sm: 8,
          md: 16,
          lg: 24,
          xl: 32,
          xxl: 48,
        );

  final double xxs;
  final double xs;
  final double sm;
  final double md;
  final double lg;
  final double xl;
  final double xxl;

  EdgeInsets inset(double value) => EdgeInsets.all(value);
  EdgeInsets horizontal(double value) => EdgeInsets.symmetric(horizontal: value);
  EdgeInsets vertical(double value) => EdgeInsets.symmetric(vertical: value);
}

class MinqRadiusTokens {
  const MinqRadiusTokens({
    required this.xs,
    required this.sm,
    required this.md,
    required this.lg,
    required this.xl,
    required this.full,
  });

  const MinqRadiusTokens.base()
      : this(
          xs: 4,
          sm: 8,
          md: 12,
          lg: 16,
          xl: 24,
          full: 999,
        );

  final double xs;
  final double sm;
  final double md;
  final double lg;
  final double xl;
  final double full;

  BorderRadius circular(double value) => BorderRadius.circular(value);
}

class MinqElevationTokens {
  const MinqElevationTokens({
    required this.none,
    required this.sm,
    required this.md,
    required this.lg,
    required this.xl,
  });

  factory MinqElevationTokens.light() => const MinqElevationTokens(
        none: [],
        sm: [
          BoxShadow(color: Color(0x0F000000), blurRadius: 4, offset: Offset(0, 1)),
        ],
        md: [
          BoxShadow(color: Color(0x14000000), blurRadius: 10, offset: Offset(0, 4)),
        ],
        lg: [
          BoxShadow(color: Color(0x1F000000), blurRadius: 18, offset: Offset(0, 8)),
        ],
        xl: [
          BoxShadow(color: Color(0x24000000), blurRadius: 26, offset: Offset(0, 12)),
        ],
      );

  factory MinqElevationTokens.dark() => const MinqElevationTokens(
        none: [],
        sm: [
          BoxShadow(color: Color(0x33000000), blurRadius: 4, offset: Offset(0, 1)),
        ],
        md: [
          BoxShadow(color: Color(0x3D000000), blurRadius: 10, offset: Offset(0, 4)),
        ],
        lg: [
          BoxShadow(color: Color(0x47000000), blurRadius: 18, offset: Offset(0, 8)),
        ],
        xl: [
          BoxShadow(color: Color(0x52000000), blurRadius: 26, offset: Offset(0, 12)),
        ],
      );

  final List<BoxShadow> none;
  final List<BoxShadow> sm;
  final List<BoxShadow> md;
  final List<BoxShadow> lg;
  final List<BoxShadow> xl;

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

class MinqAnimationTokens {
  const MinqAnimationTokens({
    this.fast = const Duration(milliseconds: 150),
    this.medium = const Duration(milliseconds: 300),
    this.slow = const Duration(milliseconds: 500),
    this.easeIn = Curves.easeIn,
    this.easeOut = Curves.easeOut,
    this.easeInOut = Curves.easeInOut,
  });

  final Duration fast;
  final Duration medium;
  final Duration slow;
  final Curve easeIn;
  final Curve easeOut;
  final Curve easeInOut;
}

class MinqDesignTokens extends ThemeExtension<MinqDesignTokens> {
  const MinqDesignTokens({
    required this.colorScheme,
    required this.textTheme,
    required this.spacing,
    required this.radius,
    required this.elevation,
    required this.animation,
  });

  final ColorScheme colorScheme;
  final TextTheme textTheme;
  final MinqSpacingTokens spacing;
  final MinqRadiusTokens radius;
  final MinqElevationTokens elevation;
  final MinqAnimationTokens animation;

  factory MinqDesignTokens.light() => MinqDesignTokens(
        colorScheme: _colorSchemeFromTokens(ColorTokens.light, Brightness.light),
        textTheme: _textTheme(Brightness.light),
        spacing: const MinqSpacingTokens.base(),
        radius: const MinqRadiusTokens.base(),
        elevation: MinqElevationTokens.light(),
        animation: const MinqAnimationTokens(),
      );

  factory MinqDesignTokens.dark() => MinqDesignTokens(
        colorScheme: _colorSchemeFromTokens(ColorTokens.dark, Brightness.dark),
        textTheme: _textTheme(Brightness.dark),
        spacing: const MinqSpacingTokens.base(),
        radius: const MinqRadiusTokens.base(),
        elevation: MinqElevationTokens.dark(),
        animation: const MinqAnimationTokens(),
      );

  static MinqDesignTokens of(BuildContext context) {
    final extension = Theme.of(context).extension<MinqDesignTokens>();
    if (extension != null) {
      return extension;
    }
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.dark
        ? MinqDesignTokens.dark()
        : MinqDesignTokens.light();
  }

  @override
  MinqDesignTokens copyWith({
    ColorScheme? colorScheme,
    TextTheme? textTheme,
    MinqSpacingTokens? spacing,
    MinqRadiusTokens? radius,
    MinqElevationTokens? elevation,
    MinqAnimationTokens? animation,
  }) {
    return MinqDesignTokens(
      colorScheme: colorScheme ?? this.colorScheme,
      textTheme: textTheme ?? this.textTheme,
      spacing: spacing ?? this.spacing,
      radius: radius ?? this.radius,
      elevation: elevation ?? this.elevation,
      animation: animation ?? this.animation,
    );
  }

  @override
  MinqDesignTokens lerp(
    ThemeExtension<MinqDesignTokens>? other,
    double t,
  ) {
    if (other is! MinqDesignTokens) return this;
    return MinqDesignTokens(
      colorScheme: ColorScheme.lerp(colorScheme, other.colorScheme, t),
      textTheme: TextTheme.lerp(textTheme, other.textTheme, t),
      spacing: spacing,
      radius: radius,
      elevation: elevation.lerp(other.elevation, t),
      animation: animation,
    );
  }
}

extension MinqDesignTokensExtension on BuildContext {
  MinqDesignTokens get tokens => MinqDesignTokens.of(this);
  ColorScheme get colors => tokens.colorScheme;
  TextTheme get typography => tokens.textTheme;
  MinqSpacingTokens get spacing => tokens.spacing;
  MinqRadiusTokens get radius => tokens.radius;
  MinqElevationTokens get elevations => tokens.elevation;
  MinqAnimationTokens get animations => tokens.animation;
}

ColorScheme _colorSchemeFromTokens(
  ColorTokens tokens,
  Brightness brightness,
) {
  final base = brightness == Brightness.dark
      ? const ColorScheme.dark()
      : const ColorScheme.light();

  return base.copyWith(
    primary: tokens.primary,
    onPrimary: tokens.onPrimary,
    primaryContainer: tokens.surfaceAlt,
    onPrimaryContainer: tokens.onSurface,
    secondary: tokens.secondary,
    onSecondary: tokens.onSecondary,
    secondaryContainer: tokens.surfaceAlt,
    onSecondaryContainer: tokens.onSurface,
    tertiary: tokens.tertiary,
    onTertiary: tokens.onTertiary,
    tertiaryContainer: tokens.surfaceAlt,
    onTertiaryContainer: tokens.onSurface,
    error: tokens.error,
    onError: tokens.onError,
    errorContainer: tokens.surfaceAlt,
    onErrorContainer: tokens.onSurface,
    surface: tokens.surface,
    onSurface: tokens.onSurface,
    // ignore: deprecated_member_use
    surfaceVariant: tokens.surfaceVariant,
    onSurfaceVariant: tokens.textSecondary,
    surfaceTint: tokens.primary,
    surfaceContainerHighest: tokens.surfaceAlt,
    surfaceBright: tokens.surface,
    surfaceDim: tokens.surfaceAlt,
    outline: tokens.border,
    outlineVariant: tokens.divider,
    inverseSurface: tokens.onSurface,
    onInverseSurface: tokens.surface,
    inversePrimary: tokens.primaryHover,
    shadow: Colors.black,
    scrim: Colors.black,
  );
}

TextTheme _textTheme(Brightness brightness) {
  final base =
      brightness == Brightness.dark ? Typography.whiteMountainView : Typography.blackMountainView;
  return base.apply(fontFamily: 'PlusJakartaSans');
}
