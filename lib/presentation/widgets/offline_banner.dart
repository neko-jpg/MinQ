import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// オフラインバナー
/// ネットワーク接続がない場合に表示
class OfflineBanner extends ConsumerWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // TODO: NetworkStatusService のプロバイダーを作成して使用
    const isOffline = false; // ref.watch(networkStatusProvider).isOffline;

    if (!isOffline) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: Colors.orange[700],
      child: Row(
        children: [
          const Icon(
            Icons.cloud_off,
            color: Colors.white,
            size: 20,
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'オフラインモード - 一部機能が制限されています',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.info_outline, color: Colors.white),
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
      builder: (context) => AlertDialog(
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
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.cloud_off,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 24),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 24),
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.orange[100],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.orange[300]!),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.visibility,
            size: 16,
            color: Colors.orange[700],
          ),
          const SizedBox(width: 6),
          Text(
            '読み取り専用',
            style: TextStyle(
              fontSize: 12,
              color: Colors.orange[700],
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
    const isOffline = false; // ref.watch(networkStatusProvider).isOffline;

    if (isOffline) {
      return offlineWidget ??
          OfflineEmptyState(
            message: offlineMessage ?? 'この機能はオフラインでは利用できません',
          );
    }

    return child;
  }
}

/// オフライン時の機能制限ダイアログ
void showOfflineDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
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
          Expanded(
            child: Text('オフラインのため、この操作は実行できません'),
          ),
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
