import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:minq/core/network/network_status_provider.dart';
import 'package:minq/core/sync/sync_providers.dart';
import 'package:minq/core/sync/sync_queue_manager.dart';
import 'package:minq/data/providers.dart';
import 'package:minq/l10n/app_localizations.dart';
import 'package:minq/presentation/theme/minq_theme.dart';

/// オフラインバナー
/// ネットワーク接続がなぁE��合に表示
class OfflineBanner extends ConsumerWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(networkStatusProvider);
    if (!status.isOffline) {
      return const SizedBox.shrink();
    }

    final tokens = context.tokens;
    final l10n = AppLocalizations.of(context);

    return Semantics(
      container: true,
      liveRegion: true,
      label: l10n.offlineModeBanner,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(
          horizontal: tokens.spacing.lg,
          vertical: tokens.spacing.sm,
        ),
        color: tokens.accentWarning,
        child: Row(
          children: [
            Icon(Icons.cloud_off, color: tokens.primaryForeground, size: 20),
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
            IconButton(
              icon: Icon(Icons.info_outline, color: tokens.primaryForeground),
              onPressed: () => _showOfflineInfo(context),
              tooltip: l10n.offlineMode,
              splashRadius: 20,
            ),
          ],
        ),
      ),
    );
  }

  void _showOfflineInfo(BuildContext context) {
    final tokens = context.tokens;
    final l10n = AppLocalizations.of(context);

    showDialog<void>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Row(
              children: [
                Icon(Icons.cloud_off, color: tokens.accentWarning),
                SizedBox(width: tokens.spacing.sm),
                Text(l10n.offlineMode),
              ],
            ),
            content: Text(l10n.noInternetConnection),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(l10n.ok),
              ),
            ],
          ),
    );
  }
}

/// オフライン時�E空状態ウィジェチE��
class OfflineEmptyState extends StatelessWidget {
  const OfflineEmptyState({this.message, this.onRetry, super.key});

  final String? message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final l10n = AppLocalizations.of(context);

    return Center(
      child: Padding(
        padding: EdgeInsets.all(tokens.spacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.cloud_off, size: 80, color: tokens.textSecondary),
            SizedBox(height: tokens.spacing.lg),
            Text(
              message ?? l10n.offlineOperationNotAvailable,
              textAlign: TextAlign.center,
              style: tokens.typography.bodyMedium.copyWith(
                color: tokens.textSecondary,
              ),
            ),
            if (onRetry != null) ...[
              SizedBox(height: tokens.spacing.lg),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: Text(l10n.retry),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// 読み取り専用モードインジケーター
class ReadOnlyModeIndicator extends StatelessWidget {
  const ReadOnlyModeIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final l10n = AppLocalizations.of(context);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: tokens.spacing.sm,
        vertical: tokens.spacing.xs,
      ),
      decoration: BoxDecoration(
        color: tokens.accentWarning.withOpacity(0.12),
        borderRadius: BorderRadius.circular(tokens.radius.md),
        border: Border.all(color: tokens.accentWarning.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.visibility, size: 16, color: tokens.accentWarning),
          SizedBox(width: tokens.spacing.xs),
          Text(
            l10n.readOnlyLabel,
            style: tokens.typography.bodySmall.copyWith(
              color: tokens.accentWarning,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

/// ネットワーク依存機�Eの無効化ラチE��ー
class NetworkDependentWidget extends ConsumerWidget {
  const NetworkDependentWidget({
    required this.child,
    this.offlineWidget,
    this.offlineMessage,
    super.key,
  });

  final Widget child;
  final Widget? offlineWidget;
  final String? offlineMessage;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(networkStatusProvider);
    if (!status.isOffline) {
      return child;
    }

    if (offlineWidget != null) {
      return offlineWidget!;
    }

    return OfflineEmptyState(message: offlineMessage);
  }
}

/// オフライン時�E機�E制限ダイアログ
void showOfflineDialog(BuildContext context) {
  final tokens = context.tokens;
  final l10n = AppLocalizations.of(context);

  showDialog<void>(
    context: context,
    builder:
        (context) => AlertDialog(
          title: Row(
            children: [
              Icon(Icons.cloud_off, color: tokens.accentWarning),
              SizedBox(width: tokens.spacing.sm),
              Text(l10n.offline),
            ],
          ),
          content: Text(l10n.noInternetConnection),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.ok),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                // TODO: Provide navigation to network settings when available.
              },
              child: Text(l10n.openSettings),
            ),
          ],
        ),
  );
}

/// オフライン時�Eスナックバ�E
void showOfflineSnackBar(BuildContext context) {
  final tokens = context.tokens;
  final l10n = AppLocalizations.of(context);

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Row(
        children: [
          Icon(Icons.cloud_off, color: tokens.primaryForeground),
          SizedBox(width: tokens.spacing.sm),
          Expanded(child: Text(l10n.offlineOperationNotAvailable)),
        ],
      ),
      backgroundColor: tokens.accentWarning,
      duration: const Duration(seconds: 3),
      action: SnackBarAction(
        label: l10n.openSettings,
        textColor: tokens.primaryForeground,
        onPressed: () {
          // TODO: ネットワーク設定画面へ遷移
        },
      ),
    ),
  );
}

/// Sync status indicator widget
class SyncStatusWidget extends ConsumerWidget {
  const SyncStatusWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final networkStatus = ref.watch(networkStatusProvider);
    final tokens = context.tokens;
    final l10n = AppLocalizations.of(context);

    return StreamBuilder<SyncStatus>(
      stream: ref.read(syncQueueManagerProvider).statusStream,
      builder: (context, snapshot) {
        final syncStatus = snapshot.data ?? SyncStatus.synced;

        if (networkStatus == NetworkStatus.offline) {
          return _buildOfflineIndicator(context, tokens, l10n);
        }

        switch (syncStatus) {
          case SyncStatus.syncing:
            return _buildSyncingIndicator(context, tokens, l10n);
          case SyncStatus.pending:
            return _buildPendingIndicator(context, tokens, l10n);
          case SyncStatus.failed:
            return _buildFailedIndicator(context, tokens, l10n);
          case SyncStatus.conflict:
            return _buildConflictIndicator(context, tokens, l10n);
          case SyncStatus.synced:
          default:
            return const SizedBox.shrink();
        }
      },
    );
  }

  Widget _buildOfflineIndicator(
    BuildContext context,
    MinqTheme tokens,
    AppLocalizations l10n,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: tokens.accentWarning,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.cloud_off, color: tokens.primaryForeground, size: 14),
          const SizedBox(width: 4),
          Text(
            l10n.offlineMode,
            style: TextStyle(
              color: tokens.primaryForeground,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSyncingIndicator(
    BuildContext context,
    MinqTheme tokens,
    AppLocalizations l10n,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: tokens.accentSecondary,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 14,
            height: 14,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                tokens.primaryForeground,
              ),
            ),
          ),
          const SizedBox(width: 4),
          Text(
            'Syncing...', // TODO: Add to l10n
            style: TextStyle(
              color: tokens.primaryForeground,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPendingIndicator(
    BuildContext context,
    MinqTheme tokens,
    AppLocalizations l10n,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: tokens.accentWarning,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.sync_problem, color: tokens.primaryForeground, size: 14),
          const SizedBox(width: 4),
          Text(
            'Sync Pending', // TODO: Add to l10n
            style: TextStyle(
              color: tokens.primaryForeground,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFailedIndicator(
    BuildContext context,
    MinqTheme tokens,
    AppLocalizations l10n,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: tokens.accentError,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.sync_disabled, color: tokens.primaryForeground, size: 14),
          const SizedBox(width: 4),
          Text(
            'Sync Failed', // TODO: Add to l10n
            style: TextStyle(
              color: tokens.primaryForeground,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConflictIndicator(
    BuildContext context,
    MinqTheme tokens,
    AppLocalizations l10n,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: tokens.accentError,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.warning, color: tokens.primaryForeground, size: 14),
          const SizedBox(width: 4),
          Text(
            'Sync Conflict', // TODO: Add to l10n
            style: TextStyle(
              color: tokens.primaryForeground,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
