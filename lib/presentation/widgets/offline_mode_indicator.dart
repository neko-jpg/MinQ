import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:minq/data/providers.dart';
import 'package:minq/presentation/theme/minq_tokens.dart';

/// オフラインモードインジケーター
class OfflineModeIndicator extends ConsumerWidget {
  final Widget child;

  const OfflineModeIndicator({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    return Stack(
      children: [
        // メインコンテンツ（オフライン時は半透明）
        Opacity(
            opacity: ref.watch(networkStatusProvider).isOnline ? 1.0 : 0.7,
            child: child),
        // オフラインバナー
        if (!ref.watch(networkStatusProvider).isOnline)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Semantics(
              container: true,
              liveRegion: true,
              label: 'オフラインモード: 読み取り専用',
              child: Material(
                color: Colors.orange,
                child: Padding(
                  padding: EdgeInsets.all(MinqTokens.spacing(2)),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.cloud_off,
                        color: Colors.white,
                        size: 20,
                      ),
                      SizedBox(width: MinqTokens.spacing(2)),
                      const Expanded(
                        child: Text(
                          'オフラインモード（読み取り専用）',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          // 再接続を試みる
                        },
                        child: const Text(
                          '再接続',
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

/// 読み取り専用モードラッパー
class ReadOnlyModeWrapper extends ConsumerWidget {
  final Widget child;
  final VoidCallback? onTap;

  const ReadOnlyModeWrapper({super.key, required this.child, this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOnline = ref.watch(networkStatusProvider).isOnline;

    if (!isOnline) {
      return AbsorbPointer(child: Opacity(opacity: 0.5, child: child));
    }

    return child;
  }
}
