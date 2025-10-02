# API ドキュメント

## 概要

MinQ APIは、アプリケーションの主要機能へのプログラマティックアクセスを提供します。

## 認証

### Personal Access Token

```dart
// トークンの生成
final token = await generatePersonalAccessToken(userId);

// APIリクエストにトークンを含める
final headers = {
  'Authorization': 'Bearer $token',
  'Content-Type': 'application/json',
};
```

### トークンの管理

- トークンは安全に保管してください
- 定期的にローテーションしてください
- 不要になったトークンは削除してください

## エンドポイント

### クエスト管理

#### クエスト一覧取得

```
GET /api/v1/quests
```

レスポンス:
```json
{
  "quests": [
    {
      "id": "quest_123",
      "title": "朝ランニング",
      "category": "健康",
      "status": "active"
    }
  ]
}
```

#### クエスト作成

```
POST /api/v1/quests
```

リクエスト:
```json
{
  "title": "読書30分",
  "category": "学習",
  "estimatedMinutes": 30
}
```

#### クエスト完了

```
POST /api/v1/quests/{questId}/complete
```

### 統計情報

#### 統計取得

```
GET /api/v1/stats
```

レスポンス:
```json
{
  "currentStreak": 7,
  "longestStreak": 30,
  "totalCompleted": 150
}
```

## レート制限

- 認証済みリクエスト: 100リクエスト/分
- 未認証リクエスト: 10リクエスト/分

レート制限に達した場合:
```json
{
  "error": "rate_limit_exceeded",
  "retryAfter": 60
}
```

## エラーハンドリング

### エラーコード

| コード | 説明 |
|-------|------|
| 400 | 不正なリクエスト |
| 401 | 認証エラー |
| 403 | 権限エラー |
| 404 | リソースが見つからない |
| 429 | レート制限超過 |
| 500 | サーバーエラー |

### エラーレスポンス

```json
{
  "error": "invalid_request",
  "message": "タイトルは必須です",
  "code": 400
}
```

## Webhook

### イベント通知

```
POST https://your-server.com/webhook
```

ペイロード:
```json
{
  "event": "quest.completed",
  "data": {
    "questId": "quest_123",
    "userId": "user_456",
    "completedAt": "2025-01-15T10:30:00Z"
  }
}
```

### サポートされているイベント

- `quest.created`
- `quest.completed`
- `quest.deleted`
- `achievement.unlocked`
- `streak.milestone`

## SDK

### Dart/Flutter

```dart
import 'package:minq_api/minq_api.dart';

final client = MinQApiClient(
  token: 'your_token',
);

// クエスト一覧取得
final quests = await client.quests.list();

// クエスト作成
final quest = await client.quests.create(
  title: '読書30分',
  category: '学習',
);
```

## ベストプラクティス

1. **エラーハンドリング**: すべてのAPIコールでエラーを適切に処理
2. **リトライロジック**: 一時的なエラーに対してリトライを実装
3. **キャッシング**: 頻繁にアクセスするデータはキャッシュ
4. **バッチ処理**: 可能な限りバッチAPIを使用

## サポート

- ドキュメント: https://docs.minq.app
- API Status: https://status.minq.app
- サポート: api-support@minq.app
