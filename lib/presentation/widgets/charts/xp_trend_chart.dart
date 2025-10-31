import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:minq/core/gamification/xp_system.dart';
import 'package:minq/domain/gamification/xp_transaction.dart';
import 'package:minq/presentation/theme/minq_theme.dart';

/// XPトレンドチャートウィジェット（要件34）
class XPTrendChart extends ConsumerWidget {
  final String userId;
  final int days;
  
  const XPTrendChart({
    super.key,
    required this.userId,
    this.days = 30,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.tokens;
    final xpSystem = ref.watch(xpSystemProvider);
    
    return FutureBuilder<List<XPTransaction>>(
      future: xpSystem.getXPHistory(
        userId: userId,
        limit: 1000,
        startDate: DateTime.now().subtract(Duration(days: days)),
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (snapshot.hasError || !snapshot.hasData) {
          return Center(
            child: Icon(
              Icons.error_outline,
              color: tokens.error,
              size: 48,
            ),
          );
        }
        
        final transactions = snapshot.data!;
        final chartData = _processChartData(transactions, days);
        
        if (chartData.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.show_chart,
                  color: tokens.textMuted,
                  size: 48,
                ),
                SizedBox(height: tokens.spacing.sm),
                Text(
                  'データがありません',
                  style: tokens.typography.body.copyWith(
                    color: tokens.textMuted,
                  ),
                ),
              ],
            ),
          );
        }
        
        return LineChart(
          LineChartData(
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              horizontalInterval: _calculateInterval(chartData),
              getDrawingHorizontalLine: (value) {
                return FlLine(
                  color: tokens.border,
                  strokeWidth: 1,
                );
              },
            ),
            titlesData: FlTitlesData(
              show: true,
              rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 30,
                  interval: (days / 7).ceil().toDouble(),
                  getTitlesWidget: (value, meta) {
                    final date = DateTime.now().subtract(
                      Duration(days: days - value.toInt()),
                    );
                    return SideTitleWidget(
                      axisSide: meta.axisSide,
                      child: Text(
                        '${date.month}/${date.day}',
                        style: tokens.typography.caption.copyWith(
                          color: tokens.textMuted,
                        ),
                      ),
                    );
                  },
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 40,
                  interval: _calculateInterval(chartData),
                  getTitlesWidget: (value, meta) {
                    return SideTitleWidget(
                      axisSide: meta.axisSide,
                      child: Text(
                        value.toInt().toString(),
                        style: tokens.typography.caption.copyWith(
                          color: tokens.textMuted,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            borderData: FlBorderData(
              show: true,
              border: Border.all(color: tokens.border),
            ),
            minX: 0,
            maxX: days.toDouble() - 1,
            minY: 0,
            maxY: _getMaxY(chartData),
            lineBarsData: [
              LineChartBarData(
                spots: chartData,
                isCurved: true,
                gradient: LinearGradient(
                  colors: [
                    tokens.brandPrimary,
                    tokens.brandPrimary.withOpacity(0.3),
                  ],
                ),
                barWidth: 3,
                isStrokeCapRound: true,
                dotData: FlDotData(
                  show: true,
                  getDotPainter: (spot, percent, barData, index) {
                    return FlDotCirclePainter(
                      radius: 4,
                      color: tokens.brandPrimary,
                      strokeWidth: 2,
                      strokeColor: Colors.white,
                    );
                  },
                ),
                belowBarData: BarAreaData(
                  show: true,
                  gradient: LinearGradient(
                    colors: [
                      tokens.brandPrimary.withOpacity(0.3),
                      tokens.brandPrimary.withOpacity(0.1),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ],
            lineTouchData: LineTouchData(
              enabled: true,
              touchTooltipData: LineTouchTooltipData(
                tooltipBgColor: tokens.surface,
                tooltipBorder: BorderSide(color: tokens.border),
                getTooltipItems: (touchedSpots) {
                  return touchedSpots.map((LineBarSpot touchedSpot) {
                    final date = DateTime.now().subtract(
                      Duration(days: days - touchedSpot.x.toInt()),
                    );
                    return LineTooltipItem(
                      '${date.month}/${date.day}\n${touchedSpot.y.toInt()} XP',
                      tokens.typography.bodySmall.copyWith(
                        color: tokens.textPrimary,
                      ),
                    );
                  }).toList();
                },
              ),
            ),
          ),
        );
      },
    );
  }
  
  List<FlSpot> _processChartData(List<XPTransaction> transactions, int days) {
    final now = DateTime.now();
    final dailyXP = <int, int>{};
    
    // 日別XPを集計
    for (final transaction in transactions) {
      final daysDiff = now.difference(transaction.createdAt).inDays;
      if (daysDiff >= 0 && daysDiff < days) {
        final dayIndex = days - 1 - daysDiff;
        dailyXP[dayIndex] = (dailyXP[dayIndex] ?? 0) + transaction.xpAmount;
      }
    }
    
    // チャートデータを生成
    final spots = <FlSpot>[];
    for (int i = 0; i < days; i++) {
      spots.add(FlSpot(i.toDouble(), (dailyXP[i] ?? 0).toDouble()));
    }
    
    return spots;
  }
  
  double _calculateInterval(List<FlSpot> data) {
    if (data.isEmpty) return 10;
    
    final maxY = data.map((spot) => spot.y).reduce((a, b) => a > b ? a : b);
    if (maxY <= 50) return 10;
    if (maxY <= 100) return 20;
    if (maxY <= 500) return 50;
    return 100;
  }
  
  double _getMaxY(List<FlSpot> data) {
    if (data.isEmpty) return 100;
    
    final maxY = data.map((spot) => spot.y).reduce((a, b) => a > b ? a : b);
    return (maxY * 1.2).ceilToDouble();
  }
}

/// 累積XPチャート
class CumulativeXPChart extends ConsumerWidget {
  final String userId;
  final int days;
  
  const CumulativeXPChart({
    super.key,
    required this.userId,
    this.days = 30,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.tokens;
    final xpSystem = ref.watch(xpSystemProvider);
    
    return FutureBuilder<List<XPTransaction>>(
      future: xpSystem.getXPHistory(
        userId: userId,
        limit: 1000,
        startDate: DateTime.now().subtract(Duration(days: days)),
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (snapshot.hasError || !snapshot.hasData) {
          return Center(
            child: Icon(
              Icons.error_outline,
              color: tokens.error,
              size: 48,
            ),
          );
        }
        
        final transactions = snapshot.data!;
        final chartData = _processCumulativeData(transactions, days);
        
        return LineChart(
          LineChartData(
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              getDrawingHorizontalLine: (value) {
                return FlLine(
                  color: tokens.border,
                  strokeWidth: 1,
                );
              },
            ),
            titlesData: FlTitlesData(
              show: true,
              rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 30,
                  interval: (days / 7).ceil().toDouble(),
                  getTitlesWidget: (value, meta) {
                    final date = DateTime.now().subtract(
                      Duration(days: days - value.toInt()),
                    );
                    return SideTitleWidget(
                      axisSide: meta.axisSide,
                      child: Text(
                        '${date.month}/${date.day}',
                        style: tokens.typography.caption.copyWith(
                          color: tokens.textMuted,
                        ),
                      ),
                    );
                  },
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 50,
                  getTitlesWidget: (value, meta) {
                    return SideTitleWidget(
                      axisSide: meta.axisSide,
                      child: Text(
                        value.toInt().toString(),
                        style: tokens.typography.caption.copyWith(
                          color: tokens.textMuted,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            borderData: FlBorderData(
              show: true,
              border: Border.all(color: tokens.border),
            ),
            minX: 0,
            maxX: days.toDouble() - 1,
            minY: 0,
            lineBarsData: [
              LineChartBarData(
                spots: chartData,
                isCurved: true,
                color: tokens.success,
                barWidth: 3,
                isStrokeCapRound: true,
                dotData: const FlDotData(show: false),
                belowBarData: BarAreaData(
                  show: true,
                  gradient: LinearGradient(
                    colors: [
                      tokens.success.withOpacity(0.3),
                      tokens.success.withOpacity(0.1),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
  
  List<FlSpot> _processCumulativeData(List<XPTransaction> transactions, int days) {
    final now = DateTime.now();
    final dailyXP = <int, int>{};
    
    // 日別XPを集計
    for (final transaction in transactions) {
      final daysDiff = now.difference(transaction.createdAt).inDays;
      if (daysDiff >= 0 && daysDiff < days) {
        final dayIndex = days - 1 - daysDiff;
        dailyXP[dayIndex] = (dailyXP[dayIndex] ?? 0) + transaction.xpAmount;
      }
    }
    
    // 累積データを生成
    final spots = <FlSpot>[];
    int cumulative = 0;
    for (int i = 0; i < days; i++) {
      cumulative += dailyXP[i] ?? 0;
      spots.add(FlSpot(i.toDouble(), cumulative.toDouble()));
    }
    
    return spots;
  }
}