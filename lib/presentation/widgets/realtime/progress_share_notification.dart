import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:minq/core/realtime/realtime_message.dart';
import 'package:minq/presentation/providers/realtime_providers.dart';

/// 進捗共有通知ウィジェット
class ProgressShareNotification extends ConsumerStatefulWidget {
  final String currentUserId;
  final Function(RealtimeMessage)? onProgressShareReceived;

  const ProgressShareNotification({
    super.key,
    required this.currentUserId,
    this.onProgressShareReceived,
  });

  @override
  ConsumerState<ProgressShareNotification> createState() =>
      _ProgressShareNotificationState();
}

class _ProgressShareNotificationState
    extends ConsumerState<ProgressShareNotification>
    with TickerProviderStateMixin {
  final List<RealtimeMessage> _recentShares = [];
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 進捗共有メッセージを監視
    ref.listen<AsyncValue<RealtimeMessage>>(progressShareStreamProvider, (
      previous,
      next,
    ) {
      next.whenData((message) {
        if (message.recipientId == widget.currentUserId) {
          _handleProgressShare(message);
        }
      });
    });

    return Positioned(
      top: 100,
      right: 16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children:
            _recentShares
                .map((share) => _buildNotificationCard(share))
                .toList(),
      ),
    );
  }

  Widget _buildNotificationCard(RealtimeMessage message) {
    final theme = Theme.of(context);
    final title = message.payload['title'] as String? ?? '';
    final description = message.payload['description'] as String? ?? '';
    final score = message.payload['score'] as int?;
    final tags = message.payload['tags'] as List<String>? ?? [];

    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          width: 280,
          margin: const EdgeInsets.only(bottom: 8),
          child: Card(
            elevation: 8,
            shadowColor: theme.colorScheme.primary.withOpacity(0.3),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.primaryContainer,
                    theme.colorScheme.primaryContainer.withOpacity(0.8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ヘッダー
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.celebration,
                            color: theme.colorScheme.onPrimary,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'ペアが進捗を共有',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onPrimaryContainer
                                      .withOpacity(0.8),
                                ),
                              ),
                              Text(
                                title,
                                style: theme.textTheme.titleSmall?.copyWith(
                                  color: theme.colorScheme.onPrimaryContainer,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () => _dismissNotification(message),
                          icon: Icon(
                            Icons.close,
                            size: 18,
                            color: theme.colorScheme.onPrimaryContainer
                                .withOpacity(0.6),
                          ),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                            minWidth: 24,
                            minHeight: 24,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // 説明
                    if (description.isNotEmpty)
                      Text(
                        description,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onPrimaryContainer,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),

                    const SizedBox(height: 8),

                    // スコアとタグ
                    Row(
                      children: [
                        if (score != null) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.secondary,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.stars,
                                  size: 14,
                                  color: theme.colorScheme.onSecondary,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '$score pt',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSecondary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],

                        Expanded(
                          child: Wrap(
                            spacing: 4,
                            children:
                                tags
                                    .take(2)
                                    .map(
                                      (tag) => Chip(
                                        label: Text(
                                          tag,
                                          style: theme.textTheme.bodySmall,
                                        ),
                                        backgroundColor:
                                            theme
                                                .colorScheme
                                                .surfaceContainerHighest,
                                        materialTapTargetSize:
                                            MaterialTapTargetSize.shrinkWrap,
                                        visualDensity: VisualDensity.compact,
                                      ),
                                    )
                                    .toList(),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // アクションボタン
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton.icon(
                          onPressed: () => _sendEncouragement(message),
                          icon: const Icon(Icons.favorite, size: 16),
                          label: const Text('励ます'),
                          style: TextButton.styleFrom(
                            foregroundColor: theme.colorScheme.primary,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          onPressed: () => _viewDetails(message),
                          icon: const Icon(Icons.visibility, size: 16),
                          label: const Text('詳細'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.colorScheme.primary,
                            foregroundColor: theme.colorScheme.onPrimary,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _handleProgressShare(RealtimeMessage message) {
    setState(() {
      _recentShares.add(message);
      // 最大3件まで表示
      if (_recentShares.length > 3) {
        _recentShares.removeAt(0);
      }
    });

    _animationController.forward();

    // コールバック実行
    if (widget.onProgressShareReceived != null) {
      widget.onProgressShareReceived!(message);
    }

    // 5秒後に自動削除
    Future.delayed(const Duration(seconds: 5), () {
      _dismissNotification(message);
    });
  }

  void _dismissNotification(RealtimeMessage message) {
    setState(() {
      _recentShares.remove(message);
    });
  }

  void _sendEncouragement(RealtimeMessage message) {
    final connectionNotifier = ref.read(realtimeConnectionProvider.notifier);
    connectionNotifier.sendEncouragement(
      senderId: widget.currentUserId,
      recipientId: message.senderId,
      message: '素晴らしい進捗ですね！頑張ってください！',
    );

    _dismissNotification(message);

    // スナックバーで確認
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('励ましメッセージを送信しました'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _viewDetails(RealtimeMessage message) {
    _dismissNotification(message);

    // 詳細画面に遷移（実装は省略）
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('進捗詳細'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('タイトル: ${message.payload['title']}'),
                const SizedBox(height: 8),
                Text('説明: ${message.payload['description']}'),
                if (message.payload['score'] != null) ...[
                  const SizedBox(height: 8),
                  Text('スコア: ${message.payload['score']} pt'),
                ],
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('閉じる'),
              ),
            ],
          ),
    );
  }
}
