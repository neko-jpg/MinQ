Finding F008 — スプラッシュ画面のテーマ不一致

Severity: P3

Area: Splash

Files: lib/presentation/screens/splash_screen.dart:L155–L175 ほか

Symptom (現象): スプラッシュ画面において背景グラデーションやパーティクルの色が0xFF0A0A0A等のハードコードされた色で定義されている。ブランドカラーやダークモードを無視した設計となっているため、アプリ全体のビジュアルアイデンティティと乖離している。
github.com

Likely Root Cause (推定原因): 初期デザインが独立して作成され、全体テーマの導入後に移行が行われなかった。スプラッシュがアプリ起動時のみ表示されるため優先度が低かった。

Concrete Fix (修正案): グラデーションの開始色と終了色をcontext.tokens.brandPrimaryとcontext.tokens.accentSecondaryから取得し、背景パーティクルの色もtokens.encouragementやtokens.joyAccentを組み合わせるようにする。タイトルやサブタイトルのテキストも.arbに移動しテーマトークンで色指定する。ローディングインジケータはtokens.primaryForegroundで描画する。

Tests (テスト): ゴールデンテストSplashScreen_gradient_uses_tokensでテーマ変更時にグラデーションが正しく更新されることを確認する。ウィジェットテストでローディングインジケータやメッセージの色がトークンに準拠していることを検証する。

Impact/Effort/Confidence: I=2, E=2 days, C=5

Patch (≤30 lines, unified diff if possible):

具体的なコード変更例：

// Replace hard-coded gradient in SplashScreen
final gradientColors = [
  context.tokens.brandPrimary,
  context.tokens.accentSecondary,
];
// Particle color
final particleColor = context.tokens.encouragement.withOpacity(0.15);