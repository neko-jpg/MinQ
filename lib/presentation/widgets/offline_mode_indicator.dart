import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:minq/data/providers.dart';
import 'package:minq/l10n/app_localizations.dart';
import 'package:minq/presentation/theme/minq_theme.dart';
import 'package:minq/presentation/widgets/offline_banner.dart';

/// オフラインモードインジケーター
class OfflineModeIndicator extends ConsumerWidget {
  const OfflineModeIndicator({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(networkStatusProvider);
    final tokens = context.tokens;
    final l10n = AppLocalizations.of(context)!;

    return Stack(
      children: [
        Opacity(
          opacity: status.isOnline ? 1 : 0.7,
          child: child,
        ),
        if (status.isOffline)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Semantics(
              container: true,
              liveRegion: true,
              label: l10n.offlineModeBanner,
              child: Material(
                color: tokens.accentWarning,
                child: Padding(
                  padding: EdgeInsets.all(tokens.spacing.sm),
                  child: Row(
                    children: [
                      Icon(
                        Icons.cloud_off,
                        color: tokens.primaryForeground,
                        size: 20,
                      ),
                      SizedBox(width: tokens.spacing.sm),
                      Expanded(
                        child: Text(
                          l10n.offlineModeBanner,
                          style: tokens.typography.bodyMedium.copyWith(
                            color: tokens.primaryForeground,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () => showOfflineDialog(context),
                        child: Text(
                          l10n.retry,
                          style: tokens.typography.bodySmall.copyWith(
                            color: tokens.primaryForeground,
                            fontWeight: FontWeight.w600,
                          ),
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
  const ReadOnlyModeWrapper({super.key, required this.child, this.onTap});

  final Widget child;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(networkStatusProvider);

    if (!status.isOnline) {
      return AbsorbPointer(child: Opacity(opacity: 0.5, child: child));
    }

    if (onTap == null) {
      return child;
    }

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: onTap,
      child: child,
    );
  }
}
