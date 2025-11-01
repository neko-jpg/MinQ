import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:minq/core/search/search_engine.dart';
import 'package:minq/core/search/search_service.dart';
import 'package:minq/l10n/app_localizations.dart';
import 'package:minq/presentation/theme/minq_theme.dart';
import 'package:minq/presentation/widgets/search/advanced_search_bar.dart';
import 'package:minq/presentation/widgets/search/search_history_widget.dart';
import 'package:minq/presentation/widgets/search/search_results_widget.dart';

/// 高度な検索画面
class AdvancedSearchScreen extends ConsumerStatefulWidget {
  final String? initialQuery;
  final SearchFilter? initialFilter;

  const AdvancedSearchScreen({
    super.key,
    this.initialQuery,
    this.initialFilter,
  });

  @override
  ConsumerState<AdvancedSearchScreen> createState() =>
      _AdvancedSearchScreenState();
}

class _AdvancedSearchScreenState extends ConsumerState<AdvancedSearchScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  String _currentQuery = '';
  SearchFilter _currentFilter = const SearchFilter();
  final SearchSortOrder _sortOrder = SearchSortOrder.relevance;
  bool _hasSearched = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    _currentQuery = widget.initialQuery ?? '';
    _currentFilter = widget.initialFilter ?? const SearchFilter();

    // 初期検索がある場合は実行
    if (_currentQuery.isNotEmpty || !_currentFilter.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _performSearch(_currentQuery, _currentFilter);
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.advancedSearch),
        elevation: 0,
        backgroundColor: tokens.surface,
        actions: [
          // 検索設定
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _showSearchSettings,
          ),

          // ヘルプ
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: _showSearchHelp,
          ),
        ],
        bottom:
            _hasSearched
                ? TabBar(
                  controller: _tabController,
                  tabs: [
                    Tab(
                      icon: const Icon(Icons.search),
                      text: l10n.searchResults,
                    ),
                    Tab(icon: const Icon(Icons.history), text: l10n.history),
                  ],
                )
                : null,
      ),
      body: Column(
        children: [
          // 検索バー
          Container(
            padding: EdgeInsets.all(tokens.spacing.md),
            decoration: BoxDecoration(
              color: tokens.surface,
              border: Border(
                bottom: BorderSide(color: tokens.border, width: 1),
              ),
            ),
            child: AdvancedSearchBar(
              initialQuery: _currentQuery,
              initialFilter: _currentFilter,
              onSearch: _performSearch,
              onClear: _clearSearch,
            ),
          ),

          // コンテンツ
          Expanded(
            child:
                _hasSearched
                    ? TabBarView(
                      controller: _tabController,
                      children: [
                        // 検索結果タブ
                        SearchResultsWidget(
                          searchQuery: SearchQuery(
                            query: _currentQuery,
                            filter: _currentFilter,
                            sortOrder: _sortOrder,
                          ),
                          onItemTap: _onSearchResultTap,
                          sortOrder: _sortOrder,
                        ),

                        // 履歴タブ
                        SearchHistoryWidget(
                          onHistoryTap: (query, filter) {
                            _performSearch(query, filter);
                            _tabController.animateTo(0); // 結果タブに切り替え
                          },
                          onSavedSearchTap: (savedSearch) {
                            _performSavedSearch(savedSearch);
                            _tabController.animateTo(0); // 結果タブに切り替え
                          },
                        ),
                      ],
                    )
                    : _buildInitialState(),
          ),
        ],
      ),

      // フローティングアクションボタン
      floatingActionButton:
          _hasSearched
              ? FloatingActionButton(
                onPressed: _showSaveSearchDialog,
                tooltip: l10n.saveSearch,
                child: const Icon(Icons.bookmark_add),
              )
              : null,
    );
  }

  Widget _buildInitialState() {
    final tokens = context.tokens;
    final l10n = AppLocalizations.of(context);

    return SingleChildScrollView(
      padding: EdgeInsets.all(tokens.spacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 人気キーワード
          _buildPopularKeywords(),

          SizedBox(height: tokens.spacing.xl),

          // 検索履歴プレビュー
          _buildRecentSearches(),

          SizedBox(height: tokens.spacing.xl),

          // 検索のヒント
          _buildSearchTips(),
        ],
      ),
    );
  }

  Widget _buildPopularKeywords() {
    final tokens = context.tokens;
    final l10n = AppLocalizations.of(context);
    final popularKeywords = ref.watch(popularKeywordsProvider);

    return popularKeywords.when(
      data: (keywords) {
        if (keywords.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.popularKeywords,
              style: context.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: tokens.spacing.md),
            Wrap(
              spacing: tokens.spacing.sm,
              runSpacing: tokens.spacing.sm,
              children:
                  keywords.map((keyword) {
                    return ActionChip(
                      label: Text(keyword),
                      onPressed:
                          () => _performSearch(keyword, const SearchFilter()),
                      backgroundColor: tokens.surfaceVariant,
                    );
                  }).toList(),
            ),
          ],
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildRecentSearches() {
    final tokens = context.tokens;
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              l10n.recentSearches,
              style: context.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            TextButton(
              onPressed: () {
                setState(() {
                  _hasSearched = true;
                  _tabController.animateTo(1); // 履歴タブに切り替え
                });
              },
              child: Text(l10n.viewAll),
            ),
          ],
        ),
        SizedBox(height: tokens.spacing.md),
        SizedBox(
          height: 200,
          child: SearchHistoryWidget(
            onHistoryTap: _performSearch,
            onSavedSearchTap: _performSavedSearch,
            showSavedSearches: false,
          ),
        ),
      ],
    );
  }

  Widget _buildSearchTips() {
    final tokens = context.tokens;
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.searchTips,
          style: context.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: tokens.spacing.md),
        Card(
          child: Padding(
            padding: EdgeInsets.all(tokens.spacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTipItem(
                  icon: Icons.search,
                  title: l10n.searchTipKeywords,
                  description: l10n.searchTipKeywordsDescription,
                ),
                SizedBox(height: tokens.spacing.md),
                _buildTipItem(
                  icon: Icons.filter_alt,
                  title: l10n.searchTipFilters,
                  description: l10n.searchTipFiltersDescription,
                ),
                SizedBox(height: tokens.spacing.md),
                _buildTipItem(
                  icon: Icons.bookmark,
                  title: l10n.searchTipSave,
                  description: l10n.searchTipSaveDescription,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTipItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    final tokens = context.tokens;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(tokens.spacing.xs),
          decoration: BoxDecoration(
            color: tokens.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(tokens.radius.sm),
          ),
          child: Icon(icon, size: 16, color: tokens.primary),
        ),
        SizedBox(width: tokens.spacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: context.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: tokens.spacing.xs),
              Text(
                description,
                style: context.textTheme.bodySmall?.copyWith(
                  color: tokens.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _performSearch(String query, SearchFilter filter) {
    setState(() {
      _currentQuery = query;
      _currentFilter = filter;
      _hasSearched = true;
    });

    // 結果タブに切り替え
    if (_tabController.length > 1) {
      _tabController.animateTo(0);
    }
  }

  void _performSavedSearch(SavedSearch savedSearch) async {
    final searchService = ref.read(searchServiceProvider);
    await searchService.useSavedSearch(savedSearch);

    _performSearch(savedSearch.query, savedSearch.filter);
  }

  void _clearSearch() {
    setState(() {
      _currentQuery = '';
      _currentFilter = const SearchFilter();
      _hasSearched = false;
    });
  }

  void _onSearchResultTap(SearchableItem item) {
    // TODO: 検索結果アイテムタップ時の処理
    if (item is SearchableQuest) {
      // クエスト詳細画面に遷移
      Navigator.of(context).pushNamed('/quest/${item.quest.id}');
    } else if (item is SearchableChallenge) {
      // チャレンジ詳細画面に遷移
      Navigator.of(context).pushNamed('/challenge/${item.challenge.id}');
    }
  }

  void _showSearchSettings() {
    // TODO: 検索設定画面
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          AppLocalizations.of(context).searchSettingsNotImplemented,
        ),
      ),
    );
  }

  void _showSearchHelp() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(AppLocalizations.of(context).searchHelp),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(AppLocalizations.of(context).searchHelpContent),
                  // TODO: より詳細なヘルプコンテンツ
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(AppLocalizations.of(context).close),
              ),
            ],
          ),
    );
  }

  void _showSaveSearchDialog() {
    final nameController = TextEditingController();

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(AppLocalizations.of(context).saveSearch),
            content: TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context).searchName,
                hintText: AppLocalizations.of(context).searchNameHint,
              ),
              autofocus: true,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(AppLocalizations.of(context).cancel),
              ),
              TextButton(
                onPressed: () async {
                  final name = nameController.text.trim();
                  if (name.isNotEmpty) {
                    Navigator.of(context).pop();

                    final searchService = ref.read(searchServiceProvider);
                    await searchService.saveSearch(
                      name: name,
                      query: _currentQuery,
                      filter: _currentFilter,
                    );

                    ref.invalidate(savedSearchesProvider);

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(AppLocalizations.of(context).searchSaved),
                      ),
                    );
                  }
                },
                child: Text(AppLocalizations.of(context).save),
              ),
            ],
          ),
    );
  }
}
