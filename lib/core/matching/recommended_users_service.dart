import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:minq/core/logging/app_logger.dart';

/// おすすめユーザーサービス
class RecommendedUsersService {
  final FirebaseFirestore _firestore;

  RecommendedUsersService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  /// おすすめユーザーを取得
  Future<List<RecommendedUser>> getRecommendedUsers({
    required String currentUserId,
    int limit = 10,
  }) async {
    try {
      // 現在のユーザー情報を取得
      final currentUserDoc =
          await _firestore.collection('users').doc(currentUserId).get();

      if (!currentUserDoc.exists) {
        return [];
      }

      final currentUserData = currentUserDoc.data()!;
      final currentUserTimezone = currentUserData['timezone'] as String?;
      final currentUserLanguage = currentUserData['language'] as String?;
      final currentUserGoals = List<String>.from(
        currentUserData['goals'] ?? [],
      );

      // ブロックリストを取得
      final blockedUsers = await _getBlockedUsers(currentUserId);

      // おすすめユーザーを検索
      final query = _firestore
          .collection('users')
          .where('isActive', isEqualTo: true)
          .where('lookingForPair', isEqualTo: true)
          .limit(limit * 2); // 多めに取得してフィルタリング

      final snapshot = await query.get();

      final recommendations = <RecommendedUser>[];

      for (final doc in snapshot.docs) {
        if (doc.id == currentUserId) continue;
        if (blockedUsers.contains(doc.id)) continue;

        final userData = doc.data();
        final score = _calculateMatchScore(
          currentUserTimezone: currentUserTimezone,
          currentUserLanguage: currentUserLanguage,
          currentUserGoals: currentUserGoals,
          targetUserData: userData,
        );

        recommendations.add(
          RecommendedUser(
            userId: doc.id,
            nickname: userData['nickname'] as String? ?? 'Unknown',
            avatarUrl: userData['avatarUrl'] as String?,
            timezone: userData['timezone'] as String?,
            language: userData['language'] as String?,
            goals: List<String>.from(userData['goals'] ?? []),
            activityScore: userData['activityScore'] as int? ?? 0,
            matchScore: score,
          ),
        );
      }

      // スコア順にソート
      recommendations.sort((a, b) => b.matchScore.compareTo(a.matchScore));

      return recommendations.take(limit).toList();
    } catch (e, stack) {
      AppLogger.error(
        'Failed to get recommended users',
        error: e,
        stackTrace: stack,
      );
      return [];
    }
  }

  /// マッチスコアを計算
  double _calculateMatchScore({
    String? currentUserTimezone,
    String? currentUserLanguage,
    required List<String> currentUserGoals,
    required Map<String, dynamic> targetUserData,
  }) {
    double score = 0.0;

    // タイムゾーンが同じ: +30点
    if (currentUserTimezone != null &&
        targetUserData['timezone'] == currentUserTimezone) {
      score += 30.0;
    }

    // 言語が同じ: +20点
    if (currentUserLanguage != null &&
        targetUserData['language'] == currentUserLanguage) {
      score += 20.0;
    }

    // 目標が重複: 1つにつき+10点
    final targetGoals = List<String>.from(targetUserData['goals'] ?? []);
    final commonGoals =
        currentUserGoals.where((goal) => targetGoals.contains(goal)).length;
    score += commonGoals * 10.0;

    // アクティブ度: 0-20点
    final activityScore = targetUserData['activityScore'] as int? ?? 0;
    score += (activityScore / 100.0) * 20.0;

    // 最終ログイン時刻: 最近ログインしているほど高得点
    final lastLoginStr = targetUserData['lastLoginAt'] as String?;
    if (lastLoginStr != null) {
      final lastLogin = DateTime.parse(lastLoginStr);
      final daysSinceLogin = DateTime.now().difference(lastLogin).inDays;

      if (daysSinceLogin == 0) {
        score += 20.0; // 今日ログイン
      } else if (daysSinceLogin <= 3) {
        score += 10.0; // 3日以内
      } else if (daysSinceLogin <= 7) {
        score += 5.0; // 1週間以内
      }
    }

    return score;
  }

  /// ブロックリストを取得
  Future<List<String>> _getBlockedUsers(String userId) async {
    try {
      final doc =
          await _firestore
              .collection('users')
              .doc(userId)
              .collection('blocked')
              .get();

      return doc.docs.map((d) => d.id).toList();
    } catch (e) {
      return [];
    }
  }

  /// アクティブ度を更新
  Future<void> updateActivityScore(String userId) async {
    try {
      final userRef = _firestore.collection('users').doc(userId);
      final userDoc = await userRef.get();

      if (!userDoc.exists) return;

      final userData = userDoc.data()!;
      final currentScore = userData['activityScore'] as int? ?? 0;

      // 簡易的なアクティブ度計算
      // 実際にはクエスト完了数、ログイン頻度などを考慮
      final newScore = (currentScore + 1).clamp(0, 100);

      await userRef.update({
        'activityScore': newScore,
        'lastLoginAt': DateTime.now().toIso8601String(),
      });
    } catch (e, stack) {
      AppLogger.error(
        'Failed to update activity score',
        error: e,
        stackTrace: stack,
      );
    }
  }
}

/// おすすめユーザー
class RecommendedUser {
  final String userId;
  final String nickname;
  final String? avatarUrl;
  final String? timezone;
  final String? language;
  final List<String> goals;
  final int activityScore;
  final double matchScore;

  RecommendedUser({
    required this.userId,
    required this.nickname,
    this.avatarUrl,
    this.timezone,
    this.language,
    required this.goals,
    required this.activityScore,
    required this.matchScore,
  });

  /// マッチ度を取得（0-100）
  int get matchPercentage => matchScore.clamp(0, 100).toInt();
}
