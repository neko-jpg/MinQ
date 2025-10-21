import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:minq/domain/community/community_post.dart';

class CommunityBoardRepository {
  CommunityBoardRepository(FirebaseFirestore firestore)
    : _collection = firestore.collection('community_posts');

  final CollectionReference<Map<String, dynamic>> _collection;

  Stream<List<CommunityPost>> watchLatest() {
    return _collection
        .orderBy('createdAt', descending: true)
        .limit(100)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map(
                    (doc) => CommunityPost(
                      id: doc.id,
                      authorId: doc['authorId'] as String,
                      authorDisplayName: doc['authorDisplayName'] as String,
                      message: doc['message'] as String,
                      createdAt: (doc['createdAt'] as Timestamp).toDate(),
                      likeCount: (doc['likeCount'] as num?)?.toInt() ?? 0,
                      flagged: doc['flagged'] as bool? ?? false,
                    ),
                  )
                  .toList(),
        );
  }

  Future<void> create({
    required String authorId,
    required String displayName,
    required String message,
  }) async {
    await _collection.add(<String, dynamic>{
      'authorId': authorId,
      'authorDisplayName': displayName,
      'message': message,
      'createdAt': FieldValue.serverTimestamp(),
      'likeCount': 0,
      'flagged': false,
    });
  }

  Future<void> like(String postId) async {
    await _collection.doc(postId).update(<String, dynamic>{
      'likeCount': FieldValue.increment(1),
    });
  }

  Future<void> report(String postId) async {
    await _collection.doc(postId).update(<String, dynamic>{'flagged': true});
  }
}
