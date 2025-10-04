import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:minq/core/network/network_status_service.dart';
import 'package:minq/presentation/theme/minq_theme.dart';

/// オフラインモードインジケーター
class OfflineModeIndicator extends ConsumerWidget {
  final Widget child;

  const OfflineModeIndicator({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOnlineAsync = ref.watch(networkStatusProvider);
    final isOnline = isOnlineAsync.valueOrNull ?? true;
    final tokens = context.tokens;

    return Stack(
      children: [
        // メインコンチE��チE��オフライン時�E半透�E�E�E
        Opacity(
          opacity: isOnline ? 1.0 : 0.7,
          child: child,
        ),
        // オフラインバナー
        if (!isOnline)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Semantics(
              container: true,
              liveRegion: true,
              label: 'オフラインモーチE 読み取り専用',
              child: Material(
                color: Colors.orange,
                child: Padding(
                  padding: EdgeInsets.all(tokens.spacing(2)),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.cloud_off,
                        color: Colors.white,
                        size: 20,
                      ),
                      SizedBox(width: tokens.spacing(2)),
                      const Expanded(
                        child: Text(
                          'オフラインモード（読み取り専用�E�E,
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          // 再接続を試みめE
                        },
                        child: const Text(
                          '再接綁E,
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// 読み取り専用モードラチE��ー
class ReadOnlyModeWrapper extends ConsumerWidget {
  final Widget child;
  final VoidCallback? onTap;

  const ReadOnlyModeWrapper({
    super.key,
    required this.child,
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOnlineAsync = ref.watch(networkStatusProvider);
    final isOnline = isOnlineAsync.valueOrNull ?? true;

    if (!isOnline) {
      return AbsorbPointer(
        child: Opacity(
          opacity: 0.5,
          child: child,
        ),
      );
    }

    return child;
  }
}
