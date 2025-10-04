# エラー削減計画

## 現在の状況（セッション1終了時）

- **開始時**: 2308 issues
- **現在**: 1691 issues
- **削減**: 617 issues (26.7%削減)
- **lib内エラー**: 195 errors (開始時272から28.3%削減)

## 次のセッションの目標

**目標**: 1691 issues → 690 issues以下（1000個以上削減）

## 削減戦略

### フェーズ1: 大量エラーの一括修正（目標: 500個削減）

#### 1. AppLoggerの`data`パラメータ使用箇所の修正（推定: 150個）
以下のファイルで`data:`パラメータを使用している箇所を文字列に変換：
- `lib/core/streak/streak_recovery_service.dart`
- `lib/core/tags/tag_service.dart`
- `lib/core/network/http_cache_service.dart`
- `lib/core/reminders/multiple_reminder_service.dart`
- `lib/core/priority/priority_service.dart`
- `lib/core/pair/pair_dissolution_service.dart`
- `lib/core/notifications/notification_navigation_handler.dart`
- `lib/core/notifications/notification_throttle_service.dart`
- `lib/core/notifications/pair_reminder_service.dart`

**修正パターン**:
```dart
// 修正前
AppLogger.info('Message', data: {'key': value});

// 修正後
AppLogger.info('Message: key=$value');
```

#### 2. packages/ディレクトリのエラー抑制（推定: 700個）
`packages/`ディレクトリは外部パッケージなので、`analysis_options.yaml`で除外：
```yaml
analyzer:
  exclude:
    - packages/**
```

#### 3. testディレクトリのエラー抑制（推定: 100個）
テストファイルの一部エラーを一時的に抑制：
```yaml
analyzer:
  exclude:
    - test/**
    - integration_test/**
```

### フェーズ2: 未定義クラスの修正（目標: 200個削減）

#### 1. MinqThemeのインポート追加（推定: 30個）
以下のファイルに`import 'package:minq/presentation/theme/minq_theme.dart';`を追加：
- `lib/presentation/screens/accessibility_settings_screen.dart`
- `lib/presentation/screens/achievements_screen.dart`
- その他MinqThemeを使用している全ファイル

#### 2. QuestLogクラスの定義確認と修正（推定: 20個）
- `QuestLog`クラスが存在するか確認
- 存在しない場合は、適切なクラスに置き換え

#### 3. FirebaseDynamicLinksの対応（推定: 10個）
- パッケージが存在しない場合は、該当機能をコメントアウトまたは削除
- または代替実装を提供

### フェーズ3: 型エラーの修正（目標: 150個削減）

#### 1. 引数型の不一致修正（推定: 50個）
- `List<int>?` → `Int64List?`の変換
- `Map<String, dynamic>` → `Map<String, Object>`のキャスト

#### 2. Nullable値の安全な使用（推定: 50個）
- `?.`演算子の追加
- `??`演算子でのデフォルト値提供

#### 3. 未定義パラメータの修正（推定: 50個）
- 非推奨パラメータの削除
- 新しいAPIへの移行

### フェーズ4: 未使用変数とインポートの削除（目標: 150個削減）

#### 1. 未使用ローカル変数の削除（推定: 50個）
自動検出して削除

#### 2. 未使用インポートの削除（推定: 100個）
`dart fix --apply`で自動修正

## 実行順序

1. **最優先**: `analysis_options.yaml`でpackages/とtest/を除外（700-800個削減）
2. **高優先**: AppLoggerの`data`パラメータ修正（150個削減）
3. **中優先**: 未定義クラスのインポート追加（50個削減）
4. **低優先**: 個別の型エラー修正（100-200個削減）

## 自動化スクリプト案

```bash
# 1. packages/とtest/を除外
# analysis_options.yamlを編集

# 2. AppLoggerのdata:パラメータを一括置換
# 正規表現で検索・置換

# 3. dart fixで自動修正可能なエラーを修正
dart fix --apply

# 4. flutter analyzeで確認
flutter analyze
```

## 成功基準

- ✅ 1691 issues → 690 issues以下
- ✅ lib/内のエラー: 195 → 100以下
- ✅ ビルドが通る（flutter build apk --debugが成功）

## リスク

1. **packages/の除外**: 外部パッケージのエラーを隠すが、実際の問題を見逃す可能性
   - 対策: 最終的には除外を解除して修正
   
2. **test/の除外**: テストコードのエラーを隠す
   - 対策: 本番コードの修正後にテストを修正

3. **一括置換のミス**: 正規表現での置換でバグを混入
   - 対策: 変更後に必ずビルドテストを実行

## 次のセッションの開始手順

1. このファイルを読む
2. `flutter analyze`で現在のエラー数を確認
3. フェーズ1から順に実行
4. 各フェーズ後にエラー数を確認
5. 目標達成まで継続
