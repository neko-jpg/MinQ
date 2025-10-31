Patch for F001 — Hardcoded colors in OfflineBanner

以下のパッチは、オフラインバナーや読み取り専用インジケータ、スナックバーで直接使用されている色を、MinqThemeのトークンに置き換えるものです。minq_theme.dartのインポートも追加します。

 --- a/lib/presentation/widgets/offline_banner.dart
 +++ b/lib/presentation/widgets/offline_banner.dart
 @@
  import 'package:minq/l10n/app_localizations.dart';
  import 'package:minq/presentation/theme/minq_tokens.dart';
@@
 class OfflineBanner extends ConsumerWidget {
@@
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