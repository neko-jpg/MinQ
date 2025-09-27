import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:minq/domain/pair/pair.dart';

class PairRepository {
  PairRepository(this._firestore);

  final FirebaseFirestore _firestore;
  final _random = Random();

  Stream<Pair?> getPairStreamForUser(String uid) {
    final assignmentStream = _firestore.collection('pair_assignments').doc(uid).snapshots();

    return assignmentStream.asyncMap((assignmentSnap) async {
      if (!assignmentSnap.exists) {
        return null;
      }
      final pairId = assignmentSnap.data()!['pairId'] as String?;
      if (pairId == null) {
        return null;
      }
      final pairSnap = await _firestore.collection('pairs').doc(pairId).get();
      if (!pairSnap.exists) {
        return null;
      }
      return Pair.fromSnapshot(pairSnap);
    });
  }

  Future<String> createPair(String uid1, String uid2, String category) async {
    final pairRef = _firestore.collection('pairs').doc();
    await pairRef.set({
      'members': [uid1, uid2],
      'category': category,
      'createdAt': FieldValue.serverTimestamp(),
      'lastHighfiveAt': null,
      'lastHighfiveBy': null,
    });

    await _setPairAssignment(uid1, pairRef.id);
    await _setPairAssignment(uid2, pairRef.id);

    return pairRef.id;
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> getPairStream(String pairId) {
    return _firestore.collection('pairs').doc(pairId).snapshots();
  }

  Future<void> sendHighFive(String pairId, String senderUid) async {
    await _firestore.collection('pairs').doc(pairId).update({
      'lastHighfiveAt': FieldValue.serverTimestamp(),
      'lastHighfiveBy': senderUid,
    });
  }

  Future<void> sendQuickMessage(String pairId, String senderUid, String message) async {
    await _firestore.collection('pairs').doc(pairId).update({
      'lastMessage': {
        'text': message,
        'senderUid': senderUid,
        'createdAt': FieldValue.serverTimestamp(),
      },
    });
  }

  Future<void> leavePair(String pairId, String leavingUserId) async {
    final pairDoc = await _firestore.collection('pairs').doc(pairId).get();
    if (!pairDoc.exists) return;

    final members = List<String>.from(pairDoc.data()!['members']);
    final otherUserId = members.firstWhere((id) => id != leavingUserId);

    await _firestore.collection('pairs').doc(pairId).delete();
    await _deletePairAssignment(leavingUserId);
    await _deletePairAssignment(otherUserId);
  }

  Future<String?> requestRandomPair(String uid, String category) async {
    // First, check if the user is already in a pair.
    final assignment = await fetchAssignment(uid);
    if (assignment != null) {
      // User is already in a pair, so they can't request a new one.
      return null;
    }

    final queueDoc = _firestore.collection('pair_queue').doc(category);
    final pairRef = _firestore.collection('pairs').doc();

    return _firestore.runTransaction<String?>((transaction) async {
      final snapshot = await transaction.get(queueDoc);
      if (!snapshot.exists) {
        transaction.set(queueDoc, {
          'waitingUid': uid,
          'createdAt': FieldValue.serverTimestamp(),
        });
        return null;
      }

      final data = snapshot.data() as Map<String, dynamic>;
      final waitingUid = data['waitingUid'] as String?;
      if (waitingUid == null || waitingUid == uid) {
        transaction.set(queueDoc, {
          'waitingUid': uid,
          'createdAt': FieldValue.serverTimestamp(),
        });
        return null;
      }

      // Check for blocks
      final blocked = await _isBlocked(uid, waitingUid);
      if (blocked) {
        // Can't pair with a blocked user. For now, just return null.
        // A more sophisticated implementation might try to find another user.
        return null;
      }

      transaction.delete(queueDoc);
      transaction.set(pairRef, {
        'members': [waitingUid, uid],
        'category': category,
        'createdAt': FieldValue.serverTimestamp(),
        'lastHighfiveAt': null,
        'lastHighfiveBy': null,
      });
      transaction.set(
        _firestore.collection('pair_assignments').doc(waitingUid),
        {'pairId': pairRef.id, 'updatedAt': FieldValue.serverTimestamp()},
      );
      transaction.set(_firestore.collection('pair_assignments').doc(uid), {
        'pairId': pairRef.id,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return pairRef.id;
    });
  }

  Future<void> cancelRandomRequest(String uid, String category) async {
    final queueDoc = _firestore.collection('pair_queue').doc(category);
    await _firestore.runTransaction<void>((transaction) async {
      final snapshot = await transaction.get(queueDoc);
      if (!snapshot.exists) {
        return;
      }
      final data = snapshot.data() as Map<String, dynamic>;
      if (data['waitingUid'] == uid) {
        transaction.delete(queueDoc);
      }
    });
  }

  Future<String> createInvitation(String ownerUid, String category) async {
    final code = _generateInviteCode();
    await _firestore.collection('pair_invites').doc(code).set({
      'ownerUid': ownerUid,
      'category': category,
      'createdAt': FieldValue.serverTimestamp(),
    });
    return code;
  }

  Future<String?> joinByInvitation(String code, String joinerUid) async {
    final normalizedCode = code.toUpperCase();
    final inviteRef = _firestore.collection('pair_invites').doc(normalizedCode);

    final result = await _firestore.runTransaction<String?>((
      transaction,
    ) async {
      final snapshot = await transaction.get(inviteRef);
      if (!snapshot.exists) {
        return null;
      }

      final data = snapshot.data() as Map<String, dynamic>;
      final ownerUid = data['ownerUid'] as String?;
      final category = data['category'] as String? ?? 'general';

      if (ownerUid == null || ownerUid == joinerUid) {
        return null;
      }

      // Check for blocks
      final blocked = await _isBlocked(joinerUid, ownerUid);
      if (blocked) {
        return null;
      }

      transaction.delete(inviteRef);
      return '$ownerUid::$category';
    });

    if (result == null) {
      return null;
    }

    final parts = result.split('::');
    return createPair(parts[0], joinerUid, parts[1]);
  }

  Future<void> blockUser(String blockerUid, String blockedUid) async {
    await _firestore
        .collection('blocks')
        .doc('$blockerUid-$blockedUid')
        .set({
      'blocker': blockerUid,
      'blocked': blockedUid,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> unblockUser(String blockerUid, String blockedUid) async {
    await _firestore.collection('blocks').doc('$blockerUid-$blockedUid').delete();
  }

  Future<void> reportUser(
      String reporterUid, String reportedUid, String reason) async {
    await _firestore.collection('reports').add({
      'reporter': reporterUid,
      'reported': reportedUid,
      'reason': reason,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<Map<String, dynamic>?> fetchAssignment(String uid) async {
    final snapshot =
        await _firestore.collection('pair_assignments').doc(uid).get();
    return snapshot.data();
  }

  Future<void> _setPairAssignment(String uid, String pairId) async {
    await _firestore.collection('pair_assignments').doc(uid).set({
      'pairId': pairId,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> _deletePairAssignment(String uid) async {
    await _firestore.collection('pair_assignments').doc(uid).delete();
  }

  Future<bool> _isBlocked(String uid1, String uid2) async {
    final block1 =
        await _firestore.collection('blocks').doc('$uid1-$uid2').get();
    if (block1.exists) return true;

    final block2 =
        await _firestore.collection('blocks').doc('$uid2-$uid1').get();
    if (block2.exists) return true;

    return false;
  }

  String _generateInviteCode() {
    const letters = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    return List.generate(
      6,
      (_) => letters[_random.nextInt(letters.length)],
    ).join();
  }
}
