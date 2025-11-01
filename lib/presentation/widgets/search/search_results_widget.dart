import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:minq/core/search/search_engine.dart';
import 'package:minq/core/search/search_service.dart';
import 'package:minq/l10n/app_localizations.dart';
import 'package:minq/presentation/theme/minq_theme.dart';
import 'package:minq/presentation/theme/theme_extensions.dart';
import 'package:minq/presentation/widgets/empty_state_widget.dart';
import 'package:minq/presentation/widgets/search/search_highlight_text.dart';

/// 検索結果表示ウィジェット
class SearchResultsWidget extends ConsumerWidget {
  final SearchQuery searchQuery;
  final Function(SearchableItem)? onItemTap;
  final SearchSortOrder sortOrder;
  final bool showSortOptions;

  const SearchResultsWidget({
    super.key,
    required this.searchQuery,
    this.onItemTap,
    this.sortOrder = SearchSortOrder.relevance,
    this.showSortOptions = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final results = ref.watch(searchResultsProvider(searchQuery));

    return results.when(
      data: (results) => _buildResults(context, results),
      loading: () => _buildLoadingState(),
      error: (error, stack) => _buildErrorState(context, error),
    );
  }

  Widget _buildResults(BuildContext context, List<SearchResult> results) {
    if (results.isEmpty) {
      return _buildEmptyState(context);
    }

    return Column(
      children: [
        // ソートオプション
        if (showSortOptions) _buildSortOptions(context),

        // 結果数表示
        _buildResultsHeader(context, results.length),

        // 結果リスト
        Expanded(
          child: ListView.builder(
            itemCount: results.length,
            itemBuilder: (context, index) {
              final result = results[index];
              return _buildResultItem(context, result);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSortOptions(BuildContext context) {
    final tokens = context.tokens;
    final l10n = AppLocalizations.of(context);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: tokens.spacing.md,
        vertical: tokens.spacing.sm,
      ),
      child: Row(
        children: [
          Text(
            l10n.sortBy,
            style: context.textTheme.bodySmall?.copyWith(
              color: tokens.textSecondary,
            ),
          ),
          SizedBox(width: tokens.spacing.sm),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children:
                    SearchSortOrder.values.map((order) {
                      final isSelected = order == sortOrder;
                      return Padding(
                        padding: EdgeInsets.only(right: tokens.spacing.sm),
                        child: FilterChip(
                          label: Text(_getSortOrderLabel(context, order)),
                          selected: isSelected,
                          onSelected: (selected) {
                            if (selected) {
                              // TODO: ソート順変更の実装
                            }
                          },
                          backgroundColor: tokens.surface,
                          selectedColor: tokens.primary.withOpacity(0.2),
                          checkmarkColor: tokens.primary,
                        ),
                      );
                    }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsHeader(BuildContext context, int count) {
    final tokens = context.tokens;
    final l10n = AppLocalizations.of(context);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: tokens.spacing.md,
        vertical: tokens.spacing.sm,
      ),
      child: Row(
        children: [
          Text(
            l10n.searchResultsCount(count),
            style: context.textTheme.bodySmall?.copyWith(
              color: tokens.textSecondary,
            ),
          ),
          const Spacer(),
          // 結果をエクスポート
          IconButton(
            icon: Icon(Icons.share, size: 16, color: tokens.textSecondary),
            onPressed: () => _exportResults(context),
          ),
        ],
      ),
    );
  }

  Widget _buildResultItem(BuildContext context, SearchResult result) {
    final tokens = context.tokens;
    final item = result.item;

    return Card(
      margin: EdgeInsets.symmetric(
        horizontal: tokens.spacing.md,
        vertical: tokens.spacing.sm,
      ),
      child: InkWell(
        onTap: () => onItemTap?.call(item),
        borderRadius: BorderRadius.circular(tokens.radius.lg),
        child: Padding(
          padding: EdgeInsets.all(tokens.spacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // タイトル行
              Row(
                children: [
                  // アイテムタイプアイコン
                  Container(
                    padding: EdgeInsets.all(tokens.spacing.xs),
                    decoration: BoxDecoration(
                      color: _getItemTypeColor(item).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(tokens.radius.sm),
                    ),
                    child: Icon(
                      _getItemTypeIcon(item),
                      size: 16,
                      color: _getItemTypeColor(item),
                    ),
                  ),

                  SizedBox(width: tokens.spacing.sm),

                  // タイトル
                  Expanded(
                    child: SearchHighlightText(
                      text: item.title,
                      query: searchQuery.query,
                      style: context.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  // 関連度スコア（デバッグ用）
                  if (sortOrder == SearchSortOrder.relevance)
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: tokens.spacing.xs,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: tokens.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(tokens.radius.sm),
                      ),
                      child: Text(
                        '${(result.relevanceScore * 10).round() / 10}',
                        style: context.textTheme.bodySmall?.copyWith(
                          color: tokens.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),

              SizedBox(height: tokens.spacing.sm),

              // 説明
              if (item.description.isNotEmpty)
                SearchHighlightText(
                  text: item.description,
                  query: searchQuery.query,
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: tokens.textSecondary,
                  ),
                  maxLines: 2,
                ),

              SizedBox(height: tokens.spacing.sm),

              // タグとメタデータ
              Row(
                children: [
                  // カテゴリ
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: tokens.spacing.sm,
                      vertical: tokens.spacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: tokens.surfaceVariant,
                      borderRadius: BorderRadius.circular(tokens.radius.sm),
                    ),
                    child: Text(
                      item.category,
                      style: context.textTheme.bodySmall?.copyWith(
                        color: tokens.textSecondary,
                      ),
                    ),
                  ),

                  SizedBox(width: tokens.spacing.sm),

                  // タグ
                  Expanded(
                    child: Wrap(
                      spacing: tokens.spacing.xs,
                      children:
                          item.tags.take(3).map((tag) {
                            return Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: tokens.spacing.xs,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: tokens.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(
                                  tokens.radius.xs,
                                ),
                              ),
                              child: Text(
                                tag,
                                style: context.textTheme.bodySmall?.copyWith(
                                  color: tokens.primary,
                                ),
                              ),
                            );
                          }).toList(),
                    ),
                  ),

                  // 作成日
                  Text(
                    _formatDate(context, item.createdAt),
                    style: context.textTheme.bodySmall?.copyWith(
                      color: tokens.textMuted,
                    ),
                  ),
                ],
              ),

              // マッチしたキーワード
              if (result.matchedKeywords.isNotEmpty) ...[
                SizedBox(height: tokens.spacing.sm),
                Text(
                  AppLocalizations.of(
                    context,
                  ).matchedKeywords(result.matchedKeywords.join(', ')),
                  style: context.textTheme.bodySmall?.copyWith(
                    color: tokens.textMuted,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(child: CircularProgressIndicator());
  }

  Widget _buildErrorState(BuildContext context, Object error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: context.tokens.error),
          SizedBox(height: context.tokens.spacing.md),
          Text(
            AppLocalizations.of(context).searchError,
            style: context.textTheme.titleMedium,
          ),
          SizedBox(height: context.tokens.spacing.sm),
          Text(
            error.toString(),
            style: context.textTheme.bodySmall?.copyWith(
              color: context.tokens.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return EmptyStateWidget.emptySearch(
      searchQuery: searchQuery.query.isNotEmpty ? searchQuery.query : null,
    );
  }

  IconData _getItemTypeIcon(SearchableItem item) {
    if (item is SearchableQuest) {
      return Icons.task_alt;
    } else if (item is SearchableChallenge) {
      return Icons.emoji_events;
    }
    return Icons.help_outline;
  }

  Color _getItemTypeColor(SearchableItem item) {
    if (item is SearchableQuest) {
      return Colors.blue;
    } else if (item is SearchableChallenge) {
      return Colors.orange;
    }
    return Colors.grey;
  }

  String _getSortOrderLabel(BuildContext context, SearchSortOrder order) {
    final l10n = AppLocalizations.of(context);
    switch (order) {
      case SearchSortOrder.relevance:
        return l10n.sortByRelevance;
      case SearchSortOrder.dateCreated:
        return l10n.sortByDateCreated;
      case SearchSortOrder.dateUpdated:
        return l10n.sortByDateUpdated;
      case SearchSortOrder.alphabetical:
        return l10n.sortByAlphabetical;
    }
  }

  String _formatDate(BuildContext context, DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return AppLocalizations.of(context).today;
    } else if (difference.inDays == 1) {
      return AppLocalizations.of(context).yesterday;
    } else if (difference.inDays < 7) {
      return AppLocalizations.of(context).daysAgo(difference.inDays);
    } else {
      return '${date.year}/${date.month}/${date.day}';
    }
  }

  void _exportResults(BuildContext context) {
    // TODO: 検索結果のエクスポート機能
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context).exportNotImplemented),
      ),
    );
  }
}
