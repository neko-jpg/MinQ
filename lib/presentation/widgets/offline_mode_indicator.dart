import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:minq/core/network/network_status_service.dart';
import 'package:minq/presentation/theme/minq_theme.dart';

/// 繧ｪ繝輔Λ繧､繝ｳ繝｢繝ｼ繝峨う繝ｳ繧ｸ繧ｱ繝ｼ繧ｿ繝ｼ
class OfflineModeIndicator extends ConsumerWidget {
  final Widget child;

  const OfflineModeIndicator({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOnline = ref.watch(networkStatusProvider);
    final tokens = context.tokens;

    return Stack(
      children: [
        // 繝｡繧､繝ｳ繧ｳ繝ｳ繝・Φ繝・ｼ医が繝輔Λ繧､繝ｳ譎ゅ・蜊企乗・・・
        Opacity(
          opacity: isOnline ? 1.0 : 0.7,
          child: child,
        ),
        // 繧ｪ繝輔Λ繧､繝ｳ繝舌リ繝ｼ
        if (!isOnline)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Semantics(
              container: true,
              liveRegion: true,
              label: '繧ｪ繝輔Λ繧､繝ｳ繝｢繝ｼ繝・ 隱ｭ縺ｿ蜿悶ｊ蟆ら畑',
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
                          '繧ｪ繝輔Λ繧､繝ｳ繝｢繝ｼ繝会ｼ郁ｪｭ縺ｿ蜿悶ｊ蟆ら畑・・,
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          // 蜀肴磁邯壹ｒ隧ｦ縺ｿ繧・
                        },
                        child: const Text(
                          '蜀肴磁邯・,
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

/// 隱ｭ縺ｿ蜿悶ｊ蟆ら畑繝｢繝ｼ繝峨Λ繝・ヱ繝ｼ
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
    final isOnline = ref.watch(networkStatusProvider);

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
