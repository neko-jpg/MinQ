# データモデル仕様

## Users Collection

ユーザー情報を格納

```typescript
{
  uid: string;              // ユーザーID（Firebase Auth）
  email: string;            // メールアドレス
  displayName: string;      // 表示名
  avatarUrl?: string;       // アバター画像URL
  createdAt: Timestamp;     // 作成日時
  updatedAt: Timestamp;     // 更新日時
  preferences: {            // ユーザー設定
    theme: 'light' | 'dark' | 'system';
    language: string;       // 言語コード
    notifications: boolean; // 通知有効/無効
  };
  stats: {                  // 統計情報
    totalQuests: number;    // 総クエスト数
    completedQuests: number; // 完了クエスト数
    currentStreak: number;  // 現在の連続日数
    longestStreak: number;  // 最長連続日数
  };
  modelVersion: number;     // データモデルバージョン
}
```

## Quests Collection

クエスト（習慣）情報を格納

```typescript
{
  id: string;               // クエストID
  userId: string;           // ユーザーID
  title: string;            // タイトル
  description?: string;     // 説明
  category: string;         // カテゴリー
  icon?: string;            // アイコン
  color?: string;           // 色
  isActive: boolean;        // アクティブ状態
  createdAt: Timestamp;     // 作成日時
  updatedAt: Timestamp;     // 更新日時
  deletedAt?: Timestamp;    // 削除日時（ソフトデリート）
  isDeleted: boolean;       // 削除フラグ
  schedule: {               // スケジュール設定
    frequency: 'daily' | 'weekly' | 'custom';
    days?: number[];        // 曜日（1-7）
    time?: string;          // 通知時刻
  };
  stats: {                  // 統計情報
    completionCount: number; // 完了回数
    currentStreak: number;  // 現在の連続日数
    longestStreak: number;  // 最長連続日数
  };
  modelVersion: number;     // データモデルバージョン
}
```

## QuestLogs Collection

クエスト完了ログを格納

```typescript
{
  id: string;               // ログID
  questId: string;          // クエストID
  userId: string;           // ユーザーID
  completedAt: Timestamp;   // 完了日時
  note?: string;            // メモ
  createdAt: Timestamp;     // 作成日時
}
```

## Pairs Collection

ペア情報を格納

```typescript
{
  id: string;               // ペアID
  members: string[];        // メンバーのユーザーID配列
  createdAt: Timestamp;     // 作成日時
  status: 'active' | 'inactive'; // ステータス
  matchingScore?: number;   // マッチングスコア
}
```

## PairMessages Collection

ペア間のメッセージを格納

```typescript
{
  id: string;               // メッセージID
  pairId: string;           // ペアID
  senderId: string;         // 送信者ID
  message: string;          // メッセージ内容
  createdAt: Timestamp;     // 作成日時
  isRead: boolean;          // 既読フラグ
}
```

## QuestPauses Collection

クエストの一時停止情報を格納

```typescript
{
  id: string;               // 一時停止ID
  questId: string;          // クエストID
  userId: string;           // ユーザーID
  startDate: Timestamp;     // 開始日
  endDate: Timestamp;       // 終了日
  reason?: string;          // 理由
  createdAt: Timestamp;     // 作成日時
}
```

## FreezeDays Collection

凍結日情報を格納

```typescript
{
  id: string;               // 凍結日ID
  questId: string;          // クエストID
  userId: string;           // ユーザーID
  date: Timestamp;          // 凍結日
  reason?: string;          // 理由
  createdAt: Timestamp;     // 作成日時
}
```

## Reports Collection

通報情報を格納

```typescript
{
  id: string;               // 通報ID
  contentId: string;        // コンテンツID
  reporterId: string;       // 通報者ID
  reason: string;           // 理由
  details?: string;         // 詳細
  status: 'pending' | 'reviewing' | 'approved' | 'rejected';
  createdAt: Timestamp;     // 作成日時
  reviewedAt?: Timestamp;   // レビュー日時
}
```

## インデックス

### Users
- `uid` (unique)
- `email` (unique)

### Quests
- `userId` + `isDeleted` + `createdAt`
- `userId` + `isActive`

### QuestLogs
- `userId` + `completedAt`
- `questId` + `completedAt`
- `userId` + `questId` + `completedAt`

### Pairs
- `members` (array-contains)
- `status`

### PairMessages
- `pairId` + `createdAt`
- `pairId` + `isRead`

## セキュリティルール

詳細は `firestore.rules` を参照

### 基本方針
- ユーザーは自分のデータのみ読み書き可能
- ペアメンバーはペアデータを読み取り可能
- 管理者のみ全データにアクセス可能

## データ移行

バージョンアップ時のデータ移行は `lib/core/migration/migration_manager.dart` で管理

### 移行履歴
- v1 → v2: questにcategoryフィールド追加
- v2 → v3: userにpreferencesフィールド追加
