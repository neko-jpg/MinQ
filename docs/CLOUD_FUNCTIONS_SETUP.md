# Cloud Functions セットアップ

## 概要
Firestoreの一意制約やその他のビジネスロジックをCloud Functionsで実装します。

## 必要な関数

### 1. ユーザー名の一意性チェック
```javascript
// functions/src/index.ts
import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

admin.initializeApp();

export const checkUsernameUniqueness = functions.https.onCall(
  async (data, context) => {
    const { username } = data;

    if (!context.auth) {
      throw new functions.https.HttpsError(
        'unauthenticated',
        'User must be authenticated'
      );
    }

    const snapshot = await admin
      .firestore()
      .collection('users')
      .where('username', '==', username)
      .limit(1)
      .get();

    return { isAvailable: snapshot.empty };
  }
);

export const enforceUsernameUniqueness = functions.firestore
  .document('users/{userId}')
  .onWrite(async (change, context) => {
    const newData = change.after.data();
    const oldData = change.before.data();

    if (!newData) return; // 削除の場合

    const newUsername = newData.username;
    const oldUsername = oldData?.username;

    // ユーザー名が変更されていない場合はスキップ
    if (newUsername === oldUsername) return;

    // 同じユーザー名を持つ他のユーザーをチェック
    const snapshot = await admin
      .firestore()
      .collection('users')
      .where('username', '==', newUsername)
      .get();

    // 自分以外に同じユーザー名が存在する場合
    if (snapshot.size > 1) {
      // ユーザー名をリセット
      await change.after.ref.update({
        username: oldUsername || `user_${context.params.userId.substring(0, 8)}`,
      });

      console.error(`Duplicate username detected: ${newUsername}`);
    }
  });
```

### 2. ペアリクエストの重複防止
```javascript
export const enforcePairRequestUniqueness = functions.firestore
  .document('pairRequests/{requestId}')
  .onCreate(async (snap, context) => {
    const data = snap.data();
    const { fromUserId, toUserId } = data;

    // 既存のリクエストをチェック
    const existingRequests = await admin
      .firestore()
      .collection('pairRequests')
      .where('fromUserId', '==', fromUserId)
      .where('toUserId', '==', toUserId)
      .where('status', '==', 'pending')
      .get();

    // 重複がある場合は新しいリクエストを削除
    if (existingRequests.size > 1) {
      await snap.ref.delete();
      console.error('Duplicate pair request detected');
    }
  });
```

### 3. クエスト作成数の制限
```javascript
export const enforceQuestLimit = functions.firestore
  .document('quests/{questId}')
  .onCreate(async (snap, context) => {
    const data = snap.data();
    const { userId } = data;

    // ユーザーのクエスト数をカウント
    const questsSnapshot = await admin
      .firestore()
      .collection('quests')
      .where('userId', '==', userId)
      .where('isArchived', '==', false)
      .get();

    // 無料ユーザーは10個まで
    const maxQuests = 10;

    if (questsSnapshot.size > maxQuests) {
      await snap.ref.delete();
      console.error(`User ${userId} exceeded quest limit`);
    }
  });
```

## デプロイ方法

```bash
# Firebase CLIのインストール
npm install -g firebase-tools

# ログイン
firebase login

# プロジェクトの初期化
firebase init functions

# デプロイ
firebase deploy --only functions
```

## 環境変数の設定

```bash
# 本番環境
firebase functions:config:set environment.mode="production"

# ステージング環境
firebase functions:config:set environment.mode="staging"
```

## ローカルテスト

```bash
# エミュレーターの起動
firebase emulators:start

# 特定の関数のみテスト
firebase emulators:start --only functions
```

## 注意事項
- Cloud Functionsは課金対象です
- 実行回数と実行時間に注意してください
- エラーハンドリングを適切に実装してください
- ログを適切に記録してください
