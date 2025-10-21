import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:minq/core/logging/app_logger.dart';

/// タグサービス
class TagService {
  final FirebaseFirestore _firestore;

  TagService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  /// タグを作成
  Future<String?> createTag({
    required String userId,
    required String name,
    required Color color,
  }) async {
    try {
      final tagRef =
          _firestore.collection('users').doc(userId).collection('tags').doc();

      await tagRef.set({
        'name': name,
        'color': color.value,
        'createdAt': FieldValue.serverTimestamp(),
      });

      AppLogger.info('Tag created', data: {'tagId': tagRef.id, 'name': name});
      return tagRef.id;
    } catch (e, stack) {
      AppLogger.error('Failed to create tag', error: e, stackTrace: stack);
      return null;
    }
  }

  /// タグを取得
  Stream<List<Tag>> getTags(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('tags')
        .orderBy('name')
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data();
            return Tag(
              id: doc.id,
              name: data['name'] as String,
              color: Color(data['color'] as int),
            );
          }).toList();
        });
  }

  /// タグを削除
  Future<void> deleteTag(String userId, String tagId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('tags')
          .doc(tagId)
          .delete();

      AppLogger.info('Tag deleted', data: {'tagId': tagId});
    } catch (e, stack) {
      AppLogger.error('Failed to delete tag', error: e, stackTrace: stack);
    }
  }
}

/// タグモデル
class Tag {
  final String id;
  final String name;
  final Color color;

  Tag({required this.id, required this.name, required this.color});
}

/// プリセットタグ
class PresetTags {
  static final List<Tag> presets = [
    Tag(id: 'health', name: '健康', color: Colors.green),
    Tag(id: 'work', name: '仕事', color: Colors.blue),
    Tag(id: 'study', name: '勉強', color: Colors.orange),
    Tag(id: 'hobby', name: '趣味', color: Colors.purple),
    Tag(id: 'exercise', name: '運動', color: Colors.red),
    Tag(id: 'reading', name: '読書', color: Colors.brown),
    Tag(id: 'family', name: '家族', color: Colors.pink),
    Tag(id: 'social', name: '交流', color: Colors.teal),
  ];
}
