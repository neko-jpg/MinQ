import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:minq/core/logging/app_logger.dart';
import 'package:minq/presentation/routing/app_router.dart';

/// 通知ナビゲーションハンドラー
/// F002対応: 通知からの遷移で適切にcontext.pushを使用してタブ履歴を保持
class NotificationNavigationHandler {
  /// 通知タップ時の処理
  static Future<void> handleNotificationTap({
    required BuildContext context,
    required String notificationType,
    Map<String, dynamic>? payload,
  }) async {
    try {
      logger.info(
        'Notification tapped',
        data: {'type': notificationType, 'payload': payload},
      );

      switch (notificationType) {
        case 'quest_reminder':
          // ホーム画面（今日のクエスト一覧）へ - タブ画面なのでcontext.go
          context.go(AppRoutes.home);
          break;

        case 'quest_deadline':
          // 特定のクエスト詳細へ - 詳細画面なのでcontext.push
          final questId = payload?['questId'] as String?;
          if (questId != null) {
            final questIdInt = int.tryParse(questId);
            if (questIdInt != null) {
              context.push(
                AppRoutes.questDetail.replaceFirst(':questId', questId),
              );
            }
          }
          break;

        case 'pair_message':
          // ペアチャット画面へ - 詳細画面なのでcontext.push
          final pairId = payload?['pairId'] as String?;
          if (pairId != null) {
            context.push(
              AppRoutes.pairChat.replaceFirst(':pairId', pairId),
            );
          }
          break;

        case 'achievement_unlocked':
          // プロフィール画面（実績表示）へ - タブ画面なのでcontext.go
          context.go(AppRoutes.profile);
          break;

        case 'weekly_summary':
          // 統計画面へ - タブ画面なのでcontext.go
          context.go(AppRoutes.stats);
          break;

        case 'pair_progress':
          // ペア画面へ - タブ画面なのでcontext.go
          context.go(AppRoutes.pair);
          break;

        case 'challenge_update':
          // チャレンジ画面へ - タブ画面なのでcontext.go
          context.go(AppRoutes.challenges);
          break;

        default:
          // ホーム画面へ - タブ画面なのでcontext.go
          context.go(AppRoutes.home);
      }
    } catch (e, stack) {
      logger.error(
        'Failed to handle notification tap',
        error: e,
        stackTrace: stack,
      );
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
