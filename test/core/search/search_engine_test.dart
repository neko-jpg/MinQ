import 'package:flutter_test/flutter_test.dart';
import 'package:minq/core/search/search_engine.dart';

// テスト用のシンプルな検索可能アイテム
class TestSearchableItem implements SearchableItem {
  @override
  final String id;
  
  @override
  final String title;
  
  @override
  final String description;
  
  @override
  final List<String> tags;
  
  @override
  final String category;
  
  @override
  final DateTime createdAt;
  
  @override
  final DateTime? updatedAt;
  
  TestSearchableItem({
    required this.id,
    required this.title,
    required this.description,
    required this.tags,
    required this.category,
    required this.createdAt,
    this.updatedAt,
  });
  
  @override
  List<String> get searchKeywords => [
    title.toLowerCase(),
    description.toLowerCase(),
    category.toLowerCase(),
    ...tags.map((tag) => tag.toLowerCase()),
  ];
}

void main() {
  group('SearchEngine', () {
    late SearchEngine searchEngine;
    
    setUp(() {
      searchEngine = SearchEngine();
    });
    
    tearDown(() {
      searchEngine.dispose();
    });
    
    test('should add items to index', () {
      final item = TestSearchableItem(
        id: '1',
        title: 'Test Quest',
        description: 'A test quest for exercise',
        category: 'Exercise',
        tags: ['fitness', 'daily'],
        createdAt: DateTime.now(),
      );
      
      searchEngine.addToIndex(item);
      
      // インデックスに追加されたことを確認するため、検索を実行
      expect(() => searchEngine.search(query: 'Test'), returnsNormally);
    });
    
    test('should search by title', () async {
      final item = TestSearchableItem(
        id: '1',
        title: 'Morning Exercise',
        description: 'Daily morning workout',
        category: 'Fitness',
        tags: ['morning', 'workout'],
        createdAt: DateTime.now(),
      );
      
      searchEngine.addToIndex(item);
      
      final results = await searchEngine.search(query: 'Morning');
      
      expect(results, isNotEmpty);
      expect(results.first.item.title, contains('Morning'));
    });
    
    test('should search by category', () async {
      final item = TestSearchableItem(
        id: '1',
        title: 'Daily Run',
        description: 'Running exercise',
        category: 'Exercise',
        tags: ['running', 'cardio'],
        createdAt: DateTime.now(),
      );
      
      searchEngine.addToIndex(item);
      
      final results = await searchEngine.search(query: 'Exercise');
      
      expect(results, isNotEmpty);
      expect(results.first.item.category, equals('Exercise'));
    });
    
    test('should filter by category', () async {
      final item1 = TestSearchableItem(
        id: '1',
        title: 'Morning Run',
        description: 'Running exercise',
        category: 'Exercise',
        tags: ['running'],
        createdAt: DateTime.now(),
      );
      
      final item2 = TestSearchableItem(
        id: '2',
        title: 'Read Book',
        description: 'Reading activity',
        category: 'Learning',
        tags: ['reading'],
        createdAt: DateTime.now(),
      );
      
      searchEngine.addToIndex(item1);
      searchEngine.addToIndex(item2);
      
      final filter = SearchFilter(categories: ['Exercise']);
      final results = await searchEngine.search(
        query: '',
        filter: filter,
      );
      
      expect(results, hasLength(1));
      expect(results.first.item.category, equals('Exercise'));
    });
    
    test('should generate autocomplete suggestions', () {
      final item = TestSearchableItem(
        id: '1',
        title: 'Morning Exercise',
        description: 'Daily workout',
        category: 'Fitness',
        tags: ['morning', 'workout'],
        createdAt: DateTime.now(),
      );
      
      searchEngine.addToIndex(item);
      
      final suggestions = searchEngine.generateAutocompleteSuggestions(query: 'mor');
      
      expect(suggestions, contains('morning'));
    });
    
    test('should remove items from index', () async {
      final item = TestSearchableItem(
        id: '1',
        title: 'Test Quest',
        description: 'A test quest',
        category: 'Exercise',
        tags: ['test'],
        createdAt: DateTime.now(),
      );
      
      searchEngine.addToIndex(item);
      
      // 検索結果があることを確認
      var results = await searchEngine.search(query: 'Test');
      expect(results, isNotEmpty);
      
      // インデックスから削除
      searchEngine.removeFromIndex(item.id);
      
      // 検索結果がないことを確認
      results = await searchEngine.search(query: 'Test');
      expect(results, isEmpty);
    });
    
    test('should calculate relevance score', () async {
      final item1 = TestSearchableItem(
        id: '1',
        title: 'Morning Exercise',  // タイトルに完全一致
        description: 'Daily workout',
        category: 'Fitness',
        tags: ['workout'],
        createdAt: DateTime.now(),
      );
      
      final item2 = TestSearchableItem(
        id: '2',
        title: 'Daily Routine',
        description: 'Morning habits',  // 説明に一致
        category: 'Habits',
        tags: ['routine'],
        createdAt: DateTime.now(),
      );
      
      searchEngine.addToIndex(item1);
      searchEngine.addToIndex(item2);
      
      final results = await searchEngine.search(query: 'Morning');
      
      expect(results, hasLength(2));
      // タイトル一致の方が関連度が高いはず
      expect(results.first.item.title, equals('Morning Exercise'));
      expect(results.first.relevanceScore, greaterThan(results.last.relevanceScore));
    });
    
    test('should handle empty search query', () async {
      final item = TestSearchableItem(
        id: '1',
        title: 'Test Quest',
        description: 'A test quest',
        category: 'Exercise',
        tags: ['test'],
        createdAt: DateTime.now(),
      );
      
      searchEngine.addToIndex(item);
      
      final results = await searchEngine.search(query: '');
      
      expect(results, isEmpty);
    });
    
    test('should handle search with no results', () async {
      final item = TestSearchableItem(
        id: '1',
        title: 'Test Quest',
        description: 'A test quest',
        category: 'Exercise',
        tags: ['test'],
        createdAt: DateTime.now(),
      );
      
      searchEngine.addToIndex(item);
      
      final results = await searchEngine.search(query: 'NonExistent');
      
      expect(results, isEmpty);
    });
  });
}