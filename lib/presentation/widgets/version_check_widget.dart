import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:minq/core/version/version_check_service.dart';
import 'package:minq/presentation/screens/version_update_screen.dart';

/// 繝舌・繧ｸ繝ｧ繝ｳ繝√ぉ繝・け繧定｡後＞縲∝ｿ・ｦ√↓蠢懊§縺ｦ譖ｴ譁ｰ逕ｻ髱｢繧定｡ｨ遉ｺ縺吶ｋ繧ｦ繧｣繧ｸ繧ｧ繝・ヨ
class VersionCheckWidget extends ConsumerStatefulWidget {
  final Widget child;

  const VersionCheckWidget({
    super.key,
    required this.child,
  });

  @override
  ConsumerState<VersionCheckWidget> createState() => _VersionCheckWidgetState();
}

class _VersionCheckWidgetState extends ConsumerState<VersionCheckWidget> {
  bool _hasChecked = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkVersion();
    });
  }

  Future<void> _checkVersion() async {
    if (_hasChecked || !mounted) return;
    _hasChecked = true;

    final result = await ref.read(versionCheckProvider.future);

    if (!mounted) return;

    switch (result) {
      case VersionForceUpdate():
        // 蠑ｷ蛻ｶ繧｢繝・・繝・・繝・ 謌ｻ繧後↑縺・判髱｢繧定｡ｨ遉ｺ
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => VersionUpdateScreen(
              result: result,
              canDismiss: false,
            ),
          ),
        );
        break;

      case VersionUpdateAvailable():
        // 謗ｨ螂ｨ繧｢繝・・繝・・繝・ 繝繧､繧｢繝ｭ繧ｰ縺ｧ騾夂衍
        await showDialog(
          context: context,
          barrierDismissible: true,
          builder: (context) => AlertDialog(
            title: const Text('譁ｰ縺励＞繝舌・繧ｸ繝ｧ繝ｳ縺後≠繧翫∪縺・),
            content: Text(
              '譁ｰ縺励＞繝舌・繧ｸ繝ｧ繝ｳ・・{result.recommendedVersion}・峨′蛻ｩ逕ｨ蜿ｯ閭ｽ縺ｧ縺吶・n'
              '繧医ｊ蠢ｫ驕ｩ縺ｫ縺泌茜逕ｨ縺・◆縺縺上◆繧√√い繝・・繝・・繝医ｒ縺翫☆縺吶ａ縺励∪縺吶・,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('蠕後〒'),
              ),
              FilledButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => VersionUpdateScreen(
                        result: result,
                        canDismiss: true,
                      ),
                    ),
                  );
                },
                child: const Text('隧ｳ邏ｰ繧定ｦ九ｋ'),
              ),
            ],
          ),
        );
        break;

      case VersionSupported():
      case VersionCheckError():
        // 菴輔ｂ縺励↑縺・
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
