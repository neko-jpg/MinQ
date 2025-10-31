# MinQ—ライト/ダーク配色フル仕様 v1.0（律案）



---

## 1. グローバル設計方針（共通）

- **狙い**: 認知負荷低減、状態の即時把握、視認性の一貫性、昼夜・環境光変化への適応。
- **意味色（Semantic）**を最優先: `Primary`=行動/選択、`Secondary`=補助、`Info`=中立通知、`Success`=達成、`Warning`=注意/猶予、`Error`=失敗/危険。
- **階層**: `Background` → `Surface` → `Card/Sheet` → `Element` → `Focus/Overlay`。
- **コントラスト**: テキストは **AA(4.5:1) 以上**、主要CTAは **AAA(7.0:1) 推奨**。
- **動的 on-color**: `contrastOn(background)` を使用（既存 `ColorTokens.contrastOn` と整合）。

---

## 2. トークン定義（Light/Dark）

> 既存 `lib/presentation/theme/minq_tokens.dart` と `color_tokens.dart` を上書き/補完することを想定。数値は sRGB 16進。

### 2.1 ライト・モード

- **Brand/Primary**
  - `primary`: `#4F46E5` (Indigo 600)
  - `primaryHover`: `#4338CA` (Indigo 700)
  - `onPrimary`: `#FFFFFF`（自動切替を併用可）
- **Secondary/Accent**
  - `secondary`: `#8B5CF6` (Violet 500)
  - `onSecondary`: `#FFFFFF`
  - `tertiary`（補助・グラフ）: `#14B8A6` (Teal 500)
- **Neutrals**
  - `background`: `#F5F7FB`
  - `surface`: `#FFFFFF`
  - `surfaceAlt`: `#F8FAFC`
  - `border`: `#E2E8F0`
  - `overlay`: `#0F172A99` (60%)
- **Text**
  - `textPrimary`: `#0F172A`
  - `textSecondary`: `#475569`
  - `textMuted/Disabled`: `#94A3B8`
- **States**
  - `success`: `#10B981`
  - `warning`: `#F59E0B`
  - `error`: `#EF4444`
  - `info`: `#0284C7`
  - `focusRing`: `#93C5FD`
- **Misc**
  - `link`: `#2563EB`
  - `divider`: `#E5E7EB`

### 2.2 ダーク・モード

- **Brand/Primary**
  - `primary`: `#818CF8` (Indigo 400)
  - `primaryHover`: `#A5B4FC` (Indigo 300)
  - `onPrimary`: `contrastOn(primary)`（推奨: `#0B1120`）
- **Secondary/Accent**
  - `secondary`: `#A78BFA` (Violet 400)
  - `onSecondary`: `#0B1120`
  - `tertiary`: `#2DD4BF` (Teal 400)
- **Neutrals**
  - `background`: `#0B1120`
  - `surface`: `#0F172A`
  - `surfaceAlt`: `#111827`
  - `border`: `#334155`
  - `overlay`: `#00000099`
- **Text**
  - `textPrimary`: `#E5E7EB`
  - `textSecondary`: `#9CA3AF`
  - `textMuted/Disabled`: `#64748B`
- **States**
  - `success`: `#34D399`
  - `warning`: `#FBBF24`
  - `error`: `#F87171`
  - `info`: `#38BDF8`
  - `focusRing`: `#60A5FA`
- **Misc**
  - `link`: `#93C5FD`
  - `divider`: `#1F2937`

### 2.3 グラフ/データ可視化パレット

順番付き: `[#3B82F6, #22C55E, #F59E0B, #EF4444, #8B5CF6, #14B8A6, #F43F5E, #06B6D4]`（Dark ではやや明度+彩度を上げる）

---

## 3. コンポーネント配色マッピング

> ここを実装すれば画面固有の指定は薄くなります。`MinqTheme` へ ThemeExtension で集約。

- **AppBar/TopBar**: `bg=surface`, `fg=textPrimary`, `elev=1`, `divider=divider`。スクロール時は `surfaceAlt`。
- **BottomNav**: `bg=surface`, `active=primary`, `inactive=textSecondary`, `badge=error/on=#FFFFFF`。
- **FAB/PrimaryButton**: `bg=primary`, `fg=onPrimary`, `hover=primaryHover`, `focus=focusRing`。
- **SecondaryButton**: `bg=secondary`, `fg=onSecondary`, `hover=darken(secondary,8%)`。
- **Tertiary/TextButton**: `fg=primary`, `hover=primary` 8% overlay。
- **OutlinedButton**: `fg=textPrimary`, `border=border`, `hover=surfaceAlt`。
- **Cards/Sheets**: `bg=surface`, `border=border`, `title=textPrimary`, `body=textSecondary`。
- **TextField**: `bg=surfaceAlt`, `text=textPrimary`, `placeholder=textMuted`, `border=border`, `focusRing=focusRing`, `error=error`。
- **Chips/Tags**: `default`: `bg=surfaceAlt`, `fg=textSecondary`, `selected`: `bg=primary`/`fg=onPrimary`。
- **Progress**: active=`primary`, complete=`success`, pending=`warning`。
- **Snackbar/Toast**: base=`surface`, info=`info`, success=`success`, warn=`warning`, error=`error`（いずれも `fg=contrastOn(bg)`）。
- **Dialogs**: `bg=surface`, `fg=textPrimary`, `danger`ダイアログのCTAは `error` を主ボタンに。
- **Skeleton**: light=`#E5E7EB→#F3F4F6`、dark=`#1F2937→#111827` のシマー。

---

## 4. 画面ごとの機能・配色指定（ライト/ダーク共通ポリシー）

> **分類ごと**に画面を束ね、機能単位まで踏み込みます。各色は上記トークンを参照名で記述（実値は 2章）。

### 4.1 ナビゲーション/ベース
- **`shell_screen.dart`（タブナビ全体）**
  - タブ背景: `surface`／境界: `divider`
  - アクティブアイコン/ラベル: `primary`、非アクティブ: `textSecondary`
  - 未読/アラートバッジ: `error`（on=`#FFF`）
  - 理由: 常時視認エリアは彩度を抑え、選択状態のみ hue を強調。

- **`splash_screen.dart`**
  - 背景: ライト=`background`、ダーク=`background`
  - センターシンボル: `primary` グラデ（`primary→secondary`）
  - ローディング: `primary`
  - 理由: ブランド印象の確立と光量最適化。

### 4.2 今日/記録/クエスト
- **`today_logs_screen.dart`**
  - 追加CTA: `primary`
  - ログカード: `surface`/`border`
  - ステータスピル: 成功=`success`、未完=`warning`、失敗=`error`
  - 理由: 状態の一目把握。色覚多様性に配慮しアイコン形状も併用。

- **`record_screen.dart`**
  - 入力フィールド: `surfaceAlt`/`border`、フォーカス=`focusRing`
  - 保存CTA: `primary`、破棄/戻る: `textSecondary`
  - エラー: `error`、成功トースト: `success`

- **`quests_screen.dart` / `quest_detail_screen.dart` / `create_quest_screen.dart` / `create_mini_quest_screen.dart`**
  - クエスト状態ラベル: `active=primary`, `completed=success`, `paused=textMuted`, `overdue=error`
  - 優先度ドット: `High=error`, `Med=warning`, `Low=info`
  - タグChip: `surfaceAlt`（選択時 `primary`）
  - タイマー/残時間: 安全域=`primary`、デッドライン警告=`warning`、超過=`error`
  - 理由: 意味色の一貫運用で学習コストを最小化。

- **`quest_timer_screen.dart`**
  - 円形ゲージ: `progressActive`=`primary`、完了=`success`、停止=`warning`
  - 本文文字: `textPrimary`、残り時間警告域で文字色は `warning` に切替

### 4.3 成長/可視化
- **`stats_screen.dart`**
  - チャート系列: パレット順（2.3章）
  - 伸長/減退インジケータ: `success`/`error`
  - しきい値ライン: `border`、選択系列: `primary`
  - ヒートマップ: 低→高の連続色 `#E5E7EB→#3B82F6`（ダークは `#1F2937→#93C5FD`）

- **`weekly_report_screen.dart`**
  - セクションタブ: `surfaceAlt`、アクティブ下線=`primary`
  - ハイライトカード: 良い変化=`success`、注意=`warning`、悪化=`error`
  - 推薦行動ボタン: `secondary`

- **`achievements_screen.dart` / `celebration_screen.dart`**
  - レアリティ: Gold=`#F59E0B`, Silver=`#9CA3AF`, Bronze=`#B45309`
  - 花火/彩度演出は `secondary` と `tertiary` をグローに使用

- **`challenges_screen.dart` / `battle_screen.dart`**
  - チャレンジ進捗: `progressActive=primary`, `complete=success`, `pending=warning`
  - バトルの被ダメ/危険演出: `error` を一時的オーバーレイ

### 4.4 ソーシャル/コミュニティ/ペア
- **`community_board_screen.dart`**
  - ピン留め: `info`、公式/モデレータ: `secondary`
  - 投票/いいね: アクティブ=`primary`、未選択=`textSecondary`

- **`buddy_list_screen.dart` / `pair_screen.dart` / `pair_matching_screen.dart` / `pair_progress_comparison_screen.dart`**
  - 相手カラー: 補色の `tertiary` 系（区別に `#2DD4BF` と `#06B6D4`）
  - 進捗比較チャート: 自分=`primary`、相手=`tertiary`

### 4.5 AI/インサイト/チャット
- **`ai_concierge_chat_screen.dart` / `chat_screen.dart`**
  - Botバブル: `info` 系（ライト=`#E0F2FE`/fg=`#075985`、ダーク=`#083344`/fg=`#E0F2FE`）
  - Userバブル: `primary` 10% 背景（ライト）/ 20%（ダーク）に `fg=textPrimary`
  - 入力ボックス: `surfaceAlt`/`border`、送信CTA=`primary`

- **`ai_insights_screen.dart`**
  - インサイトカード: 改善提案=`secondary`、注意喚起=`warning`、成功要因=`success`

### 4.6 設定/課金/サポート/各種
- **`settings_screen.dart` / `profile_*_screen.dart` / `accessibility_settings_screen.dart` / `smart_notification_settings_screen.dart`**
  - セクションヘッダ: `textSecondary`
  - スイッチ ON=`primary`、OFF=`textMuted`
  - 危険操作（リセット等）: `error`

- **`subscription_screen.dart` / `subscription_premium_screen.dart`**
  - ヒーロー: `primary→secondary` グラデ
  - プランカード: 選択中ボーダー=`primary`、推しプランリボン=`secondary`
  - CTA: `primary`

- **`support_screen.dart` / `policy_viewer_screen.dart` / `changelog_screen.dart` / `whats_new_screen.dart` / `version_update_screen.dart` / `data_migration_guide_screen.dart`**
  - 情報通知色として `info`
  - 旧バージョン警告/互換注意: `warning`

- **`crash_recovery_screen.dart` / `account_deletion_screen.dart`**
  - 強調 CTA（実行）: `error`（確認ダイアログも同系）
  - セカンダリ: `textSecondary`（安全側の選択を視覚的に弱めない）

- **`referral_screen.dart`**
  - 成功共有/リンクコピー完了: `success`

---

## 5. 実装差分（サンプル）

> 既存構成にフィットする **最小差分**。`build_theme.dart`/`app_theme.dart` はそのまま利用可能。

```dart
// lib/presentation/theme/color_tokens.dart （差し替え/拡張）
class ColorTokens {
  const ColorTokens({
    required this.primary,
    required this.primaryHover,
    required this.secondary,
    required this.tertiary,
    required this.background,
    required this.surface,
    required this.surfaceAlt,
    required this.border,
    required this.overlay,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.success,
    required this.warning,
    required this.error,
    required this.info,
    required this.focusRing,
  });
  final Color primary, primaryHover, secondary, tertiary;
  final Color background, surface, surfaceAlt, border, overlay;
  final Color textPrimary, textSecondary, textMuted;
  final Color success, warning, error, info, focusRing;

  Color contrastOn(Color bg) =>
      bg.computeLuminance() > 0.5 ? const Color(0xFF0B1120) : Colors.white;

  static ColorTokens light() => const ColorTokens(
        primary: Color(0xFF4F46E5),
        primaryHover: Color(0xFF4338CA),
        secondary: Color(0xFF8B5CF6),
        tertiary: Color(0xFF14B8A6),
        background: Color(0xFFF5F7FB),
        surface: Colors.white,
        surfaceAlt: Color(0xFFF8FAFC),
        border: Color(0xFFE2E8F0),
        overlay: Color(0x990F172A),
        textPrimary: Color(0xFF0F172A),
        textSecondary: Color(0xFF475569),
        textMuted: Color(0xFF94A3B8),
        success: Color(0xFF10B981),
        warning: Color(0xFFF59E0B),
        error: Color(0xFFEF4444),
        info: Color(0xFF0284C7),
        focusRing: Color(0xFF93C5FD),
      );

  static ColorTokens dark() => const ColorTokens(
        primary: Color(0xFF818CF8),
        primaryHover: Color(0xFFA5B4FC),
        secondary: Color(0xFFA78BFA),
        tertiary: Color(0xFF2DD4BF),
        background: Color(0xFF0B1120),
        surface: Color(0xFF0F172A),
        surfaceAlt: Color(0xFF111827),
        border: Color(0xFF334155),
        overlay: Color(0x99000000),
        textPrimary: Color(0xFFE5E7EB),
        textSecondary: Color(0xFF9CA3AF),
        textMuted: Color(0xFF64748B),
        success: Color(0xFF34D399),
        warning: Color(0xFFFBBF24),
        error: Color(0xFFF87171),
        info: Color(0xFF38BDF8),
        focusRing: Color(0xFF60A5FA),
      );
}
```

```dart
// lib/presentation/theme/minq_theme.dart （ThemeExtension 例）
@immutable
class MinqTheme extends ThemeExtension<MinqTheme> {
  const MinqTheme({required this.brightness, required this.colors});
  final Brightness brightness;
  final ColorTokens colors;

  static MinqTheme light() => MinqTheme(
        brightness: Brightness.light,
        colors: ColorTokens.light(),
      );
  static MinqTheme dark() => MinqTheme(
        brightness: Brightness.dark,
        colors: ColorTokens.dark(),
      );

  @override
  MinqTheme copyWith({Brightness? brightness, ColorTokens? colors}) =>
      MinqTheme(
        brightness: brightness ?? this.brightness,
        colors: colors ?? this.colors,
      );

  @override
  MinqTheme lerp(ThemeExtension<MinqTheme>? other, double t) {
    // 省略（必要なら線形補間を実装）
    return this;
  }
}

extension MinqThemeContext on BuildContext {
  MinqTheme get tokens => Theme.of(this).extension<MinqTheme>()!;
}
```

```dart
// lib/presentation/theme/build_theme.dart （既存に追記）
ThemeData buildTheme(MinqTheme t) {
  final c = t.colors;
  final onPrimary = c.contrastOn(c.primary);
  return ThemeData(
    brightness: t.brightness,
    scaffoldBackgroundColor: c.background,
    colorScheme: ColorScheme(
      brightness: t.brightness,
      primary: c.primary,
      onPrimary: onPrimary,
      secondary: c.secondary,
      onSecondary: c.contrastOn(c.secondary),
      surface: c.surface,
      onSurface: c.textPrimary,
      background: c.background,
      onBackground: c.textPrimary,
      error: c.error,
      onError: c.contrastOn(c.error),
    ),
    dividerColor: c.border,
    dialogBackgroundColor: c.surface,
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: c.surface,
      selectedItemColor: c.primary,
      unselectedItemColor: c.textSecondary,
      type: BottomNavigationBarType.fixed,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: c.surfaceAlt,
      border: OutlineInputBorder(
        borderSide: BorderSide(color: c.border),
        borderRadius: BorderRadius.circular(12),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: c.focusRing, width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
      errorBorder: OutlineInputBorder(
        borderSide: BorderSide(color: c.error, width: 2),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: c.surface,
      contentTextStyle: TextStyle(color: c.textPrimary),
      actionTextColor: c.primary,
    ),
    extensions: [t],
  );
}
```

---

## 6. コントラスト検証と代替案

- 各CTA/本文: **AA** 満たすまで `contrastOn` で自動 on-color 切替。
- ダークの `primary` が明るすぎる端末では `primary=#6D28D9`（Violet 700）へのフォールバック案あり。

---

## 7. 運用メモ

- **データ可視化**: 夜間に輝度差が強く出ないよう彩度を+10%/明度-5%で補正。
- **色覚多様性**: 状態色は **形状/アイコン/テクスチャ**の冗長符号化を併用。
- **アニメーション**: 色変化は 120–180ms、`curve=fastOutSlowIn`。

---

## 8. 変更影響範囲

- 画面: すべて（本仕様はトークン駆動のため差分は最小）
- コンポーネント: `BottomNav`/`Buttons`/`Inputs`/`Cards`/`Snackbars`/`Charts`

---

### 付録A: 画面一覧とトークン適用早見（抜粋）

| カテゴリ | 画面 | 主要トークン |
|---|---|---|
| ナビ | shell | `primary`, `surface`, `textSecondary` |
| 今日/記録 | today_logs / record | `success/warning/error`, `surfaceAlt`, `focusRing` |
| クエスト | quests / quest_detail / create_* | `primary`, `success`, `error`, `warning` |
| 可視化 | stats / weekly_report | パレット(2.3), `info`, `success`, `error` |
| ゲーミフィケーション | achievements / celebration / challenges / battle | `secondary`, `success`, `warning`, `error` |
| ソーシャル | community_board / buddy_list / pair_* | `tertiary`, `info`, `primary` |
| AI | ai_concierge_chat / chat / ai_insights | `info`, `primary`, `surfaceAlt` |
| 設定等 | settings / profile_* / accessibility / smart_notification | `textSecondary`, `primary`, `error` |
| 課金 | subscription* | `primary→secondary` グラデ, `primary` CTA |
| 重要操作 | account_deletion / crash_recovery | `error`, `surface`, `textPrimary` |

> フルリストはソースに即して適用済み。個別エッジケースは PR 上で指摘します。

---

**以上。** バグが潜んでいたら、私のセンサーが即座にスキャンして捕捉します。

