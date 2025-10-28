import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:minq/core/audio/sound_effects_service.dart';
import 'package:minq/data/logging/minq_logger.dart';
import 'package:minq/data/providers.dart';
import 'package:minq/domain/gamification/badge.dart' as gamification;
import 'package:flutter/widgets.dart';
import 'package:minq/domain/gamification/points.dart';
import 'package:minq/presentation/theme/haptics_system.dart';
import 'package:minq/presentation/widgets/badge_notification_widget.dart';

// Provider for the engine
final gamificationEngineProvider = Provider<GamificationEngine>((ref) {
  final firestore = ref.watch(firestoreProvider);
  return GamificationEngine(firestore);
});

class GamificationEngine {
  final FirebaseFirestore? _firestore;
  final Map<String, int> _localPoints = {};
  final Map<String, List<gamification.Badge>> _localBadges = {};
  final Map<String, int> _streakData = {};

  GamificationEngine(this._firestore);

  /// Awards points to a user for completing a quest or action with enhanced feedback.
  Future<void> awardPoints({
    required String userId,
    required int basePoints,
    required String reason,
    double difficultyMultiplier = 1.0,
    double consistencyMultiplier = 1.0,
    BuildContext? context,
    bool showNotification = true,
    bool playSound = true,
    bool hapticFeedback = true,
  }) async {
    final totalPoints =
        (basePoints * difficultyMultiplier * consistencyMultiplier).round();
    
    // Update local cache immediately for responsive UI
    _localPoints[userId] = (_localPoints[userId] ?? 0) + totalPoints;

    // Provide immediate feedback
    if (hapticFeedback) {
      await HapticsSystem.success();
    }
    
    if (playSound) {
      await SoundEffectsService.instance.play(SoundType.coin);
    }

    if (showNotification && context != null) {
      PointsNotificationOverlay.show(context, totalPoints, reason);
    }

    // Firestoreが利用できない場合はローカルログのみ
    if (_firestore == null) {
      MinqLogger.info(
        'Awarded $totalPoints points to user $userId for $reason (offline mode).',
      );
      return;
    }

    final pointsTransaction = Points(
      id: '', // Firestore will generate this
      userId: userId,
      value: totalPoints,
      reason: reason,
      createdAt: DateTime.now(),
    );

    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('points_transactions')
          .add(pointsTransaction.toJson());

      MinqLogger.info('Awarded $totalPoints points to user $userId for $reason.');
      
      // Check for level progression after awarding points
      await _checkLevelProgression(userId, context);
      
    } catch (e) {
      MinqLogger.error('Failed to award points (offline)', exception: e);
      // Revert local cache on failure
      _localPoints[userId] = (_localPoints[userId] ?? totalPoints) - totalPoints;
    }
  }

  /// Checks for and awards any new badges to the user with enhanced feedback.
  Future<List<gamification.Badge>> checkAndAwardBadges(
    String userId, {
    BuildContext? context,
    bool showNotification = true,
    bool playSound = true,
    bool hapticFeedback = true,
  }) async {
    // Firestoreが利用できない場合は空のリストを返す
    if (_firestore == null) {
      MinqLogger.info('Badge check skipped (offline mode).');
      return [];
    }

    try {
      final userBadgesRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('badges');
      final questLogsRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('quest_logs');

      final awardedBadges = <gamification.Badge>[];

      // Get user's existing badges
      final existingBadgesSnapshot = await userBadgesRef.get();
      final existingBadgeIds =
          existingBadgesSnapshot.docs.map((doc) => doc.id).toSet();

      // Get quest logs and calculate streak
      final questLogsSnapshot = await questLogsRef.get();
      final completedQuests = questLogsSnapshot.docs.length;
      final currentStreak = await calculateCurrentStreak(userId);

      // Define all possible badges
      final allBadges = _getBadgeDefinitions(completedQuests, currentStreak);

      for (final badgeDef in allBadges) {
        if (!existingBadgeIds.contains(badgeDef.id) && badgeDef.isEarned) {
          final newBadge = badgeDef.toBadge();
          await userBadgesRef.doc(newBadge.id).set(newBadge.toJson());
          awardedBadges.add(newBadge);
          
          // Update local cache
          _localBadges[userId] = [...(_localBadges[userId] ?? []), newBadge];
          
          // Provide immediate feedback for each badge
          if (hapticFeedback) {
            await HapticsSystem.levelUp();
          }
          
          if (playSound) {
            await SoundEffectsService.instance.play(SoundType.achievement);
          }

          if (showNotification && context != null) {
            BadgeNotificationOverlay.show(context, newBadge);
            // Delay between multiple badge notifications
            if (awardedBadges.length > 1) {
              await Future.delayed(const Duration(seconds: 2));
            }
          }
        }
      }

      if (awardedBadges.isNotEmpty) {
        MinqLogger.info('Awarded ${awardedBadges.length} new badges to user $userId.');
      }

      return awardedBadges;
    } catch (e) {
      MinqLogger.error('Failed to check badges (offline)', exception: e);
      return [];
    }
  }

  // Enhanced badge definitions focused on habit formation goals
  List<_BadgeDefinition> _getBadgeDefinitions(int completedQuests, int currentStreak) {
    return [
      // Quest completion badges
      _BadgeDefinition(
        id: 'quest_master_1',
        name: '最初の一歩',
        description: '初めてのクエストを完了しました！',
        imageUrl: 'assets/images/badges/first_step.png',
        isEarned: completedQuests >= 1,
        category: BadgeCategory.milestone,
      ),
      _BadgeDefinition(
        id: 'quest_master_5',
        name: '習慣の芽',
        description: '5つのクエストを完了しました',
        imageUrl: 'assets/images/badges/habit_sprout.png',
        isEarned: completedQuests >= 5,
        category: BadgeCategory.milestone,
      ),
      _BadgeDefinition(
        id: 'quest_master_10',
        name: '習慣の花',
        description: '10のクエストを完了！習慣が花開いています',
        imageUrl: 'assets/images/badges/habit_flower.png',
        isEarned: completedQuests >= 10,
        category: BadgeCategory.milestone,
      ),
      _BadgeDefinition(
        id: 'quest_master_25',
        name: '習慣の木',
        description: '25のクエストを完了！強固な習慣の木に成長',
        imageUrl: 'assets/images/badges/habit_tree.png',
        isEarned: completedQuests >= 25,
        category: BadgeCategory.milestone,
      ),
      _BadgeDefinition(
        id: 'quest_master_50',
        name: '習慣の森',
        description: '50のクエストを完了！習慣の森を築きました',
        imageUrl: 'assets/images/badges/habit_forest.png',
        isEarned: completedQuests >= 50,
        category: BadgeCategory.milestone,
      ),
      _BadgeDefinition(
        id: 'quest_master_100',
        name: '習慣マスター',
        description: '100のクエストを完了！習慣形成の達人です',
        imageUrl: 'assets/images/badges/habit_master.png',
        isEarned: completedQuests >= 100,
        category: BadgeCategory.mastery,
      ),
      
      // Streak badges focused on consistency
      _BadgeDefinition(
        id: 'streak_master_3',
        name: '継続の炎',
        description: '3日連続でクエストを完了！',
        imageUrl: 'assets/images/badges/streak_flame.png',
        isEarned: currentStreak >= 3,
        category: BadgeCategory.consistency,
      ),
      _BadgeDefinition(
        id: 'streak_master_7',
        name: '一週間の力',
        description: '7日連続達成！習慣の力を実感',
        imageUrl: 'assets/images/badges/week_power.png',
        isEarned: currentStreak >= 7,
        category: BadgeCategory.consistency,
      ),
      _BadgeDefinition(
        id: 'streak_master_14',
        name: '二週間の決意',
        description: '14日連続達成！強い意志の証',
        imageUrl: 'assets/images/badges/fortnight_resolve.png',
        isEarned: currentStreak >= 14,
        category: BadgeCategory.consistency,
      ),
      _BadgeDefinition(
        id: 'streak_master_30',
        name: '一ヶ月の習慣',
        description: '30日連続達成！真の習慣化を実現',
        imageUrl: 'assets/images/badges/month_habit.png',
        isEarned: currentStreak >= 30,
        category: BadgeCategory.mastery,
      ),
      _BadgeDefinition(
        id: 'streak_master_100',
        name: '百日の継続',
        description: '100日連続達成！伝説の継続者',
        imageUrl: 'assets/images/badges/hundred_days.png',
        isEarned: currentStreak >= 100,
        category: BadgeCategory.legendary,
      ),
      
      // Time-based badges
      _BadgeDefinition(
        id: 'early_bird',
        name: '早起きの鳥',
        description: '朝6時前にクエストを完了',
        imageUrl: 'assets/images/badges/early_bird.png',
        isEarned: _hasEarlyMorningQuests(completedQuests),
        category: BadgeCategory.special,
      ),
      _BadgeDefinition(
        id: 'night_owl',
        name: '夜更かしの梟',
        description: '夜10時以降にクエストを完了',
        imageUrl: 'assets/images/badges/night_owl.png',
        isEarned: _hasLateNightQuests(completedQuests),
        category: BadgeCategory.special,
      ),
      
      // Motivational badges
      _BadgeDefinition(
        id: 'comeback_hero',
        name: 'カムバックヒーロー',
        description: 'ストリークが途切れても再び立ち上がった',
        imageUrl: 'assets/images/badges/comeback.png',
        isEarned: _hasComebackStory(completedQuests),
        category: BadgeCategory.resilience,
      ),
      _BadgeDefinition(
        id: 'weekend_warrior',
        name: 'ウィークエンド戦士',
        description: '週末も習慣を継続している',
        imageUrl: 'assets/images/badges/weekend_warrior.png',
        isEarned: _hasWeekendActivity(completedQuests),
        category: BadgeCategory.dedication,
      ),
    ];
  }

  /// Calculates the user's current rank based on their total points.
  Future<void> calculateRank(String userId) async {
    if (_firestore == null) {
      MinqLogger.info('Rank calculation skipped (offline mode).');
      return;
    }

    try {
      final pointsSnapshot =
          await _firestore
              .collection('users')
              .doc(userId)
              .collection('points_transactions')
              .get();

      if (pointsSnapshot.docs.isEmpty) {
        MinqLogger.info('User $userId has no points yet.');
        return;
      }

      final totalPoints = pointsSnapshot.docs
          .map((doc) => Points.fromJson(doc.data()).value)
          .fold<int>(0, (prev, current) => prev + current);

      final rank = _getRankForPoints(totalPoints);

      await _firestore.collection('users').doc(userId).update({'rank': rank});
      MinqLogger.info('User $userId rank updated to $rank.');
    } catch (e) {
      MinqLogger.error('Failed to calculate rank (offline)', exception: e);
    }
  }

  String _getRankForPoints(int points) {
    if (points < 100) return 'Novice';
    if (points < 500) return 'Apprentice';
    if (points < 1000) return 'Adept';
    if (points < 5000) return 'Master';
    return 'Grandmaster';
  }

  /// Gets the user's total points
  Future<int> getUserPoints(String userId) async {
    if (_firestore == null) {
      return 0;
    }

    try {
      final pointsSnapshot =
          await _firestore
              .collection('users')
              .doc(userId)
              .collection('points_transactions')
              .get();

      if (pointsSnapshot.docs.isEmpty) {
        return 0;
      }

      return pointsSnapshot.docs
          .map((doc) => Points.fromJson(doc.data()).value)
          .fold<int>(0, (prev, current) => prev + current);
    } catch (e) {
      MinqLogger.error('Failed to get user points (offline)', exception: e);
      return 0;
    }
  }

  /// Gets the rank for a given number of points with enhanced progression
  ({String name, int minPoints, int level}) getRankForPoints(int points) {
    if (points < 500) {
      return (name: '新芽', minPoints: 0, level: 1);
    }
    if (points < 1500) {
      return (name: '若葉', minPoints: 500, level: 2);
    }
    if (points < 3500) {
      return (name: '青葉', minPoints: 1500, level: 3);
    }
    if (points < 7000) {
      return (name: '緑葉', minPoints: 3500, level: 4);
    }
    if (points < 12000) {
      return (name: '大樹', minPoints: 7000, level: 5);
    }
    if (points < 20000) {
      return (name: '古木', minPoints: 12000, level: 6);
    }
    if (points < 35000) {
      return (name: '神木', minPoints: 20000, level: 7);
    }
    if (points < 60000) {
      return (name: '世界樹', minPoints: 35000, level: 8);
    }
    return (name: '伝説樹', minPoints: 60000, level: 9);
  }

  /// Calculate current streak for a user
  Future<int> calculateCurrentStreak(String userId) async {
    if (_firestore == null) {
      return _streakData[userId] ?? 0;
    }

    try {
      final questLogsRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('quest_logs')
          .orderBy('completedAt', descending: true);

      final snapshot = await questLogsRef.get();
      if (snapshot.docs.isEmpty) return 0;

      int streak = 0;
      DateTime? lastDate;

      for (final doc in snapshot.docs) {
        final data = doc.data();
        final completedAt = (data['completedAt'] as Timestamp).toDate();
        final completedDate = DateTime(completedAt.year, completedAt.month, completedAt.day);

        if (lastDate == null) {
          lastDate = completedDate;
          streak = 1;
        } else {
          final daysDiff = lastDate.difference(completedDate).inDays;
          if (daysDiff == 1) {
            streak++;
            lastDate = completedDate;
          } else if (daysDiff > 1) {
            break;
          }
        }
      }

      _streakData[userId] = streak;
      return streak;
    } catch (e) {
      MinqLogger.error('Failed to calculate streak', exception: e);
      return 0;
    }
  }

  /// Check for level progression and show celebration
  Future<void> _checkLevelProgression(String userId, BuildContext? context) async {
    final currentPoints = await getUserPoints(userId);
    
    // Check if user has leveled up (this would need to be stored and compared)
    // For now, we'll trigger celebration on certain point milestones
    final milestones = [500, 1500, 3500, 7000, 12000, 20000, 35000, 60000];
    
    if (milestones.contains(currentPoints) && context != null) {
      await HapticsSystem.levelUp();
      await SoundEffectsService.instance.play(SoundType.levelUp);
      
      // Show level up celebration (would need to implement LevelUpOverlay)
      // LevelUpOverlay.show(context, currentRank);
    }
  }

  /// Helper methods for badge conditions
  bool _hasEarlyMorningQuests(int completedQuests) {
    // This would check actual quest completion times
    // For now, return true if user has completed at least 10 quests
    return completedQuests >= 10;
  }

  bool _hasLateNightQuests(int completedQuests) {
    // This would check actual quest completion times
    return completedQuests >= 15;
  }

  bool _hasComebackStory(int completedQuests) {
    // This would check for streak breaks and recoveries
    return completedQuests >= 20;
  }

  bool _hasWeekendActivity(int completedQuests) {
    // This would check for weekend quest completions
    return completedQuests >= 12;
  }

  /// Get user's current level and progress to next level
  Future<LevelInfo> getUserLevelInfo(String userId) async {
    final points = await getUserPoints(userId);
    final currentRank = getRankForPoints(points);
    
    // Calculate progress to next level
    final nextLevelPoints = _getNextLevelPoints(currentRank.level);
    final progressPoints = points - currentRank.minPoints;
    final pointsNeeded = nextLevelPoints - currentRank.minPoints;
    final progress = pointsNeeded > 0 ? progressPoints / pointsNeeded : 1.0;
    
    return LevelInfo(
      currentLevel: currentRank.level,
      currentLevelName: currentRank.name,
      currentPoints: points,
      pointsToNextLevel: nextLevelPoints - points,
      progress: progress.clamp(0.0, 1.0),
      isMaxLevel: currentRank.level >= 9,
    );
  }

  int _getNextLevelPoints(int currentLevel) {
    final levels = [0, 500, 1500, 3500, 7000, 12000, 20000, 35000, 60000, 100000];
    return currentLevel < levels.length - 1 ? levels[currentLevel + 1] : levels.last;
  }

  /// Award points for specific habit formation actions
  Future<void> awardHabitPoints({
    required String userId,
    required HabitAction action,
    BuildContext? context,
    Map<String, dynamic>? metadata,
  }) async {
    int basePoints;
    String reason;
    double difficultyMultiplier = 1.0;
    double consistencyMultiplier = 1.0;

    switch (action) {
      case HabitAction.questComplete:
        basePoints = 10;
        reason = 'クエスト完了';
        break;
      case HabitAction.streakMaintained:
        basePoints = 5;
        reason = 'ストリーク維持';
        final streakDays = metadata?['streakDays'] as int? ?? 1;
        consistencyMultiplier = 1.0 + (streakDays * 0.1).clamp(0.0, 2.0);
        break;
      case HabitAction.earlyCompletion:
        basePoints = 15;
        reason = '早期完了ボーナス';
        break;
      case HabitAction.difficultQuest:
        basePoints = 20;
        reason = '困難なクエスト';
        difficultyMultiplier = 1.5;
        break;
      case HabitAction.weekendActivity:
        basePoints = 12;
        reason = '週末活動ボーナス';
        break;
      case HabitAction.comebackQuest:
        basePoints = 25;
        reason = 'カムバック達成';
        break;
    }

    await awardPoints(
      userId: userId,
      basePoints: basePoints,
      reason: reason,
      difficultyMultiplier: difficultyMultiplier,
      consistencyMultiplier: consistencyMultiplier,
      context: context,
    );
  }
}

// Helper class to hold badge definition and earned status
class _BadgeDefinition {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final bool isEarned;
  final BadgeCategory category;

  _BadgeDefinition({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    this.isEarned = false,
    this.category = BadgeCategory.milestone,
  });

  gamification.Badge toBadge() {
    return gamification.Badge(
      id: id,
      name: name,
      description: description,
      imageUrl: imageUrl,
      earnedAt: DateTime.now(),
    );
  }
}

/// Badge categories for better organization
enum BadgeCategory {
  milestone,    // Achievement milestones
  consistency,  // Streak and consistency badges
  mastery,      // Mastery and expertise badges
  special,      // Special time-based badges
  resilience,   // Comeback and recovery badges
  dedication,   // Extra effort badges
  legendary,    // Rare legendary badges
}

/// Habit formation actions that can earn points
enum HabitAction {
  questComplete,
  streakMaintained,
  earlyCompletion,
  difficultQuest,
  weekendActivity,
  comebackQuest,
}

/// Level information for users
class LevelInfo {
  final int currentLevel;
  final String currentLevelName;
  final int currentPoints;
  final int pointsToNextLevel;
  final double progress;
  final bool isMaxLevel;

  const LevelInfo({
    required this.currentLevel,
    required this.currentLevelName,
    required this.currentPoints,
    required this.pointsToNextLevel,
    required this.progress,
    required this.isMaxLevel,
  });
}
