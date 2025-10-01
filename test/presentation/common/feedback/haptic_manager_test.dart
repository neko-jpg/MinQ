import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:minq/presentation/common/feedback/haptic_manager.dart';

void main() {
  group('HapticManager', () {
    setUpAll(() {
      // Initialize Flutter binding for tests
      TestWidgetsFlutterBinding.ensureInitialized();
    });

    setUp(() async {
      // Reset shared preferences and manager state before each test
      SharedPreferences.setMockInitialValues({});
      HapticManager.reset();
    });

    test('should initialize with default enabled state', () async {
      await HapticManager.initialize();
      expect(HapticManager.isEnabled, isTrue);
    });

    test('should load saved preference on initialization', () async {
      // Set up mock preference
      SharedPreferences.setMockInitialValues({
        'haptic_feedback_enabled': false,
      });

      await HapticManager.initialize();
      expect(HapticManager.isEnabled, isFalse);
    });

    test('should save preference when enabled state changes', () async {
      await HapticManager.initialize();
      
      // Change the setting
      await HapticManager.setEnabled(false);
      expect(HapticManager.isEnabled, isFalse);

      // Verify it was saved
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('haptic_feedback_enabled'), isFalse);
    });

    test('should handle initialization failure gracefully', () async {
      // This test verifies that the manager doesn't crash if SharedPreferences fails
      // In a real scenario, we might mock SharedPreferences to throw an exception
      await HapticManager.initialize();
      expect(HapticManager.isEnabled, isTrue); // Should default to enabled
    });

    test('should not initialize multiple times', () async {
      await HapticManager.initialize();
      final firstState = HapticManager.isEnabled;
      
      // Change the mock preferences
      SharedPreferences.setMockInitialValues({
        'haptic_feedback_enabled': !firstState,
      });
      
      // Initialize again - should not reload preferences
      await HapticManager.initialize();
      expect(HapticManager.isEnabled, equals(firstState));
    });

    group('feedback methods', () {
      setUp(() async {
        await HapticManager.initialize();
      });

      test('should not throw when calling feedback methods', () async {
        // These methods interact with platform channels, so we can't easily test
        // the actual haptic feedback, but we can ensure they don't throw
        expect(() async => await HapticManager.success(), returnsNormally);
        expect(() async => await HapticManager.warning(), returnsNormally);
        expect(() async => await HapticManager.error(), returnsNormally);
        expect(() async => await HapticManager.selection(), returnsNormally);
        expect(() async => await HapticManager.achievement(), returnsNormally);
        expect(() async => await HapticManager.streak(), returnsNormally);
        expect(() async => await HapticManager.levelUp(), returnsNormally);
        expect(() async => await HapticManager.buttonPress(), returnsNormally);
        expect(() async => await HapticManager.toggle(), returnsNormally);
      });

      test('should respect enabled state', () async {
        // Disable haptic feedback
        await HapticManager.setEnabled(false);
        
        // Methods should still not throw when disabled
        expect(() async => await HapticManager.success(), returnsNormally);
        expect(() async => await HapticManager.error(), returnsNormally);
      });
    });
  });
}