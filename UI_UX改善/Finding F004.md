Finding F004 — プロフィール設定画面のハードコードカラー

Severity: P2

Area: Theming

Files: lib/presentation/screens/profile_setting_screen.dart:L40, L145, L342, L386, L671

Symptom (現象): プロフィール設定画面のダミーデータ警告や編集アイコン、ダミーデータ撤去ボタン、プレミアム機能アイコンなど複数箇所でColors.orange・Colors.white・Colors.red・Colors.amberが直接使用されている。テーマトークンとの整合性がない。
github.com
github.com
github.com

Likely Root Cause (推定原因): 複数機能の実装が進行する中で、個別の色指定がトークン化されずに残ってしまった。特に警告色や成功色がわかりやすい色として一時的にハードコーディングされた。

Concrete Fix (修正案): 以下の通り、各色指定をMinqThemeから取得するトークンに置き換える。ダミーモード警告アイコンはtokens.accentWarning、編集ボタンは背景をtokens.brandPrimary、アイコン色をtokens.primaryForegroundとする。ダミーデータ撤去ボタンは前景色をtokens.primaryForeground、確認ダイアログの削除ボタンはtokens.accentErrorを用いる。プレミアム機能の星アイコンは暖かみのあるtokens.encouragement色に変更する。

Tests (テスト): ウィジェットテストProfileSettingScreen respects theme tokensを追加し、ダミーモードON時の各アイコンやボタン色がテーマに応じて正しく描画されることを確認する。

Impact/Effort/Confidence: I=3, E=1 day, C=5

Patch (≤30 lines, unified diff if possible):

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