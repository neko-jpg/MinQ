import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:minq/core/version/version_check_service.dart';
import 'package:minq/presentation/theme/minq_theme.dart';
import 'package:url_launcher/url_launcher.dart';

/// バージョン更新画面
class VersionUpdateScreen extends ConsumerWidget {
  final VersionCheckResult result;
  final bool canDismiss;

  const VersionUpdateScreen({
    super.key,
    required this.result,
    this.canDismiss = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.tokens;

    return PopScope(
      canPop: canDismiss,
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(tokens.spacing.lg),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.system_update, size: 80, color: tokens.brandPrimary),
                SizedBox(height: tokens.spacing.xl),
                Text(
                  _getTitle(result),
                  style: tokens.typography.h2,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: tokens.spacing.md),
                Text(
                  _getMessage(result),
                  style: tokens.typography.body,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: tokens.spacing.xl),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _openStore(),
                    child: const Text('アップデートする'),
                  ),
                ),
                if (canDismiss) ...[
                  SizedBox(height: tokens.spacing.md),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('後で'),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getTitle(VersionCheckResult result) {
    return switch (result) {
      VersionForceUpdate() => '更新が必要です',
      VersionUpdateAvailable() => '新しいバージョンがあります',
      _ => 'アップデート',
    };
  }

  String _getMessage(VersionCheckResult result) {
    return switch (result) {
      VersionForceUpdate(:final minVersion) =>
        'このバージョンはサポートが終了しました。\n'
            '最新バージョン（$minVersion以上）にアップデートしてください。',
      VersionUpdateAvailable(
        :final recommendedVersion,
      ) =>
        '新しいバージョン（$recommendedVersion）が利用可能です。\n'
            'より快適にご利用いただくため、アップデートをおすすめします。',
      _ => '最新バージョンにアップデートしてください。',
    };
  }

  Future<void> _openStore() async {
    // TODO: プラットフォームに応じてストアURLを変更
    final url = Uri.parse(
      'https://play.google.com/store/apps/details?id=com.example.minq',
    );
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }
}
