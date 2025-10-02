# バックエンドコストアラート設計（Firestore / Cloud Functions超過時）

## 目的
- 月次予算を超える前にコストを検知し、施策を打てるようにする
- 予測値も把握し、突発的なスパイクに備える

## データ取得
1. Cloud Billing ExportをBigQuery `billing.gcp_billing_export_v1` に出力
2. `tool/backend_cost_alert.dart` が以下のテーブルを参照
   - `service.description`（例: Firestore, Cloud Functions）
   - `cost`、`usage.amount_in_pricing_units`
   - `usage_start_time`
3. しきい値設定は`config/backend_cost_thresholds.yaml`

## アラート条件
| サービス | 条件 |
| --- | --- |
| Firestore | 当月累計コスト > 予算の80% かつ 日次コスト平均が前週比20%増 |
| Cloud Functions | 同上 + 実行回数が1日あたり300万回を超過 |
| Cloud Run | 1時間あたりのCPU秒が5万秒超 |

## 通知フロー
1. GitHub Actions (`backend-cost-alert.yml`) が毎日 00:30 JST にBigQueryへクエリ
2. `tool/backend_cost_alert.dart` がSlack (Webhook) と Opsgenie (API) に通知
3. 通知内容
   - 対象サービス
   - 当月コスト、予算、予測コスト
   - 主要増加要因（クエリ結果のTop Projects）

## 対応プロセス
- アラート受信後、SREチームがNotionテンプレート「Cost Incident」を作成
- 原因分析（例: 新機能の書き込み増加、失敗リトライ）が完了するまで毎日フォローアップ
- コスト抑制策（キャッシュ、TTL設定、バッチ処理）を検討し、30日以内に再発防止策をレビュー

## 今後の改善
- 予測にProphetを利用して季節性を考慮
- Slack通知にLooker Studioのコストダッシュボードリンクを添付
- Firebase Remote ConfigでDynamic Samplingを調整し、コスト削減施策を即時反映
