import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:minq/core/logging/app_logger.dart';

/// 優先度レベル
enum PriorityLevel { low, medium, high }

extension PriorityLevelExtension on PriorityLevel {
  /// 表示名
  String get displayName {
    switch (this) {
      case PriorityLevel.low:
        return '低';
      case PriorityLevel.medium:
        return '中';
      case PriorityLevel.high:
        return '高';
    }
  }

  /// カラー
  Color get color {
    switch (this) {
      case PriorityLevel.low:
        return Colors.grey;
      case PriorityLevel.medium:
        return Colors.orange;
      case PriorityLevel.high:
        return Colors.red;
    }
  }

  /// アイコン
  IconData get icon {
    switch (this) {
      case PriorityLevel.low:
        return Icons.arrow_downward;
      case PriorityLevel.medium:
        return Icons.remove;
      case PriorityLevel.high:
        return Icons.arrow_upward;
    }
  }

  /// ソート順
  int get sortOrder {
    switch (this) {
      case PriorityLevel.high:
        return 0;
      case PriorityLevel.medium:
        return 1;
      case PriorityLevel.low:
        return 2;
    }
  }
}

/// 優先度サービス
class PriorityService {
  final FirebaseFirestore _firestore;

  PriorityService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  /// クエストの優先度を設定
  Future<void> setPriority({
    required String userId,
    required String questId,
    required PriorityLevel priority,
  }) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('quests')
          .doc(questId)
          .update({
            'priority': priority.name,
            'priorityOrder': priority.sortOrder,
          });

      AppLogger().info(
        'Priority set',
        data: {'questId': questId, 'priority': priority.name},
      );
    } catch (e, stack) {
      AppLogger().error('Failed to set priority', e, stack);
      rethrow;
    }
  }

  /// 優先度でクエストをソート
  List<T> sortByPriority<T>(
    List<T> quests,
    PriorityLevel Function(T) getPriority,
  ) {
    final sorted = List<T>.from(quests);
    sorted.sort((a, b) {
      final priorityA = getPriority(a);
      final priorityB = getPriority(b);
      return priorityA.sortOrder.compareTo(priorityB.sortOrder);
    });
    return sorted;
  }
}
