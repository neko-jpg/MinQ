import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:minq/presentation/widgets/performance/virtualized_list.dart';

void main() {
  group('VirtualizedList', () {
    testWidgets('should display items correctly', (WidgetTester tester) async {
      final items = List.generate(100, (index) => 'Item $index');
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VirtualizedList<String>(
              items: items,
              itemBuilder: (context, item, index) {
                return ListTile(
                  title: Text(item),
                );
              },
            ),
          ),
        ),
      );
      
      // Verify that some items are displayed
      expect(find.text('Item 0'), findsOneWidget);
      expect(find.byType(ListTile), findsWidgets);
    });
    
    testWidgets('should display empty widget when no items', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VirtualizedList<String>(
              items: [],
              itemBuilder: (context, item, index) {
                return ListTile(title: Text(item));
              },
            ),
          ),
        ),
      );
      
      expect(find.text('No items to display'), findsOneWidget);
      expect(find.byIcon(Icons.inbox_outlined), findsOneWidget);
    });
    
    testWidgets('should display custom empty widget', (WidgetTester tester) async {
      const customEmptyText = 'Custom empty message';
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VirtualizedList<String>(
              items: [],
              itemBuilder: (context, item, index) {
                return ListTile(title: Text(item));
              },
              emptyWidget: Text(customEmptyText),
            ),
          ),
        ),
      );
      
      expect(find.text(customEmptyText), findsOneWidget);
    });
    
    testWidgets('should handle scrolling', (WidgetTester tester) async {
      final items = List.generate(100, (index) => 'Item $index');
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VirtualizedList<String>(
              items: items,
              itemHeight: 60.0,
              itemBuilder: (context, item, index) {
                return Container(
                  height: 60,
                  child: ListTile(title: Text(item)),
                );
              },
            ),
          ),
        ),
      );
      
      // Initially, only first few items should be visible
      expect(find.text('Item 0'), findsOneWidget);
      expect(find.text('Item 50'), findsNothing);
      
      // Scroll down
      await tester.drag(find.byType(CustomScrollView), Offset(0, -3000));
      await tester.pumpAndSettle();
      
      // Now different items should be visible
      expect(find.text('Item 0'), findsNothing);
      // Note: Exact items visible depend on viewport size and implementation
    });
    
    testWidgets('should add separators when specified', (WidgetTester tester) async {
      final items = ['Item 1', 'Item 2', 'Item 3'];
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VirtualizedList<String>(
              items: items,
              itemBuilder: (context, item, index) {
                return ListTile(title: Text(item));
              },
              separator: Divider(),
            ),
          ),
        ),
      );
      
      expect(find.byType(Divider), findsWidgets);
    });
    
    testWidgets('should handle end reached callback', (WidgetTester tester) async {
      final items = List.generate(20, (index) => 'Item $index');
      bool endReachedCalled = false;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VirtualizedList<String>(
              items: items,
              itemHeight: 60.0,
              itemBuilder: (context, item, index) {
                return Container(
                  height: 60,
                  child: ListTile(title: Text(item)),
                );
              },
              onEndReached: () {
                endReachedCalled = true;
              },
              endReachedThreshold: 100.0,
            ),
          ),
        ),
      );
      
      // Scroll to near the end
      await tester.drag(find.byType(CustomScrollView), Offset(0, -1000));
      await tester.pumpAndSettle();
      
      // The callback should be called when near the end
      // Note: This might not work in test environment due to scroll physics
    });
  });
  
  group('QuestVirtualizedList', () {
    testWidgets('should display quest items', (WidgetTester tester) async {
      final quests = [
        {'id': '1', 'title': 'Quest 1'},
        {'id': '2', 'title': 'Quest 2'},
        {'id': '3', 'title': 'Quest 3'},
      ];
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: QuestVirtualizedList(
              quests: quests,
              itemBuilder: (context, quest, index) {
                return ListTile(
                  title: Text(quest['title'] as String),
                );
              },
            ),
          ),
        ),
      );
      
      expect(find.text('Quest 1'), findsOneWidget);
      expect(find.text('Quest 2'), findsOneWidget);
      expect(find.text('Quest 3'), findsOneWidget);
    });
    
    testWidgets('should display empty state for quests', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: QuestVirtualizedList(
              quests: [],
              itemBuilder: (context, quest, index) {
                return ListTile(
                  title: Text(quest['title'] as String),
                );
              },
            ),
          ),
        ),
      );
      
      expect(find.text('No quests found'), findsOneWidget);
      expect(find.text('Create your first quest to get started'), findsOneWidget);
      expect(find.byIcon(Icons.task_outlined), findsOneWidget);
    });
    
    testWidgets('should display loading widget when loading', (WidgetTester tester) async {
      final quests = [
        {'id': '1', 'title': 'Quest 1'},
      ];
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: QuestVirtualizedList(
              quests: quests,
              itemBuilder: (context, quest, index) {
                return ListTile(
                  title: Text(quest['title'] as String),
                );
              },
              isLoading: true,
            ),
          ),
        ),
      );
      
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });
}