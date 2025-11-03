import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:minq/core/ai/dynamic_prompt_engine.dart';
import 'package:minq/presentation/theme/minq_tokens.dart';

/// 強化されたAIコーチオーバーレイウィジェット
/// クイックアクションと提案を表示
class EnhancedAICoachOverlay extends ConsumerWidget {
  final List<QuickAction> quickActions;
  final List<String> suggestions;
  final bool isOffline;
  final VoidCallback? onDismiss;

  const EnhancedAICoachOverlay({
    super.key,
    required this.quickActions,
    required this.suggestions,
    this.isOffline = false,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: MinqTokens.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: MinqTokens.textPrimary.withAlpha((255 * 0.1).round()),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ヘッダー
          _buildHeader(context),

          // クイックアクション
          if (quickActions.isNotEmpty) ...[
            const SizedBox(height: 8),
            _buildQuickActions(context),
          ],

          // 提案
          if (suggestions.isNotEmpty) ...[
            const SizedBox(height: 8),
            _buildSuggestions(context),
          ],

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: MinqTokens.brandPrimary.withAlpha((255 * 0.1).round()),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Row(
        children: [
          Icon(
            isOffline ? Icons.offline_bolt : Icons.psychology,
            color: MinqTokens.brandPrimary,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              isOffline ? 'オフラインAIコーチ' : '動的AIコーチ',
              style: TextStyle(
                color: MinqTokens.textPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
          if (onDismiss != null)
            IconButton(
              onPressed: onDismiss,
              icon: Icon(
                Icons.close,
                color: MinqTokens.textSecondary,
                size: 18,
              ),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
            ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'おすすめアクション',
            style: TextStyle(
              color: MinqTokens.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          ...quickActions.map(
            (action) => _buildQuickActionItem(context, action),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionItem(BuildContext context, QuickAction action) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _handleQuickAction(context, action),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: MinqTokens.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: MinqTokens.textSecondary.withAlpha((255 * 0.2).round()),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: MinqTokens.brandPrimary.withAlpha((255 * 0.1).round()),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getIconData(action.icon),
                    color: MinqTokens.brandPrimary,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        action.title,
                        style: TextStyle(
                          color: MinqTokens.textPrimary,
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                      if (action.description.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          action.description,
                          style: TextStyle(
                            color: MinqTokens.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: MinqTokens.textSecondary,
                  size: 12,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSuggestions(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '提案',
            style: TextStyle(
              color: MinqTokens.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          ...suggestions.map(
            (suggestion) => _buildSuggestionItem(context, suggestion),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionItem(BuildContext context, String suggestion) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: MinqTokens.brandPrimary.withAlpha((255 * 0.1).round()),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: MinqTokens.brandPrimary.withAlpha((255 * 0.2).round()),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.lightbulb_outline,
            color: MinqTokens.brandPrimary,
            size: 14,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              suggestion,
              style: TextStyle(color: MinqTokens.textPrimary, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  void _handleQuickAction(BuildContext context, QuickAction action) {
    // ナビゲーション処理
    if (action.route.isNotEmpty) {
      Navigator.of(
        context,
      ).pushNamed(action.route, arguments: action.parameters);
    }

    // オーバーレイを閉じる
    onDismiss?.call();
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'add_task':
        return Icons.add_task;
      case 'play_arrow':
        return Icons.play_arrow;
      case 'timer':
        return Icons.timer;
      case 'trending_up':
        return Icons.trending_up;
      case 'people':
        return Icons.people;
      case 'emoji_events':
        return Icons.emoji_events;
      case 'settings':
        return Icons.settings;
      case 'help':
        return Icons.help_outline;
      default:
        return Icons.star;
    }
  }
}

/// AIコーチメッセージバブル
class AICoachMessageBubble extends ConsumerWidget {
  final String message;
  final bool isUser;
  final List<QuickAction> quickActions;
  final List<String> suggestions;
  final bool isOffline;
  final DateTime timestamp;

  const AICoachMessageBubble({
    super.key,
    required this.message,
    required this.isUser,
    this.quickActions = const [],
    this.suggestions = const [],
    this.isOffline = false,
    required this.timestamp,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[_buildAvatar(), const SizedBox(width: 8)],
          Flexible(
            child: Column(
              crossAxisAlignment:
                  isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                _buildMessageBubble(context),
                if (!isUser &&
                    (quickActions.isNotEmpty || suggestions.isNotEmpty))
                  _buildEnhancements(context),
                _buildTimestamp(),
              ],
            ),
          ),
          if (isUser) ...[const SizedBox(width: 8), _buildUserAvatar()],
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color:
            isOffline
                ? Colors.orange.withAlpha((255 * 0.2).round())
                : MinqTokens.brandPrimary.withAlpha((255 * 0.2).round()),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Icon(
        isOffline ? Icons.offline_bolt : Icons.psychology,
        color: isOffline ? Colors.orange : MinqTokens.brandPrimary,
        size: 16,
      ),
    );
  }

  Widget _buildUserAvatar() {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: MinqTokens.brandPrimary.withAlpha((255 * 0.2).round()),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Icon(Icons.person, color: MinqTokens.brandPrimary, size: 16),
    );
  }

  Widget _buildMessageBubble(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isUser ? MinqTokens.brandPrimary : MinqTokens.surface,
        borderRadius: BorderRadius.circular(16).copyWith(
          bottomLeft:
              isUser ? const Radius.circular(16) : const Radius.circular(4),
          bottomRight:
              isUser ? const Radius.circular(4) : const Radius.circular(16),
        ),
        border:
            isUser
                ? null
                : Border.all(
                  color: MinqTokens.textSecondary.withAlpha((255 * 0.2).round()),
                  width: 1,
                ),
      ),
      child: Text(
        message,
        style: TextStyle(
          color: isUser ? Colors.white : MinqTokens.textPrimary,
          fontSize: 14,
          height: 1.4,
        ),
      ),
    );
  }

  Widget _buildEnhancements(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (quickActions.isNotEmpty) _buildQuickActionsRow(context),
          if (suggestions.isNotEmpty) _buildSuggestionsRow(context),
        ],
      ),
    );
  }

  Widget _buildQuickActionsRow(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children:
          quickActions
              .take(2)
              .map((action) => _buildQuickActionChip(context, action))
              .toList(),
    );
  }

  Widget _buildQuickActionChip(BuildContext context, QuickAction action) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _handleQuickAction(context, action),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: MinqTokens.brandPrimary.withAlpha((255 * 0.1).round()),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: MinqTokens.brandPrimary.withAlpha((255 * 0.3).round()),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _getIconData(action.icon),
                color: MinqTokens.brandPrimary,
                size: 12,
              ),
              const SizedBox(width: 4),
              Text(
                action.title,
                style: TextStyle(
                  color: MinqTokens.brandPrimary,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSuggestionsRow(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 4),
      child: Wrap(
        spacing: 4,
        runSpacing: 2,
        children:
            suggestions
                .take(2)
                .map(
                  (suggestion) => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: MinqTokens.brandPrimary.withAlpha((255 * 0.1).round()),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      suggestion,
                      style: TextStyle(
                        color: MinqTokens.brandPrimary,
                        fontSize: 11,
                      ),
                    ),
                  ),
                )
                .toList(),
      ),
    );
  }

  Widget _buildTimestamp() {
    return Container(
      margin: const EdgeInsets.only(top: 4),
      child: Text(
        _formatTimestamp(timestamp),
        style: TextStyle(color: MinqTokens.textSecondary, fontSize: 10),
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'たった今';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}分前';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}時間前';
    } else {
      return '${timestamp.month}/${timestamp.day}';
    }
  }

  void _handleQuickAction(BuildContext context, QuickAction action) {
    if (action.route.isNotEmpty) {
      Navigator.of(
        context,
      ).pushNamed(action.route, arguments: action.parameters);
    }
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'add_task':
        return Icons.add_task;
      case 'play_arrow':
        return Icons.play_arrow;
      case 'timer':
        return Icons.timer;
      case 'trending_up':
        return Icons.trending_up;
      case 'people':
        return Icons.people;
      case 'emoji_events':
        return Icons.emoji_events;
      default:
        return Icons.star;
    }
  }
}
