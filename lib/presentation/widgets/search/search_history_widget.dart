import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:minq/core/search/search_engine.dart';
import 'package:minq/core/search/search_history_service.dart';
import 'package:minq/core/search/search_service.dart';
import 'package:minq/l10n/app_localizations.dart';
import 'package:minq/presentation/theme/minq_theme.dart';
import 'package:minq/presentation/theme/theme_extensions.dart';

/// 検索履歴表示ウィジェット
class SearchHistoryWidget extends ConsumerWidget {
  final Function(String query, SearchFilter filter)? onHistoryTap;
  final Function(SavedSearch savedSearch)? onSavedSearchTap;
  final bool showSavedSearches;

  const SearchHistoryWidget({
    super.key,
    this.onHistoryTap,
    this.onSavedSearchTap,
    this.showSavedSearches = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.tokens;
    final l10n = AppLocalizations.of(context);

    return DefaultTabController(
      length: showSavedSearches ? 2 : 1,
      child: Column(
        children: [
          // タブバー
          if (showSavedSearches)
            TabBar(
              tabs: [
                Tab(icon: const Icon(Icons.history), text: l10n.searchHistory),
                Tab(icon: const Icon(Icons.bookmark), text: l10n.savedSearches),
              ],
            ),

          // タブビュー
          Expanded(
            child:
                showSavedSearches
                    ? TabBarView(
                      children: [
                        _buildHistoryTab(context, ref),
                        _buildSavedSearchesTab(context, ref),
                      ],
                    )
                    : _buildHistoryTab(context, ref),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryTab(BuildContext context, WidgetRef ref) {
    final history = ref.watch(searchHistoryProvider);

    return history.when(
      data: (entries) => _buildHistoryList(context, ref, entries),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => _buildErrorState(context, error),
    );
  }

  Widget _buildSavedSearchesTab(BuildContext context, WidgetRef ref) {
    final savedSearches = ref.watch(savedSearchesProvider);

    return savedSearches.when(
      data: (searches) => _buildSavedSearchesList(context, ref, searches),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => _buildErrorState(context, error),
    );
  }

  Widget _buildHistoryList(
    BuildContext context,
    WidgetRef ref,
    List<SearchHistoryEntry> entries,
  ) {
    final tokens = context.tokens;
    final l10n = AppLocalizations.of(context);

    if (entries.isEmpty) {
      return _buildEmptyHistoryState(context);
    }

    return Column(
      children: [
        // ヘッダー
        Padding(
          padding: EdgeInsets.all(tokens.spacing.md),
          child: Row(
            children: [
              Text(
                l10n.recentSearches,
                style: context.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () => _clearHistory(context, ref),
                child: Text(l10n.clearAll),
              ),
            ],
          ),
        ),

        // 履歴リスト
        Expanded(
          child: ListView.builder(
            itemCount: entries.length,
            itemBuilder: (context, index) {
              final entry = entries[index];
              return _buildHistoryItem(context, ref, entry);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSavedSearchesList(
    BuildContext context,
    WidgetRef ref,
    List<SavedSearch> searches,
  ) {
    final tokens = context.tokens;
    final l10n = AppLocalizations.of(context);

    if (searches.isEmpty) {
      return _buildEmptySavedSearchesState(context);
    }

    return Column(
      children: [
        // ヘッダー
        Padding(
          padding: EdgeInsets.all(tokens.spacing.md),
          child: Row(
            children: [
              Text(
                l10n.savedSearches,
                style: context.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () => _showSaveSearchDialog(context, ref),
              ),
            ],
          ),
        ),

        // 保存された検索リスト
        Expanded(
          child: ListView.builder(
            itemCount: searches.length,
            itemBuilder: (context, index) {
              final search = searches[index];
              return _buildSavedSearchItem(context, ref, search);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildHistoryItem(
    BuildContext context,
    WidgetRef ref,
    SearchHistoryEntry entry,
  ) {
    final tokens = context.tokens;

    return ListTile(
      leading: Icon(Icons.history, color: tokens.textSecondary),
      title: Text(
        entry.query.isNotEmpty
            ? entry.query
            : AppLocalizations.of(context).filterOnly,
        style: context.textTheme.bodyMedium,
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!entry.filter.isEmpty)
            Text(
              _formatFilter(context, entry.filter),
              style: context.textTheme.bodySmall?.copyWith(
                color: tokens.textSecondary,
              ),
            ),
          Text(
            '${AppLocalizations.of(context).resultsCount(entry.resultCount)} • ${_formatTimestamp(context, entry.timestamp)}',
            style: context.textTheme.bodySmall?.copyWith(
              color: tokens.textMuted,
            ),
          ),
        ],
      ),
      trailing: IconButton(
        icon: Icon(Icons.close, size: 16, color: tokens.textMuted),
        onPressed: () => _removeHistoryEntry(context, ref, entry),
      ),
      onTap: () => onHistoryTap?.call(entry.query, entry.filter),
    );
  }

  Widget _buildSavedSearchItem(
    BuildContext context,
    WidgetRef ref,
    SavedSearch search,
  ) {
    final tokens = context.tokens;

    return ListTile(
      leading: Icon(Icons.bookmark, color: tokens.primary),
      title: Text(
        search.name,
        style: context.textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (search.query.isNotEmpty)
            Text(search.query, style: context.textTheme.bodySmall),
          if (!search.filter.isEmpty)
            Text(
              _formatFilter(context, search.filter),
              style: context.textTheme.bodySmall?.copyWith(
                color: tokens.textSecondary,
              ),
            ),
          Text(
            '${AppLocalizations.of(context).usedCount(search.useCount)} • ${_formatTimestamp(context, search.lastUsedAt)}',
            style: context.textTheme.bodySmall?.copyWith(
              color: tokens.textMuted,
            ),
          ),
        ],
      ),
      trailing: PopupMenuButton<String>(
        onSelected: (value) {
          switch (value) {
            case 'edit':
              _editSavedSearch(context, ref, search);
              break;
            case 'delete':
              _deleteSavedSearch(context, ref, search);
              break;
          }
        },
        itemBuilder:
            (context) => [
              PopupMenuItem(
                value: 'edit',
                child: ListTile(
                  leading: const Icon(Icons.edit),
                  title: Text(AppLocalizations.of(context).edit),
                ),
              ),
              PopupMenuItem(
                value: 'delete',
                child: ListTile(
                  leading: const Icon(Icons.delete),
                  title: Text(AppLocalizations.of(context).delete),
                ),
              ),
            ],
      ),
      onTap: () => onSavedSearchTap?.call(search),
    );
  }

  Widget _buildEmptyHistoryState(BuildContext context) {
    final tokens = context.tokens;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history, size: 64, color: tokens.textMuted),
          SizedBox(height: tokens.spacing.md),
          Text(
            AppLocalizations.of(context).noSearchHistory,
            style: context.textTheme.titleMedium?.copyWith(
              color: tokens.textSecondary,
            ),
          ),
          SizedBox(height: tokens.spacing.sm),
          Text(
            AppLocalizations.of(context).noSearchHistoryDescription,
            style: context.textTheme.bodyMedium?.copyWith(
              color: tokens.textMuted,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptySavedSearchesState(BuildContext context) {
    final tokens = context.tokens;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.bookmark_border, size: 64, color: tokens.textMuted),
          SizedBox(height: tokens.spacing.md),
          Text(
            AppLocalizations.of(context).noSavedSearches,
            style: context.textTheme.titleMedium?.copyWith(
              color: tokens.textSecondary,
            ),
          ),
          SizedBox(height: tokens.spacing.sm),
          Text(
            AppLocalizations.of(context).noSavedSearchesDescription,
            style: context.textTheme.bodyMedium?.copyWith(
              color: tokens.textMuted,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: tokens.spacing.md),
          ElevatedButton.icon(
            onPressed: () => _showSaveSearchDialog(context, ref),
            icon: const Icon(Icons.add),
            label: Text(AppLocalizations.of(context).saveSearch),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, Object error) {
    final tokens = context.tokens;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: tokens.error),
          SizedBox(height: tokens.spacing.md),
          Text(
            AppLocalizations.of(context).loadError,
            style: context.textTheme.titleMedium,
          ),
          SizedBox(height: tokens.spacing.sm),
          Text(
            error.toString(),
            style: context.textTheme.bodySmall?.copyWith(
              color: tokens.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _formatFilter(BuildContext context, SearchFilter filter) {
    final parts = <String>[];

    if (filter.categories.isNotEmpty) {
      parts.add(
        '${AppLocalizations.of(context).category}: ${filter.categories.join(', ')}',
      );
    }

    if (filter.difficulty != null) {
      parts.add(
        '${AppLocalizations.of(context).difficulty}: ${filter.difficulty}',
      );
    }

    if (filter.location != null) {
      parts.add('${AppLocalizations.of(context).location}: ${filter.location}');
    }

    if (filter.status != null) {
      parts.add('${AppLocalizations.of(context).status}: ${filter.status}');
    }

    return parts.join(' • ');
  }

  String _formatTimestamp(BuildContext context, DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return AppLocalizations.of(context).justNow;
    } else if (difference.inHours < 1) {
      return AppLocalizations.of(context).minutesAgo(difference.inMinutes);
    } else if (difference.inDays < 1) {
      return AppLocalizations.of(context).hoursAgo(difference.inHours);
    } else if (difference.inDays < 7) {
      return AppLocalizations.of(context).daysAgo(difference.inDays);
    } else {
      return '${timestamp.year}/${timestamp.month}/${timestamp.day}';
    }
  }

  void _clearHistory(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(AppLocalizations.of(context).clearSearchHistory),
            content: Text(
              AppLocalizations.of(context).clearSearchHistoryConfirmation,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(AppLocalizations.of(context).cancel),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.of(context).pop();
                  final searchService = ref.read(searchServiceProvider);
                  await searchService.clearSearchHistory();
                  ref.invalidate(searchHistoryProvider);
                },
                child: Text(AppLocalizations.of(context).clear),
              ),
            ],
          ),
    );
  }

  void _removeHistoryEntry(
    BuildContext context,
    WidgetRef ref,
    SearchHistoryEntry entry,
  ) async {
    // TODO: 個別履歴削除の実装
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context).historyEntryRemoved)),
    );
  }

  void _showSaveSearchDialog(BuildContext context, WidgetRef ref) {
    // TODO: 検索保存ダイアログの実装
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context).saveSearchNotImplemented),
      ),
    );
  }

  void _editSavedSearch(
    BuildContext context,
    WidgetRef ref,
    SavedSearch search,
  ) {
    // TODO: 保存された検索の編集
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context).editNotImplemented)),
    );
  }

  void _deleteSavedSearch(
    BuildContext context,
    WidgetRef ref,
    SavedSearch search,
  ) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(AppLocalizations.of(context).deleteSavedSearch),
            content: Text(
              AppLocalizations.of(
                context,
              ).deleteSavedSearchConfirmation(search.name),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(AppLocalizations.of(context).cancel),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.of(context).pop();
                  final searchService = ref.read(searchServiceProvider);
                  await searchService.deleteSavedSearch(search.id);
                  ref.invalidate(savedSearchesProvider);
                },
                child: Text(AppLocalizations.of(context).delete),
              ),
            ],
          ),
    );
  }
}
