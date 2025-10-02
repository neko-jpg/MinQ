# CDNヘッダ最適化戦略（Cache-Control / ETag / Brotli）

## 目的
- Webクライアント、PWA、APIレスポンスのレスポンス改善
- オリジンサーバー負荷の軽減
- コンテンツ鮮度とキャッシュヒット率の両立

## 適用範囲
- Firebase Hosting + Cloud CDN
- Cloud Run API
- Cloud Storage (ユーザー生成アセット)

## Cache-Control ポリシー

| コンテンツ | 値 | 備考 |
| --- | --- | --- |
| `app.webmanifest`, `index.html` | `public, max-age=0, must-revalidate` | デプロイ毎に最新化 |
| `/assets/**` (ハッシュ付き) | `public, max-age=31536000, immutable` | Flutter buildのfingerprint利用 |
| APIレスポンス (GET) | `private, max-age=60, stale-while-revalidate=30` | 認証済みユーザー向け、データ鮮度重視 |
| Cloud Storage署名付きURL | `public, max-age=3600` | 期限付きキャッシュ |
| Feature flag JSON | `public, max-age=30, stale-if-error=86400` | Remote Configフェイルオーバー |

## ETag 運用
- Firebase Hosting: デフォルトの`ETag`を保持、`If-None-Match`ヘッダによる差分配信を許容。
- Cloud Run: `etag`ヘッダを手動生成（`sha256(body)`）し、304レスポンスを返却。
- APIのリストレスポンスは`updatedAt`のハッシュ値でETagを生成し、差分比較を実施。

## Brotli圧縮
- Firebase Hosting: `firebase.json`で`"compression": "brotli"`を有効化。
- Cloud Run: `gcloud run deploy`時に`--compression`を指定。
- Flutter Webビルド成果物は`brotli`圧縮済みファイルを`build/web`配下に生成し、`firebase.json`で`headers`設定を追加。

## 実装チェックリスト
- [ ] `firebase.json` に `headers` 設定を追加してCache-Control/ETag/Brotliを適用
- [ ] Cloud Runの`Dockerfile`で`ENV COMPRESSION_ENABLED=true`
- [ ] Integration Testで`Cache-Control`ヘッダ値を確認
- [ ] Lighthouse CIでキャッシュ効率の測定

## モニタリング
- Cloud CDNログをBigQueryにエクスポートし、キャッシュヒット率を日次可視化
- Cloud Monitoringで`cdn.googleapis.com/response_latencies`メトリクスをダッシュボード化
- ヒット率80%未満でアラート

## ロールアウト
1. ステージング環境でヘッダ適用を検証
2. パフォーマンス計測（TTFB、Largest Contentful Paint）
3. 本番反映後、24時間ヒット率を監視
