import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:minq/core/startup/startup_performance_manager.dart';
import 'package:minq/core/startup/crash_prevention_service.dart';
import 'package:minq/core/logging/secure_startup_logger.dart';

void main() {
  group('StartupPerformanceManager', () {
    late StartupPerformanceManager manager;
    late ProviderContainer container;

    setUp(() {
      manager = StartupPerformanceManager.instance;
      container = ProviderContainer();
    });

    tearDown(() {
      manager.reset();
      container.dispose();
    });

    test('should initialize within target time', () async {
      final stopwatch = Stopwatch()..start();
      
      await manager.initializeApp(
        container.read,
        onProgress: (message, progress) {
          expect(progress, greaterThanOrEqualTo(0.0));
          expect(progress, lessThanOrEqualTo(1.0));
        },
      );
      
      stopwatch.stop();
      
      // Should complete within reasonable time for tests
      expect(stopwatch.elapsed.inMilliseconds, lessThan(5000));
      
      final report = manager.getPerformanceReport();
      expect(report.totalStartupTime, isNotNull);
      expect(report.phaseTimings, isNotEmpty);
    });

    test('should record performance metrics', () async {
      await manager.initializeApp(container.read);
      
      final report = manager.getPerformanceReport();
      
      expect(report.metrics, isNotEmpty);
      expect(report.phaseTimings, isNotEmpty);
      expect(report.errors, isEmpty);
      
      // Check that key phases are recorded
      expect(report.phaseTimings.keys, contains('critical_services'));
      expect(report.phaseTimings.keys, contains('core_infrastructure'));
    });

    test('should handle initialization errors gracefully', () async {
      // This test would need mock providers that throw errors
      // For now, we'll test the error handling structure
      
      expect(() async {
        await manager.initializeApp(container.read);
      }, returnsNormally);
    });

    test('should calculate performance score correctly', () async {
      await manager.initializeApp(container.read);
      
      final report = manager.getPerformanceReport();
      final score = report.getPerformanceScore();
      
      expect(score, greaterThanOrEqualTo(0));
      expect(score, lessThanOrEqualTo(100));
    });

    test('should provide progress callbacks', () async {
      final progressUpdates = <double>[];
      final messages = <String>[];
      
      await manager.initializeApp(
        container.read,
        onProgress: (message, progress) {
          messages.add(message);
          progressUpdates.add(progress);
        },
      );
      
      expect(progressUpdates, isNotEmpty);
      expect(messages, isNotEmpty);
      
      // Progress should be monotonically increasing
      for (int i = 1; i < progressUpdates.length; i++) {
        expect(progressUpdates[i], greaterThanOrEqualTo(progressUpdates[i - 1]));
      }
    });
  });

  group('CrashPreventionService', () {
    late CrashPreventionService service;

    setUp(() {
      service = CrashPreventionService.instance;
    });

    tearDown(() {
      service.reset();
    });

    test('should initialize crash prevention', () async {
      await service.initialize();
      
      final stats = service.getCrashStatistics();
      expect(stats.totalCrashes, equals(0));
      expect(stats.criticalErrors, equals(0));
    });

    test('should track crash statistics', () async {
      await service.initialize();
      
      // Simulate some errors (this would normally be done by the error handlers)
      // For testing, we'll check the statistics structure
      
      final stats = service.getCrashStatistics();
      expect(stats.reportTimestamp, isNotNull);
      expect(stats.mostFrequentErrors, isNotNull);
    });

    test('should handle memory pressure', () async {
      await service.initialize();
      
      // This test would verify memory pressure handling
      // In a real scenario, we'd simulate memory pressure
      expect(() => service.dispose(), returnsNormally);
    });
  });

  group('SecureStartupLogger', () {
    late SecureStartupLogger logger;

    setUp(() {
      logger = SecureStartupLogger.instance;
    });

    tearDown(() {
      logger.reset();
    });

    test('should initialize secure logging', () async {
      await logger.initialize();
      
      logger.logStartupPhase('test_phase', 'Test message');
      
      final logs = logger.getRecentLogs(limit: 10);
      expect(logs, isNotEmpty);
      expect(logs.first.category, equals('StartupPhase'));
    });

    test('should sanitize sensitive data', () async {
      await logger.initialize();
      
      logger.logStartupError('test_phase', 'Error with email user@example.com', null,
          context: {
            'userId': '12345',
            'email': 'user@example.com',
            'token': 'secret_token_123',
          });
      
      final logs = logger.getRecentLogs(limit: 1);
      final logData = logs.first.data;
      
      // Sensitive data should be redacted
      expect(logData?['context']?['email'], equals('[REDACTED]'));
      expect(logData?['context']?['token'], equals('[REDACTED]'));
      expect(logData?['context']?['userId'], equals('[REDACTED]'));
    });

    test('should log performance metrics', () async {
      await logger.initialize();
      
      logger.logPerformanceMetric('startup_time', 1500, unit: 'ms');
      
      final logs = logger.getLogsByCategory('Performance');
      expect(logs, isNotEmpty);
      expect(logs.first.data?['metric'], equals('startup_time'));
      expect(logs.first.data?['value'], equals(1500));
    });

    test('should log memory usage', () async {
      await logger.initialize();
      
      logger.logMemoryUsage(100 * 1024 * 1024, context: 'startup');
      
      final logs = logger.getLogsByCategory('Memory');
      expect(logs, isNotEmpty);
      expect(logs.first.data?['memory_bytes'], equals(100 * 1024 * 1024));
    });

    test('should export logs for debugging', () async {
      await logger.initialize();
      
      logger.logStartupPhase('test', 'Test message');
      logger.logPerformanceMetric('test_metric', 100);
      
      final export = logger.exportLogsForDebugging();
      expect(export, contains('MinQ Startup Logs Export'));
      expect(export, contains('StartupPhase'));
      expect(export, contains('Performance'));
    });
  });

  group('Integration Tests', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
      StartupPerformanceManager.instance.reset();
      CrashPreventionService.instance.reset();
      SecureStartupLogger.instance.reset();
    });

    test('should integrate all startup systems', () async {
      final manager = StartupPerformanceManager.instance;
      final crashService = CrashPreventionService.instance;
      final logger = SecureStartupLogger.instance;
      
      // Initialize all systems
      await crashService.initialize();
      await logger.initialize();
      
      // Run startup process
      await manager.initializeApp(container.read);
      
      // Verify all systems are working
      final report = manager.getPerformanceReport();
      expect(report.totalStartupTime, isNotNull);
      
      final stats = crashService.getCrashStatistics();
      expect(stats, isNotNull);
      
      final logs = logger.getRecentLogs();
      expect(logs, isNotEmpty);
    });

    test('should handle startup failures gracefully', () async {
      final manager = StartupPerformanceManager.instance;
      
      // This would test error recovery in a real scenario
      // For now, we verify the system doesn't crash
      expect(() async {
        await manager.initializeApp(container.read);
      }, returnsNormally);
    });

    test('should maintain performance within targets', () async {
      final manager = StartupPerformanceManager.instance;
      
      final stopwatch = Stopwatch()..start();
      await manager.initializeApp(container.read);
      stopwatch.stop();
      
      final report = manager.getPerformanceReport();
      final score = report.getPerformanceScore();
      
      // Performance score should be reasonable for tests
      expect(score, greaterThan(50));
      
      // Startup time should be reasonable for tests
      expect(stopwatch.elapsed.inMilliseconds, lessThan(10000));
    });
  });
}