import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:minq/data/logging/minq_logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Manages audio feedback across the application with user preferences support
/// and platform-specific optimizations for iOS and Android
class AudioFeedbackManager {
  static const String _audioEnabledKey = 'audio_feedback_enabled';
  static bool _isEnabled = true;
  static bool _isInitialized = false;

  /// Reset the manager state (for testing purposes)
  @visibleForTesting
  static void reset() {
    _isEnabled = true;
    _isInitialized = false;
  }

  /// Initialize the audio feedback manager with user preferences
  static Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      _isEnabled = prefs.getBool(_audioEnabledKey) ?? true;
      _isInitialized = true;
    } catch (e) {
      MinqLogger.warn(
        'AudioFeedbackManager: Failed to initialize preferences',
        metadata: {'error': e.toString()},
      );
      _isEnabled = true;
      _isInitialized = true;
    }
  }

  /// Check if audio feedback is enabled
  static bool get isEnabled => _isEnabled;

  /// Enable or disable audio feedback
  static Future<void> setEnabled(bool enabled) async {
    _isEnabled = enabled;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_audioEnabledKey, enabled);
    } catch (e) {
      MinqLogger.warn(
        'AudioFeedbackManager: Failed to save preference',
        metadata: {'error': e.toString()},
      );
    }
  }

  /// Play success sound - for quest completion, achievements
  /// Uses system success sound or custom sound if available
  static Future<void> playSuccess() async {
    if (!_isEnabled) return;

    try {
      // Use system click sound as a placeholder
      // In a real implementation, you might want to use a package like audioplayers
      // to play custom success sounds
      await SystemSound.play(SystemSoundType.click);
    } catch (e) {
      MinqLogger.warn(
        'AudioFeedbackManager: Success sound failed',
        metadata: {'error': e.toString()},
      );
    }
  }

  /// Play encouragement sound - for motivational moments
  /// Uses a gentle, uplifting sound
  static Future<void> playEncouragement() async {
    if (!_isEnabled) return;

    try {
      // Use system click sound as a placeholder
      // In production, this would be a custom encouraging sound
      await SystemSound.play(SystemSoundType.click);
    } catch (e) {
      MinqLogger.warn(
        'AudioFeedbackManager: Encouragement sound failed',
        metadata: {'error': e.toString()},
      );
    }
  }

  /// Play notification sound - for alerts and reminders
  /// Uses system alert sound
  static Future<void> playNotification() async {
    if (!_isEnabled) return;

    try {
      await SystemSound.play(SystemSoundType.alert);
    } catch (e) {
      MinqLogger.warn(
        'AudioFeedbackManager: Notification sound failed',
        metadata: {'error': e.toString()},
      );
    }
  }

  /// Play error sound - for validation errors and failures
  /// Uses system alert sound with different context
  static Future<void> playError() async {
    if (!_isEnabled) return;

    try {
      await SystemSound.play(SystemSoundType.alert);
    } catch (e) {
      MinqLogger.warn(
        'AudioFeedbackManager: Error sound failed',
        metadata: {'error': e.toString()},
      );
    }
  }

  /// Play button tap sound - for UI interactions
  /// Uses system click sound
  static Future<void> playButtonTap() async {
    if (!_isEnabled) return;

    try {
      await SystemSound.play(SystemSoundType.click);
    } catch (e) {
      MinqLogger.warn(
        'AudioFeedbackManager: Button tap sound failed',
        metadata: {'error': e.toString()},
      );
    }
  }

  /// Play achievement sound - for major accomplishments
  /// Uses a celebratory sound sequence
  static Future<void> playAchievement() async {
    if (!_isEnabled) return;

    try {
      // Play a sequence of clicks to simulate celebration
      await SystemSound.play(SystemSoundType.click);
      await Future.delayed(const Duration(milliseconds: 100));
      await SystemSound.play(SystemSoundType.click);
      await Future.delayed(const Duration(milliseconds: 100));
      await SystemSound.play(SystemSoundType.click);
    } catch (e) {
      MinqLogger.warn(
        'AudioFeedbackManager: Achievement sound failed',
        metadata: {'error': e.toString()},
      );
    }
  }

  /// Play streak sound - for maintaining streaks
  /// Uses a quick double-click pattern
  static Future<void> playStreak() async {
    if (!_isEnabled) return;

    try {
      await SystemSound.play(SystemSoundType.click);
      await Future.delayed(const Duration(milliseconds: 50));
      await SystemSound.play(SystemSoundType.click);
    } catch (e) {
      MinqLogger.warn(
        'AudioFeedbackManager: Streak sound failed',
        metadata: {'error': e.toString()},
      );
    }
  }

  /// Play level up sound - for significant progress milestones
  /// Uses an ascending pattern of sounds
  static Future<void> playLevelUp() async {
    if (!_isEnabled) return;

    try {
      // Simulate ascending tones with clicks at different intervals
      await SystemSound.play(SystemSoundType.click);
      await Future.delayed(const Duration(milliseconds: 120));
      await SystemSound.play(SystemSoundType.click);
      await Future.delayed(const Duration(milliseconds: 100));
      await SystemSound.play(SystemSoundType.click);
    } catch (e) {
      MinqLogger.warn(
        'AudioFeedbackManager: Level up sound failed',
        metadata: {'error': e.toString()},
      );
    }
  }

  /// Play toggle sound - for switches, checkboxes
  /// Uses a subtle click sound
  static Future<void> playToggle() async {
    if (!_isEnabled) return;

    try {
      await SystemSound.play(SystemSoundType.click);
    } catch (e) {
      MinqLogger.warn(
        'AudioFeedbackManager: Toggle sound failed',
        metadata: {'error': e.toString()},
      );
    }
  }

  /// Play swipe sound - for navigation gestures
  /// Uses a subtle sound for gesture feedback
  static Future<void> playSwipe() async {
    if (!_isEnabled) return;

    try {
      await SystemSound.play(SystemSoundType.click);
    } catch (e) {
      MinqLogger.warn(
        'AudioFeedbackManager: Swipe sound failed',
        metadata: {'error': e.toString()},
      );
    }
  }
}
