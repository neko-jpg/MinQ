import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:minq/core/performance/performance_settings_service.dart';
import 'package:minq/presentation/providers/performance_providers.dart';

class PerformanceSettingsScreen extends ConsumerStatefulWidget {
  const PerformanceSettingsScreen({super.key});

  @override
  ConsumerState<PerformanceSettingsScreen> createState() =>
      _PerformanceSettingsScreenState();
}

class _PerformanceSettingsScreenState
    extends ConsumerState<PerformanceSettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final settingsAsync = ref.watch(performanceSettingsProvider);
    final recommendationsAsync = ref.watch(performanceRecommendationsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Performance Settings'),
        actions: [
          IconButton(
            icon: const Icon(Icons.auto_fix_high),
            onPressed: _autoOptimize,
            tooltip: 'Auto Optimize',
          ),
          PopupMenuButton<String>(
            onSelected: _handleMenuAction,
            itemBuilder:
                (context) => [
                  const PopupMenuItem(
                    value: 'reset',
                    child: Text('Reset to Defaults'),
                  ),
                  const PopupMenuItem(
                    value: 'performance',
                    child: Text('Performance Preset'),
                  ),
                  const PopupMenuItem(
                    value: 'balanced',
                    child: Text('Balanced Preset'),
                  ),
                  const PopupMenuItem(
                    value: 'battery',
                    child: Text('Battery Preset'),
                  ),
                ],
          ),
        ],
      ),
      body: settingsAsync.when(
        data:
            (settings) => _buildSettingsContent(settings, recommendationsAsync),
        loading: () => const Center(child: CircularProgressIndicator()),
        error:
            (error, stack) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Error loading settings: $error'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => ref.refresh(performanceSettingsProvider),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
      ),
    );
  }

  Widget _buildSettingsContent(
    PerformanceSettings settings,
    AsyncValue<List<PerformanceRecommendation>> recommendationsAsync,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Performance Mode Section
          _buildPerformanceModeSection(settings),
          const SizedBox(height: 24),

          // Animation Settings
          _buildAnimationSection(settings),
          const SizedBox(height: 24),

          // Optimization Settings
          _buildOptimizationSection(settings),
          const SizedBox(height: 24),

          // Advanced Settings
          _buildAdvancedSection(settings),
          const SizedBox(height: 24),

          // Recommendations Section
          recommendationsAsync.when(
            data:
                (recommendations) =>
                    _buildRecommendationsSection(recommendations),
            loading: () => _buildLoadingSection('Loading recommendations...'),
            error:
                (error, stack) =>
                    _buildErrorSection('Failed to load recommendations'),
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceModeSection(PerformanceSettings settings) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Performance Mode',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Choose a preset that matches your priorities',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            ...PerformanceMode.values.map(
              (mode) => RadioListTile<PerformanceMode>(
                title: Text(_getPerformanceModeTitle(mode)),
                subtitle: Text(_getPerformanceModeDescription(mode)),
                value: mode,
                groupValue: settings.performanceMode,
                onChanged: (value) => _updatePerformanceMode(value!),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimationSection(PerformanceSettings settings) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Animation Settings',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Enable Animations'),
              subtitle: const Text('Basic UI animations and transitions'),
              value: settings.animationsEnabled,
              onChanged: _updateAnimationsEnabled,
            ),
            SwitchListTile(
              title: const Text('Particle Effects'),
              subtitle: const Text('Visual particle effects and celebrations'),
              value: settings.particleEffectsEnabled,
              onChanged: _updateParticleEffectsEnabled,
            ),
            SwitchListTile(
              title: const Text('Heavy Animations'),
              subtitle: const Text(
                'Complex animations that may impact performance',
              ),
              value: settings.heavyAnimationsEnabled,
              onChanged: _updateHeavyAnimationsEnabled,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptimizationSection(PerformanceSettings settings) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Optimization Settings',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Image Optimization'),
              subtitle: const Text(
                'Compress and cache images for better performance',
              ),
              value: settings.imageOptimizationEnabled,
              onChanged: _updateImageOptimizationEnabled,
            ),
            SwitchListTile(
              title: const Text('Lazy Loading'),
              subtitle: const Text('Load content only when needed'),
              value: settings.lazyLoadingEnabled,
              onChanged: _updateLazyLoadingEnabled,
            ),
            SwitchListTile(
              title: const Text('Memory Optimization'),
              subtitle: const Text('Automatic memory management and cleanup'),
              value: settings.memoryOptimizationEnabled,
              onChanged: _updateMemoryOptimizationEnabled,
            ),
            SwitchListTile(
              title: const Text('Battery Optimization'),
              subtitle: const Text('Reduce battery usage when possible'),
              value: settings.batteryOptimizationEnabled,
              onChanged: _updateBatteryOptimizationEnabled,
            ),
            SwitchListTile(
              title: const Text('Network Optimization'),
              subtitle: const Text('Cache and compress network requests'),
              value: settings.networkOptimizationEnabled,
              onChanged: _updateNetworkOptimizationEnabled,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdvancedSection(PerformanceSettings settings) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Advanced Settings',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('Frame Rate Limit'),
              subtitle: Text(
                'Maximum frames per second: ${settings.frameRateLimit} FPS',
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _showFrameRateDialog(settings.frameRateLimit),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendationsSection(
    List<PerformanceRecommendation> recommendations,
  ) {
    if (recommendations.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 48),
              const SizedBox(height: 8),
              Text(
                'Performance Optimized',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Text(
                'Your settings are optimized for your device',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recommendations',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            ...recommendations.map((rec) => _buildRecommendationItem(rec)),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendationItem(PerformanceRecommendation recommendation) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(
          _getRecommendationIcon(recommendation.type),
          color: _getRecommendationColor(recommendation.priority),
        ),
        title: Text(recommendation.title),
        subtitle: Text(recommendation.description),
        trailing: ElevatedButton(
          onPressed: () {
            recommendation.action();
            ref.refresh(performanceSettingsProvider);
            ref.refresh(performanceRecommendationsProvider);
          },
          child: const Text('Apply'),
        ),
      ),
    );
  }

  Widget _buildLoadingSection(String message) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(width: 16),
            Text(message),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorSection(String message) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.red),
            const SizedBox(width: 16),
            Expanded(child: Text(message)),
          ],
        ),
      ),
    );
  }

  // Event handlers

  void _updatePerformanceMode(PerformanceMode mode) async {
    final service = ref.read(performanceSettingsServiceProvider);
    await service.applyPerformanceModePreset(mode);
    ref.refresh(performanceSettingsProvider);
  }

  void _updateAnimationsEnabled(bool? value) async {
    if (value == null) return;
    final service = ref.read(performanceSettingsServiceProvider);
    await service.setAnimationsEnabled(value);
    ref.refresh(performanceSettingsProvider);
  }

  void _updateParticleEffectsEnabled(bool? value) async {
    if (value == null) return;
    final service = ref.read(performanceSettingsServiceProvider);
    await service.setParticleEffectsEnabled(value);
    ref.refresh(performanceSettingsProvider);
  }

  void _updateHeavyAnimationsEnabled(bool? value) async {
    if (value == null) return;
    final service = ref.read(performanceSettingsServiceProvider);
    await service.setHeavyAnimationsEnabled(value);
    ref.refresh(performanceSettingsProvider);
  }

  void _updateImageOptimizationEnabled(bool? value) async {
    if (value == null) return;
    final service = ref.read(performanceSettingsServiceProvider);
    final settings = await service.getSettings();
    await service.updateSettings(
      settings.copyWith(imageOptimizationEnabled: value),
    );
    ref.refresh(performanceSettingsProvider);
  }

  void _updateLazyLoadingEnabled(bool? value) async {
    if (value == null) return;
    final service = ref.read(performanceSettingsServiceProvider);
    final settings = await service.getSettings();
    await service.updateSettings(settings.copyWith(lazyLoadingEnabled: value));
    ref.refresh(performanceSettingsProvider);
  }

  void _updateMemoryOptimizationEnabled(bool? value) async {
    if (value == null) return;
    final service = ref.read(performanceSettingsServiceProvider);
    final settings = await service.getSettings();
    await service.updateSettings(
      settings.copyWith(memoryOptimizationEnabled: value),
    );
    ref.refresh(performanceSettingsProvider);
  }

  void _updateBatteryOptimizationEnabled(bool? value) async {
    if (value == null) return;
    final service = ref.read(performanceSettingsServiceProvider);
    final settings = await service.getSettings();
    await service.updateSettings(
      settings.copyWith(batteryOptimizationEnabled: value),
    );
    ref.refresh(performanceSettingsProvider);
  }

  void _updateNetworkOptimizationEnabled(bool? value) async {
    if (value == null) return;
    final service = ref.read(performanceSettingsServiceProvider);
    final settings = await service.getSettings();
    await service.updateSettings(
      settings.copyWith(networkOptimizationEnabled: value),
    );
    ref.refresh(performanceSettingsProvider);
  }

  void _autoOptimize() async {
    final service = ref.read(performanceSettingsServiceProvider);
    await service.autoOptimize();
    ref.refresh(performanceSettingsProvider);
    ref.refresh(performanceRecommendationsProvider);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Settings auto-optimized for your device')),
    );
  }

  void _handleMenuAction(String action) async {
    final service = ref.read(performanceSettingsServiceProvider);

    switch (action) {
      case 'reset':
        await service.resetToDefaults();
        break;
      case 'performance':
        await service.applyPerformanceModePreset(PerformanceMode.performance);
        break;
      case 'balanced':
        await service.applyPerformanceModePreset(PerformanceMode.balanced);
        break;
      case 'battery':
        await service.applyPerformanceModePreset(PerformanceMode.battery);
        break;
    }

    ref.refresh(performanceSettingsProvider);
    ref.refresh(performanceRecommendationsProvider);
  }

  void _showFrameRateDialog(int currentFrameRate) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Frame Rate Limit'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Select maximum frame rate:'),
                const SizedBox(height: 16),
                ...([30, 60, 90, 120].map(
                  (fps) => RadioListTile<int>(
                    title: Text('$fps FPS'),
                    value: fps,
                    groupValue: currentFrameRate,
                    onChanged: (value) {
                      Navigator.pop(context);
                      _updateFrameRate(value!);
                    },
                  ),
                )),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
            ],
          ),
    );
  }

  void _updateFrameRate(int frameRate) async {
    final service = ref.read(performanceSettingsServiceProvider);
    final settings = await service.getSettings();
    await service.updateSettings(settings.copyWith(frameRateLimit: frameRate));
    ref.refresh(performanceSettingsProvider);
  }

  // Helper methods

  String _getPerformanceModeTitle(PerformanceMode mode) {
    switch (mode) {
      case PerformanceMode.performance:
        return 'Performance';
      case PerformanceMode.balanced:
        return 'Balanced';
      case PerformanceMode.battery:
        return 'Battery Saver';
    }
  }

  String _getPerformanceModeDescription(PerformanceMode mode) {
    switch (mode) {
      case PerformanceMode.performance:
        return 'Maximum performance, higher battery usage';
      case PerformanceMode.balanced:
        return 'Good balance of performance and battery life';
      case PerformanceMode.battery:
        return 'Optimized for battery life, reduced performance';
    }
  }

  IconData _getRecommendationIcon(RecommendationType type) {
    switch (type) {
      case RecommendationType.memory:
        return Icons.memory;
      case RecommendationType.animation:
        return Icons.animation;
      case RecommendationType.battery:
        return Icons.battery_saver;
      case RecommendationType.network:
        return Icons.network_check;
      case RecommendationType.display:
        return Icons.display_settings;
    }
  }

  Color _getRecommendationColor(RecommendationPriority priority) {
    switch (priority) {
      case RecommendationPriority.low:
        return Colors.blue;
      case RecommendationPriority.medium:
        return Colors.orange;
      case RecommendationPriority.high:
        return Colors.red;
      case RecommendationPriority.critical:
        return Colors.red[900]!;
    }
  }
}
