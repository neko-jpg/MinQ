Patch for F003 — Theme token usage in LoginScreen

ログイン画面内のSnackBar、背景装飾、カードのシャドウで直接Colors.whiteやColors.blackを参照している部分をトークンへ置き換えます。

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


Patch for F004 — Replace hard‑coded colors in ProfileSettingScreen

プロフィール設定画面に残っているハードコーディングされたカラー値をトークンベースの指定に置き換えます。

 --- a/lib/presentation/screens/profile_setting_screen.dart
 +++ b/lib/presentation/screens/profile_setting_screen.dart
@@ AppBar(
-         actions: [
-           if (isDummyMode)
-             IconButton(
-               icon: const Icon(Icons.warning, color: Colors.orange),
-               onPressed: () => _showDummyModeWarning(context),
-               tooltip: 'ダミーデータモード',
-             ),
-         ],
+         actions: [
+           if (isDummyMode)
+             IconButton(
+               icon: Icon(Icons.warning, color: tokens.accentWarning),
+               onPressed: () => _showDummyModeWarning(context),
+               tooltip: 'ダミーデータモード',
+             ),
+         ],
@@ _buildProfileHeader(BuildContext context, WidgetRef ref, user) {
-             child: const Padding(
-               padding: EdgeInsets.all(6.0),
-               child: Icon(Icons.edit, color: Colors.white, size: 16),
-             ),
+             child: Padding(
+               padding: const EdgeInsets.all(6.0),
+               child: Icon(Icons.edit, color: tokens.primaryForeground, size: 16),
+             ),
@@ _buildDummyDataControls(BuildContext context, WidgetRef ref) {
-                 style: ElevatedButton.styleFrom(
-                   backgroundColor: tokens.accentWarning,
-                   foregroundColor: Colors.white,
-                 ),
+                 style: ElevatedButton.styleFrom(
+                   backgroundColor: tokens.accentWarning,
+                   foregroundColor: tokens.primaryForeground,
+                 ),
@@ _removeDummyData(BuildContext context, WidgetRef ref) {
-                 style: TextButton.styleFrom(foregroundColor: Colors.red),
+                 style: TextButton.styleFrom(foregroundColor: tokens.accentError),
@@ _buildPremiumFeatures(BuildContext context) {
-                 Icon(Icons.star, size: 48, color: Colors.amber),
+                 Icon(Icons.star, size: 48, color: tokens.encouragement),