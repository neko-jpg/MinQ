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
    primary: Color(0xFF4F46E5),
    primaryHover: Color(0xFF4338CA),
    secondary: Color(0xFF22D3EE),
    background: Color(0xFFF4F6FB),
    surface: Color(0xFFFFFFFF),
    surfaceAlt: Color(0xFFEEF1FF),
    divider: Color(0xFFE2E8F0),
    border: Color(0xFFE2E8F0),
    textPrimary: Color(0xFF0F172A),
    textSecondary: Color(0xFF475569),
    success: Color(0xFF22C55E),
    warning: Color(0xFFF59E0B),
    error: Color(0xFFEF4444),
    onPrimary: Color(0xFFFFFFFF),
    onSecondary: Color(0xFF0B1120),
    onSurface: Color(0xFF0F172A),
    highContrastPrimary: Color(0xFF1E1B4B),
    highContrastOnPrimary: Color(0xFFFFFFFF),
  );

  static const ColorTokens dark = ColorTokens(
    primary: Color(0xFFA5B4FC),
    primaryHover: Color(0xFF818CF8),
    secondary: Color(0xFF2DD4BF),
    background: Color(0xFF0F172A),
    surface: Color(0xFF111827),
    surfaceAlt: Color(0xFF1F2937),
    divider: Color(0xFF1E293B),
    border: Color(0xFF1E293B),
    textPrimary: Color(0xFFE2E8F0),
    textSecondary: Color(0xFF94A3B8),
    success: Color(0xFF34D399),
    warning: Color(0xFFFBBF24),
    error: Color(0xFFF87171),
    onPrimary: Color(0xFF0B1120),
    onSecondary: Color(0xFF0B1120),
    onSurface: Color(0xFFE2E8F0),
    highContrastPrimary: Color(0xFFC4B5FD),
    highContrastOnPrimary: Color(0xFF0F172A),
  );

  /// Provides a readable on-color automatically for arbitrary backgrounds.
  Color contrastOn(Color background) {
    final luminance = background.computeLuminance();
    return luminance > 0.5 ? const Color(0xFF0D0D0D) : const Color(0xFFFFFFFF);
  }
}
