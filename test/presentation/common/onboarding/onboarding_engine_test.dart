import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:minq/presentation/common/onboarding/onboarding_engine.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('OnboardingEngine', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    group('Onboarding Completion', () {
      test('should return false for hasCompletedOnboarding initially', () async {
        final result = await OnboardingEngine.hasCompletedOnboarding();
        expect(result, false);
      });

      test('should return true after marking onboarding as completed', () async {
        await OnboardingEngine.markOnboardingCompleted();
        final result = await OnboardingEngine.hasCompletedOnboarding();
        expect(result, true);
      });
    });

    group('Tooltip Management', () {
      test('should return false for hasSeenTooltip initially', () async {
        const tooltipId = 'test_tooltip';
        final result = await OnboardingEngine.hasSeenTooltip(tooltipId);
        expect(result, false);
      });

      test('should return true after marking tooltip as seen', () async {
        const tooltipId = 'test_tooltip';
        await OnboardingEngine.markTooltipSeen(tooltipId);
        final result = await OnboardingEngine.hasSeenTooltip(tooltipId);
        expect(result, true);
      });

      test('should handle multiple tooltips correctly', () async {
        const tooltip1 = 'tooltip_1';
        const tooltip2 = 'tooltip_2';

        await OnboardingEngine.markTooltipSeen(tooltip1);
        
        expect(await OnboardingEngine.hasSeenTooltip(tooltip1), true);
        expect(await OnboardingEngine.hasSeenTooltip(tooltip2), false);

        await OnboardingEngine.markTooltipSeen(tooltip2);
        
        expect(await OnboardingEngine.hasSeenTooltip(tooltip1), true);
        expect(await OnboardingEngine.hasSeenTooltip(tooltip2), true);
      });

      test('should not duplicate tooltip IDs', () async {
        const tooltipId = 'duplicate_test';
        
        await OnboardingEngine.markTooltipSeen(tooltipId);
        await OnboardingEngine.markTooltipSeen(tooltipId);
        
        final prefs = await SharedPreferences.getInstance();
        final viewedTooltips = prefs.getStringList('onboarding_viewed_tooltips') ?? [];
        
        expect(viewedTooltips.where((id) => id == tooltipId).length, 1);
      });
    });

    group('Step Management', () {
      test('should return 0 for getCurrentStep initially', () async {
        final result = await OnboardingEngine.getCurrentStep();
        expect(result, 0);
      });

      test('should update and retrieve step correctly', () async {
        const step = 3;
        await OnboardingEngine.updateStep(step);
        final result = await OnboardingEngine.getCurrentStep();
        expect(result, step);
      });
    });

    group('Progressive Hints', () {
      test('should handle UserProgress with no quests', () async {
        const progress = UserProgress(
          totalQuests: 0,
          completedQuests: 0,
          currentStreak: 0,
          bestStreak: 0,
        );

        // This should not throw an exception
        await OnboardingEngine.showProgressiveHint(progress);
      });

      test('should handle UserProgress with completed quests', () async {
        const progress = UserProgress(
          totalQuests: 5,
          completedQuests: 3,
          currentStreak: 2,
          bestStreak: 5,
        );

        // This should not throw an exception
        await OnboardingEngine.showProgressiveHint(progress);
      });

      test('should handle UserProgress with streak', () async {
        const progress = UserProgress(
          totalQuests: 10,
          completedQuests: 8,
          currentStreak: 5,
          bestStreak: 7,
        );

        // This should not throw an exception
        await OnboardingEngine.showProgressiveHint(progress);
      });
    });
  });

  group('UserProgress', () {
    test('should create UserProgress with correct values', () {
      const progress = UserProgress(
        totalQuests: 10,
        completedQuests: 7,
        currentStreak: 3,
        bestStreak: 5,
      );

      expect(progress.totalQuests, 10);
      expect(progress.completedQuests, 7);
      expect(progress.currentStreak, 3);
      expect(progress.bestStreak, 5);
    });
  });

  group('TourStep', () {
    test('should create TourStep with required parameters', () {
      const step = TourStep(
        title: 'Test Title',
        description: 'Test Description',
      );

      expect(step.title, 'Test Title');
      expect(step.description, 'Test Description');
      expect(step.targetKey, null);
      expect(step.customWidget, null);
      expect(step.onNext, null);
    });

    test('should create TourStep with all parameters', () {
      void testCallback() {}
      
      final step = TourStep(
        title: 'Test Title',
        description: 'Test Description',
        targetKey: 'test_key',
        customWidget: const SizedBox.shrink(),
        onNext: testCallback,
      );

      expect(step.title, 'Test Title');
      expect(step.description, 'Test Description');
      expect(step.targetKey, 'test_key');
      expect(step.customWidget, isA<Widget>());
      expect(step.onNext, testCallback);
    });
  });
}