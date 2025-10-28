import 'package:minq/data/logging/minq_logger.dart';
import 'package:minq/presentation/common/feedback/audio_feedback_manager.dart';
import 'package:minq/presentation/common/feedback/haptic_manager.dart';

/// Unified feedback manager that coordinates haptic and audio feedback
/// Provides convenient methods for common interaction patterns
class FeedbackManager {
  static bool _isInitialized = false;

  /// Initialize both haptic and audio feedback managers
  static Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      await Future.wait([
        HapticManager.initialize(),
        AudioFeedbackManager.initialize(),
      ]);
      _isInitialized = true;
    } catch (e) {
      MinqLogger.warn(
        'FeedbackManager: Initialization failed',
        metadata: {'error': e.toString()},
      );
    }
  }

  /// Quest completion feedback - combines success haptic and audio
  static Future<void> questCompleted() async {
    await Future.wait([
      HapticManager.success(),
      AudioFeedbackManager.playSuccess(),
    ]);
  }

  /// Achievement unlocked feedback - celebratory combination
  static Future<void> achievementUnlocked() async {
    await Future.wait([
      HapticManager.achievement(),
      AudioFeedbackManager.playAchievement(),
    ]);
  }

  /// Streak maintained feedback - encouraging combination
  static Future<void> streakMaintained() async {
    await Future.wait([
      HapticManager.streak(),
      AudioFeedbackManager.playStreak(),
    ]);
  }

  /// Level up feedback - major milestone celebration
  static Future<void> levelUp() async {
    await Future.wait([
      HapticManager.levelUp(),
      AudioFeedbackManager.playLevelUp(),
    ]);
  }

  /// Button press feedback - immediate UI response
  static Future<void> buttonPressed() async {
    await Future.wait([
      HapticManager.buttonPress(),
      AudioFeedbackManager.playButtonTap(),
    ]);
  }

  /// Toggle feedback - for checkboxes, switches
  static Future<void> toggled() async {
    await Future.wait([
      HapticManager.toggle(),
      AudioFeedbackManager.playToggle(),
    ]);
  }

  /// Error feedback - for validation errors
  static Future<void> error() async {
    await Future.wait([
      HapticManager.error(),
      AudioFeedbackManager.playError(),
    ]);
  }

  /// Warning feedback - for cautionary actions
  static Future<void> warning() async {
    await Future.wait([
      HapticManager.warning(),
      AudioFeedbackManager.playNotification(),
    ]);
  }

  /// Selection feedback - for navigation and selection
  static Future<void> selected() async {
    await Future.wait([
      HapticManager.selection(),
      AudioFeedbackManager.playButtonTap(),
    ]);
  }

  /// Swipe feedback - for gesture interactions
  static Future<void> swiped() async {
    await Future.wait([
      HapticManager.selection(),
      AudioFeedbackManager.playSwipe(),
    ]);
  }

  /// Enable or disable haptic feedback
  static Future<void> setHapticEnabled(bool enabled) async {
    await HapticManager.setEnabled(enabled);
  }

  /// Enable or disable audio feedback
  static Future<void> setAudioEnabled(bool enabled) async {
    await AudioFeedbackManager.setEnabled(enabled);
  }

  /// Check if haptic feedback is enabled
  static bool get isHapticEnabled => HapticManager.isEnabled;

  /// Check if audio feedback is enabled
  static bool get isAudioEnabled => AudioFeedbackManager.isEnabled;
}
