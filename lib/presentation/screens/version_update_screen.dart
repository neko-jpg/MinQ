import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:minq/core/version/version_check_service.dart';
import 'package:minq/presentation/theme/minq_theme.dart';
import 'package:url_launcher/url_launcher.dart';

/// バ�Eジョン更新画面
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
            padding: EdgeInsets.all(tokens.spacing(4)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.system_update,
                  size: 80,
                  color: tokens.brandPrimary,
                ),
                SizedBox(height: tokens.spacing(6)),
                Text(
                  _getTitle(result),
                  style: tokens.titleLarge,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: tokens.spacing(3)),
                Text(
                  _getMessage(result),
                  style: tokens.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: tokens.spacing(6)),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _openStore(),
                    child: const Text('アチE�EチE�EトすめE),
                  ),
                ),
                if (canDismiss) ...[
                  SizedBox(height: tokens.spacing(3)),
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
      VersionForceUpdate() => '更新が忁E��でぁE,
      VersionUpdateAvailable() => '新しいバ�EジョンがありまぁE,
      _ => 'アチE�EチE�EチE,
    };
  }

  String _getMessage(VersionCheckResult result) {
    return switch (result) {
      VersionForceUpdate(:final currentVersion, :final minVersion) =>
        'こ�Eバ�Eジョン�E�EcurrentVersion�E��Eサポ�Eトが終亁E��ました、En'
        '最新バ�Eジョン�E�EminVersion以上）にアチE�EチE�Eトしてください、E,
      VersionUpdateAvailable(:final currentVersion, :final recommendedVersion) =>
        '新しいバ�Eジョン�E�ErecommendedVersion�E�が利用可能です、En'
        'より快適にご利用ぁE��だくため、アチE�EチE�Eトをおすすめします、E,
      _ => '最新バ�EジョンにアチE�EチE�Eトしてください、E,
    };
  }

  Future<void> _openStore() async {
    // TODO: プラチE��フォームに応じてストアURLを変更
    final url = Uri.parse('https://play.google.com/store/apps/details?id=com.example.minq');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }
}
