import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:minq/core/monitoring/ab_testing_service.dart';
import 'package:minq/core/monitoring/app_monitoring_service.dart';
import 'package:minq/core/monitoring/crash_reporting_service.dart';
import 'package:minq/core/monitoring/performance_monitoring_service.dart';
import 'package:minq/core/monitoring/user_behavior_analytics.dart';
import 'package:minq/presentation/widgets/monitoring/crash_statistics_card.dart';
import 'package:minq/presentation/widgets/monitoring/health_status_card.dart';
import 'package:minq/presentation/widgets/monitoring/performance_chart.dart';
import 'package:minq/presentation/widgets/monitoring/user_analytics_card.dart';

class MonitoringDashboardScreen extends ConsumerStatefulWidget {
  const MonitoringDashboardScreen({super.key});

  @override
  ConsumerState<MonitoringDashboardScreen> createState() =>
      _MonitoringDashboardScreenState();
}

class _MonitoringDashboardScreenState
    extends ConsumerState<MonitoringDashboardScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  final AppMonitoringService _appMonitoring = AppMonitoringService();
  final CrashReportingService _crashReporting = CrashReportingService();
  final PerformanceMonitoringService _performance =
      PerformanceMonitoringService();
  final UserBehaviorAnalytics _userAnalytics = UserBehaviorAnalytics();
  // final ABTestingService _abTesting = ABTestingService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
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
        title: const Text('Monitoring Dashboard'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(icon: Icon(Icons.health_and_safety), text: 'Health'),
            Tab(icon: Icon(Icons.speed), text: 'Performance'),
            Tab(icon: Icon(Icons.bug_report), text: 'Crashes'),
            Tab(icon: Icon(Icons.analytics), text: 'Analytics'),
            // Tab(icon: Icon(Icons.science), text: 'A/B Tests'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildHealthTab(),
          _buildPerformanceTab(),
          _buildCrashesTab(),
          _buildAnalyticsTab(),
          // _buildABTestsTab(),
        ],
      ),
    );
  }

  Widget _buildHealthTab() {
    return RefreshIndicator(
      onRefresh: () async {
        setState(() {});
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Health Status Overview
            FutureBuilder<AppHealthStatus>(
              future: Future.value(_appMonitoring.getHealthStatus()),
              builder: (context, snapshot) {
                return HealthStatusCard(
                  status: snapshot.data ?? AppHealthStatus.healthy,
                  metrics: _appMonitoring.getHealthMetrics(),
                );
              },
            ),

            const SizedBox(height: 16),

            // Recent Health Events
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Recent Health Events',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    ...(_appMonitoring
                        .getRecentHealthEvents(limit: 5)
                        .map((event) => _buildHealthEventTile(event))),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // System Information
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'System Information',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    _buildSystemInfoTiles(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPerformanceTab() {
    return RefreshIndicator(
      onRefresh: () async {
        setState(() {});
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Performance Statistics
            FutureBuilder<PerformanceStatistics>(
              future: Future.value(_performance.getPerformanceStatistics()),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final stats = snapshot.data!;
                return Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _buildMetricCard(
                            'Frame Rate',
                            '${stats.frameRate.toStringAsFixed(1)} fps',
                            Icons.speed,
                            stats.frameRate >= 55
                                ? Colors.green
                                : Colors.orange,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildMetricCard(
                            'Memory Usage',
                            '${stats.currentMemoryUsage.toStringAsFixed(1)} MB',
                            Icons.memory,
                            stats.currentMemoryUsage < 300
                                ? Colors.green
                                : Colors.orange,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: _buildMetricCard(
                            'Network Latency',
                            '${stats.averageNetworkLatency.toStringAsFixed(0)} ms',
                            Icons.network_check,
                            stats.averageNetworkLatency < 500
                                ? Colors.green
                                : Colors.orange,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildMetricCard(
                            'App Uptime',
                            _formatDuration(stats.appUptime),
                            Icons.timer,
                            Colors.blue,
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 16),

            // Performance Charts
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Performance Trends',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 200,
                      child: PerformanceChart(
                        trends: _performance.getPerformanceTrends(),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Memory Usage History
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Memory Usage History',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    SizedBox(height: 200, child: _buildMemoryChart()),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCrashesTab() {
    return RefreshIndicator(
      onRefresh: () async {
        setState(() {});
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Crash Statistics
            FutureBuilder<CrashStatistics>(
              future: _crashReporting.getCrashStatistics(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                return CrashStatisticsCard(statistics: snapshot.data!);
              },
            ),

            const SizedBox(height: 16),

            // Recent Crashes
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Recent Crashes',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    FutureBuilder<List<CrashReport>>(
                      future: _crashReporting.getRecentCrashReports(limit: 10),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const CircularProgressIndicator();
                        }

                        final crashes = snapshot.data!;
                        if (crashes.isEmpty) {
                          return const Text('No recent crashes');
                        }

                        return Column(
                          children:
                              crashes
                                  .map((crash) => _buildCrashTile(crash))
                                  .toList(),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalyticsTab() {
    return RefreshIndicator(
      onRefresh: () async {
        setState(() {});
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Behavior Insights
            FutureBuilder<UserBehaviorInsights>(
              future: _userAnalytics.getUserBehaviorInsights(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                return UserAnalyticsCard(insights: snapshot.data!);
              },
            ),

            const SizedBox(height: 16),

            // Feature Adoption
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Feature Adoption',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    _buildFeatureAdoptionChart(),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Retention Analysis
            FutureBuilder<RetentionAnalysis>(
              future: _userAnalytics.analyzeRetention(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const SizedBox();
                }

                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'User Retention',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 12),
                        _buildRetentionChart(snapshot.data!),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // Widget _buildABTestsTab() {
  //   return RefreshIndicator(
  //     onRefresh: () async {
  //       setState(() {});
  //     },
  //     child: SingleChildScrollView(
  //       padding: const EdgeInsets.all(16),
  //       child: Column(
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           // Active A/B Tests
  //           Card(
  //             child: Padding(
  //               padding: const EdgeInsets.all(16),
  //               child: Column(
  //                 crossAxisAlignment: CrossAxisAlignment.start,
  //                 children: [
  //                   Text(
  //                     'Active A/B Tests',
  //                     style: Theme.of(context).textTheme.titleMedium,
  //                   ),
  //                   const SizedBox(height: 12),
  //                   _buildActiveABTests(),
  //                 ],
  //               ),
  //             ),
  //           ),

  //           const SizedBox(height: 16),

  //           // User Assignments
  //           Card(
  //             child: Padding(
  //               padding: const EdgeInsets.all(16),
  //               child: Column(
  //                 crossAxisAlignment: CrossAxisAlignment.start,
  //                 children: [
  //                   Text(
  //                     'Current User Assignments',
  //                     style: Theme.of(context).textTheme.titleMedium,
  //                   ),
  //                   const SizedBox(height: 12),
  //                   _buildUserAssignments(),
  //                 ],
  //               ),
  //             ),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  Widget _buildHealthEventTile(AppHealthEvent event) {
    IconData icon;
    Color color;

    switch (event.type) {
      case AppHealthEventType.critical:
        icon = Icons.error;
        color = Colors.red;
        break;
      case AppHealthEventType.warning:
        icon = Icons.warning;
        color = Colors.orange;
        break;
      case AppHealthEventType.error:
        icon = Icons.error_outline;
        color = Colors.red.shade300;
        break;
      default:
        icon = Icons.info;
        color = Colors.blue;
    }

    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(event.issues.join(', ')),
      subtitle: Text(_formatDateTime(event.timestamp)),
      dense: true,
    );
  }

  Widget _buildSystemInfoTiles() {
    final metrics = _appMonitoring.getHealthMetrics();

    return Column(
      children: [
        _buildInfoTile('App Version', metrics['app_version'] ?? 'Unknown'),
        _buildInfoTile(
          'Uptime',
          _formatDuration(
            Duration(minutes: (metrics['uptime_minutes'] ?? 0).toInt()),
          ),
        ),
        _buildInfoTile(
          'Memory Usage',
          '${(metrics['memory_usage_mb'] ?? 0).toStringAsFixed(1)} MB',
        ),
        _buildInfoTile(
          'Frame Drop Rate',
          '${((metrics['frame_drop_rate'] ?? 0) * 100).toStringAsFixed(1)}%',
        ),
      ],
    );
  }

  Widget _buildInfoTile(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildMetricCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMemoryChart() {
    final memoryHistory = _performance.getMemoryHistory(limit: 20);

    if (memoryHistory.isEmpty) {
      return const Center(child: Text('No memory data available'));
    }

    final spots =
        memoryHistory.asMap().entries.map((entry) {
          return FlSpot(entry.key.toDouble(), entry.value.usedMemoryMB);
        }).toList();

    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: true),
        titlesData: const FlTitlesData(show: false),
        borderData: FlBorderData(show: true),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: Colors.blue,
            barWidth: 2,
            dotData: const FlDotData(show: false),
          ),
        ],
      ),
    );
  }

  Widget _buildCrashTile(CrashReport crash) {
    Color severityColor;
    switch (crash.severity) {
      case CrashSeverity.critical:
        severityColor = Colors.red;
        break;
      case CrashSeverity.high:
        severityColor = Colors.orange;
        break;
      case CrashSeverity.medium:
        severityColor = Colors.yellow;
        break;
      default:
        severityColor = Colors.blue;
    }

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: severityColor,
        child: Text(crash.severity.name[0].toUpperCase()),
      ),
      title: Text(crash.error, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text(_formatDateTime(crash.timestamp)),
      trailing: Chip(
        label: Text(crash.type.name),
        backgroundColor: severityColor.withAlpha((255 * 0.2).round()),
      ),
      onTap: () => _showCrashDetails(crash),
    );
  }

  Widget _buildFeatureAdoptionChart() {
    final adoption = _userAnalytics.getFeatureAdoption();

    if (adoption.isEmpty) {
      return const Center(child: Text('No feature adoption data'));
    }

    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: adoption.length,
        itemBuilder: (context, index) {
          final feature = adoption.values.elementAt(index);
          return Container(
            width: 120,
            margin: const EdgeInsets.only(right: 8),
            child: Column(
              children: [
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.blue.withAlpha((255 * 0.2).round()),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          feature.totalUsage.toString(),
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Text('uses'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  feature.featureName,
                  style: const TextStyle(fontSize: 12),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildRetentionChart(RetentionAnalysis retention) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildRetentionMetric('Total Days', retention.totalDays.toString()),
            _buildRetentionMetric(
              'Active Days',
              retention.activeDays.toString(),
            ),
            _buildRetentionMetric(
              'Retention Rate',
              '${(retention.retentionRate * 100).toStringAsFixed(1)}%',
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: retention.sessionsByDay.length,
            itemBuilder: (context, index) {
              final entry = retention.sessionsByDay.entries.elementAt(index);
              final maxSessions = retention.sessionsByDay.values.reduce(
                (a, b) => a > b ? a : b,
              );
              final height = (entry.value / maxSessions) * 80;

              return Container(
                width: 30,
                margin: const EdgeInsets.only(right: 4),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      height: height,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      entry.key.split('-')[2],
                      style: const TextStyle(fontSize: 10),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRetentionMetric(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  // Widget _buildActiveABTests() {
  //   final assignments = _abTesting.getActiveAssignments();

  //   if (assignments.isEmpty) {
  //     return const Text('No active A/B tests');
  //   }

  //   return Column(
  //     children:
  //         assignments.entries.map((entry) {
  //           return ListTile(
  //             title: Text(entry.key),
  //             subtitle: Text('Variant: ${entry.value}'),
  //             trailing: const Icon(Icons.science),
  //           );
  //         }).toList(),
  //   );
  // }

  // Widget _buildUserAssignments() {
  //   final assignments = _abTesting.getActiveAssignments();

  //   if (assignments.isEmpty) {
  //     return const Text('No current assignments');
  //   }

  //   return Column(
  //     children:
  //         assignments.entries.map((entry) {
  //           return Card(
  //             child: ListTile(
  //               title: Text(entry.key),
  //               subtitle: Text('Assigned to: ${entry.value}'),
  //               leading: const Icon(Icons.person),
  //             ),
  //           );
  //         }).toList(),
  //   );
  // }

  void _showCrashDetails(CrashReport crash) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Crash Details'),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Type: ${crash.type.name}'),
                  Text('Severity: ${crash.severity.name}'),
                  Text('Time: ${_formatDateTime(crash.timestamp)}'),
                  const SizedBox(height: 8),
                  const Text(
                    'Error:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(crash.error),
                  if (crash.stackTrace != null) ...[
                    const SizedBox(height: 8),
                    const Text(
                      'Stack Trace:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      crash.stackTrace!,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
              ),
            ],
          ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m';
    }
  }
}
