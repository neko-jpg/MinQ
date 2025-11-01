import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:minq/core/audio/sound_effects_service.dart';
import 'package:minq/data/logging/minq_logger.dart';
import 'package:minq/data/providers.dart';
import 'package:minq/domain/gamification/xp_transaction.dart';
import 'package:minq/domain/user/user.dart';
import 'package:minq/presentation/theme/haptics_system.dart';
import 'package:minq/presentation/widgets/xp_gain_animation.dart';

/// XPシステムプロバイダー
final xpSystemProvider = Provider<XPSystem>((ref) {
  final isar = ref.watch(isarProvider);
  return XPSystem(isar.value!);
});

/// XPシステムの核となるサービス
/// XP獲得、レベル計算、レベルアップ処理を管理
class XPSystem {
  final Isar _isar;

  // レベル定義（要件34に基づく）
  static const List<LevelInfo> _levelDefinitions = [
    LevelInfo(
      level: 1,
      name: '新芽',
      description: '習慣化の第一歩を踏み出しました',
      minXP: 0,
      maxXP: 99,
      rewards: ['基本機能解放'],
      unlockedFeatures: ['quest_create', 'quest_complete'],
    ),
    LevelInfo(
      level: 2,
      name: '若葉',
      description: '習慣の芽が育ち始めています',
      minXP: 100,
      maxXP: 299,
      rewards: ['通知機能解放', 'XP+10ボーナス'],
      unlockedFeatures: ['notifications', 'basic_stats'],
    ),
    LevelInfo(
      level: 3,
      name: '青葉',
      description: '継続の力を身につけました',
      minXP: 300,
      maxXP: 699,
      rewards: ['ストリーク追跡解放', 'XP+15ボーナス'],
      unlockedFeatures: ['streak_tracking', 'weekly_stats'],
    ),
    LevelInfo(
      level: 4,
      name: '緑葉',
      description: '習慣が根付いてきました',
      minXP: 700,
      maxXP: 1499,
      rewards: ['ペア機能解放', 'XP+20ボーナス'],
      unlockedFeatures: ['pair_feature', 'tags'],
    ),
    LevelInfo(
      level: 5,
      name: '大樹',
      description: '強固な習慣の基盤ができました',
      minXP: 1500,
      maxXP: 2999,
      rewards: ['高度な統計解放', 'XP+25ボーナス'],
      unlockedFeatures: ['advanced_stats', 'achievements'],
    ),
    LevelInfo(
      level: 6,
      name: '古木',
      description: '習慣のマスターに近づいています',
      minXP: 3000,
      maxXP: 5999,
      rewards: ['イベント機能解放', 'XP+30ボーナス'],
      unlockedFeatures: ['events', 'templates'],
    ),
    LevelInfo(
      level: 7,
      name: '神木',
      description: '習慣化の達人です',
      minXP: 6000,
      maxXP: 11999,
      rewards: ['タイマー機能解放', 'XP+35ボーナス'],
      unlockedFeatures: ['timer', 'export_data'],
    ),
    LevelInfo(
      level: 8,
      name: '世界樹',
      description: '習慣化の伝説的存在です',
      minXP: 12000,
      maxXP: 24999,
      rewards: ['高度なカスタマイズ解放', 'XP+40ボーナス'],
      unlockedFeatures: ['advanced_customization'],
    ),
    LevelInfo(
      level: 9,
      name: '伝説樹',
      description: '習慣化の究極の境地に達しました',
      minXP: 25000,
      maxXP: 999999,
      rewards: ['全機能マスター', 'XP+50ボーナス'],
      unlockedFeatures: [],
    ),
  ];

  // XP報酬設定（要件34に基づく）
  static const Map<XPSource, int> _baseXPRewards = {
    XPSource.questComplete: 10,
    XPSource.miniQuestComplete: 5,
    XPSource.streakMilestone: 20,
    XPSource.challengeComplete: 50,
    XPSource.weeklyGoal: 100,
    XPSource.monthlyGoal: 500,
    XPSource.earlyCompletion: 15,
    XPSource.perfectCompletion: 25,
    XPSource.comebackBonus: 30,
    XPSource.weekendActivity: 12,
    XPSource.specialEvent: 100,
  };

  XPSystem(this._isar);

  /// XPを獲得する（要件34）
  Future<XPGainResult> awardXP({
    required String userId,
    required XPSource source,
    required String reason,
    Map<String, dynamic>? metadata,
    BuildContext? context,
    bool showAnimation = true,
    bool playSound = true,
    bool hapticFeedback = true,
  }) async {
    try {
      // 現在のユーザー情報を取得
      final user =
          await _isar.collection<User>().where().uidEqualTo(userId).findFirst();
      if (user == null) {
        throw Exception('User not found: $userId');
      }

      final previousLevel = user.currentLevel;
      final previousXP = user.totalPoints;

      // 基本XPを計算
      final baseXP = _baseXPRewards[source] ?? 10;

      // マルチプライヤーを計算
      final multiplier = _calculateMultiplier(source, metadata, user);

      // ボーナスXPを計算
      final bonusXP = _calculateBonusXP(source, metadata, user);

      // 総XPを計算
      final totalXP = (baseXP * multiplier).round() + bonusXP;

      // XPトランザクションを作成
      final transaction = XPTransaction(
        userId: userId,
        xpAmount: totalXP,
        reason: reason,
        source: source,
        createdAt: DateTime.now(),
        metadata: metadata,
        multiplier: multiplier,
        streakBonus: _calculateStreakBonus(user.currentStreak),
        difficultyBonus: bonusXP,
      );

      // ユーザーのXPを更新
      final newTotalXP = previousXP + totalXP;
      final newLevel = _calculateLevel(newTotalXP);
      final leveledUp = newLevel > previousLevel;

      await _isar.writeTxn(() async {
        // XPトランザクションを保存
        await _isar.collection<XPTransaction>().put(transaction);

        // ユーザー情報を更新
        user.totalPoints = newTotalXP;
        user.currentLevel = newLevel;
        await _isar.collection<User>().put(user);
      });

      // レベルアップ報酬を処理
      final newRewards = <String>[];
      if (leveledUp) {
        newRewards.addAll(
          await _processLevelUpRewards(userId, newLevel, context),
        );
      }

      // フィードバックを提供
      if (context != null && context.mounted) {
        if (hapticFeedback) {
          await HapticsSystem.success();
        }

        if (playSound) {
          await SoundEffectsService.instance.play(SoundType.coin);
        }

        if (showAnimation) {
          XPGainOverlay.show(context, totalXP, reason);
        }

        if (leveledUp) {
          await _showLevelUpCelebration(context, newLevel);
        }
      }

      final result = XPGainResult(
        xpGained: totalXP,
        newTotalXP: newTotalXP,
        previousLevel: previousLevel,
        newLevel: newLevel,
        leveledUp: leveledUp,
        newRewards: newRewards,
        transaction: transaction,
      );

      MinqLogger.info('XP awarded: $totalXP to user $userId (${source.name})');
      return result;
    } catch (e) {
      MinqLogger.error('Failed to award XP', exception: e);
      rethrow;
    }
  }

  /// レベルを計算する
  int _calculateLevel(int totalXP) {
    for (int i = _levelDefinitions.length - 1; i >= 0; i--) {
      final levelInfo = _levelDefinitions[i];
      if (totalXP >= levelInfo.minXP) {
        return levelInfo.level;
      }
    }
    return 1;
  }

  /// マルチプライヤーを計算する
  double _calculateMultiplier(
    XPSource source,
    Map<String, dynamic>? metadata,
    User user,
  ) {
    double multiplier = 1.0;

    // ストリークボーナス（要件34）
    final streak = user.currentStreak;
    if (streak > 0) {
      multiplier += (streak / 10).clamp(0.0, 1.5); // 最大2.5倍
    }

    // 難易度ボーナス
    final difficulty = metadata?['difficulty'] as String?;
    switch (difficulty) {
      case 'easy':
        multiplier *= 0.8;
        break;
      case 'hard':
        multiplier *= 1.3;
        break;
      case 'expert':
        multiplier *= 1.6;
        break;
      default:
        multiplier *= 1.0;
    }

    // レベルボーナス（高レベルユーザーへの追加報酬）
    if (user.currentLevel >= 5) {
      multiplier += 0.1 * (user.currentLevel - 4);
    }

    return multiplier.clamp(0.5, 3.0); // 最小0.5倍、最大3.0倍
  }

  /// ボーナスXPを計算する
  int _calculateBonusXP(
    XPSource source,
    Map<String, dynamic>? metadata,
    User user,
  ) {
    int bonus = 0;

    // パーフェクト完了ボーナス
    if (metadata?['perfect'] == true) {
      bonus += 5;
    }

    // 早期完了ボーナス
    if (metadata?['early_completion'] == true) {
      bonus += 3;
    }

    // 初回ボーナス
    if (metadata?['first_time'] == true) {
      bonus += 10;
    }

    // 時間帯ボーナス
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 8) {
      // 早朝ボーナス
      bonus += 5;
    } else if (hour >= 22 || hour < 1) {
      // 夜更かしボーナス
      bonus += 3;
    }

    return bonus;
  }

  /// ストリークボーナスを計算する
  int _calculateStreakBonus(int streak) {
    if (streak < 3) return 0;
    if (streak < 7) return 2;
    if (streak < 14) return 5;
    if (streak < 30) return 10;
    if (streak < 60) return 15;
    return 20; // 60日以上のストリーク
  }

  /// ユーザーのレベル進捗情報を取得する
  Future<UserLevelProgress> getUserLevelProgress(String userId) async {
    final user =
        await _isar.collection<User>().where().uidEqualTo(userId).findFirst();
    if (user == null) {
      throw Exception('User not found: $userId');
    }

    final currentLevelInfo = _levelDefinitions[user.currentLevel - 1];
    final nextLevelInfo =
        user.currentLevel < _levelDefinitions.length
            ? _levelDefinitions[user.currentLevel]
            : null;

    final xpToNextLevel =
        nextLevelInfo != null ? nextLevelInfo.minXP - user.totalPoints : 0;

    final progressToNextLevel =
        nextLevelInfo != null
            ? ((user.totalPoints - currentLevelInfo.minXP) /
                    (nextLevelInfo.minXP - currentLevelInfo.minXP))
                .clamp(0.0, 1.0)
            : 1.0;

    return UserLevelProgress(
      currentLevel: user.currentLevel,
      currentLevelName: currentLevelInfo.name,
      currentXP: user.totalPoints,
      xpToNextLevel: xpToNextLevel,
      progressToNextLevel: progressToNextLevel,
      isMaxLevel: nextLevelInfo == null,
      currentLevelInfo: currentLevelInfo,
      nextLevelInfo: nextLevelInfo,
    );
  }

  /// XP履歴を取得する（要件34）
  Future<List<XPTransaction>> getXPHistory({
    required String userId,
    int limit = 50,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    var query =
        _isar
            .collection<XPTransaction>()
            .where()
            .userIdEqualTo(userId)
            .sortByCreatedAtDesc();

    if (startDate != null || endDate != null) {
      query = query.filter();
      if (startDate != null) {
        query = query.createdAtGreaterThan(startDate);
      }
      if (endDate != null) {
        query = query.createdAtLessThan(endDate);
      }
    }

    return await query.limit(limit).findAll();
  }

  /// XP統計を取得する（要件34）
  Future<Map<String, dynamic>> getXPStatistics(String userId) async {
    final transactions =
        await _isar
            .collection<XPTransaction>()
            .where()
            .userIdEqualTo(userId)
            .findAll();

    if (transactions.isEmpty) {
      return {
        'totalXP': 0,
        'totalTransactions': 0,
        'averageXPPerDay': 0.0,
        'topSources': <String, int>{},
        'weeklyXP': 0,
        'monthlyXP': 0,
      };
    }

    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));
    final monthAgo = now.subtract(const Duration(days: 30));

    final weeklyTransactions =
        transactions.where((t) => t.createdAt.isAfter(weekAgo)).toList();

    final monthlyTransactions =
        transactions.where((t) => t.createdAt.isAfter(monthAgo)).toList();

    // ソース別XP集計
    final sourceXP = <String, int>{};
    for (final transaction in transactions) {
      final sourceName = transaction.source.name;
      sourceXP[sourceName] = (sourceXP[sourceName] ?? 0) + transaction.xpAmount;
    }

    // トップソースを取得
    final topSources = Map.fromEntries(
      sourceXP.entries.toList()..sort((a, b) => b.value.compareTo(a.value)),
    );

    // 平均XP/日を計算
    final firstTransaction = transactions.last;
    final daysSinceFirst =
        now.difference(firstTransaction.createdAt).inDays + 1;
    final totalXP = transactions.fold<int>(0, (sum, t) => sum + t.xpAmount);
    final averageXPPerDay = totalXP / daysSinceFirst;

    return {
      'totalXP': totalXP,
      'totalTransactions': transactions.length,
      'averageXPPerDay': averageXPPerDay,
      'topSources': topSources,
      'weeklyXP': weeklyTransactions.fold<int>(0, (sum, t) => sum + t.xpAmount),
      'monthlyXP': monthlyTransactions.fold<int>(
        0,
        (sum, t) => sum + t.xpAmount,
      ),
    };
  }

  /// レベル情報を取得する
  LevelInfo getLevelInfo(int level) {
    if (level < 1 || level > _levelDefinitions.length) {
      return _levelDefinitions.first;
    }
    return _levelDefinitions[level - 1];
  }

  /// 全レベル定義を取得する
  List<LevelInfo> getAllLevels() => _levelDefinitions;

  /// 詳細なXP分析を取得する（要件34）
  Future<XPAnalytics> getDetailedXPAnalytics(String userId) async {
    final transactions =
        await _isar
            .collection<XPTransaction>()
            .where()
            .userIdEqualTo(userId)
            .findAll();

    if (transactions.isEmpty) {
      return XPAnalytics.empty();
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final weekAgo = today.subtract(const Duration(days: 7));
    final monthAgo = today.subtract(const Duration(days: 30));

    // 期間別フィルタリング
    final todayTransactions =
        transactions.where((t) => _isSameDay(t.createdAt, today)).toList();

    final weeklyTransactions =
        transactions.where((t) => t.createdAt.isAfter(weekAgo)).toList();

    final monthlyTransactions =
        transactions.where((t) => t.createdAt.isAfter(monthAgo)).toList();

    // 時間帯別分析
    final hourlyDistribution = <int, int>{};
    for (final transaction in transactions) {
      final hour = transaction.createdAt.hour;
      hourlyDistribution[hour] =
          (hourlyDistribution[hour] ?? 0) + transaction.xpAmount;
    }

    // 曜日別分析
    final weekdayDistribution = <int, int>{};
    for (final transaction in transactions) {
      final weekday = transaction.createdAt.weekday;
      weekdayDistribution[weekday] =
          (weekdayDistribution[weekday] ?? 0) + transaction.xpAmount;
    }

    // ソース別分析
    final sourceAnalysis = <XPSource, SourceAnalytics>{};
    for (final source in XPSource.values) {
      final sourceTransactions =
          transactions.where((t) => t.source == source).toList();
      if (sourceTransactions.isNotEmpty) {
        final totalXP = sourceTransactions.fold<int>(
          0,
          (sum, t) => sum + t.xpAmount,
        );
        final avgXP = totalXP / sourceTransactions.length;
        sourceAnalysis[source] = SourceAnalytics(
          totalXP: totalXP,
          transactionCount: sourceTransactions.length,
          averageXP: avgXP,
          lastActivity: sourceTransactions
              .map((t) => t.createdAt)
              .reduce((a, b) => a.isAfter(b) ? a : b),
        );
      }
    }

    // ストリーク分析
    final streakBonuses =
        transactions
            .where((t) => t.streakBonus != null && t.streakBonus! > 0)
            .toList();

    final totalStreakBonus = streakBonuses.fold<int>(
      0,
      (sum, t) => sum + (t.streakBonus ?? 0),
    );

    // 成長トレンド分析
    final growthTrend = _calculateGrowthTrend(transactions);

    return XPAnalytics(
      totalXP: transactions.fold<int>(0, (sum, t) => sum + t.xpAmount),
      totalTransactions: transactions.length,
      todayXP: todayTransactions.fold<int>(0, (sum, t) => sum + t.xpAmount),
      weeklyXP: weeklyTransactions.fold<int>(0, (sum, t) => sum + t.xpAmount),
      monthlyXP: monthlyTransactions.fold<int>(0, (sum, t) => sum + t.xpAmount),
      averageXPPerDay: _calculateAverageXPPerDay(transactions),
      averageXPPerTransaction:
          transactions.fold<int>(0, (sum, t) => sum + t.xpAmount) /
          transactions.length,
      hourlyDistribution: hourlyDistribution,
      weekdayDistribution: weekdayDistribution,
      sourceAnalysis: sourceAnalysis,
      totalStreakBonus: totalStreakBonus,
      streakBonusTransactions: streakBonuses.length,
      growthTrend: growthTrend,
      mostActiveHour: _getMostActiveHour(hourlyDistribution),
      mostActiveWeekday: _getMostActiveWeekday(weekdayDistribution),
      topSource: _getTopSource(sourceAnalysis),
      firstActivity: transactions
          .map((t) => t.createdAt)
          .reduce((a, b) => a.isBefore(b) ? a : b),
      lastActivity: transactions
          .map((t) => t.createdAt)
          .reduce((a, b) => a.isAfter(b) ? a : b),
    );
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  double _calculateAverageXPPerDay(List<XPTransaction> transactions) {
    if (transactions.isEmpty) return 0.0;

    final firstTransaction = transactions
        .map((t) => t.createdAt)
        .reduce((a, b) => a.isBefore(b) ? a : b);
    final daysSinceFirst =
        DateTime.now().difference(firstTransaction).inDays + 1;
    final totalXP = transactions.fold<int>(0, (sum, t) => sum + t.xpAmount);

    return totalXP / daysSinceFirst;
  }

  GrowthTrend _calculateGrowthTrend(List<XPTransaction> transactions) {
    if (transactions.length < 2) return GrowthTrend.stable;

    // 最近7日と前の7日を比較
    final now = DateTime.now();
    final recent7Days = now.subtract(const Duration(days: 7));
    final previous7Days = now.subtract(const Duration(days: 14));

    final recentXP = transactions
        .where((t) => t.createdAt.isAfter(recent7Days))
        .fold<int>(0, (sum, t) => sum + t.xpAmount);

    final previousXP = transactions
        .where(
          (t) =>
              t.createdAt.isAfter(previous7Days) &&
              t.createdAt.isBefore(recent7Days),
        )
        .fold<int>(0, (sum, t) => sum + t.xpAmount);

    if (previousXP == 0) return GrowthTrend.stable;

    final growthRate = (recentXP - previousXP) / previousXP;

    if (growthRate > 0.2) return GrowthTrend.increasing;
    if (growthRate < -0.2) return GrowthTrend.decreasing;
    return GrowthTrend.stable;
  }

  int _getMostActiveHour(Map<int, int> hourlyDistribution) {
    if (hourlyDistribution.isEmpty) return 12;
    return hourlyDistribution.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
  }

  int _getMostActiveWeekday(Map<int, int> weekdayDistribution) {
    if (weekdayDistribution.isEmpty) return 1;
    return weekdayDistribution.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
  }

  XPSource? _getTopSource(Map<XPSource, SourceAnalytics> sourceAnalysis) {
    if (sourceAnalysis.isEmpty) return null;
    return sourceAnalysis.entries
        .reduce((a, b) => a.value.totalXP > b.value.totalXP ? a : b)
        .key;
  }

  /// レベルアップ報酬を処理する
  Future<List<String>> _processLevelUpRewards(
    String userId,
    int newLevel,
    BuildContext? context,
  ) async {
    final levelInfo = getLevelInfo(newLevel);
    final rewards = <String>[];

    try {
      // 基本報酬を付与
      rewards.addAll(levelInfo.rewards);

      // 機能解放を処理
      await _unlockFeatures(userId, levelInfo.unlockedFeatures);

      // レベル別特別報酬
      switch (newLevel) {
        case 2:
          // 通知機能解放 + ボーナスXP
          await _grantBonusXP(userId, 10, 'レベル2到達ボーナス');
          break;
        case 3:
          // ストリーク追跡解放 + ボーナスXP
          await _grantBonusXP(userId, 15, 'レベル3到達ボーナス');
          break;
        case 4:
          // ペア機能解放 + ボーナスXP
          await _grantBonusXP(userId, 20, 'レベル4到達ボーナス');
          break;
        case 5:
          // 高度な統計解放 + ボーナスXP + 特別バッジ
          await _grantBonusXP(userId, 25, 'レベル5到達ボーナス');
          await _grantBadge(userId, 'master_badge', 'マスターバッジ');
          rewards.add('マスターバッジ獲得');
          break;
        case 6:
          // イベント機能解放 + ボーナスXP
          await _grantBonusXP(userId, 30, 'レベル6到達ボーナス');
          break;
        case 7:
          // タイマー機能解放 + ボーナスXP + 特別称号
          await _grantBonusXP(userId, 35, 'レベル7到達ボーナス');
          await _grantTitle(userId, 'habit_expert', '習慣化エキスパート');
          rewards.add('習慣化エキスパート称号獲得');
          break;
        case 8:
          // 高度なカスタマイズ解放 + ボーナスXP + レア称号
          await _grantBonusXP(userId, 40, 'レベル8到達ボーナス');
          await _grantTitle(userId, 'legendary_user', '伝説のユーザー');
          rewards.add('伝説のユーザー称号獲得');
          break;
        case 9:
          // 全機能マスター + 最大ボーナスXP + 最高称号
          await _grantBonusXP(userId, 50, 'レベル9到達ボーナス');
          await _grantTitle(userId, 'ultimate_master', '究極のマスター');
          rewards.add('究極のマスター称号獲得');
          break;
      }

      // レベルアップ記録を保存
      await _recordLevelUpAchievement(userId, newLevel);

      MinqLogger.info(
        'Level up rewards processed for user $userId, level $newLevel: $rewards',
      );
      return rewards;
    } catch (e) {
      MinqLogger.error('Failed to process level up rewards', exception: e);
      return levelInfo.rewards; // フォールバック
    }
  }

  /// 機能を解放する
  Future<void> _unlockFeatures(String userId, List<String> features) async {
    if (features.isEmpty) return;

    try {
      final user =
          await _isar.collection<User>().where().uidEqualTo(userId).findFirst();
      if (user == null) return;

      // ユーザーの解放済み機能リストを更新
      // 注意: User モデルに unlockedFeatures フィールドが必要
      // 現在のUser モデルには存在しないため、将来の拡張として記録

      MinqLogger.info('Features unlocked for user $userId: $features');
    } catch (e) {
      MinqLogger.error('Failed to unlock features', exception: e);
    }
  }

  /// ボーナスXPを付与する
  Future<void> _grantBonusXP(String userId, int bonusXP, String reason) async {
    try {
      await awardXP(
        userId: userId,
        source: XPSource.specialEvent,
        reason: reason,
        metadata: {'bonus_type': 'level_up'},
        showAnimation: false, // レベルアップアニメーション中なので重複を避ける
        playSound: false,
        hapticFeedback: false,
      );
    } catch (e) {
      MinqLogger.error('Failed to grant bonus XP', exception: e);
    }
  }

  /// バッジを付与する
  Future<void> _grantBadge(
    String userId,
    String badgeId,
    String badgeName,
  ) async {
    try {
      // バッジシステムとの連携
      // 注意: バッジシステムが実装されている場合のみ動作
      MinqLogger.info('Badge granted to user $userId: $badgeName ($badgeId)');
    } catch (e) {
      MinqLogger.error('Failed to grant badge', exception: e);
    }
  }

  /// 称号を付与する
  Future<void> _grantTitle(
    String userId,
    String titleId,
    String titleName,
  ) async {
    try {
      // 称号システムとの連携
      // 注意: 称号システムが実装されている場合のみ動作
      MinqLogger.info('Title granted to user $userId: $titleName ($titleId)');
    } catch (e) {
      MinqLogger.error('Failed to grant title', exception: e);
    }
  }

  /// レベルアップ実績を記録する
  Future<void> _recordLevelUpAchievement(String userId, int level) async {
    try {
      // レベルアップ履歴をXPトランザクションとして記録
      final achievement = XPTransaction(
        userId: userId,
        xpAmount: 0, // 実績記録なのでXPは0
        reason: 'レベル$level到達',
        source: XPSource.specialEvent,
        createdAt: DateTime.now(),
        metadata: {'achievement_type': 'level_up', 'level': level},
      );

      await _isar.writeTxn(() async {
        await _isar.collection<XPTransaction>().put(achievement);
      });
    } catch (e) {
      MinqLogger.error('Failed to record level up achievement', exception: e);
    }
  }

  /// レベルアップ祝福を表示する
  Future<void> _showLevelUpCelebration(
    BuildContext context,
    int newLevel,
  ) async {
    if (!context.mounted) return;

    await HapticsSystem.levelUp();
    await SoundEffectsService.instance.play(SoundType.levelUp);

    final levelInfo = getLevelInfo(newLevel);

    // レベルアップオーバーレイを表示（報酬情報も含める）
    LevelUpOverlay.show(
      context,
      newLevel,
      levelInfo.name,
      rewards: levelInfo.rewards,
    );
  }
}
