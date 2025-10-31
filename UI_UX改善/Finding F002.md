Finding F002 — 通知遷移でgoを使用している

Severity: P2

Area: Navigation

Files: lib/core/notifications/notification_navigation_handler.dart:L19–L49

Symptom (現象): 通知からクエスト詳細やペア画面などを開く際にcontext.goを用いているため、シェルタブのナビゲーションスタックがリセットされ、戻る操作でホームに戻ってしまう。GoRouterの使い分け規則に反している。

Likely Root Cause (推定原因): GoRouterのAPI設計に不慣れで、タブ遷移と詳細遷移の区別が反映されていない。すべての遷移でgoを使用したまま実装している。

Concrete Fix (修正案): 詳細画面（今日のクエスト一覧・クエスト詳細・ペア・実績）はcontext.pushで遷移し、タブ画面（統計）はgoのままとする。これにより、Androidバックボタンやアプリの戻る操作で前の画面に戻れるようになる。以下に該当部分のパッチを示す。

Tests (テスト): ウィジェットテストNotificationTap_uses_push_for_detailsを作成し、通知をタップした際にcontext.pushが呼ばれていること、およびバック操作で元のタブに戻ることを検証する。

Impact/Effort/Confidence: I=3, E=0.5 days, C=5

Patch (≤30 lines, unified diff if possible):

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
 @@ static Future<void> handleNotificationTap({
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
 @@ static Future<void> handleNotificationTap({
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
 @@ static Future<void> handleNotificationTap({
 -         case 'achievement_unlocked':
 -           // 実績画面へ
 -           context.go('/achievements');
 -           break;
 +         case 'achievement_unlocked':
 +           // 実績画面は詳細画面として push
 +           context.push('/achievements');
 +           break;