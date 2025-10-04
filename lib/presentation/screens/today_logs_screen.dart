import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:minq/data/providers.dart';
import 'package:minq/domain/log/quest_log.dart';
import 'package:minq/presentation/common/minq_empty_state.dart';
import 'package:minq/presentation/common/quest_icon_catalog.dart';
import 'package:minq/presentation/controllers/quest_log_controller.dart';
import 'package:minq/presentation/theme/minq_theme.dart';

class TodayLogsScreen extends ConsumerWidget {
  const TodayLogsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.tokens;
    final todayLogsAsync = ref.watch(todayLogsProvider);

    return Scaffold(
      backgroundColor: tokens.background,
      appBar: AppBar(
        title: Text(
          '今日の記録',
          style: tokens.titleMedium.copyWith(
            color: tokens.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        backgroundColor: tokens.background.withValues(alpha: 0.9),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: todayLogsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Text(
            'エラーが発生しました: $error',
            style: tokens.bodyMedium.copyWith(color: tokens.accentError),
          ),
        ),
        data: (logs) {
          if (logs.isEmpty) {
            return Padding(
              padding: EdgeInsets.all(tokens.spacing(4)),
              child: MinqEmptyState(
                icon: Icons.today_outlined,
                title: '今日の記録はありません',
                message: 'クエストを完亁E��ると、ここに記録が表示されます、E,
                actionArea: ElevatedButton(
                  onPressed: () => context.pop(),
                  child: const Text('クエスト一覧に戻めE),
                ),
              ),
            );
          }

          return ListView.builder(
            padding: EdgeInsets.all(tokens.spacing(4)),
            itemCount: logs.length,
            itemBuilder: (context, index) {
              final log = logs[index];
              return _LogCard(log: log);
            },
          );
        },
      ),
    );
  }
}

class _LogCard extends ConsumerWidget {
  const _LogCard({required this.log});

  final QuestLog log;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.tokens;
    final questAsync = ref.watch(questByIdProvider(log.questId));
    final logController = ref.watch(questLogControllerProvider);

    return Card(
      color: tokens.surface,
      shape: RoundedRectangleBorder(
        borderRadius: tokens.cornerLarge(),
        side: BorderSide(color: tokens.border),
      ),
      elevation: 0,
      margin: EdgeInsets.only(bottom: tokens.spacing(3)),
      child: Padding(
        padding: EdgeInsets.all(tokens.spacing(4)),
        child: questAsync.when(
          loading: () => const SizedBox(
            height: 60,
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (error, _) => ListTile(
            leading: const Icon(Icons.error_outline),
            title: const Text('クエストが見つかりません'),
            subtitle: Text('ID: ${log.questId}'),
          ),
          data: (quest) {
            if (quest == null) {
              return ListTile(
                leading: const Icon(Icons.error_outline),
                title: const Text('クエストが見つかりません'),
                subtitle: Text('ID: ${log.questId}'),
              );
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: tokens.brandPrimary.withValues(alpha: 0.1),
                        borderRadius: tokens.cornerMedium(),
                      ),
                      child: Icon(
                        iconDataForKey(quest.iconKey),
                        color: tokens.brandPrimary,
                        size: 24,
                      ),
                    ),
                    SizedBox(width: tokens.spacing(3)),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            quest.title,
                            style: tokens.titleSmall.copyWith(
                              color: tokens.textPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: tokens.spacing(1)),
                          Text(
                            DateFormat('HH:mm').format(log.ts.toLocal()),
                            style: tokens.bodySmall.copyWith(
                              color: tokens.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _ProofTypeChip(proofType: log.proofType.name),
                  ],
                ),
                if (log.proofType == ProofType.photo && (log.proofValue?.isNotEmpty ?? false)) ...[
                  SizedBox(height: tokens.spacing(3)),
                  ClipRRect(
                    borderRadius: tokens.cornerMedium(),
                    child: Image.network(
                      log.proofValue,
                      height: 120,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        height: 120,
                        color: tokens.border.withValues(alpha: 0.3),
                        child: const Center(
                          child: Icon(Icons.broken_image_outlined),
                        ),
                      ),
                    ),
                  ),
                ],
                SizedBox(height: tokens.spacing(3)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      onPressed: logController.isLoading
                          ? null
                          : () => _showUndoConfirmation(context, ref),
                      icon: logController.isLoading
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.undo),
                      label: const Text('取り消し'),
                      style: TextButton.styleFrom(
                        foregroundColor: tokens.accentError,
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _showUndoConfirmation(BuildContext context, WidgetRef ref) {
    final tokens = context.tokens;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('記録を取り消し'),
        content: const Text('こ�E記録を取り消しますか�E�この操作�E允E��戻せません、E),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              final controller = ref.read(questLogControllerProvider.notifier);
              final success = await controller.undoLog(log.id);
              
              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('記録を取り消しました'),
                    backgroundColor: tokens.accentSuccess,
                  ),
                );
              } else {
                final error = ref.read(questLogControllerProvider).error;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(error?.toString() ?? '取り消しに失敗しました'),
                    backgroundColor: tokens.accentError,
                  ),
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: tokens.accentError),
            child: const Text('取り消し'),
          ),
        ],
      ),
    );
  }
}

class _ProofTypeChip extends StatelessWidget {
  const _ProofTypeChip({required this.proofType});

  final String proofType;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    
    final (icon, label, color) = switch (proofType) {
      'photo' => (Icons.camera_alt, '写真', tokens.brandPrimary),
      'check' => (Icons.check_circle, 'セルチE, tokens.accentSuccess),
      _ => (Icons.help_outline, '不�E', tokens.textMuted),
    };

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: tokens.spacing(2),
        vertical: tokens.spacing(1),
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: tokens.cornerSmall(),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          SizedBox(width: tokens.spacing(1)),
          Text(
            label,
            style: tokens.bodySmall.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}