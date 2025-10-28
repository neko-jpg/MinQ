import 'dart:async';
import 'dart:developer';
import 'dart:math' as math;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';

/// ソーシャルプルーフサービス
/// リアルタイムアクティビティを追跡し、社会的な習慣化を促進
class SocialProofService {
  static SocialProofService? _instance;
  static SocialProofService get instance =>
      _instance ??= SocialProofService._();

  SocialProofService._();

  FirebaseFirestore? _firestore;
  FirebaseFirestore get firestore {
    if (_firestore == null) {
      try {
        _firestore = FirebaseFirestore.instance;
      } catch (e) {
        // Firebase が初期化されていない場合はnullを返す
        throw Exception('Firebase is not initialized');
      }
    }
    return _firestore!;
  }

  StreamSubscription<QuerySnapshot>? _activitySubscription;
  StreamSubscription<QuerySnapshot>? _liveUsersSubscription;

  final StreamController<LiveActivityUpdate> _activityController =
      StreamController<LiveActivityUpdate>.broadcast();

  final StreamController<SocialStats> _statsController =
      StreamController<SocialStats>.broadcast();

  Stream<LiveActivityUpdate> get activityStream => _activityController.stream;
  Stream<SocialStats> get statsStream => _statsController.stream;

  bool _isActive = false;
  String? _currentUserId;
  SocialSettings _settings = const SocialSettings();

  final Map<String, UserActivity> _activeUsers = {};
  final List<ActivityEvent> _recentActivities = [];

  /// ソーシャルプルーフの開始
  Future<void> startSocialProof({
    required String userId,
    SocialSettings? settings,
  }) async {
    if (_isActive) {
      await stopSocialProof();
    }

    _currentUserId = userId;
    _settings = settings ?? const SocialSettings();
    _isActive = true;

    await _initializeUserPresence();
    _startListeningToActivities();
    _startListeningToLiveUsers();

    log('SocialProof: ソーシャルプルーフ開始 - $userId');
  }

  /// ソーシャルプルーフの停止
  Future<void> stopSocialProof() async {
    if (!_isActive) return;

    await _removeUserPresence();

    _activitySubscription?.cancel();
    _liveUsersSubscription?.cancel();

    _activeUsers.clear();
    _recentActivities.clear();

    _isActive = false;
    _currentUserId = null;

    log('SocialProof: ソーシャルプルーフ停止');
  }

  /// ユーザープレゼンスの初期化
  Future<void> _initializeUserPresence() async {
    if (_currentUserId == null) return;

    try {
      await firestore.collection('live_users').doc(_currentUserId).set({
        'userId': _currentUserId,
        'isOnline': true,
        'lastSeen': FieldValue.serverTimestamp(),
        'currentActivity': null,
        'avatar': _generateAnonymousAvatar(),
        'nickname': _generateAnonymousNickname(),
        'settings': {
          'showActivity': _settings.showActivity,
          'allowInteraction': _settings.allowInteraction,
        },
      });

      log('SocialProof: ユーザープレゼンス初期化完了');
    } catch (e) {
      log('SocialProof: プレゼンス初期化エラー - $e');
    }
  }

  /// ユーザープレゼンスの削除
  Future<void> _removeUserPresence() async {
    if (_currentUserId == null) return;

    try {
      await firestore.collection('live_users').doc(_currentUserId).update({
        'isOnline': false,
        'lastSeen': FieldValue.serverTimestamp(),
        'currentActivity': null,
      });

      log('SocialProof: ユーザープレゼンス削除完了');
    } catch (e) {
      log('SocialProof: プレゼンス削除エラー - $e');
    }
  }

  /// アクティビティの監視開始
  void _startListeningToActivities() {
    _activitySubscription = firestore
        .collection('live_activities')
        .where(
          'timestamp',
          isGreaterThan: DateTime.now().subtract(const Duration(minutes: 30)),
        )
        .orderBy('timestamp', descending: true)
        .limit(50)
        .snapshots()
        .listen(
          _handleActivityUpdate,
          onError: (error) => log('SocialProof: アクティビティ監視エラー - $error'),
        );
  }

  /// ライブユーザーの監視開始
  void _startListeningToLiveUsers() {
    _liveUsersSubscription = firestore
        .collection('live_users')
        .where('isOnline', isEqualTo: true)
        .where(
          'lastSeen',
          isGreaterThan: DateTime.now().subtract(const Duration(minutes: 5)),
        )
        .snapshots()
        .listen(
          _handleLiveUsersUpdate,
          onError: (error) => log('SocialProof: ライブユーザー監視エラー - $error'),
        );
  }

  /// アクティビティ更新の処理
  void _handleActivityUpdate(QuerySnapshot snapshot) {
    try {
      _recentActivities.clear();

      for (final doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final activity = ActivityEvent.fromMap(data);
        _recentActivities.add(activity);
      }

      // アクティビティ統計の更新
      _updateActivityStats();

      // 最新のアクティビティを通知
      if (_recentActivities.isNotEmpty) {
        final latest = _recentActivities.first;
        _activityController.add(
          LiveActivityUpdate(
            type: ActivityUpdateType.newActivity,
            activity: latest,
            totalActiveUsers: _activeUsers.length,
          ),
        );
      }
    } catch (e) {
      log('SocialProof: アクティビティ更新処理エラー - $e');
    }
  }

  /// ライブユーザー更新の処理
  void _handleLiveUsersUpdate(QuerySnapshot snapshot) {
    try {
      _activeUsers.clear();

      for (final doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final user = UserActivity.fromMap(data);
        _activeUsers[user.userId] = user;
      }

      // 統計の更新
      _updateSocialStats();

      log('SocialProof: アクティブユーザー数: ${_activeUsers.length}');
    } catch (e) {
      log('SocialProof: ライブユーザー更新処理エラー - $e');
    }
  }

  /// アクティビティ統計の更新
  void _updateActivityStats() {
    final now = DateTime.now();
    final last5Minutes = now.subtract(const Duration(minutes: 5));
    final last15Minutes = now.subtract(const Duration(minutes: 15));

    final recent5min =
        _recentActivities
            .where((a) => a.timestamp.isAfter(last5Minutes))
            .toList();

    final recent15min =
        _recentActivities
            .where((a) => a.timestamp.isAfter(last15Minutes))
            .toList();

    // カテゴリ別の統計
    final categoryStats = <String, CategoryActivity>{};

    for (final activity in recent15min) {
      final category = activity.category;
      if (!categoryStats.containsKey(category)) {
        categoryStats[category] = CategoryActivity(
          category: category,
          activeUsers: <String>{},
          recentCompletions: 0,
        );
      }

      categoryStats[category]!.activeUsers.add(activity.userId);
      if (activity.type == ActivityType.completion) {
        categoryStats[category]!.recentCompletions++;
      }
    }

    _activityController.add(
      LiveActivityUpdate(
        type: ActivityUpdateType.statsUpdate,
        totalActiveUsers: _activeUsers.length,
        recentActivities5min: recent5min.length,
        recentActivities15min: recent15min.length,
        categoryStats: categoryStats,
      ),
    );
  }

  /// ソーシャル統計の更新
  void _updateSocialStats() {
    final stats = SocialStats(
      totalOnlineUsers: _activeUsers.length,
      activeInLastHour: _calculateActiveInLastHour(),
      topCategories: _getTopCategories(),
      encouragementMessages: _generateEncouragementMessages(),
      timestamp: DateTime.now(),
    );

    _statsController.add(stats);
  }

  /// 習慣開始の記録
  Future<void> recordHabitStart({
    required String habitId,
    required String habitTitle,
    required String category,
    Duration? estimatedDuration,
  }) async {
    if (!_isActive || _currentUserId == null) return;

    try {
      // ライブアクティビティに記録
      await firestore.collection('live_activities').add({
        'userId': _currentUserId,
        'habitId': habitId,
        'habitTitle': habitTitle,
        'category': category,
        'type': 'start',
        'timestamp': FieldValue.serverTimestamp(),
        'estimatedDuration': estimatedDuration?.inMinutes,
        'avatar': _generateAnonymousAvatar(),
        'nickname': _generateAnonymousNickname(),
      });

      // ユーザーの現在のアクティビティを更新
      await firestore.collection('live_users').doc(_currentUserId).update({
        'currentActivity': {
          'habitId': habitId,
          'habitTitle': habitTitle,
          'category': category,
          'startedAt': FieldValue.serverTimestamp(),
          'estimatedDuration': estimatedDuration?.inMinutes,
        },
        'lastSeen': FieldValue.serverTimestamp(),
      });

      // 触覚フィードバック
      if (_settings.enableHaptics) {
        HapticFeedback.lightImpact();
      }

      log('SocialProof: 習慣開始記録 - $habitTitle');
    } catch (e) {
      log('SocialProof: 習慣開始記録エラー - $e');
    }
  }

  /// 習慣完了の記録
  Future<void> recordHabitCompletion({
    required String habitId,
    required String habitTitle,
    required String category,
    Duration? actualDuration,
  }) async {
    if (!_isActive || _currentUserId == null) return;

    try {
      // ライブアクティビティに記録
      await firestore.collection('live_activities').add({
        'userId': _currentUserId,
        'habitId': habitId,
        'habitTitle': habitTitle,
        'category': category,
        'type': 'completion',
        'timestamp': FieldValue.serverTimestamp(),
        'actualDuration': actualDuration?.inMinutes,
        'avatar': _generateAnonymousAvatar(),
        'nickname': _generateAnonymousNickname(),
      });

      // ユーザーの現在のアクティビティをクリア
      await firestore.collection('live_users').doc(_currentUserId).update({
        'currentActivity': null,
        'lastSeen': FieldValue.serverTimestamp(),
      });

      // 完了時の特別な通知
      _activityController.add(
        LiveActivityUpdate(
          type: ActivityUpdateType.completion,
          activity: ActivityEvent(
            userId: _currentUserId!,
            habitId: habitId,
            habitTitle: habitTitle,
            category: category,
            type: ActivityType.completion,
            timestamp: DateTime.now(),
            avatar: _generateAnonymousAvatar(),
            nickname: _generateAnonymousNickname(),
          ),
          totalActiveUsers: _activeUsers.length,
        ),
      );

      // 祝福エフェクト
      if (_settings.enableCelebration) {
        _triggerCelebrationEffect();
      }

      log('SocialProof: 習慣完了記録 - $habitTitle');
    } catch (e) {
      log('SocialProof: 習慣完了記録エラー - $e');
    }
  }

  /// 励ましスタンプの送信
  Future<void> sendEncouragementStamp({
    required String targetUserId,
    required EncouragementType stampType,
  }) async {
    if (!_isActive || _currentUserId == null || !_settings.allowInteraction) {
      return;
    }

    try {
      await firestore.collection('encouragements').add({
        'fromUserId': _currentUserId,
        'toUserId': targetUserId,
        'type': stampType.name,
        'timestamp': FieldValue.serverTimestamp(),
        'fromAvatar': _generateAnonymousAvatar(),
        'fromNickname': _generateAnonymousNickname(),
      });

      // 送信者にフィードバック
      if (_settings.enableHaptics) {
        HapticFeedback.mediumImpact();
      }

      _activityController.add(
        LiveActivityUpdate(
          type: ActivityUpdateType.encouragement,
          encouragement: EncouragementEvent(
            fromUserId: _currentUserId!,
            toUserId: targetUserId,
            type: stampType,
            timestamp: DateTime.now(),
          ),
          totalActiveUsers: _activeUsers.length,
        ),
      );

      log('SocialProof: 励ましスタンプ送信 - ${stampType.name}');
    } catch (e) {
      log('SocialProof: 励ましスタンプ送信エラー - $e');
    }
  }

  /// 現在のアクティビティ統計を取得
  Future<CurrentActivityStats> getCurrentStats() async {
    final now = DateTime.now();

    // カテゴリ別のアクティブユーザー数を計算
    final categoryUsers = <String, Set<String>>{};

    for (final user in _activeUsers.values) {
      if (user.currentActivity != null) {
        final category = user.currentActivity!.category;
        categoryUsers.putIfAbsent(category, () => <String>{}).add(user.userId);
      }
    }

    // 最も人気のあるカテゴリを特定
    String? mostPopularCategory;
    int maxUsers = 0;

    categoryUsers.forEach((category, users) {
      if (users.length > maxUsers) {
        maxUsers = users.length;
        mostPopularCategory = category;
      }
    });

    return CurrentActivityStats(
      totalOnlineUsers: _activeUsers.length,
      totalActiveUsers:
          _activeUsers.values.where((u) => u.currentActivity != null).length,
      categoryStats: categoryUsers.map((k, v) => MapEntry(k, v.length)),
      mostPopularCategory: mostPopularCategory,
      mostPopularCategoryUsers: maxUsers,
      recentCompletions:
          _recentActivities
              .where((a) => a.type == ActivityType.completion)
              .where((a) => now.difference(a.timestamp).inMinutes <= 15)
              .length,
    );
  }

  /// 特定カテゴリのライブ情報を取得
  Future<CategoryLiveInfo> getCategoryLiveInfo(String category) async {
    final categoryUsers =
        _activeUsers.values
            .where((u) => u.currentActivity?.category == category)
            .toList();

    final recentCompletions =
        _recentActivities
            .where((a) => a.category == category)
            .where((a) => a.type == ActivityType.completion)
            .where(
              (a) => DateTime.now().difference(a.timestamp).inMinutes <= 30,
            )
            .toList();

    return CategoryLiveInfo(
      category: category,
      activeUsers: categoryUsers.length,
      recentCompletions: recentCompletions.length,
      averageSessionTime: _calculateAverageSessionTime(category),
      popularHabits: _getPopularHabits(category),
      encouragementMessages: _generateCategoryEncouragement(
        category,
        categoryUsers.length,
      ),
    );
  }

  /// 祝福エフェクトのトリガー
  void _triggerCelebrationEffect() {
    // 拍手や花火などのエフェクトをトリガー
    _activityController.add(
      LiveActivityUpdate(
        type: ActivityUpdateType.celebration,
        totalActiveUsers: _activeUsers.length,
      ),
    );
  }

  /// 匿名アバターの生成
  String _generateAnonymousAvatar() {
    final avatars = [
      '🐱',
      '🐶',
      '🐰',
      '🐻',
      '🐼',
      '🦊',
      '🐸',
      '🐧',
      '🦋',
      '🌟',
    ];
    return avatars[math.Random().nextInt(avatars.length)];
  }

  /// 匿名ニックネームの生成
  String _generateAnonymousNickname() {
    final adjectives = ['頑張る', '元気な', '優しい', '強い', '明るい', '素敵な'];
    final nouns = ['ユーザー', '仲間', '友達', 'パートナー', 'メンバー'];

    final adj = adjectives[math.Random().nextInt(adjectives.length)];
    final noun = nouns[math.Random().nextInt(nouns.length)];

    return '$adj$noun';
  }

  /// 過去1時間のアクティブユーザー数を計算
  int _calculateActiveInLastHour() {
    final oneHourAgo = DateTime.now().subtract(const Duration(hours: 1));
    return _recentActivities
        .where((a) => a.timestamp.isAfter(oneHourAgo))
        .map((a) => a.userId)
        .toSet()
        .length;
  }

  /// トップカテゴリを取得
  List<String> _getTopCategories() {
    final categoryCount = <String, int>{};

    for (final activity in _recentActivities) {
      categoryCount[activity.category] =
          (categoryCount[activity.category] ?? 0) + 1;
    }

    final sorted =
        categoryCount.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));

    return sorted.take(3).map((e) => e.key).toList();
  }

  /// 励ましメッセージの生成
  List<String> _generateEncouragementMessages() {
    final messages = <String>[];

    if (_activeUsers.length > 10) {
      messages.add('今${_activeUsers.length}人が一緒に頑張っています！');
    }

    final recentCompletions =
        _recentActivities
            .where((a) => a.type == ActivityType.completion)
            .where(
              (a) => DateTime.now().difference(a.timestamp).inMinutes <= 15,
            )
            .length;

    if (recentCompletions > 5) {
      messages.add('この15分で$recentCompletions個の習慣が完了しました！');
    }

    return messages;
  }

  /// 平均セッション時間の計算
  Duration _calculateAverageSessionTime(String category) {
    final completions =
        _recentActivities
            .where(
              (a) =>
                  a.category == category && a.type == ActivityType.completion,
            )
            .toList();

    if (completions.isEmpty) return const Duration(minutes: 15);

    var totalMinutes = 0;
    var count = 0;

    for (final completion in completions) {
      if (completion.actualDuration != null) {
        totalMinutes += completion.actualDuration!;
        count++;
      }
    }

    if (count == 0) return const Duration(minutes: 15);

    return Duration(minutes: (totalMinutes / count).round());
  }

  /// 人気の習慣を取得
  List<String> _getPopularHabits(String category) {
    final habitCount = <String, int>{};

    for (final activity in _recentActivities) {
      if (activity.category == category) {
        habitCount[activity.habitTitle] =
            (habitCount[activity.habitTitle] ?? 0) + 1;
      }
    }

    final sorted =
        habitCount.entries.toList()..sort((a, b) => b.value.compareTo(a.value));

    return sorted.take(3).map((e) => e.key).toList();
  }

  /// カテゴリ別励ましメッセージの生成
  List<String> _generateCategoryEncouragement(
    String category,
    int activeUsers,
  ) {
    final messages = <String>[];

    switch (category) {
      case 'fitness':
        if (activeUsers > 0) {
          messages.add('今$activeUsers人が運動中です！一緒に体を動かしましょう！');
        }
        break;
      case 'mindfulness':
        if (activeUsers > 0) {
          messages.add('$activeUsers人が瞑想中です。心を落ち着けて参加しませんか？');
        }
        break;
      case 'learning':
        if (activeUsers > 0) {
          messages.add('$activeUsers人が学習中です。知識を深める時間ですね！');
        }
        break;
      default:
        if (activeUsers > 0) {
          messages.add('$activeUsers人が$categoryに取り組んでいます！');
        }
    }

    return messages;
  }

  /// 設定の更新
  void updateSettings(SocialSettings settings) {
    _settings = settings;

    // プライバシー設定の更新
    if (_currentUserId != null) {
      firestore.collection('live_users').doc(_currentUserId).update({
        'settings': {
          'showActivity': settings.showActivity,
          'allowInteraction': settings.allowInteraction,
        },
      });
    }
  }

  /// リソースの解放
  void dispose() {
    _activitySubscription?.cancel();
    _liveUsersSubscription?.cancel();
    _activityController.close();
    _statsController.close();

    _activeUsers.clear();
    _recentActivities.clear();

    _isActive = false;
    _currentUserId = null;
  }
}

// ========== データクラス ==========

/// ソーシャル設定
class SocialSettings {
  final bool showActivity;
  final bool allowInteraction;
  final bool enableHaptics;
  final bool enableCelebration;

  const SocialSettings({
    this.showActivity = true,
    this.allowInteraction = true,
    this.enableHaptics = true,
    this.enableCelebration = true,
  });

  SocialSettings copyWith({
    bool? showActivity,
    bool? allowInteraction,
    bool? enableHaptics,
    bool? enableCelebration,
  }) {
    return SocialSettings(
      showActivity: showActivity ?? this.showActivity,
      allowInteraction: allowInteraction ?? this.allowInteraction,
      enableHaptics: enableHaptics ?? this.enableHaptics,
      enableCelebration: enableCelebration ?? this.enableCelebration,
    );
  }
}

/// ライブアクティビティ更新
class LiveActivityUpdate {
  final ActivityUpdateType type;
  final ActivityEvent? activity;
  final EncouragementEvent? encouragement;
  final int totalActiveUsers;
  final int? recentActivities5min;
  final int? recentActivities15min;
  final Map<String, CategoryActivity>? categoryStats;

  LiveActivityUpdate({
    required this.type,
    this.activity,
    this.encouragement,
    required this.totalActiveUsers,
    this.recentActivities5min,
    this.recentActivities15min,
    this.categoryStats,
  });
}

/// アクティビティイベント
class ActivityEvent {
  final String userId;
  final String habitId;
  final String habitTitle;
  final String category;
  final ActivityType type;
  final DateTime timestamp;
  final String avatar;
  final String nickname;
  final int? estimatedDuration;
  final int? actualDuration;

  ActivityEvent({
    required this.userId,
    required this.habitId,
    required this.habitTitle,
    required this.category,
    required this.type,
    required this.timestamp,
    required this.avatar,
    required this.nickname,
    this.estimatedDuration,
    this.actualDuration,
  });

  factory ActivityEvent.fromMap(Map<String, dynamic> map) {
    return ActivityEvent(
      userId: map['userId'] ?? '',
      habitId: map['habitId'] ?? '',
      habitTitle: map['habitTitle'] ?? '',
      category: map['category'] ?? '',
      type: ActivityType.values.firstWhere(
        (t) => t.name == map['type'],
        orElse: () => ActivityType.start,
      ),
      timestamp: (map['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      avatar: map['avatar'] ?? '🌟',
      nickname: map['nickname'] ?? '匿名ユーザー',
      estimatedDuration: map['estimatedDuration'],
      actualDuration: map['actualDuration'],
    );
  }
}

/// ユーザーアクティビティ
class UserActivity {
  final String userId;
  final bool isOnline;
  final DateTime lastSeen;
  final CurrentHabitActivity? currentActivity;
  final String avatar;
  final String nickname;

  UserActivity({
    required this.userId,
    required this.isOnline,
    required this.lastSeen,
    this.currentActivity,
    required this.avatar,
    required this.nickname,
  });

  factory UserActivity.fromMap(Map<String, dynamic> map) {
    return UserActivity(
      userId: map['userId'] ?? '',
      isOnline: map['isOnline'] ?? false,
      lastSeen: (map['lastSeen'] as Timestamp?)?.toDate() ?? DateTime.now(),
      currentActivity:
          map['currentActivity'] != null
              ? CurrentHabitActivity.fromMap(map['currentActivity'])
              : null,
      avatar: map['avatar'] ?? '🌟',
      nickname: map['nickname'] ?? '匿名ユーザー',
    );
  }
}

/// 現在の習慣アクティビティ
class CurrentHabitActivity {
  final String habitId;
  final String habitTitle;
  final String category;
  final DateTime startedAt;
  final int? estimatedDuration;

  CurrentHabitActivity({
    required this.habitId,
    required this.habitTitle,
    required this.category,
    required this.startedAt,
    this.estimatedDuration,
  });

  factory CurrentHabitActivity.fromMap(Map<String, dynamic> map) {
    return CurrentHabitActivity(
      habitId: map['habitId'] ?? '',
      habitTitle: map['habitTitle'] ?? '',
      category: map['category'] ?? '',
      startedAt: (map['startedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      estimatedDuration: map['estimatedDuration'],
    );
  }
}

/// 励ましイベント
class EncouragementEvent {
  final String fromUserId;
  final String toUserId;
  final EncouragementType type;
  final DateTime timestamp;

  EncouragementEvent({
    required this.fromUserId,
    required this.toUserId,
    required this.type,
    required this.timestamp,
  });
}

/// カテゴリアクティビティ
class CategoryActivity {
  final String category;
  final Set<String> activeUsers;
  int recentCompletions;

  CategoryActivity({
    required this.category,
    required this.activeUsers,
    required this.recentCompletions,
  });
}

/// ソーシャル統計
class SocialStats {
  final int totalOnlineUsers;
  final int activeInLastHour;
  final List<String> topCategories;
  final List<String> encouragementMessages;
  final DateTime timestamp;

  SocialStats({
    required this.totalOnlineUsers,
    required this.activeInLastHour,
    required this.topCategories,
    required this.encouragementMessages,
    required this.timestamp,
  });
}

/// 現在のアクティビティ統計
class CurrentActivityStats {
  final int totalOnlineUsers;
  final int totalActiveUsers;
  final Map<String, int> categoryStats;
  final String? mostPopularCategory;
  final int mostPopularCategoryUsers;
  final int recentCompletions;

  CurrentActivityStats({
    required this.totalOnlineUsers,
    required this.totalActiveUsers,
    required this.categoryStats,
    this.mostPopularCategory,
    required this.mostPopularCategoryUsers,
    required this.recentCompletions,
  });
}

/// カテゴリライブ情報
class CategoryLiveInfo {
  final String category;
  final int activeUsers;
  final int recentCompletions;
  final Duration averageSessionTime;
  final List<String> popularHabits;
  final List<String> encouragementMessages;

  CategoryLiveInfo({
    required this.category,
    required this.activeUsers,
    required this.recentCompletions,
    required this.averageSessionTime,
    required this.popularHabits,
    required this.encouragementMessages,
  });
}

/// 列挙型
enum ActivityType { start, completion, pause, resume }

enum ActivityUpdateType {
  newActivity,
  completion,
  encouragement,
  celebration,
  statsUpdate,
}

enum EncouragementType {
  thumbsUp('👍'),
  heart('❤️'),
  fire('🔥'),
  clap('👏'),
  star('⭐'),
  muscle('💪');

  const EncouragementType(this.emoji);
  final String emoji;
}
