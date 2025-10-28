import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:minq/core/audio/sound_effects_service.dart';
import 'package:minq/core/gamification/gamification_engine.dart';
import 'package:minq/data/logging/minq_logger.dart';
import 'package:minq/domain/gamification/badge.dart' as gamification;
import 'package:minq/presentation/common/celebration/celebration_system.dart';
import 'package:minq/presentation/theme/design_tokens.dart';
import 'package:minq/presentation/theme/haptics_system.dart';
import 'package:minq/presentation/widgets/enhanced_achievement_notification.dart';

/// Provider for the comprehensive gamification service
final comprehensiveGamificationServiceProvider = Provider<ComprehensiveGamificationService>((ref) {
  final gamificationEngine = ref.watch(gamificationEngineProvider);
  return ComprehensiveGamificationService(gamificationEngine);
});

/// Comprehensive gamification service that orchestrates all gamification features
/// with enhanced user experience, animations, and feedback systems
class ComprehensiveGamificationService {
  final GamificationEngine _gamificationEngine;

  // Cache for performance
  final Map<String, LevelInfo> _levelCache = {};
  final Map<String, List<gamification.Badge>> _badgeCache = {};
  final Map<String, DateTime> _lastCacheUpdate = {};

  // Configuration
  static const Duration _cacheExpiry = Duration(minutes: 5);
  static const int _maxCacheSize = 100;

  ComprehensiveGamificationService(this._gamificationEngine);

  /// Award points for quest completion with comprehensive feedback
  Future<GamificationResult> completeQuest({
    required String userId,
    required String questId,
    required BuildContext context,
    Map<String, dynamic>? questMetadata,
  }) async {
    try {
      final result = GamificationResult();

      // Calculate base points based on quest difficulty
      final difficulty = questMetadata?['difficulty'] as String? ?? 'normal';
      final basePoints = _calculateQuestPoints(difficulty);

      // Check for streak bonus
      final currentStreak = await _gamificationEngine.calculateCurrentStreak(userId);
      final streakMultiplier = _calculateStreakMultiplier(currentStreak);

      // Check for time-based bonuses
      final timeBonus = _calculateTimeBonus(DateTime.now());

      // Award base points
      await _gamificationEngine.awardPoints(
        userId: userId,
        basePoints: basePoints,
        reason: 'クエスト完了',
        difficultyMultiplier: _getDifficultyMultiplier(difficulty),
        consistencyMultiplier: streakMultiplier,
        context: context,
        showNotification: true,
        playSound: true,
        hapticFeedback: true,
      );

      result.pointsAwarded = (basePoints * _getDifficultyMultiplier(difficulty) * streakMultiplier).round();

      // Award time bonus if applicable
      if (timeBonus > 0) {
        await _gamificationEngine.awardPoints(
          userId: userId,
          basePoints: timeBonus,
          reason: 'タイムボーナス',
          context: context,
          showNotification: true,
        );
        result.bonusPoints = timeBonus;
      }

      // Check for new badges
      final newBadges = await _gamificationEngine.checkAndAwardBadges(
        userId,
        context: context,
        showNotification: true,
        playSound: true,
        hapticFeedback: true,
      );

      result.newBadges = newBadges;

      // Check for level progression
      final levelInfo = await _gamificationEngine.getUserLevelInfo(userId);
      final previousLevel = _levelCache[userId]?.currentLevel ?? 0;

      if (levelInfo.currentLevel > previousLevel) {
        result.leveledUp = true;
        result.newLevel = levelInfo.currentLevel;
        await _showLevelUpCelebration(context, levelInfo);
      }

      // Update cache
      _levelCache[userId] = levelInfo;
      _lastCacheUpdate[userId] = DateTime.now();

      // Show celebration for significant achievements
      if (result.shouldShowCelebration()) {
        await _showAchievementCelebration(context, result);
      }

      MinqLogger.info('Quest completed successfully for user $userId');
      return result;

    } catch (e) {
      MinqLogger.error('Failed to complete quest gamification', exception: e);
      return GamificationResult()..hasError = true;
    }
  }

  /// Award points for maintaining streak
  Future<void> maintainStreak({
    required String userId,
    required int streakDays,
    required BuildContext context,
  }) async {
    await _gamificationEngine.awardHabitPoints(
      userId: userId,
      action: HabitAction.streakMaintained,
      context: context,
      metadata: {'streakDays': streakDays},
    );

    // Special celebrations for milestone streaks
    if (_isStreakMilestone(streakDays)) {
      await _showStreakMilestoneCelebration(context, streakDays);
    }
  }

  /// Award points for early quest completion
  Future<void> awardEarlyCompletion({
    required String userId,
    required BuildContext context,
  }) async {
    await _gamificationEngine.awardHabitPoints(
      userId: userId,
      action: HabitAction.earlyCompletion,
      context: context,
    );
  }

  /// Award points for weekend activity
  Future<void> awardWeekendActivity({
    required String userId,
    required BuildContext context,
  }) async {
    await _gamificationEngine.awardHabitPoints(
      userId: userId,
      action: HabitAction.weekendActivity,
      context: context,
    );
  }

  /// Award points for comeback after streak break
  Future<void> awardComeback({
    required String userId,
    required BuildContext context,
  }) async {
    await _gamificationEngine.awardHabitPoints(
      userId: userId,
      action: HabitAction.comebackQuest,
      context: context,
    );

    // Show special comeback celebration
    await _showComebackCelebration(context);
  }

  /// Get user's current level info with caching
  Future<LevelInfo> getUserLevelInfo(String userId) async {
    final cached = _levelCache[userId];
    final lastUpdate = _lastCacheUpdate[userId];

    if (cached != null &&
        lastUpdate != null &&
        DateTime.now().difference(lastUpdate) < _cacheExpiry) {
      return cached;
    }

    final levelInfo = await _gamificationEngine.getUserLevelInfo(userId);
    _levelCache[userId] = levelInfo;
    _lastCacheUpdate[userId] = DateTime.now();

    return levelInfo;
  }

  /// Get user's badges with caching
  Future<List<gamification.Badge>> getUserBadges(String userId) async {
    // This would implement badge caching similar to level info
    // For now, return empty list as the actual implementation would depend on Firestore
    return [];
  }

  /// Calculate quest points based on difficulty
  int _calculateQuestPoints(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'easy':
        return 8;
      case 'normal':
        return 10;
      case 'hard':
        return 15;
      case 'expert':
        return 20;
      default:
        return 10;
    }
  }

  /// Calculate difficulty multiplier
  double _getDifficultyMultiplier(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'easy':
        return 0.8;
      case 'normal':
        return 1.0;
      case 'hard':
        return 1.3;
      case 'expert':
        return 1.6;
      default:
        return 1.0;
    }
  }

  /// Calculate streak multiplier
  double _calculateStreakMultiplier(int streakDays) {
    if (streakDays < 3) return 1.0;
    if (streakDays < 7) return 1.1;
    if (streakDays < 14) return 1.2;
    if (streakDays < 30) return 1.3;
    if (streakDays < 60) return 1.4;
    return 1.5; // Max multiplier for 60+ day streaks
  }

  /// Calculate time-based bonus points
  int _calculateTimeBonus(DateTime completionTime) {
    final hour = completionTime.hour;

    // Early bird bonus (5-8 AM)
    if (hour >= 5 && hour < 8) {
      return 5;
    }

    // Night owl bonus (10 PM - 12 AM)
    if (hour >= 22 || hour < 1) {
      return 3;
    }

    return 0;
  }

  /// Check if streak is a milestone
  bool _isStreakMilestone(int streakDays) {
    const milestones = [3, 7, 14, 30, 60, 100, 365];
    return milestones.contains(streakDays);
  }

  /// Show level up celebration
  Future<void> _showLevelUpCelebration(BuildContext context, LevelInfo levelInfo) async {
    await HapticsSystem.levelUp();
    await SoundEffectsService.instance.play(SoundType.levelUp);

    // Show celebration system
    CelebrationSystem.showCelebration(
      context,
      config: CelebrationConfig(
        type: CelebrationType.trophy,
        message: 'レベル${levelInfo.currentLevel}達成！\n${levelInfo.currentLevelName}',
        primaryColor: Colors.amber,
        secondaryColor: Colors.orange,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  /// Show achievement celebration
  Future<void> _showAchievementCelebration(BuildContext context, GamificationResult result) async {
    if (result.newBadges.isNotEmpty) {
      // Show enhanced badge notifications
      for (final badge in result.newBadges) {
        EnhancedAchievementOverlay.show(context, badge);
        // Delay between multiple badges
        if (result.newBadges.length > 1) {
          await Future.delayed(const Duration(seconds: 3));
        }
      }
    }

    if (result.leveledUp) {
      // Level up celebration is handled separately
      return;
    }

    // Show general celebration for high point awards
    if (result.totalPoints >= 50) {
      CelebrationSystem.showCelebration(
        context,
        config: const CelebrationConfig(
          type: CelebrationType.confetti,
          message: '素晴らしい達成！',
          primaryColor: Colors.amber,
          secondaryColor: Colors.orange,
        ),
      );
    }
  }

  /// Show streak milestone celebration
  Future<void> _showStreakMilestoneCelebration(BuildContext context, int streakDays) async {
    final config = CelebrationSystem.getStreakCelebration(streakDays);
    CelebrationSystem.showCelebration(context, config: config);
  }

  /// Show comeback celebration
  Future<void> _showComebackCelebration(BuildContext context) async {
    await HapticsSystem.success();
    await SoundEffectsService.instance.play(SoundType.success);

    CelebrationSystem.showCelebration(
      context,
      config: const CelebrationConfig(
        type: CelebrationType.mascot,
        message: 'カムバック成功！\n諦めない心が素晴らしい！',
        primaryColor: Colors.green,
        secondaryColor: Colors.lightGreen,
        duration: Duration(seconds: 3),
      ),
    );
  }

  /// Clean up old cache entries
  void _cleanupCache() {
    if (_levelCache.length > _maxCacheSize) {
      final oldestEntries = _lastCacheUpdate.entries
          .toList()
          ..sort((a, b) => a.value.compareTo(b.value));

      final entriesToRemove = oldestEntries.take(_levelCache.length - _maxCacheSize);
      for (final entry in entriesToRemove) {
        _levelCache.remove(entry.key);
        _lastCacheUpdate.remove(entry.key);
      }
    }
  }

  /// Dispose resources
  void dispose() {
    _levelCache.clear();
    _badgeCache.clear();
    _lastCacheUpdate.clear();
  }
}

/// Result of gamification actions
class GamificationResult {
  int pointsAwarded = 0;
  int bonusPoints = 0;
  List<gamification.Badge> newBadges = [];
  bool leveledUp = false;
  int newLevel = 0;
  bool hasError = false;

  int get totalPoints => pointsAwarded + bonusPoints;

  bool shouldShowCelebration() {
    return newBadges.isNotEmpty || leveledUp || totalPoints >= 30;
  }

  @override
  String toString() {
    return 'GamificationResult(points: $totalPoints, badges: ${newBadges.length}, levelUp: $leveledUp)';
  }
}