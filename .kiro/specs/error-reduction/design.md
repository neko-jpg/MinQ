# Design Document

## Overview

このドキュメントは、Flutter analyzeとtestで検出される736個のissuesを0にするための設計を定義します。エラーは以下のように分類されます：

- **Errors**: 291個（コンパイルエラー、型エラー、未定義参照など）
- **Warnings**: 25個（未使用変数、デッドコードなど）
- **Info**: 420個（非推奨API、コーディングスタイルなど）

段階的なアプローチを採用し、影響範囲が大きく自動化可能な修正から優先的に実施します。

## Architecture

### 修正フェーズの構成

```
Phase 1: 高頻度エラーの一括修正
├── 1.1 非推奨API (withOpacity) の移行
├── 1.2 未定義クラス・プロパティの修正
└── 1.3 依存関係の問題解決

Phase 2: 型安全性の確保
├── 2.1 引数型の不一致修正
├── 2.2 Nullable値の安全な使用
└── 2.3 未定義メソッドの修正

Phase 3: BuildContext使用の安全性確保
├── 3.1 async gap警告の修正
└── 3.2 mountedチェックの追加

Phase 4: 未使用コードのクリーンアップ
├── 4.1 未使用変数の削除
├── 4.2 未使用メソッドの削除
└── 4.3 デッドコードの削除

Phase 5: テストの修正
├── 5.1 コンパイルエラーの修正
├── 5.2 モックの問題解決
└── 5.3 テストの実行確認

Phase 6: 最終検証
├── 6.1 ビルドテスト
├── 6.2 テスト実行
└── 6.3 ドキュメント更新
```

## Components and Interfaces

### 1. エラー分析コンポーネント

**責務**: エラーを分類し、優先順位を決定する

```dart
class ErrorAnalyzer {
  /// エラーログを解析して分類
  Map<ErrorCategory, List<ErrorInfo>> analyzeErrors(String analyzeOutput);
  
  /// 優先順位を計算
  List<ErrorInfo> prioritizeErrors(List<ErrorInfo> errors);
}

enum ErrorCategory {
  deprecatedApi,      // 非推奨API
  undefinedReference, // 未定義参照
  typeError,          // 型エラー
  unusedCode,         // 未使用コード
  asyncContext,       // BuildContext async gap
  dependency,         // 依存関係
  test,              // テスト関連
}
```

### 2. 自動修正コンポーネント

**責務**: パターンマッチングによる自動修正

```dart
class AutoFixer {
  /// withOpacityをwithValuesに変換
  Future<void> fixWithOpacity(List<String> filePaths);
  
  /// 未使用インポートを削除
  Future<void> removeUnusedImports();
  
  /// dart fix --applyを実行
  Future<void> applyDartFix();
}
```

### 3. 手動修正ガイドコンポーネント

**責務**: 手動修正が必要なエラーのガイドを提供

```dart
class ManualFixGuide {
  /// エラーに対する修正方法を提供
  String getFixInstructions(ErrorInfo error);
  
  /// 修正例を提供
  CodeExample getFixExample(ErrorInfo error);
}
```

## Data Models

### ErrorInfo

```dart
class ErrorInfo {
  final String filePath;
  final int lineNumber;
  final ErrorCategory category;
  final String errorCode;
  final String message;
  final ErrorSeverity severity;
  final bool autoFixable;
  
  ErrorInfo({
    required this.filePath,
    required this.lineNumber,
    required this.category,
    required this.errorCode,
    required this.message,
    required this.severity,
    required this.autoFixable,
  });
}

enum ErrorSeverity {
  error,
  warning,
  info,
}
```

### FixResult

```dart
class FixResult {
  final int totalErrors;
  final int fixedErrors;
  final int remainingErrors;
  final List<String> modifiedFiles;
  final List<ErrorInfo> unfixedErrors;
  
  FixResult({
    required this.totalErrors,
    required this.fixedErrors,
    required this.remainingErrors,
    required this.modifiedFiles,
    required this.unfixedErrors,
  });
}
```

## Error Handling

### エラー修正時の安全性確保

1. **バックアップ戦略**
   - 各フェーズ開始前にGitコミット
   - 修正失敗時のロールバック手順を用意

2. **検証プロセス**
   - 各修正後に`flutter analyze`を実行
   - ビルドが成功することを確認
   - 重要な機能のスモークテストを実行

3. **エラーハンドリング**
   - 自動修正が失敗した場合は手動修正にフォールバック
   - 修正不可能なエラーはドキュメント化

## Testing Strategy

### 修正の検証方法

1. **ユニットテスト**
   - 修正後もすべてのユニットテストがパスすること
   - 新しいテストは追加しない（既存テストの修正のみ）

2. **ビルドテスト**
   ```bash
   flutter build apk --debug
   flutter build web --debug
   ```

3. **Analyzeテスト**
   ```bash
   flutter analyze --no-fatal-infos
   ```

4. **統合テスト**
   - 主要な画面が正常に表示されること
   - 基本的なユーザーフローが動作すること

## Implementation Details

### Phase 1: 高頻度エラーの一括修正

#### 1.1 withOpacityの移行（推定: 150個のinfo）

**問題**: `withOpacity`が非推奨になり、`withValues()`への移行が推奨されている

**修正方法**:
```dart
// Before
color.withOpacity(0.5)

// After
color.withValues(alpha: 0.5)
```

**実装アプローチ**:
- 正規表現で一括置換
- パターン: `\.withOpacity\(([0-9.]+)\)` → `.withValues(alpha: $1)`
- 対象ファイル: `lib/presentation/**/*.dart`

#### 1.2 未定義クラス・プロパティの修正（推定: 100個のerror）

**主なエラー**:
1. `MinqTheme`のプロパティ未定義（typography, primary, success, error, lg, md, sm, xs, xl, xxs, full）
2. `Spacing`クラス未定義
3. `FocusThemeData`クラス未定義
4. `Icons.database_outlined`未定義

**修正方法**:

a) **MinqThemeの拡張**:
```dart
// lib/presentation/theme/minq_theme.dart
extension MinqThemeExtension on MinqTheme {
  // Typography
  TypographySystem get typography => TypographySystem();
  
  // Colors
  Color get primary => colors.primary;
  Color get success => colors.success;
  Color get error => colors.error;
  
  // Spacing
  double Function(double) get spacing => (multiplier) => 8.0 * multiplier;
  double get xs => spacing(1);    // 8
  double get sm => spacing(2);    // 16
  double get md => spacing(3);    // 24
  double get lg => spacing(4);    // 32
  double get xl => spacing(5);    // 40
  double get xxs => spacing(0.5); // 4
  double get full => double.infinity;
}
```

b) **Spacingクラスの定義**:
```dart
// lib/presentation/theme/spacing_system.dart
class Spacing {
  static const double xxs = 4.0;
  static const double xs = 8.0;
  static const double sm = 16.0;
  static const double md = 24.0;
  static const double lg = 32.0;
  static const double xl = 40.0;
  static const double xxl = 48.0;
}
```

c) **FocusThemeDataの修正**:
```dart
// lib/presentation/theme/focus_system.dart
// FocusThemeData → ThemeData に変更
// または適切なクラスを定義
```

#### 1.3 依存関係の問題解決（推定: 10個のerror）

**問題**:
- `miinq_integrations`パッケージが存在しない
- `riverpod`が依存関係に宣言されていない

**修正方法**:
1. 存在しないパッケージを使用しているファイルをコメントアウトまたは削除
2. `pubspec.yaml`に必要な依存関係を追加

### Phase 2: 型安全性の確保

#### 2.1 引数型の不一致修正（推定: 30個のerror）

**主なエラー**:
1. `Object` → `String`の変換
2. `num` → `double`の変換
3. `ProofType` → `String`の変換

**修正方法**:
```dart
// Object → String
final value = obj as String;
// または
final value = obj.toString();

// num → double
final doubleValue = numValue.toDouble();

// ProofType → String
final stringValue = proofType.name;
```

#### 2.2 Nullable値の安全な使用（推定: 10個のerror）

**修正方法**:
```dart
// Before
final length = nullableString.length;

// After
final length = nullableString?.length ?? 0;
```

#### 2.3 未定義メソッドの修正（推定: 20個のerror）

**主なエラー**:
- `AnalyticsService.logEvent`が未定義
- `BuildContext.tokens`が未定義

**修正方法**:
1. メソッドが存在するか確認
2. 存在しない場合は、適切なメソッドに置き換えまたはコメントアウト

### Phase 3: BuildContext使用の安全性確保

#### 3.1 async gap警告の修正（推定: 50個のinfo）

**修正方法**:
```dart
// Before
Future<void> someMethod(BuildContext context) async {
  await someAsyncOperation();
  Navigator.of(context).pop();
}

// After
Future<void> someMethod(BuildContext context) async {
  await someAsyncOperation();
  if (!context.mounted) return;
  Navigator.of(context).pop();
}
```

### Phase 4: 未使用コードのクリーンアップ

#### 4.1 未使用変数の削除（推定: 20個のwarning/info）

**自動修正**:
```bash
dart fix --apply
```

#### 4.2 未使用メソッドの削除（推定: 15個のwarning）

**手動確認が必要**:
- 本当に未使用か確認
- 将来使用予定の場合は`@visibleForTesting`などのアノテーションを追加

### Phase 5: テストの修正

#### 5.1 コンパイルエラーの修正

**問題**:
- `test`パッケージのインポートエラー
- モックの型不一致

**修正方法**:
1. `pubspec.yaml`の`dev_dependencies`に`test`を追加
2. モックの生成コマンドを再実行

#### 5.2 モックの問題解決

**問題**:
```dart
MissingStubError: 'user'
No stub was found which matches the arguments of this method call
```

**修正方法**:
```dart
// テストのsetUpで適切なスタブを追加
setUp(() {
  final mockUser = MockUser();
  when(mockUserCredential.user).thenReturn(mockUser);
});
```

### Phase 6: 最終検証

#### 6.1 ビルドテスト
```bash
flutter clean
flutter pub get
flutter build apk --debug
```

#### 6.2 テスト実行
```bash
flutter test
```

#### 6.3 ドキュメント更新
- 修正内容のサマリー作成
- 今後の注意点をドキュメント化

## Performance Considerations

1. **一括修正の効率化**
   - 正規表現による一括置換を活用
   - ファイル単位での並列処理

2. **検証の最適化**
   - 修正後の差分ビルドを活用
   - 重要なテストのみを優先実行

## Security Considerations

1. **コード変更の安全性**
   - 各フェーズでGitコミット
   - レビュー可能な単位で変更を分割

2. **依存関係の安全性**
   - 新しい依存関係を追加する際はセキュリティチェック
   - 不要な依存関係は削除

## Rollback Strategy

各フェーズで問題が発生した場合のロールバック手順：

1. **Gitによるロールバック**
   ```bash
   git reset --hard HEAD~1
   ```

2. **部分的なロールバック**
   ```bash
   git checkout HEAD -- <file_path>
   ```

3. **フェーズのスキップ**
   - 問題のあるフェーズをスキップして次に進む
   - 後で個別に対応

## Success Metrics

- ✅ `flutter analyze`のエラー: 291 → 0
- ✅ `flutter analyze`の警告: 25 → 0
- ✅ `flutter analyze`のinfo: 420 → 50以下（修正不可能なものを除く）
- ✅ `flutter test`のコンパイルエラー: すべて解消
- ✅ `flutter test`の失敗: すべて解消
- ✅ ビルド成功率: 100%

## Timeline Estimate

- Phase 1: 4-6時間
- Phase 2: 2-3時間
- Phase 3: 1-2時間
- Phase 4: 1時間
- Phase 5: 2-3時間
- Phase 6: 1時間

**合計**: 11-16時間
