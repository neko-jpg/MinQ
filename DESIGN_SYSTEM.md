# MiniQuest Design System

完全なデザインシステムドキュメント - すべてのデザイントークン、コンポーネント、ガイドラインを定義

## 目次

1. [タイポグラフィ](#タイポグラフィ)
2. [スペーシング](#スペーシング)
3. [カラー](#カラー)
4. [Elevation（影）](#elevation影)
5. [Border（枠線・角丸）](#border枠線角丸)
6. [アニメーション](#アニメーション)
7. [ハプティクス](#ハプティクス)
8. [アクセシビリティ](#アクセシビリティ)

---

## タイポグラフィ

### 階層定義

#### Display（最大見出し）
- **H1**: 40px / 800 / -1.0 letter-spacing
  - 用途: ランディングページ、重要な画面タイトル
- **H2**: 32px / 800 / -0.5 letter-spacing
  - 用途: セクションタイトル

#### Title（見出し）
- **H3**: 28px / 700 / -0.3 letter-spacing
  - 用途: カードタイトル、画面サブタイトル
- **H4**: 24px / 700 / -0.2 letter-spacing
  - 用途: セクション内のタイトル
- **H5**: 20px / 600 / 0 letter-spacing
  - 用途: リストアイテムタイトル
- **H6**: 16px / 600 / 0 letter-spacing
  - 用途: インラインタイトル

#### Body（本文）
- **Body Large**: 16px / 500 / 1.5 line-height
  - 用途: 重要な説明文
- **Body Medium**: 14px / 500 / 1.5 line-height
  - 用途: 通常の説明文（デフォルト）
- **Body Small**: 12px / 500 / 1.4 line-height
  - 用途: 補足説明

#### Caption（キャプション）
- **Caption**: 12px / 400 / 1.4 line-height / 0.2 letter-spacing
  - 用途: 画像説明、メタ情報
- **Overline**: 11px / 600 / 1.3 line-height / 0.5 letter-spacing
  - 用途: ラベル、カテゴリ

#### Button（ボタン）
- **Button Large**: 16px / 600 / 0.2 letter-spacing
- **Button Medium**: 14px / 600 / 0.2 letter-spacing
- **Button Small**: 12px / 600 / 0.3 letter-spacing

#### Monospace（等幅）
- **Mono Large**: 16px / Roboto Mono
- **Mono Medium**: 14px / Roboto Mono
- **Mono Small**: 12px / Roboto Mono
  - 用途: コード、数値、ID

#### Emotional（感情的）
- **Celebration**: 24px / 700 / ゴールド
  - 用途: 祝福メッセージ
- **Encouragement**: 18px / 600 / 暖色
  - 用途: 励ましメッセージ
- **Guidance**: 14px / 500 / セレニティ
  - 用途: ガイダンス
- **Whisper**: 12px / 400 / ミュート
  - 用途: 控えめなヒント

### フォント

- **Primary**: Plus Jakarta Sans
- **Monospace**: Roboto Mono

### 使用例

```dart
import 'package:minq/presentation/theme/typography_system.dart';

Text(
  'タイトル',
  style: TypographySystem.h3(),
);

Text(
  '本文テキスト',
  style: TypographySystem.bodyMedium(color: Colors.black),
);
```

---

## スペーシング

### ベースライングリッド

- **基本単位**: 4px
- **グリッド単位**: 8px

すべての余白とサイズはこのグリッドに従う。

### スペーシングスケール

| 名前 | 値 | 用途 |
|------|-----|------|
| none | 0px | なし |
| xxxs | 2px | 極小 |
| xxs | 4px | 最小 |
| xs | 6px | 親密な間隔 |
| sm | 8px | 小 |
| md | 12px | 中小 |
| lg | 16px | 中（呼吸できる間隔） |
| xl | 20px | 中大 |
| xxl | 24px | 大 |
| xxxl | 32px | 敬意ある間隔 |
| xxxxl | 40px | 特大 |
| xxxxxl | 48px | 劇的な間隔 |
| xxxxxxl | 64px | 超特大 |

### セマンティックスペーシング

- **intimate**: 6px - 関連性の高い要素間
- **breathing**: 16px - 通常の要素間
- **respectful**: 32px - セクション間
- **dramatic**: 48px - 大きなセクション間

### コンポーネント固有

- **cardPadding**: 16px
- **cardMargin**: 12px
- **listItemSpacing**: 8px
- **buttonPaddingH**: 20px
- **buttonPaddingV**: 12px
- **iconTextGap**: 8px
- **formFieldSpacing**: 16px
- **sectionSpacing**: 32px
- **screenPadding**: 16px

### 使用例

```dart
import 'package:minq/presentation/theme/spacing_system.dart';

Container(
  padding: SpacingSystem.paddingLG,
  margin: EdgeInsets.symmetric(
    horizontal: SpacingSystem.lg,
    vertical: SpacingSystem.md,
  ),
  child: Column(
    children: [
      Text('タイトル'),
      SpacingSystem.vSpaceMD,
      Text('本文'),
    ],
  ),
);
```

---

## カラー

### ライトモード

#### ブランド
- **brandPrimary**: #37CBFA
- **background**: #F6F8F8
- **surface**: #FFFFFF
- **textPrimary**: #101D22
- **textSecondary**: #1F2933
- **textMuted**: #64748B

#### 感情的な色
- **joyAccent**: #FFD700 (ゴールド)
- **encouragement**: #FF6B6B (暖色)
- **serenity**: #4ECDC4 (セレニティ)
- **warmth**: #FFA726 (暖かいオレンジ)

#### 状態
- **progressActive**: #13B6EC
- **progressComplete**: #10B981
- **progressPending**: #94A3B8
- **accentSuccess**: #10B981
- **accentError**: #EF4444
- **accentWarning**: #F59E0B

### ダークモード

#### ブランド
- **brandPrimary**: #37CBFA
- **background**: #0F172A
- **surface**: #3D444D (RGB 61,68,77)
- **textPrimary**: #FFFFFF
- **textSecondary**: #CBD5F5
- **textMuted**: #94A3B8

### アクセシビリティ

すべての色の組み合わせはWCAG AA準拠（コントラスト比4.5:1以上）

---

## Elevation（影）

### レベル定義

| レベル | 用途 | BoxShadow |
|--------|------|-----------|
| 0 | フラット | なし |
| 1 | カード、チップ | minimal |
| 2 | ボタン、FAB | small |
| 3 | ダイアログ、メニュー | medium |
| 4 | ナビゲーションドロワー | large |
| 5 | モーダル、ボトムシート | maximum |

### セマンティック

- **card**: small
- **button**: medium
- **dialog**: large
- **menu**: large
- **bottomSheet**: maximum
- **fab**: medium
- **appBar**: minimal

### 使用例

```dart
import 'package:minq/presentation/theme/elevation_system.dart';

Container(
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(12),
    boxShadow: ElevationSystem.card,
  ),
  child: content,
);
```

---

## Border（枠線・角丸）

### Border Width

- **none**: 0px
- **thin**: 1px
- **regular**: 1.5px
- **thick**: 2px
- **extraThick**: 3px

### Border Radius

| 名前 | 値 | 用途 |
|------|-----|------|
| none | 0px | 角丸なし |
| xs | 4px | 極小 |
| sm | 8px | 小（ボタン、入力） |
| md | 12px | 中（カード） |
| lg | 16px | 大（ダイアログ） |
| xl | 20px | 特大 |
| xxl | 28px | 超特大 |
| full | 999px | 完全な円形 |

### セマンティック

- **cardRadius**: md (12px)
- **buttonRadius**: sm (8px)
- **inputRadius**: sm (8px)
- **dialogRadius**: lg (16px)
- **chipRadius**: full
- **avatarRadius**: full

### 使用例

```dart
import 'package:minq/presentation/theme/elevation_system.dart';

Container(
  decoration: BoxDecoration(
    border: BorderSystem.standard(Colors.grey),
    borderRadius: BorderSystem.cardRadius,
  ),
  child: content,
);
```

---

## アニメーション

### Duration（継続時間）

| 名前 | 値 | 用途 |
|------|-----|------|
| instant | 50ms | 瞬時 |
| veryFast | 100ms | 極短 |
| fast | 150ms | 短 |
| normal | 200ms | 標準 |
| moderate | 300ms | やや長 |
| slow | 400ms | 長 |
| verySlow | 600ms | 極長 |
| dramatic | 1000ms | 劇的 |

### Curve（イージング）

- **standard**: easeInOut
- **accelerate**: easeIn
- **decelerate**: easeOut
- **emphasized**: easeInOutCubic
- **bounce**: bounceOut
- **elastic**: elasticOut
- **overshoot**: easeOutBack
- **smooth**: easeInOutQuart

### セマンティック

- **pageTransition**: 200ms / emphasized
- **modalPresent**: 300ms / decelerate
- **modalDismiss**: 150ms / accelerate
- **buttonTap**: 100ms / standard
- **fadeIn**: 200ms / decelerate
- **fadeOut**: 150ms / accelerate

### Reduce Motion対応

すべてのアニメーションは`MediaQuery.disableAnimations`を考慮し、必要に応じて無効化される。

### 使用例

```dart
import 'package:minq/presentation/theme/animation_system.dart';

// 拡張メソッド使用
Widget build(BuildContext context) {
  return Text('Hello').fadeIn(
    duration: AnimationSystem.normal,
    curve: AnimationSystem.fadeInCurve,
  );
}

// コンポーネント使用
FadeInAnimation(
  duration: AnimationSystem.fadeIn,
  child: MyWidget(),
);
```

---

## ハプティクス

### 基本タイプ

- **lightImpact**: 軽いタップ
- **mediumImpact**: 中程度のタップ
- **heavyImpact**: 重いタップ
- **selectionClick**: 選択変更
- **vibrate**: バイブレーション

### セマンティック

- **success**: タスク完了、保存成功
- **warning**: 注意が必要
- **error**: 失敗、無効な操作
- **notification**: 新しい情報

### UI要素別

- **buttonTap**: lightImpact
- **primaryButtonTap**: mediumImpact
- **switchToggle**: selectionClick
- **checkboxToggle**: lightImpact
- **dragStart**: mediumImpact
- **dragEnd**: lightImpact

### アプリ固有

- **questComplete**: success
- **questCreate**: mediumImpact
- **questDelete**: heavyImpact
- **pairMatched**: 複合パターン
- **streakAchieved**: success

### 使用例

```dart
import 'package:minq/presentation/theme/haptics_system.dart';

ElevatedButton(
  onPressed: () async {
    await HapticsSystem.buttonTap();
    // アクション実行
  },
  child: Text('ボタン'),
);

// または専用ウィジェット
HapticButton(
  onPressed: () {
    // アクション実行
  },
  child: Text('ボタン'),
);
```

---

## アクセシビリティ

### タップターゲット

- **最小サイズ**: 44pt (iOS) / 48dp (Android)
- すべてのタップ可能な要素はこのサイズ以上

### コントラスト

- **WCAG AA**: 4.5:1（通常テキスト）
- **WCAG AA Large**: 3:1（大きなテキスト）
- **WCAG AAA**: 7:1（通常テキスト）
- **WCAG AAA Large**: 4.5:1（大きなテキスト）

### テキストスケール

- **1.0x**: デフォルト
- **1.3x**: 推奨テスト
- **2.0x**: 最大テスト

すべてのUIは2.0xでも崩れないこと。

### Semantics

すべてのインタラクティブ要素に適切なSemantics設定:
- label: 要素の説明
- hint: 操作のヒント
- button: ボタンであることを示す
- value: 現在の値

### Reduce Motion

- `MediaQuery.disableAnimations`を考慮
- アニメーションを無効化または短縮

### High Contrast

- `MediaQuery.highContrast`を考慮
- より高いコントラストの色を使用

### 使用例

```dart
import 'package:minq/presentation/theme/contrast_validator.dart';

// コントラストチェック
final isAccessible = ContrastValidator.meetsWCAGAA(
  textColor,
  backgroundColor,
);

// 自動調整
final adjustedColor = textColor.ensureContrastWith(
  backgroundColor,
  minContrast: 4.5,
);

// Semantics
Semantics(
  label: 'クエストを完了',
  hint: 'タップして完了としてマーク',
  button: true,
  child: IconButton(
    icon: Icon(Icons.check),
    onPressed: onComplete,
  ),
);
```

---

## 実装ファイル

### テーマシステム
- `lib/presentation/theme/minq_theme.dart` - メインテーマ定義
- `lib/presentation/theme/app_theme.dart` - ライト/ダークテーマ
- `lib/presentation/theme/build_theme.dart` - テーマビルダー

### デザイントークン
- `lib/presentation/theme/typography_system.dart` - タイポグラフィ
- `lib/presentation/theme/spacing_system.dart` - スペーシング
- `lib/presentation/theme/elevation_system.dart` - Elevation & Border
- `lib/presentation/theme/animation_system.dart` - アニメーション
- `lib/presentation/theme/haptics_system.dart` - ハプティクス
- `lib/presentation/theme/contrast_validator.dart` - コントラスト検証

### 使用方法

```dart
// テーマトークンへのアクセス
final tokens = context.tokens;

// 色
final primaryColor = tokens.brandPrimary;
final surfaceColor = tokens.surface;

// タイポグラフィ
Text('タイトル', style: tokens.titleLarge);

// スペーシング
Container(
  padding: tokens.breathingPadding,
  margin: EdgeInsets.all(tokens.lg),
);

// 角丸
Container(
  decoration: BoxDecoration(
    borderRadius: tokens.cornerMedium(),
  ),
);

// 影
Container(
  decoration: BoxDecoration(
    boxShadow: tokens.shadowSoft,
  ),
);
```

---

## ベストプラクティス

### DO ✅

- デザイントークンを使用する
- セマンティックな名前を使用する
- アクセシビリティを考慮する
- Reduce Motionを尊重する
- 4/8pxグリッドに従う
- WCAG AA準拠を維持する

### DON'T ❌

- マジックナンバーを使用しない
- 直接色を指定しない
- EdgeInsetsを直接書かない
- アクセシビリティを無視しない
- グリッドから外れない
- コントラストを無視しない

---

## 更新履歴

- 2025-10-02: 初版作成
  - タイポグラフィシステム完成
  - スペーシングシステム完成
  - Elevation & Borderシステム完成
  - アニメーションシステム完成
  - ハプティクスシステム完成
  - コントラスト検証ツール完成
