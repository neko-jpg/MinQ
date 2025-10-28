import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:minq/core/gamification/gamification_engine.dart';
import 'package:minq/data/providers.dart' as providers;
import 'package:minq/domain/challenges/challenge.dart';
import 'package:minq/domain/challenges/challenge_progress.dart';

// Service provider
final challengeServiceProvider = Provider<ChallengeService?>((ref) {
  final firestore = FirebaseFirestore.instance;
  final gamificationEngine = ref.watch(providers.gamificationEngineProvider);
  final userId = ref.watch(providers.uidProvider);

  if (userId == null || gamificationEngine == null) {
    return null; // 必要な依存関係が利用できない場合はnullを返す
  }

  return ChallengeService(firestore, gamificationEngine, userId);
});

// Stream provider for active challenges
final activeChallengesProvider = StreamProvider<List<Challenge>>((ref) {
  final service = ref.watch(challengeServiceProvider);
  if (service == null) {
    return Stream.value(<Challenge>[]);
  }
  return service.getActiveChallengesStream();
});

// Stream provider for completed challenges
final completedChallengesProvider = StreamProvider<List<Challenge>>((ref) {
  final service = ref.watch(challengeServiceProvider);
  if (service == null) {
    return Stream.value(<Challenge>[]);
  }
  return service.getCompletedChallengesStream();
});

// Stream provider for a specific challenge's progress
final challengeProgressProvider = StreamProvider.autoDispose
    .family<ChallengeProgress?, ChallengeProgressIdentity>((ref, identity) {
  final service = ref.watch(challengeServiceProvider);
  if (service == null) {
    return Stream.value(null);
  }
  return service.getChallengeProgressStream(identity.challengeId);
});

class ChallengeProgressIdentity {
  final String userId;
  final String challengeId;

  ChallengeProgressIdentity({required this.userId, required this.challengeId});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChallengeProgressIdentity &&
          runtimeType == other.runtimeType &&
          userId == other.userId &&
          challengeId == other.challengeId;

  @override
  int get hashCode => userId.hashCode ^ challengeId.hashCode;
}

class ChallengeService {
  final FirebaseFirestore _firestore;
  final GamificationEngine _gamificationEngine;
  final String _userId;

  ChallengeService(this._firestore, this._gamificationEngine, this._userId);

  CollectionReference get _challengesRef => _firestore.collection('challenges');
  CollectionReference get _progressRef => _firestore
      .collection('users')
      .doc(_userId)
      .collection('challenge_progress');

  /// Fetches active challenges as a stream.
  Stream<List<Challenge>> getActiveChallengesStream() {
    return _challengesRef
        .where('endDate', isGreaterThanOrEqualTo: DateTime.now())
        .snapshots()
        .asyncMap((snapshot) async {
      final progressSnapshot = await _progressRef.get();
      final completedIds = progressSnapshot.docs
          .where((doc) {
            final data = doc.data() as Map<String, dynamic>?;
            return data?['completed'] == true;
          })
          .map((doc) => doc.id)
          .toSet();

      return snapshot.docs
          .map((doc) => Challenge.fromJson(doc.data() as Map<String, dynamic>))
          .where((challenge) => !completedIds.contains(challenge.id))
          .toList();
    });
  }

  /// Fetches completed challenges as a stream.
  Stream<List<Challenge>> getCompletedChallengesStream() {
    return _progressRef
        .where('completed', isEqualTo: true)
        .snapshots()
        .asyncMap((progressSnapshot) async {
      if (progressSnapshot.docs.isEmpty) return [];

      final challengeIds = progressSnapshot.docs.map((doc) => doc.id).toList();

      // Firestore 'in' query has a limit of 10 elements.
      // We need to fetch challenges in batches if needed.
      final challengeFutures = <Future<DocumentSnapshot>>[];
      for (final challengeId in challengeIds) {
        challengeFutures.add(_challengesRef.doc(challengeId).get());
      }
      final challengeSnapshots = await Future.wait(challengeFutures);

      return challengeSnapshots
          .where((doc) => doc.exists)
          .map((doc) => Challenge.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    });
  }

  /// Gets a stream of progress for a specific challenge.
  Stream<ChallengeProgress?> getChallengeProgressStream(String challengeId) {
    return _progressRef.doc(challengeId).snapshots().map((snapshot) {
      if (snapshot.exists) {
        return ChallengeProgress.fromJson(
            snapshot.data() as Map<String, dynamic>);
      }
      // If no progress exists, create one. This is useful for new challenges.
      _createInitialProgress(challengeId);
      return null;
    });
  }

  /// Creates an initial progress document if it doesn't exist.
  Future<void> _createInitialProgress(String challengeId) async {
    final doc = _progressRef.doc(challengeId);
    final snapshot = await doc.get();
    if (!snapshot.exists) {
      await doc.set({
        'userId': _userId,
        'challengeId': challengeId,
        'progress': 0,
        'completed': false,
      });
    }
  }

  /// Updates the progress of a challenge.
  Future<void> updateProgress({
    required String challengeId,
    required int incrementBy,
  }) async {
    final progressDocRef = _progressRef.doc(challengeId);
    final challengeDoc = await _challengesRef.doc(challengeId).get();

    if (!challengeDoc.exists) return;
    final challenge =
        Challenge.fromJson(challengeDoc.data() as Map<String, dynamic>);

    final progressSnapshot = await progressDocRef.get();
    final currentProgress = progressSnapshot.exists
        ? ChallengeProgress.fromJson(
            progressSnapshot.data() as Map<String, dynamic>)
        : null;

    if (currentProgress == null || currentProgress.completed) return;

    final newProgress = currentProgress.progress + incrementBy;
    await progressDocRef.update({'progress': newProgress});

    if (newProgress >= challenge.goal) {
      await _completeChallenge(challenge);
    }
  }

  /// Completes a challenge and awards rewards.
  Future<void> _completeChallenge(Challenge challenge) async {
    await _progressRef.doc(challenge.id).update({
      'completed': true,
      'progress': challenge.goal,
    });

    await _gamificationEngine.awardPoints(
      userId: _userId,
      basePoints: 100, // FIXME: Use value from challenge
      reason: 'Completed Challenge: ${challenge.name}',
    );

    await _gamificationEngine.checkAndAwardBadges(_userId);
  }
}
