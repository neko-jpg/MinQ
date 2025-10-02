# Chaos Testing プログラム

## 目的
- ネットワーク断、メモリ圧迫、時刻改変などの異常系でアプリが安全にフェイルすることを検証
- インシデント時の検知・復旧時間を短縮

## テスト対象
- Flutterクライアント（Android/iOS）
- Firebase Functions / Cloud Run API
- Firestore、Workmanagerジョブ

## ツールチェーン
- **Android**: `adb shell cmd connectivity airplane-mode`, `adb shell am broadcast -a android.intent.action.AIRPLANE_MODE`
- **iOS**: Xcode Network Link Conditioner
- **バックエンド**: `chaos-mesh`（GKE）によるPod再起動・レイテンシ注入
- **時刻改変**: Android Emulatorの`adb shell date`, iOS Simulatorの`xcrun simctl status_bar`

## 実行シナリオ
| シナリオ | 手順 | 期待結果 |
| --- | --- | --- |
| ネットワーク断 | 1. Workmanagerジョブ実行中に機内モード<br>2. 1分後に復旧 | ジョブが指数バックオフで再試行し、ユーザーにRetry SnackBarを表示 |
| 高遅延 | 1. Chaos MeshでFirestoreへ500ms遅延注入<br>2. リアルタイムリスト更新を観測 | UIがSkeletonを表示し、Timeoutでエラーカードに遷移 |
| メモリ圧迫 | 1. Android Studio Profilerでヒープを80%占有<br>2. 進捗画面のスクロール操作 | `OutOfMemory`を回避し、必要なら画像キャッシュをクリア |
| 時刻改変 | 1. 端末時刻を+2日<br>2. 進捗ログ記録→元に戻す | タイムゾーン処理が正しく補正され、重複通知が発生しない |

## オートメーション
- GitHub Actionsで`workflow_dispatch`トリガー。Firebase Test LabへInstrumentationテストをデプロイ。
- `integration_test/chaos_scenarios_test.dart` で`NetworkImage`タイムアウトやWorkmanager再試行をシミュレーション。
- Chaos MeshはTerraform経由で実験テンプレートを登録し、`kubectl apply`をCIから実行。

## 計測とアラート
- Firebase Performanceの`custom trace`に`chaos_test`タグを追加。
- Sentryで`CHAOS_TEST`タグを付けたエラーを別プロジェクトに集約。
- MTTR（Mean Time To Recovery）を週次レポートに記載。

## ロールアウト
1. ステージング環境で月1回実施
2. 本番影響のない時間帯で四半期に1回実施
3. レポートをNotionテンプレートに保存し、再発防止策をリンク
