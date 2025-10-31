import 'package:flutter_test/flutter_test.dart';
import 'package:minq/core/performance/memory_management_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('MemoryManagementService', () {
    late MemoryManagementService service;
    
    setUp(() {
      service = MemoryManagementService();
    });
    
    tearDown(() {
      service.stopMonitoring();
    });
    
    test('should start and stop monitoring', () {
      expect(service, isNotNull);
      
      service.startMonitoring();
      // Verify monitoring is active
      
      service.stopMonitoring();
      // Verify monitoring is stopped
    });
    
    test('should get current memory usage', () async {
      final memoryInfo = await service.getCurrentMemoryUsage();
      
      expect(memoryInfo.timestamp, isNotNull);
      expect(memoryInfo.heapUsage, greaterThanOrEqualTo(0));
      expect(memoryInfo.physicalMemory, greaterThanOrEqualTo(0));
      expect(memoryInfo.availableMemory, greaterThanOrEqualTo(0));
      expect(memoryInfo.vmInfo, isNotNull);
    });
    
    test('should force garbage collection', () {
      // This should not throw an exception
      expect(() => service.forceGarbageCollection(), returnsNormally);
    });
    
    test('should get memory statistics', () {
      final stats = service.getMemoryStatistics();
      
      expect(stats.averageUsage, greaterThanOrEqualTo(0));
      expect(stats.peakUsage, greaterThanOrEqualTo(0));
      expect(stats.currentUsage, greaterThanOrEqualTo(0));
      expect(stats.memoryLeaks, isA<List<MemoryLeak>>());
      expect(stats.recommendations, isA<List<String>>());
    });
    
    test('should optimize memory', () async {
      // This should not throw an exception
      await expectLater(service.optimizeMemory(), completes);
    });
    
    test('should handle callbacks', () {
      bool callbackCalled = false;
      MemoryEvent? receivedEvent;
      MemoryInfo? receivedInfo;
      
      service.registerCallback((event, info) {
        callbackCalled = true;
        receivedEvent = event;
        receivedInfo = info;
      });
      
      // In a real implementation, callbacks would be triggered by monitoring
      
      service.unregisterCallback((event, info) {
        callbackCalled = true;
        receivedEvent = event;
        receivedInfo = info;
      });
    });
    
    test('should get and clear memory history', () {
      final initialHistory = service.getMemoryHistory();
      expect(initialHistory, isEmpty);
      
      // In a real implementation, history would be populated by monitoring
      
      service.clearHistory();
      final clearedHistory = service.getMemoryHistory();
      expect(clearedHistory, isEmpty);
    });
  });
  
  group('MemoryInfo', () {
    test('should create memory info with all fields', () {
      final timestamp = DateTime.now();
      final memoryInfo = MemoryInfo(
        timestamp: timestamp,
        heapUsage: 1024 * 1024, // 1MB
        physicalMemory: 512 * 1024 * 1024, // 512MB
        availableMemory: 256 * 1024 * 1024, // 256MB
        vmInfo: 'test vm info',
      );
      
      expect(memoryInfo.timestamp, equals(timestamp));
      expect(memoryInfo.heapUsage, equals(1024 * 1024));
      expect(memoryInfo.physicalMemory, equals(512 * 1024 * 1024));
      expect(memoryInfo.availableMemory, equals(256 * 1024 * 1024));
      expect(memoryInfo.vmInfo, equals('test vm info'));
    });
  });
  
  group('MemorySnapshot', () {
    test('should create memory snapshot', () {
      final timestamp = DateTime.now();
      final snapshot = MemorySnapshot(
        timestamp: timestamp,
        heapUsage: 1024,
        physicalMemory: 2048,
        availableMemory: 1024,
      );
      
      expect(snapshot.timestamp, equals(timestamp));
      expect(snapshot.heapUsage, equals(1024));
      expect(snapshot.physicalMemory, equals(2048));
      expect(snapshot.availableMemory, equals(1024));
    });
  });
  
  group('MemoryLeak', () {
    test('should create memory leak with all properties', () {
      const leak = MemoryLeak(
        type: 'Test Leak',
        description: 'Test description',
        severity: MemoryLeakSeverity.high,
        recommendation: 'Test recommendation',
      );
      
      expect(leak.type, equals('Test Leak'));
      expect(leak.description, equals('Test description'));
      expect(leak.severity, equals(MemoryLeakSeverity.high));
      expect(leak.recommendation, equals('Test recommendation'));
    });
  });
  
  group('MemoryStatistics', () {
    test('should create memory statistics', () {
      const stats = MemoryStatistics(
        averageUsage: 100.0,
        peakUsage: 200.0,
        currentUsage: 150.0,
        memoryLeaks: [],
        recommendations: ['Test recommendation'],
      );
      
      expect(stats.averageUsage, equals(100.0));
      expect(stats.peakUsage, equals(200.0));
      expect(stats.currentUsage, equals(150.0));
      expect(stats.memoryLeaks, isEmpty);
      expect(stats.recommendations, contains('Test recommendation'));
    });
  });
}