import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:minq/presentation/theme/minq_theme.dart';

/// オフラインバナー
/// ネットワーク接続がない場合に表示
class OfflineBanner extends ConsumerWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // TODO: NetworkStatusService のプロバイダーを作成して使用
    // const isOffline = ref.watch(networkStatusProvider).isOffline;

    final tokens = Theme.of(context).extension<MinqTheme>()!;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: tokens.spacing.md,
        vertical: tokens.spacing.sm,
      ),
      color: tokens.accentWarning,
      child: Row(
        children: [
          Icon(Icons.cloud_off, color: tokens.onPrimary, size: 20),
          SizedBox(width: tokens.spacing.sm),
          Expanded(
            child: Text(
              'オフラインモード - 一部機能が制限されています',
              style: tokens.typography.body.copyWith(color: tokens.onPrimary),
            ),
          ),
          IconButton(
            icon: Icon(Icons.info_outline, color: tokens.onPrimary),
            onPressed: () => _showOfflineInfo(context),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  void _showOfflineInfo(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('オフラインモード'),
            content: const Text(
              'インターネット接続がありません。\n\n'
              '利用可能な機能:\n'
              '• クエストの記録\n'
              '• 進捗の確認\n'
              '• 統計の表示\n\n'
              '制限される機能:\n'
              '• データの同期\n'
              '• ペア機能\n'
              '• 共有機能\n\n'
              'インターネットに接続すると、自動的にデータが同期されます。',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }
}

/// オフライン時の空状態ウィジェット
class OfflineEmptyState extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const OfflineEmptyState({
    this.message = 'オフラインのため表示できません',
    this.onRetry,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<MinqTheme>()!;
    return Center(
      child: Padding(
        padding: EdgeInsets.all(tokens.spacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.cloud_off, size: 80, color: tokens.textMuted),
            SizedBox(height: tokens.spacing.lg),
            Text(
              message,
              textAlign: TextAlign.center,
              style: tokens.typography.body.copyWith(color: tokens.textSecondary),
            ),
            if (onRetry != null) ...[
              SizedBox(height: tokens.spacing.lg),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('再試行'),
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
    final tokens = Theme.of(context).extension<MinqTheme>()!;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: tokens.spacing.sm,
        vertical: tokens.spacing.xs,
      ),
      decoration: BoxDecoration(
        color: tokens.accentWarning.withAlpha(51),
        borderRadius: BorderRadius.circular(tokens.radius.lg),
        border: Border.all(color: tokens.accentWarning.withAlpha(128)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.visibility, size: 16, color: tokens.accentWarning),
          SizedBox(width: tokens.spacing.xs),
          Text(
            '読み取り専用',
            style: tokens.typography.caption.copyWith(
              color: tokens.accentWarning,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

/// ネットワーク依存機能の無効化ラッパー
class NetworkDependentWidget extends ConsumerWidget {
  final Widget child;
  final Widget? offlineWidget;
  final String? offlineMessage;

  const NetworkDependentWidget({
    required this.child,
    this.offlineWidget,
    this.offlineMessage,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // TODO: NetworkStatusService のプロバイダーを作成して使用
    // const isOffline = ref.watch(networkStatusProvider).isOffline;

    return child;
  }
}

/// オフライン時の機能制限ダイアログ
void showOfflineDialog(BuildContext context) {
  showDialog(
    context: context,
    builder:
        (context) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.cloud_off, color: Colors.orange),
              SizedBox(width: 12),
              Text('オフライン'),
            ],
          ),
          content: const Text(
            'この機能を使用するにはインターネット接続が必要です。\n\n'
            'WiFiまたはモバイルデータに接続してから再度お試しください。',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
  );
}

/// オフライン時のスナックバー
void showOfflineSnackBar(BuildContext context) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: const Row(
        children: [
          Icon(Icons.cloud_off, color: Colors.white),
          SizedBox(width: 12),
          Expanded(child: Text('オフラインのため、この操作は実行できません')),
        ],
      ),
      backgroundColor: Colors.orange[700],
      duration: const Duration(seconds: 3),
      action: SnackBarAction(
        label: '設定',
        textColor: Colors.white,
        onPressed: () {
          // TODO: ネットワーク設定画面へ遷移
        },
      ),
    ),
  );
}
