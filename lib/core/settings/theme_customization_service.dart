import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:minq/core/settings/settings_service.dart';
import 'package:minq/presentation/theme/minq_theme.dart';

/// Service for managing theme customization
class ThemeCustomizationService {
  final SettingsService _settingsService;

  ThemeCustomizationService(this._settingsService);

  /// Predefined accent colors
  static const List<Color> accentColors = [
    Color(0xFF4F46E5), // Midnight Indigo (default)
    Color(0xFF8B5CF6), // Aurora Violet
    Color(0xFF14B8A6), // Horizon Teal
    Color(0xFFEF4444), // Red
    Color(0xFFF59E0B), // Amber
    Color(0xFF10B981), // Emerald
    Color(0xFF3B82F6), // Blue
    Color(0xFF8B5CF6), // Purple
    Color(0xFFEC4899), // Pink
    Color(0xFF06B6D4), // Cyan
  ];

  /// Get current theme mode
  Future<ThemeMode> getThemeMode() async {
    return await _settingsService.getThemeMode();
  }

  /// Set theme mode
  Future<void> setThemeMode(ThemeMode mode) async {
    await _settingsService.setThemeMode(mode);
  }

  /// Get current accent color
  Future<Color> getAccentColor() async {
    final color = await _settingsService.getAccentColor();
    return color ?? accentColors.first;
  }

  /// Set accent color
  Future<void> setAccentColor(Color color) async {
    await _settingsService.setAccentColor(color);
  }

  /// Create custom theme with accent color
  MinqTheme createCustomTheme({
    required Brightness brightness,
    Color? accentColor,
  }) {
    final baseTheme = brightness == Brightness.light 
        ? MinqTheme.light() 
        : MinqTheme.dark();

    if (accentColor == null) {
      return baseTheme;
    }

    // Generate complementary colors based on accent
    final primaryHover = _adjustColorBrightness(accentColor, 0.1);
    final secondary = _adjustColorHue(accentColor, 30);
    
    return baseTheme.copyWith(
      brandPrimary: accentColor,
      primaryHover: primaryHover,
      accentSecondary: secondary,
      progressActive: accentColor,
      joyAccent: _adjustColorHue(accentColor, 60),
      encouragement: _adjustColorHue(accentColor, -30),
    );
  }

  /// Adjust color brightness
  Color _adjustColorBrightness(Color color, double factor) {
    final hsl = HSLColor.fromColor(color);
    final lightness = (hsl.lightness + factor).clamp(0.0, 1.0);
    return hsl.withLightness(lightness).toColor();
  }

  /// Adjust color hue
  Color _adjustColorHue(Color color, double degrees) {
    final hsl = HSLColor.fromColor(color);
    final hue = (hsl.hue + degrees) % 360;
    return hsl.withHue(hue).toColor();
  }

  /// Get theme preview data
  ThemePreviewData getThemePreview({
    required Brightness brightness,
    Color? accentColor,
  }) {
    final theme = createCustomTheme(
      brightness: brightness,
      accentColor: accentColor,
    );

    return ThemePreviewData(
      theme: theme,
      brightness: brightness,
      accentColor: accentColor ?? accentColors.first,
    );
  }

  /// Reset theme to default
  Future<void> resetTheme() async {
    await _settingsService.setThemeMode(ThemeMode.system);
    await _settingsService.setAccentColor(accentColors.first);
  }
}

/// Data class for theme preview
class ThemePreviewData {
  final MinqTheme theme;
  final Brightness brightness;
  final Color accentColor;

  const ThemePreviewData({
    required this.theme,
    required this.brightness,
    required this.accentColor,
  });
}

final themeCustomizationServiceProvider = Provider<ThemeCustomizationService>((ref) {
  final settingsService = ref.watch(settingsServiceProvider);
  return ThemeCustomizationService(settingsService);
});

/// Provider for current theme mode
final themeModeProvider = FutureProvider<ThemeMode>((ref) async {
  final service = ref.watch(themeCustomizationServiceProvider);
  return await service.getThemeMode();
});

/// Provider for current accent color
final accentColorProvider = FutureProvider<Color>((ref) async {
  final service = ref.watch(themeCustomizationServiceProvider);
  return await service.getAccentColor();
});

/// Provider for theme preview
final themePreviewProvider = Provider.family<ThemePreviewData, ThemePreviewParams>((ref, params) {
  final service = ref.watch(themeCustomizationServiceProvider);
  return service.getThemePreview(
    brightness: params.brightness,
    accentColor: params.accentColor,
  );
});

class ThemePreviewParams {
  final Brightness brightness;
  final Color? accentColor;

  const ThemePreviewParams({
    required this.brightness,
    this.accentColor,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ThemePreviewParams &&
          runtimeType == other.runtimeType &&
          brightness == other.brightness &&
          accentColor == other.accentColor;

  @override
  int get hashCode => brightness.hashCode ^ accentColor.hashCode;
}