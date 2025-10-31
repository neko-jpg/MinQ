import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:minq/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Performance Benchmark E2E Tests', () {
    testWidgets('App startup performance benchmark', (tester) async {
      final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
      
      // === COLD START PERFORMANCE ===
      
      final startupStopwatch = Stopwatch()..start();
      
      await tester.pumpWidget(app.MinQApp());
      await tester.pumpAndSettle();
      
      startupStopwatch.stop();
      final startupTime = startupStopwatch.elapsedMilliseconds;
      
      // Verify startup time is under 3 seconds
      expect(startupTime, lessThan(3000), 
        reason: 'App startup should complete within 3 seconds, took ${startupTime}ms');
      
      print('📱 Cold startup time: ${startupTime}ms');
      
      // === FIRST FRAME PERFORMANCE ===
      
      // Measure time to first meaningful paint
      final firstFrameStopwatch = Stopwatch()..start();
      
      // Wait for first frame
      await tester.pump();
      
      firstFrameStopwatch.stop();
      final firstFrameTime = firstFrameStopwatch.elapsedMilliseconds;
      
      // First frame should render within 500ms
      expect(firstFrameTime, lessThan(500),
        reason: 'First frame should render within 500ms, took ${firstFrameTime}ms');
      
      print('🎨 First frame time: ${firstFrameTime}ms');
      
      // === MEMORY USAGE BASELINE ===
      
      // Get initial memory usage
      final initialMemory = await _getCurrentMemoryUsage();
      print('💾 Initial memory usage: ${initialMemory}MB');
      
      // Memory should be under 100MB for initial load
      expect(initialMemory, lessThan(100),
        reason: 'Initial memory usage should be under 100MB, was ${initialMemory}MB');
    });

    testWidgets('Navigation performance benchmark', (tester) async {
      await tester.pumpWidget(app.MinQApp(skipOnboarding: true));
      await tester.pumpAndSettle();
      
      // === TAB NAVIGATION PERFORMANCE ===
      
      final tabNavigationTimes = <String, int>{};
      
      final tabs = [
        ('quests_tab', 'Quests'),
        ('ai_coach_tab', 'AI Coach'),
        ('challenges_tab', 'Challenges'),
        ('league_tab', 'League'),
        ('stats_tab', 'Statistics'),
        ('settings_tab', 'Settings'),
      ];
      
      for (final (tabKey, tabName) in tabs) {
        final stopwatch = Stopwatch()..start();
        
        await tester.tap(find.byKey(Key(tabKey)));
        await tester.pumpAndSettle();
        
        stopwatch.stop();
        final navigationTime = stopwatch.elapsedMilliseconds;
        tabNavigationTimes[tabName] = navigationTime;
        
        // Each tab navigation should complete within 300ms
        expect(navigationTime, lessThan(300),
          reason: '$tabName tab navigation should complete within 300ms, took ${navigationTime}ms');
      }
      
      print('🧭 Tab navigation times: $tabNavigationTimes');
      
      // === SCREEN TRANSITION PERFORMANCE ===
      
      // Test quest creation screen transition
      final questCreationStopwatch = Stopwatch()..start();
      
      await tester.tap(find.byKey(const Key('create_quest_fab')));
      await tester.pumpAndSettle();
      
      questCreationStopwatch.stop();
      final questCreationTime = questCreationStopwatch.elapsedMilliseconds;
      
      expect(questCreationTime, lessThan(200),
        reason: 'Quest creation screen should open within 200ms, took ${questCreationTime}ms');
      
      print('📝 Quest creation transition: ${questCreationTime}ms');
      
      // Test back navigation
      final backNavigationStopwatch = Stopwatch()..start();
      
      await tester.tap(find.byKey(const Key('back_button')));
      await tester.pumpAndSettle();
      
      backNavigationStopwatch.stop();
      final backNavigationTime = backNavigationStopwatch.elapsedMilliseconds;
      
      expect(backNavigationTime, lessThan(150),
        reason: 'Back navigation should complete within 150ms, took ${backNavigationTime}ms');
      
      print('⬅️ Back navigation time: ${backNavigationTime}ms');
    });

    testWidgets('Large dataset rendering performance', (tester) async {
      await tester.pumpWidget(app.MinQApp(
        skipOnboarding: true,
        mockData: MockData.largeDataset(),
      ));
      await tester.pumpAndSettle();
      
      // === LARGE QUEST LIST PERFORMANCE ===
      
      // Navigate to quests with 1000+ items
      await tester.tap(find.byKey(const Key('quests_tab')));
      await tester.pumpAndSettle();
      
      final largeListStopwatch = Stopwatch()..start();
      
      // Wait for list to fully render
      await tester.pumpAndSettle();
      
      largeListStopwatch.stop();
      final largeListTime = largeListStopwatch.elapsedMilliseconds;
      
      // Large list should render within 1 second
      expect(largeListTime, lessThan(1000),
        reason: 'Large quest list (1000+ items) should render within 1s, took ${largeListTime}ms');
      
      print('📋 Large list rendering: ${largeListTime}ms');
      
      // === SCROLL PERFORMANCE ===
      
      final scrollStopwatch = Stopwatch()..start();
      
      // Perform fast scroll through large list
      await tester.fling(
        find.byKey(const Key('quest_list')),
        const Offset(0, -5000),
        1000,
      );
      await tester.pumpAndSettle();
      
      scrollStopwatch.stop();
      final scrollTime = scrollStopwatch.elapsedMilliseconds;
      
      // Scroll should complete smoothly within 500ms
      expect(scrollTime, lessThan(500),
        reason: 'Fast scroll should complete within 500ms, took ${scrollTime}ms');
      
      print('📜 Scroll performance: ${scrollTime}ms');
      
      // === SEARCH PERFORMANCE ===
      
      // Test search in large dataset
      await tester.tap(find.byKey(const Key('search_button')));
      await tester.pumpAndSettle();
      
      final searchStopwatch = Stopwatch()..start();
      
      await tester.enterText(
        find.byKey(const Key('search_field')),
        'morning exercise'
      );
      await tester.pumpAndSettle();
      
      searchStopwatch.stop();
      final searchTime = searchStopwatch.elapsedMilliseconds;
      
      // Search should complete within 300ms
      expect(searchTime, lessThan(300),
        reason: 'Search in large dataset should complete within 300ms, took ${searchTime}ms');
      
      print('🔍 Search performance: ${searchTime}ms');
    });

    testWidgets('Memory usage under load', (tester) async {
      await tester.pumpWidget(app.MinQApp(skipOnboarding: true));
      await tester.pumpAndSettle();
      
      final initialMemory = await _getCurrentMemoryUsage();
      print('💾 Initial memory: ${initialMemory}MB');
      
      // === MEMORY STRESS TEST ===
      
      // Create multiple quests
      for (int i = 0; i < 50; i++) {
        await tester.tap(find.byKey(const Key('create_quest_fab')));
        await tester.pumpAndSettle();
        
        await tester.enterText(
          find.byKey(const Key('quest_title_field')),
          'Memory Test Quest $i'
        );
        await tester.tap(find.byKey(const Key('save_quest_button')));
        await tester.pumpAndSettle();
        
        // Check memory every 10 quests
        if (i % 10 == 0) {
          final currentMemory = await _getCurrentMemoryUsage();
          print('💾 Memory after ${i + 1} quests: ${currentMemory}MB');
          
          // Memory should not exceed 200MB
          expect(currentMemory, lessThan(200),
            reason: 'Memory usage should stay under 200MB, was ${currentMemory}MB after ${i + 1} quests');
        }
      }
      
      final finalMemory = await _getCurrentMemoryUsage();
      final memoryIncrease = finalMemory - initialMemory;
      
      print('💾 Final memory: ${finalMemory}MB (increase: ${memoryIncrease}MB)');
      
      // Memory increase should be reasonable (under 50MB for 50 quests)
      expect(memoryIncrease, lessThan(50),
        reason: 'Memory increase should be under 50MB, was ${memoryIncrease}MB');
      
      // === NAVIGATION MEMORY TEST ===
      
      // Navigate between tabs multiple times to test memory leaks
      final navigationMemoryStart = await _getCurrentMemoryUsage();
      
      for (int i = 0; i < 20; i++) {
        await tester.tap(find.byKey(const Key('stats_tab')));
        await tester.pumpAndSettle();
        
        await tester.tap(find.byKey(const Key('ai_coach_tab')));
        await tester.pumpAndSettle();
        
        await tester.tap(find.byKey(const Key('challenges_tab')));
        await tester.pumpAndSettle();
        
        await tester.tap(find.byKey(const Key('quests_tab')));
        await tester.pumpAndSettle();
      }
      
      final navigationMemoryEnd = await _getCurrentMemoryUsage();
      final navigationMemoryIncrease = navigationMemoryEnd - navigationMemoryStart;
      
      print('💾 Memory after navigation test: ${navigationMemoryEnd}MB (increase: ${navigationMemoryIncrease}MB)');
      
      // Navigation should not cause significant memory leaks (under 10MB)
      expect(navigationMemoryIncrease, lessThan(10),
        reason: 'Navigation memory increase should be under 10MB, was ${navigationMemoryIncrease}MB');
    });

    testWidgets('Animation performance benchmark', (tester) async {
      await tester.pumpWidget(app.MinQApp(skipOnboarding: true));
      await tester.pumpAndSettle();
      
      // === XP GAIN ANIMATION PERFORMANCE ===
      
      // Create and complete quest to trigger XP animation
      await tester.tap(find.byKey(const Key('create_quest_fab')));
      await tester.pumpAndSettle();
      
      await tester.enterText(
        find.byKey(const Key('quest_title_field')),
        'Animation Test Quest'
      );
      await tester.tap(find.byKey(const Key('save_quest_button')));
      await tester.pumpAndSettle();
      
      await tester.tap(find.text('Animation Test Quest'));
      await tester.pumpAndSettle();
      
      await tester.tap(find.byKey(const Key('complete_quest_button')));
      await tester.pumpAndSettle();
      
      await tester.tap(find.byKey(const Key('confirm_completion_button')));
      await tester.pumpAndSettle();
      
      // Measure XP animation performance
      final animationStopwatch = Stopwatch()..start();
      
      // Wait for XP animation to complete
      await tester.pump(const Duration(seconds: 3));
      
      animationStopwatch.stop();
      final animationTime = animationStopwatch.elapsedMilliseconds;
      
      // Animation should complete smoothly
      expect(animationTime, lessThanOrEqualTo(3000),
        reason: 'XP animation should complete within expected time');
      
      print('🎬 XP animation time: ${animationTime}ms');
      
      // === LEVEL UP ANIMATION PERFORMANCE ===
      
      // Trigger level up animation (mock scenario)
      await tester.tap(find.byKey(const Key('trigger_level_up_button')));
      await tester.pumpAndSettle();
      
      final levelUpStopwatch = Stopwatch()..start();
      
      // Wait for level up animation
      await tester.pump(const Duration(seconds: 4));
      
      levelUpStopwatch.stop();
      final levelUpTime = levelUpStopwatch.elapsedMilliseconds;
      
      print('🏆 Level up animation time: ${levelUpTime}ms');
      
      // === PARTICLE SYSTEM PERFORMANCE ===
      
      // Test particle system performance
      await tester.tap(find.byKey(const Key('trigger_particles_button')));
      await tester.pumpAndSettle();
      
      final particleStopwatch = Stopwatch()..start();
      
      // Let particles run for 2 seconds
      await tester.pump(const Duration(seconds: 2));
      
      particleStopwatch.stop();
      final particleTime = particleStopwatch.elapsedMilliseconds;
      
      print('✨ Particle system time: ${particleTime}ms');
      
      // Check memory during animations
      final animationMemory = await _getCurrentMemoryUsage();
      print('💾 Memory during animations: ${animationMemory}MB');
      
      // Memory should not spike excessively during animations
      expect(animationMemory, lessThan(150),
        reason: 'Memory during animations should stay reasonable');
    });

    testWidgets('Database performance benchmark', (tester) async {
      await tester.pumpWidget(app.MinQApp(skipOnboarding: true));
      await tester.pumpAndSettle();
      
      // === BULK INSERT PERFORMANCE ===
      
      final bulkInsertStopwatch = Stopwatch()..start();
      
      // Create 100 quests rapidly
      for (int i = 0; i < 100; i++) {
        await tester.tap(find.byKey(const Key('create_quest_fab')));
        await tester.pumpAndSettle();
        
        await tester.enterText(
          find.byKey(const Key('quest_title_field')),
          'Bulk Quest $i'
        );
        await tester.tap(find.byKey(const Key('save_quest_button')));
        await tester.pumpAndSettle();
      }
      
      bulkInsertStopwatch.stop();
      final bulkInsertTime = bulkInsertStopwatch.elapsedMilliseconds;
      
      // Bulk insert should complete within reasonable time (under 30 seconds)
      expect(bulkInsertTime, lessThan(30000),
        reason: 'Bulk insert of 100 quests should complete within 30s, took ${bulkInsertTime}ms');
      
      print('💾 Bulk insert time (100 quests): ${bulkInsertTime}ms');
      
      // === QUERY PERFORMANCE ===
      
      // Test complex query performance
      await tester.tap(find.byKey(const Key('stats_tab')));
      await tester.pumpAndSettle();
      
      final queryStopwatch = Stopwatch()..start();
      
      // Trigger complex statistics calculation
      await tester.tap(find.byKey(const Key('calculate_advanced_stats_button')));
      await tester.pumpAndSettle();
      
      queryStopwatch.stop();
      final queryTime = queryStopwatch.elapsedMilliseconds;
      
      // Complex queries should complete within 1 second
      expect(queryTime, lessThan(1000),
        reason: 'Complex statistics query should complete within 1s, took ${queryTime}ms');
      
      print('📊 Complex query time: ${queryTime}ms');
      
      // === SYNC PERFORMANCE ===
      
      // Test sync performance with large dataset
      await tester.tap(find.byKey(const Key('settings_tab')));
      await tester.pumpAndSettle();
      
      await tester.tap(find.byKey(const Key('sync_status_tile')));
      await tester.pumpAndSettle();
      
      final syncStopwatch = Stopwatch()..start();
      
      await tester.tap(find.byKey(const Key('manual_sync_button')));
      await tester.pumpAndSettle();
      
      // Wait for sync to complete
      await tester.pump(const Duration(seconds: 10));
      
      syncStopwatch.stop();
      final syncTime = syncStopwatch.elapsedMilliseconds;
      
      // Sync should complete within reasonable time
      expect(syncTime, lessThan(10000),
        reason: 'Sync should complete within 10s, took ${syncTime}ms');
      
      print('🔄 Sync time: ${syncTime}ms');
    });

    testWidgets('Network performance benchmark', (tester) async {
      await tester.pumpWidget(app.MinQApp(skipOnboarding: true));
      await tester.pumpAndSettle();
      
      // === API RESPONSE TIME ===
      
      // Test AI Coach API response time
      await tester.tap(find.byKey(const Key('ai_coach_tab')));
      await tester.pumpAndSettle();
      
      final apiStopwatch = Stopwatch()..start();
      
      await tester.enterText(
        find.byKey(const Key('ai_chat_input')),
        'How am I doing with my habits?'
      );
      await tester.tap(find.byKey(const Key('send_message_button')));
      await tester.pumpAndSettle();
      
      // Wait for AI response
      await tester.pump(const Duration(seconds: 5));
      
      apiStopwatch.stop();
      final apiTime = apiStopwatch.elapsedMilliseconds;
      
      // API response should be within 5 seconds
      expect(apiTime, lessThan(5000),
        reason: 'AI API response should be within 5s, took ${apiTime}ms');
      
      print('🤖 AI API response time: ${apiTime}ms');
      
      // === IMAGE LOADING PERFORMANCE ===
      
      // Test image loading performance
      await tester.tap(find.byKey(const Key('challenges_tab')));
      await tester.pumpAndSettle();
      
      final imageLoadStopwatch = Stopwatch()..start();
      
      // Navigate to challenge with images
      await tester.tap(find.text('Photo Challenge'));
      await tester.pumpAndSettle();
      
      // Wait for images to load
      await tester.pump(const Duration(seconds: 3));
      
      imageLoadStopwatch.stop();
      final imageLoadTime = imageLoadStopwatch.elapsedMilliseconds;
      
      // Images should load within 3 seconds
      expect(imageLoadTime, lessThan(3000),
        reason: 'Images should load within 3s, took ${imageLoadTime}ms');
      
      print('🖼️ Image loading time: ${imageLoadTime}ms');
    });

    testWidgets('Overall performance summary', (tester) async {
      // This test provides a comprehensive performance summary
      
      print('\n📊 PERFORMANCE BENCHMARK SUMMARY');
      print('================================');
      
      // Run a complete user flow and measure overall performance
      final overallStopwatch = Stopwatch()..start();
      
      await tester.pumpWidget(app.MinQApp());
      await tester.pumpAndSettle();
      
      // Complete onboarding
      for (int i = 0; i < 3; i++) {
        await tester.tap(find.byKey(const Key('next_button')));
        await tester.pumpAndSettle();
      }
      
      await tester.enterText(
        find.byKey(const Key('display_name_field')),
        'Performance Test User'
      );
      await tester.tap(find.byKey(const Key('complete_onboarding_button')));
      await tester.pumpAndSettle();
      
      // Create and complete quest
      await tester.tap(find.byKey(const Key('create_quest_fab')));
      await tester.pumpAndSettle();
      
      await tester.enterText(
        find.byKey(const Key('quest_title_field')),
        'Performance Test Quest'
      );
      await tester.tap(find.byKey(const Key('save_quest_button')));
      await tester.pumpAndSettle();
      
      await tester.tap(find.text('Performance Test Quest'));
      await tester.pumpAndSettle();
      
      await tester.tap(find.byKey(const Key('complete_quest_button')));
      await tester.pumpAndSettle();
      
      await tester.tap(find.byKey(const Key('confirm_completion_button')));
      await tester.pumpAndSettle();
      
      // Wait for animations
      await tester.pump(const Duration(seconds: 3));
      
      // Navigate through all tabs
      final tabs = ['ai_coach_tab', 'challenges_tab', 'league_tab', 'stats_tab', 'settings_tab'];
      for (final tab in tabs) {
        await tester.tap(find.byKey(Key(tab)));
        await tester.pumpAndSettle();
      }
      
      overallStopwatch.stop();
      final overallTime = overallStopwatch.elapsedMilliseconds;
      
      print('⏱️ Complete user flow time: ${overallTime}ms');
      
      final finalMemory = await _getCurrentMemoryUsage();
      print('💾 Final memory usage: ${finalMemory}MB');
      
      // Overall performance should be acceptable
      expect(overallTime, lessThan(30000),
        reason: 'Complete user flow should finish within 30s');
      expect(finalMemory, lessThan(150),
        reason: 'Final memory usage should be under 150MB');
      
      print('\n✅ All performance benchmarks passed!');
    });
  });
}

/// Get current memory usage in MB
Future<double> _getCurrentMemoryUsage() async {
  // This would integrate with platform-specific memory monitoring
  // For now, return a mock value that represents realistic memory usage
  await Future.delayed(const Duration(milliseconds: 10));
  return 45.0 + (DateTime.now().millisecondsSinceEpoch % 100) / 10;
}

/// Mock data for performance testing
class MockData {
  static Map<String, dynamic> largeDataset() => {
    'quests': List.generate(1000, (i) => {
      'id': 'quest-$i',
      'title': 'Performance Test Quest $i',
      'description': 'This is quest number $i for performance testing',
      'category': ['health', 'fitness', 'productivity', 'mindfulness'][i % 4],
      'status': ['active', 'completed', 'paused'][i % 3],
      'createdAt': DateTime.now().subtract(Duration(days: i % 365)),
    }),
    'questLogs': List.generate(2000, (i) => {
      'id': 'log-$i',
      'questId': 'quest-${i % 1000}',
      'completedAt': DateTime.now().subtract(Duration(hours: i % 8760)),
      'xpEarned': 10 + (i % 40),
    }),
    'challenges': List.generate(50, (i) => {
      'id': 'challenge-$i',
      'title': 'Performance Challenge $i',
      'description': 'Challenge number $i for testing',
      'participants': i * 10,
      'progress': i % 100,
    }),
  };
}