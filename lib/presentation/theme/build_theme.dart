import 'package:flutter/material.dart';
import 'package:minq/presentation/theme/minq_theme.dart';

/// A utility function to build a [ThemeData] from a [MinqTheme] instance.
///
/// This function encapsulates the logic of translating design tokens from [MinqTheme]
/// into a fully-fledged [ThemeData] object, ensuring consistency across the app.
ThemeData buildTheme(MinqTheme tokens) {
  final baseScheme = ColorScheme.fromSeed(
    seedColor: tokens.brandPrimary,
    brightness: tokens.brightness,
  );

  final colorScheme = baseScheme.copyWith(
    primary: tokens.brandPrimary,
    onPrimary: tokens.onPrimary,
    secondary: tokens.accentSecondary,
    onSecondary: tokens.onSecondary,
    error: tokens.accentError,
    onError: tokens.onPrimary,
    surface: tokens.surface,
    onSurface: tokens.onSurface,
    outline: tokens.divider,
  );

  final buttonShape = WidgetStatePropertyAll<OutlinedBorder>(
    RoundedRectangleBorder(borderRadius: tokens.cornerLarge()),
  );
  final buttonPadding = WidgetStatePropertyAll<EdgeInsetsGeometry>(
    EdgeInsets.symmetric(horizontal: tokens.spacing(4)),
  );
  const minButtonSize = WidgetStatePropertyAll<Size>(Size(80, 48));

  final typeScale = tokens.typeScale;
  final textTheme = TextTheme(
    displayMedium: typeScale.h1,
    displaySmall: typeScale.h2,
    headlineMedium: typeScale.h3,
    headlineSmall: typeScale.h4,
    titleLarge: typeScale.h3,
    titleMedium: typeScale.h4,
    titleSmall: typeScale.h5,
    bodyLarge: typeScale.bodyLarge,
    bodyMedium: typeScale.bodyMedium,
    bodySmall: typeScale.bodySmall,
    labelLarge: typeScale.button,
    labelSmall: typeScale.caption,
  ).apply(bodyColor: tokens.textPrimary, displayColor: tokens.textPrimary);

  final isLight = tokens.brightness == Brightness.light;
  const transparent = Color(0x00000000);
  final cardBorder =
      isLight ? BorderSide.none : BorderSide(color: tokens.divider);
  final cardElevation = isLight ? 2.0 : 0.0;
  final cardShadowColor =
      isLight ? tokens.onSurface.withValues(alpha: 0.08) : transparent;

  final overlayPrimary = WidgetStatePropertyAll<Color>(
    tokens.primaryHover.withValues(alpha: 0.12),
  );
  final overlaySecondary = WidgetStatePropertyAll<Color>(
    tokens.accentSecondary.withValues(alpha: 0.12),
  );

  return ThemeData(
    useMaterial3: true,
    brightness: tokens.brightness,
    colorScheme: colorScheme,
    textTheme: textTheme,
    scaffoldBackgroundColor: tokens.background,
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: tokens.surfaceAlt,
      contentTextStyle: tokens.bodyMedium.copyWith(color: tokens.onSurface),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: tokens.background,
      foregroundColor: tokens.onSurface,
      surfaceTintColor: transparent,
      elevation: 0,
    ),
    cardTheme: CardThemeData(
      color: tokens.surface,
      shadowColor: cardShadowColor,
      surfaceTintColor: transparent,
      shape: RoundedRectangleBorder(
        borderRadius: tokens.cornerMedium(),
        side: cardBorder,
      ),
      elevation: cardElevation,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        minimumSize: minButtonSize,
        padding: buttonPadding,
        shape: buttonShape,
        tapTargetSize: MaterialTapTargetSize.padded,
        backgroundColor: WidgetStatePropertyAll<Color>(tokens.brandPrimary),
        foregroundColor: WidgetStatePropertyAll<Color>(tokens.onPrimary),
        overlayColor: overlayPrimary,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: ButtonStyle(
        minimumSize: minButtonSize,
        padding: buttonPadding,
        shape: buttonShape,
        tapTargetSize: MaterialTapTargetSize.padded,
        foregroundColor: WidgetStatePropertyAll<Color>(tokens.accentSecondary),
        overlayColor: overlaySecondary,
        side: WidgetStatePropertyAll<BorderSide>(
          BorderSide(color: tokens.accentSecondary),
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: ButtonStyle(
        minimumSize: minButtonSize,
        padding: buttonPadding,
        shape: buttonShape,
        tapTargetSize: MaterialTapTargetSize.padded,
        foregroundColor: WidgetStatePropertyAll<Color>(tokens.brandPrimary),
        overlayColor: overlayPrimary,
      ),
    ),
    iconButtonTheme: IconButtonThemeData(
      style: ButtonStyle(
        tapTargetSize: MaterialTapTargetSize.padded,
        minimumSize: const WidgetStatePropertyAll<Size>(Size.square(48)),
        foregroundColor: WidgetStatePropertyAll<Color>(tokens.onSurface),
        overlayColor: overlayPrimary,
      ),
    ),
    iconTheme: IconThemeData(
      weight:
          400, // Use "regular" weight, which is visually close to a 2dp stroke.
      color: tokens.onSurface,
    ),
    listTileTheme: const ListTileThemeData(
      minVerticalPadding:
          16, // Ensures a minimum height of ~48dp for a single-line tile
    ),
    extensions: <ThemeExtension<dynamic>>[tokens],
  );
}
