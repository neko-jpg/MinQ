import 'package:flutter/material.dart';
import 'package:minq/core/performance/battery_optimization_service.dart';
import 'package:minq/core/performance/memory_management_service.dart';
import 'package:minq/core/performance/network_optimization_service.dart';
import 'package:minq/core/performance/performance_monitoring_service.dart';
import 'package:minq/core/performance/performance_settings_service.dart';
import 'package:minq/core/performance/startup_optimization_service.dart';

/// Performance monitoring dashboard widget
class PerformanceDashboard extends StatefulWidget {
  const PerformanceDashboard({super.key});

  @override
  State<PerformanceDashboard> createState() => _PerformanceDashboardState();
}

class _PerformanceDashboardState extends State<PerformanceDashboard>
    with TickerProviderStateMixin {
  late TabController _tabController;

  final _performanceService = PerformanceMonitoringService();
  final _memoryService = MemoryManagementService();
  final _batteryService = BatteryOptimizationService();
  final _startupService = StartupOptimizationService();
  final _networkService = NetworkOptimizationService();
  final _settingsService = PerformanceSettingsService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);

    // Start monitoring services
    _performanceService.startMonitoring();
    _memoryService.startMonitoring();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Performance Dashboard'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.speed), text: 'Performance'),
            Tab(icon: Icon(Icons.memory), text: 'Memory'),
            Tab(icon: Icon(Icons.battery_std), text: 'Battery'),
            Tab(icon: Icon(Icons.rocket_launch), text: 'Startup'),
            Tab(icon: Icon(Icons.settings), text: 'Settings'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildPerformanceTab(),
          _buildMemoryTab(),
          _buildBatteryTab(),
          _buildStartupTab(),
          _buildSettingsTab(),
        ],
      ),
    );
  }

  Widget _buildPerformanceTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCurrentMetricsCard(),
          const SizedBox(height: 16),
          _buildPerformanceChart(),
          const SizedBox(height: 16),
          _buildPerformanceIssuesCard(),
          const SizedBox(height: 16),
          _buildRecommendationsCard(),
        ],
      ),
    );
  }

  Widget _buildMemoryTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildMemoryUsageCard(),
          const SizedBox(height: 16),
          _buildMemoryHistoryChart(),
          const SizedBox(height: 16),
          _buildMemoryActionsCard(),
        ],
      ),
    );
  }

  Widget _buildBatteryTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildBatteryStatusCard(),
          const SizedBox(height: 16),
          _buildBatteryOptimizationCard(),
          const SizedBox(height: 16),
          _buildBatteryRecommendationsCard(),
        ],
      ),
    );
  }

  Widget _buildCurrentMetricsCard() {
    return FutureBuilder<PerformanceSnapshot>(
      future: Future.value(_performanceService.getCurrentMetrics()),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return _buildLoadingCard('Current Metrics');
        }

        final metrics = snapshot.data!;

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Current Performance',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildMetricItem(
                        'Frame Rate',
                        '${metrics.frameRate.toStringAsFixed(1)} FPS',
                        Icons.speed,
                        _getFrameRateColor(metrics.frameRate),
                      ),
                    ),
                    Expanded(
                      child: _buildMetricItem(
                        'Memory',
                        '${(metrics.memoryUsage / 1024 / 1024).toStringAsFixed(1)} MB',
                        Icons.memory,
                        _getMemoryColor(metrics.memoryUsage),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildMetricItem(
                        'CPU Usage',
                        '${metrics.cpuUsage.toStringAsFixed(1)}%',
                        Icons.memory,
                        _getCPUColor(metrics.cpuUsage),
                      ),
                    ),
                    Expanded(
                      child: _buildMetricItem(
                        'Operations',
                        '${metrics.activeOperations}',
                        Icons.work,
                        Colors.blue,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPerformanceChart() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Performance History',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            SizedBox(height: 200, child: _buildSimpleChart()),
          ],
        ),
      ),
    );
  }

  Widget _buildPerformanceIssuesCard() {
    return FutureBuilder<PerformanceStatistics>(
      future: Future.value(_performanceService.getPerformanceStatistics()),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return _buildLoadingCard('Performance Issues');
        }

        final stats = snapshot.data!;

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Performance Issues',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                if (stats.performanceIssues.isEmpty)
                  _buildNoIssuesWidget()
                else
                  ...stats.performanceIssues.map(
                    (issue) => _buildIssueItem(issue),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRecommendationsCard() {
    return FutureBuilder<PerformanceStatistics>(
      future: Future.value(_performanceService.getPerformanceStatistics()),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return _buildLoadingCard('Recommendations');
        }

        final stats = snapshot.data!;

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
                ...stats.recommendations.map(
                  (rec) => _buildRecommendationItem(rec),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMemoryUsageCard() {
    return FutureBuilder<MemoryInfo>(
      future: _memoryService.getCurrentMemoryUsage(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return _buildLoadingCard('Memory Usage');
        }

        final memory = snapshot.data!;

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Memory Usage',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                _buildMemoryProgressBar(memory.heapUsage),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildMemoryStatItem(
                      'Heap',
                      '${(memory.heapUsage / 1024 / 1024).toStringAsFixed(1)} MB',
                    ),
                    _buildMemoryStatItem(
                      'Physical',
                      '${(memory.physicalMemory / 1024 / 1024).toStringAsFixed(1)} MB',
                    ),
                    _buildMemoryStatItem(
                      'Available',
                      '${(memory.availableMemory / 1024 / 1024).toStringAsFixed(1)} MB',
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMemoryHistoryChart() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Memory History',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            SizedBox(height: 150, child: _buildMemoryChart()),
          ],
        ),
      ),
    );
  }

  Widget _buildMemoryActionsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Memory Actions',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _memoryService.forceGarbageCollection(),
                    icon: const Icon(Icons.cleaning_services),
                    label: const Text('Force GC'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _memoryService.optimizeMemory(),
                    icon: const Icon(Icons.tune),
                    label: const Text('Optimize'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBatteryStatusCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Battery Status',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            FutureBuilder<BatteryInfo>(
              future: Future.value(_batteryService.getCurrentBatteryInfo()),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const CircularProgressIndicator();
                }

                final battery = snapshot.data!;

                return Column(
                  children: [
                    _buildBatteryLevelIndicator(battery.level),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildBatteryStatItem(
                          'Level',
                          '${(battery.level * 100).toInt()}%',
                        ),
                        _buildBatteryStatItem(
                          'State',
                          _getBatteryStateText(battery.state),
                        ),
                        _buildBatteryStatItem(
                          'Mode',
                          battery.isLowPowerMode ? 'Low Power' : 'Normal',
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBatteryOptimizationCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Battery Optimization',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Enable Optimization'),
              subtitle: const Text('Automatically optimize battery usage'),
              value: true, // This would be bound to actual state
              onChanged: (value) {
                _batteryService.setOptimizationEnabled(value);
              },
            ),
            ElevatedButton.icon(
              onPressed: () => _batteryService.optimizeBatteryUsage(),
              icon: const Icon(Icons.battery_saver),
              label: const Text('Optimize Now'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBatteryRecommendationsCard() {
    return FutureBuilder<BatteryUsageStats>(
      future: Future.value(_batteryService.getBatteryUsageStats()),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return _buildLoadingCard('Battery Recommendations');
        }

        final stats = snapshot.data!;

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Battery Recommendations',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                ...stats.recommendations.map(
                  (rec) => _buildRecommendationItem(rec),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStartupTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStartupMetricsCard(),
          const SizedBox(height: 16),
          _buildStartupOptimizationCard(),
          const SizedBox(height: 16),
          _buildNetworkOptimizationCard(),
        ],
      ),
    );
  }

  Widget _buildSettingsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPerformanceSettingsCard(),
          const SizedBox(height: 16),
          _buildOptimizationActionsCard(),
        ],
      ),
    );
  }

  Widget _buildStartupMetricsCard() {
    return FutureBuilder<StartupMetrics>(
      future: Future.value(_startupService.getStartupMetrics()),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return _buildLoadingCard('Startup Metrics');
        }

        final metrics = snapshot.data!;

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Startup Performance',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildMetricItem(
                        'Startup Time',
                        '${metrics.startupDuration.inMilliseconds}ms',
                        Icons.timer,
                        _getStartupTimeColor(
                          metrics.startupDuration.inMilliseconds,
                        ),
                      ),
                    ),
                    Expanded(
                      child: _buildMetricItem(
                        'First Frame',
                        '${metrics.timeToFirstFrame.inMilliseconds}ms',
                        Icons.visibility,
                        _getFirstFrameColor(
                          metrics.timeToFirstFrame.inMilliseconds,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildMetricItem(
                        'Preload Tasks',
                        '${metrics.preloadTasksCount}',
                        Icons.download,
                        Colors.blue,
                      ),
                    ),
                    Expanded(
                      child: _buildMetricItem(
                        'Deferred Tasks',
                        '${metrics.deferredTasksCount}',
                        Icons.schedule,
                        Colors.orange,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStartupOptimizationCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Startup Optimization',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _startupService.optimizeForNextStartup(),
                    icon: const Icon(Icons.rocket_launch),
                    label: const Text('Optimize Startup'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _startupService.markFirstFrameRendered(),
                    icon: const Icon(Icons.visibility),
                    label: const Text('Mark First Frame'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNetworkOptimizationCard() {
    return FutureBuilder<NetworkCacheStats>(
      future: Future.value(_networkService.getCacheStats()),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return _buildLoadingCard('Network Optimization');
        }

        final stats = snapshot.data!;

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Network Optimization',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildNetworkStatItem(
                      'Cache Size',
                      '${(stats.cacheSize / 1024 / 1024).toStringAsFixed(1)} MB',
                    ),
                    _buildNetworkStatItem(
                      'Hit Rate',
                      '${(stats.hitRate * 100).toStringAsFixed(1)}%',
                    ),
                    _buildNetworkStatItem(
                      'Utilization',
                      '${(stats.utilizationRate * 100).toStringAsFixed(1)}%',
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _networkService.clearCache(),
                        icon: const Icon(Icons.clear_all),
                        label: const Text('Clear Cache'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _networkService.optimizeNetworkUsage(),
                        icon: const Icon(Icons.network_check),
                        label: const Text('Optimize'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPerformanceSettingsCard() {
    return FutureBuilder<PerformanceSettings>(
      future: _settingsService.getSettings(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return _buildLoadingCard('Performance Settings');
        }

        final settings = snapshot.data!;

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Performance Settings',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  title: const Text('Animations'),
                  subtitle: const Text('Enable UI animations'),
                  value: settings.animationsEnabled,
                  onChanged: (value) {
                    _settingsService.setAnimationsEnabled(value);
                  },
                ),
                SwitchListTile(
                  title: const Text('Heavy Animations'),
                  subtitle: const Text(
                    'Enable particle effects and complex animations',
                  ),
                  value: settings.heavyAnimationsEnabled,
                  onChanged: (value) {
                    _settingsService.setHeavyAnimationsEnabled(value);
                  },
                ),
                ListTile(
                  title: const Text('Performance Mode'),
                  subtitle: Text(
                    _getPerformanceModeText(settings.performanceMode),
                  ),
                  trailing: DropdownButton<PerformanceMode>(
                    value: settings.performanceMode,
                    onChanged: (mode) {
                      if (mode != null) {
                        _settingsService.setPerformanceMode(mode);
                      }
                    },
                    items:
                        PerformanceMode.values.map((mode) {
                          return DropdownMenuItem(
                            value: mode,
                            child: Text(_getPerformanceModeText(mode)),
                          );
                        }).toList(),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildOptimizationActionsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Optimization Actions',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _settingsService.autoOptimize(),
                    icon: const Icon(Icons.auto_fix_high),
                    label: const Text('Auto Optimize'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _settingsService.resetToDefaults(),
                    icon: const Icon(Icons.restore),
                    label: const Text('Reset Defaults'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Helper widgets

  Widget _buildLoadingCard(String title) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            const Center(child: CircularProgressIndicator()),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricItem(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }

  Widget _buildSimpleChart() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(
          'Performance Chart\n(Chart implementation would go here)',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey[600]),
        ),
      ),
    );
  }

  Widget _buildMemoryChart() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(
          'Memory Chart\n(Chart implementation would go here)',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey[600]),
        ),
      ),
    );
  }

  Widget _buildNoIssuesWidget() {
    return const Row(
      children: [
        Icon(Icons.check_circle, color: Colors.green),
        SizedBox(width: 8),
        Text('No performance issues detected'),
      ],
    );
  }

  Widget _buildIssueItem(String issue) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          const Icon(Icons.warning, color: Colors.orange, size: 20),
          const SizedBox(width: 8),
          Expanded(child: Text(issue)),
        ],
      ),
    );
  }

  Widget _buildRecommendationItem(String recommendation) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          const Icon(Icons.lightbulb, color: Colors.blue, size: 20),
          const SizedBox(width: 8),
          Expanded(child: Text(recommendation)),
        ],
      ),
    );
  }

  Widget _buildMemoryProgressBar(int heapUsage) {
    const maxMemory = 500 * 1024 * 1024; // 500MB max
    final progress = (heapUsage / maxMemory).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Heap Usage'),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: Colors.grey[300],
          valueColor: AlwaysStoppedAnimation<Color>(_getMemoryColor(heapUsage)),
        ),
      ],
    );
  }

  Widget _buildMemoryStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }

  Widget _buildBatteryLevelIndicator(double level) {
    return Column(
      children: [
        const Text('Battery Level'),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: level,
          backgroundColor: Colors.grey[300],
          valueColor: AlwaysStoppedAnimation<Color>(_getBatteryColor(level)),
        ),
      ],
    );
  }

  Widget _buildBatteryStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }

  // Helper methods

  Color _getFrameRateColor(double frameRate) {
    if (frameRate >= 50) return Colors.green;
    if (frameRate >= 30) return Colors.orange;
    return Colors.red;
  }

  Color _getMemoryColor(int memoryUsage) {
    final mb = memoryUsage / 1024 / 1024;
    if (mb < 100) return Colors.green;
    if (mb < 200) return Colors.orange;
    return Colors.red;
  }

  Color _getCPUColor(double cpuUsage) {
    if (cpuUsage < 50) return Colors.green;
    if (cpuUsage < 80) return Colors.orange;
    return Colors.red;
  }

  Color _getBatteryColor(double level) {
    if (level > 0.5) return Colors.green;
    if (level > 0.2) return Colors.orange;
    return Colors.red;
  }

  String _getBatteryStateText(BatteryState state) {
    switch (state) {
      case BatteryState.charging:
        return 'Charging';
      case BatteryState.discharging:
        return 'Discharging';
      case BatteryState.full:
        return 'Full';
      case BatteryState.unknown:
        return 'Unknown';
    }
  }

  Color _getStartupTimeColor(int milliseconds) {
    if (milliseconds < 1000) return Colors.green;
    if (milliseconds < 3000) return Colors.orange;
    return Colors.red;
  }

  Color _getFirstFrameColor(int milliseconds) {
    if (milliseconds < 500) return Colors.green;
    if (milliseconds < 1000) return Colors.orange;
    return Colors.red;
  }

  Widget _buildNetworkStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }

  String _getPerformanceModeText(PerformanceMode mode) {
    switch (mode) {
      case PerformanceMode.performance:
        return 'Performance';
      case PerformanceMode.balanced:
        return 'Balanced';
      case PerformanceMode.battery:
        return 'Battery Saver';
    }
  }
}
