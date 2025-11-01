import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:minq/core/accessibility/accessibility_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Provider for SharedPreferences
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences provider must be overridden');
});

/// Provider for AccessibilityService
final accessibilityServiceProvider =
    StateNotifierProvider<AccessibilityService, AccessibilitySettings>((ref) {
      final prefs = ref.watch(sharedPreferencesProvider);
      return AccessibilityService(prefs);
    });

/// Provider for high contrast mode
final highContrastProvider = Provider<bool>((ref) {
  return ref.watch(
    accessibilityServiceProvider.select((settings) => settings.highContrast),
  );
});

/// Provider for large text mode
final largeTextProvider = Provider<bool>((ref) {
  return ref.watch(
    accessibilityServiceProvider.select((settings) => settings.largeText),
  );
});

/// Provider for bold text mode
final boldTextProvider = Provider<bool>((ref) {
  return ref.watch(
    accessibilityServiceProvider.select((settings) => settings.boldText),
  );
});

/// Provider for reduce motion mode
final reduceMotionProvider = Provider<bool>((ref) {
  return ref.watch(
    accessibilityServiceProvider.select((settings) => settings.reduceMotion),
  );
});

/// Provider for text scale factor
final textScaleProvider = Provider<double>((ref) {
  return ref.watch(
    accessibilityServiceProvider.select((settings) => settings.textScale),
  );
});

/// Provider for button scale factor
final buttonScaleProvider = Provider<double>((ref) {
  return ref.watch(
    accessibilityServiceProvider.select((settings) => settings.buttonScale),
  );
});

/// Provider for screen reader optimization
final screenReaderOptimizedProvider = Provider<bool>((ref) {
  return ref.watch(
    accessibilityServiceProvider.select(
      (settings) => settings.screenReaderOptimized,
    ),
  );
});

/// Provider for haptic feedback
final hapticFeedbackProvider = Provider<bool>((ref) {
  return ref.watch(
    accessibilityServiceProvider.select((settings) => settings.hapticFeedback),
  );
});

/// Provider for sound feedback
final soundFeedbackProvider = Provider<bool>((ref) {
  return ref.watch(
    accessibilityServiceProvider.select((settings) => settings.soundFeedback),
  );
});

/// Provider for color blindness mode
final colorBlindnessModeProvider = Provider<ColorBlindnessMode>((ref) {
  return ref.watch(
    accessibilityServiceProvider.select(
      (settings) => settings.colorBlindnessMode,
    ),
  );
});

/// Provider for keyboard navigation
final keyboardNavigationProvider = Provider<bool>((ref) {
  return ref.watch(
    accessibilityServiceProvider.select(
      (settings) => settings.keyboardNavigation,
    ),
  );
});

/// Provider for focus indicator
final focusIndicatorProvider = Provider<bool>((ref) {
  return ref.watch(
    accessibilityServiceProvider.select((settings) => settings.focusIndicator),
  );
});

/// Provider for checking if any accessibility features are enabled
final hasAccessibilityFeaturesProvider = Provider<bool>((ref) {
  final settings = ref.watch(accessibilityServiceProvider);
  return settings.highContrast ||
      settings.largeText ||
      settings.boldText ||
      settings.reduceMotion ||
      settings.textScale != 1.0 ||
      settings.buttonScale != 1.0 ||
      settings.screenReaderOptimized ||
      settings.colorBlindnessMode != ColorBlindnessMode.none ||
      settings.keyboardNavigation;
});

/// Provider for accessibility summary text
final accessibilitySummaryProvider = Provider<String>((ref) {
  final settings = ref.watch(accessibilityServiceProvider);
  final features = <String>[];

  if (settings.highContrast) features.add('High Contrast');
  if (settings.largeText) features.add('Large Text');
  if (settings.boldText) features.add('Bold Text');
  if (settings.reduceMotion) features.add('Reduced Motion');
  if (settings.textScale != 1.0)
    features.add('Text Scale: ${(settings.textScale * 100).round()}%');
  if (settings.buttonScale != 1.0)
    features.add('Button Scale: ${(settings.buttonScale * 100).round()}%');
  if (settings.screenReaderOptimized) features.add('Screen Reader Optimized');
  if (settings.colorBlindnessMode != ColorBlindnessMode.none) {
    features.add('Color Blindness: ${settings.colorBlindnessMode.name}');
  }
  if (settings.keyboardNavigation) features.add('Keyboard Navigation');

  if (features.isEmpty) {
    return 'No accessibility features enabled';
  }

  return 'Enabled: ${features.join(', ')}';
});

/// Provider for effective animation duration based on reduce motion setting
final effectiveAnimationDurationProvider = Provider.family<Duration, Duration>((
  ref,
  baseDuration,
) {
  final reduceMotion = ref.watch(reduceMotionProvider);
  return reduceMotion ? Duration.zero : baseDuration;
});

/// Provider for checking if screen reader is likely active
final screenReaderActiveProvider = FutureProvider<bool>((ref) async {
  return await AccessibilityService.isScreenReaderEnabled();
});
