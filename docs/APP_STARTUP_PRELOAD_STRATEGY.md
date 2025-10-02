# アプリ起動時プリロード戦略 (Warm-up isolate / DWU削減)

## 背景
- Cold startが2.8秒、DWU (Displayed When Usable) 指標が4.1秒。
- Firebase Remote ConfigやローカルDB初期化がクリティカルパスに存在。
- スプラッシュ画面での待機時間を短縮し、初回操作可能までの時間を縮める。

## Warm-up isolate
1. `FlutterEngineGroup` を活用し、バックグラウンドで初期化済みエンジンをプール。
2. `main.dart` の `main()` で `WarmUpService.initialize()` をawaitし、Isolateを事前起動。
3. `lib/core/initialization/warm_up_service.dart` を新規作成して以下を実行:
   - `Firebase.initializeApp()`
   - `SharedPreferences.getInstance()`
   - `Isar.open()` （read-only instance）
4. Androidは`Application`クラスで`FlutterMain.startInitialization()`を呼び、スプラッシュ直後にエンジンをattach。

## リソースプリフェッチ
- Remote Config: `await remoteConfig.fetchAndActivate()`をWarm-up isolate内で先行実行。
- Feature flag: `core/feature_flags/feature_flag_bootstrapper.dart`で`Future.wait`に組み込み。
- アセット画像: Heroアニメーションに使用するSVGを`precachePicture`でロード。

## 減量（DWU削減）
- 初期表示ウィジェットの非同期依存を分離し、`FutureBuilder`で遅延読込。
- `record_screen`など重い画面は `deferred import` を利用。
- `rive` アニメーションは `Placeholder` → 遅延で差し替え。

## 計測
- Performance Monitoringで`app_start`トレースに`warmup_done`カスタムメトリクスを追加。
- Firebase Analyticsに`app_ready`イベントを送信し、Warm-up導入前後を比較。

## ロールアウト
1. StagingでA/Bテスト (Warm-up isolate on/off)
2. DWUが15%改善した場合に本番展開
3. バックグラウンドIsolate失敗時のフォールバックを検証

## TODO
- [ ] `WarmUpService` 実装
- [ ] Android Applicationで`initWarmUpEngine()`呼び出し
- [ ] iOS `AppDelegate`でプリウォーミング処理追加
- [ ] Performanceモニタリングのカスタムメトリクス導入
