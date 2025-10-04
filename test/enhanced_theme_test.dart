import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:minq/presentation/theme/minq_theme.dart';

void main() {
  group('Enhanced MinqTheme Tests', () {
    testWidgets('Light theme has all emotional colors defined', (tester) async {
      final lightTheme = MinqTheme.light();
      
      // Test emotional colors
      expect(lightTheme.joyAccent, const Color(0xFFFFD700));
      expect(lightTheme.encouragement, const Color(0xFFFF6B6B));
      expect(lightTheme.serenity, const Color(0xFF4ECDC4));
      expect(lightTheme.warmth, const Color(0xFFFFA726));
      
      // Test state colors
      expect(lightTheme.progressActive, const Color(0xFF13B6EC));
      expect(lightTheme.progressComplete, const Color(0xFF10B981));
      expect(lightTheme.progressPending, const Color(0xFF94A3B8));
      
      // Test interaction colors
      expect(lightTheme.tapFeedback, const Color(0xFFE3F2FD));
      expect(lightTheme.hoverState, const Color(0xFFF5F5F5));
    });

    testWidgets('Dark theme has all emotional colors defined', (tester) async {
      final darkTheme = MinqTheme.dark();
      
      // Test emotional colors (adjusted for dark theme)
      expect(darkTheme.joyAccent, const Color(0xFFFFC107));
      expect(darkTheme.encouragement, const Color(0xFFFF8A80));
      expect(darkTheme.serenity, const Color(0xFF80CBC4));
      expect(darkTheme.warmth, const Color(0xFFFFB74D));
      
      // Test state colors
      expect(darkTheme.progressActive, const Color(0xFF38CFFE));
      expect(darkTheme.progressComplete, const Color(0xFF22D3A0));
      expect(darkTheme.progressPending, const Color(0xFF64748B));
    });

    testWidgets('Enhanced spacing system works correctly', (tester) async {
      final theme = MinqTheme.light();
      
      // Test enhanced spacing values
      expect(theme.breathingSpace, 16.0); // base * 4
      expect(theme.intimateSpace, 6.0);   // base * 1.5
      expect(theme.respectfulSpace, 32.0); // base * 8
      expect(theme.dramaticSpace, 48.0);   // base * 12
      
      // Test padding helpers
      expect(theme.breathingPadding, const EdgeInsets.all(16.0));
      expect(theme.intimatePadding, const EdgeInsets.all(6.0));
      expect(theme.respectfulPadding, const EdgeInsets.all(32.0));
      expect(theme.dramaticPadding, const EdgeInsets.all(48.0));
    });

    testWidgets('Emotional typography styles are defined', (tester) async {
      final lightTheme = MinqTheme.light();
      final darkTheme = MinqTheme.dark();
      
      // Test light theme emotional typography
      expect(lightTheme.celebrationText.fontSize, 20);
      expect(lightTheme.celebrationText.fontWeight, FontWeight.w700);
      expect(lightTheme.celebrationText.color, const Color(0xFFFFD700));
      
      expect(lightTheme.encouragementText.fontSize, 16);
      expect(lightTheme.encouragementText.color, const Color(0xFFFF6B6B));
      
      expect(lightTheme.guidanceText.fontSize, 14);
      expect(lightTheme.guidanceText.color, const Color(0xFF4ECDC4));
      
      expect(lightTheme.whisperText.fontSize, 12);
      expect(lightTheme.whisperText.color, const Color(0xFF94A3B8));
      
      // Test dark theme emotional typography
      expect(darkTheme.celebrationText.color, const Color(0xFFFFC107));
      expect(darkTheme.encouragementText.color, const Color(0xFFFF8A80));
      expect(darkTheme.guidanceText.color, const Color(0xFF80CBC4));
      expect(darkTheme.whisperText.color, const Color(0xFF64748B));
    });

    testWidgets('Animation curves are defined', (tester) async {
      final theme = MinqTheme.light();
      
      expect(theme.easeInOutCubic, Curves.easeInOutCubic);
      expect(theme.easeOutBack, Curves.easeOutBack);
      expect(theme.easeInOutQuart, Curves.easeInOutQuart);
      expect(theme.bounceOut, Curves.bounceOut);
    });

    testWidgets('Accessibility colors meet WCAG standards', (tester) async {
      final lightTheme = MinqTheme.light();
      final darkTheme = MinqTheme.dark();
      
      // Test light theme accessibility
      expect(lightTheme.highContrastText, const Color(0xFF000000));
      expect(lightTheme.highContrastBackground, const Color(0xFFFFFFFF));
      
      // Test dark theme accessibility
      expect(darkTheme.highContrastText, const Color(0xFFFFFFFF));
      expect(darkTheme.highContrastBackground, const Color(0xFF000000));
      
      // Test contrast ratio calculations
      final contrastRatio = MinqTheme.calculateContrastRatio(
        lightTheme.highContrastText,
        lightTheme.highContrastBackground,
      );
      expect(contrastRatio, greaterThan(7.0)); // Should meet WCAG AAA
      
      // Test WCAG compliance methods
      expect(lightTheme.meetsWCAGAA(
        lightTheme.textPrimary,
        lightTheme.background,
      ), isTrue,);
      
      expect(lightTheme.meetsWCAGAAA(
        lightTheme.highContrastText,
        lightTheme.highContrastBackground,
      ), isTrue,);
    });

    testWidgets('Error and warning colors are defined', (tester) async {
      final lightTheme = MinqTheme.light();
      final darkTheme = MinqTheme.dark();
      
      // Test light theme error/warning colors
      expect(lightTheme.accentError, const Color(0xFFEF4444));
      expect(lightTheme.accentWarning, const Color(0xFFF59E0B));
      
      // Test dark theme error/warning colors
      expect(darkTheme.accentError, const Color(0xFFFF5252));
      expect(darkTheme.accentWarning, const Color(0xFFFFB74D));
    });

    testWidgets('Theme lerp works with new properties', (tester) async {
      final lightTheme = MinqTheme.light();
      final darkTheme = MinqTheme.dark();
      
      final lerpedTheme = lightTheme.lerp(darkTheme, 0.5);
      
      // Test that lerped theme has interpolated values
      expect(lerpedTheme.joyAccent, isNot(equals(lightTheme.joyAccent)));
      expect(lerpedTheme.joyAccent, isNot(equals(darkTheme.joyAccent)));
      
      // Test spacing lerp
      expect(lerpedTheme.breathingSpace, equals(lightTheme.breathingSpace));
      expect(lerpedTheme.intimateSpace, equals(lightTheme.intimateSpace));
    });

    testWidgets('copyWith works with new properties', (tester) async {
      final originalTheme = MinqTheme.light();
      const customJoyColor = Color(0xFF00FF00);
      
      final copiedTheme = originalTheme.copyWith(
        joyAccent: customJoyColor,
        breathingSpace: 20.0,
      );
      
      expect(copiedTheme.joyAccent, customJoyColor);
      expect(copiedTheme.breathingSpace, 20.0);
      expect(copiedTheme.encouragement, originalTheme.encouragement); // Unchanged
    });

    testWidgets('Minimum touch target size constant is defined', (tester) async {
      expect(MinqTheme.minTouchTargetSize, 44.0);
    });
  });
}