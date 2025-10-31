import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:minq/core/search/search_engine.dart';
import 'package:minq/core/search/search_history_service.dart';
import 'package:minq/core/search/search_service.dart';

/// 検索エンジンプロバイダー
final searchEngineProvider = Provider<SearchEngine>((ref) {
  return SearchEngine();
});

/// 検索履歴サービスプロバイダー
final searchHistoryServiceProvider = Provider<SearchHistoryService>((ref) {
  return SearchHistoryService();
});

/// 検索サービスプロバイダー（実装版）
final searchServiceImplProvider = Provider<SearchService>((ref) {
  final searchEngine = ref.watch(searchEngineProvider);
  final historyService = ref.watch(searchHistoryServiceProvider);
  final isar = ref.watch(isarProvider);
  
  return SearchService(
    searchEngine: searchEngine,
    historyService: historyService,
    isar: isar,
  );
});

/// Isarプロバイダー（他の場所で定義されている場合はそれを使用）
final isarProvider = Provider<Isar>((ref) {
  throw UnimplementedError('Isar provider must be overridden');
});

/// 検索状態管理プロバイダー
final searchStateProvider = StateNotifierProvider<SearchStateNotifier, SearchState>((ref) {
  final searchService = ref.watch(searchServiceImplProvider);
  return SearchStateNotifier(searchService);
});

/// 検索状態
class SearchState {
  final String query;
  final SearchFilter filter;
  final SearchSortOrder sortOrder;
  final bool isSearching;
  final List<SearchResult> results;
  final String? error;
  
  const SearchState({
    this.query = '',
    this.filter = const SearchFilter(),
    this.sortOrder = SearchSortOrder.relevance,
    this.isSearching = false,
    this.results = const [],
    this.error,
  });
  
  SearchState copyWith({
    String? query,
    SearchFilter? filter,
    SearchSortOrder? sortOrder,
    bool? isSearching,
    List<SearchResult>? results,
    String? error,
  }) {
    return SearchState(
      query: query ?? this.query,
      filter: filter ?? this.filter,
      sortOrder: sortOrder ?? this.sortOrder,
      isSearching: isSearching ?? this.isSearching,
      results: results ?? this.results,
      error: error ?? this.error,
    );
  }
}

/// 検索状態管理
class SearchStateNotifier extends StateNotifier<SearchState> {
  final SearchService _searchService;
  
  SearchStateNotifier(this._searchService) : super(const SearchState()) {
    _initialize();
  }
  
  Future<void> _initialize() async {
    await _searchService.initialize();
  }
  
  /// 検索を実行
  Future<void> search({
    required String query,
    SearchFilter? filter,
    SearchSortOrder? sortOrder,
  }) async {
    state = state.copyWith(
      query: query,
      filter: filter ?? state.filter,
      sortOrder: sortOrder ?? state.sortOrder,
      isSearching: true,
      error: null,
    );
    
    try {
      final results = await _searchService.search(
        query: query,
        filter: state.filter,
        sortOrder: state.sortOrder,
      );
      
      state = state.copyWith(
        results: results,
        isSearching: false,
      );
    } catch (error) {
      state = state.copyWith(
        error: error.toString(),
        isSearching: false,
      );
    }
  }
  
  /// フィルターを更新
  void updateFilter(SearchFilter filter) {
    state = state.copyWith(filter: filter);
    
    // フィルター変更時に自動検索
    if (state.query.isNotEmpty || !filter.isEmpty) {
      search(query: state.query, filter: filter);
    }
  }
  
  /// ソート順を更新
  void updateSortOrder(SearchSortOrder sortOrder) {
    state = state.copyWith(sortOrder: sortOrder);
    
    // ソート順変更時に自動検索
    if (state.query.isNotEmpty || !state.filter.isEmpty) {
      search(query: state.query, sortOrder: sortOrder);
    }
  }
  
  /// 検索をクリア
  void clearSearch() {
    state = const SearchState();
  }
  
  /// 保存された検索を使用
  Future<void> useSavedSearch(SavedSearch savedSearch) async {
    try {
      final results = await _searchService.useSavedSearch(savedSearch);
      
      state = state.copyWith(
        query: savedSearch.query,
        filter: savedSearch.filter,
        results: results,
        isSearching: false,
        error: null,
      );
    } catch (error) {
      state = state.copyWith(
        error: error.toString(),
        isSearching: false,
      );
    }
  }
}

/// 現在の検索クエリプロバイダー
final currentSearchQueryProvider = Provider<SearchQuery>((ref) {
  final searchState = ref.watch(searchStateProvider);
  return SearchQuery(
    query: searchState.query,
    filter: searchState.filter,
    sortOrder: searchState.sortOrder,
  );
});

/// 検索候補プロバイダー
final searchSuggestionsProvider = FutureProvider.family<List<String>, String>((ref, query) async {
  if (query.isEmpty) return [];
  
  final searchService = ref.watch(searchServiceImplProvider);
  return await searchService.getAutocompleteSuggestions(query: query);
});

/// 検索フィルターオプションプロバイダー
final searchFilterOptionsProvider = FutureProvider<SearchFilterOptions>((ref) async {
  final searchService = ref.watch(searchServiceImplProvider);
  return await searchService.getFilterOptions();
});

/// 人気検索キーワードプロバイダー
final popularSearchKeywordsProvider = FutureProvider<List<String>>((ref) async {
  final searchService = ref.watch(searchServiceImplProvider);
  return await searchService.getPopularKeywords();
});

/// 検索履歴プロバイダー
final searchHistoryListProvider = FutureProvider<List<SearchHistoryEntry>>((ref) async {
  final searchService = ref.watch(searchServiceImplProvider);
  return await searchService.getSearchHistory();
});

/// 保存された検索リストプロバイダー
final savedSearchListProvider = FutureProvider<List<SavedSearch>>((ref) async {
  final searchService = ref.watch(searchServiceImplProvider);
  return await searchService.getSavedSearches();
});