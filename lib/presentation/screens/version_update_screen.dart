import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:minq/core/version/version_check_service.dart';
import 'package:minq/presentation/theme/minq_theme.dart';
import 'package:url_launcher/url_launcher.dart';

/// 繝舌・繧ｸ繝ｧ繝ｳ譖ｴ譁ｰ逕ｻ髱｢
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
                    child: const Text('繧｢繝・・繝・・繝医☆繧・),
                  ),
                ),
                if (canDismiss) ...[
                  SizedBox(height: tokens.spacing(3)),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('蠕後〒'),
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
      VersionForceUpdate() => '譖ｴ譁ｰ縺悟ｿ・ｦ√〒縺・,
      VersionUpdateAvailable() => '譁ｰ縺励＞繝舌・繧ｸ繝ｧ繝ｳ縺後≠繧翫∪縺・,
      _ => '繧｢繝・・繝・・繝・,
    };
  }

  String _getMessage(VersionCheckResult result) {
    return switch (result) {
      VersionForceUpdate(:final currentVersion, :final minVersion) =>
        '縺薙・繝舌・繧ｸ繝ｧ繝ｳ・・currentVersion・峨・繧ｵ繝昴・繝医′邨ゆｺ・＠縺ｾ縺励◆縲・n'
        '譛譁ｰ繝舌・繧ｸ繝ｧ繝ｳ・・minVersion莉･荳奇ｼ峨↓繧｢繝・・繝・・繝医＠縺ｦ縺上□縺輔＞縲・,
      VersionUpdateAvailable(:final currentVersion, :final recommendedVersion) =>
        '譁ｰ縺励＞繝舌・繧ｸ繝ｧ繝ｳ・・recommendedVersion・峨′蛻ｩ逕ｨ蜿ｯ閭ｽ縺ｧ縺吶・n'
        '繧医ｊ蠢ｫ驕ｩ縺ｫ縺泌茜逕ｨ縺・◆縺縺上◆繧√√い繝・・繝・・繝医ｒ縺翫☆縺吶ａ縺励∪縺吶・,
      _ => '譛譁ｰ繝舌・繧ｸ繝ｧ繝ｳ縺ｫ繧｢繝・・繝・・繝医＠縺ｦ縺上□縺輔＞縲・,
    };
  }

  Future<void> _openStore() async {
    // TODO: 繝励Λ繝・ヨ繝輔か繝ｼ繝縺ｫ蠢懊§縺ｦ繧ｹ繝医いURL繧貞､画峩
    final url = Uri.parse('https://play.google.com/store/apps/details?id=com.example.minq');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }
}
