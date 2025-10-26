import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:minq/core/database/database_lifecycle_manager.dart';
import 'package:minq/core/error/exceptions.dart';
import 'package:minq/domain/quest/quest.dart';
import 'package:minq/domain/user/user.dart';

void main() {
  group('DatabaseLifecycleManager', () {
    late DatabaseLifecycleManager manager;
    
    setUp(() {
      // Reset singleton for each test
      DatabaseLifecycleManager.instance.reset();
      manager = DatabaseLifecycleManager.instance;
    });
    
    tearDown(() async {
      await manager.dispose();
    });
    
    test('should initialize database successfully', () async {
      final schemas = [QuestSchema, UserSchema];
      
      final isar = await manager.initialize(
        schemas: schemas,
        onProgress: (message, progress) {
          expect(message, isA<String>());
          expect(progress, greaterThanOrEqualTo(0.0));
          expect(progress, lessThanOrEqualTo(1.0));
        },
      );
      
      expect(isar, isNotNull);
      expect(manager.isInitialized, isTrue);
    });
    
    test('should return existing instance on second initialization', () async {
      final schemas = [QuestSchema, UserSchema];
      
      final isar1 = await manager.initialize(schemas: schemas);
      final isar2 = await manager.initialize(schemas: schemas);
      
      expect(isar1, same(isar2));
    });
    
    test('should perform health check', () async {
      final schemas = [QuestSchema, UserSchema];
      await manager.initialize(schemas: schemas);
      
      final healthStatus = await manager.performHealthCheck();
      
      expect(healthStatus, isA<DatabaseHealthStatus>());
    });
    
    test('should handle disposal properly', () async {
      final schemas = [QuestSchema, UserSchema];
      await manager.initialize(schemas: schemas);
      
      expect(manager.isInitialized, isTrue);
      
      await manager.dispose();
      
      expect(manager.isInitialized, isFalse);
    });
    
    test('should throw error when disposed', () async {
      await manager.dispose();
      
      expect(
        () => manager.initialize(schemas: []),
        throwsA(isA<DatabaseException>()),
      );
    });
  });
  
  group('EnhancedIsarService', () {
    late EnhancedIsarService service;
    
    setUp(() {
      service = EnhancedIsarService();
    });
    
    tearDown(() async {
      await service.dispose();
    });
    
    test('should initialize with progress callback', () async {
      var progressCalled = false;
      
      final isar = await service.init(
        schemas: [QuestSchema, UserSchema],
        onProgress: (message, progress) {
          progressCalled = true;
        },
      );
      
      expect(isar, isNotNull);
      expect(service.isReady, isTrue);
      expect(progressCalled, isTrue);
    });
    
    test('should check health status', () async {
      await service.init(schemas: [QuestSchema, UserSchema]);
      
      final healthStatus = await service.checkHealth();
      
      expect(healthStatus, isA<DatabaseHealthStatus>());
    });
    
    test('should optimize database', () async {
      await service.init(schemas: [QuestSchema, UserSchema]);
      
      // Should not throw
      await service.optimize();
    });
  });
}