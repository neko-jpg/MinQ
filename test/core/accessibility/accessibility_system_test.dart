import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:minq/core/accessibility/accessibility_service.dart';
import 'package:minq/core/accessibility/color_blindness_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  
  group('AccessibilityService', () {
    late AccessibilityService accessibilityService;
    late SharedPreferences prefs;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
      accessibilityService = AccessibilityService(prefs);
      
      // Mock haptic feedback to avoid platform channel issues
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('flutter/hapticfeedback'),
        (MethodCall methodCall) async {
          return null;
        },
      );
    });

    test('should initialize with default settings', () {
      expect(accessibilityService.state.highContrast, false);
      expect(accessibilityService.state.largeText, false);
      expect(accessibilityService.state.boldText, false);
      expect(accessibilityService.state.reduceMotion, false);
      expect(accessibilityService.state.textScale, 1.0);
      expect(accessibilityService.state.buttonScale, 1.0);
      expect(accessibilityService.state.screenReaderOptimized, false);
      expect(accessibilityService.state.hapticFeedback, true);
      expect(accessibilityService.state.soundFeedback, true);
      expect(accessibilityService.state.colorBlindnessMode, ColorBlindnessMode.none);
      expect(accessibilityService.state.keyboardNavigation, false);
      expect(accessibilityService.state.focusIndicator, true);
    });

    test('should update high contrast setting', () async {
      await accessibilityService.setHighContrast(true);
      expect(accessibilityService.state.highContrast, true);
      expect(prefs.getBool('accessibility_high_contrast'), true);
    });

    test('should update text scale setting', () async {
      await accessibilityService.setTextScale(1.5);
      expect(accessibilityService.state.textScale, 1.5);
      expect(prefs.getDouble('accessibility_text_scale'), 1.5);
    });

    test('should update color blindness mode', () async {
      await accessibilityService.setColorBlindnessMode(ColorBlindnessMode.protanopia);
      expect(accessibilityService.state.colorBlindnessMode, ColorBlindnessMode.protanopia);
      expect(prefs.getInt('accessibility_color_blindness_mode'), ColorBlindnessMode.protanopia.index);
    });

    test('should get effective animation duration', () async {
      // Normal motion
      expect(
        accessibilityService.getEffectiveAnimationDuration(const Duration(milliseconds: 300)),
        const Duration(milliseconds: 300),
      );

      // Reduced motion
      await accessibilityService.setReduceMotion(true);
      expect(
        accessibilityService.getEffectiveAnimationDuration(const Duration(milliseconds: 300)),
        Duration.zero,
      );
    });
  });

  group('ColorBlindnessHelper', () {
    test('should not transform colors when mode is none', () {
      const color = Color(0xFF4F46E5);
      final transformed = ColorBlindnessHelper.transformColor(color, ColorBlindnessMode.none);
      expect(transformed, color);
    });

    test('should transform colors for protanopia', () {
      const color = Color(0xFFFF0000); // Red
      final transformed = ColorBlindnessHelper.transformColor(color, ColorBlindnessMode.protanopia);
      expect(transformed, isNot(color));
      expect(transformed.red, lessThan(color.red));
    });

    test('should transform colors for deuteranopia', () {
      const color = Color(0xFF00FF00); // Green
      final transformed = ColorBlindnessHelper.transformColor(color, ColorBlindnessMode.deuteranopia);
      expect(transformed, isNot(color));
      expect(transformed.green, lessThan(color.green));
    });

    test('should transform colors for tritanopia', () {
      const color = Color(0xFF0000FF); // Blue
      final transformed = ColorBlindnessHelper.transformColor(color, ColorBlindnessMode.tritanopia);
      expect(transformed, isNot(color));
      expect(transformed.blue, lessThan(color.blue));
    });

    test('should convert to grayscale for monochromacy', () {
      const color = Color(0xFF4F46E5);
      final transformed = ColorBlindnessHelper.transformColor(color, ColorBlindnessMode.monochromacy);
      expect(transformed.red, transformed.green);
      expect(transformed.green, transformed.blue);
    });

    test('should check color distinguishability', () {
      const color1 = Color(0xFF4F46E5);
      const color2 = Color(0xFF8B5CF6);
      
      // Colors should be distinguishable for normal vision
      expect(
        ColorBlindnessHelper.areColorsDistinguishable(color1, color2, ColorBlindnessMode.none),
        true,
      );
      
      // May not be distinguishable for certain color blindness types
      final distinguishable = ColorBlindnessHelper.areColorsDistinguishable(
        color1, 
        color2, 
        ColorBlindnessMode.protanopia,
      );
      expect(distinguishable, isA<bool>());
    });

    test('should provide accessible chart colors', () {
      final chartColors = ColorBlindnessHelper.getAccessibleChartColors();
      expect(chartColors.length, greaterThan(0));
      expect(chartColors.first.color, isA<Color>());
      expect(chartColors.first.pattern, isA<String>());
      expect(chartColors.first.icon, isA<IconData>());
      expect(chartColors.first.label, isA<String>());
    });

    test('should get high contrast colors', () {
      const color = Color(0xFF4F46E5);
      
      // Light mode
      final lightContrast = ColorBlindnessHelper.getHighContrastColor(color, false);
      expect(lightContrast, anyOf(Colors.black, Colors.white));
      
      // Dark mode
      final darkContrast = ColorBlindnessHelper.getHighContrastColor(color, true);
      expect(darkContrast, anyOf(Colors.black, Colors.white));
    });
  });

  group('AccessibilitySettings', () {
    test('should create default settings', () {
      final settings = AccessibilitySettings.defaultSettings();
      expect(settings.highContrast, false);
      expect(settings.textScale, 1.0);
      expect(settings.hapticFeedback, true);
    });

    test('should copy with new values', () {
      final original = AccessibilitySettings.defaultSettings();
      final updated = original.copyWith(
        highContrast: true,
        textScale: 1.5,
      );
      
      expect(updated.highContrast, true);
      expect(updated.textScale, 1.5);
      expect(updated.hapticFeedback, original.hapticFeedback); // Unchanged
    });
  });
}