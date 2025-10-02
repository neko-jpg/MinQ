# Carbon Footprint 計測計画（CI/CD & ランタイム）

## 目的
- 開発/運用による温室効果ガス排出量を定量化し、削減施策を策定
- サステナビリティ指標を四半期レポートに組み込み

## 範囲
- GitHub Actions、Firebase Test LabなどCIジョブ
- GCP（Firestore、Functions、Cloud Run、Cloud Storage）
- エンドユーザー端末の電力消費推定

## 計測方法
1. **CI/CD**
   - GitHub Actionsの`GITHUB_RUN_ATTEMPT`ごとの実行時間を取得
   - 各ランナー種別の消費電力係数（例: 0.035 kWh/分）を元にCO2換算
   - `tool/carbon_report.dart`で`ci_runs.csv`を読み込み、自動計算
2. **GCPリソース**
   - Cloud Billing ExportをBigQueryへ
   - `gcp_carbon_intensity`テーブルをLooker Studioで可視化
   - サービス別消費電力量係数（Google公開値）を掛け合わせ
3. **エンドユーザー**
   - Firebase Performance Monitoringのバッテリー指標を使用
   - `displayed_time` × 端末平均消費電力で推定

## 自動化
- `.github/workflows/carbon-report.yml`
  - 月初1日にスケジュール実行
  - BigQueryから`billing_export`データを取得
  - `tool/carbon_report.dart`を実行し、SlackにPDFレポートを送付

## 目標指標
- CI/CD: 月間CO2e 10%削減（キャッシュ導入、不要ジョブ停止）
- ランタイム: Cloud Functionsの平均CPU使用率70%以下
- ユーザー端末: セッションあたり消費電力量 15%削減（ダークモード・バッチ同期）

## ロードマップ
1. データ収集基盤の構築
2. 初回ベースラインレポートの作成
3. 削減施策（CIキャッシュ、Firestoreルール最適化）の実施
4. 四半期レビューでの改善計画見直し
