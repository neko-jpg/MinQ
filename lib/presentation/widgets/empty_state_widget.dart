import 'package:flutter/material.dart';

import 'package:minq/core/assets/app_icons.dart';
import 'package:minq/presentation/theme/spacing_system.dart';

/// 空状態ウィジェット - 統一されたスタイル
class EmptyStateWidget extends StatelessWidget {
  final IconData? icon;
  final String? title;
  final String? message;
  final Widget? illustration;
  final Widget? action;
  final EmptyStateType type;

  const EmptyStateWidget({
    super.key,
    this.icon,
    this.title,
    this.message,
    this.illustration,
    this.action,
    this.type = EmptyStateType.general,
  });

  /// クエストが空の状態
  factory EmptyStateWidget.emptyQuests({VoidCallback? onCreateQuest}) {
    return EmptyStateWidget(
      type: EmptyStateType.quests,
      icon: AppIcons.questOutlined,
      title: 'クエストがありません',
      message: '最初のクエストを作成して\n習慣づくりを始めましょう',
      action:
          onCreateQuest != null
              ? ElevatedButton.icon(
                onPressed: onCreateQuest,
                icon: const Icon(AppIcons.add),
                label: const Text('クエストを作成'),
              )
              : null,
    );
  }

  /// ログが空の状態
  factory EmptyStateWidget.emptyLogs({VoidCallback? onStartLogging}) {
    return EmptyStateWidget(
      type: EmptyStateType.logs,
      icon: AppIcons.calendar,
      title: 'まだ記録がありません',
      message: 'クエストを完了して\n進捗を記録しましょう',
      action:
          onStartLogging != null
              ? ElevatedButton(
                onPressed: onStartLogging,
                child: const Text('今日のクエストを見る'),
              )
              : null,
    );
  }

  /// 統計が空の状態
  factory EmptyStateWidget.emptyStats() {
    return const EmptyStateWidget(
      type: EmptyStateType.stats,
      icon: AppIcons.chart,
      title: 'データがありません',
      message: 'クエストを完了すると\n統計が表示されます',
    );
  }

  /// ペアが空の状態
  factory EmptyStateWidget.emptyPairs({VoidCallback? onFindPair}) {
    return EmptyStateWidget(
      type: EmptyStateType.pairs,
      icon: AppIcons.pairOutlined,
      title: 'ペアがいません',
      message: '一緒に頑張る仲間を\n見つけましょう',
      action:
          onFindPair != null
              ? ElevatedButton.icon(
                onPressed: onFindPair,
                icon: const Icon(AppIcons.search),
                label: const Text('ペアを探す'),
              )
              : null,
    );
  }

  /// 検索結果が空の状態
  factory EmptyStateWidget.emptySearch({String? searchQuery}) {
    return EmptyStateWidget(
      type: EmptyStateType.search,
      icon: AppIcons.search,
      title: '検索結果がありません',
      message:
          searchQuery != null
              ? '「$searchQuery」に一致する\n結果が見つかりませんでした'
              : '検索条件を変更して\n再度お試しください',
    );
  }

  /// エラー状態
  factory EmptyStateWidget.error({
    String? errorMessage,
    VoidCallback? onRetry,
  }) {
    return EmptyStateWidget(
      type: EmptyStateType.error,
      icon: AppIcons.error,
      title: 'エラーが発生しました',
      message: errorMessage ?? '問題が発生しました\nもう一度お試しください',
      action:
          onRetry != null
              ? ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(AppIcons.refresh),
                label: const Text('再試行'),
              )
              : null,
    );
  }

  /// ネットワークエラー状態
  factory EmptyStateWidget.networkError({VoidCallback? onRetry}) {
    return EmptyStateWidget(
      type: EmptyStateType.networkError,
      icon: Icons.wifi_off_rounded,
      title: 'インターネット接続がありません',
      message: 'ネットワーク接続を確認して\n再度お試しください',
      action:
          onRetry != null
              ? ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(AppIcons.refresh),
                label: const Text('再試行'),
              )
              : null,
    );
  }

  /// 権限エラー状態
  factory EmptyStateWidget.permissionDenied({
    String? permissionName,
    VoidCallback? onRequestPermission,
  }) {
    return EmptyStateWidget(
      type: EmptyStateType.permissionDenied,
      icon: AppIcons.lock,
      title: '権限が必要です',
      message:
          permissionName != null
              ? '$permissionNameの権限が\n必要です'
              : 'この機能を使用するには\n権限が必要です',
      action:
          onRequestPermission != null
              ? ElevatedButton(
                onPressed: onRequestPermission,
                child: const Text('権限を許可'),
              )
              : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: SpacingSystem.paddingXXL,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            // イラストまたはアイコン
            if (illustration != null)
              illustration!
            else if (icon != null)
              _buildIcon(context, icon!, type),

            SpacingSystem.vSpaceLG,

            // タイトル
            if (title != null)
              Text(
                title!,
                style: theme.textTheme.titleLarge?.copyWith(
                  color: _getTitleColor(colorScheme, type),
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),

            if (title != null && message != null) SpacingSystem.vSpaceSM,

            // メッセージ
            if (message != null)
              Text(
                message!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.6),
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),

            // アクション
            if (action != null) ...[SpacingSystem.vSpaceXL, action!],
          ],
        ),
      ),
    );
  }

  Widget _buildIcon(BuildContext context, IconData icon, EmptyStateType type) {
    final colorScheme = Theme.of(context).colorScheme;
    final iconColor = _getIconColor(colorScheme, type);

    return Container(
      width: 96,
      height: 96,
      decoration: BoxDecoration(
        color: iconColor.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, size: 48, color: iconColor),
    );
  }

  Color _getIconColor(ColorScheme colorScheme, EmptyStateType type) {
    switch (type) {
      case EmptyStateType.error:
      case EmptyStateType.networkError:
        return colorScheme.error;
      case EmptyStateType.permissionDenied:
        return const Color(0xFFF59E0B); // Warning color
      case EmptyStateType.quests:
      case EmptyStateType.pairs:
        return colorScheme.primary;
      default:
        return colorScheme.onSurface.withValues(alpha: 0.4);
    }
  }

  Color _getTitleColor(ColorScheme colorScheme, EmptyStateType type) {
    switch (type) {
      case EmptyStateType.error:
      case EmptyStateType.networkError:
        return colorScheme.error;
      default:
        return colorScheme.onSurface;
    }
  }
}

/// 空状態のタイプ
enum EmptyStateType {
  general,
  quests,
  logs,
  stats,
  pairs,
  search,
  error,
  networkError,
  permissionDenied,
}

/// 空状態イラストウィジェット
class EmptyStateIllustration extends StatelessWidget {
  final String assetPath;
  final double? width;
  final double? height;

  const EmptyStateIllustration({
    super.key,
    required this.assetPath,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      assetPath,
      width: width ?? 200,
      height: height ?? 200,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        // フォールバック: アイコンを表示
        return const Icon(
          Icons.image_not_supported_rounded,
          size: 96,
          color: Colors.grey,
        );
      },
    );
  }
}

/// 空状態アニメーションウィジェット（Lottie）
class EmptyStateAnimation extends StatelessWidget {
  final String animationPath;
  final double? width;
  final double? height;

  const EmptyStateAnimation({
    super.key,
    required this.animationPath,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    // Lottieアニメーションの実装
    // 実際の実装では lottie パッケージを使用
    return SizedBox(
      width: width ?? 200,
      height: height ?? 200,
      child: const Center(
        child: Icon(Icons.animation_rounded, size: 96, color: Colors.grey),
      ),
    );
  }
}

/// 空状態カードウィジェット
class EmptyStateCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final VoidCallback? onTap;

  const EmptyStateCard({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: SpacingSystem.paddingLG,
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: colorScheme.primary, size: 24),
              ),
              SpacingSystem.hSpaceMD,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: theme.textTheme.titleMedium),
                    SpacingSystem.vSpaceXS,
                    Text(
                      message,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
              if (onTap != null)
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: colorScheme.onSurface.withValues(alpha: 0.4),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
