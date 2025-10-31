import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:minq/core/search/search_engine.dart';
import 'package:minq/core/search/search_history_service.dart';
import 'package:minq/domain/quest/quest.dart';

/// 検索サービス
class SearchService {
  final SearchEngine _searchEngine;
  final SearchHistoryService _historyService;
  final Isar _isar;
  
  SearchService({
    required SearchEngine searchEngine,
    required SearchHistoryService historyService,
    required Isar isar,
  }) : _searchEngine = searchEngine,
       _historyService = historyService,
       _isar = isar;
  
  /// 初期化
  Future<void> initialize() async {
    await _historyService.initialize();
    await _rebuildIndex();
  }
  
  /// インデックスを再構築
  Future<void> _rebuildIndex() async {
    _searchEngine.clearIndex();
    
    // クエストをインデックスに追加
    final quests = await _isar.quests.where().findAll();
    for (final quest in quests) {
      _searchEngine.addToIndex(SearchableQuest(quest));
    }
    
    // チャレンジをインデックスに追加（実装されている場合）
    // TODO: チャレンジのIsarコレクションが実装されたら追加
  }
  
  /// 検索を実行
  Future<List<SearchResult>> search({
    required String query,
    SearchFilter? filter,
    SearchSortOrder sortOrder = SearchSortOrder.relevance,
    int limit = 50,
    bool saveToHistory = true,
  }) async {
    final results = await _searchEngine.search(
      query: query,
      filter: filter,
      sortOrder: sortOrder,
      limit: limit,
    );
    
    // 検索履歴に保存
    if (saveToHistory && (query.isNotEmpty || !(filter?.isEmpty ?? true))) {
      await _historyService.addToHistory(
        query: query,
        filter: filter ?? const SearchFilter(),
        resultCount: results.length,
      );
    }
    
    return results;
  }
  
  /// インクリメンタル検索
  Stream<List<SearchResult>> searchIncremental({
    required String query,
    SearchFilter? filter,
    SearchSortOrder sortOrder = SearchSortOrder.relevance,
    int limit = 20,
    Duration debounce = const Duration(milliseconds: 300),
  }) {
    return Stream.fromFuture(
      Future.delayed(debounce, () => search(
        query: query,
        filter: filter,
        sortOrder: sortOrder,
        limit: limit,
        saveToHistory: false, // インクリメンタル検索は履歴に保存しない
      ))
    );
  }
  
  /// オートコンプリート候補を取得
  Future<List<String>> getAutocompleteSuggestions({
    required String query,
    int limit = 10,
  }) async {
    final engineSuggestions = _searchEngine.generateAutocompleteSuggestions(
      query: query,
      limit: limit ~/ 2,
    );
    
    final recentQueries = await _historyService.getRecentQueries(
      limit: limit ~/ 2,
    );
    
    final allSuggestions = <String>[];
    
    // 最近の検索から候補を追加
    for (final recent in recentQueries) {
      if (recent.toLowerCase().contains(query.toLowerCase()) && 
          !allSuggestions.contains(recent)) {
        allSuggestions.add(recent);
      }
    }
    
    // エンジンからの候補を追加
    for (final suggestion in engineSuggestions) {
      if (!allSuggestions.contains(suggestion)) {
        allSuggestions.add(suggestion);
      }
    }
    
    return allSuggestions.take(limit).toList();
  }
  
  /// 人気検索キーワードを取得
  Future<List<String>> getPopularKeywords({int limit = 10}) async {
    final engineKeywords = _searchEngine.getPopularKeywords(limit: limit ~/ 2);
    final historyKeywords = await _historyService.getPopularQueries(limit: limit ~/ 2);
    
    final allKeywords = <String>[];
    allKeywords.addAll(historyKeywords);
    
    for (final keyword in engineKeywords) {
      if (!allKeywords.contains(keyword)) {
        allKeywords.add(keyword);
      }
    }
    
    return allKeywords.take(limit).toList();
  }
  
  /// 利用可能なフィルターオプションを取得
  Future<SearchFilterOptions> getFilterOptions() async {
    final quests = await _isar.quests.where().findAll();
    
    final categories = <String>{};
    final difficulties = <String>{};
    final locations = <String>{};
    final statuses = <String>{};
    
    for (final quest in quests) {
      categories.add(quest.category);
      if (quest.difficulty != null) difficulties.add(quest.difficulty!);
      if (quest.location != null) locations.add(quest.location!);
      statuses.add(quest.status.name);
    }
    
    return SearchFilterOptions(
      categories: categories.toList()..sort(),
      difficulties: difficulties.toList()..sort(),
      locations: locations.toList()..sort(),
      statuses: statuses.toList()..sort(),
    );
  }
  
  /// クエストを追加（インデックスを更新）
  Future<void> addQuest(Quest quest) async {
    _searchEngine.addToIndex(SearchableQuest(quest));
  }
  
  /// クエストを更新（インデックスを更新）
  Future<void> updateQuest(Quest quest) async {
    _searchEngine.removeFromIndex(quest.id.toString());
    _searchEngine.addToIndex(SearchableQuest(quest));
  }
  
  /// クエストを削除（インデックスから削除）
  Future<void> removeQuest(String questId) async {
    _searchEngine.removeFromIndex(questId);
  }
  
  /// 検索履歴を取得
  Future<List<SearchHistoryEntry>> getSearchHistory() async {
    return await _historyService.getHistory();
  }
  
  /// 検索履歴をクリア
  Future<void> clearSearchHistory() async {
    await _historyService.clearHistory();
  }
  
  /// 検索を保存
  Future<void> saveSearch({
    required String name,
    required String query,
    required SearchFilter filter,
  }) async {
    await _historyService.saveSearch(
      name: name,
      query: query,
      filter: filter,
    );
  }
  
  /// 保存された検索を取得
  Future<List<SavedSearch>> getSavedSearches() async {
    return await _historyService.getSavedSearches();
  }
  
  /// 保存された検索を使用
  Future<List<SearchResult>> useSavedSearch(SavedSearch savedSearch) async {
    await _historyService.useSavedSearch(savedSearch.id);
    
    return await search(
      query: savedSearch.query,
      filter: savedSearch.filter,
      saveToHistory: true,
    );
  }
  
  /// 保存された検索を削除
  Future<void> deleteSavedSearch(String searchId) async {
    await _historyService.deleteSavedSearch(searchId);
  }
  
  void dispose() {
    _searchEngine.dispose();
  }
}

/// 検索フィルターオプション
class SearchFilterOptions {
  final List<String> categories;
  final List<String> difficulties;
  final List<String> locations;
  final List<String> statuses;
  
  const SearchFilterOptions({
    required this.categories,
    required this.difficulties,
    required this.locations,
    required this.statuses,
  });
}

/// 検索サービスプロバイダー
final searchServiceProvider = Provider<SearchService>((ref) {
  throw UnimplementedError('SearchService must be overridden');
});

/// 検索結果プロバイダー
final searchResultsProvider = StreamProvider.family<List<SearchResult>, SearchQuery>(
  (ref, query) {
    final searchService = ref.watch(searchServiceProvider);
    
    if (query.query.isEmpty && (query.filter?.isEmpty ?? true)) {
      return Stream.value([]);
    }
    
    return searchService.searchIncremental(
      query: query.query,
      filter: query.filter,
      sortOrder: query.sortOrder,
      limit: query.limit,
    );
  },
);

/// オートコンプリート候補プロバイダー
final autocompleteSuggestionsProvider = FutureProvider.family<List<String>, String>(
  (ref, query) async {
    if (query.isEmpty) return [];
    
    final searchService = ref.watch(searchServiceProvider);
    return await searchService.getAutocompleteSuggestions(query: query);
  },
);

/// 人気キーワードプロバイダー
final popularKeywordsProvider = FutureProvider<List<String>>((ref) async {
  final searchService = ref.watch(searchServiceProvider);
  return await searchService.getPopularKeywords();
});

/// フィルターオプションプロバイダー
final filterOptionsProvider = FutureProvider<SearchFilterOptions>((ref) async {
  final searchService = ref.watch(searchServiceProvider);
  return await searchService.getFilterOptions();
});

/// 検索履歴プロバイダー
final searchHistoryProvider = FutureProvider<List<SearchHistoryEntry>>((ref) async {
  final searchService = ref.watch(searchServiceProvider);
  return await searchService.getSearchHistory();
});

/// 保存された検索プロバイダー
final savedSearchesProvider = FutureProvider<List<SavedSearch>>((ref) async {
  final searchService = ref.watch(searchServiceProvider);
  return await searchService.getSavedSearches();
});

/// 検索クエリ
class SearchQuery {
  final String query;
  final SearchFilter? filter;
  final SearchSortOrder sortOrder;
  final int limit;
  
  const SearchQuery({
    required this.query,
    this.filter,
    this.sortOrder = SearchSortOrder.relevance,
    this.limit = 50,
  });
  
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SearchQuery &&
          runtimeType == other.runtimeType &&
          query == other.query &&
          filter == other.filter &&
          sortOrder == other.sortOrder &&
          limit == other.limit;
  
  @override
  int get hashCode =>
      query.hashCode ^
      filter.hashCode ^
      sortOrder.hashCode ^
      limit.hashCode;
}