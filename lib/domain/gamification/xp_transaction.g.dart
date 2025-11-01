// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'xp_transaction.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$XPTransactionImpl _$$XPTransactionImplFromJson(Map<String, dynamic> json) =>
    _$XPTransactionImpl(
      id: (json['id'] as num?)?.toInt() ?? 0,
      userId: json['userId'] as String,
      xpAmount: (json['xpAmount'] as num).toInt(),
      reason: json['reason'] as String,
      source: $enumDecode(_$XPSourceEnumMap, json['source']),
      createdAt: DateTime.parse(json['createdAt'] as String),
      metadata: json['metadata'] as Map<String, dynamic>?,
      multiplier: (json['multiplier'] as num?)?.toDouble(),
      streakBonus: (json['streakBonus'] as num?)?.toInt(),
      difficultyBonus: (json['difficultyBonus'] as num?)?.toInt(),
    );

Map<String, dynamic> _$$XPTransactionImplToJson(_$XPTransactionImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'xpAmount': instance.xpAmount,
      'reason': instance.reason,
      'source': _$XPSourceEnumMap[instance.source]!,
      'createdAt': instance.createdAt.toIso8601String(),
      'metadata': instance.metadata,
      'multiplier': instance.multiplier,
      'streakBonus': instance.streakBonus,
      'difficultyBonus': instance.difficultyBonus,
    };

const _$XPSourceEnumMap = {
  XPSource.questComplete: 'quest_complete',
  XPSource.miniQuestComplete: 'mini_quest_complete',
  XPSource.streakMilestone: 'streak_milestone',
  XPSource.challengeComplete: 'challenge_complete',
  XPSource.weeklyGoal: 'weekly_goal',
  XPSource.monthlyGoal: 'monthly_goal',
  XPSource.earlyCompletion: 'early_completion',
  XPSource.perfectCompletion: 'perfect_completion',
  XPSource.comebackBonus: 'comeback_bonus',
  XPSource.weekendActivity: 'weekend_activity',
  XPSource.specialEvent: 'special_event',
};

_$XPGainResultImpl _$$XPGainResultImplFromJson(Map<String, dynamic> json) =>
    _$XPGainResultImpl(
      xpGained: (json['xpGained'] as num).toInt(),
      newTotalXP: (json['newTotalXP'] as num).toInt(),
      previousLevel: (json['previousLevel'] as num).toInt(),
      newLevel: (json['newLevel'] as num).toInt(),
      leveledUp: json['leveledUp'] as bool,
      newRewards: (json['newRewards'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      transaction:
          XPTransaction.fromJson(json['transaction'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$XPGainResultImplToJson(_$XPGainResultImpl instance) =>
    <String, dynamic>{
      'xpGained': instance.xpGained,
      'newTotalXP': instance.newTotalXP,
      'previousLevel': instance.previousLevel,
      'newLevel': instance.newLevel,
      'leveledUp': instance.leveledUp,
      'newRewards': instance.newRewards,
      'transaction': instance.transaction,
    };

_$LevelInfoImpl _$$LevelInfoImplFromJson(Map<String, dynamic> json) =>
    _$LevelInfoImpl(
      level: (json['level'] as num).toInt(),
      name: json['name'] as String,
      description: json['description'] as String,
      minXP: (json['minXP'] as num).toInt(),
      maxXP: (json['maxXP'] as num).toInt(),
      rewards:
          (json['rewards'] as List<dynamic>).map((e) => e as String).toList(),
      unlockedFeatures: (json['unlockedFeatures'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$$LevelInfoImplToJson(_$LevelInfoImpl instance) =>
    <String, dynamic>{
      'level': instance.level,
      'name': instance.name,
      'description': instance.description,
      'minXP': instance.minXP,
      'maxXP': instance.maxXP,
      'rewards': instance.rewards,
      'unlockedFeatures': instance.unlockedFeatures,
    };

_$UserLevelProgressImpl _$$UserLevelProgressImplFromJson(
        Map<String, dynamic> json) =>
    _$UserLevelProgressImpl(
      currentLevel: (json['currentLevel'] as num).toInt(),
      currentLevelName: json['currentLevelName'] as String,
      currentXP: (json['currentXP'] as num).toInt(),
      xpToNextLevel: (json['xpToNextLevel'] as num).toInt(),
      progressToNextLevel: (json['progressToNextLevel'] as num).toDouble(),
      isMaxLevel: json['isMaxLevel'] as bool,
      currentLevelInfo:
          LevelInfo.fromJson(json['currentLevelInfo'] as Map<String, dynamic>),
      nextLevelInfo: json['nextLevelInfo'] == null
          ? null
          : LevelInfo.fromJson(json['nextLevelInfo'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$UserLevelProgressImplToJson(
        _$UserLevelProgressImpl instance) =>
    <String, dynamic>{
      'currentLevel': instance.currentLevel,
      'currentLevelName': instance.currentLevelName,
      'currentXP': instance.currentXP,
      'xpToNextLevel': instance.xpToNextLevel,
      'progressToNextLevel': instance.progressToNextLevel,
      'isMaxLevel': instance.isMaxLevel,
      'currentLevelInfo': instance.currentLevelInfo,
      'nextLevelInfo': instance.nextLevelInfo,
    };

_$XPAnalyticsImpl _$$XPAnalyticsImplFromJson(Map<String, dynamic> json) =>
    _$XPAnalyticsImpl(
      totalXP: (json['totalXP'] as num).toInt(),
      totalTransactions: (json['totalTransactions'] as num).toInt(),
      todayXP: (json['todayXP'] as num).toInt(),
      weeklyXP: (json['weeklyXP'] as num).toInt(),
      monthlyXP: (json['monthlyXP'] as num).toInt(),
      averageXPPerDay: (json['averageXPPerDay'] as num).toDouble(),
      averageXPPerTransaction:
          (json['averageXPPerTransaction'] as num).toDouble(),
      hourlyDistribution:
          (json['hourlyDistribution'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(int.parse(k), (e as num).toInt()),
      ),
      weekdayDistribution:
          (json['weekdayDistribution'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(int.parse(k), (e as num).toInt()),
      ),
      sourceAnalysis: (json['sourceAnalysis'] as Map<String, dynamic>).map(
        (k, e) => MapEntry($enumDecode(_$XPSourceEnumMap, k),
            SourceAnalytics.fromJson(e as Map<String, dynamic>)),
      ),
      totalStreakBonus: (json['totalStreakBonus'] as num).toInt(),
      streakBonusTransactions: (json['streakBonusTransactions'] as num).toInt(),
      growthTrend: $enumDecode(_$GrowthTrendEnumMap, json['growthTrend']),
      mostActiveHour: (json['mostActiveHour'] as num).toInt(),
      mostActiveWeekday: (json['mostActiveWeekday'] as num).toInt(),
      topSource: $enumDecodeNullable(_$XPSourceEnumMap, json['topSource']),
      firstActivity: DateTime.parse(json['firstActivity'] as String),
      lastActivity: DateTime.parse(json['lastActivity'] as String),
    );

Map<String, dynamic> _$$XPAnalyticsImplToJson(_$XPAnalyticsImpl instance) =>
    <String, dynamic>{
      'totalXP': instance.totalXP,
      'totalTransactions': instance.totalTransactions,
      'todayXP': instance.todayXP,
      'weeklyXP': instance.weeklyXP,
      'monthlyXP': instance.monthlyXP,
      'averageXPPerDay': instance.averageXPPerDay,
      'averageXPPerTransaction': instance.averageXPPerTransaction,
      'hourlyDistribution':
          instance.hourlyDistribution.map((k, e) => MapEntry(k.toString(), e)),
      'weekdayDistribution':
          instance.weekdayDistribution.map((k, e) => MapEntry(k.toString(), e)),
      'sourceAnalysis': instance.sourceAnalysis
          .map((k, e) => MapEntry(_$XPSourceEnumMap[k]!, e)),
      'totalStreakBonus': instance.totalStreakBonus,
      'streakBonusTransactions': instance.streakBonusTransactions,
      'growthTrend': _$GrowthTrendEnumMap[instance.growthTrend]!,
      'mostActiveHour': instance.mostActiveHour,
      'mostActiveWeekday': instance.mostActiveWeekday,
      'topSource': _$XPSourceEnumMap[instance.topSource],
      'firstActivity': instance.firstActivity.toIso8601String(),
      'lastActivity': instance.lastActivity.toIso8601String(),
    };

const _$GrowthTrendEnumMap = {
  GrowthTrend.increasing: 'increasing',
  GrowthTrend.stable: 'stable',
  GrowthTrend.decreasing: 'decreasing',
};

_$SourceAnalyticsImpl _$$SourceAnalyticsImplFromJson(
        Map<String, dynamic> json) =>
    _$SourceAnalyticsImpl(
      totalXP: (json['totalXP'] as num).toInt(),
      transactionCount: (json['transactionCount'] as num).toInt(),
      averageXP: (json['averageXP'] as num).toDouble(),
      lastActivity: DateTime.parse(json['lastActivity'] as String),
    );

Map<String, dynamic> _$$SourceAnalyticsImplToJson(
        _$SourceAnalyticsImpl instance) =>
    <String, dynamic>{
      'totalXP': instance.totalXP,
      'transactionCount': instance.transactionCount,
      'averageXP': instance.averageXP,
      'lastActivity': instance.lastActivity.toIso8601String(),
    };
