# Fuzz Testing 戦略

## 目的
- フォーム入力やAPIエンドポイントに対する予期せぬ入力でのクラッシュ・バリデーション漏れを検出
- リリース前に自動で異常系を網羅

## 対象範囲
- Flutterフォーム（プロフィール設定、クエスト作成、ペアチャット）
- Cloud Functions RESTエンドポイント
- Firestoreセキュリティルール

## ツール
- `dart_fuzz` + property-based testing (`package:checks`)
- REST: `schemathesis`（OpenAPI 3.0仕様から生成）
- Firestore Rules: `firebase emulators:exec` + `fuzz-rules`スクリプト

## 実装ステップ
1. `integration_test/fuzz_inputs_test.dart` を作成
   - `Quest`フォームのテキストフィールドに対し、長文・絵文字・SQL風文字列などを生成
   - `expectLater`でUIがバリデーションメッセージを表示することを確認
2. Cloud Functions: OpenAPI定義を`tool/openapi.yaml`に用意し、`schemathesis run`でfuzz実行
3. Firestore: `firebase emulators:start`上で権限境界を検証。拒否されるべき操作がallowされていないか確認

## 自動化
- GitHub Actions (`.github/workflows/fuzz-testing.yml`)
  - Flutter integration testをAndroid Emulator headlessで実行
  - `schemathesis`をDockerで実行し、Slack通知
  - フェイル時には問題のペイロードをアーティファクト化

## メトリクス
- 発見されたバグ件数/スプリント
- 1回あたりのテスト実行時間
- バリデーションのカバレッジ（入力フィールド数に対する割合）

## ロールアウト
1. スプリントごとに1回自動実行
2. 重大バグ検出時はHotfixブランチを作成し、対策完了までブロック
3. 成果を`QA回帰レポート`に記録し、ナレッジ共有
