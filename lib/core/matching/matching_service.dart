import 'dart:math';

/// マッチングサービス
class MatchingService {
  /// ユーザーをマッチング
  Future<List<MatchCandidate>> findMatches({
    required String userId,
    required MatchingPreferences preferences,
    required List<UserProfile> availableUsers,
  }) async {
    final candidates = <MatchCandidate>[];

    for (final user in availableUsers) {
      if (user.id == userId) continue;

      final score = _calculateMatchScore(
        preferences: preferences,
        candidate: user,
      );

      if (score >= preferences.minMatchScore) {
        candidates.add(MatchCandidate(
          user: user,
          score: score,
          reasons: _getMatchReasons(preferences, user),
        ));
      }
    }

    // スコアでソート
    candidates.sort((a, b) => b.score.compareTo(a.score));

    return candidates.take(preferences.maxResults).toList();
  }

  /// マッチスコアを計算
  double _calculateMatchScore({
    required MatchingPreferences preferences,
    required UserProfile candidate,
  }) {
    double score = 0.0;
    int factors = 0;

    // 時間帯の一致
    if (preferences.preferredTimeSlots != null &&
        candidate.activeTimeSlots != null) {
      final timeSlotMatch = _calculateTimeSlotMatch(
        preferences.preferredTimeSlots!,
        candidate.activeTimeSlots!,
      );
      score += timeSlotMatch * 30; // 最大30点
      factors++;
    }

    // 言語の一致
    if (preferences.preferredLanguages != null &&
        candidate.languages != null) {
      final languageMatch = _calculateLanguageMatch(
        preferences.preferredLanguages!,
        candidate.languages!,
      );
      score += languageMatch * 25; // 最大25点
      factors++;
    }

    // 目的の一致
    if (preferences.purposes != null && candidate.purposes != null) {
      final purposeMatch = _calculatePurposeMatch(
        preferences.purposes!,
        candidate.purposes!,
      );
      score += purposeMatch * 25; // 最大25点
      factors++;
    }

    // アクティビティレベルの一致
    if (preferences.activityLevel != null &&
        candidate.activityLevel != null) {
      final activityMatch = _calculateActivityMatch(
        preferences.activityLevel!,
        candidate.activityLevel!,
      );
      score += activityMatch * 20; // 最大20点
      factors++;
    }

    // 正規化（0-100）
    return factors > 0 ? score : 0.0;
  }

  /// 時間帯の一致度を計算
  double _calculateTimeSlotMatch(
    List<TimeSlot> preferred,
    List<TimeSlot> candidate,
  ) {
    int matches = 0;
    for (final pref in preferred) {
      for (final cand in candidate) {
        if (_timeSlotsOverlap(pref, cand)) {
          matches++;
          break;
        }
      }
    }
    return matches / preferred.length;
  }

  /// 時間帯が重複しているかチェック
  bool _timeSlotsOverlap(TimeSlot a, TimeSlot b) {
    return a.start.isBefore(b.end) && a.end.isAfter(b.start);
  }

  /// 言語の一致度を計算
  double _calculateLanguageMatch(
    List<String> preferred,
    List<String> candidate,
  ) {
    int matches = 0;
    for (final lang in preferred) {
      if (candidate.contains(lang)) {
        matches++;
      }
    }
    return matches / preferred.length;
  }

  /// 目的の一致度を計算
  double _calculatePurposeMatch(
    List<MatchingPurpose> preferred,
    List<MatchingPurpose> candidate,
  ) {
    int matches = 0;
    for (final purpose in preferred) {
      if (candidate.contains(purpose)) {
        matches++;
      }
    }
    return matches / preferred.length;
  }

  /// アクティビティレベルの一致度を計算
  double _calculateActivityMatch(
    ActivityLevel preferred,
    ActivityLevel candidate,
  ) {
    final diff = (preferred.index - candidate.index).abs();
    return 1.0 - (diff / ActivityLevel.values.length);
  }

  /// マッチング理由を取得
  List<String> _getMatchReasons(
    MatchingPreferences preferences,
    UserProfile candidate,
  ) {
    final reasons = <String>[];

    // 時間帯
    if (preferences.preferredTimeSlots != null &&
        candidate.activeTimeSlots != null) {
      final match = _calculateTimeSlotMatch(
        preferences.preferredTimeSlots!,
        candidate.activeTimeSlots!,
      );
      if (match > 0.5) {
        reasons.add('活動時間帯が一致');
      }
    }

    // 言語
    if (preferences.preferredLanguages != null &&
        candidate.languages != null) {
      final commonLanguages = preferences.preferredLanguages!
          .where((lang) => candidate.languages!.contains(lang))
          .toList();
      if (commonLanguages.isNotEmpty) {
        reasons.add('共通言語: ${commonLanguages.join(", ")}');
      }
    }

    // 目的
    if (preferences.purposes != null && candidate.purposes != null) {
      final commonPurposes = preferences.purposes!
          .where((purpose) => candidate.purposes!.contains(purpose))
          .toList();
      if (commonPurposes.isNotEmpty) {
        reasons.add('共通の目的: ${commonPurposes.map((p) => p.displayName).join(", ")}');
      }
    }

    // アクティビティレベル
    if (preferences.activityLevel != null &&
        candidate.activityLevel != null) {
      if (preferences.activityLevel == candidate.activityLevel) {
        reasons.add('同じアクティビティレベル');
      }
    }

    return reasons;
  }
}

/// マッチング設定
class MatchingPreferences {
  final List<TimeSlot>? preferredTimeSlots;
  final List<String>? preferredLanguages;
  final List<MatchingPurpose>? purposes;
  final ActivityLevel? activityLevel;
  final double minMatchScore;
  final int maxResults;
  final bool excludeBlockedUsers;
  final bool excludePreviousMatches;

  const MatchingPreferences({
    this.preferredTimeSlots,
    this.preferredLanguages,
    this.purposes,
    this.activityLevel,
    this.minMatchScore = 50.0,
    this.maxResults = 10,
    this.excludeBlockedUsers = true,
    this.excludePreviousMatches = false,
  });

  /// デフォルト設定
  static const defaultPreferences = MatchingPreferences();

  /// 厳格な設定
  static const strict = MatchingPreferences(
    minMatchScore: 70.0,
    maxResults: 5,
    excludePreviousMatches: true,
  );

  /// 緩い設定
  static const relaxed = MatchingPreferences(
    minMatchScore: 30.0,
    maxResults: 20,
    excludePreviousMatches: false,
  );
}

/// 時間帯
class TimeSlot {
  final DateTime start;
  final DateTime end;

  const TimeSlot({
    required this.start,
    required this.end,
  });

  /// 朝（6:00-12:00）
  factory TimeSlot.morning() {
    final now = DateTime.now();
    return TimeSlot(
      start: DateTime(now.year, now.month, now.day, 6, 0),
      end: DateTime(now.year, now.month, now.day, 12, 0),
    );
  }

  /// 昼（12:00-18:00）
  factory TimeSlot.afternoon() {
    final now = DateTime.now();
    return TimeSlot(
      start: DateTime(now.year, now.month, now.day, 12, 0),
      end: DateTime(now.year, now.month, now.day, 18, 0),
    );
  }

  /// 夜（18:00-24:00）
  factory TimeSlot.evening() {
    final now = DateTime.now();
    return TimeSlot(
      start: DateTime(now.year, now.month, now.day, 18, 0),
      end: DateTime(now.year, now.month, now.day, 24, 0),
    );
  }

  /// 深夜（0:00-6:00）
  factory TimeSlot.night() {
    final now = DateTime.now();
    return TimeSlot(
      start: DateTime(now.year, now.month, now.day, 0, 0),
      end: DateTime(now.year, now.month, now.day, 6, 0),
    );
  }

  /// 時間帯の長さ
  Duration get duration => end.difference(start);

  @override
  String toString() {
    return '${start.hour}:${start.minute.toString().padLeft(2, "0")} - ${end.hour}:${end.minute.toString().padLeft(2, "0")}';
  }
}

/// マッチング目的
enum MatchingPurpose {
  motivation,
  accountability,
  socializing,
  learning,
  competition,
  support,
}

extension MatchingPurposeExtension on MatchingPurpose {
  String get displayName {
    switch (this) {
      case MatchingPurpose.motivation:
        return 'モチベーション維持';
      case MatchingPurpose.accountability:
        return '相互監視';
      case MatchingPurpose.socializing:
        return '交流';
      case MatchingPurpose.learning:
        return '学習';
      case MatchingPurpose.competition:
        return '競争';
      case MatchingPurpose.support:
        return 'サポート';
    }
  }
}

/// アクティビティレベル
enum ActivityLevel {
  low,
  medium,
  high,
  veryHigh,
}

extension ActivityLevelExtension on ActivityLevel {
  String get displayName {
    switch (this) {
      case ActivityLevel.low:
        return '低';
      case ActivityLevel.medium:
        return '中';
      case ActivityLevel.high:
        return '高';
      case ActivityLevel.veryHigh:
        return '非常に高い';
    }
  }
}

/// ユーザープロフィール
class UserProfile {
  final String id;
  final String name;
  final String? avatarUrl;
  final List<TimeSlot>? activeTimeSlots;
  final List<String>? languages;
  final List<MatchingPurpose>? purposes;
  final ActivityLevel? activityLevel;
  final int totalQuests;
  final int completedQuests;
  final int currentStreak;

  const UserProfile({
    required this.id,
    required this.name,
    this.avatarUrl,
    this.activeTimeSlots,
    this.languages,
    this.purposes,
    this.activityLevel,
    this.totalQuests = 0,
    this.completedQuests = 0,
    this.currentStreak = 0,
  });
}

/// マッチ候補
class MatchCandidate {
  final UserProfile user;
  final double score;
  final List<String> reasons;

  const MatchCandidate({
    required this.user,
    required this.score,
    required this.reasons,
  });
}

/// 再マッチ回避システム
class RematchAvoidanceSystem {
  final Map<String, Set<String>> _previousMatches = {};
  final Map<String, DateTime> _cooldownExpiry = {};
  final Duration _cooldownDuration;

  RematchAvoidanceSystem({
    Duration? cooldownDuration,
  }) : _cooldownDuration = cooldownDuration ?? const Duration(days: 7);

  /// 以前マッチしたかチェック
  bool hasPreviouslyMatched(String userId, String candidateId) {
    return _previousMatches[userId]?.contains(candidateId) ?? false;
  }

  /// クールダウン中かチェック
  bool isInCooldown(String userId, String candidateId) {
    final key = _getCooldownKey(userId, candidateId);
    final expiry = _cooldownExpiry[key];

    if (expiry == null) return false;

    if (DateTime.now().isAfter(expiry)) {
      _cooldownExpiry.remove(key);
      return false;
    }

    return true;
  }

  /// マッチを記録
  void recordMatch(String userId, String candidateId) {
    _previousMatches.putIfAbsent(userId, () => {});
    _previousMatches[userId]!.add(candidateId);

    _previousMatches.putIfAbsent(candidateId, () => {});
    _previousMatches[candidateId]!.add(userId);

    // クールダウンを設定
    final key = _getCooldownKey(userId, candidateId);
    _cooldownExpiry[key] = DateTime.now().add(_cooldownDuration);
  }

  /// マッチ解除を記録
  void recordUnmatch(String userId, String candidateId) {
    _previousMatches[userId]?.remove(candidateId);
    _previousMatches[candidateId]?.remove(userId);
  }

  /// クールダウンキーを取得
  String _getCooldownKey(String userId, String candidateId) {
    final ids = [userId, candidateId]..sort();
    return '${ids[0]}:${ids[1]}';
  }

  /// クールダウンをリセット
  void resetCooldown(String userId, String candidateId) {
    final key = _getCooldownKey(userId, candidateId);
    _cooldownExpiry.remove(key);
  }

  /// 全てのクールダウンをクリア
  void clearAllCooldowns() {
    _cooldownExpiry.clear();
  }

  /// 以前のマッチをクリア
  void clearPreviousMatches(String userId) {
    _previousMatches.remove(userId);
  }
}

/// マッチング統計
class MatchingStats {
  int _totalMatches = 0;
  int _successfulMatches = 0;
  int _failedMatches = 0;
  final Map<String, int> _matchReasonCount = {};

  /// 総マッチ数
  int get totalMatches => _totalMatches;

  /// 成功したマッチ数
  int get successfulMatches => _successfulMatches;

  /// 失敗したマッチ数
  int get failedMatches => _failedMatches;

  /// 成功率
  double get successRate =>
      _totalMatches > 0 ? _successfulMatches / _totalMatches : 0.0;

  /// マッチを記録
  void recordMatch({required bool success, List<String>? reasons}) {
    _totalMatches++;
    if (success) {
      _successfulMatches++;
      if (reasons != null) {
        for (final reason in reasons) {
          _matchReasonCount[reason] = (_matchReasonCount[reason] ?? 0) + 1;
        }
      }
    } else {
      _failedMatches++;
    }
  }

  /// 理由別のマッチ数
  int getMatchCountByReason(String reason) {
    return _matchReasonCount[reason] ?? 0;
  }

  /// 統計をリセット
  void reset() {
    _totalMatches = 0;
    _successfulMatches = 0;
    _failedMatches = 0;
    _matchReasonCount.clear();
  }

  /// 統計を取得
  Map<String, dynamic> getStats() {
    return {
      'totalMatches': _totalMatches,
      'successfulMatches': _successfulMatches,
      'failedMatches': _failedMatches,
      'successRate': successRate,
      'matchReasons': Map.unmodifiable(_matchReasonCount),
    };
  }
}
