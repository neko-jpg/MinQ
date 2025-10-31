import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:minq/core/sync/sync_queue_manager.dart';
import 'package:minq/presentation/providers/profile_providers.dart';
import 'package:minq/presentation/theme/minq_theme.dart';
import 'package:minq/presentation/theme/theme_extensions.dart';

/// Widget to display profile sync status
class SyncStatusWidget extends ConsumerWidget {
  const SyncStatusWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.tokens;
    final syncStatusAsync = ref.watch(profileSyncStatusProvider);

    return syncStatusAsync.when(
      data: (status) => _buildSyncStatus(context, tokens, status),
      loading: () => _buildLoadingStatus(tokens),
      error: (error, _) => _buildErrorStatus(tokens),
    );
  }

  Widget _buildSyncStatus(BuildContext context, MinqTheme tokens, SyncQueueStatus status) {
    if (status.isIdle && status.isOnline) {
      return _buildSyncedStatus(tokens);
    }
    
    if (!status.isOnline) {
      return _buildOfflineStatus(tokens);
    }
    
    if (status.isProcessing || status.syncingJobs > 0) {
      return _buildSyncingStatus(tokens, status);
    }
    
    if (status.pendingJobs > 0) {
      return _buildPendingStatus(tokens, status);
    }
    
    if (status.failedJobs > 0) {
      return _buildFailedStatus(context, tokens, status);
    }
    
    return _buildSyncedStatus(tokens);
  }

  Widget _buildSyncedStatus(MinqTheme tokens) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: tokens.spacing.sm,
        vertical: tokens.spacing.xs,
      ),
      decoration: BoxDecoration(
        color: tokens.success.withOpacity(0.1),
        borderRadius: BorderRadius.circular(tokens.radius.sm),
        border: Border.all(color: tokens.success.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.cloud_done,
            size: 16,
            color: tokens.success,
          ),
          SizedBox(width: tokens.spacing.xs),
          Text(
            '同期済み',
            style: tokens.typography.caption.copyWith(
              color: tokens.success,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSyncingStatus(MinqTheme tokens, SyncQueueStatus status) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: tokens.spacing.sm,
        vertical: tokens.spacing.xs,
      ),
      decoration: BoxDecoration(
        color: tokens.info.withOpacity(0.1),
        borderRadius: BorderRadius.circular(tokens.radius.sm),
        border: Border.all(color: tokens.info.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(tokens.info),
            ),
          ),
          SizedBox(width: tokens.spacing.xs),
          Text(
            '同期中...',
            style: tokens.typography.caption.copyWith(
              color: tokens.info,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPendingStatus(MinqTheme tokens, SyncQueueStatus status) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: tokens.spacing.sm,
        vertical: tokens.spacing.xs,
      ),
      decoration: BoxDecoration(
        color: tokens.warning.withOpacity(0.1),
        borderRadius: BorderRadius.circular(tokens.radius.sm),
        border: Border.all(color: tokens.warning.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.schedule,
            size: 16,
            color: tokens.warning,
          ),
          SizedBox(width: tokens.spacing.xs),
          Text(
            '同期待ち (${status.pendingJobs})',
            style: tokens.typography.caption.copyWith(
              color: tokens.warning,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFailedStatus(BuildContext context, MinqTheme tokens, SyncQueueStatus status) {
    return GestureDetector(
      onTap: () => _showSyncErrorDialog(context, status),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: tokens.spacing.sm,
          vertical: tokens.spacing.xs,
        ),
        decoration: BoxDecoration(
          color: tokens.error.withOpacity(0.1),
          borderRadius: BorderRadius.circular(tokens.radius.sm),
          border: Border.all(color: tokens.error.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: 16,
              color: tokens.error,
            ),
            SizedBox(width: tokens.spacing.xs),
            Text(
              '同期エラー (${status.failedJobs})',
              style: tokens.typography.caption.copyWith(
                color: tokens.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOfflineStatus(MinqTheme tokens) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: tokens.spacing.sm,
        vertical: tokens.spacing.xs,
      ),
      decoration: BoxDecoration(
        color: tokens.textMuted.withOpacity(0.1),
        borderRadius: BorderRadius.circular(tokens.radius.sm),
        border: Border.all(color: tokens.textMuted.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.cloud_off,
            size: 16,
            color: tokens.textMuted,
          ),
          SizedBox(width: tokens.spacing.xs),
          Text(
            'オフライン',
            style: tokens.typography.caption.copyWith(
              color: tokens.textMuted,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingStatus(MinqTheme tokens) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: tokens.spacing.sm,
        vertical: tokens.spacing.xs,
      ),
      decoration: BoxDecoration(
        color: tokens.surfaceVariant,
        borderRadius: BorderRadius.circular(tokens.radius.sm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(tokens.textMuted),
            ),
          ),
          SizedBox(width: tokens.spacing.xs),
          Text(
            '読み込み中...',
            style: tokens.typography.caption.copyWith(
              color: tokens.textMuted,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorStatus(MinqTheme tokens) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: tokens.spacing.sm,
        vertical: tokens.spacing.xs,
      ),
      decoration: BoxDecoration(
        color: tokens.error.withOpacity(0.1),
        borderRadius: BorderRadius.circular(tokens.radius.sm),
        border: Border.all(color: tokens.error.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.error,
            size: 16,
            color: tokens.error,
          ),
          SizedBox(width: tokens.spacing.xs),
          Text(
            'ステータス取得エラー',
            style: tokens.typography.caption.copyWith(
              color: tokens.error,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  void _showSyncErrorDialog(BuildContext context, SyncQueueStatus status) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('同期エラー'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${status.failedJobs}件の同期に失敗しました。'),
            const SizedBox(height: 16),
            const Text('ネットワーク接続を確認して、再試行してください。'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('閉じる'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Retry failed sync jobs
              // This would need to be implemented in the sync queue manager
            },
            child: const Text('再試行'),
          ),
        ],
      ),
    );
  }
}

/// Compact version of sync status for use in app bars or small spaces
class CompactSyncStatusWidget extends ConsumerWidget {
  const CompactSyncStatusWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.tokens;
    final syncStatusAsync = ref.watch(profileSyncStatusProvider);

    return syncStatusAsync.when(
      data: (status) => _buildCompactStatus(tokens, status),
      loading: () => Icon(Icons.sync, size: 20, color: tokens.textMuted),
      error: (error, _) => Icon(Icons.sync_problem, size: 20, color: tokens.error),
    );
  }

  Widget _buildCompactStatus(MinqTheme tokens, SyncQueueStatus status) {
    if (!status.isOnline) {
      return Icon(Icons.cloud_off, size: 20, color: tokens.textMuted);
    }
    
    if (status.isProcessing || status.syncingJobs > 0) {
      return SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(tokens.info),
        ),
      );
    }
    
    if (status.failedJobs > 0) {
      return Icon(Icons.sync_problem, size: 20, color: tokens.error);
    }
    
    if (status.pendingJobs > 0) {
      return Icon(Icons.schedule, size: 20, color: tokens.warning);
    }
    
    return Icon(Icons.cloud_done, size: 20, color: tokens.success);
  }
}