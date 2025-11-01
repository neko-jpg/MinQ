import 'package:flutter_test/flutter_test.dart';
import 'package:minq/core/performance/startup_optimization_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('StartupOptimizationService', () {
    late StartupOptimizationService service;

    setUp(() {
      service = StartupOptimizationService();
    });

    test('should initialize successfully', () async {
      await expectLater(service.initialize(), completes);
    });

    test('should register and execute preload tasks', () async {
      bool taskExecuted = false;

      final task = TestStartupTask(
        name: 'Test Task',
        priority: 5,
        onExecute: () async {
          taskExecuted = true;
        },
      );

      service.registerPreloadTask(task);
      await service.initialize();

      // Give some time for tasks to execute
      await Future.delayed(Duration(milliseconds: 100));

      expect(taskExecuted, isTrue);
    });

    test('should register and execute deferred tasks', () async {
      bool taskExecuted = false;

      final task = TestStartupTask(
        name: 'Deferred Task',
        priority: 3,
        onExecute: () async {
          taskExecuted = true;
        },
      );

      service.registerDeferredTask(task);
      await service.initialize();

      // Give time for deferred tasks to execute
      await Future.delayed(Duration(seconds: 3));

      expect(taskExecuted, isTrue);
    });

    test('should get startup metrics', () {
      final metrics = service.getStartupMetrics();

      expect(metrics.appStartTime, isNotNull);
      expect(metrics.startupDuration, isA<Duration>());
      expect(metrics.timeToFirstFrame, isA<Duration>());
      expect(metrics.preloadTasksCount, greaterThanOrEqualTo(0));
      expect(metrics.deferredTasksCount, greaterThanOrEqualTo(0));
    });

    test('should mark first frame rendered', () {
      service.markFirstFrameRendered();

      final metrics = service.getStartupMetrics();
      expect(metrics.firstFrameTime, isNotNull);
      expect(metrics.timeToFirstFrame.inMilliseconds, greaterThanOrEqualTo(0));
    });

    test('should store and retrieve preloaded data', () {
      const key = 'test_data';
      const value = 'test_value';

      service.setPreloadedData(key, value);
      final retrievedValue = service.getPreloadedData<String>(key);

      expect(retrievedValue, equals(value));
    });

    test('should optimize for next startup', () async {
      await expectLater(service.optimizeForNextStartup(), completes);
    });

    test('should get startup recommendations', () async {
      final recommendations = await service.getStartupRecommendations();

      expect(recommendations, isA<List<String>>());
      expect(recommendations, isNotEmpty);
    });

    test('should get and update settings', () async {
      await service.setPreloadDataEnabled(false);
      await service.setLazyLoadingEnabled(false);

      final settings = await service.getSettings();

      expect(settings.preloadDataEnabled, isFalse);
      expect(settings.lazyLoadingEnabled, isFalse);
      expect(settings.coldStartCount, greaterThanOrEqualTo(0));
    });
  });

  group('StartupMetrics', () {
    test('should create startup metrics with all fields', () {
      final now = DateTime.now();
      final metrics = StartupMetrics(
        appStartTime: now,
        firstFrameTime: now.add(Duration(milliseconds: 500)),
        startupDuration: Duration(seconds: 2),
        timeToFirstFrame: Duration(milliseconds: 500),
        preloadTasksCount: 3,
        deferredTasksCount: 2,
        preloadedDataSize: 5,
      );

      expect(metrics.appStartTime, equals(now));
      expect(metrics.firstFrameTime, isNotNull);
      expect(metrics.startupDuration.inSeconds, equals(2));
      expect(metrics.timeToFirstFrame.inMilliseconds, equals(500));
      expect(metrics.preloadTasksCount, equals(3));
      expect(metrics.deferredTasksCount, equals(2));
      expect(metrics.preloadedDataSize, equals(5));
    });
  });

  group('StartupOptimizationSettings', () {
    test('should create settings with all fields', () {
      const settings = StartupOptimizationSettings(
        preloadDataEnabled: true,
        lazyLoadingEnabled: false,
        coldStartCount: 5,
        lastStartupTime: 1234567890,
      );

      expect(settings.preloadDataEnabled, isTrue);
      expect(settings.lazyLoadingEnabled, isFalse);
      expect(settings.coldStartCount, equals(5));
      expect(settings.lastStartupTime, equals(1234567890));
    });
  });
}

// Test implementation of StartupTask
class TestStartupTask extends StartupTask {
  final String _name;
  final int _priority;
  final Future<void> Function() onExecute;

  TestStartupTask({
    required String name,
    required int priority,
    required this.onExecute,
  }) : _name = name,
       _priority = priority;

  @override
  String get name => _name;

  @override
  int get priority => _priority;

  @override
  Future<void> execute() => onExecute();
}
