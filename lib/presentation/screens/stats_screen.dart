import 'package:flutter/material.dart';
import 'package:flutter_heatmap_calendar/flutter_heatmap_calendar.dart';
import 'package:go_router/go_router.dart';
import 'package:minq/presentation/common/minq_empty_state.dart';
import 'package:minq/presentation/theme/minq_theme.dart';
import 'package:minq/presentation/common/minq_skeleton.dart';

final Map<DateTime, int> _heatmapData = {
  DateTime(2024, 6, 3): 5,
  DateTime(2024, 6, 4): 7,
  DateTime(2024, 6, 5): 10,
  DateTime(2024, 6, 6): 3,
  DateTime(2024, 6, 8): 6,
  DateTime(2024, 6, 9): 8,
  DateTime(2024, 6, 10): 10,
  DateTime(2024, 6, 12): 5,
  DateTime(2024, 6, 13): 9,
  DateTime(2024, 6, 17): 4,
  DateTime(2024, 6, 21): 10,
  DateTime(2024, 6, 22): 7,
  DateTime(2024, 6, 23): 8,
};

class _DailyLogEntry {
  const _DailyLogEntry({required this.dateLabel, required this.time});

  final String dateLabel;
  final String time;
}

const List<_DailyLogEntry> _dailyLogs = <_DailyLogEntry>[
  _DailyLogEntry(dateLabel: 'Today', time: '8:15 AM'),
  _DailyLogEntry(dateLabel: 'Yesterday', time: '7:50 AM'),
  _DailyLogEntry(dateLabel: 'June 22, 2024', time: '9:02 AM'),
];

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  bool _showHelpBanner = true;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    Future<void>.delayed(const Duration(milliseconds: 600), () {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final hasActivity = _heatmapData.isNotEmpty;
    final hasLogs = _dailyLogs.isNotEmpty;

    return Scaffold(
      backgroundColor: tokens.background,
      appBar: AppBar(
        title: Text(
          'Progress',
          style: tokens.titleMedium.copyWith(color: tokens.textPrimary),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
      ),
      body: _isLoading
          ? _StatsSkeleton(tokens: tokens)
          : !(hasActivity || hasLogs)
              ? Center(
                  child: MinqEmptyState(
                    icon: Icons.insights_outlined,
                    title: 'まだRecordがありません',
                    message:
                        'Recordすると、ストリークやヒートマップで成長が見えるようになります。',
                    actionLabel: '最初のRecordをする',
                    onAction: () => context.go('/record'),
                  ),
                )
              : ListView(
                  padding: EdgeInsets.all(tokens.spacing(5)),
                  children: <Widget>[
                    if (_showHelpBanner)
                      Card(
                        elevation: 0,
                        color: tokens.brandPrimary.withValues(alpha: 0.1),
                        shape: RoundedRectangleBorder(
                            borderRadius: tokens.cornerLarge()),
                        child: ListTile(
                          leading: Icon(Icons.info_outline, color: tokens.brandPrimary),
                          title: Text(
                            '毎日のRecordをヒートマップで振り返り、ストリークを伸ばすモチベーションにしよう。',
                            style: tokens.bodySmall
                                .copyWith(color: tokens.textPrimary),
                          ),
                          trailing: IconButton(
                            icon: Icon(Icons.close, color: tokens.textPrimary),
                            onPressed: () =>
                                setState(() => _showHelpBanner = false),
                          ),
                        ),
                      ),
                    if (hasActivity) _buildStreakCounter(tokens),
                    if (hasActivity) SizedBox(height: tokens.spacing(6)),
                    if (hasActivity) _buildHeatmapCard(tokens),
                    if (hasLogs && hasActivity)
                      SizedBox(height: tokens.spacing(6)),
                    if (hasLogs) _buildDailyLog(tokens),
                  ],
                ),
    );
  }

  Widget _buildStreakCounter(MinqTheme tokens) {
    return Column(
      children: <Widget>[
        Text(
          'Current Streak',
          style: tokens.bodySmall.copyWith(color: tokens.textMuted),
        ),
        SizedBox(height: tokens.spacing(2)),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Icon(
              Icons.local_fire_department,
              color: Colors.amber,
              size: tokens.spacing(13),
            ),
            SizedBox(width: tokens.spacing(2)),
            Text(
              '21',
              style: tokens.titleLarge.copyWith(
                color: tokens.textPrimary,
                fontSize: (tokens.titleLarge.fontSize ?? 28) * 2,
              ),
            ),
          ],
        ),
        Text('days', style: tokens.bodySmall.copyWith(color: tokens.textMuted)),
      ],
    );
  }

  Widget _buildHeatmapCard(MinqTheme tokens) {
    return Card(
      elevation: 0,
      color: tokens.surface,
      shape: RoundedRectangleBorder(borderRadius: tokens.cornerLarge()),
      shadowColor: Colors.transparent,
      child: Padding(
        padding: EdgeInsets.all(tokens.spacing(4)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  'Activity Heatmap',
                  style: tokens.titleSmall.copyWith(color: tokens.textPrimary),
                ),
                Row(
                  children: <Widget>[
                    Text(
                      'This month',
                      style: tokens.bodySmall.copyWith(color: tokens.textMuted),
                    ),
                    Icon(Icons.expand_more, color: tokens.textMuted),
                  ],
                ),
              ],
            ),
            SizedBox(height: tokens.spacing(4)),
            HeatMap(
              datasets: _heatmapData,
              colorMode: ColorMode.opacity,
              showText: false,
              scrollable: true,
              colorsets: <int, Color>{1: tokens.brandPrimary},
              defaultColor: tokens.brandPrimary.withValues(alpha: 0.05),
              borderRadius: 8,
              margin: EdgeInsets.all(tokens.spacing(0.5)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDailyLog(MinqTheme tokens) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Daily Log',
          style: tokens.titleSmall.copyWith(color: tokens.textPrimary),
        ),
        SizedBox(height: tokens.spacing(3)),
        ..._dailyLogs.map((entry) => _LogItem(entry: entry)),
      ],
    );
  }
}

class _LogItem extends StatelessWidget {
  const _LogItem({required this.entry});

  final _DailyLogEntry entry;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Card(
      elevation: 0,
      margin: EdgeInsets.symmetric(vertical: tokens.spacing(1)),
      color: tokens.surface,
      shape: RoundedRectangleBorder(borderRadius: tokens.cornerMedium()),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: tokens.spacing(4),
          vertical: tokens.spacing(3),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(
              entry.dateLabel,
              style: tokens.bodyMedium.copyWith(
                color: tokens.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            Row(
              children: <Widget>[
                Text(
                  entry.time,
                  style: tokens.bodySmall.copyWith(color: tokens.textMuted),
                ),
                SizedBox(width: tokens.spacing(2)),
                CircleAvatar(
                  radius: tokens.spacing(4),
                  backgroundColor: tokens.accentSuccess,
                  child: Icon(
                    Icons.check,
                    color: tokens.surface,
                    size: tokens.spacing(3),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatsSkeleton extends StatelessWidget {
  const _StatsSkeleton({required this.tokens});

  final MinqTheme tokens;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.all(tokens.spacing(5)),
      children: <Widget>[
        MinqSkeleton(
          height: tokens.spacing(12),
          borderRadius: tokens.cornerLarge(),
        ),
        SizedBox(height: tokens.spacing(4)),
        MinqSkeleton(
          height: tokens.spacing(24),
          borderRadius: tokens.cornerLarge(),
        ),
        SizedBox(height: tokens.spacing(4)),
        MinqSkeleton(
          height: tokens.spacing(30),
          borderRadius: tokens.cornerLarge(),
        ),
        SizedBox(height: tokens.spacing(4)),
        const MinqSkeletonLine(width: 160, height: 20),
        SizedBox(height: tokens.spacing(3)),
        const MinqSkeletonList(itemCount: 3, itemHeight: 64),
      ],
    );
  }
}
