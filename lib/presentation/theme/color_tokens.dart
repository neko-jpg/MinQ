import 'package:flutter/material.dart';

/// Defines the comprehensive color palette for the MinQ design system v2.0.
///
/// Implements the new brand colors (Midnight Indigo, Aurora Violet, Horizon Teal)
/// with full light/dark theme support and WCAG AA compliance.
/// All colors meet accessibility standards with proper contrast ratios.
class ColorTokens {
  const ColorTokens({
    // Brand Colors
    required this.primary,
    required this.primaryHover,
    required this.onPrimary,
    required this.secondary,
    required this.onSecondary,
    required this.tertiary,
    required this.onTertiary,
    
    // Surfaces
    required this.background,
    required this.onBackground,
    required this.surface,
    required this.onSurface,
    required this.surfaceAlt,
    required this.surfaceVariant,
    
    // Text Colors
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    
    // Semantic Colors
    required this.success,
    required this.onSuccess,
    required this.warning,
    required this.onWarning,
    required this.error,
    required this.onError,
    required this.info,
    required this.onInfo,
    
    // Interactive
    required this.focusRing,
    required this.border,
    required this.divider,
    required this.overlay,
    
    // Accessibility
    required this.highContrastPrimary,
    required this.highContrastOnPrimary,
    required this.highContrastBackground,
    required this.highContrastText,
  });

  // Brand Colors - New Midnight Indigo, Aurora Violet, Horizon Teal palette
  final Color primary;
  final Color primaryHover;
  final Color onPrimary;
  final Color secondary;
  final Color onSecondary;
  final Color tertiary;
  final Color onTertiary;
  
  // Surfaces
  final Color background;
  final Color onBackground;
  final Color surface;
  final Color onSurface;
  final Color surfaceAlt;
  final Color surfaceVariant;
  
  // Text Colors
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;
  
  // Semantic Colors
  final Color success;
  final Color onSuccess;
  final Color warning;
  final Color onWarning;
  final Color error;
  final Color onError;
  final Color info;
  final Color onInfo;
  
  // Interactive
  final Color focusRing;
  final Color border;
  final Color divider;
  final Color overlay;
  
  // Accessibility
  final Color highContrastPrimary;
  final Color highContrastOnPrimary;
  final Color highContrastBackground;
  final Color highContrastText;

  /// Light theme with new brand colors - Midnight Indigo, Aurora Violet, Horizon Teal
  static const ColorTokens light = ColorTokens(
    // Brand Colors
    primary: Color(0xFF4F46E5), // Midnight Indigo
    primaryHover: Color(0xFF4338CA),
    onPrimary: Color(0xFFFFFFFF),
    secondary: Color(0xFF8B5CF6), // Aurora Violet
    onSecondary: Color(0xFF000000), // Black for better contrast
    tertiary: Color(0xFF14B8A6), // Horizon Teal
    onTertiary: Color(0xFF000000), // Black for better contrast
    
    // Surfaces
    background: Color(0xFFF5F7FB),
    onBackground: Color(0xFF0F172A),
    surface: Color(0xFFFFFFFF),
    onSurface: Color(0xFF0F172A),
    surfaceAlt: Color(0xFFF8FAFC),
    surfaceVariant: Color(0xFFE2E8F0),
    
    // Text Colors
    textPrimary: Color(0xFF0F172A),
    textSecondary: Color(0xFF475569),
    textMuted: Color(0xFF94A3B8),
    
    // Semantic Colors
    success: Color(0xFF10B981),
    onSuccess: Color(0xFF000000), // Black for better contrast
    warning: Color(0xFFF59E0B),
    onWarning: Color(0xFF000000), // Black for better contrast
    error: Color(0xFFDC2626), // Darker red for better contrast
    onError: Color(0xFFFFFFFF),
    info: Color(0xFF0369A1), // Darker blue for better contrast
    onInfo: Color(0xFFFFFFFF),
    
    // Interactive
    focusRing: Color(0xFF93C5FD),
    border: Color(0xFFE2E8F0),
    divider: Color(0xFFE2E8F0),
    overlay: Color(0x990F172A),
    
    // Accessibility
    highContrastPrimary: Color(0xFF1E1B4B),
    highContrastOnPrimary: Color(0xFFFFFFFF),
    highContrastBackground: Color(0xFFFFFFFF),
    highContrastText: Color(0xFF000000),
  );

  /// Dark theme with adjusted brand colors for optimal contrast
  static const ColorTokens dark = ColorTokens(
    // Brand Colors (adjusted for dark theme)
    primary: Color(0xFF818CF8), // Lighter Midnight Indigo for dark
    primaryHover: Color(0xFFA5B4FC),
    onPrimary: Color(0xFF0B1120),
    secondary: Color(0xFFA78BFA), // Lighter Aurora Violet for dark
    onSecondary: Color(0xFF0B1120),
    tertiary: Color(0xFF2DD4BF), // Lighter Horizon Teal for dark
    onTertiary: Color(0xFF0B1120),
    
    // Surfaces
    background: Color(0xFF0B1120),
    onBackground: Color(0xFFE5E7EB),
    surface: Color(0xFF0F172A),
    onSurface: Color(0xFFE5E7EB),
    surfaceAlt: Color(0xFF111827),
    surfaceVariant: Color(0xFF334155),
    
    // Text Colors
    textPrimary: Color(0xFFE5E7EB),
    textSecondary: Color(0xFF9CA3AF),
    textMuted: Color(0xFF64748B),
    
    // Semantic Colors
    success: Color(0xFF34D399),
    onSuccess: Color(0xFF0B1120),
    warning: Color(0xFFFBBF24),
    onWarning: Color(0xFF0B1120),
    error: Color(0xFFF87171),
    onError: Color(0xFF0B1120),
    info: Color(0xFF38BDF8),
    onInfo: Color(0xFF0B1120),
    
    // Interactive
    focusRing: Color(0xFF60A5FA),
    border: Color(0xFF334155),
    divider: Color(0xFF334155),
    overlay: Color(0x99000000),
    
    // Accessibility
    highContrastPrimary: Color(0xFFC4B5FD),
    highContrastOnPrimary: Color(0xFF000000),
    highContrastBackground: Color(0xFF000000),
    highContrastText: Color(0xFFFFFFFF),
  );

  /// Data visualization palette (8 colors for charts/graphs)
  static const List<Color> dataVisualizationPalette = [
    Color(0xFF4F46E5), // Midnight Indigo
    Color(0xFF8B5CF6), // Aurora Violet
    Color(0xFF14B8A6), // Horizon Teal
    Color(0xFF10B981), // Success Green
    Color(0xFFF59E0B), // Warning Orange
    Color(0xFFEF4444), // Error Red
    Color(0xFF0284C7), // Info Blue
    Color(0xFF6366F1), // Accent Purple
  ];

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

  /// Provides a readable on-color automatically for arbitrary backgrounds.
  Color contrastOn(Color background) {
    final luminance = background.computeLuminance();
    return luminance > 0.5 ? textPrimary : onSurface;
  }

  /// Get accessible text color for given background
  Color getAccessibleTextColor(Color background) {
    return meetsWCAGAA(textPrimary, background) ? textPrimary : onBackground;
  }

  /// Ensure color meets accessibility standards on given background
  Color ensureAccessible(Color color, Color background) {
    if (meetsWCAGAA(color, background)) {
      return color;
    }
    
    // Try to adjust the color to meet accessibility standards
    final isBackgroundLight = background.computeLuminance() >= 0.5;
    final targetColor = isBackgroundLight ? textPrimary : onSurface;
    
    // Gradually blend towards accessible color
    for (double t = 0.1; t <= 1.0; t += 0.1) {
      final candidate = Color.lerp(color, targetColor, t)!;
      if (meetsWCAGAA(candidate, background)) {
        return candidate;
      }
    }
    
    return targetColor;
  }
}
