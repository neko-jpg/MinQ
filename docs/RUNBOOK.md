# MiniQ Runbook - 運用手順書

このドキュメントは、MiniQアプリの運用に関する手順をまとめたものです。

## 目次

1. [日常運用](#日常運用)
2. [監視とアラート](#監視とアラート)
3. [インシデント対応](#インシデント対応)
4. [デプロイ手順](#デプロイ手順)
5. [バックアップとリストア](#バックアップとリストア)
6. [トラブルシューティング](#トラブルシューティング)
7. [緊急連絡先](#緊急連絡先)

---

## 日常運用

### 毎日のチェックリスト

#### 朝（9:00 AM）
- [ ] Firebase Consoleでクラッシュレポートを確認
- [ ] Google Play Console / App Store Connectでレビューを確認
- [ ] Slackの通知チャンネルを確認
- [ ] ユーザーサポートメールを確認

#### 夕方（5:00 PM）
- [ ] 当日のKPIを確認（DAU, MAU, 達成率など）
- [ ] エラーログを確認
- [ ] パフォーマンスメトリクスを確認

### 週次チェックリスト

#### 月曜日
- [ ] 先週のKPIレポートを作成
- [ ] ストアレビューに返信
- [ ] バックログの優先順位を見直し

#### 金曜日
- [ ] 今週のリリース内容を確認
- [ ] 来週のリリース計画を確認
- [ ] オンコール担当者を確認

### 月次チェックリスト

- [ ] 月次レポートを作成
- [ ] Firebase/GCPの請求額を確認
- [ ] セキュリティアップデートを確認
- [ ] 依存パッケージの更新を確認
- [ ] バックアップの整合性を確認

---

## 監視とアラート

### 監視対象

#### アプリケーション
- **クラッシュ率**: < 1%
- **ANR率**: < 0.5%
- **起動時間**: < 3秒
- **API レスポンス時間**: < 1秒

#### インフラ
- **Firestore 読み取り**: < 50,000/日
- **Firestore 書き込み**: < 20,000/日
- **Cloud Functions 実行回数**: < 100,000/日
- **ストレージ使用量**: < 10GB

#### ビジネス
- **DAU**: 日次アクティブユーザー数
- **MAU**: 月次アクティブユーザー数
- **リテンション率**: 7日後、30日後
- **クエスト達成率**: 平均達成率

### アラート設定

#### P0（クリティカル）- 即座に対応
- クラッシュ率 > 5%
- API エラー率 > 10%
- サービス停止
- データ損失

**対応時間**: 15分以内
**通知先**: PagerDuty + Slack + メール

#### P1（高）- 1時間以内に対応
- クラッシュ率 > 2%
- API レスポンス時間 > 5秒
- エラー率 > 5%

**対応時間**: 1時間以内
**通知先**: Slack + メール

#### P2（中）- 当日中に対応
- クラッシュ率 > 1%
- パフォーマンス低下
- ストレージ使用量 > 80%

**対応時間**: 8時間以内
**通知先**: Slack

#### P3（低）- 週内に対応
- マイナーなバグ
- UI の改善要望
- ドキュメントの更新

**対応時間**: 1週間以内
**通知先**: Backlog

### 監視ダッシュボード

#### Firebase Console
- URL: https://console.firebase.google.com/
- 確認項目:
  - Crashlytics: クラッシュレポート
  - Performance: パフォーマンスメトリクス
  - Analytics: ユーザー行動
  - Firestore: データベース使用量

#### Google Play Console
- URL: https://play.google.com/console/
- 確認項目:
  - クラッシュと ANR
  - ユーザーレビュー
  - インストール数
  - アンインストール数

#### App Store Connect
- URL: https://appstoreconnect.apple.com/
- 確認項目:
  - クラッシュレポート
  - ユーザーレビュー
  - ダウンロード数
  - 売上（課金がある場合）

---

## インシデント対応

### インシデント対応フロー

```
1. 検知 → 2. トリアージ → 3. 調査 → 4. 対応 → 5. 復旧 → 6. 事後分析
```

### 1. 検知

#### 自動検知
- アラートシステムからの通知
- 監視ダッシュボードの異常値

#### 手動検知
- ユーザーからの報告
- ストアレビュー
- サポートメール

### 2. トリアージ

#### 重要度の判定
- **P0**: サービス停止、データ損失
- **P1**: 主要機能の障害
- **P2**: 一部機能の障害
- **P3**: マイナーな問題

#### 影響範囲の確認
- 影響を受けるユーザー数
- 影響を受ける機能
- 影響を受けるプラットフォーム（iOS/Android）

### 3. 調査

#### ログの確認
```bash
# Firebase Crashlytics
# Firebase Console → Crashlytics → Issues

# Cloud Functions ログ
gcloud functions logs read FUNCTION_NAME --limit 50

# Firestore ログ
gcloud logging read "resource.type=cloud_firestore_database" --limit 50
```

#### 再現手順の確認
1. 問題が発生する条件を特定
2. 開発環境で再現を試みる
3. 再現手順をドキュメント化

### 4. 対応

#### 緊急対応（P0/P1）

**オプション1: ホットフィックス**
```bash
# 修正ブランチを作成
git checkout -b hotfix/critical-bug

# 修正を実装
# ... コード修正 ...

# テスト
flutter test

# コミット
git commit -m "hotfix: Fix critical bug"

# プッシュ
git push origin hotfix/critical-bug

# マージ
# GitHub でプルリクエストを作成し、レビュー後マージ

# リリース
# fastlane を使用して緊急リリース
cd android && fastlane deploy_hotfix
cd ios && fastlane deploy_hotfix
```

**オプション2: ロールバック**
```bash
# Google Play Console
# リリース → 本番環境 → 前のバージョンを選択 → 公開

# App Store Connect
# App Store → バージョン → 前のバージョンを選択 → 送信
```

**オプション3: Feature Flag で無効化**
```dart
// Remote Config で機能を無効化
// Firebase Console → Remote Config → パラメータを更新
// 例: enable_problematic_feature = false
```

#### 通常対応（P2/P3）
1. バグチケットを作成
2. 優先順位を設定
3. 次のリリースで修正

### 5. 復旧

#### 復旧確認
- [ ] 問題が解決したことを確認
- [ ] 影響を受けたユーザーに通知
- [ ] 監視ダッシュボードで正常値を確認

#### ユーザーへの通知
```
件名: [復旧完了] サービス障害のお知らせ

いつもMiniQをご利用いただきありがとうございます。

本日XX:XX頃から発生しておりました障害は、XX:XXに復旧いたしました。
ご不便をおかけして申し訳ございませんでした。

【障害内容】
- 発生時刻: YYYY/MM/DD HH:MM
- 復旧時刻: YYYY/MM/DD HH:MM
- 影響範囲: XXX機能
- 原因: XXX

今後このような事態が発生しないよう、再発防止に努めてまいります。

MiniQ開発チーム
```

### 6. 事後分析（ポストモーテム）

#### テンプレート
```markdown
# インシデントレポート

## 概要
- 発生日時: YYYY/MM/DD HH:MM
- 検知日時: YYYY/MM/DD HH:MM
- 復旧日時: YYYY/MM/DD HH:MM
- 影響時間: XX時間XX分
- 重要度: P0/P1/P2/P3

## 影響範囲
- 影響ユーザー数: XXX名
- 影響機能: XXX
- プラットフォーム: iOS/Android/両方

## 原因
- 根本原因: XXX
- 直接原因: XXX

## 対応内容
1. XXX
2. XXX
3. XXX

## タイムライン
- HH:MM - 障害発生
- HH:MM - 検知
- HH:MM - 調査開始
- HH:MM - 原因特定
- HH:MM - 修正開始
- HH:MM - 修正完了
- HH:MM - 復旧確認

## 再発防止策
1. XXX
2. XXX
3. XXX

## 学んだこと
- XXX
- XXX

## アクションアイテム
- [ ] XXX（担当: XXX、期限: YYYY/MM/DD）
- [ ] XXX（担当: XXX、期限: YYYY/MM/DD）
```

---

## デプロイ手順

### 通常リリース

#### 1. リリース準備
```bash
# 最新のmainブランチを取得
git checkout main
git pull origin main

# リリースブランチを作成
git checkout -b release/v1.0.0

# バージョン番号を更新
# pubspec.yaml の version を更新

# CHANGELOG.md を更新
# 変更内容を記載

# コミット
git commit -m "chore: Bump version to 1.0.0"
git push origin release/v1.0.0
```

#### 2. テスト
```bash
# ユニットテスト
flutter test

# ウィジェットテスト
flutter test test/widget

# インテグレーションテスト
flutter test integration_test

# ゴールデンテスト
flutter test --update-goldens
flutter test test/golden
```

#### 3. ビルド

**Android**
```bash
# 本番ビルド
flutter build appbundle --release \
  --dart-define=ENV=production \
  --dart-define=FIREBASE_PROJECT_ID=minq-prod

# または Fastlane を使用
cd android
fastlane build_production
```

**iOS**
```bash
# 本番ビルド
flutter build ipa --release \
  --dart-define=ENV=production \
  --dart-define=FIREBASE_PROJECT_ID=minq-prod

# または Fastlane を使用
cd ios
fastlane build_production
```

#### 4. 内部テスト配信
```bash
# Android
cd android
fastlane deploy_internal

# iOS
cd ios
fastlane deploy_testflight
```

#### 5. 本番リリース
```bash
# Android（段階的公開）
cd android
fastlane deploy_production

# iOS
cd ios
fastlane deploy_appstore
```

### ホットフィックスリリース

```bash
# ホットフィックスブランチを作成
git checkout -b hotfix/v1.0.1 v1.0.0

# 修正を実装
# ... コード修正 ...

# テスト
flutter test

# バージョン番号を更新（パッチバージョンのみ）
# pubspec.yaml: version: 1.0.0+1 → 1.0.1+2

# ビルド＆デプロイ
cd android && fastlane deploy_hotfix
cd ios && fastlane deploy_hotfix

# mainにマージ
git checkout main
git merge hotfix/v1.0.1
git push origin main

# タグを作成
git tag v1.0.1
git push origin v1.0.1
```

---

## バックアップとリストア

### Firestore バックアップ

#### 自動バックアップ（推奨）
```bash
# Cloud Scheduler で毎日実行
gcloud firestore export gs://minq-backups/$(date +%Y%m%d)
```

#### 手動バックアップ
```bash
# エクスポート
gcloud firestore export gs://minq-backups/manual-backup-$(date +%Y%m%d)

# 確認
gsutil ls gs://minq-backups/
```

### Firestore リストア

```bash
# インポート
gcloud firestore import gs://minq-backups/20251002

# 特定のコレクションのみ
gcloud firestore import gs://minq-backups/20251002 \
  --collection-ids=users,quests
```

### ユーザーデータのバックアップ

ユーザーは アプリ内でデータをエクスポート可能：
- 設定 → データ管理 → エクスポート
- JSON または CSV 形式

---

## トラブルシューティング

### よくある問題

#### 1. アプリが起動しない

**症状**: アプリが起動時にクラッシュする

**確認事項**:
- Firebase の設定ファイルが正しいか
- 依存パッケージのバージョン競合がないか
- ネイティブビルドが成功しているか

**対処法**:
```bash
# キャッシュをクリア
flutter clean
flutter pub get

# ネイティブビルドをクリーン
cd android && ./gradlew clean
cd ios && rm -rf Pods && pod install
```

#### 2. 通知が届かない

**症状**: プッシュ通知が配信されない

**確認事項**:
- FCM トークンが正しく登録されているか
- 通知権限が許可されているか
- Firebase Console で通知が送信されているか

**対処法**:
```dart
// FCM トークンを確認
final token = await FirebaseMessaging.instance.getToken();
print('FCM Token: $token');

// 通知権限を確認
final settings = await FirebaseMessaging.instance.requestPermission();
print('Permission: ${settings.authorizationStatus}');
```

#### 3. データ同期が遅い

**症状**: Firestore のデータ同期に時間がかかる

**確認事項**:
- ネットワーク接続が安定しているか
- Firestore のインデックスが作成されているか
- クエリが最適化されているか

**対処法**:
```bash
# インデックスを確認
firebase firestore:indexes

# インデックスを作成
firebase deploy --only firestore:indexes
```

#### 4. クラッシュが多発

**症状**: 特定の画面でクラッシュが発生する

**確認事項**:
- Crashlytics でスタックトレースを確認
- 特定のデバイス/OSバージョンで発生しているか
- 再現手順を特定

**対処法**:
1. Crashlytics でエラーを確認
2. 該当コードを修正
3. ホットフィックスをリリース

---

## 緊急連絡先

### 開発チーム
- **リードエンジニア**: [name] - [email] - [phone]
- **バックエンドエンジニア**: [name] - [email] - [phone]
- **フロントエンドエンジニア**: [name] - [email] - [phone]

### インフラ
- **Firebase サポート**: https://firebase.google.com/support
- **Google Cloud サポート**: https://cloud.google.com/support

### オンコール
- **平日（9:00-18:00）**: [name] - [phone]
- **夜間・休日**: [name] - [phone]

### エスカレーション
1. オンコール担当者
2. リードエンジニア
3. CTO

---

## 付録

### 便利なコマンド

#### Flutter
```bash
# デバイス一覧
flutter devices

# ログ表示
flutter logs

# パフォーマンスプロファイル
flutter run --profile

# ビルドサイズ分析
flutter build apk --analyze-size
```

#### Firebase
```bash
# プロジェクト一覧
firebase projects:list

# プロジェクト切り替え
firebase use minq-prod

# デプロイ
firebase deploy

# ログ表示
firebase functions:log
```

#### Git
```bash
# タグ一覧
git tag -l

# 特定のタグをチェックアウト
git checkout v1.0.0

# タグを削除
git tag -d v1.0.0
git push origin :refs/tags/v1.0.0
```

---

## 更新履歴

- 2025-10-02: 初版作成
