import 'dart:async';
import 'dart:developer';
import 'dart:math' as math;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

/// ハビットバトルサービス
/// 習慣継続で対戦するリアルタイムバトルシステム
class BattleService {
  static BattleService? _instance;
  static BattleService get instance => _instance ??= BattleService._();
  
  BattleService._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  StreamSubscription<QuerySnapshot>? _battleSubscription;
  StreamSubscription<DocumentSnapshot>? _currentBattleSubscription;
  
  final ValueNotifier<List<Battle>> _activeBattles = ValueNotifier([]);
  final ValueNotifier<Battle?> _currentBattle = ValueNotifier(null);
  final ValueNotifier<List<BattleResult>> _battleHistory = ValueNotifier([]);
  
  ValueListenable<List<Battle>> get activeBattles => _activeBattles;
  ValueListenable<Battle?> get currentBattle => _currentBattle;
  ValueListenable<List<BattleResult>> get battleHistory => _battleHistory;

  /// サービスの初期化
  Future<void> initialize(String userId) async {
    try {
      log('BattleService: 初期化開始 - $userId');
      
      // アクティブなバトルを監視
      _battleSubscription = _firestore
          .collection('battles')
          .where('status', isEqualTo: 'active')
          .where('participants', arrayContains: userId)
          .snapshots()
          .listen(_onActiveBattlesChanged);
      
      // バトル履歴を読み込み
      await _loadBattleHistory(userId);
      
      log('BattleService: 初期化完了');
    } catch (e) {
      log('BattleService: 初期化エラー - $e');
    }
  }

  /// サービスの終了
  void dispose() {
    _battleSubscription?.cancel();
    _currentBattleSubscription?.cancel();
    _activeBattles.dispose();
    _currentBattle.dispose();
    _battleHistory.dispose();
  }

  /// バトルの作成
  Future<Battle> createBattle({
    required String creatorId,
    required String habitCategory,
    required Duration duration,
    required int entryFee,
    String? title,
    String? description,
  }) async {
    try {
      log('BattleService: バトル作成開始');
      
      final battleId = _generateBattleId();
      final now = DateTime.now();
      
      final battle = Battle(
        id: battleId,
        title: title ?? '${habitCategory}バトル',
        description: description ?? '$habitCategory習慣で対戦しましょう！',
        category: habitCategory,
        creatorId: creatorId,
        participants: [creatorId],
        maxParticipants: 8,
        entryFee: entryFee,
        totalPrize: entryFee,
        duration: duration,
        status: BattleStatus.waiting,
        createdAt: now,
        startTime: null,
        endTime: null,
        rules: BattleRules.defaultRules(),
        leaderboard: [],
      );
      
      await _firestore.collection('battles').doc(battleId).set(battle.toMap());
      
      log('BattleService: バトル作成完了 - $battleId');
      return battle;
    } catch (e) {
      log('BattleService: バトル作成エラー - $e');
      rethrow;
    }
  }

  /// バトルに参加
  Future<void> joinBattle(String battleId, String userId) async {
    try {
      log('BattleService: バトル参加開始 - $battleId');
      
      final battleDoc = _firestore.collection('battles').doc(battleId);
      
      await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(battleDoc);
        
        if (!snapshot.exists) {
          throw Exception('バトルが見つかりません');
        }
        
        final battle = Battle.fromMap(snapshot.data()!);
        
        if (battle.status != BattleStatus.waiting) {
          throw Exception('このバトルは参加できません');
        }
        
        if (battle.participants.contains(userId)) {
          throw Exception('既に参加しています');
        }
        
        if (battle.participants.length >= battle.maxParticipants) {
          throw Exception('参加者数が上限に達しています');
        }
        
        final updatedParticipants = [...battle.participants, userId];
        final updatedPrize = battle.totalPrize + battle.entryFee;
        
        transaction.update(battleDoc, {
          'participants': updatedParticipants,
          'totalPrize': updatedPrize,
          'updatedAt': FieldValue.serverTimestamp(),
        });
        
        // 参加者が揃ったら自動開始
        if (updatedParticipants.length >= 2) {
          transaction.update(battleDoc, {
            'status': 'active',
            'startTime': FieldValue.serverTimestamp(),
            'endTime': DateTime.now().add(battle.duration).millisecondsSinceEpoch,
          });
        }
      });
      
      log('BattleService: バトル参加完了');
    } catch (e) {
      log('BattleService: バトル参加エラー - $e');
      rethrow;
    }
  }

  /// バトルから退出
  Future<void> leaveBattle(String battleId, String userId) async {
    try {
      log('BattleService: バトル退出開始 - $battleId');
      
      final battleDoc = _firestore.collection('battles').doc(battleId);
      
      await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(battleDoc);
        
        if (!snapshot.exists) {
          throw Exception('バトルが見つかりません');
        }
        
        final battle = Battle.fromMap(snapshot.data()!);
        
        if (battle.status == BattleStatus.finished) {
          throw Exception('終了したバトルからは退出できません');
        }
        
        if (!battle.participants.contains(userId)) {
          throw Exception('このバトルに参加していません');
        }
        
        final updatedParticipants = battle.participants.where((id) => id != userId).toList();
        final refundAmount = battle.entryFee;
        
        transaction.update(battleDoc, {
          'participants': updatedParticipants,
          'totalPrize': battle.totalPrize - refundAmount,
          'updatedAt': FieldValue.serverTimestamp(),
        });
        
        // 参加者がいなくなったらキャンセル
        if (updatedParticipants.isEmpty) {
          transaction.update(battleDoc, {
            'status': 'cancelled',
          });
        }
      });
      
      log('BattleService: バトル退出完了');
    } catch (e) {
      log('BattleService: バトル退出エラー - $e');
      rethrow;
    }
  }

  /// 習慣完了の記録
  Future<void> recordHabitCompletion({
    required String battleId,
    required String userId,
    required String habitId,
    required DateTime completedAt,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      log('BattleService: 習慣完了記録開始');
      
      final completionId = _generateCompletionId();
      
      final completion = BattleCompletion(
        id: completionId,
        battleId: battleId,
        userId: userId,
        habitId: habitId,
        completedAt: completedAt,
        points: _calculatePoints(completedAt, metadata),
        metadata: metadata ?? {},
      );
      
      await _firestore
          .collection('battle_completions')
          .doc(completionId)
          .set(completion.toMap());
      
      // リーダーボードを更新
      await _updateLeaderboard(battleId, userId, completion.points);
      
      log('BattleService: 習慣完了記録完了');
    } catch (e) {
      log('BattleService: 習慣完了記録エラー - $e');
      rethrow;
    }
  }

  /// バトル結果の取得
  Future<BattleResult> getBattleResult(String battleId) async {
    try {
      log('BattleService: バトル結果取得開始 - $battleId');
      
      final battleDoc = await _firestore.collection('battles').doc(battleId).get();
      
      if (!battleDoc.exists) {
        throw Exception('バトルが見つかりません');
      }
      
      final battle = Battle.fromMap(battleDoc.data()!);
      
      if (battle.status != BattleStatus.finished) {
        throw Exception('バトルがまだ終了していません');
      }
      
      // 完了記録を取得
      final completionsQuery = await _firestore
          .collection('battle_completions')
          .where('battleId', isEqualTo: battleId)
          .get();
      
      final completions = completionsQuery.docs
          .map((doc) => BattleCompletion.fromMap(doc.data()))
          .toList();
      
      // 結果を計算
      final result = _calculateBattleResult(battle, completions);
      
      log('BattleService: バトル結果取得完了');
      return result;
    } catch (e) {
      log('BattleService: バトル結果取得エラー - $e');
      rethrow;
    }
  }

  /// 利用可能なバトルを検索
  Future<List<Battle>> searchAvailableBattles({
    String? category,
    int? maxEntryFee,
    Duration? maxDuration,
  }) async {
    try {
      log('BattleService: バトル検索開始');
      
      Query query = _firestore
          .collection('battles')
          .where('status', isEqualTo: 'waiting')
          .orderBy('createdAt', descending: true)
          .limit(20);
      
      if (category != null) {
        query = query.where('category', isEqualTo: category);
      }
      
      if (maxEntryFee != null) {
        query = query.where('entryFee', isLessThanOrEqualTo: maxEntryFee);
      }
      
      final snapshot = await query.get();
      
      final battles = snapshot.docs
          .map((doc) => Battle.fromMap(doc.data() as Map<String, dynamic>))
          .where((battle) {
            if (maxDuration != null && battle.duration > maxDuration) {
              return false;
            }
            return battle.participants.length < battle.maxParticipants;
          })
          .toList();
      
      log('BattleService: バトル検索完了 - ${battles.length}件');
      return battles;
    } catch (e) {
      log('BattleService: バトル検索エラー - $e');
      return [];
    }
  }

  /// ランキングの取得
  Future<List<BattleRanking>> getGlobalRanking({
    String? category,
    RankingPeriod period = RankingPeriod.allTime,
  }) async {
    try {
      log('BattleService: ランキング取得開始');
      
      // 期間の計算
      DateTime? startDate;
      switch (period) {
        case RankingPeriod.daily:
          startDate = DateTime.now().subtract(const Duration(days: 1));
          break;
        case RankingPeriod.weekly:
          startDate = DateTime.now().subtract(const Duration(days: 7));
          break;
        case RankingPeriod.monthly:
          startDate = DateTime.now().subtract(const Duration(days: 30));
          break;
        case RankingPeriod.allTime:
          startDate = null;
          break;
      }
      
      // TODO: 実際の実装では、ユーザーの統計データを集計
      // ここでは簡略化してサンプルデータを返す
      final rankings = <BattleRanking>[
        BattleRanking(
          userId: 'user1',
          username: 'バトルマスター',
          totalWins: 15,
          totalBattles: 20,
          totalPoints: 1500,
          winRate: 0.75,
          rank: 1,
        ),
        BattleRanking(
          userId: 'user2',
          username: 'ハビット戦士',
          totalWins: 12,
          totalBattles: 18,
          totalPoints: 1200,
          winRate: 0.67,
          rank: 2,
        ),
      ];
      
      log('BattleService: ランキング取得完了');
      return rankings;
    } catch (e) {
      log('BattleService: ランキング取得エラー - $e');
      return [];
    }
  }

  // ========== プライベートメソッド ==========

  void _onActiveBattlesChanged(QuerySnapshot snapshot) {
    try {
      final battles = snapshot.docs
          .map((doc) => Battle.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
      
      _activeBattles.value = battles;
      
      // 現在のバトルを更新
      if (battles.isNotEmpty) {
        _currentBattle.value = battles.first;
        _subscribeToCurrentBattle(battles.first.id);
      } else {
        _currentBattle.value = null;
        _currentBattleSubscription?.cancel();
      }
      
      log('BattleService: アクティブバトル更新 - ${battles.length}件');
    } catch (e) {
      log('BattleService: アクティブバトル更新エラー - $e');
    }
  }

  void _subscribeToCurrentBattle(String battleId) {
    _currentBattleSubscription?.cancel();
    
    _currentBattleSubscription = _firestore
        .collection('battles')
        .doc(battleId)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists) {
        final battle = Battle.fromMap(snapshot.data()!);
        _currentBattle.value = battle;
      }
    });
  }

  Future<void> _loadBattleHistory(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('battle_results')
          .where('participants', arrayContains: userId)
          .orderBy('endTime', descending: true)
          .limit(50)
          .get();
      
      final history = snapshot.docs
          .map((doc) => BattleResult.fromMap(doc.data()))
          .toList();
      
      _battleHistory.value = history;
      
      log('BattleService: バトル履歴読み込み完了 - ${history.length}件');
    } catch (e) {
      log('BattleService: バトル履歴読み込みエラー - $e');
    }
  }

  Future<void> _updateLeaderboard(String battleId, String userId, int points) async {
    try {
      final battleDoc = _firestore.collection('battles').doc(battleId);
      
      await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(battleDoc);
        
        if (!snapshot.exists) return;
        
        final battle = Battle.fromMap(snapshot.data()!);
        final leaderboard = List<LeaderboardEntry>.from(battle.leaderboard);
        
        // 既存のエントリを更新または新規追加
        final existingIndex = leaderboard.indexWhere((entry) => entry.userId == userId);
        
        if (existingIndex >= 0) {
          leaderboard[existingIndex] = leaderboard[existingIndex].copyWith(
            totalPoints: leaderboard[existingIndex].totalPoints + points,
            completions: leaderboard[existingIndex].completions + 1,
            lastUpdate: DateTime.now(),
          );
        } else {
          leaderboard.add(LeaderboardEntry(
            userId: userId,
            totalPoints: points,
            completions: 1,
            rank: 0, // 後で計算
            lastUpdate: DateTime.now(),
          ));
        }
        
        // ランキングを再計算
        leaderboard.sort((a, b) => b.totalPoints.compareTo(a.totalPoints));
        for (int i = 0; i < leaderboard.length; i++) {
          leaderboard[i] = leaderboard[i].copyWith(rank: i + 1);
        }
        
        transaction.update(battleDoc, {
          'leaderboard': leaderboard.map((entry) => entry.toMap()).toList(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      });
    } catch (e) {
      log('BattleService: リーダーボード更新エラー - $e');
    }
  }

  int _calculatePoints(DateTime completedAt, Map<String, dynamic>? metadata) {
    int basePoints = 100;
    
    // 時間ボーナス（早朝や深夜は追加ポイント）
    final hour = completedAt.hour;
    if (hour >= 5 && hour <= 7) {
      basePoints += 20; // 早朝ボーナス
    } else if (hour >= 22 || hour <= 4) {
      basePoints += 10; // 深夜ボーナス
    }
    
    // 連続ボーナス
    if (metadata?['streak'] != null) {
      final streak = metadata!['streak'] as int;
      basePoints += math.min(streak * 5, 50); // 最大50ポイント
    }
    
    // 難易度ボーナス
    if (metadata?['difficulty'] != null) {
      final difficulty = metadata!['difficulty'] as String;
      switch (difficulty) {
        case 'easy':
          break;
        case 'medium':
          basePoints += 25;
          break;
        case 'hard':
          basePoints += 50;
          break;
      }
    }
    
    return basePoints;
  }

  BattleResult _calculateBattleResult(Battle battle, List<BattleCompletion> completions) {
    // 参加者ごとの統計を計算
    final participantStats = <String, ParticipantStats>{};
    
    for (final participant in battle.participants) {
      final userCompletions = completions.where((c) => c.userId == participant).toList();
      final totalPoints = userCompletions.fold(0, (sum, c) => sum + c.points);
      
      participantStats[participant] = ParticipantStats(
        userId: participant,
        totalPoints: totalPoints,
        completions: userCompletions.length,
        averagePoints: userCompletions.isNotEmpty ? totalPoints / userCompletions.length : 0,
        rank: 0, // 後で計算
      );
    }
    
    // ランキングを計算
    final sortedStats = participantStats.values.toList()
      ..sort((a, b) => b.totalPoints.compareTo(a.totalPoints));
    
    for (int i = 0; i < sortedStats.length; i++) {
      sortedStats[i] = sortedStats[i].copyWith(rank: i + 1);
    }
    
    // 勝者を決定
    final winner = sortedStats.isNotEmpty ? sortedStats.first : null;
    
    return BattleResult(
      battleId: battle.id,
      title: battle.title,
      category: battle.category,
      participants: battle.participants,
      participantStats: sortedStats,
      winner: winner,
      totalPrize: battle.totalPrize,
      duration: battle.duration,
      startTime: battle.startTime!,
      endTime: battle.endTime!,
      completedAt: DateTime.now(),
    );
  }

  String _generateBattleId() {
    return 'battle_${DateTime.now().millisecondsSinceEpoch}_${math.Random().nextInt(1000)}';
  }

  String _generateCompletionId() {
    return 'completion_${DateTime.now().millisecondsSinceEpoch}_${math.Random().nextInt(1000)}';
  }
}

// ========== データクラス ==========

/// バトル
class Battle {
  final String id;
  final String title;
  final String description;
  final String category;
  final String creatorId;
  final List<String> participants;
  final int maxParticipants;
  final int entryFee;
  final int totalPrize;
  final Duration duration;
  final BattleStatus status;
  final DateTime createdAt;
  final DateTime? startTime;
  final DateTime? endTime;
  final BattleRules rules;
  final List<LeaderboardEntry> leaderboard;

  Battle({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.creatorId,
    required this.participants,
    required this.maxParticipants,
    required this.entryFee,
    required this.totalPrize,
    required this.duration,
    required this.status,
    required this.createdAt,
    this.startTime,
    this.endTime,
    required this.rules,
    required this.leaderboard,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'creatorId': creatorId,
      'participants': participants,
      'maxParticipants': maxParticipants,
      'entryFee': entryFee,
      'totalPrize': totalPrize,
      'durationMinutes': duration.inMinutes,
      'status': status.name,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'startTime': startTime?.millisecondsSinceEpoch,
      'endTime': endTime?.millisecondsSinceEpoch,
      'rules': rules.toMap(),
      'leaderboard': leaderboard.map((entry) => entry.toMap()).toList(),
    };
  }

  factory Battle.fromMap(Map<String, dynamic> map) {
    return Battle(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      category: map['category'] ?? '',
      creatorId: map['creatorId'] ?? '',
      participants: List<String>.from(map['participants'] ?? []),
      maxParticipants: map['maxParticipants'] ?? 8,
      entryFee: map['entryFee'] ?? 0,
      totalPrize: map['totalPrize'] ?? 0,
      duration: Duration(minutes: map['durationMinutes'] ?? 60),
      status: BattleStatus.values.firstWhere(
        (s) => s.name == map['status'],
        orElse: () => BattleStatus.waiting,
      ),
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] ?? 0),
      startTime: map['startTime'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(map['startTime'])
          : null,
      endTime: map['endTime'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(map['endTime'])
          : null,
      rules: BattleRules.fromMap(map['rules'] ?? {}),
      leaderboard: (map['leaderboard'] as List<dynamic>?)
          ?.map((entry) => LeaderboardEntry.fromMap(entry))
          .toList() ?? [],
    );
  }
}

/// バトルステータス
enum BattleStatus {
  waiting,
  active,
  finished,
  cancelled,
}

/// バトルルール
class BattleRules {
  final int minCompletions;
  final int maxCompletions;
  final bool allowLateJoin;
  final Duration gracePeriod;
  final Map<String, dynamic> customRules;

  BattleRules({
    required this.minCompletions,
    required this.maxCompletions,
    required this.allowLateJoin,
    required this.gracePeriod,
    required this.customRules,
  });

  factory BattleRules.defaultRules() {
    return BattleRules(
      minCompletions: 1,
      maxCompletions: 10,
      allowLateJoin: true,
      gracePeriod: const Duration(minutes: 15),
      customRules: {},
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'minCompletions': minCompletions,
      'maxCompletions': maxCompletions,
      'allowLateJoin': allowLateJoin,
      'gracePeriodMinutes': gracePeriod.inMinutes,
      'customRules': customRules,
    };
  }

  factory BattleRules.fromMap(Map<String, dynamic> map) {
    return BattleRules(
      minCompletions: map['minCompletions'] ?? 1,
      maxCompletions: map['maxCompletions'] ?? 10,
      allowLateJoin: map['allowLateJoin'] ?? true,
      gracePeriod: Duration(minutes: map['gracePeriodMinutes'] ?? 15),
      customRules: Map<String, dynamic>.from(map['customRules'] ?? {}),
    );
  }
}

/// リーダーボードエントリ
class LeaderboardEntry {
  final String userId;
  final int totalPoints;
  final int completions;
  final int rank;
  final DateTime lastUpdate;

  LeaderboardEntry({
    required this.userId,
    required this.totalPoints,
    required this.completions,
    required this.rank,
    required this.lastUpdate,
  });

  LeaderboardEntry copyWith({
    String? userId,
    int? totalPoints,
    int? completions,
    int? rank,
    DateTime? lastUpdate,
  }) {
    return LeaderboardEntry(
      userId: userId ?? this.userId,
      totalPoints: totalPoints ?? this.totalPoints,
      completions: completions ?? this.completions,
      rank: rank ?? this.rank,
      lastUpdate: lastUpdate ?? this.lastUpdate,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'totalPoints': totalPoints,
      'completions': completions,
      'rank': rank,
      'lastUpdate': lastUpdate.millisecondsSinceEpoch,
    };
  }

  factory LeaderboardEntry.fromMap(Map<String, dynamic> map) {
    return LeaderboardEntry(
      userId: map['userId'] ?? '',
      totalPoints: map['totalPoints'] ?? 0,
      completions: map['completions'] ?? 0,
      rank: map['rank'] ?? 0,
      lastUpdate: DateTime.fromMillisecondsSinceEpoch(map['lastUpdate'] ?? 0),
    );
  }
}

/// バトル完了記録
class BattleCompletion {
  final String id;
  final String battleId;
  final String userId;
  final String habitId;
  final DateTime completedAt;
  final int points;
  final Map<String, dynamic> metadata;

  BattleCompletion({
    required this.id,
    required this.battleId,
    required this.userId,
    required this.habitId,
    required this.completedAt,
    required this.points,
    required this.metadata,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'battleId': battleId,
      'userId': userId,
      'habitId': habitId,
      'completedAt': completedAt.millisecondsSinceEpoch,
      'points': points,
      'metadata': metadata,
    };
  }

  factory BattleCompletion.fromMap(Map<String, dynamic> map) {
    return BattleCompletion(
      id: map['id'] ?? '',
      battleId: map['battleId'] ?? '',
      userId: map['userId'] ?? '',
      habitId: map['habitId'] ?? '',
      completedAt: DateTime.fromMillisecondsSinceEpoch(map['completedAt'] ?? 0),
      points: map['points'] ?? 0,
      metadata: Map<String, dynamic>.from(map['metadata'] ?? {}),
    );
  }
}

/// バトル結果
class BattleResult {
  final String battleId;
  final String title;
  final String category;
  final List<String> participants;
  final List<ParticipantStats> participantStats;
  final ParticipantStats? winner;
  final int totalPrize;
  final Duration duration;
  final DateTime startTime;
  final DateTime endTime;
  final DateTime completedAt;

  BattleResult({
    required this.battleId,
    required this.title,
    required this.category,
    required this.participants,
    required this.participantStats,
    this.winner,
    required this.totalPrize,
    required this.duration,
    required this.startTime,
    required this.endTime,
    required this.completedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'battleId': battleId,
      'title': title,
      'category': category,
      'participants': participants,
      'participantStats': participantStats.map((stats) => stats.toMap()).toList(),
      'winner': winner?.toMap(),
      'totalPrize': totalPrize,
      'durationMinutes': duration.inMinutes,
      'startTime': startTime.millisecondsSinceEpoch,
      'endTime': endTime.millisecondsSinceEpoch,
      'completedAt': completedAt.millisecondsSinceEpoch,
    };
  }

  factory BattleResult.fromMap(Map<String, dynamic> map) {
    return BattleResult(
      battleId: map['battleId'] ?? '',
      title: map['title'] ?? '',
      category: map['category'] ?? '',
      participants: List<String>.from(map['participants'] ?? []),
      participantStats: (map['participantStats'] as List<dynamic>?)
          ?.map((stats) => ParticipantStats.fromMap(stats))
          .toList() ?? [],
      winner: map['winner'] != null ? ParticipantStats.fromMap(map['winner']) : null,
      totalPrize: map['totalPrize'] ?? 0,
      duration: Duration(minutes: map['durationMinutes'] ?? 60),
      startTime: DateTime.fromMillisecondsSinceEpoch(map['startTime'] ?? 0),
      endTime: DateTime.fromMillisecondsSinceEpoch(map['endTime'] ?? 0),
      completedAt: DateTime.fromMillisecondsSinceEpoch(map['completedAt'] ?? 0),
    );
  }
}

/// 参加者統計
class ParticipantStats {
  final String userId;
  final int totalPoints;
  final int completions;
  final double averagePoints;
  final int rank;

  ParticipantStats({
    required this.userId,
    required this.totalPoints,
    required this.completions,
    required this.averagePoints,
    required this.rank,
  });

  ParticipantStats copyWith({
    String? userId,
    int? totalPoints,
    int? completions,
    double? averagePoints,
    int? rank,
  }) {
    return ParticipantStats(
      userId: userId ?? this.userId,
      totalPoints: totalPoints ?? this.totalPoints,
      completions: completions ?? this.completions,
      averagePoints: averagePoints ?? this.averagePoints,
      rank: rank ?? this.rank,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'totalPoints': totalPoints,
      'completions': completions,
      'averagePoints': averagePoints,
      'rank': rank,
    };
  }

  factory ParticipantStats.fromMap(Map<String, dynamic> map) {
    return ParticipantStats(
      userId: map['userId'] ?? '',
      totalPoints: map['totalPoints'] ?? 0,
      completions: map['completions'] ?? 0,
      averagePoints: (map['averagePoints'] ?? 0).toDouble(),
      rank: map['rank'] ?? 0,
    );
  }
}

/// バトルランキング
class BattleRanking {
  final String userId;
  final String username;
  final int totalWins;
  final int totalBattles;
  final int totalPoints;
  final double winRate;
  final int rank;

  BattleRanking({
    required this.userId,
    required this.username,
    required this.totalWins,
    required this.totalBattles,
    required this.totalPoints,
    required this.winRate,
    required this.rank,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'username': username,
      'totalWins': totalWins,
      'totalBattles': totalBattles,
      'totalPoints': totalPoints,
      'winRate': winRate,
      'rank': rank,
    };
  }

  factory BattleRanking.fromMap(Map<String, dynamic> map) {
    return BattleRanking(
      userId: map['userId'] ?? '',
      username: map['username'] ?? '',
      totalWins: map['totalWins'] ?? 0,
      totalBattles: map['totalBattles'] ?? 0,
      totalPoints: map['totalPoints'] ?? 0,
      winRate: (map['winRate'] ?? 0).toDouble(),
      rank: map['rank'] ?? 0,
    );
  }
}

/// ランキング期間
enum RankingPeriod {
  daily,
  weekly,
  monthly,
  allTime,
}