import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:minq/data/providers.dart';
import 'package:minq/domain/stats/stats_view_data.dart';
import 'package:minq/presentation/common/minq_buttons.dart';
import 'package:minq/presentation/common/minq_empty_state.dart';
import 'package:minq/presentation/controllers/stats_data_controller.dart';
import 'package:minq/presentation/controllers/sync_status_controller.dart';
import 'package:minq/presentation/routing/app_router.dart';
import 'package:minq/presentation/theme/minq_theme.dart';

class StatsScreen extends ConsumerStatefulWidget {
  const StatsScreen({super.key});

  @override
  ConsumerState<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends ConsumerState<StatsScreen> {
  ProviderSubscription<SyncStatus>? _syncStatusSubscription;
  bool _hasRequestedReview = false;

  @override
  void initState() {
    super.initState();
    _syncStatusSubscription = ref.listenManual<SyncStatus>(syncStatusProvider, (previous, next) {
      if (!mounted) return;
      if (next.showBanner && next.bannerMessage != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          final messenger = ScaffoldMessenger.of(context);
          messenger.hideCurrentSnackBar();
          messenger.showSnackBar(
            SnackBar(
              content: Text(next.bannerMessage!),
              duration: const Duration(seconds: 2),
            ),
          );
          ref.read(syncStatusProvider.notifier).acknowledgeBanner();
        });
      }
    });

    // Stats逕ｻ髱｢陦ｨ遉ｺ譎ゅ↓繝ｬ繝薙Η繝ｼ繝ｪ繧ｯ繧ｨ繧ｹ繝医ｒ隧ｦ陦・
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _maybeRequestReview();
    });
  }

  Future<void> _maybeRequestReview() async {
    if (_hasRequestedReview || !mounted) return;
    _hasRequestedReview = true;

    try {
      final statsData = await ref.read(statsDataProvider.future);
      final totalCompleted = statsData.heatmap.values.fold<int>(0, (sum, count) => sum + count);
      
      final reviewService = ref.read(inAppReviewServiceProvider);
      await reviewService.maybeRequestReviewByQuestCount(
        completedCount: totalCompleted,
      );
    } catch (e) {
      // 繧ｨ繝ｩ繝ｼ縺ｯ辟｡隕厄ｼ医Θ繝ｼ繧ｶ繝ｼ菴馴ｨ薙ｒ謳阪↑繧上↑縺・ｼ・
    }
  }

  @override
  void dispose() {
    _syncStatusSubscription?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final l10n = AppLocalizations.of(context)!;
    final statsAsync = ref.watch(statsDataProvider);
    final StatsViewData? data = statsAsync.valueOrNull;
    final bool hasCachedContent = data?.hasCachedContent ?? false;
    final bool isLoading = statsAsync.isLoading && !hasCachedContent;
    final bool hasError = statsAsync.hasError && !hasCachedContent;
    final bool isRefreshing = statsAsync.isLoading && hasCachedContent;
    final StatsViewData content = data ?? StatsViewData.empty();

    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (hasError) {
      return Scaffold(
        body: Center(child: Text(l10n.errorGeneric)),
      );
    }

    return Scaffold(
      backgroundColor: tokens.background,
      appBar: AppBar(
        title: Text(
          '騾ｲ謐・,
          style:
              tokens.titleMedium.copyWith(color: tokens.textPrimary, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: MinqIconButton(icon: Icons.arrow_back, onTap: () => context.pop()),
        backgroundColor: tokens.background.withValues(alpha: 0.9),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          const maxWidth = 640.0;

          Widget child = ListView(
            padding: EdgeInsets.symmetric(
              horizontal: tokens.spacing(4),
              vertical: tokens.spacing(6),
            ),
            children: [
              if (isRefreshing)
                Padding(
                  padding: EdgeInsets.only(bottom: tokens.spacing(3)),
                  child: const LinearProgressIndicator(),
                ),
              _buildStreakCard(context, tokens, content, l10n),
              SizedBox(height: tokens.spacing(6)),
              _buildTodayStatsCard(context, tokens, content, ref),
              SizedBox(height: tokens.spacing(6)),
              _buildWeeklyStatsCard(context, tokens, content, ref),
              SizedBox(height: tokens.spacing(6)),
              _buildGoalCard(context, tokens),
              SizedBox(height: tokens.spacing(6)),
              _buildCompareProgressCard(context, ref, tokens),
              SizedBox(height: tokens.spacing(6)),
              _buildWeeklyProgressCard(context, ref, tokens),
              SizedBox(height: tokens.spacing(6)),
              _buildCalendarCard(context, ref, tokens, content.heatmap),
            ],
          );

          if (constraints.maxWidth > maxWidth) {
            child = Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: maxWidth),
                child: child,
              ),
            );
          }

          return child;
        },
      ),
    );
  }
}
Widget _buildStreakCard(
  BuildContext context,
  MinqTheme tokens,
  StatsViewData data,
  AppLocalizations l10n,
) {
  final int streak = data.streak;
  final bool hasStreak = streak > 0;
  final String streakText = '$streak';
  final String streakDescription = hasStreak
      ? l10n.streakDayCount(streak)
      : '縺ｾ縺騾｣邯夊ｨ倬鹸縺後≠繧翫∪縺帙ｓ';

  return Card(
    color: tokens.surface,
    shape: RoundedRectangleBorder(
      borderRadius: tokens.cornerXLarge(),
      side: BorderSide(color: tokens.border),
    ),
    elevation: 0,
    child: Padding(
      padding: EdgeInsets.all(tokens.spacing(6)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            '迴ｾ蝨ｨ縺ｮ騾｣邯壽律謨ｰ',
            style: tokens.typeScale.bodyMedium.copyWith(color: tokens.textMuted),
          ),
          SizedBox(height: tokens.spacing(2)),
          Semantics(
            label: streakDescription,
            value: streakDescription,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  Icons.local_fire_department,
                  size: tokens.spacing(12),
                  color: hasStreak ? tokens.brandPrimary : tokens.textMuted,
                ),
                SizedBox(width: tokens.spacing(2)),
                Text(
                  streakText,
                  style: tokens.typeScale.h1.copyWith(color: tokens.textPrimary),
                ),
              ],
            ),
          ),
          SizedBox(height: tokens.spacing(2)),
          Text(
            hasStreak
                ? streakDescription
                : '莉頑律縺ｮ譛蛻昴・鄙呈・繧定ｨ倬鹸縺励※騾｣邯壽律謨ｰ繧偵せ繧ｿ繝ｼ繝医＠縺ｾ縺励ｇ縺・・,
            style: tokens.typeScale.bodyMedium.copyWith(color: tokens.textMuted),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ),
  );
}

Widget _buildGoalCard(BuildContext context, MinqTheme tokens) {
  return Card(
    color: tokens.surface,
    shape: RoundedRectangleBorder(
      borderRadius: tokens.cornerXLarge(),
      side: BorderSide(color: tokens.border),
    ),
    elevation: 0,
    child: ListTile(
      onTap: () => _showGoalBottomSheet(context, tokens),
      contentPadding: EdgeInsets.symmetric(
        horizontal: tokens.spacing(4),
        vertical: tokens.spacing(2),
      ),
      leading: Container(
        width: tokens.spacing(10),
        height: tokens.spacing(10),
        decoration: BoxDecoration(
          color: tokens.brandPrimary.withValues(alpha: 0.12),
          borderRadius: tokens.cornerLarge(),
        ),
        child: Icon(Icons.flag, color: tokens.brandPrimary, size: tokens.spacing(6)),
      ),
      title: Text(
        '逶ｮ讓呵ｨｭ螳・,
        style: tokens.typeScale.h4.copyWith(color: tokens.textPrimary),
      ),
      subtitle: Padding(
        padding: EdgeInsets.only(top: tokens.spacing(1)),
        child: Text(
          '莉頑怦縺ｮ逶ｮ讓・ 5譌･邯咏ｶ・,
          style: tokens.typeScale.bodySmall.copyWith(color: tokens.textMuted),
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '邱ｨ髮・☆繧・,
            style: tokens.typeScale.bodySmall.copyWith(color: tokens.brandPrimary),
          ),
          SizedBox(width: tokens.spacing(1)),
          Icon(Icons.chevron_right, color: tokens.brandPrimary),
        ],
      ),
    ),
  );
}

void _showGoalBottomSheet(BuildContext context, MinqTheme tokens) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    shape: RoundedRectangleBorder(borderRadius: tokens.cornerXLarge()),
    builder: (context) {
      return SafeArea(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height * 0.3,
          ),
          child: SingleChildScrollView(
            padding: EdgeInsets.only(
              left: tokens.spacing(4),
              right: tokens.spacing(4),
              top: tokens.spacing(4),
              bottom: MediaQuery.of(context).viewInsets.bottom + tokens.spacing(4),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('逶ｮ讓吶ｒ邱ｨ髮・☆繧・, style: tokens.titleMedium.copyWith(fontWeight: FontWeight.bold)),
                SizedBox(height: tokens.spacing(4)),
                TextField(
                  decoration: InputDecoration(
                    labelText: '騾｣邯壽律謨ｰ縺ｮ逶ｮ讓・,
                    hintText: '萓・ 7',
                    border: OutlineInputBorder(borderRadius: tokens.cornerLarge()),
                  ),
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: tokens.spacing(4)),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('菫晏ｭ倥☆繧・),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
class _ProgressEntry {
  const _ProgressEntry({
    required this.label,
    required this.value,
    required this.unit,
    required this.progress,
    required this.color,
    required this.icon,
    required this.semanticsLabel,
  });

  final String label;
  final double value;
  final String unit;
  final double progress;
  final Color color;
  final IconData icon;
  final String semanticsLabel;
}

class _RingMetric {
  const _RingMetric({
    required this.label,
    required this.value,
    required this.unit,
    required this.progress,
    this.delta,
  });

  final String label;
  final double value;
  final String unit;
  final double progress;
  final double? delta;
}

Widget _buildCompareProgressCard(BuildContext context, WidgetRef ref, MinqTheme tokens) {
  final navigation = ref.read(navigationUseCaseProvider);
  final entries = <_ProgressEntry>[
    _ProgressEntry(
      label: '莉企ｱ',
      value: 5,
      unit: '譌･',
      progress: 0.71,
      color: tokens.brandPrimary,
      icon: Icons.trending_up,
      semanticsLabel: '莉企ｱ縺ｯ5譌･驕疲・縺励※縺・∪縺・,
    ),
    _ProgressEntry(
      label: '蜈磯ｱ',
      value: 6,
      unit: '譌･',
      progress: 0.86,
      color: tokens.serenity,
      icon: Icons.history,
      semanticsLabel: '蜈磯ｱ縺ｯ6譌･驕疲・縺励∪縺励◆',
    ),
  ];
  final hasProgress = entries.any((entry) => entry.progress > 0);
  final double? deltaFromPrevious =
      entries.length >= 2 ? entries.first.value - entries[1].value : null;

  if (!hasProgress) {
    return _buildZeroChart(
      tokens,
      message: '縺ｾ縺豈碑ｼ・〒縺阪ｋ騾ｲ謐励ョ繝ｼ繧ｿ縺後≠繧翫∪縺帙ｓ縲・,
      actionLabel: '險倬鹸縺吶ｋ',
      onAction: () => navigation.goToQuests(),
    );
  }

  return Card(
    color: tokens.surface,
    shape: RoundedRectangleBorder(
      borderRadius: tokens.cornerXLarge(),
      side: BorderSide(color: tokens.border),
    ),
    elevation: 0,
    child: Padding(
      padding: EdgeInsets.all(tokens.spacing(4)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('騾ｲ謐励ｒ豈碑ｼ・☆繧・, style: tokens.titleLarge.copyWith(color: tokens.textPrimary, fontWeight: FontWeight.bold)),
          SizedBox(height: tokens.spacing(3)),
          Wrap(
            spacing: tokens.spacing(3),
            runSpacing: tokens.spacing(2),
            children: [
              for (final entry in entries)
                Semantics(
                  container: true,
                  label: entry.semanticsLabel,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _LegendBadge(color: entry.color, icon: entry.icon),
                      SizedBox(width: tokens.spacing(1.5)),
                      Text(
                        '${entry.label}・・{entry.unit}・・,
                        style: tokens.typeScale.bodySmall.copyWith(color: tokens.textMuted),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          SizedBox(height: tokens.spacing(4)),
          for (int i = 0; i < entries.length; i++) ...[
            _buildProgressBar(
              tokens,
              entries[i],
              isPrimary: i == 0,
              delta: i == 0 ? deltaFromPrevious : null,
            ),
            if (i < entries.length - 1) SizedBox(height: tokens.spacing(4)),
          ],
        ],
      ),
    ),
  );
}

Widget _buildWeeklyProgressCard(BuildContext context, WidgetRef ref, MinqTheme tokens) {
  final navigation = ref.read(navigationUseCaseProvider);
  const hasProgress = true; // Replace with actual data when available

  if (!hasProgress) {
    return _buildZeroChart(
      tokens,
      message: '騾ｱ髢薙・騾ｲ謐励′縺ｾ縺縺ゅｊ縺ｾ縺帙ｓ縲・,
      actionLabel: '鄙呈・繧定ｿｽ蜉縺吶ｋ',
      onAction: () => navigation.goToQuests(),
    );
  }

  final metrics = <_RingMetric>[
    const _RingMetric(label: '譌･謨ｰ', value: 5, unit: '譌･', progress: 0.71, delta: 1),
    const _RingMetric(label: '蜷郁ｨ域凾髢・, value: 4.2, unit: '譎る俣', progress: 0.6, delta: -0.3),
    const _RingMetric(label: '蟷ｳ蝮・凾髢・, value: 32, unit: '蛻・, progress: 0.75, delta: 2),
  ];

  return Card(
    color: tokens.surface,
    shape: RoundedRectangleBorder(
      borderRadius: tokens.cornerXLarge(),
      side: BorderSide(color: tokens.border),
    ),
    elevation: 0,
    child: Padding(
      padding: EdgeInsets.all(tokens.spacing(4)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('騾ｱ髢薙・騾ｲ謐・, style: tokens.titleLarge.copyWith(color: tokens.textPrimary, fontWeight: FontWeight.bold)),
          SizedBox(height: tokens.spacing(4)),
          Row(
            children: [
              for (final metric in metrics)
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: tokens.spacing(2)),
                    child: _buildProgressRing(tokens, metric),
                  ),
                ),
            ],
          ),
        ],
      ),
    ),
  );
}

Widget _buildZeroChart(
  MinqTheme tokens, {
  required String message,
  required String actionLabel,
  required VoidCallback onAction,
}) {
  return Card(
    color: tokens.surface,
    shape: RoundedRectangleBorder(
      borderRadius: tokens.cornerXLarge(),
      side: BorderSide(color: tokens.border),
    ),
    elevation: 0,
    child: Padding(
      padding: EdgeInsets.symmetric(
        horizontal: tokens.spacing(4),
        vertical: tokens.spacing(6),
      ),
      child: MinqEmptyState(
        icon: Icons.insights_outlined,
        title: '繝・・繧ｿ縺後≠繧翫∪縺帙ｓ',
        message: message,
        actionArea: ElevatedButton(
          onPressed: onAction,
          child: Text(actionLabel),
        ),
      ),
    ),
  );
}

Widget _buildProgressBar(
  MinqTheme tokens,
  _ProgressEntry entry, {
  bool isPrimary = false,
  double? delta,
}) {
  final progressColor =
      isPrimary ? entry.color : entry.color.withValues(alpha: 0.7);
  final deltaLabel = delta != null ? _formatDelta(delta, entry.unit) : null;
  final valueText = '${entry.value.toStringAsFixed(entry.value % 1 == 0 ? 0 : 1)}${entry.unit}';

  return RepaintBoundary(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _LegendBadge(color: progressColor, icon: entry.icon),
            SizedBox(width: tokens.spacing(2)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.label,
                    style: tokens.typeScale.bodyMedium.copyWith(
                      color: tokens.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (deltaLabel != null)
                    Text(
                      '蜈磯ｱ豈・$deltaLabel',
                      style: tokens.typeScale.bodySmall
                          .copyWith(color: tokens.textMuted),
                    ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  valueText,
                  style: tokens.typeScale.bodyMedium.copyWith(
                    color: tokens.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
        SizedBox(height: tokens.spacing(2)),
        Semantics(
          label: entry.semanticsLabel,
          value: '${(entry.progress * 100).round()}%',
          child: ClipRRect(
            borderRadius: tokens.cornerLarge(),
            child: LinearProgressIndicator(
              value: entry.progress.clamp(0.0, 1.0),
              minHeight: 10,
              backgroundColor: tokens.border.withValues(alpha: 0.3),
              valueColor: AlwaysStoppedAnimation<Color>(progressColor),
            ),
          ),
        ),
      ],
    ),
  );
}

class _LegendBadge extends StatelessWidget {
  const _LegendBadge({required this.color, required this.icon});

  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final Color iconColor =
        tokens.ensureAccessibleOnBackground(tokens.textPrimary, color);
    return Container(
      width: tokens.spacing(6),
      height: tokens.spacing(6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: tokens.cornerMedium(),
        border: Border.all(color: tokens.border.withValues(alpha: 0.4)),
      ),
      alignment: Alignment.center,
      child: Icon(icon, color: iconColor, size: tokens.spacing(3.5)),
    );
  }
}

String _formatDelta(double delta, String unit) {
  if (delta > 0) {
    return '笆ｲ${delta.toStringAsFixed(delta.abs() < 1 ? 1 : 0)}$unit';
  }
  if (delta < 0) {
    return '笆ｼ${delta.abs().toStringAsFixed(delta.abs() < 1 ? 1 : 0)}$unit';
  }
  return 'ﾂｱ0$unit';
}
Widget _buildProgressRing(MinqTheme tokens, _RingMetric metric) {
  final hasProgress = metric.progress > 0;
  final valueText =
      '${metric.value.toStringAsFixed(metric.value % 1 == 0 ? 0 : 1)}${metric.unit}';
  final deltaLabel =
      metric.delta != null ? _formatDelta(metric.delta!, metric.unit) : null;
  return RepaintBoundary(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 96,
          height: 96,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CircularProgressIndicator(
                value: 1,
                strokeWidth: 8,
                valueColor: AlwaysStoppedAnimation<Color>(tokens.border.withValues(alpha: 0.3)),
                backgroundColor: Colors.transparent,
              ),
              if (hasProgress)
                CircularProgressIndicator(
                  value: metric.progress.clamp(0.0, 1.0),
                  strokeWidth: 8,
                  valueColor: AlwaysStoppedAnimation<Color>(tokens.brandPrimary),
                  backgroundColor: Colors.transparent,
                ),
              Padding(
                padding: EdgeInsets.all(tokens.spacing(2)),
                child: hasProgress
                    ? Text(
                        valueText,
                        style: tokens.typeScale.bodyMedium
                            .copyWith(color: tokens.textPrimary, fontWeight: FontWeight.bold),
                      )
                    : Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.hourglass_empty, size: tokens.spacing(6), color: tokens.textMuted),
                          SizedBox(height: tokens.spacing(2)),
                          Text('譛ｪ險域ｸｬ', style: tokens.bodySmall.copyWith(color: tokens.textMuted)),
                        ],
                      ),
              ),
            ],
          ),
        ),
        SizedBox(height: tokens.spacing(2)),
        Text(
          metric.label,
          style: tokens.typeScale.bodySmall.copyWith(
            color: tokens.textMuted,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
        if (deltaLabel != null) ...[
          SizedBox(height: tokens.spacing(1)),
          Text(
            '蜈磯ｱ豈・$deltaLabel',
            style: tokens.typeScale.bodySmall.copyWith(color: tokens.textMuted),
          ),
        ],
      ],
    ),
  );
}
Widget _buildCalendarCard(
  BuildContext context,
  WidgetRef ref,
  MinqTheme tokens,
  Map<DateTime, int> data,
) {
  final navigation = ref.read(navigationUseCaseProvider);
  final now = DateTime.now();
  final monthName = DateFormat.MMMM('ja').format(now);
  final daysInMonth = DateUtils.getDaysInMonth(now.year, now.month);
  final firstDayOfMonth = DateTime(now.year, now.month, 1);
  final weekdayOfFirstDay = firstDayOfMonth.weekday;
  final hasData = data.values.any((value) => value > 0);

  if (!hasData) {
    return _buildZeroChart(
      tokens,
      message: '繧ｫ繝ｬ繝ｳ繝繝ｼ縺ｫ陦ｨ遉ｺ縺ｧ縺阪ｋ險倬鹸縺後∪縺縺ゅｊ縺ｾ縺帙ｓ縲・,
      actionLabel: '莉頑律縺ｮ鄙呈・繧定ｨ倬鹸縺吶ｋ',
      onAction: () => navigation.goToQuests(),
    );
  }

  return Card(
    color: tokens.surface,
    shape: RoundedRectangleBorder(
      borderRadius: tokens.cornerXLarge(),
      side: BorderSide(color: tokens.border),
    ),
    elevation: 0,
    child: Padding(
      padding: EdgeInsets.all(tokens.spacing(4)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(monthName, style: tokens.titleLarge.copyWith(color: tokens.textPrimary, fontWeight: FontWeight.bold)),
              Row(
                children: [
                  IconButton(onPressed: () {}, icon: const Icon(Icons.chevron_left)),
                  IconButton(onPressed: () {}, icon: const Icon(Icons.chevron_right)),
                ],
              ),
            ],
          ),
          SizedBox(height: tokens.spacing(4)),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 7),
            itemCount: daysInMonth + weekdayOfFirstDay - 1,
            itemBuilder: (context, index) {
              if (index < weekdayOfFirstDay - 1) {
                return const SizedBox.shrink();
              }
              final day = index - (weekdayOfFirstDay - 2);
              final date = DateTime(now.year, now.month, day);
              final value = data[DateUtils.dateOnly(date)] ?? 0;
              final isToday = DateUtils.isSameDay(date, now);

              return Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: value > 0 ? tokens.brandPrimary.withOpacity(value / 5.0) : Colors.transparent,
                  shape: BoxShape.circle,
                  border: isToday ? Border.all(color: tokens.brandPrimary, width: 2) : null,
                ),
                child: Text(
                  '$day',
                  style: tokens.bodyMedium.copyWith(color: tokens.textPrimary),
                ),
              );
            },
          ),
        ],
      ),
    ),
  );
}
Widget _buildTodayStatsCard(
  BuildContext context,
  MinqTheme tokens,
  StatsViewData data,
  WidgetRef ref,
) {
  final navigation = ref.read(navigationUseCaseProvider);
  final todayCount = data.todayCompletionCount;
  final hasProgress = todayCount > 0;

  if (!hasProgress) {
    return Card(
      color: tokens.surface,
      shape: RoundedRectangleBorder(
        borderRadius: tokens.cornerXLarge(),
        side: BorderSide(color: tokens.border),
      ),
      elevation: 0,
      child: Padding(
        padding: EdgeInsets.all(tokens.spacing(6)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              Icons.today_outlined,
              size: tokens.spacing(12),
              color: tokens.textMuted,
            ),
            SizedBox(height: tokens.spacing(3)),
            Text(
              '莉頑律縺ｯ縺ｾ縺險倬鹸縺後≠繧翫∪縺帙ｓ',
              style: tokens.titleMedium.copyWith(
                color: tokens.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: tokens.spacing(2)),
            Text(
              '譛蛻昴・繧ｯ繧ｨ繧ｹ繝医ｒ螳御ｺ・＠縺ｦ縲∽ｻ頑律縺ｮ險倬鹸繧貞ｧ九ａ縺ｾ縺励ｇ縺・ｼ・,
              style: tokens.bodyMedium.copyWith(color: tokens.textMuted),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: tokens.spacing(4)),
            ElevatedButton(
              onPressed: () => navigation.goToQuests(),
              child: const Text('繧ｯ繧ｨ繧ｹ繝医ｒ隕九ｋ'),
            ),
          ],
        ),
      ),
    );
  }

  return Card(
    color: tokens.surface,
    shape: RoundedRectangleBorder(
      borderRadius: tokens.cornerXLarge(),
      side: BorderSide(color: tokens.border),
    ),
    elevation: 0,
    child: Padding(
      padding: EdgeInsets.all(tokens.spacing(6)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            '莉頑律縺ｮ螳御ｺ・焚',
            style: tokens.typeScale.bodyMedium.copyWith(color: tokens.textMuted),
          ),
          SizedBox(height: tokens.spacing(2)),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                Icons.check_circle,
                size: tokens.spacing(12),
                color: tokens.accentSuccess,
              ),
              SizedBox(width: tokens.spacing(2)),
              Text(
                '$todayCount',
                style: tokens.typeScale.h1.copyWith(color: tokens.textPrimary),
              ),
            ],
          ),
          SizedBox(height: tokens.spacing(2)),
          Text(
            todayCount >= 3 
                ? '邏譎ｴ繧峨＠縺・ｼ∽ｻ頑律縺ｮ逶ｮ讓吶ｒ驕疲・縺励∪縺励◆縲・
                : '逶ｮ讓吶∪縺ｧ縺ゅ→${3 - todayCount}蛟九〒縺吶・,
            style: tokens.typeScale.bodyMedium.copyWith(color: tokens.textMuted),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ),
  );
}

Widget _buildWeeklyStatsCard(
  BuildContext context,
  MinqTheme tokens,
  StatsViewData data,
  WidgetRef ref,
) {
  final navigation = ref.read(navigationUseCaseProvider);
  final weeklyRate = data.weeklyCompletionRate;
  final percentage = (weeklyRate * 100).round();
  final hasProgress = weeklyRate > 0;

  if (!hasProgress) {
    return Card(
      color: tokens.surface,
      shape: RoundedRectangleBorder(
        borderRadius: tokens.cornerXLarge(),
        side: BorderSide(color: tokens.border),
      ),
      elevation: 0,
      child: Padding(
        padding: EdgeInsets.all(tokens.spacing(6)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              Icons.calendar_today,
              size: tokens.spacing(12),
              color: tokens.textMuted,
            ),
            SizedBox(height: tokens.spacing(3)),
            Text(
              '莉企ｱ縺ｯ縺ｾ縺險倬鹸縺後≠繧翫∪縺帙ｓ',
              style: tokens.titleMedium.copyWith(
                color: tokens.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: tokens.spacing(2)),
            Text(
              '莉企ｱ縺ｮ鄙呈・繧貞ｧ九ａ縺ｦ縲・ｱ髢馴＃謌千紫繧貞髄荳翫＆縺帙∪縺励ｇ縺・ｼ・,
              style: tokens.bodyMedium.copyWith(color: tokens.textMuted),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: tokens.spacing(4)),
            ElevatedButton(
              onPressed: () => navigation.goToQuests(),
              child: const Text('莉翫☆縺仙ｧ九ａ繧・),
            ),
          ],
        ),
      ),
    );
  }

  return Card(
    color: tokens.surface,
    shape: RoundedRectangleBorder(
      borderRadius: tokens.cornerXLarge(),
      side: BorderSide(color: tokens.border),
    ),
    elevation: 0,
    child: Padding(
      padding: EdgeInsets.all(tokens.spacing(6)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            '莉企ｱ縺ｮ驕疲・邇・,
            style: tokens.typeScale.bodyMedium.copyWith(color: tokens.textMuted),
          ),
          SizedBox(height: tokens.spacing(4)),
          SizedBox(
            width: 120,
            height: 120,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: 1,
                  strokeWidth: 12,
                  valueColor: AlwaysStoppedAnimation<Color>(tokens.border.withValues(alpha: 0.3)),
                  backgroundColor: Colors.transparent,
                ),
                CircularProgressIndicator(
                  value: weeklyRate.clamp(0.0, 1.0),
                  strokeWidth: 12,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    weeklyRate >= 0.7 ? tokens.accentSuccess : tokens.brandPrimary,
                  ),
                  backgroundColor: Colors.transparent,
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$percentage%',
                      style: tokens.typeScale.h2.copyWith(
                        color: tokens.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '驕疲・',
                      style: tokens.bodySmall.copyWith(color: tokens.textMuted),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: tokens.spacing(4)),
          Text(
            weeklyRate >= 0.7
                ? '邏譎ｴ繧峨＠縺・ｱ髢薙ヱ繝輔か繝ｼ繝槭Φ繧ｹ縺ｧ縺呻ｼ・
                : weeklyRate >= 0.5
                    ? '濶ｯ縺・・繝ｼ繧ｹ縺ｧ縺吶らｶ咏ｶ壹＠縺ｦ縺・″縺ｾ縺励ｇ縺・・
                    : '莉企ｱ縺ｯ繧ゅ≧蟆代＠鬆大ｼｵ縺｣縺ｦ縺ｿ縺ｾ縺励ｇ縺・・,
            style: tokens.typeScale.bodyMedium.copyWith(color: tokens.textMuted),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ),
  );
}