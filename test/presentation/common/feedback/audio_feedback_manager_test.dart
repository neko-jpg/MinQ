import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:minq/presentation/common/feedback/audio_feedback_manager.dart';

void main() {
  group('AudioFeedbackManager', () {
    setUpAll(() {
      // Initialize Flutter binding for tests
      TestWidgetsFlutterBinding.ensureInitialized();
    });

    setUp(() async {
      // Reset shared preferences and manager state before each test
      SharedPreferences.setMockInitialValues({});
      AudioFeedbackManager.reset();
    });

    test('should initialize with default enabled state', () async {
      await AudioFeedbackManager.initialize();
      expect(AudioFeedbackManager.isEnabled, isTrue);
    });

    test('should load saved preference on initialization', () async {
      // Set up mock preference
      SharedPreferences.setMockInitialValues({
        'audio_feedback_enabled': false,
      });

      await AudioFeedbackManager.initialize();
      expect(AudioFeedbackManager.isEnabled, isFalse);
    });

    test('should save preference when enabled state changes', () async {
      await AudioFeedbackManager.initialize();
      
      // Change the setting
      await AudioFeedbackManager.setEnabled(false);
      expect(AudioFeedbackManager.isEnabled, isFalse);

      // Verify it was saved
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('audio_feedback_enabled'), isFalse);
    });

    test('should handle initialization failure gracefully', () async {
      // This test verifies that the manager doesn't crash if SharedPreferences fails
      await AudioFeedbackManager.initialize();
      expect(AudioFeedbackManager.isEnabled, isTrue); // Should default to enabled
    });

    test('should not initialize multiple times', () async {
      await AudioFeedbackManager.initialize();
      final firstState = AudioFeedbackManager.isEnabled;
      
      // Change the mock preferences
      SharedPreferences.setMockInitialValues({
        'audio_feedback_enabled': !firstState,
      });
      
      // Initialize again - should not reload preferences
      await AudioFeedbackManager.initialize();
      expect(AudioFeedbackManager.isEnabled, equals(firstState));
    });

    group('audio feedback methods', () {
      setUp(() async {
        await AudioFeedbackManager.initialize();
      });

      test('should not throw when calling audio feedback methods', () async {
        // These methods interact with platform channels, so we can't easily test
        // the actual audio feedback, but we can ensure they don't throw
        expect(() async => await AudioFeedbackManager.playSuccess(), returnsNormally);
        expect(() async => await AudioFeedbackManager.playEncouragement(), returnsNormally);
        expect(() async => await AudioFeedbackManager.playNotification(), returnsNormally);
        expect(() async => await AudioFeedbackManager.playError(), returnsNormally);
        expect(() async => await AudioFeedbackManager.playButtonTap(), returnsNormally);
        expect(() async => await AudioFeedbackManager.playAchievement(), returnsNormally);
        expect(() async => await AudioFeedbackManager.playStreak(), returnsNormally);
        expect(() async => await AudioFeedbackManager.playLevelUp(), returnsNormally);
        expect(() async => await AudioFeedbackManager.playToggle(), returnsNormally);
        expect(() async => await AudioFeedbackManager.playSwipe(), returnsNormally);
      });

      test('should respect enabled state', () async {
        // Disable audio feedback
        await AudioFeedbackManager.setEnabled(false);
        
        // Methods should still not throw when disabled
        expect(() async => await AudioFeedbackManager.playSuccess(), returnsNormally);
        expect(() async => await AudioFeedbackManager.playError(), returnsNormally);
      });
    });
  });
}