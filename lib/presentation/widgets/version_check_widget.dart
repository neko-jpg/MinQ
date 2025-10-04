import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:minq/core/version/version_check_service.dart';
import 'package:minq/presentation/screens/version_update_screen.dart';

/// バ�EジョンチェチE��を行い、忁E��に応じて更新画面を表示するウィジェチE��
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
        // 強制アチE�EチE�EチE 戻れなぁE��面を表示
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
        // 推奨アチE�EチE�EチE ダイアログで通知
        await showDialog(
          context: context,
          barrierDismissible: true,
          builder: (context) => AlertDialog(
            title: const Text('新しいバ�EジョンがありまぁE),
            content: Text(
              '新しいバ�Eジョン�E�E{result.recommendedVersion}�E�が利用可能です、En'
              'より快適にご利用ぁE��だくため、アチE�EチE�Eトをおすすめします、E,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('後で'),
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
                child: const Text('詳細を見る'),
              ),
            ],
          ),
        );
        break;

      case VersionSupported():
      case VersionCheckError():
        // 何もしなぁE
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
