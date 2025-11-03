import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:minq/presentation/theme/minq_tokens.dart';

/// Indicator widget to show offline status
class OfflineIndicator extends ConsumerWidget {
  const OfflineIndicator({
    super.key,
    this.size = 20.0,
    this.showLabel = false,
    this.color,
  });

  final double size;
  final bool showLabel;
  final Color? color;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final indicatorColor = color ?? MinqTokens.accentWarning;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: indicatorColor.withAlpha((255 * 0.2).round()),
            borderRadius: BorderRadius.circular(size / 2),
            border: Border.all(color: indicatorColor, width: 1.5),
          ),
          child: Icon(Icons.cloud_off, size: size * 0.6, color: indicatorColor),
        ),
        if (showLabel) ...[
          SizedBox(width: MinqTokens.spacing(1)),
          Text(
            'オフライン',
            style: MinqTokens.bodySmall.copyWith(
              color: indicatorColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }
}

/// Banner widget to show offline status at the top of screens
class OfflineBanner extends ConsumerWidget {
  const OfflineBanner({
    super.key,
    this.message = 'オフラインモードです。変更は接続時に同期されます。',
    this.showSyncButton = true,
    this.onSyncPressed,
  });

  final String message;
  final bool showSyncButton;
  final VoidCallback? onSyncPressed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: MinqTokens.spacing(4),
        vertical: MinqTokens.spacing(2),
      ),
      decoration: BoxDecoration(
        color: MinqTokens.accentWarning,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((255 * 0.1).round()),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.cloud_off, color: MinqTokens.primaryForeground, size: 20),
          SizedBox(width: MinqTokens.spacing(2)),
          Expanded(
            child: Text(
              message,
              style: MinqTokens.bodySmall.copyWith(
                color: MinqTokens.primaryForeground,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          if (showSyncButton && onSyncPressed != null) ...[
            SizedBox(width: MinqTokens.spacing(2)),
            TextButton(
              onPressed: onSyncPressed,
              style: TextButton.styleFrom(
                foregroundColor: MinqTokens.primaryForeground,
                padding: EdgeInsets.symmetric(
                  horizontal: MinqTokens.spacing(2),
                  vertical: MinqTokens.spacing(1),
                ),
              ),
              child: Text(
                '同期',
                style: MinqTokens.bodySmall.copyWith(
                  color: MinqTokens.primaryForeground,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Sync status indicator with different states
class SyncStatusIndicator extends ConsumerWidget {
  const SyncStatusIndicator({
    super.key,
    required this.status,
    this.size = 16.0,
    this.showLabel = false,
  });

  final SyncStatus status;
  final double size;
  final bool showLabel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = _getSyncStatusConfig(status);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: config.color.withAlpha((255 * 0.2).round()),
            borderRadius: BorderRadius.circular(size / 2),
          ),
          child:
              status == SyncStatus.syncing
                  ? SizedBox(
                    width: size * 0.6,
                    height: size * 0.6,
                    child: CircularProgressIndicator(
                      strokeWidth: 1.5,
                      valueColor: AlwaysStoppedAnimation(config.color),
                    ),
                  )
                  : Icon(config.icon, size: size * 0.6, color: config.color),
        ),
        if (showLabel) ...[
          SizedBox(width: MinqTokens.spacing(1)),
          Text(
            config.label,
            style: MinqTokens.bodySmall.copyWith(
              color: config.color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }

  _SyncStatusConfig _getSyncStatusConfig(SyncStatus status) {
    switch (status) {
      case SyncStatus.synced:
        return const _SyncStatusConfig(
          icon: Icons.cloud_done,
          color: Colors.green,
          label: '同期済み',
        );
      case SyncStatus.pending:
        return const _SyncStatusConfig(
          icon: Icons.cloud_queue,
          color: Colors.orange,
          label: '同期待ち',
        );
      case SyncStatus.syncing:
        return const _SyncStatusConfig(
          icon: Icons.cloud_sync,
          color: Colors.blue,
          label: '同期中',
        );
      case SyncStatus.failed:
        return const _SyncStatusConfig(
          icon: Icons.cloud_off,
          color: Colors.red,
          label: '同期失敗',
        );
      case SyncStatus.conflict:
        return const _SyncStatusConfig(
          icon: Icons.warning,
          color: Colors.amber,
          label: '競合',
        );
    }
  }
}

class _SyncStatusConfig {
  final IconData icon;
  final Color color;
  final String label;

  const _SyncStatusConfig({
    required this.icon,
    required this.color,
    required this.label,
  });
}

/// Enum for sync status (should match the one in local models)
enum SyncStatus {
  synced, // Successfully synced with server
  pending, // Waiting to be synced
  syncing, // Currently being synced
  failed, // Sync failed
  conflict, // Conflict detected, needs resolution
}
