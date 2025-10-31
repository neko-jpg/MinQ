Finding F001 — オフラインバナーでハードコードされた色

Severity: P2

Area: Theming

Files: lib/presentation/widgets/offline_banner.dart:L21–L40, L114–L130, L166–L205

Symptom (現象): オフラインバナー、読み取り専用インジケータおよびオフラインスナックバーでColors.orangeやColors.whiteが直接使用されており、テーマ変更やダークモードに追従しない。
github.com
github.com

Likely Root Cause (推定原因): テーマトークンへの移行途中で古い色指定が残っているため。新しいMinqThemeが提供するaccentWarning・primaryForegroundといったトークンを利用していない。

Concrete Fix (修正案): offline_banner.dartにminq_theme.dartをインポートし、背景色をcontext.tokens.accentWarningに、アイコンやテキストをcontext.tokens.primaryForegroundに置き換える。またReadOnlyModeIndicatorやshowOfflineSnackBar内でも同様のトークンを使用する。詳しいパッチは下記の通り。

Tests (テスト): ゴールデンテストOfflineBanner_matches_theme_tokensを追加し、ライト・ダークテーマでオフラインバナーの背景とテキストがそれぞれ正しいトークン色で描画されることを検証する。

Impact/Effort/Confidence: I=3, E=1 day, C=5

Patch (≤30 lines, unified diff if possible):

--- a/lib/presentation/widgets/offline_banner.dart
+++ b/lib/presentation/widgets/offline_banner.dart
@@
 import 'package:minq/l10n/app_localizations.dart';
 import 'package:minq/presentation/theme/minq_tokens.dart';
+import 'package:minq/presentation/theme/minq_theme.dart';
@@ class OfflineBanner extends ConsumerWidget {
-      color: Colors.orange,
+      // Use accentWarning from theme instead of hard‑coded orange
+      color: context.tokens.accentWarning,
@@
-          const Icon(Icons.cloud_off, color: Colors.white, size: 20),
+          Icon(Icons.cloud_off, color: context.tokens.primaryForeground, size: 20),
@@
-              style: MinqTokens.bodyMedium.copyWith(color: Colors.white),
+              style: MinqTokens.bodyMedium.copyWith(color: context.tokens.primaryForeground),
@@
-            icon: const Icon(Icons.info_outline, color: Colors.white),
+            icon: Icon(Icons.info_outline, color: context.tokens.primaryForeground),
@@ class ReadOnlyModeIndicator extends StatelessWidget {
-        color: Colors.orange.withAlpha(51),
+        color: context.tokens.accentWarning.withAlpha(51),
@@
-        border: Border.all(color: Colors.orange.withAlpha(128)),
+        border: Border.all(color: context.tokens.accentWarning.withAlpha(128)),
@@
-          const Icon(Icons.visibility, size: 16, color: Colors.orange),
+          Icon(Icons.visibility, size: 16, color: context.tokens.accentWarning),
@@
-            style: MinqTokens.bodySmall.copyWith(
-              color: Colors.orange,
-              fontWeight: FontWeight.bold,
-            ),
+            style: MinqTokens.bodySmall.copyWith(
+              color: context.tokens.accentWarning,
+              fontWeight: FontWeight.bold,
+            ),
@@ void showOfflineDialog(BuildContext context) {
-               const Icon(Icons.cloud_off, color: Colors.orange),
+               Icon(Icons.cloud_off, color: context.tokens.accentWarning),
@@ void showOfflineSnackBar(BuildContext context) {
-          const Icon(Icons.cloud_off, color: Colors.white),
+          Icon(Icons.cloud_off, color: context.tokens.primaryForeground),
@@
-      backgroundColor: Colors.orange[700],
+      backgroundColor: context.tokens.accentWarning,
@@
-        textColor: Colors.white,
+        textColor: context.tokens.primaryForeground,