import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:minq/data/providers.dart';
import 'package:minq/domain/pair/pair.dart';
import 'package:minq/presentation/common/feedback/feedback_manager.dart';
import 'package:minq/presentation/common/feedback/feedback_messenger.dart';
import 'package:minq/presentation/routing/app_router.dart';
import 'package:minq/presentation/screens/pair_screen.dart'
    show userPairProvider;
import 'package:minq/presentation/theme/minq_theme.dart';

class BuddyListScreen extends ConsumerWidget {
  const BuddyListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = MinqTheme.of(context);
    final pairAsync = ref.watch(userPairProvider);

    return Scaffold(
      backgroundColor: tokens.background,
      appBar: AppBar(
        title: Text(
          '迴ｾ蝨ｨ縺ｮ繝舌ョ繧｣',
          style: tokens.titleMedium.copyWith(
            color: tokens.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: tokens.background,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: pairAsync.when(
        data: (pair) {
          if (pair == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.people_outline, size: 64, color: tokens.textMuted),
                  const SizedBox(height: 16),
                  const Text('縺ｾ縺繝舌ョ繧｣縺後＞縺ｾ縺帙ｓ'),
                ],
              ),
            );
          }
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: _BuddyCard(pair: pair),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('繧ｨ繝ｩ繝ｼ縺檎匱逕溘＠縺ｾ縺励◆: $err')),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton.icon(
          icon: const Icon(Icons.search),
          label: const Text('譁ｰ縺励＞繝舌ョ繧｣繧呈爾縺・),
          onPressed:
              () => ref.read(navigationUseCaseProvider).goToPairMatching(),
          style: ElevatedButton.styleFrom(
            backgroundColor: tokens.brandPrimary,
            foregroundColor: tokens.surface,
            minimumSize: Size.fromHeight(tokens.spacing(14)),
            shape: RoundedRectangleBorder(borderRadius: tokens.cornerXLarge()),
            textStyle: tokens.titleSmall,
          ),
        ),
      ),
    );
  }
}

class _BuddyCard extends ConsumerWidget {
  const _BuddyCard({required this.pair});

  final Pair pair;

  void _showOptionsMenu(
    BuildContext context,
    WidgetRef ref,
    String otherMemberId,
  ) {
    final repo = ref.read(pairRepositoryProvider);
    final currentUserId = ref.read(uidProvider);
    final l10n = AppLocalizations.of(context)!;

    showModalBottomSheet(
      context: context,
      builder: (ctx) => Wrap(
        children: <Widget>[
          ListTile(
            leading: const Icon(Icons.report, color: Colors.redAccent),
            title: Text(
              l10n.reportUser,
              style: const TextStyle(color: Colors.redAccent),
            ),
            onTap: () {
              Navigator.of(ctx).pop();
              _showReportDialog(context, ref, otherMemberId);
            },
          ),
          ListTile(
            leading: const Icon(Icons.block, color: Colors.red),
            title: const Text(
              '繝舌ョ繧｣繧偵ヶ繝ｭ繝・け',
              style: TextStyle(color: Colors.red),
            ),
            onTap: () {
              Navigator.of(ctx).pop();
              showDialog(
                context: context,
                builder: (dialogCtx) => AlertDialog(
                  title: const Text('繝舌ョ繧｣繧偵ヶ繝ｭ繝・け'),
                  content: const Text(
                    '繝悶Ο繝・け縺吶ｋ縺ｨ縲∽ｻ雁ｾ後％縺ｮ繝ｦ繝ｼ繧ｶ繝ｼ縺ｨ繝槭ャ繝√Φ繧ｰ縺励↑縺上↑繧翫∪縺吶よ悽蠖薙↓繧医ｍ縺励＞縺ｧ縺吶°・・,
                  ),
                  actions: <Widget>[
                    TextButton(
                      child: const Text('繧ｭ繝｣繝ｳ繧ｻ繝ｫ'),
                      onPressed: () => Navigator.of(dialogCtx).pop(),
                    ),
                    TextButton(
                      child: const Text(
                        '繝悶Ο繝・け',
                        style: TextStyle(color: Colors.red),
                      ),
                      onPressed: () async {
                        if (repo != null && currentUserId != null) {
                          await repo.blockUser(currentUserId, otherMemberId);
                          FeedbackMessenger.showSuccessToast(
                            context,
                            '繝舌ョ繧｣繧偵ヶ繝ｭ繝・け縺励∪縺励◆縲・,
                          );
                        }
                        if (context.mounted) {
                          Navigator.of(dialogCtx).pop();
                        }
                      },
                    ),
                  ],
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('繝壹い繧定ｧ｣豸・, style: TextStyle(color: Colors.red)),
            onTap: () {
              Navigator.of(ctx).pop();
              showDialog(
                context: context,
                builder: (dialogCtx) => AlertDialog(
                  title: const Text('繝壹い繧定ｧ｣豸・),
                  content: const Text(
                    '譛ｬ蠖薙↓縺薙・繝舌ョ繧｣縺ｨ縺ｮ繝壹い繧定ｧ｣豸医＠縺ｾ縺吶°・溘％縺ｮ謫堺ｽ懊・蜿悶ｊ豸医○縺ｾ縺帙ｓ縲・,
                  ),
                  actions: <Widget>[
                    TextButton(
                      child: const Text('繧ｭ繝｣繝ｳ繧ｻ繝ｫ'),
                      onPressed: () => Navigator.of(dialogCtx).pop(),
                    ),
                    TextButton(
                      child: const Text(
                        '隗｣豸医☆繧・,
                        style: TextStyle(color: Colors.red),
                      ),
                      onPressed: () async {
                        if (repo != null && currentUserId != null) {
                          await repo.leavePair(pair.id, currentUserId);
                          FeedbackMessenger.showSuccessToast(
                            context,
                            '繝壹い繧定ｧ｣豸医＠縺ｾ縺励◆縲・,
                          );
                        }
                        if (context.mounted) {
                          Navigator.of(dialogCtx).pop();
                        }
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = MinqTheme.of(context);
    final currentUserId = ref.watch(uidProvider);
    final otherMemberId = pair.members.firstWhere(
      (id) => id != currentUserId,
      orElse: () => '...',
    );

    return Card(
      elevation: 0,
      color: tokens.surface,
      shape: RoundedRectangleBorder(borderRadius: tokens.cornerXLarge()),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: tokens.background,
                  child: Icon(Icons.person, size: 28, color: tokens.textMuted),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Buddy#${otherMemberId.substring(0, 4)}',
                        style: tokens.titleSmall.copyWith(
                          color: tokens.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '逶ｮ讓呻ｼ・{pair.category}',
                        style: tokens.bodySmall.copyWith(
                          color: tokens.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.more_vert, color: tokens.textMuted),
                  onPressed:
                      () => _showOptionsMenu(context, ref, otherMemberId),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Divider(color: tokens.border, height: 1),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _ActionItem(
                  icon: Icons.volunteer_activism_outlined,
                  label: '諡肴焔',
                  color: Colors.green.shade400,
                  onTap: () {
                    final repo = ref.read(pairRepositoryProvider);
                    if (currentUserId != null && repo != null) {
                      repo.sendHighFive(pair.id, currentUserId);
                      FeedbackMessenger.showSuccessToast(
                        context,
                        '聡 諡肴焔繧帝√ｊ縺ｾ縺励◆・・,
                      );
                      FeedbackManager.selected();
                    }
                  },
                ),
                _ActionItem(
                  icon: Icons.chat_bubble_outline,
                  label: '繝√Ε繝・ヨ',
                  color: Colors.blue.shade400,
                  onTap:
                      () => ref
                          .read(navigationUseCaseProvider)
                          .goToPairChat(pair.id),
                ),
                _ActionItem(
                  icon: Icons.check_circle_outline,
                  label: '繝√ぉ繝・け繧､繝ｳ',
                  color: Colors.orange.shade400,
                  onTap: () {
                    final repo = ref.read(pairRepositoryProvider);
                    if (currentUserId != null && repo != null) {
                      repo.sendCheckIn(pair.id, currentUserId);
                      FeedbackMessenger.showSuccessToast(
                        context,
                        '笨・莉頑律縺ｮ驕疲・繧貞ｱ蜻翫＠縺ｾ縺励◆・・,
                      );
                      FeedbackManager.questCompleted();
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionItem extends StatelessWidget {
  const _ActionItem({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = MinqTheme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: tokens.cornerLarge(),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: tokens.bodySmall.copyWith(
                color: tokens.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> _showReportDialog(
  BuildContext context,
  WidgetRef ref,
  String buddyId,
) async {
  final l10n = AppLocalizations.of(context)!;
  final reasonController = TextEditingController();
  final currentUserId = ref.read(uidProvider);

  if (currentUserId == null) {
    FeedbackMessenger.showErrorSnackBar(
      context,
      l10n.notSignedIn,
    );
    return;
  }

  final shouldReport = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(l10n.reportUser),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(l10n.reportConfirmation),
          const SizedBox(height: 12),
          TextField(
            controller: reasonController,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: '蜀・ｮｹ繧定ｨ伜・縺励※縺上□縺輔＞',
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: () => Navigator.of(dialogContext).pop(true),
          child: Text(l10n.report),
        ),
      ],
    ),
  );

  if (shouldReport != true) {
    reasonController.dispose();
    return;
  }

  final repo = ref.read(pairRepositoryProvider);
  if (repo == null) {
    FeedbackMessenger.showErrorSnackBar(
      context,
      l10n.errorGeneric,
    );
    reasonController.dispose();
    return;
  }

  await repo.reportUser(currentUserId, buddyId, reasonController.text);
  FeedbackMessenger.showSuccessToast(
    context,
    l10n.reportSubmitted,
  );
  reasonController.dispose();
}
