# Social Sharing & Recognition System

## 概要

MinQアプリのソーシャルシェア機能と祝福演出システムの実装です。ユーザーの達成感を高め、継続モチベーションを向上させることを目的としています。

## 実装された機能

### 1. 進捗共有カード (ProgressShareCard)

**ファイル:** `progress_share_card.dart`

**機能:**
- 連続記録、ベスト記録、総クエスト数、今日の完了数を美しく表示
- 連続記録に応じた動的なグラデーション背景
- パルスアニメーション（7日以上の連続記録で自動発動）
- ワンタップでソーシャルメディアにシェア
- カスタマイズ可能な表示設定

**特徴:**
- 連続記録に応じた色彩変化（緑→青→紫→金）
- 心地よいマイクロインタラクション
- アクセシビリティ対応

### 2. 祝福演出システム (CelebrationSystem)

**ファイル:** `celebration_system.dart`

**機能:**
- 6種類の祝福演出タイプ（紙吹雪、花火、キラキラ、トロフィー、マスコット、ゴールド）
- ランダム祝福演出の自動選択
- 連続記録に応じた特別演出
- ハプティックフィードバックと音声フィードバック連携
- カスタマイズ可能な演出設定

**演出の種類:**
- **7日達成:** 紙吹雪エフェクト
- **30日達成:** 花火エフェクト  
- **50日達成:** トロフィーエフェクト
- **100日達成:** ゴールドエフェクト（5秒間の特別演出）

### 3. ペア間相互リマインド機能

**ファイル:** `pair_reminder_service.dart`, `pair_reminder.dart`

**機能:**
- 4種類のリマインダータイプ（励まし、お祝い、チェックイン、モチベーション）
- 定型メッセージテンプレート（各タイプ4種類ずつ）
- 自動リマインダー機能（条件に応じて自動送信）
- プッシュ通知連携
- リマインダー統計機能

**リマインダータイプ:**
- **励まし (encouragement):** 「今日のクエスト、一緒に頑張りましょう！💪」
- **お祝い (celebration):** 「お疲れさまでした！今日もよく頑張りましたね🎉」
- **チェックイン (checkIn):** 「調子はどうですか？一緒に継続していきましょう😊」
- **モチベーション (motivation):** 「あなたならできます！応援しています🌟」

### 4. ソーシャルシェア画像生成

**ファイル:** `social_sharing_service.dart`

**機能:**
- 実績達成画像の自動生成
- 進捗データの美しい可視化
- SNS投稿用の最適化されたサイズ（800x600px）
- カスタマイズ可能なデザインテンプレート
- 一時ファイルの自動クリーンアップ

## 使用方法

### 進捗共有カードの表示

```dart
ProgressShareCard(
  currentStreak: 15,
  bestStreak: 25,
  totalQuests: 100,
  completedToday: 3,
  onShare: () {
    // シェア完了時の処理
  },
)
```

### 祝福演出の表示

```dart
// ランダム祝福演出
CelebrationSystem.showCelebration(context);

// 特定の連続記録に応じた祝福演出
CelebrationSystem.showCelebration(
  context,
  config: CelebrationSystem.getStreakCelebration(30),
);
```

### ペアリマインダーの送信

```dart
final reminderService = PairReminderService(
  pairRepository: pairRepository,
  userRepository: userRepository,
  notificationService: notificationService,
);

await reminderService.sendReminderToPair(
  pairId: 'pair_123',
  senderId: 'user_456',
  type: ReminderType.encouragement,
  customMessage: 'カスタムメッセージ',
);
```

## デモ画面

**ファイル:** `social_sharing_demo.dart`

全機能を試すことができるデモ画面を提供しています。以下の機能をテストできます：

- 進捗データの調整（スライダー）
- 各種祝福演出のプレビュー
- リマインダーテンプレートの確認
- シェア機能のテスト

## テスト

**テストファイル:**
- `test/presentation/common/sharing/social_sharing_test.dart`
- `test/data/services/pair_reminder_service_test.dart`

**テスト内容:**
- ウィジェットの正常な描画
- 祝福演出システムの動作
- リマインダーテンプレートの品質
- エラーハンドリング

## 技術的特徴

### パフォーマンス最適化
- RepaintBoundary による描画最適化
- アニメーションコントローラーの適切な管理
- メモリリークの防止

### アクセシビリティ対応
- セマンティクス情報の提供
- 適切なコントラスト比
- スクリーンリーダー対応

### 国際化対応
- 日本語メッセージの最適化
- 文化的に適切な表現の使用
- 絵文字による視覚的コミュニケーション

## 今後の拡張予定

1. **A/Bテスト機能:** 異なる演出パターンの効果測定
2. **カスタムテンプレート:** ユーザー独自のメッセージテンプレート
3. **アニメーション拡張:** より豊富な演出パターン
4. **SNS連携強化:** 各プラットフォーム固有の最適化
5. **分析機能:** シェア率や継続率の詳細分析

## 依存関係

- `share_plus`: ソーシャルシェア機能
- `flutter/services`: ハプティックフィードバック
- `path_provider`: 一時ファイル管理
- `cloud_firestore`: リマインダーデータの保存
- `firebase_messaging`: プッシュ通知

## 注意事項

- 画像生成機能は端末の性能に依存します
- ハプティックフィードバックはiOS/Android固有の実装が必要です
- プッシュ通知の設定が適切に行われている必要があります