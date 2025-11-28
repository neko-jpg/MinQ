import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Manages haptic feedback across the application with user preferences support
/// and platform-specific optimizations for iOS and Android
class HapticManager {
  static const String _hapticEnabledKey = 'haptic_feedback_enabled';
  static bool _isEnabled = true;
  static bool _isInitialized = false;

  /// Reset the manager state (for testing purposes)
  @visibleForTesting
  static void reset() {
    _isEnabled = true;
    _isInitialized = false;
  }

  /// Initialize the haptic manager with user preferences
  static Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      _isEnabled = prefs.getBool(_hapticEnabledKey) ?? true;
      _isInitialized = true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('HapticManager: Failed to initialize preferences: $e');
      }
      _isEnabled = true;
      _isInitialized = true;
    }
  }

  /// Check if haptic feedback is enabled
  static bool get isEnabled => _isEnabled;

  /// Enable or disable haptic feedback
  static Future<void> setEnabled(bool enabled) async {
    _isEnabled = enabled;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_hapticEnabledKey, enabled);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('HapticManager: Failed to save preference: $e');
      }
    }
  }

  /// Success feedback - for quest completion, achievements, positive actions
  /// Uses light impact on iOS, light vibration on Android
  static Future<void> success() async {
    if (!_isEnabled) return;

    try {
      if (Platform.isIOS) {
        // iOS: Use light impact for subtle success feedback
        await HapticFeedback.lightImpact();
      } else if (Platform.isAndroid) {
        // Android: Use light impact as well, but could be customized
        await HapticFeedback.lightImpact();
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('HapticManager: Success feedback failed: $e');
      }
    }
  }

  /// Warning feedback - for validation errors, cautionary actions
  /// Uses medium impact for noticeable but not alarming feedback
  static Future<void> warning() async {
    if (!_isEnabled) return;

    try {
      if (Platform.isIOS) {
        // iOS: Medium impact for warnings
        await HapticFeedback.mediumImpact();
      } else if (Platform.isAndroid) {
        // Android: Medium impact
        await HapticFeedback.mediumImpact();
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('HapticManager: Warning feedback failed: $e');
      }
    }
  }

  /// Error feedback - for critical errors, failed actions
  /// Uses heavy impact for strong, attention-grabbing feedback
  static Future<void> error() async {
    if (!_isEnabled) return;

    try {
      if (Platform.isIOS) {
        // iOS: Heavy impact for errors
        await HapticFeedback.heavyImpact();
      } else if (Platform.isAndroid) {
        // Android: Heavy impact
        await HapticFeedback.heavyImpact();
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('HapticManager: Error feedback failed: $e');
      }
    }
  }

  /// Selection feedback - for UI element selection, navigation
  /// Uses selection click for subtle interaction confirmation
  static Future<void> selection() async {
    if (!_isEnabled) return;

    try {
      if (Platform.isIOS) {
        // iOS: Selection click for UI interactions
        await HapticFeedback.selectionClick();
      } else if (Platform.isAndroid) {
        // Android: Selection click
        await HapticFeedback.selectionClick();
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('HapticManager: Selection feedback failed: $e');
      }
    }
  }

  /// Achievement feedback - special feedback for major accomplishments
  /// Uses a sequence of impacts to create a celebratory feeling
  static Future<void> achievement() async {
    if (!_isEnabled) return;

    try {
      // Create a celebratory sequence: light -> medium -> light
      await HapticFeedback.lightImpact();
      await Future.delayed(const Duration(milliseconds: 100));
      await HapticFeedback.mediumImpact();
      await Future.delayed(const Duration(milliseconds: 100));
      await HapticFeedback.lightImpact();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('HapticManager: Achievement feedback failed: $e');
      }
    }
  }

  /// Streak feedback - special feedback for maintaining streaks
  /// Uses a quick double-tap pattern
  static Future<void> streak() async {
    if (!_isEnabled) return;

    try {
      await HapticFeedback.lightImpact();
      await Future.delayed(const Duration(milliseconds: 50));
      await HapticFeedback.lightImpact();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('HapticManager: Streak feedback failed: $e');
      }
    }
  }

  /// Level up feedback - for significant progress milestones
  /// Uses a ascending pattern of impacts
  static Future<void> levelUp() async {
    if (!_isEnabled) return;

    try {
      await HapticFeedback.lightImpact();
      await Future.delayed(const Duration(milliseconds: 80));
      await HapticFeedback.mediumImpact();
      await Future.delayed(const Duration(milliseconds: 80));
      await HapticFeedback.heavyImpact();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('HapticManager: Level up feedback failed: $e');
      }
    }
  }

  /// Button press feedback - for button interactions
  /// Uses selection click for immediate response
  static Future<void> buttonPress() async {
    if (!_isEnabled) return;

    try {
      await HapticFeedback.selectionClick();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('HapticManager: Button press feedback failed: $e');
      }
    }
  }

  /// Toggle feedback - for switches, checkboxes, toggles
  /// Uses light impact for toggle actions
  static Future<void> toggle() async {
    if (!_isEnabled) return;

    try {
      await HapticFeedback.lightImpact();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('HapticManager: Toggle feedback failed: $e');
      }
    }
  }
}
