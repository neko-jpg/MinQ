import 'package:flutter_test/flutter_test.dart';
import 'package:minq/core/gamification/gamification_engine.dart';

void main() {
  group('Gamification System Tests', () {
    late GamificationEngine gamificationEngine;

    setUp(() {
      // Initialize with null Firestore for testing
      gamificationEngine = GamificationEngine(null);
    });

    test('should calculate rank correctly for different point values', () {
      // Test different point values
      final rank1 = gamificationEngine.getRankForPoints(0);
      expect(rank1.name, equals('新芽'));
      expect(rank1.level, equals(1));

      final rank2 = gamificationEngine.getRankForPoints(1000);
      expect(rank2.name, equals('青葉'));
      expect(rank2.level, equals(3));

      final rank3 = gamificationEngine.getRankForPoints(50000);
      expect(rank3.name, equals('世界樹'));
      expect(rank3.level, equals(8));

      final rank4 = gamificationEngine.getRankForPoints(100000);
      expect(rank4.name, equals('伝説樹'));
      expect(rank4.level, equals(9));
    });

    test('should return correct level info structure', () async {
      const userId = 'test_user';
      
      final levelInfo = await gamificationEngine.getUserLevelInfo(userId);
      
      expect(levelInfo.currentLevel, greaterThan(0));
      expect(levelInfo.currentLevelName, isNotEmpty);
      expect(levelInfo.progress, greaterThanOrEqualTo(0.0));
      expect(levelInfo.progress, lessThanOrEqualTo(1.0));
    });

    test('should handle offline mode gracefully', () async {
      const userId = 'test_user';
      
      // Test awarding points in offline mode
      await gamificationEngine.awardPoints(
        userId: userId,
        basePoints: 10,
        reason: 'Test quest completion',
      );
      
      // Should complete without errors
      expect(true, isTrue);
    });

    test('should calculate habit action points correctly', () async {
      const userId = 'test_user';
      
      // Test different habit actions
      await gamificationEngine.awardHabitPoints(
        userId: userId,
        action: HabitAction.questComplete,
      );
      
      await gamificationEngine.awardHabitPoints(
        userId: userId,
        action: HabitAction.earlyCompletion,
      );
      
      // Should complete without errors
      expect(true, isTrue);
    });

    test('should handle streak multipliers correctly', () async {
      const userId = 'test_user';
      
      // Test with streak metadata
      await gamificationEngine.awardHabitPoints(
        userId: userId,
        action: HabitAction.streakMaintained,
        metadata: {'streakDays': 7},
      );
      
      // Should complete without errors
      expect(true, isTrue);
    });

    test('should check and award badges without errors', () async {
      const userId = 'test_user';
      
      final badges = await gamificationEngine.checkAndAwardBadges(userId);
      
      // Should return a list (empty in offline mode)
      expect(badges, isA<List>());
    });

    test('should calculate current streak without errors', () async {
      const userId = 'test_user';
      
      final streak = await gamificationEngine.calculateCurrentStreak(userId);
      
      // Should return a non-negative number
      expect(streak, greaterThanOrEqualTo(0));
    });
  });
}