import 'package:flutter/material.dart';

/// Defines the core color palette for the MiniQuest design system.
///
/// The values are extracted from `color.md` and exposed as semantic
/// tokens so widgets can describe intent (primary, surface, border, etc.)
/// without hard-coding material color constants. Keeping the palette in a
/// single location also makes it trivial to update when the design team
/// revises the visual language.
class ColorTokens {
  const ColorTokens({
    required this.primary,
    required this.primaryHover,
    required this.secondary,
    required this.background,
    required this.surface,
    required this.surfaceAlt,
    required this.divider,
    required this.border,
    required this.textPrimary,
    required this.textSecondary,
    required this.success,
    required this.warning,
    required this.error,
    required this.onPrimary,
    required this.onSecondary,
    required this.onSurface,
    required this.highContrastPrimary,
    required this.highContrastOnPrimary,
  });

  final Color primary;
  final Color primaryHover;
  final Color secondary;
  final Color background;
  final Color surface;
  final Color surfaceAlt;
  final Color divider;
  final Color border;
  final Color textPrimary;
  final Color textSecondary;
  final Color success;
  final Color warning;
  final Color error;
  final Color onPrimary;
  final Color onSecondary;
  final Color onSurface;
  final Color highContrastPrimary;
  final Color highContrastOnPrimary;

  static const ColorTokens light = ColorTokens(
    primary: Color(0xFF18A0FB),
    primaryHover: Color(0xFF0B74D8),
    secondary: Color(0xFF06BCB5),
    background: Color(0xFFFFFFFF),
    surface: Color(0xFFF7FAFC),
    surfaceAlt: Color(0xFFEFF3F8),
    divider: Color(0xFFE0E0E0),
    border: Color(0xFFE0E0E0),
    textPrimary: Color(0xFF0D0D0D),
    textSecondary: Color(0xFF4F4F4F),
    success: Color(0xFF3CB371),
    warning: Color(0xFFF0A202),
    error: Color(0xFFE55D5D),
    onPrimary: Color(0xFFFFFFFF),
    onSecondary: Color(0xFFFFFFFF),
    onSurface: Color(0xFF0D0D0D),
    highContrastPrimary: Color(0xFF005BBB),
    highContrastOnPrimary: Color(0xFFFFFFFF),
  );

  static const ColorTokens dark = ColorTokens(
    primary: Color(0xFF90CAF9),
    primaryHover: Color(0xFF64B5F6),
    secondary: Color(0xFF4DD0C4),
    background: Color(0xFF121212),
    surface: Color(0xFF1E1E1E),
    surfaceAlt: Color(0xFF242424),
    divider: Color(0xFF262626),
    border: Color(0xFF262626),
    textPrimary: Color(0xFFECEFF1),
    textSecondary: Color(0xFFB0BEC5),
    success: Color(0xFF66BB6A),
    warning: Color(0xFFFFB74D),
    error: Color(0xFFEF9A9A),
    onPrimary: Color(0xFF0D0D0D),
    onSecondary: Color(0xFF0D0D0D),
    onSurface: Color(0xFFECEFF1),
    highContrastPrimary: Color(0xFF005BBB),
    highContrastOnPrimary: Color(0xFFFFFFFF),
  );

  /// Provides a readable on-color automatically for arbitrary backgrounds.
  Color contrastOn(Color background) {
    final luminance = background.computeLuminance();
    return luminance > 0.5 ? const Color(0xFF0D0D0D) : const Color(0xFFFFFFFF);
  }
}
