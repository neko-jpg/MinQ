import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:minq/core/logging/app_logger.dart';

/// 通知ナビゲーションハンドラー
class NotificationNavigationHandler {
  /// 通知タップ時の処理
  static Future<void> handleNotificationTap({
    required BuildContext context,
    required String notificationType,
    Map<String, dynamic>? payload,
  }) async {
    try {
      AppLogger.info('Notification tapped', data: {
        'type': notificationType,
        'payload': payload,
      });

      switch (notificationType) {
        case 'quest_reminder':
          // 今日のクエスト一覧へ
          context.go('/today-quests');
          break;

        case 'quest_deadline':
          // 特定のクエストへ
          final questId = payload?['questId'] as String?;
          if (questId != null) {
            context.go('/quest/$questId');
          }
          break;

        case 'pair_message':
          // ペア画面へ
          final pairId = payload?['pairId'] as String?;
          if (pairId != null) {
            context.go('/pair/$pairId');
          }
          break;

        case 'achievement_unlocked':
          // 実績画面へ
          context.go('/achievements');
          break;

        case 'weekly_summary':
          // 統計画面へ
          context.go('/stats');
          break;

        default:
          // ホーム画面へ
          context.go('/');
      }
    } catch (e, stack) {
      AppLogger.error('Failed to handle notification tap',
          error: e, stackTrace: stack);
    }
  }

  /// ディープリンクから通知タイプを解析
  static String? parseNotificationType(String deepLink) {
    final uri = Uri.parse(deepLink);
    return uri.queryParameters['type'];
  }

  /// ペイロードを解析
  static Map<String, dynamic>? parsePayload(String deepLink) {
    final uri = Uri.parse(deepLink);
    return uri.queryParameters;
  }
}
