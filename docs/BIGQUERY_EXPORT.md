# BigQuery エクスポート設定

## 概要
FirestoreのデータをBigQueryにエクスポートして、高度な分析を可能にします。

## 設定手順

### 1. Firebase ConsoleでBigQueryを有効化

1. Firebase Consoleを開く
2. プロジェクト設定 > 統合 > BigQuery
3. 「リンク」をクリック
4. エクスポートするコレクションを選択
   - users
   - quests
   - questLogs
   - pairRequests
   - achievements

### 2. エクスポート設定

```json
{
  "collections": [
    {
      "name": "users",
      "fields": [
        "userId",
        "username",
        "email",
        "createdAt",
        "lastLoginAt",
        "isPremium"
      ]
    },
    {
      "name": "quests",
      "fields": [
        "questId",
        "userId",
        "title",
        "description",
        "createdAt",
        "isArchived"
      ]
    },
    {
      "name": "questLogs",
      "fields": [
        "logId",
        "questId",
        "userId",
        "completedAt",
        "streak"
      ]
    }
  ]
}
```

### 3. BigQueryでのクエリ例

#### ユーザーのアクティビティ分析
```sql
SELECT
  DATE(timestamp) as date,
  COUNT(DISTINCT user_id) as active_users,
  COUNT(*) as total_completions
FROM
  `project-id.dataset.questLogs`
WHERE
  timestamp >= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 30 DAY)
GROUP BY
  date
ORDER BY
  date DESC
```

#### クエスト完了率の分析
```sql
SELECT
  q.title,
  COUNT(DISTINCT ql.user_id) as unique_users,
  COUNT(ql.log_id) as total_completions,
  AVG(ql.streak) as avg_streak
FROM
  `project-id.dataset.quests` q
LEFT JOIN
  `project-id.dataset.questLogs` ql
ON
  q.quest_id = ql.quest_id
GROUP BY
  q.title
ORDER BY
  total_completions DESC
LIMIT 20
```

#### ユーザーリテンション分析
```sql
WITH user_cohorts AS (
  SELECT
    user_id,
    DATE_TRUNC(DATE(MIN(timestamp)), MONTH) as cohort_month
  FROM
    `project-id.dataset.questLogs`
  GROUP BY
    user_id
),
user_activities AS (
  SELECT
    user_id,
    DATE_TRUNC(DATE(timestamp), MONTH) as activity_month
  FROM
    `project-id.dataset.questLogs`
  GROUP BY
    user_id,
    activity_month
)
SELECT
  uc.cohort_month,
  ua.activity_month,
  COUNT(DISTINCT uc.user_id) as cohort_size,
  COUNT(DISTINCT ua.user_id) as retained_users,
  ROUND(COUNT(DISTINCT ua.user_id) / COUNT(DISTINCT uc.user_id) * 100, 2) as retention_rate
FROM
  user_cohorts uc
LEFT JOIN
  user_activities ua
ON
  uc.user_id = ua.user_id
GROUP BY
  uc.cohort_month,
  ua.activity_month
ORDER BY
  uc.cohort_month,
  ua.activity_month
```

#### ペア機能の利用状況
```sql
SELECT
  DATE(timestamp) as date,
  COUNT(*) as pair_requests,
  COUNTIF(status = 'accepted') as accepted_requests,
  ROUND(COUNTIF(status = 'accepted') / COUNT(*) * 100, 2) as acceptance_rate
FROM
  `project-id.dataset.pairRequests`
WHERE
  timestamp >= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 30 DAY)
GROUP BY
  date
ORDER BY
  date DESC
```

### 4. データスタジオでのダッシュボード作成

1. Google Data Studioを開く
2. 新しいレポートを作成
3. BigQueryをデータソースとして追加
4. 以下のグラフを作成：
   - DAU/MAU推移
   - クエスト完了数推移
   - ユーザーリテンション率
   - ペア機能利用率
   - 課金ユーザー数推移

### 5. 定期レポートの設定

```sql
-- 週次レポート用のビュー作成
CREATE OR REPLACE VIEW `project-id.dataset.weekly_report` AS
SELECT
  DATE_TRUNC(DATE(timestamp), WEEK) as week,
  COUNT(DISTINCT user_id) as active_users,
  COUNT(*) as total_completions,
  AVG(streak) as avg_streak,
  COUNTIF(is_premium) as premium_users
FROM
  `project-id.dataset.questLogs` ql
JOIN
  `project-id.dataset.users` u
ON
  ql.user_id = u.user_id
GROUP BY
  week
ORDER BY
  week DESC
```

## コスト管理

### BigQueryの料金
- ストレージ: $0.02/GB/月
- クエリ: $5/TB

### コスト削減のヒント
1. パーティション分割テーブルを使用
2. クエリ結果をキャッシュ
3. 必要なカラムのみをSELECT
4. WHERE句で日付範囲を制限

## 注意事項
- エクスポートには遅延があります（通常24-48時間）
- 個人情報の取り扱いに注意してください
- GDPRやプライバシーポリシーに準拠してください
- 定期的にデータを確認してください
