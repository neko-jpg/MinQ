import 'dart:convert';

import 'package:minq/core/search/search_engine.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 保存された検索
class SavedSearch {
  final String id;
  final String name;
  final String query;
  final SearchFilter filter;
  final DateTime createdAt;
  final DateTime lastUsedAt;
  final int useCount;

  const SavedSearch({
    required this.id,
    required this.name,
    required this.query,
    required this.filter,
    required this.createdAt,
    required this.lastUsedAt,
    required this.useCount,
  });

  SavedSearch copyWith({
    String? id,
    String? name,
    String? query,
    SearchFilter? filter,
    DateTime? createdAt,
    DateTime? lastUsedAt,
    int? useCount,
  }) {
    return SavedSearch(
      id: id ?? this.id,
      name: name ?? this.name,
      query: query ?? this.query,
      filter: filter ?? this.filter,
      createdAt: createdAt ?? this.createdAt,
      lastUsedAt: lastUsedAt ?? this.lastUsedAt,
      useCount: useCount ?? this.useCount,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'query': query,
      'filter': _filterToJson(filter),
      'createdAt': createdAt.toIso8601String(),
      'lastUsedAt': lastUsedAt.toIso8601String(),
      'useCount': useCount,
    };
  }

  factory SavedSearch.fromJson(Map<String, dynamic> json) {
    return SavedSearch(
      id: json['id'],
      name: json['name'],
      query: json['query'],
      filter: _filterFromJson(json['filter']),
      createdAt: DateTime.parse(json['createdAt']),
      lastUsedAt: DateTime.parse(json['lastUsedAt']),
      useCount: json['useCount'],
    );
  }

  static Map<String, dynamic> _filterToJson(SearchFilter filter) {
    return {
      'categories': filter.categories,
      'tags': filter.tags,
      'dateRange':
          filter.dateRange != null
              ? {
                'start': filter.dateRange!.start.toIso8601String(),
                'end': filter.dateRange!.end.toIso8601String(),
              }
              : null,
      'difficulty': filter.difficulty,
      'location': filter.location,
      'status': filter.status,
    };
  }

  static SearchFilter _filterFromJson(Map<String, dynamic> json) {
    return SearchFilter(
      categories: List<String>.from(json['categories'] ?? []),
      tags: List<String>.from(json['tags'] ?? []),
      dateRange:
          json['dateRange'] != null
              ? DateRange(
                start: DateTime.parse(json['dateRange']['start']),
                end: DateTime.parse(json['dateRange']['end']),
              )
              : null,
      difficulty: json['difficulty'],
      location: json['location'],
      status: json['status'],
    );
  }
}

/// 検索履歴エントリ
class SearchHistoryEntry {
  final String query;
  final SearchFilter filter;
  final DateTime timestamp;
  final int resultCount;

  const SearchHistoryEntry({
    required this.query,
    required this.filter,
    required this.timestamp,
    required this.resultCount,
  });

  Map<String, dynamic> toJson() {
    return {
      'query': query,
      'filter': SavedSearch._filterToJson(filter),
      'timestamp': timestamp.toIso8601String(),
      'resultCount': resultCount,
    };
  }

  factory SearchHistoryEntry.fromJson(Map<String, dynamic> json) {
    return SearchHistoryEntry(
      query: json['query'],
      filter: SavedSearch._filterFromJson(json['filter']),
      timestamp: DateTime.parse(json['timestamp']),
      resultCount: json['resultCount'],
    );
  }
}

/// 検索履歴・保存検索管理サービス
class SearchHistoryService {
  static const String _historyKey = 'search_history';
  static const String _savedSearchesKey = 'saved_searches';
  static const int _maxHistorySize = 50;
  static const int _maxSavedSearches = 20;

  SharedPreferences? _prefs;

  /// 初期化
  Future<void> initialize() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  /// 検索履歴に追加
  Future<void> addToHistory({
    required String query,
    required SearchFilter filter,
    required int resultCount,
  }) async {
    await initialize();

    if (query.trim().isEmpty) return;

    final entry = SearchHistoryEntry(
      query: query.trim(),
      filter: filter,
      timestamp: DateTime.now(),
      resultCount: resultCount,
    );

    final history = await getHistory();

    // 重複を削除（同じクエリとフィルター）
    history.removeWhere(
      (existing) =>
          existing.query == entry.query &&
          _filtersEqual(existing.filter, entry.filter),
    );

    // 新しいエントリを先頭に追加
    history.insert(0, entry);

    // サイズ制限
    if (history.length > _maxHistorySize) {
      history.removeRange(_maxHistorySize, history.length);
    }

    await _saveHistory(history);
  }

  /// 検索履歴を取得
  Future<List<SearchHistoryEntry>> getHistory() async {
    await initialize();

    final historyJson = _prefs!.getStringList(_historyKey) ?? [];
    return historyJson
        .map((json) => SearchHistoryEntry.fromJson(jsonDecode(json)))
        .toList();
  }

  /// 検索履歴をクリア
  Future<void> clearHistory() async {
    await initialize();
    await _prefs!.remove(_historyKey);
  }

  /// 検索履歴から削除
  Future<void> removeFromHistory(SearchHistoryEntry entry) async {
    await initialize();

    final history = await getHistory();
    history.removeWhere(
      (existing) =>
          existing.query == entry.query &&
          existing.timestamp == entry.timestamp,
    );

    await _saveHistory(history);
  }

  /// 検索を保存
  Future<void> saveSearch({
    required String name,
    required String query,
    required SearchFilter filter,
  }) async {
    await initialize();

    final savedSearch = SavedSearch(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name.trim(),
      query: query.trim(),
      filter: filter,
      createdAt: DateTime.now(),
      lastUsedAt: DateTime.now(),
      useCount: 1,
    );

    final savedSearches = await getSavedSearches();

    // 重複チェック（同じ名前）
    savedSearches.removeWhere((existing) => existing.name == savedSearch.name);

    // 新しい検索を追加
    savedSearches.insert(0, savedSearch);

    // サイズ制限
    if (savedSearches.length > _maxSavedSearches) {
      savedSearches.removeRange(_maxSavedSearches, savedSearches.length);
    }

    await _saveSavedSearches(savedSearches);
  }

  /// 保存された検索を取得
  Future<List<SavedSearch>> getSavedSearches() async {
    await initialize();

    final savedSearchesJson = _prefs!.getStringList(_savedSearchesKey) ?? [];
    return savedSearchesJson
        .map((json) => SavedSearch.fromJson(jsonDecode(json)))
        .toList();
  }

  /// 保存された検索を使用（使用回数を増やす）
  Future<void> useSavedSearch(String searchId) async {
    await initialize();

    final savedSearches = await getSavedSearches();
    final index = savedSearches.indexWhere((search) => search.id == searchId);

    if (index != -1) {
      final updatedSearch = savedSearches[index].copyWith(
        lastUsedAt: DateTime.now(),
        useCount: savedSearches[index].useCount + 1,
      );

      savedSearches[index] = updatedSearch;

      // 使用頻度でソート
      savedSearches.sort((a, b) => b.useCount.compareTo(a.useCount));

      await _saveSavedSearches(savedSearches);
    }
  }

  /// 保存された検索を削除
  Future<void> deleteSavedSearch(String searchId) async {
    await initialize();

    final savedSearches = await getSavedSearches();
    savedSearches.removeWhere((search) => search.id == searchId);

    await _saveSavedSearches(savedSearches);
  }

  /// 保存された検索を更新
  Future<void> updateSavedSearch(SavedSearch updatedSearch) async {
    await initialize();

    final savedSearches = await getSavedSearches();
    final index = savedSearches.indexWhere(
      (search) => search.id == updatedSearch.id,
    );

    if (index != -1) {
      savedSearches[index] = updatedSearch;
      await _saveSavedSearches(savedSearches);
    }
  }

  /// 人気検索クエリを取得
  Future<List<String>> getPopularQueries({int limit = 10}) async {
    final history = await getHistory();

    final queryCount = <String, int>{};
    for (final entry in history) {
      queryCount[entry.query] = (queryCount[entry.query] ?? 0) + 1;
    }

    final sortedQueries =
        queryCount.entries.toList()..sort((a, b) => b.value.compareTo(a.value));

    return sortedQueries.take(limit).map((entry) => entry.key).toList();
  }

  /// 最近の検索クエリを取得
  Future<List<String>> getRecentQueries({int limit = 5}) async {
    final history = await getHistory();
    final uniqueQueries = <String>[];

    for (final entry in history) {
      if (!uniqueQueries.contains(entry.query)) {
        uniqueQueries.add(entry.query);
        if (uniqueQueries.length >= limit) break;
      }
    }

    return uniqueQueries;
  }

  /// 検索履歴を保存
  Future<void> _saveHistory(List<SearchHistoryEntry> history) async {
    final historyJson =
        history.map((entry) => jsonEncode(entry.toJson())).toList();
    await _prefs!.setStringList(_historyKey, historyJson);
  }

  /// 保存された検索を保存
  Future<void> _saveSavedSearches(List<SavedSearch> savedSearches) async {
    final savedSearchesJson =
        savedSearches.map((search) => jsonEncode(search.toJson())).toList();
    await _prefs!.setStringList(_savedSearchesKey, savedSearchesJson);
  }

  /// フィルターが等しいかチェック
  bool _filtersEqual(SearchFilter a, SearchFilter b) {
    return a.categories.length == b.categories.length &&
        a.categories.every((cat) => b.categories.contains(cat)) &&
        a.tags.length == b.tags.length &&
        a.tags.every((tag) => b.tags.contains(tag)) &&
        a.difficulty == b.difficulty &&
        a.location == b.location &&
        a.status == b.status &&
        ((a.dateRange == null && b.dateRange == null) ||
            (a.dateRange != null &&
                b.dateRange != null &&
                a.dateRange!.start == b.dateRange!.start &&
                a.dateRange!.end == b.dateRange!.end));
  }
}
