import 'package:flutter_test/flutter_test.dart';
import 'package:minq/core/database/database_performance_monitor.dart';

void main() {
  group('DatabasePerformanceMonitor', () {
    late DatabasePerformanceMonitor monitor;
    
    setUp(() {
      monitor = DatabasePerformanceMonitor.instance;
      monitor.clearData();
    });
    
    tearDown(() {
      monitor.dispose();
    });
    
    test('should record operation timing', () {
      const operationType = 'test_operation';
      const duration = Duration(milliseconds: 100);
      
      monitor.recordOperation(operationType, duration);
      
      final report = monitor.getPerformanceReport();
      expect(report.operationCounts[operationType], equals(1));
      expect(report.operationStatistics[operationType], isNotNull);
    });
    
    test('should generate performance alerts for slow operations', () {
      const operationType = 'slow_operation';
      const slowDuration = Duration(seconds: 3); // Very slow
      
      monitor.recordOperation(operationType, slowDuration);
      
      final alerts = monitor.getRecentAlerts();
      expect(alerts, isNotEmpty);
      expect(alerts.first.type, equals(AlertType.verySlowOperation));
    });
    
    test('should calculate statistics correctly', () {
      const operationType = 'test_operation';
      
      // Record multiple operations
      monitor.recordOperation(operationType, const Duration(milliseconds: 100));
      monitor.recordOperation(operationType, const Duration(milliseconds: 200));
      monitor.recordOperation(operationType, const Duration(milliseconds: 300));
      
      final report = monitor.getPerformanceReport();
      final stats = report.operationStatistics[operationType]!;
      
      expect(stats.averageDuration.inMilliseconds, equals(200));
      expect(stats.minDuration.inMilliseconds, equals(100));
      expect(stats.maxDuration.inMilliseconds, equals(300));
    });
    
    test('should start and stop monitoring', () {
      expect(monitor.startMonitoring, returnsNormally);
      expect(monitor.stopMonitoring, returnsNormally);
    });
    
    test('should clear data', () {
      monitor.recordOperation('test', const Duration(milliseconds: 100));
      
      var report = monitor.getPerformanceReport();
      expect(report.operationCounts, isNotEmpty);
      
      monitor.clearData();
      
      report = monitor.getPerformanceReport();
      expect(report.operationCounts, isEmpty);
    });
  });
  
  group('DatabasePerformanceTracking mixin', () {
    late TestClassWithTracking testClass;
    
    setUp(() {
      testClass = TestClassWithTracking();
      DatabasePerformanceMonitor.instance.clearData();
    });
    
    test('should track async operation performance', () async {
      const operationType = 'async_test';
      
      final result = await testClass.trackOperation(
        operationType,
        () async {
          await Future.delayed(const Duration(milliseconds: 50));
          return 'success';
        },
      );
      
      expect(result, equals('success'));
      
      final report = DatabasePerformanceMonitor.instance.getPerformanceReport();
      expect(report.operationCounts[operationType], equals(1));
    });
    
    test('should track sync operation performance', () {
      const operationType = 'sync_test';
      
      final result = testClass.trackSyncOperation(
        operationType,
        () => 'success',
      );
      
      expect(result, equals('success'));
      
      final report = DatabasePerformanceMonitor.instance.getPerformanceReport();
      expect(report.operationCounts[operationType], equals(1));
    });
    
    test('should track failed operations', () async {
      const operationType = 'failing_test';
      
      try {
        await testClass.trackOperation(
          operationType,
          () async => throw Exception('Test error'),
        );
      } catch (e) {
        // Expected to throw
      }
      
      final report = DatabasePerformanceMonitor.instance.getPerformanceReport();
      expect(report.operationCounts['${operationType}_failed'], equals(1));
    });
  });
}

/// Test class that uses the performance tracking mixin
class TestClassWithTracking with DatabasePerformanceTracking {
  // Mixin methods are available for testing
}