# プログレッシブオンボーディングシステム ガイド

## 概要

プログレッシブオンボーディングシステムは、ユーザーの進捗に応じて段階的にヒントを表示し、機能を解放するシステムです。F005問題の解決として実装され、SharedPreferencesによる状態管理とアニメーション付きUIを提供します。

## アーキテクチャ

### コンポーネント構成

```
lib/core/onboarding/
├── progressive_hint_service.dart          # ヒント表示サービス
├── progressive_onboarding.dart            # レベル・機能管理
└── progressive_onboarding_integration.dart # 統合サービス

lib/presentation/
├── controllers/progressive_onboarding_controller.dart # Riverpodコントローラー
└── widgets/progressive_onboarding_widget.dart         # UIウィジェット

test/core/onboarding/
└── progressive_onboarding_test.dart       # テストスイート
```

### 主要クラス

#### 1. ProgressiveHintService
- ヒントの表示・状態管理を担当
- SharedPreferencesで表示済み状態を記録
- ダイアログ、スナックバー、オーバーレイ形式でヒント表示

#### 2. ProgressiveOnboarding
- レベルシステムと機能解放を管理
- 4段階のレベル（ビギナー → エキスパート）
- 各レベルで解放される機能を定義

#### 3. ProgressiveOnboardingIntegration
- 各コンポーネントを統合
- イベント駆動でヒント表示をトリガー
- 機能ロック状態の管理

## 使用方法

### 1. 基本的な統合

既存の画面にプログレッシブオンボーディングを統合：

```dart
import 'package:minq/presentation/widgets/progressive_onboarding_widget.dart';

class MyScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ProgressiveOnboardingWidget(
      screenId: 'home', // 画面識別子
      child: Scaffold(
        // 既存のUI
      ),
    );
  }
}
```

### 2. イベント駆動のヒント表示

ユーザーアクション時にヒントを表示：

```dart
import 'package:minq/core/onboarding/progressive_onboarding_integration.dart';

// クエスト作成時
void onQuestCreated() {
  ProgressiveOnboardingIntegration.onQuestCreated(
    context,
    ref,
    isFirstQuest: true,
  );
}

// クエスト完了時
void onQuestCompleted() {
  ProgressiveOnboardingIntegration.onQuestCompleted(
    context,
    ref,
    totalCompleted: completedCount,
    currentStreak: currentStreak,
  );
}
```

### 3. 機能ロック状態の確認

```dart
// 機能がロックされているかチェック
final isPairLocked = ref.watch(featureLockStateProvider('pair_feature'));

// ロックメッセージを取得
final lockMessage = ref.watch(featureLockMessageProvider('pair_feature'));

if (isPairLocked) {
  // ロック状態のUI表示
  Text(lockMessage);
} else {
  // 機能利用可能なUI表示
  ElevatedButton(
    onPressed: () => openPairFeature(),
    child: Text('ペア機能を使う'),
  );
}
```

## ヒントの種類

### 定義済みヒント

| ヒントID | 表示タイミング | 内容 |
|---------|---------------|------|
| `hintFirstQuest` | 初回クエスト作成時 | クエスト作成の励まし |
| `hintFirstCompletion` | 初回完了時 | 継続の重要性説明 |
| `hintStreak` | 3日以上ストリーク達成時 | ストリーク継続の励まし |
| `hintWeeklyGoal` | 週次目標達成時 | 統計機能の案内 |
| `hintPairFeature` | ペア機能解放時 | ペア機能の説明 |
| `hintAdvancedStats` | 高度統計解放時 | 分析機能の説明 |
| `hintAchievements` | 実績機能解放時 | 実績システムの説明 |

### カスタムヒントの追加

新しいヒントを追加する場合：

1. `ProgressiveHintService`にヒントIDを定義
2. 表示メソッドを実装
3. 多言語対応のため`.arb`ファイルに文言追加

```dart
// 1. ヒントID定義
static const String hintNewFeature = 'new_feature';

// 2. 表示メソッド実装
static Future<void> showNewFeatureHint(BuildContext context) async {
  if (await hasShownHint(hintNewFeature)) return;
  if (!context.mounted) return;

  await _showHintDialog(
    context: context,
    hintId: hintNewFeature,
    title: '新機能が追加されました！',
    message: '新しい機能を試してみてください。',
    icon: Icons.new_releases,
    color: Theme.of(context).colorScheme.primary,
  );
}
```

## レベルシステム

### レベル定義

| レベル | 名称 | 解放条件 | 解放機能 |
|-------|------|---------|---------|
| 1 | ビギナー | 初期状態 | クエスト作成・完了・基本統計 |
| 2 | アクティブユーザー | クエスト5個完了・3日使用 | 通知・ストリーク追跡・週次統計 |
| 3 | ハビットマスター | クエスト15個完了・7日使用・3日ストリーク | ペア機能・高度統計・データエクスポート・タグ |
| 4 | エキスパート | クエスト30個完了・14日使用・7日ストリーク | 実績・イベント・テンプレート・タイマー・高度カスタマイズ |

### 機能ID一覧

```dart
// レベル1
FeatureIds.questCreate
FeatureIds.questComplete
FeatureIds.basicStats

// レベル2
FeatureIds.notifications
FeatureIds.streakTracking
FeatureIds.weeklyStats

// レベル3
FeatureIds.pairFeature
FeatureIds.advancedStats
FeatureIds.exportData
FeatureIds.tags

// レベル4
FeatureIds.achievements
FeatureIds.events
FeatureIds.templates
FeatureIds.timer
FeatureIds.advancedCustomization
```

## UI コンポーネント

### 1. ProgressiveHintDialog
- アニメーション付きダイアログ
- アイコン・タイトル・メッセージ・アクションボタン
- テーマ対応

### 2. OnboardingProgressIndicator
- 現在レベルと進捗を表示
- タップで詳細表示
- 画面右上に配置

### 3. LevelUpDialog
- レベルアップ時の祝福アニメーション
- 解放された機能の一覧表示
- エラスティックアニメーション

## 状態管理

### SharedPreferences キー

```
progressive_hint_first_quest          # 初回クエストヒント表示済み
progressive_hint_first_completion     # 初回完了ヒント表示済み
progressive_hint_streak_achievement   # ストリークヒント表示済み
progressive_hint_weekly_goal          # 週次目標ヒント表示済み
progressive_hint_pair_feature_unlock  # ペア機能解放ヒント表示済み
progressive_hint_advanced_stats_unlock # 高度統計解放ヒント表示済み
progressive_hint_achievements_unlock  # 実績機能解放ヒント表示済み
```

### Riverpod プロバイダー

```dart
// メインコントローラー
progressiveOnboardingControllerProvider

// レベルアップイベント
levelUpEventProvider

// 機能アンロック状態
featureUnlockProvider.family<String>

// 進捗情報
onboardingProgressProvider

// 機能ロック状態
featureLockStateProvider.family<String>

// 機能ロックメッセージ
featureLockMessageProvider.family<String>
```

## 多言語対応

### 日本語 (app_ja.arb)
```json
{
  "hintFirstQuest": "最初のクエストを作成しましょう！",
  "hintFirstQuestMessage": "クエストを作成して習慣化の第一歩を踏み出しましょう。\n小さな目標から始めることが成功の秘訣です。",
  "hintFirstCompletion": "初めての完了おめでとうございます！",
  "hintFirstCompletionMessage": "継続することでストリークが増えます。\n毎日少しずつでも続けることが大切です。"
}
```

### 英語 (app_en.arb)
```json
{
  "hintFirstQuest": "Let's create your first quest!",
  "hintFirstQuestMessage": "Create a quest and take the first step towards building habits.\nStarting with small goals is the key to success.",
  "hintFirstCompletion": "Congratulations on your first completion!",
  "hintFirstCompletionMessage": "Continuing will increase your streak.\nIt's important to keep going even a little bit every day."
}
```

## テスト

### テストカバレッジ

- ヒント表示ロジック
- 状態管理（SharedPreferences）
- レベルアップ条件
- 機能解放チェック
- UI コンポーネント

### テスト実行

```bash
flutter test test/core/onboarding/progressive_onboarding_test.dart
```

## デバッグ機能

### ヒントリセット

```dart
// 全てのヒントをリセット
await ProgressiveHintService.resetAllHints();

// 特定のヒントをリセット
await ProgressiveHintService.resetHint('first_quest');
```

### 開発者向け機能

- デバッグモードでヒントリセットボタン表示
- 進捗状況の手動調整
- レベルアップの強制実行

## パフォーマンス考慮事項

### 最適化ポイント

1. **遅延読み込み**: ヒント表示時のみダイアログを構築
2. **キャッシュ**: SharedPreferences の読み取り結果をキャッシュ
3. **非同期処理**: UI ブロックを避けるため非同期でヒント状態チェック
4. **メモリ管理**: アニメーションコントローラーの適切な破棄

### 注意点

- `BuildContext.mounted` チェックで非同期処理の安全性確保
- アニメーション中の画面遷移に対する適切な処理
- SharedPreferences の書き込み頻度制限

## 今後の拡張予定

### 予定機能

1. **A/Bテスト対応**: ヒント表示パターンの実験
2. **分析機能**: ヒント効果の測定
3. **カスタマイズ**: ユーザーによるヒント設定
4. **アニメーション拡張**: より豊富な表現効果

### 技術的改善

1. **パフォーマンス最適化**: より効率的な状態管理
2. **アクセシビリティ**: スクリーンリーダー対応強化
3. **テスト拡充**: E2Eテストの追加
4. **ドキュメント**: より詳細な実装ガイド

## トラブルシューティング

### よくある問題

#### Q: ヒントが表示されない
A: 以下を確認してください：
- `BuildContext.mounted` が true か
- SharedPreferences で既に表示済みになっていないか
- 適切なタイミングで呼び出されているか

#### Q: レベルアップが発生しない
A: 以下を確認してください：
- ユーザー統計が正しく更新されているか
- レベルアップ条件を満たしているか
- `checkLevelUp()` が呼び出されているか

#### Q: アニメーションが正常に動作しない
A: 以下を確認してください：
- AnimationController が適切に初期化されているか
- dispose() でリソースが解放されているか
- 画面遷移中でないか

## 関連ドキュメント

- [要件定義書](../.kiro/specs/ui-ux-comprehensive-overhaul/requirements.md)
- [設計書](../.kiro/specs/ui-ux-comprehensive-overhaul/design.md)
- [タスクリスト](../.kiro/specs/ui-ux-comprehensive-overhaul/tasks.md)
- [UI/UX改善フォルダ](../UI_UX改善/)