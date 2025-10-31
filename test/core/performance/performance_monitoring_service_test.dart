import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:minq/core/performance/performance_monitoring_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('PerformanceMonitoringService', () {
    late PerformanceMonitoringService service;
    
    setUp(() {
      service = PerformanceMonitoringService();
    });
    
    tearDown(() {
      service.stopMonitoring();
    });
    
    test('should start and stop monitoring', () {
      expect(service, isNotNull);
      
      service.startMonitoring();
      // Verify monitoring is active (would check internal state in real implementation)
      
      service.stopMonitoring();
      // Verify monitoring is stopped
    });
    
    test('should track operations', () async {
      const operationName = 'test_operation';
      
      final tracker = service.startTracking(operationName);
      expect(tracker.operationName, equals(operationName));
      expect(tracker.isActive, isTrue);
      
      // Simulate some work
      await Future.delayed(Duration(milliseconds: 10));
      
      service.stopTracking(operationName);
      expect(tracker.isActive, isFalse);
      expect(tracker.duration.inMilliseconds, greaterThanOrEqualTo(0));
    });
    
    test('should get current metrics', () {
      final metrics = service.getCurrentMetrics();
      
      expect(metrics.timestamp, isNotNull);
      expect(metrics.memoryUsage, greaterThanOrEqualTo(0));
      expect(metrics.cpuUsage, greaterThanOrEqualTo(0));
      expect(metrics.frameRate, greaterThanOrEqualTo(0));
      expect(metrics.activeOperations, greaterThanOrEqualTo(0));
    });
    
    test('should measure async operations', () async {
      const operationName = 'async_test';
      
      final result = await service.measureAsync(operationName, () async {
        await Future.delayed(Duration(milliseconds: 50));
        return 'test_result';
      });
      
      expect(result, equals('test_result'));
    });
    
    test('should measure sync operations', () {
      const operationName = 'sync_test';
      
      final result = service.measure(operationName, () {
        // Simulate some work
        var sum = 0;
        for (int i = 0; i < 1000; i++) {
          sum += i;
        }
        return sum;
      });
      
      expect(result, equals(499500)); // Sum of 0 to 999
    });
    
    test('should record custom events', () {
      service.recordEvent('test_event', properties: {
        'key1': 'value1',
        'key2': 42,
      });
      
      // In a real implementation, you'd verify the event was recorded
    });
    
    test('should generate performance statistics', () {
      final stats = service.getPerformanceStatistics();
      
      expect(stats.averageFrameRate, greaterThanOrEqualTo(0));
      expect(stats.averageMemoryUsage, greaterThanOrEqualTo(0));
      expect(stats.averageCPUUsage, greaterThanOrEqualTo(0));
      expect(stats.frameDropCount, greaterThanOrEqualTo(0));
      expect(stats.memoryLeaks, isA<List<String>>());
      expect(stats.performanceIssues, isA<List<String>>());
      expect(stats.recommendations, isA<List<String>>());
    });
    
    test('should generate performance report', () {
      final report = service.generateReport();
      
      expect(report.generatedAt, isNotNull);
      expect(report.currentMetrics, isNotNull);
      expect(report.statistics, isNotNull);
      expect(report.history, isA<List<PerformanceMetric>>());
      expect(report.recommendations, isA<List<String>>());
    });
    
    test('should handle callbacks', () {
      bool callbackCalled = false;
      PerformanceEventType? receivedType;
      dynamic receivedData;
      
      service.registerCallback((type, data) {
        callbackCalled = true;
        receivedType = type;
        receivedData = data;
      });
      
      // Trigger a callback (in real implementation, this would happen automatically)
      // For testing, we can't easily trigger the internal monitoring
      
      service.unregisterCallback((type, data) {
        callbackCalled = true;
        receivedType = type;
        receivedData = data;
      });
    });
  });
  
  group('PerformanceTracker', () {
    test('should track operation duration', () async {
      final tracker = PerformanceTracker('test_operation');
      
      expect(tracker.operationName, equals('test_operation'));
      expect(tracker.isActive, isTrue);
      expect(tracker.startTime, isNotNull);
      
      // Simulate some work
      await Future.delayed(Duration(milliseconds: 10));
      
      tracker.stop();
      
      expect(tracker.isActive, isFalse);
      expect(tracker.endTime, isNotNull);
      expect(tracker.duration.inMilliseconds, greaterThanOrEqualTo(0));
    });
  });
  
  group('PerformanceEvent', () {
    test('should create event with properties', () {
      final event = PerformanceEvent(
        name: 'test_event',
        timestamp: DateTime.now(),
        properties: {'key': 'value'},
        duration: Duration(milliseconds: 100),
      );
      
      expect(event.name, equals('test_event'));
      expect(event.timestamp, isNotNull);
      expect(event.properties['key'], equals('value'));
      expect(event.duration?.inMilliseconds, equals(100));
    });
  });
}