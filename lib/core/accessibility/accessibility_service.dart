import 'package:flutter/material.dart';
import 'package:flutter/services.dart' as services;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Comprehensive accessibility service that manages all accessibility features
/// including screen reader support, high contrast mode, font scaling, and more.
class AccessibilityService extends StateNotifier<AccessibilitySettings> {
  AccessibilityService(this._prefs) : super(AccessibilitySettings.defaultSettings()) {
    _loadSettings();
  }

  final SharedPreferences _prefs;
  
  static AccessibilityService? _instance;
  
  /// Get the singleton instance of AccessibilityService
  static AccessibilityService get instance {
    if (_instance == null) {
      throw StateError('AccessibilityService not initialized. Call initialize() first.');
    }
    return _instance!;
  }
  
  /// Initialize the AccessibilityService singleton
  static Future<void> initialize(SharedPreferences prefs) async {
    _instance = AccessibilityService(prefs);
  }

  static const String _keyHighContrast = 'accessibility_high_contrast';
  static const String _keyLargeText = 'accessibility_large_text';
  static const String _keyBoldText = 'accessibility_bold_text';
  static const String _keyReduceMotion = 'accessibility_reduce_motion';
  static const String _keyTextScale = 'accessibility_text_scale';
  static const String _keyButtonScale = 'accessibility_button_scale';
  static const String _keyScreenReaderOptimized = 'accessibility_screen_reader_optimized';
  static const String _keyHapticFeedback = 'accessibility_haptic_feedback';
  static const String _keySoundFeedback = 'accessibility_sound_feedback';
  static const String _keyColorBlindnessMode = 'accessibility_color_blindness_mode';
  static const String _keyKeyboardNavigation = 'accessibility_keyboard_navigation';
  static const String _keyFocusIndicator = 'accessibility_focus_indicator';

  /// Load accessibility settings from SharedPreferences
  Future<void> _loadSettings() async {
    final settings = AccessibilitySettings(
      highContrast: _prefs.getBool(_keyHighContrast) ?? false,
      largeText: _prefs.getBool(_keyLargeText) ?? false,
      boldText: _prefs.getBool(_keyBoldText) ?? false,
      reduceMotion: _prefs.getBool(_keyReduceMotion) ?? false,
      textScale: _prefs.getDouble(_keyTextScale) ?? 1.0,
      buttonScale: _prefs.getDouble(_keyButtonScale) ?? 1.0,
      screenReaderOptimized: _prefs.getBool(_keyScreenReaderOptimized) ?? false,
      hapticFeedback: _prefs.getBool(_keyHapticFeedback) ?? true,
      soundFeedback: _prefs.getBool(_keySoundFeedback) ?? true,
      colorBlindnessMode: ColorBlindnessMode.values[
        _prefs.getInt(_keyColorBlindnessMode) ?? 0
      ],
      keyboardNavigation: _prefs.getBool(_keyKeyboardNavigation) ?? false,
      focusIndicator: _prefs.getBool(_keyFocusIndicator) ?? true,
    );
    
    state = settings;
  }

  /// Update high contrast mode
  Future<void> setHighContrast(bool enabled) async {
    await _prefs.setBool(_keyHighContrast, enabled);
    state = state.copyWith(highContrast: enabled);
    
    if (enabled) {
      services.HapticFeedback.lightImpact();
    }
  }

  /// Update large text setting
  Future<void> setLargeText(bool enabled) async {
    await _prefs.setBool(_keyLargeText, enabled);
    state = state.copyWith(largeText: enabled);
    
    if (state.hapticFeedback) {
      services.HapticFeedback.lightImpact();
    }
  }

  /// Update bold text setting
  Future<void> setBoldText(bool enabled) async {
    await _prefs.setBool(_keyBoldText, enabled);
    state = state.copyWith(boldText: enabled);
    
    if (state.hapticFeedback) {
      services.HapticFeedback.lightImpact();
    }
  }

  /// Update reduce motion setting
  Future<void> setReduceMotion(bool enabled) async {
    await _prefs.setBool(_keyReduceMotion, enabled);
    state = state.copyWith(reduceMotion: enabled);
    
    if (state.hapticFeedback) {
      services.HapticFeedback.lightImpact();
    }
  }

  /// Update text scale factor
  Future<void> setTextScale(double scale) async {
    await _prefs.setDouble(_keyTextScale, scale);
    state = state.copyWith(textScale: scale);
  }

  /// Update button scale factor
  Future<void> setButtonScale(double scale) async {
    await _prefs.setDouble(_keyButtonScale, scale);
    state = state.copyWith(buttonScale: scale);
  }

  /// Update screen reader optimization
  Future<void> setScreenReaderOptimized(bool enabled) async {
    await _prefs.setBool(_keyScreenReaderOptimized, enabled);
    state = state.copyWith(screenReaderOptimized: enabled);
    
    if (state.hapticFeedback) {
      services.HapticFeedback.lightImpact();
    }
  }

  /// Update haptic feedback setting
  Future<void> setHapticFeedback(bool enabled) async {
    await _prefs.setBool(_keyHapticFeedback, enabled);
    state = state.copyWith(hapticFeedback: enabled);
    
    if (enabled) {
      services.HapticFeedback.lightImpact();
    }
  }

  /// Update sound feedback setting
  Future<void> setSoundFeedback(bool enabled) async {
    await _prefs.setBool(_keySoundFeedback, enabled);
    state = state.copyWith(soundFeedback: enabled);
    
    if (state.hapticFeedback) {
      services.HapticFeedback.lightImpact();
    }
  }

  /// Update color blindness mode
  Future<void> setColorBlindnessMode(ColorBlindnessMode mode) async {
    await _prefs.setInt(_keyColorBlindnessMode, mode.index);
    state = state.copyWith(colorBlindnessMode: mode);
    
    if (state.hapticFeedback) {
      services.HapticFeedback.lightImpact();
    }
  }

  /// Update keyboard navigation setting
  Future<void> setKeyboardNavigation(bool enabled) async {
    await _prefs.setBool(_keyKeyboardNavigation, enabled);
    state = state.copyWith(keyboardNavigation: enabled);
    
    if (state.hapticFeedback) {
      services.HapticFeedback.lightImpact();
    }
  }

  /// Update focus indicator setting
  Future<void> setFocusIndicator(bool enabled) async {
    await _prefs.setBool(_keyFocusIndicator, enabled);
    state = state.copyWith(focusIndicator: enabled);
    
    if (state.hapticFeedback) {
      services.HapticFeedback.lightImpact();
    }
  }

  /// Check if device has screen reader enabled
  static Future<bool> isScreenReaderEnabled() async {
    try {
      // This is a simplified check - in a real app you'd use platform channels
      // to check for TalkBack (Android) or VoiceOver (iOS)
      return false; // Placeholder
    } catch (e) {
      return false;
    }
  }

  /// Get effective text scale considering both user setting and system setting
  double getEffectiveTextScale(BuildContext context) {
    final systemScale = MediaQuery.of(context).textScaler.scale(1.0);
    final userScale = state.textScale;
    
    // Combine system and user scales, but cap at reasonable maximum
    return (systemScale * userScale).clamp(0.5, 3.0);
  }

  /// Get effective animation duration considering reduce motion setting
  Duration getEffectiveAnimationDuration(Duration baseDuration) {
    if (state.reduceMotion) {
      return Duration.zero;
    }
    return baseDuration;
  }

  /// Provide haptic feedback if enabled
  void provideHapticFeedback([HapticFeedbackType? feedback]) {
    if (state.hapticFeedback) {
      switch (feedback) {
        case HapticFeedbackType.lightImpact:
          services.HapticFeedback.lightImpact();
          break;
        case HapticFeedbackType.mediumImpact:
          services.HapticFeedback.mediumImpact();
          break;
        case HapticFeedbackType.heavyImpact:
          services.HapticFeedback.heavyImpact();
          break;
        case HapticFeedbackType.selectionClick:
          services.HapticFeedback.selectionClick();
          break;
        default:
          services.HapticFeedback.lightImpact();
      }
    }
  }
}

/// Accessibility settings data class
class AccessibilitySettings {
  const AccessibilitySettings({
    required this.highContrast,
    required this.largeText,
    required this.boldText,
    required this.reduceMotion,
    required this.textScale,
    required this.buttonScale,
    required this.screenReaderOptimized,
    required this.hapticFeedback,
    required this.soundFeedback,
    required this.colorBlindnessMode,
    required this.keyboardNavigation,
    required this.focusIndicator,
  });

  final bool highContrast;
  final bool largeText;
  final bool boldText;
  final bool reduceMotion;
  final double textScale;
  final double buttonScale;
  final bool screenReaderOptimized;
  final bool hapticFeedback;
  final bool soundFeedback;
  final ColorBlindnessMode colorBlindnessMode;
  final bool keyboardNavigation;
  final bool focusIndicator;

  static AccessibilitySettings defaultSettings() {
    return const AccessibilitySettings(
      highContrast: false,
      largeText: false,
      boldText: false,
      reduceMotion: false,
      textScale: 1.0,
      buttonScale: 1.0,
      screenReaderOptimized: false,
      hapticFeedback: true,
      soundFeedback: true,
      colorBlindnessMode: ColorBlindnessMode.none,
      keyboardNavigation: false,
      focusIndicator: true,
    );
  }

  AccessibilitySettings copyWith({
    bool? highContrast,
    bool? largeText,
    bool? boldText,
    bool? reduceMotion,
    double? textScale,
    double? buttonScale,
    bool? screenReaderOptimized,
    bool? hapticFeedback,
    bool? soundFeedback,
    ColorBlindnessMode? colorBlindnessMode,
    bool? keyboardNavigation,
    bool? focusIndicator,
  }) {
    return AccessibilitySettings(
      highContrast: highContrast ?? this.highContrast,
      largeText: largeText ?? this.largeText,
      boldText: boldText ?? this.boldText,
      reduceMotion: reduceMotion ?? this.reduceMotion,
      textScale: textScale ?? this.textScale,
      buttonScale: buttonScale ?? this.buttonScale,
      screenReaderOptimized: screenReaderOptimized ?? this.screenReaderOptimized,
      hapticFeedback: hapticFeedback ?? this.hapticFeedback,
      soundFeedback: soundFeedback ?? this.soundFeedback,
      colorBlindnessMode: colorBlindnessMode ?? this.colorBlindnessMode,
      keyboardNavigation: keyboardNavigation ?? this.keyboardNavigation,
      focusIndicator: focusIndicator ?? this.focusIndicator,
    );
  }
}

/// Color blindness support modes
enum ColorBlindnessMode {
  none,
  protanopia,    // Red-blind
  deuteranopia,  // Green-blind
  tritanopia,    // Blue-blind
  monochromacy,  // Complete color blindness
}

/// Haptic feedback types
enum HapticFeedbackType {
  lightImpact,
  mediumImpact,
  heavyImpact,
  selectionClick,
}

/// Provider for accessibility service
final accessibilityServiceProvider = StateNotifierProvider<AccessibilityService, AccessibilitySettings>((ref) {
  throw UnimplementedError('AccessibilityService provider must be overridden');
});