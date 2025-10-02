# アーキテクチャドキュメント

## 概要

MiniQuestはFlutter + Riverpod + Firebaseで構築されたモバイルアプリケーションです。

## アーキテクチャパターン

### レイヤー構造

```
lib/
├── core/              # コアロジック・ユーティリティ
├── data/              # データ層（Repository, Service）
├── domain/            # ドメイン層（Entity, UseCase）
└── presentation/      # プレゼンテーション層（UI, Controller）
```

### 依存関係

```
Presentation → Domain → Data → Core
```

- 上位レイヤーは下位レイヤーに依存可能
- 下位レイヤーは上位レイヤーに依存不可

## 状態管理

### Riverpod

- StateNotifierProvider: 複雑な状態管理
- StreamProvider: リアルタイムデータ
- FutureProvider: 非同期データ取得
- Provider: 依存性注入

### AutoDispose vs KeepAlive

詳細は `lib/core/providers/provider_lifecycle_guide.md` を参照

## データフロー

```
UI → Controller → UseCase → Repository → Service → Firebase
                                                  ↓
                                              Local Cache
```

### 読み取り
1. UIがControllerを監視
2. Controllerがデータを要求
3. Repositoryがキャッシュをチェック
4. キャッシュミスの場合、Firebaseから取得
5. データをキャッシュして返却

### 書き込み
1. UIがControllerにアクションを送信
2. Controllerがバリデーション
3. Repositoryがデータを保存
4. Firebaseに同期
5. ローカルキャッシュを更新

## Firebase統合

### Firestore
- オフライン永続化有効
- キャッシュサイズ: 無制限
- リトライ/バックオフ実装

### Authentication
- Google Sign-In
- Apple Sign-In
- Email/Password

### Cloud Functions
- データ検証
- 通知送信
- バッチ処理

### Cloud Storage
- 画像アップロード
- 自動リサイズ

## エラーハンドリング

### 階層別エラー処理

```
UI Layer:
  - SnackBar/Dialog表示
  - EmptyState表示

Controller Layer:
  - AsyncValue.guard()でラップ
  - エラーログ記録

Repository Layer:
  - リトライ処理
  - キャッシュフォールバック

Service Layer:
  - 例外スロー
  - Crashlytics記録
```

## テスト戦略

### ユニットテスト
- Repository
- UseCase
- Utility関数

### ウィジェットテスト
- 主要画面
- カスタムウィジェット

### 統合テスト
- 主要フロー
- エンドツーエンド

## パフォーマンス最適化

### 起動時間
- 遅延初期化
- 優先度付き初期化
- 画像プリフェッチ

### メモリ
- AutoDispose活用
- 画像キャッシュ管理
- リスト仮想化

### ネットワーク
- オフライン対応
- キャッシュ戦略
- バッチ処理

## セキュリティ

### 認証
- Firebase Authentication
- セッション管理
- トークンリフレッシュ

### データ保護
- Firestoreルール
- 暗号化通信
- 入力サニタイズ

### モデレーション
- NGワードフィルター
- スパム検出
- レート制限

## CI/CD

### GitHub Actions
- Lint/Test/Build
- 自動デプロイ
- CHANGELOG生成

### Fastlane
- ビルド自動化
- 署名管理
- ストア配布

## モニタリング

### Crashlytics
- クラッシュレポート
- 非致命的エラー
- カスタムログ

### Performance Monitoring
- 起動時間
- 画面描画
- ネットワーク

### Analytics
- ユーザー行動
- イベント追跡
- コンバージョン

## スケーラビリティ

### 水平スケーリング
- Firestore自動スケール
- Cloud Functions自動スケール

### データ分割
- ユーザーIDベースのシャーディング
- 地域別データセンター

### キャッシュ戦略
- クライアントサイドキャッシュ
- CDN活用

## 今後の拡張

### 予定機能
- Widget対応
- Wear OS対応
- Web版

### 技術的改善
- GraphQL導入検討
- マイクロサービス化
- リアルタイム同期強化
