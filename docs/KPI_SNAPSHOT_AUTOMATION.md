# KPIダッシュボード自動スナップショット & Slack送信

## ゴール
- Looker Studioの主要チャートを日次で画像化し、Slack `#minq-metrics`に投稿
- KPI閾値を自動判定し、異常値の場合はアラート絵文字を付与

## 構成
1. **BigQuery Export**: `analytics_app.daily_metrics` から最新値を取得
2. **Formatter**: `tool/kpi_snapshot.dart` がJSON入力を受け取り、ターゲットとの比較結果を生成
3. **Slack送信**: Incoming Webhook (`SLACK_KPI_WEBHOOK_URL`) にテキストメッセージを投稿（dry-runサポート）
4. **スケジュール**: `.github/workflows/kpi-snapshot.yml` が平日 09:00 JST に実行

## JSONペイロード例
```json
{
  "generatedAt": "2024-06-01T00:00:00Z",
  "metrics": [
    {"key": "d1_retention", "label": "D1 Retention", "value": 0.46, "target": 0.45},
    {"key": "quest_completion", "label": "Quest Completion", "value": 0.68, "target": 0.65},
    {"key": "notification_open", "label": "Notification Open", "value": 0.18, "target": 0.20}
  ]
}
```

## Slackメッセージ仕様
- タイトル: `MinQ KPI Snapshot - {generatedAt JST}`
- 各メトリクスの行: `:white_check_mark:` もしくは `:warning:` + `label` + `value` (百分率表示)
- dry-run時は標準出力にプレビューを表示

## 運用
- 失敗時はSlackに`@channel`せず、`#minq-data-alerts`へリトライ通知
- ペイロード生成はCloud Functions (`minq-kpi-snapshot`) でBigQueryから取得
- 機密データ保護のため、Webhook URLはGitHub Secrets管理
- GitHub ActionsのCron設定（`0 0 * * 1-5` UTC）で自動実行
