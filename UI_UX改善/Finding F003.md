Finding F003 — ログイン画面のハードコーデッド色

Severity: P2

Area: Theming

Files: lib/presentation/screens/login_screen.dart:L24–L29, L106–L108, L126–L128

Symptom (現象): ログイン画面のSnackBarアクションの文字色、背景の装飾バブル、カードの影色にColors.whiteやColors.blackを直接使用している。ダークモード時やテーマ変更時に整合性が失われる恐れがある。
github.com
github.com

Likely Root Cause (推定原因): 既存のUIを実装する際に急ごしらえでハードコードし、トークン化が遅れているため。

Concrete Fix (修正案): SnackBarアクションのtextColorをcontext.tokens.primaryForegroundに置き換え、背景の装飾バブルの色をtokens.primaryForeground.withOpacity(0.08)とする。カードの影色はtokens.textPrimary.withOpacity(0.14)に変更する。これによりライト・ダーク両テーマで読みやすさが確保される。以下のパッチを参照。

Tests (テスト): ゴールデンテストLoginCard_shadow_and_snackbar_colorsで、ライトとダークテーマにおける影とSnackBarの色を検証する。

Impact/Effort/Confidence: I=3, E=1 day, C=5

Patch (≤30 lines, unified diff if possible):

 --- a/lib/presentation/screens/login_screen.dart
 +++ b/lib/presentation/screens/login_screen.dart
@@ @override
-                 action: SnackBarAction(
-                 label: '閉じる',
-                 textColor: Colors.white,
-                 onPressed:
-                     () =>
-                         ref.read(authControllerProvider.notifier).clearError(),
-               ),
+                 action: SnackBarAction(
+                   label: '閉じる',
+                   // Use primaryForeground instead of white
+                   textColor: context.tokens.primaryForeground,
+                   onPressed: () =>
+                       ref.read(authControllerProvider.notifier).clearError(),
+                 ),
@@ class _LoginBackground extends StatelessWidget {
-           decoration: BoxDecoration(
-             shape: BoxShape.circle,
-             color: Colors.white.withOpacity(0.08),
-           ),
+           decoration: BoxDecoration(
+             shape: BoxShape.circle,
+             // Use primaryForeground with opacity for subtle highlight
+             color: tokens.primaryForeground.withOpacity(0.08),
+           ),
@@ class _LoginCard extends ConsumerWidget {
-       shadowColor: Colors.black.withOpacity(0.14),
+       // Derive shadow from textPrimary color
+       shadowColor: tokens.textPrimary.withOpacity(0.14),