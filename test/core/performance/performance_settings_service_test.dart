import 'package:flutter_test/flutter_test.dart';
import 'package:minq/core/performance/performance_settings_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  
  group('PerformanceSettingsService', () {
    late PerformanceSettingsService service;
    
    setUp(() {
      service = PerformanceSettingsService();
    });
    
    test('should get default settings', () async {
      final settings = await service.getSettings();
      
      expect(settings.animationsEnabled, isTrue);
      expect(settings.particleEffectsEnabled, isTrue);
      expect(settings.heavyAnimationsEnabled, isTrue);
      expect(settings.imageOptimizationEnabled, isTrue);
      expect(settings.lazyLoadingEnabled, isTrue);
      expect(settings.performanceMode, equals(PerformanceMode.balanced));
      expect(settings.frameRateLimit, equals(60));
      expect(settings.memoryOptimizationEnabled, isTrue);
      expect(settings.batteryOptimizationEnabled, isTrue);
      expect(settings.networkOptimizationEnabled, isTrue);
    });
    
    test('should update settings', () async {
      final newSettings = PerformanceSettings(
        animationsEnabled: false,
        particleEffectsEnabled: false,
        heavyAnimationsEnabled: false,
        imageOptimizationEnabled: true,
        lazyLoadingEnabled: true,
        performanceMode: PerformanceMode.battery,
        frameRateLimit: 30,
        memoryOptimizationEnabled: true,
        batteryOptimizationEnabled: true,
        networkOptimizationEnabled: true,
      );
      
      await service.updateSettings(newSettings);
      
      final updatedSettings = await service.getSettings();
      expect(updatedSettings.animationsEnabled, isFalse);
      expect(updatedSettings.particleEffectsEnabled, isFalse);
      expect(updatedSettings.heavyAnimationsEnabled, isFalse);
      expect(updatedSettings.performanceMode, equals(PerformanceMode.battery));
      expect(updatedSettings.frameRateLimit, equals(30));
    });
    
    test('should set individual settings', () async {
      await service.setAnimationsEnabled(false);
      await service.setParticleEffectsEnabled(false);
      await service.setHeavyAnimationsEnabled(false);
      
      final settings = await service.getSettings();
      expect(settings.animationsEnabled, isFalse);
      expect(settings.particleEffectsEnabled, isFalse);
      expect(settings.heavyAnimationsEnabled, isFalse);
    });
    
    test('should set performance mode', () async {
      await service.setPerformanceMode(PerformanceMode.performance);
      
      final settings = await service.getSettings();
      expect(settings.performanceMode, equals(PerformanceMode.performance));
    });
    
    test('should apply performance mode presets', () async {
      // Test performance preset
      await service.applyPerformanceModePreset(PerformanceMode.performance);
      var settings = await service.getSettings();
      expect(settings.performanceMode, equals(PerformanceMode.performance));
      expect(settings.frameRateLimit, equals(120));
      expect(settings.memoryOptimizationEnabled, isFalse);
      expect(settings.batteryOptimizationEnabled, isFalse);
      
      // Test battery preset
      await service.applyPerformanceModePreset(PerformanceMode.battery);
      settings = await service.getSettings();
      expect(settings.performanceMode, equals(PerformanceMode.battery));
      expect(settings.animationsEnabled, isFalse);
      expect(settings.particleEffectsEnabled, isFalse);
      expect(settings.heavyAnimationsEnabled, isFalse);
      expect(settings.frameRateLimit, equals(30));
      
      // Test balanced preset
      await service.applyPerformanceModePreset(PerformanceMode.balanced);
      settings = await service.getSettings();
      expect(settings.performanceMode, equals(PerformanceMode.balanced));
      expect(settings.animationsEnabled, isTrue);
      expect(settings.frameRateLimit, equals(60));
    });
    
    test('should get recommendations', () async {
      final recommendations = await service.getRecommendations();
      
      expect(recommendations, isA<List<PerformanceRecommendation>>());
      // Recommendations depend on device characteristics, so we just check the type
    });
    
    test('should auto-optimize settings', () async {
      await expectLater(service.autoOptimize(), completes);
      
      final settings = await service.getSettings();
      expect(settings, isA<PerformanceSettings>());
    });
    
    test('should reset to defaults', () async {
      // First change some settings
      await service.setAnimationsEnabled(false);
      await service.setPerformanceMode(PerformanceMode.battery);
      
      // Reset to defaults
      await service.resetToDefaults();
      
      final settings = await service.getSettings();
      expect(settings.animationsEnabled, isTrue);
      expect(settings.performanceMode, equals(PerformanceMode.balanced));
    });
    
    test('should provide settings stream', () async {
      final stream = service.settingsStream;
      expect(stream, isA<Stream<PerformanceSettings>>());
      
      // Update settings and verify stream emits
      bool streamEmitted = false;
      final subscription = stream.listen((settings) {
        streamEmitted = true;
      });
      
      await service.setAnimationsEnabled(false);
      
      // Give some time for stream to emit
      await Future.delayed(Duration(milliseconds: 100));
      
      expect(streamEmitted, isTrue);
      await subscription.cancel();
    });
  });
  
  group('PerformanceSettings', () {
    test('should create default settings', () {
      final settings = PerformanceSettings.defaultSettings();
      
      expect(settings.animationsEnabled, isTrue);
      expect(settings.performanceMode, equals(PerformanceMode.balanced));
      expect(settings.frameRateLimit, equals(60));
    });
    
    test('should create performance preset', () {
      final settings = PerformanceSettings.performancePreset();
      
      expect(settings.performanceMode, equals(PerformanceMode.performance));
      expect(settings.frameRateLimit, equals(120));
      expect(settings.memoryOptimizationEnabled, isFalse);
      expect(settings.batteryOptimizationEnabled, isFalse);
    });
    
    test('should create balanced preset', () {
      final settings = PerformanceSettings.balancedPreset();
      
      expect(settings.performanceMode, equals(PerformanceMode.balanced));
      expect(settings.frameRateLimit, equals(60));
      expect(settings.animationsEnabled, isTrue);
    });
    
    test('should create battery preset', () {
      final settings = PerformanceSettings.batteryPreset();
      
      expect(settings.performanceMode, equals(PerformanceMode.battery));
      expect(settings.animationsEnabled, isFalse);
      expect(settings.particleEffectsEnabled, isFalse);
      expect(settings.heavyAnimationsEnabled, isFalse);
      expect(settings.frameRateLimit, equals(30));
    });
    
    test('should copy with new values', () {
      final original = PerformanceSettings.defaultSettings();
      
      final copied = original.copyWith(
        animationsEnabled: false,
        performanceMode: PerformanceMode.battery,
      );
      
      expect(copied.animationsEnabled, isFalse);
      expect(copied.performanceMode, equals(PerformanceMode.battery));
      expect(copied.frameRateLimit, equals(original.frameRateLimit));
    });
  });
  
  group('PerformanceRecommendation', () {
    test('should create recommendation with all fields', () {
      bool actionCalled = false;
      
      final recommendation = PerformanceRecommendation(
        type: RecommendationType.memory,
        title: 'Test Recommendation',
        description: 'Test description',
        action: () => actionCalled = true,
        priority: RecommendationPriority.high,
      );
      
      expect(recommendation.type, equals(RecommendationType.memory));
      expect(recommendation.title, equals('Test Recommendation'));
      expect(recommendation.description, equals('Test description'));
      expect(recommendation.priority, equals(RecommendationPriority.high));
      
      recommendation.action();
      expect(actionCalled, isTrue);
    });
  });
  
  group('DevicePerformanceInfo', () {
    test('should create device info with all fields', () {
      const deviceInfo = DevicePerformanceInfo(
        availableMemory: 4096,
        cpuCores: 8,
        batteryLevel: 0.75,
        isOnSlowNetwork: false,
        maxRefreshRate: 120,
        performanceScore: 85,
      );
      
      expect(deviceInfo.availableMemory, equals(4096));
      expect(deviceInfo.cpuCores, equals(8));
      expect(deviceInfo.batteryLevel, equals(0.75));
      expect(deviceInfo.isOnSlowNetwork, isFalse);
      expect(deviceInfo.maxRefreshRate, equals(120));
      expect(deviceInfo.performanceScore, equals(85));
    });
  });
}