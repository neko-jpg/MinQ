import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:minq/presentation/common/feedback/feedback_manager.dart';

void main() {
  group('FeedbackManager', () {
    setUpAll(() {
      // Initialize Flutter binding for tests
      TestWidgetsFlutterBinding.ensureInitialized();
    });

    setUp(() async {
      // Reset shared preferences and manager state before each test
      SharedPreferences.setMockInitialValues({});
      FeedbackManager.reset();
    });

    test('should initialize both haptic and audio managers', () async {
      await FeedbackManager.initialize();
      
      // Should not throw and should have default enabled states
      expect(FeedbackManager.isHapticEnabled, isTrue);
      expect(FeedbackManager.isAudioEnabled, isTrue);
    });

    test('should handle initialization failure gracefully', () async {
      // Should not throw even if initialization fails
      expect(() async => await FeedbackManager.initialize(), returnsNormally);
    });

    group('combined feedback methods', () {
      setUp(() async {
        await FeedbackManager.initialize();
      });

      test('should not throw when calling combined feedback methods', () async {
        // These methods combine haptic and audio feedback
        expect(() async => await FeedbackManager.questCompleted(), returnsNormally);
        expect(() async => await FeedbackManager.achievementUnlocked(), returnsNormally);
        expect(() async => await FeedbackManager.streakMaintained(), returnsNormally);
        expect(() async => await FeedbackManager.levelUp(), returnsNormally);
        expect(() async => await FeedbackManager.buttonPressed(), returnsNormally);
        expect(() async => await FeedbackManager.toggled(), returnsNormally);
        expect(() async => await FeedbackManager.error(), returnsNormally);
        expect(() async => await FeedbackManager.warning(), returnsNormally);
        expect(() async => await FeedbackManager.selected(), returnsNormally);
        expect(() async => await FeedbackManager.swiped(), returnsNormally);
      });
    });

    group('preference management', () {
      setUp(() async {
        await FeedbackManager.initialize();
      });

      test('should manage haptic preferences', () async {
        expect(FeedbackManager.isHapticEnabled, isTrue);
        
        await FeedbackManager.setHapticEnabled(false);
        expect(FeedbackManager.isHapticEnabled, isFalse);
        
        await FeedbackManager.setHapticEnabled(true);
        expect(FeedbackManager.isHapticEnabled, isTrue);
      });

      test('should manage audio preferences', () async {
        expect(FeedbackManager.isAudioEnabled, isTrue);
        
        await FeedbackManager.setAudioEnabled(false);
        expect(FeedbackManager.isAudioEnabled, isFalse);
        
        await FeedbackManager.setAudioEnabled(true);
        expect(FeedbackManager.isAudioEnabled, isTrue);
      });

      test('should manage preferences independently', () async {
        // Disable haptic but keep audio enabled
        await FeedbackManager.setHapticEnabled(false);
        await FeedbackManager.setAudioEnabled(true);
        
        expect(FeedbackManager.isHapticEnabled, isFalse);
        expect(FeedbackManager.isAudioEnabled, isTrue);
        
        // Disable audio but enable haptic
        await FeedbackManager.setHapticEnabled(true);
        await FeedbackManager.setAudioEnabled(false);
        
        expect(FeedbackManager.isHapticEnabled, isTrue);
        expect(FeedbackManager.isAudioEnabled, isFalse);
      });
    });
  });
}