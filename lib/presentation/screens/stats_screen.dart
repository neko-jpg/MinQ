import 'package:flutter/material.dart';
import 'package:flutter_heatmap_calendar/flutter_heatmap_calendar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:minq/presentation/common/minq_buttons.dart';
import 'package:minq/presentation/theme/minq_theme.dart';

class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.tokens;
    // Mock data based on the design
    final heatmapData = {
      DateTime.now().subtract(const Duration(days: 3)): 1,
      DateTime.now().subtract(const Duration(days: 4)): 1,
      DateTime.now().subtract(const Duration(days: 5)): 1,
      DateTime.now().subtract(const Duration(days: 6)): 1,
      DateTime.now().subtract(const Duration(days: 7)): 1,
      DateTime.now().subtract(const Duration(days: 8)): 1,
      DateTime.now().subtract(const Duration(days: 9)): 1,
    };

    return Scaffold(
      backgroundColor: tokens.background,
      appBar: AppBar(
        title: Text('Progress for "Meditate"', style: tokens.titleMedium.copyWith(color: tokens.textPrimary, fontWeight: FontWeight.bold)),
        centerTitle: true,
        leading: MinqIconButton(icon: Icons.arrow_back, onTap: () => context.pop()),
        backgroundColor: tokens.background.withOpacity(0.8),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: ListView(
        padding: EdgeInsets.all(tokens.spacing(4)),
        children: [
          SizedBox(height: tokens.spacing(4)),
          _buildStreakCounter(tokens),
          SizedBox(height: tokens.spacing(8)),
          _buildHeatmapCard(tokens, heatmapData),
          SizedBox(height: tokens.spacing(8)),
          _buildDailyLog(tokens),
        ],
      ),
    );
  }

  Widget _buildStreakCounter(MinqTheme tokens) {
    return Column(
      children: [
        Text('Current Streak', style: tokens.bodyMedium.copyWith(color: tokens.textMuted)),
        SizedBox(height: tokens.spacing(2)),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(Icons.local_fire_department, size: tokens.spacing(12), color: Colors.amber.shade400),
            SizedBox(width: tokens.spacing(2)),
            Text('21', style: tokens.displayMedium.copyWith(color: tokens.textPrimary, fontWeight: FontWeight.w800)),
          ],
        ),
        Text('days', style: tokens.bodyMedium.copyWith(color: tokens.textMuted)),
      ],
    );
  }

  Widget _buildHeatmapCard(MinqTheme tokens, Map<DateTime, int> heatmapData) {
    return Card(
      elevation: 0,
      color: tokens.surface,
      shape: RoundedRectangleBorder(borderRadius: tokens.cornerLarge()),
      child: Padding(
        padding: EdgeInsets.all(tokens.spacing(4)),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Weekly Heatmap', style: tokens.titleSmall.copyWith(color: tokens.textPrimary, fontWeight: FontWeight.bold)),
                Row(
                  children: [
                    Text('This week', style: tokens.bodyMedium.copyWith(color: tokens.textMuted)),
                    Icon(Icons.expand_more, color: tokens.textMuted, size: tokens.spacing(5)),
                  ],
                ),
              ],
            ),
            SizedBox(height: tokens.spacing(4)),
            HeatMap(
              datasets: heatmapData,
              colorMode: ColorMode.color,
              showText: false,
              scrollable: true,
              colorsets: {1: tokens.brandPrimary},
              defaultColor: tokens.background,
              borderRadius: tokens.radiusMedium,
              margin: EdgeInsets.all(tokens.spacing(1)),
              size: tokens.spacing(10),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDailyLog(MinqTheme tokens) {
    // Mock data
    final logItems = {
      'Today': '8:15 AM',
      'Yesterday': '7:50 AM',
      'June 5, 2024': '9:02 AM',
      'June 4, 2024': '8:30 AM',
      'June 3, 2024': '7:45 AM',
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Daily Log', style: tokens.titleSmall.copyWith(color: tokens.textPrimary, fontWeight: FontWeight.bold)),
        SizedBox(height: tokens.spacing(4)),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: logItems.length,
          itemBuilder: (context, index) {
            final entry = logItems.entries.elementAt(index);
            return Card(
              elevation: 0,
              color: tokens.surface,
              shape: RoundedRectangleBorder(borderRadius: tokens.cornerLarge()),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: tokens.spacing(4), vertical: tokens.spacing(3)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(entry.key, style: tokens.bodyLarge.copyWith(color: tokens.textPrimary, fontWeight: FontWeight.w600)),
                    Row(
                      children: [
                        Text(entry.value, style: tokens.bodyMedium.copyWith(color: tokens.textMuted)),
                        SizedBox(width: tokens.spacing(2)),
                        Container(
                          padding: EdgeInsets.all(tokens.spacing(1)),
                          decoration: BoxDecoration(color: Colors.green.shade500, shape: BoxShape.circle),
                          child: Icon(Icons.check, color: Colors.white, size: tokens.spacing(4)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
          separatorBuilder: (context, index) => SizedBox(height: tokens.spacing(3)),
        ),
      ],
    );
  }
}