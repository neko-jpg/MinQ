import 'package:cloud_firestore/cloud_firestore.dart';

/// ストリーク保護サービス
class StreakProtectionService {
  final FirebaseFirestore _firestore;

  StreakProtectionService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  /// クエストを一時停止
  Future<void> pauseQuest({
    required String questId,
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
    String? reason,
  }) async {
    await _firestore.collection('questPauses').add({
      'questId': questId,
      'userId': userId,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'reason': reason,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// クエストの一時停止を解除
  Future<void> resumeQuest({
    required String questId,
    required String userId,
  }) async {
    final snapshot =
        await _firestore
            .collection('questPauses')
            .where('questId', isEqualTo: questId)
            .where('userId', isEqualTo: userId)
            .where('endDate', isGreaterThan: Timestamp.now())
            .get();

    for (final doc in snapshot.docs) {
      await doc.reference.delete();
    }
  }

  /// クエストが一時停止中かチェック
  Future<bool> isQuestPaused({
    required String questId,
    required String userId,
    DateTime? date,
  }) async {
    final checkDate = date ?? DateTime.now();

    final snapshot =
        await _firestore
            .collection('questPauses')
            .where('questId', isEqualTo: questId)
            .where('userId', isEqualTo: userId)
            .where(
              'startDate',
              isLessThanOrEqualTo: Timestamp.fromDate(checkDate),
            )
            .where(
              'endDate',
              isGreaterThanOrEqualTo: Timestamp.fromDate(checkDate),
            )
            .get();

    return snapshot.docs.isNotEmpty;
  }

  /// 凍結日を追加
  Future<void> addFreezeDay({
    required String questId,
    required String userId,
    required DateTime date,
    String? reason,
  }) async {
    await _firestore.collection('freezeDays').add({
      'questId': questId,
      'userId': userId,
      'date': Timestamp.fromDate(date),
      'reason': reason,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// 凍結日を削除
  Future<void> removeFreezeDay({
    required String questId,
    required String userId,
    required DateTime date,
  }) async {
    final snapshot =
        await _firestore
            .collection('freezeDays')
            .where('questId', isEqualTo: questId)
            .where('userId', isEqualTo: userId)
            .where('date', isEqualTo: Timestamp.fromDate(date))
            .get();

    for (final doc in snapshot.docs) {
      await doc.reference.delete();
    }
  }

  /// 指定日が凍結日かチェック
  Future<bool> isFreezeDay({
    required String questId,
    required String userId,
    required DateTime date,
  }) async {
    final snapshot =
        await _firestore
            .collection('freezeDays')
            .where('questId', isEqualTo: questId)
            .where('userId', isEqualTo: userId)
            .where('date', isEqualTo: Timestamp.fromDate(date))
            .get();

    return snapshot.docs.isNotEmpty;
  }

  /// スキップ可能回数を取得
  Future<int> getAvailableSkips({
    required String questId,
    required String userId,
  }) async {
    final questDoc = await _firestore.collection('quests').doc(questId).get();

    final data = questDoc.data();
    if (data == null) return 0;

    final maxSkips = data['maxSkipsPerMonth'] as int? ?? 3;
    final usedSkips = await _getUsedSkipsThisMonth(questId, userId);

    return maxSkips - usedSkips;
  }

  /// 今月使用したスキップ回数を取得
  Future<int> _getUsedSkipsThisMonth(String questId, String userId) async {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0);

    final snapshot =
        await _firestore
            .collection('freezeDays')
            .where('questId', isEqualTo: questId)
            .where('userId', isEqualTo: userId)
            .where(
              'date',
              isGreaterThanOrEqualTo: Timestamp.fromDate(startOfMonth),
            )
            .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endOfMonth))
            .get();

    return snapshot.docs.length;
  }

  /// ストリークを計算（一時停止と凍結日を考慮）
  Future<int> calculateStreak({
    required String questId,
    required String userId,
    required List<DateTime> completionDates,
  }) async {
    if (completionDates.isEmpty) return 0;

    int streak = 0;
    DateTime currentDate = DateTime.now();

    while (true) {
      final dateOnly = DateTime(
        currentDate.year,
        currentDate.month,
        currentDate.day,
      );

      // 一時停止中または凍結日の場合はスキップ
      final isPaused = await isQuestPaused(
        questId: questId,
        userId: userId,
        date: dateOnly,
      );

      final isFrozen = await isFreezeDay(
        questId: questId,
        userId: userId,
        date: dateOnly,
      );

      if (isPaused || isFrozen) {
        currentDate = currentDate.subtract(const Duration(days: 1));
        continue;
      }

      // 完了しているかチェック
      final isCompleted = completionDates.any((date) {
        final completionDateOnly = DateTime(date.year, date.month, date.day);
        return completionDateOnly.isAtSameMomentAs(dateOnly);
      });

      if (isCompleted) {
        streak++;
        currentDate = currentDate.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }

    return streak;
  }
}

/// ストリーク保護タイプ
enum StreakProtectionType {
  /// 一時停止
  pause,

  /// 凍結日
  freeze,

  /// スキップ
  skip,
}

/// ストリーク保護設定
class StreakProtectionConfig {
  final int maxSkipsPerMonth;
  final int maxPauseDays;
  final bool allowWeekendSkip;
  final bool allowHolidaySkip;

  const StreakProtectionConfig({
    this.maxSkipsPerMonth = 3,
    this.maxPauseDays = 14,
    this.allowWeekendSkip = true,
    this.allowHolidaySkip = true,
  });

  /// デフォルト設定
  static const defaultConfig = StreakProtectionConfig();

  /// 厳格な設定
  static const strict = StreakProtectionConfig(
    maxSkipsPerMonth: 1,
    maxPauseDays: 7,
    allowWeekendSkip: false,
    allowHolidaySkip: false,
  );

  /// 緩い設定
  static const relaxed = StreakProtectionConfig(
    maxSkipsPerMonth: 5,
    maxPauseDays: 30,
    allowWeekendSkip: true,
    allowHolidaySkip: true,
  );
}

/// 一時停止理由
enum PauseReason { vacation, illness, work, personal, other }

extension PauseReasonExtension on PauseReason {
  String get displayName {
    switch (this) {
      case PauseReason.vacation:
        return '休暇';
      case PauseReason.illness:
        return '体調不良';
      case PauseReason.work:
        return '仕事';
      case PauseReason.personal:
        return '個人的な理由';
      case PauseReason.other:
        return 'その他';
    }
  }
}

/// ストリーク保護履歴
class StreakProtectionHistory {
  final String id;
  final String questId;
  final String userId;
  final StreakProtectionType type;
  final DateTime startDate;
  final DateTime? endDate;
  final String? reason;
  final DateTime createdAt;

  const StreakProtectionHistory({
    required this.id,
    required this.questId,
    required this.userId,
    required this.type,
    required this.startDate,
    this.endDate,
    this.reason,
    required this.createdAt,
  });

  /// Firestoreから生成
  factory StreakProtectionHistory.fromFirestore(
    DocumentSnapshot doc,
    StreakProtectionType type,
  ) {
    final data = doc.data() as Map<String, dynamic>;
    return StreakProtectionHistory(
      id: doc.id,
      questId: data['questId'] as String,
      userId: data['userId'] as String,
      type: type,
      startDate: (data['startDate'] as Timestamp).toDate(),
      endDate:
          data['endDate'] != null
              ? (data['endDate'] as Timestamp).toDate()
              : null,
      reason: data['reason'] as String?,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }
}

/// ストリーク統計
class StreakStats {
  final int currentStreak;
  final int longestStreak;
  final int totalCompletions;
  final int totalSkips;
  final int totalPauseDays;
  final int totalFreezeDays;

  const StreakStats({
    required this.currentStreak,
    required this.longestStreak,
    required this.totalCompletions,
    required this.totalSkips,
    required this.totalPauseDays,
    required this.totalFreezeDays,
  });

  /// 完了率
  double get completionRate {
    final total = totalCompletions + totalSkips;
    return total > 0 ? totalCompletions / total : 0.0;
  }

  /// 保護使用率
  double get protectionUsageRate {
    final total =
        totalCompletions + totalSkips + totalPauseDays + totalFreezeDays;
    final protected = totalSkips + totalPauseDays + totalFreezeDays;
    return total > 0 ? protected / total : 0.0;
  }
}

/// ストリーク保護マネージャー
class StreakProtectionManager {
  final StreakProtectionService _service;
  final StreakProtectionConfig _config;

  StreakProtectionManager({
    required StreakProtectionService service,
    StreakProtectionConfig config = StreakProtectionConfig.defaultConfig,
  }) : _service = service,
       _config = config;

  /// スキップ可能かチェック
  Future<bool> canSkip({
    required String questId,
    required String userId,
  }) async {
    final availableSkips = await _service.getAvailableSkips(
      questId: questId,
      userId: userId,
    );
    return availableSkips > 0;
  }

  /// 一時停止可能かチェック
  Future<bool> canPause({
    required String questId,
    required String userId,
    required int requestedDays,
  }) async {
    return requestedDays <= _config.maxPauseDays;
  }

  /// 週末スキップが許可されているかチェック
  bool canSkipWeekend(DateTime date) {
    return _config.allowWeekendSkip &&
        (date.weekday == DateTime.saturday || date.weekday == DateTime.sunday);
  }

  /// 祝日スキップが許可されているかチェック
  bool canSkipHoliday(DateTime date) {
    // TODO: 祝日判定ロジックを実装
    return _config.allowHolidaySkip;
  }
}

/// ストリーク回復システム
class StreakRecoverySystem {
  /// ストリークを回復（課金または広告視聴）
  Future<bool> recoverStreak({
    required String questId,
    required String userId,
    required RecoveryMethod method,
  }) async {
    // TODO: 課金または広告視聴の処理を実装
    return true;
  }

  /// 回復可能かチェック
  Future<bool> canRecover({
    required String questId,
    required String userId,
  }) async {
    // 最後の完了から24時間以内のみ回復可能
    // TODO: 実装
    return true;
  }
}

/// 回復方法
enum RecoveryMethod {
  /// 課金
  payment,

  /// 広告視聴
  watchAd,

  /// 無料（1回のみ）
  free,
}
