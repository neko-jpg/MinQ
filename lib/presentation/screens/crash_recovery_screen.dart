import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:minq/data/services/crash_recovery_store.dart';
import 'package:minq/presentation/controllers/crash_recovery_controller.dart';
import 'package:minq/presentation/theme/minq_theme.dart';

class CrashRecoveryScreen extends ConsumerStatefulWidget {
  const CrashRecoveryScreen({super.key});

  @override
  ConsumerState<CrashRecoveryScreen> createState() =>
      _CrashRecoveryScreenState();
}

class _CrashRecoveryScreenState extends ConsumerState<CrashRecoveryScreen> {
  bool _showDetails = false;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final state = ref.watch(crashRecoveryControllerProvider);
    final report = state.report;
    final hasDetails =
        report != null &&
        (report.message.isNotEmpty || report.stackTrace.isNotEmpty);
    final animationDuration = tokens.getAnimationDuration(
      context,
      const Duration(milliseconds: 250),
    );

    return Scaffold(
      backgroundColor: tokens.background,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Padding(
              padding: EdgeInsets.all(tokens.spacing(6)),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.refresh,
                    size: tokens.spacing(12),
                    color: tokens.brandPrimary,
                  ),
                  SizedBox(height: tokens.spacing(4)),
                  Text(
                    '前回のセッションを復元しますか？',
                    style: tokens.typeScale.h3.copyWith(
                      color: tokens.textPrimary,
                    ),
                  ),
                  SizedBox(height: tokens.spacing(2)),
                  Text(
                    '前回の起動でアプリが予期せず終了しました。状態を復元すると、保存されていないデータを再読み込みします。',
                    style: tokens.typeScale.bodyMedium.copyWith(
                      color: tokens.textMuted,
                    ),
                  ),
                  if (hasDetails) ...[
                    SizedBox(height: tokens.spacing(4)),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        onPressed:
                            () => setState(() => _showDetails = !_showDetails),
                        icon: Icon(
                          _showDetails ? Icons.expand_less : Icons.expand_more,
                        ),
                        label: Text(_showDetails ? '詳細を閉じる' : '詳細を表示'),
                      ),
                    ),
                    AnimatedCrossFade(
                      duration: animationDuration,
                      crossFadeState:
                          _showDetails
                              ? CrossFadeState.showSecond
                              : CrossFadeState.showFirst,
                      firstChild: const SizedBox.shrink(),
                      secondChild: _CrashDetailCard(report: report),
                    ),
                  ],
                  SizedBox(height: tokens.spacing(6)),
                  if (state.isRestoring)
                    Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          tokens.brandPrimary,
                        ),
                      ),
                    )
                  else ...[
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: () async {
                          await ref
                              .read(crashRecoveryControllerProvider.notifier)
                              .restoreAndResume();
                        },
                        child: const Text('状態を復元する'),
                      ),
                    ),
                    SizedBox(height: tokens.spacing(2)),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () async {
                          await ref
                              .read(crashRecoveryControllerProvider.notifier)
                              .discardRecovery();
                        },
                        child: const Text('破棄して起動する'),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CrashDetailCard extends StatelessWidget {
  const _CrashDetailCard({required this.report});

  final CrashReport report;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final dateFormatter = DateFormat.yMMMd().add_Hm();
    final recordedAt = dateFormatter.format(report.recordedAt.toLocal());

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(tokens.spacing(3)),
      decoration: BoxDecoration(
        color: tokens.surface,
        borderRadius: tokens.cornerLarge(),
        border: Border.all(color: tokens.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '記録時刻: $recordedAt',
            style: tokens.bodySmall.copyWith(color: tokens.textMuted),
          ),
          SizedBox(height: tokens.spacing(2)),
          Text(
            report.message,
            style: tokens.bodyMedium.copyWith(color: tokens.textPrimary),
          ),
          if (report.stackTrace.isNotEmpty) ...[
            SizedBox(height: tokens.spacing(3)),
            Text(
              'スタックトレース',
              style: tokens.bodySmall.copyWith(color: tokens.textMuted),
            ),
            SizedBox(height: tokens.spacing(1)),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(tokens.spacing(2)),
              decoration: BoxDecoration(
                color: tokens.background,
                borderRadius: tokens.cornerMedium(),
                border: Border.all(color: tokens.border),
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SelectableText(
                  report.stackTrace,
                  style: tokens.bodySmall.copyWith(color: tokens.textMuted),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
