Patch for F002 — Use push for detail navigation in notifications

通知からディープリンクされる詳細画面はタブ履歴を残す必要があるため、context.goをcontext.pushに置き換えます。統計画面のようなタブ画面はgoのままにします。

 --- a/lib/core/notifications/notification_navigation_handler.dart
 +++ b/lib/core/notifications/notification_navigation_handler.dart
@@ static Future<void> handleNotificationTap({
-         case 'quest_reminder':
-           // 今日のクエスト一覧へ
-           context.go('/today-quests');
-           break;
+         case 'quest_reminder':
+           // 今日のクエスト一覧は詳細画面として push する
+           context.push('/today-quests');
+           break;
@@
-         case 'quest_deadline':
-           // 特定のクエストへ
-           final questId = payload?['questId'] as String?;
-           if (questId != null) {
-             context.go('/quest/$questId');
-           }
-           break;
+         case 'quest_deadline':
+           // 特定のクエストへは push で開く
+           final questId = payload?['questId'] as String?;
+           if (questId != null) {
+             context.push('/quest/$questId');
+           }
+           break;
@@
-         case 'pair_message':
-           // ペア画面へ
-           final pairId = payload?['pairId'] as String?;
-           if (pairId != null) {
-             context.go('/pair/$pairId');
-           }
-           break;
+         case 'pair_message':
+           // ペア画面は詳細画面として push
+           final pairId = payload?['pairId'] as String?;
+           if (pairId != null) {
+             context.push('/pair/$pairId');
+           }
+           break;
@@
-         case 'achievement_unlocked':
-           // 実績画面へ
-           context.go('/achievements');
-           break;
+         case 'achievement_unlocked':
+           // 実績画面は詳細画面として push
+           context.push('/achievements');
+           break;
@@
-         case 'weekly_summary':
-           // 統計画面へ
-           context.go('/stats');
-           break;
+         case 'weekly_summary':
+           // 統計画面はタブなので go を維持
+           context.go('/stats');
+           break;