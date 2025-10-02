# Firestore データライフサイクル管理

## TTL (Time To Live) 方針

### 自動削除対象データ

#### 一時データ（7日後に削除）
- セッショントークン
- 一時的な招待コード
- キャッシュデータ

```javascript
// Cloud Functionsでの実装例
exports.cleanupExpiredData = functions.pubsub
  .schedule('every 24 hours')
  .onRun(async (context) => {
    const sevenDaysAgo = admin.firestore.Timestamp.fromDate(
      new Date(Date.now() - 7 * 24 * 60 * 60 * 1000)
    );
    
    const snapshot = await admin.firestore()
      .collection('temporaryData')
      .where('expiresAt', '<=', sevenDaysAgo)
      .get();
    
    const batch = admin.firestore().batch();
    snapshot.docs.forEach(doc => batch.delete(doc.ref));
    await batch.commit();
  });
```

#### 通知履歴（30日後に削除）
- プッシュ通知ログ
- アプリ内通知履歴

#### 分析データ（90日後に削除）
- イベントログ
- エラーログ（非致命的）

### TTL設定方法

各ドキュメントに`expiresAt`フィールドを追加:

```dart
// Dart実装例
await firestore.collection('temporaryData').add({
  'data': 'some data',
  'expiresAt': Timestamp.fromDate(
    DateTime.now().add(Duration(days: 7)),
  ),
  'createdAt': FieldValue.serverTimestamp(),
});
```

## ソフトデリート方針

### ソフトデリート対象

#### ユーザーデータ
- 理由: GDPR対応、誤削除からの復旧
- 保持期間: 30日間
- 完全削除: 30日後に自動削除

```dart
// ユーザー削除（ソフトデリート）
Future<void> softDeleteUser(String userId) async {
  await firestore.collection('users').doc(userId).update({
    'deletedAt': FieldValue.serverTimestamp(),
    'status': 'deleted',
  });
}

// ユーザー復元
Future<void> restoreUser(String userId) async {
  await firestore.collection('users').doc(userId).update({
    'deletedAt': FieldValue.delete(),
    'status': 'active',
  });
}
```

#### クエスト
- 理由: 誤削除からの復旧、統計データの整合性
- 保持期間: 30日間
- アーカイブ機能: ユーザーが明示的にアーカイブ可能

```dart
// クエスト削除（ソフトデリート）
Future<void> softDeleteQuest(String questId) async {
  await firestore.collection('quests').doc(questId).update({
    'deletedAt': FieldValue.serverTimestamp(),
    'isDeleted': true,
  });
}

// クエストアーカイブ
Future<void> archiveQuest(String questId) async {
  await firestore.collection('quests').doc(questId).update({
    'archivedAt': FieldValue.serverTimestamp(),
    'isArchived': true,
  });
}
```

#### ペア関係
- 理由: トラブル時の調査、統計データ
- 保持期間: 90日間

### ハードデリート対象

以下のデータは即座に完全削除:

- 一時的なセッションデータ
- キャッシュデータ
- 重複データ

### クエリでの除外

ソフトデリートされたデータをクエリから除外:

```dart
// アクティブなクエストのみ取得
Stream<List<Quest>> watchActiveQuests(String userId) {
  return firestore
    .collection('quests')
    .where('userId', isEqualTo: userId)
    .where('isDeleted', isEqualTo: false)
    .snapshots()
    .map((snapshot) => snapshot.docs.map((doc) => Quest.fromFirestore(doc)).toList());
}

// 削除されたクエストを含む全クエスト取得（管理者用）
Stream<List<Quest>> watchAllQuests(String userId) {
  return firestore
    .collection('quests')
    .where('userId', isEqualTo: userId)
    .snapshots()
    .map((snapshot) => snapshot.docs.map((doc) => Quest.fromFirestore(doc)).toList());
}
```

## 自動クリーンアップ

### Cloud Functions実装

```javascript
// 30日前に削除されたユーザーを完全削除
exports.cleanupDeletedUsers = functions.pubsub
  .schedule('every 24 hours')
  .onRun(async (context) => {
    const thirtyDaysAgo = admin.firestore.Timestamp.fromDate(
      new Date(Date.now() - 30 * 24 * 60 * 60 * 1000)
    );
    
    const snapshot = await admin.firestore()
      .collection('users')
      .where('deletedAt', '<=', thirtyDaysAgo)
      .get();
    
    const batch = admin.firestore().batch();
    
    for (const doc of snapshot.docs) {
      // ユーザーの関連データも削除
      const userId = doc.id;
      
      // クエストを削除
      const quests = await admin.firestore()
        .collection('quests')
        .where('userId', '==', userId)
        .get();
      quests.docs.forEach(questDoc => batch.delete(questDoc.ref));
      
      // ログを削除
      const logs = await admin.firestore()
        .collection('questLogs')
        .where('userId', '==', userId)
        .get();
      logs.docs.forEach(logDoc => batch.delete(logDoc.ref));
      
      // ユーザーを削除
      batch.delete(doc.ref);
    }
    
    await batch.commit();
    console.log(`Cleaned up ${snapshot.size} deleted users`);
  });

// 30日前に削除されたクエストを完全削除
exports.cleanupDeletedQuests = functions.pubsub
  .schedule('every 24 hours')
  .onRun(async (context) => {
    const thirtyDaysAgo = admin.firestore.Timestamp.fromDate(
      new Date(Date.now() - 30 * 24 * 60 * 60 * 1000)
    );
    
    const snapshot = await admin.firestore()
      .collection('quests')
      .where('deletedAt', '<=', thirtyDaysAgo)
      .where('isDeleted', '==', true)
      .get();
    
    const batch = admin.firestore().batch();
    snapshot.docs.forEach(doc => batch.delete(doc.ref));
    await batch.commit();
    
    console.log(`Cleaned up ${snapshot.size} deleted quests`);
  });
```

## データモデル規約

### 必須フィールド

全てのコレクションに以下のフィールドを含める:

```dart
class BaseModel {
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final DateTime? archivedAt;
  final bool isDeleted;
  final bool isArchived;
  
  BaseModel({
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    this.archivedAt,
    this.isDeleted = false,
    this.isArchived = false,
  });
}
```

### インデックス

ソフトデリートとTTLのために以下のインデックスを作成:

```json
{
  "indexes": [
    {
      "collectionGroup": "users",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "deletedAt", "order": "ASCENDING" },
        { "fieldPath": "status", "order": "ASCENDING" }
      ]
    },
    {
      "collectionGroup": "quests",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "userId", "order": "ASCENDING" },
        { "fieldPath": "isDeleted", "order": "ASCENDING" },
        { "fieldPath": "createdAt", "order": "DESCENDING" }
      ]
    },
    {
      "collectionGroup": "temporaryData",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "expiresAt", "order": "ASCENDING" }
      ]
    }
  ]
}
```

## バックアップ戦略

### 自動バックアップ

- 毎日: 全データの自動バックアップ
- 保持期間: 30日間
- ストレージ: Cloud Storage

### 手動バックアップ

ユーザーが明示的にデータをエクスポート可能:

```dart
Future<void> exportUserData(String userId) async {
  final userData = await firestore.collection('users').doc(userId).get();
  final quests = await firestore
    .collection('quests')
    .where('userId', isEqualTo: userId)
    .get();
  final logs = await firestore
    .collection('questLogs')
    .where('userId', isEqualTo: userId)
    .get();
  
  final exportData = {
    'user': userData.data(),
    'quests': quests.docs.map((doc) => doc.data()).toList(),
    'logs': logs.docs.map((doc) => doc.data()).toList(),
    'exportedAt': DateTime.now().toIso8601String(),
  };
  
  // JSONファイルとしてダウンロード
  final json = jsonEncode(exportData);
  // ... ファイル保存処理
}
```

## GDPR対応

### データ削除リクエスト

ユーザーからのデータ削除リクエストに対応:

1. ソフトデリート（即座）
2. 30日間の猶予期間
3. 完全削除（30日後）

### データポータビリティ

ユーザーが自分のデータをエクスポート可能:

- JSON形式
- CSV形式（統計データ）
- PDF形式（レポート）

## モニタリング

### アラート設定

- ストレージ使用量が80%を超えた場合
- 削除処理が失敗した場合
- TTL処理が24時間以上実行されていない場合

### ダッシュボード

- 総データ量
- ソフトデリート済みデータ量
- TTL対象データ量
- クリーンアップ実行履歴
