import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:minq/l10n/app_localizations.dart';
import 'package:minq/presentation/theme/minq_tokens.dart';

/// オフラインバナー
/// ネットワーク接続がない場合に表示
class OfflineBanner extends ConsumerWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // TODO: NetworkStatusService のプロバイダーを作成して使用
    // const isOffline = ref.watch(networkStatusProvider).isOffline;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: MinqTokens.spacing(4),
        vertical: MinqTokens.spacing(2),
      ),
      color: Colors.orange,
      child: Row(
        children: [
          const Icon(Icons.cloud_off, color: Colors.white, size: 20),
          SizedBox(width: MinqTokens.spacing(2)),
          Expanded(
            child: Text(
              'オフラインモード - 一部機能が制限されています',
              style: MinqTokens.bodyMedium.copyWith(color: Colors.white),
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
      builder:
          (context) => AlertDialog(
            title: Text(AppLocalizations.of(context)!.offlineMode),
            content: Text(AppLocalizations.of(context)!.noInternetConnection),
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
        padding: EdgeInsets.all(MinqTokens.spacing(6)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.cloud_off, size: 80, color: MinqTokens.textSecondary),
            SizedBox(height: MinqTokens.spacing(4)),
            Text(
              message,
              textAlign: TextAlign.center,
              style: MinqTokens.bodyMedium.copyWith(color: MinqTokens.textSecondary),
            ),
            if (onRetry != null) ...[
              SizedBox(height: MinqTokens.spacing(4)),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
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
      padding: EdgeInsets.symmetric(
        horizontal: MinqTokens.spacing(2),
        vertical: MinqTokens.spacing(1),
      ),
      decoration: BoxDecoration(
        color: Colors.orange.withAlpha(51),
        borderRadius: MinqTokens.cornerLarge(),
        border: Border.all(color: Colors.orange.withAlpha(128)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.visibility, size: 16, color: Colors.orange),
          SizedBox(width: MinqTokens.spacing(1)),
          Text(
            '読み取り専用',
            style: MinqTokens.bodySmall.copyWith(
              color: Colors.orange,
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
          title: Row(
            children: [
              const Icon(Icons.cloud_off, color: Colors.orange),
              const SizedBox(width: 12),
              Text(AppLocalizations.of(context)!.offline),
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
      content: Row(
        children: [
          const Icon(Icons.cloud_off, color: Colors.white),
          const SizedBox(width: 12),
          Expanded(child: Text(AppLocalizations.of(context)!.offlineOperationNotAvailable)),
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
