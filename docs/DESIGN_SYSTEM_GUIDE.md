# デザインシステムガイド

このドキュメントは、MiniQアプリのデザインシステムの使用方法を詳しく説明します。

## 目次

1. [カラーシステム](#カラーシステム)
2. [タイポグラフィ](#タイポグラフィ)
3. [スペーシング](#スペーシング)
4. [モーションとアニメーション](#モーションとアニメーション)
5. [コンポーネント](#コンポーネント)
6. [アイコン](#アイコン)
7. [アクセシビリティ](#アクセシビリティ)

---

## カラーシステム

### 使用方法

```dart
import 'package:flutter/material.dart';

// テーマトークンを使用（推奨）
Container(
  color: context.tokens.surface,
  child: Text(
    'Hello',
    style: TextStyle(color: context.tokens.onSurface),
  ),
)

// または Theme を使用
Container(
  color: Theme.of(context).colorScheme.surface,
  child: Text(
    'Hello',
    style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
  ),
)
```

### カラーパレット

#### プライマリカラー（青系）
```dart
// ライトモード
primary: Color(0xFF2196F3)      // #2196F3
onPrimary: Color(0xFFFFFFFF)    // #FFFFFF

// ダークモード
primary: Color(0xFF64B5F6)      // #64B5F6
onPrimary: Color(0xFF000000)    // #000000
```

#### セカンダリカラー（紫系）
```dart
// ライトモード
secondary: Color(0xFF9C27B0)    // #9C27B0
onSecondary: Color(0xFFFFFFFF)  // #FFFFFF

// ダークモード
secondary: Color(0xFFBA68C8)    // #BA68C8
onSecondary: Color(0xFF000000)  // #000000
```

#### サーフェスカラー
```dart
// ライトモード
surface: Color(0xFFFFFFFF)      // #FFFFFF
onSurface: Color(0xFF000000)    // #000000

// ダークモード
surface: Color(0xFF3D444D)      // RGB(61, 68, 77)
onSurface: Color(0xFFFFFFFF)    // #FFFFFF
```

#### 背景カラー
```dart
// ライトモード
background: Color(0xFFF5F5F5)   // #F5F5F5
onBackground: Color(0xFF000000) // #000000

// ダークモード
background: Color(0xFF121212)   // #121212
onBackground: Color(0xFFFFFFFF) // #FFFFFF
```

#### セマンティックカラー
```dart
// 成功
success: Color(0xFF4CAF50)      // #4CAF50
onSuccess: Color(0xFFFFFFFF)    // #FFFFFF

// 警告
warning: Color(0xFFFF9800)      // #FF9800
onWarning: Color(0xFF000000)    // #000000

// エラー
error: Color(0xFFF44336)        // #F44336
onError: Color(0xFFFFFFFF)      // #FFFFFF

// 情報
info: Color(0xFF2196F3)         // #2196F3
onInfo: Color(0xFFFFFFFF)       // #FFFFFF
```

### コントラスト比

すべての色の組み合わせは WCAG 2.1 AA 基準（4.5:1）を満たしています。

```dart
// コントラスト比を確認
import 'package:flutter/material.dart';

double calculateContrastRatio(Color foreground, Color background) {
  final fgLuminance = foreground.computeLuminance();
  final bgLuminance = background.computeLuminance();
  
  final lighter = max(fgLuminance, bgLuminance);
  final darker = min(fgLuminance, bgLuminance);
  
  return (lighter + 0.05) / (darker + 0.05);
}

// 使用例
final ratio = calculateContrastRatio(
  context.tokens.onSurface,
  context.tokens.surface,
);
print('Contrast ratio: $ratio'); // 4.5以上であるべき
```

---

## タイポグラフィ

### 使用方法

```dart
import '../theme/typography_system.dart';

// タイポグラフィトークンを使用（推奨）
Text('見出し1', style: AppTypography.h1)
Text('見出し2', style: AppTypography.h2)
Text('本文', style: AppTypography.body)
Text('キャプション', style: AppTypography.caption)

// カスタマイズ
Text(
  '強調テキスト',
  style: AppTypography.body.copyWith(
    fontWeight: FontWeight.bold,
    color: context.tokens.primary,
  ),
)
```

### タイポグラフィスケール

#### 見出し
```dart
// H1 - ページタイトル
h1: TextStyle(
  fontSize: 32,
  fontWeight: FontWeight.bold,
  height: 1.25,
  letterSpacing: -0.5,
)

// H2 - セクションタイトル
h2: TextStyle(
  fontSize: 24,
  fontWeight: FontWeight.bold,
  height: 1.33,
  letterSpacing: 0,
)

// H3 - サブセクションタイトル
h3: TextStyle(
  fontSize: 20,
  fontWeight: FontWeight.w600,
  height: 1.4,
  letterSpacing: 0.15,
)

// H4 - カードタイトル
h4: TextStyle(
  fontSize: 18,
  fontWeight: FontWeight.w600,
  height: 1.44,
  letterSpacing: 0.15,
)

// H5 - リストアイテムタイトル
h5: TextStyle(
  fontSize: 16,
  fontWeight: FontWeight.w600,
  height: 1.5,
  letterSpacing: 0.15,
)

// H6 - 小見出し
h6: TextStyle(
  fontSize: 14,
  fontWeight: FontWeight.w600,
  height: 1.57,
  letterSpacing: 0.1,
)
```

#### 本文
```dart
// Body - 通常の本文
body: TextStyle(
  fontSize: 16,
  fontWeight: FontWeight.normal,
  height: 1.5,
  letterSpacing: 0.5,
)

// Body Small - 小さい本文
bodySmall: TextStyle(
  fontSize: 14,
  fontWeight: FontWeight.normal,
  height: 1.43,
  letterSpacing: 0.25,
)

// Body Large - 大きい本文
bodyLarge: TextStyle(
  fontSize: 18,
  fontWeight: FontWeight.normal,
  height: 1.56,
  letterSpacing: 0.5,
)
```

#### その他
```dart
// Caption - キャプション、補足テキスト
caption: TextStyle(
  fontSize: 12,
  fontWeight: FontWeight.normal,
  height: 1.33,
  letterSpacing: 0.4,
)

// Button - ボタンテキスト
button: TextStyle(
  fontSize: 14,
  fontWeight: FontWeight.w600,
  height: 1.14,
  letterSpacing: 1.25,
)

// Overline - オーバーライン
overline: TextStyle(
  fontSize: 10,
  fontWeight: FontWeight.w600,
  height: 1.6,
  letterSpacing: 1.5,
)

// Mono - 等幅フォント（コード、数値）
mono: TextStyle(
  fontFamily: 'RobotoMono',
  fontSize: 14,
  fontWeight: FontWeight.normal,
  height: 1.43,
  letterSpacing: 0,
)
```

### フォントファミリー

```yaml
# pubspec.yaml
fonts:
  - family: Noto Sans JP
    fonts:
      - asset: fonts/NotoSansJP-Regular.ttf
      - asset: fonts/NotoSansJP-Bold.ttf
        weight: 700
  
  - family: RobotoMono
    fonts:
      - asset: fonts/RobotoMono-Regular.ttf
```

### テキストスケーリング対応

```dart
// テキストスケールを制限（最大1.3倍）
MediaQuery(
  data: MediaQuery.of(context).copyWith(
    textScaleFactor: min(MediaQuery.of(context).textScaleFactor, 1.3),
  ),
  child: YourWidget(),
)

// または個別に設定
Text(
  'スケールしないテキスト',
  textScaleFactor: 1.0,
)
```

---

## スペーシング

### 使用方法

```dart
import '../theme/spacing_system.dart';

// パディング
Padding(
  padding: EdgeInsets.all(AppSpacing.md),
  child: YourWidget(),
)

// マージン
Container(
  margin: EdgeInsets.symmetric(
    horizontal: AppSpacing.lg,
    vertical: AppSpacing.sm,
  ),
  child: YourWidget(),
)

// SizedBox
Column(
  children: [
    Widget1(),
    SizedBox(height: AppSpacing.md),
    Widget2(),
  ],
)
```

### スペーシングスケール

```dart
// 4px ベースのスケール
xxs: 2.0   // 2px
xs: 4.0    // 4px
sm: 8.0    // 8px
md: 16.0   // 16px
lg: 24.0   // 24px
xl: 32.0   // 32px
xxl: 48.0  // 48px
xxxl: 64.0 // 64px
```

### 使用ガイドライン

```dart
// カード内のパディング
Card(
  child: Padding(
    padding: EdgeInsets.all(AppSpacing.md), // 16px
    child: Content(),
  ),
)

// リストアイテム間のスペース
ListView.separated(
  separatorBuilder: (_, __) => SizedBox(height: AppSpacing.sm), // 8px
  itemBuilder: (_, index) => ListItem(),
)

// セクション間のスペース
Column(
  children: [
    Section1(),
    SizedBox(height: AppSpacing.lg), // 24px
    Section2(),
  ],
)

// 画面の余白
Scaffold(
  body: Padding(
    padding: EdgeInsets.all(AppSpacing.md), // 16px
    child: Content(),
  ),
)
```

---

## モーションとアニメーション

### 使用方法

```dart
import '../theme/animation_system.dart';

// アニメーション期間
AnimatedContainer(
  duration: AppAnimation.durationNormal, // 300ms
  curve: AppAnimation.curveStandard,     // Curves.easeInOut
  // ...
)

// ページ遷移
Navigator.push(
  context,
  PageRouteBuilder(
    pageBuilder: (_, __, ___) => NextPage(),
    transitionDuration: AppAnimation.durationSlow,
    transitionsBuilder: (_, animation, __, child) {
      return FadeTransition(
        opacity: animation,
        child: child,
      );
    },
  ),
)
```

### アニメーション期間

```dart
// 高速 - 小さな変化（ボタンのホバーなど）
durationFast: Duration(milliseconds: 150)

// 通常 - 一般的なアニメーション
durationNormal: Duration(milliseconds: 300)

// 遅い - 大きな変化（ページ遷移など）
durationSlow: Duration(milliseconds: 500)

// 非常に遅い - 特別な演出
durationVerySlow: Duration(milliseconds: 1000)
```

### イージングカーブ

```dart
// 標準 - 一般的なアニメーション
curveStandard: Curves.easeInOut

// 強調 - 注目を集める
curveEmphasized: Curves.easeInOutCubic

// 減速 - 画面に入る
curveDecelerate: Curves.easeOut

// 加速 - 画面から出る
curveAccelerate: Curves.easeIn

// バウンス - 楽しい演出
curveBounce: Curves.bounceOut

// エラスティック - 強い演出
curveElastic: Curves.elasticOut
```

### アニメーションパターン

#### フェード
```dart
AnimatedOpacity(
  opacity: isVisible ? 1.0 : 0.0,
  duration: AppAnimation.durationNormal,
  child: YourWidget(),
)
```

#### スライド
```dart
AnimatedSlide(
  offset: isVisible ? Offset.zero : Offset(0, 0.1),
  duration: AppAnimation.durationNormal,
  curve: AppAnimation.curveDecelerate,
  child: YourWidget(),
)
```

#### スケール
```dart
AnimatedScale(
  scale: isPressed ? 0.95 : 1.0,
  duration: AppAnimation.durationFast,
  child: YourWidget(),
)
```

#### 回転
```dart
AnimatedRotation(
  turns: isRotated ? 0.5 : 0.0,
  duration: AppAnimation.durationNormal,
  child: YourWidget(),
)
```

### Reduce Motion 対応

```dart
// OSの設定を確認
final disableAnimations = MediaQuery.of(context).disableAnimations;

// アニメーションを無効化
AnimatedContainer(
  duration: disableAnimations 
    ? Duration.zero 
    : AppAnimation.durationNormal,
  // ...
)
```

---

## コンポーネント

### ボタン

#### プライマリボタン
```dart
ElevatedButton(
  onPressed: () {},
  child: Text('プライマリアクション'),
)
```

#### セカンダリボタン
```dart
OutlinedButton(
  onPressed: () {},
  child: Text('セカンダリアクション'),
)
```

#### テキストボタン
```dart
TextButton(
  onPressed: () {},
  child: Text('テキストアクション'),
)
```

### カード

```dart
Card(
  elevation: 2,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(12),
  ),
  child: Padding(
    padding: EdgeInsets.all(AppSpacing.md),
    child: Content(),
  ),
)
```

### ダイアログ

```dart
showDialog(
  context: context,
  builder: (context) => AlertDialog(
    title: Text('タイトル'),
    content: Text('メッセージ'),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: Text('キャンセル'),
      ),
      ElevatedButton(
        onPressed: () {
          // アクション
          Navigator.pop(context);
        },
        child: Text('OK'),
      ),
    ],
  ),
)
```

### ボトムシート

```dart
showModalBottomSheet(
  context: context,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.vertical(
      top: Radius.circular(16),
    ),
  ),
  builder: (context) => Container(
    padding: EdgeInsets.all(AppSpacing.md),
    child: Content(),
  ),
)
```

### スナックバー

```dart
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(
    content: Text('メッセージ'),
    action: SnackBarAction(
      label: 'アクション',
      onPressed: () {},
    ),
    duration: Duration(seconds: 3),
  ),
)
```

---

## アイコン

### 使用方法

```dart
// Material Icons
Icon(Icons.home)
Icon(Icons.settings)
Icon(Icons.person)

// カスタムアイコン
import '../core/assets/app_icons.dart';

Icon(AppIcons.quest)
Icon(AppIcons.streak)
Icon(AppIcons.pair)
```

### アイコンサイズ

```dart
// 小
Icon(Icons.home, size: 16)

// 通常
Icon(Icons.home, size: 24)

// 大
Icon(Icons.home, size: 32)

// 特大
Icon(Icons.home, size: 48)
```

### アイコンカラー

```dart
// テーマカラーを使用
Icon(
  Icons.home,
  color: context.tokens.primary,
)

// セマンティックカラー
Icon(
  Icons.check_circle,
  color: context.tokens.success,
)
```

---

## アクセシビリティ

### セマンティクス

```dart
// ラベルを追加
Semantics(
  label: 'ホームボタン',
  child: IconButton(
    icon: Icon(Icons.home),
    onPressed: () {},
  ),
)

// ヒントを追加
Semantics(
  hint: 'タップしてホーム画面に移動',
  child: IconButton(
    icon: Icon(Icons.home),
    onPressed: () {},
  ),
)

// 読み上げ順序を制御
Semantics(
  sortKey: OrdinalSortKey(1.0),
  child: Widget1(),
)
```

### タップターゲットサイズ

```dart
// 最小48dp
MaterialButton(
  minWidth: 48,
  height: 48,
  onPressed: () {},
  child: Icon(Icons.add),
)

// または
SizedBox(
  width: 48,
  height: 48,
  child: IconButton(
    icon: Icon(Icons.add),
    onPressed: () {},
  ),
)
```

### フォーカス

```dart
// フォーカス可能
Focus(
  child: GestureDetector(
    onTap: () {},
    child: Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: context.tokens.primary,
          width: 2,
        ),
      ),
      child: Content(),
    ),
  ),
)
```

---

## ベストプラクティス

### DO（推奨）

✅ テーマトークンを使用する
```dart
color: context.tokens.primary
```

✅ スペーシングシステムを使用する
```dart
padding: EdgeInsets.all(AppSpacing.md)
```

✅ タイポグラフィシステムを使用する
```dart
style: AppTypography.h1
```

✅ アニメーション期間を統一する
```dart
duration: AppAnimation.durationNormal
```

### DON'T（非推奨）

❌ ハードコードされた色を使用しない
```dart
color: Color(0xFF2196F3) // NG
```

❌ マジックナンバーを使用しない
```dart
padding: EdgeInsets.all(16) // NG
```

❌ インラインスタイルを使用しない
```dart
style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold) // NG
```

❌ 任意のアニメーション期間を使用しない
```dart
duration: Duration(milliseconds: 250) // NG
```

---

## 更新履歴

- 2025-10-02: 初版作成
