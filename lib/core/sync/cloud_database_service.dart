import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:minq/core/sync/sync_queue_manager.dart';
import 'package:minq/data/logging/minq_logger.dart';

/// Implementation of CloudDatabaseService using Firestore
class FirestoreCloudDatabaseService implements CloudDatabaseService {
  FirestoreCloudDatabaseService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  @override
  Future<SyncResult> upsertQuest(Map<String, dynamic> data) async {
    try {
      final questId = data['questId'] as String;
      await _firestore
          .collection('quests')
          .doc(questId)
          .set(data, SetOptions(merge: true));
      
      MinqLogger.info('Quest synced to Firestore', metadata: {
        'questId': questId,
      });
      
      return SyncResult.success();
    } catch (e, stackTrace) {
      MinqLogger.error('Failed to sync quest to Firestore', 
          error: e, stackTrace: stackTrace);
      return SyncResult.failure(e.toString());
    }
  }

  @override
  Future<SyncResult> deleteQuest(String questId) async {
    try {
      await _firestore
          .collection('quests')
          .doc(questId)
          .update({'deletedAt': FieldValue.serverTimestamp()});
      
      MinqLogger.info('Quest deleted in Firestore', metadata: {
        'questId': questId,
      });
      
      return SyncResult.success();
    } catch (e, stackTrace) {
      MinqLogger.error('Failed to delete quest in Firestore', 
          error: e, stackTrace: stackTrace);
      return SyncResult.failure(e.toString());
    }
  }

  @override
  Future<SyncResult> upsertUser(Map<String, dynamic> data) async {
    try {
      final uid = data['uid'] as String;
      await _firestore
          .collection('users')
          .doc(uid)
          .set(data, SetOptions(merge: true));
      
      MinqLogger.info('User synced to Firestore', metadata: {
        'uid': uid,
      });
      
      return SyncResult.success();
    } catch (e, stackTrace) {
      MinqLogger.error('Failed to sync user to Firestore', 
          error: e, stackTrace: stackTrace);
      return SyncResult.failure(e.toString());
    }
  }

  @override
  Future<SyncResult> upsertChallenge(Map<String, dynamic> data) async {
    try {
      final challengeId = data['challengeId'] as String;
      await _firestore
          .collection('challenges')
          .doc(challengeId)
          .set(data, SetOptions(merge: true));
      
      MinqLogger.info('Challenge synced to Firestore', metadata: {
        'challengeId': challengeId,
      });
      
      return SyncResult.success();
    } catch (e, stackTrace) {
      MinqLogger.error('Failed to sync challenge to Firestore', 
          error: e, stackTrace: stackTrace);
      return SyncResult.failure(e.toString());
    }
  }

  @override
  Future<SyncResult> deleteChallenge(String challengeId) async {
    try {
      await _firestore
          .collection('challenges')
          .doc(challengeId)
          .update({'deletedAt': FieldValue.serverTimestamp()});
      
      MinqLogger.info('Challenge deleted in Firestore', metadata: {
        'challengeId': challengeId,
      });
      
      return SyncResult.success();
    } catch (e, stackTrace) {
      MinqLogger.error('Failed to delete challenge in Firestore', 
          error: e, stackTrace: stackTrace);
      return SyncResult.failure(e.toString());
    }
  }

  @override
  Future<SyncResult> upsertQuestLog(Map<String, dynamic> data) async {
    try {
      final logId = data['logId'] as String;
      await _firestore
          .collection('questLogs')
          .doc(logId)
          .set(data, SetOptions(merge: true));
      
      MinqLogger.info('Quest log synced to Firestore', metadata: {
        'logId': logId,
      });
      
      return SyncResult.success();
    } catch (e, stackTrace) {
      MinqLogger.error('Failed to sync quest log to Firestore', 
          error: e, stackTrace: stackTrace);
      return SyncResult.failure(e.toString());
    }
  }

  @override
  Future<SyncResult> deleteQuestLog(String logId) async {
    try {
      await _firestore
          .collection('questLogs')
          .doc(logId)
          .delete();
      
      MinqLogger.info('Quest log deleted in Firestore', metadata: {
        'logId': logId,
      });
      
      return SyncResult.success();
    } catch (e, stackTrace) {
      MinqLogger.error('Failed to delete quest log in Firestore', 
          error: e, stackTrace: stackTrace);
      return SyncResult.failure(e.toString());
    }
  }

  /// Fetch data from server for conflict resolution
  Future<Map<String, dynamic>?> getQuestData(String questId) async {
    try {
      final doc = await _firestore
          .collection('quests')
          .doc(questId)
          .get();
      
      if (doc.exists) {
        return doc.data();
      }
      return null;
    } catch (e, stackTrace) {
      MinqLogger.error('Failed to fetch quest from Firestore', 
          error: e, stackTrace: stackTrace);
      return null;
    }
  }

  /// Fetch user data from server for conflict resolution
  Future<Map<String, dynamic>?> getUserData(String uid) async {
    try {
      final doc = await _firestore
          .collection('users')
          .doc(uid)
          .get();
      
      if (doc.exists) {
        return doc.data();
      }
      return null;
    } catch (e, stackTrace) {
      MinqLogger.error('Failed to fetch user from Firestore', 
          error: e, stackTrace: stackTrace);
      return null;
    }
  }

  /// Fetch challenge data from server for conflict resolution
  Future<Map<String, dynamic>?> getChallengeData(String challengeId) async {
    try {
      final doc = await _firestore
          .collection('challenges')
          .doc(challengeId)
          .get();
      
      if (doc.exists) {
        return doc.data();
      }
      return null;
    } catch (e, stackTrace) {
      MinqLogger.error('Failed to fetch challenge from Firestore', 
          error: e, stackTrace: stackTrace);
      return null;
    }
  }

  /// Fetch quest log data from server for conflict resolution
  Future<Map<String, dynamic>?> getQuestLogData(String logId) async {
    try {
      final doc = await _firestore
          .collection('questLogs')
          .doc(logId)
          .get();
      
      if (doc.exists) {
        return doc.data();
      }
      return null;
    } catch (e, stackTrace) {
      MinqLogger.error('Failed to fetch quest log from Firestore', 
          error: e, stackTrace: stackTrace);
      return null;
    }
  }

  /// Sync data from server to local database
  Future<void> syncFromServer({
    required String uid,
    DateTime? lastSyncTime,
  }) async {
    try {
      // Sync user data
      final userData = await getUserData(uid);
      if (userData != null) {
        // Handle user data sync
        MinqLogger.info('User data fetched from server', metadata: {
          'uid': uid,
        });
      }

      // Sync quests
      var questsQuery = _firestore
          .collection('quests')
          .where('owner', isEqualTo: uid);
      
      if (lastSyncTime != null) {
        questsQuery = questsQuery.where('updatedAt', isGreaterThan: lastSyncTime);
      }
      
      final questsSnapshot = await questsQuery.get();
      MinqLogger.info('Quests fetched from server', metadata: {
        'count': questsSnapshot.docs.length,
        'uid': uid,
      });

      // Sync quest logs
      var logsQuery = _firestore
          .collection('questLogs')
          .where('uid', isEqualTo: uid);
      
      if (lastSyncTime != null) {
        logsQuery = logsQuery.where('updatedAt', isGreaterThan: lastSyncTime);
      }
      
      final logsSnapshot = await logsQuery.get();
      MinqLogger.info('Quest logs fetched from server', metadata: {
        'count': logsSnapshot.docs.length,
        'uid': uid,
      });

      // Sync challenges (public challenges)
      var challengesQuery = _firestore
          .collection('challenges')
          .where('isActive', isEqualTo: true);
      
      if (lastSyncTime != null) {
        challengesQuery = challengesQuery.where('updatedAt', isGreaterThan: lastSyncTime);
      }
      
      final challengesSnapshot = await challengesQuery.get();
      MinqLogger.info('Challenges fetched from server', metadata: {
        'count': challengesSnapshot.docs.length,
      });

    } catch (e, stackTrace) {
      MinqLogger.error('Failed to sync from server', 
          error: e, stackTrace: stackTrace);
      rethrow;
    }
  }
}