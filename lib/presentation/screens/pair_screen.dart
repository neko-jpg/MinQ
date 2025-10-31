import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:minq/core/social/pair_system.dart';
import 'package:minq/data/providers.dart';
import 'package:minq/domain/pair/pair.dart';
import 'package:minq/domain/pair/pair_connection.dart';
import 'package:minq/l10n/app_localizations.dart';
import 'package:minq/presentation/common/feedback/feedback_messenger.dart';
import 'package:minq/presentation/common/minq_buttons.dart';
import 'package:minq/presentation/theme/minq_theme.dart';
import 'package:minq/presentation/widgets/polished_buttons.dart';

final userPairProvider = StreamProvider<Pair?>((ref) {
  final uid = ref.watch(uidProvider);
  if (uid == null) return Stream.value(null);
  // TODO: Handle null repository gracefully
  return ref.watch(pairRepositoryProvider)!.getPairStreamForUser(uid);
});

final userPairConnectionProvider = FutureProvider<PairConnection?>((ref) async {
  final uid = ref.watch(uidProvider);
  if (uid == null) return null;
  
  final pairSystem = ref.watch(pairSystemProvider);
  return await pairSystem.getActiveConnectionForUser(uid);
});

class PairScreen extends ConsumerWidget {
  const PairScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.tokens;
    final pairConnectionAsync = ref.watch(userPairConnectionProvider);

    return Scaffold(
      backgroundColor: tokens.background,
      appBar: AppBar(
        title: Text(
          'ペア機能',
          style: tokens.typography.h4.copyWith(
            color: tokens.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.close, color: tokens.textPrimary),
          onPressed: () => context.pop(),
        ),
        backgroundColor: tokens.surface,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.help_outline, color: tokens.textSecondary),
            onPressed: () => _showHelpDialog(context),
          ),
        ],
      ),
      body: pairConnectionAsync.when(
        data: (connection) => AnimatedSwitcher(
          duration: const Duration(milliseconds: 500),
          transitionBuilder: (child, animation) =>
              FadeTransition(opacity: animation, child: child),
          child: connection != null && connection.isActive
              ? _PairedView(key: ValueKey(connection.id), connection: connection)
              : const _UnpairedView(key: ValueKey('unpaired')),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: tokens.error),
              SizedBox(height: tokens.spacing.md),
              Text(
                'エラーが発生しました',
                style: tokens.typography.body.copyWith(
                  color: tokens.error,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ペア機能について'),
        content: const Text(
          'ペア機能では、友人と一緒に習慣化に取り組むことができます。\n\n'
          '• 招待リンクやQRコードで友人を招待\n'
          '• リアルタイムチャットで励まし合い\n'
          '• 進捗を共有して競い合い\n'
          '• 統計で成果を比較',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('閉じる'),
          ),
        ],
      ),
    );
  }
}

class _PairedView extends ConsumerWidget {
  const _PairedView({super.key, required this.connection});

  final PairConnection connection;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.tokens;
    final statistics = connection.statistics;

    return SingleChildScrollView(
      padding: EdgeInsets.all(tokens.spacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ペア情報カード
          Container(
            padding: EdgeInsets.all(tokens.spacing.lg),
            decoration: BoxDecoration(
              color: tokens.surface,
              borderRadius: BorderRadius.circular(tokens.radius.lg),
              border: Border.all(color: tokens.border),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 32,
                      backgroundColor: tokens.primary.withOpacity(0.2),
                      child: Icon(
                        Icons.person,
                        size: 32,
                        color: tokens.primary,
                      ),
                    ),
                    SizedBox(width: tokens.spacing.md),
                    Icon(
                      Icons.favorite,
                      color: tokens.error,
                      size: 24,
                    ),
                    SizedBox(width: tokens.spacing.md),
                    CircleAvatar(
                      radius: 32,
                      backgroundColor: tokens.secondary.withOpacity(0.2),
                      child: Icon(
                        Icons.person,
                        size: 32,
                        color: tokens.secondary,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: tokens.spacing.lg),
                Text(
                  'ペアパートナー',
                  style: tokens.typography.h3.copyWith(
                    color: tokens.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: tokens.spacing.sm),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: tokens.spacing.md,
                    vertical: tokens.spacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: tokens.success.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(tokens.radius.sm),
                  ),
                  child: Text(
                    '${_getCategoryName(connection.category)} • ${_getDurationText(connection.createdAt)}',
                    style: tokens.typography.bodySmall.copyWith(
                      color: tokens.success,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: tokens.spacing.lg),

          // 統計カード
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  tokens,
                  'メッセージ',
                  '${statistics.totalMessages}',
                  Icons.chat,
                  tokens.primary,
                ),
              ),
              SizedBox(width: tokens.spacing.md),
              Expanded(
                child: _buildStatCard(
                  tokens,
                  '進捗共有',
                  '${statistics.totalProgressShares}',
                  Icons.trending_up,
                  tokens.success,
                ),
              ),
            ],
          ),

          SizedBox(height: tokens.spacing.lg),

          // アクションボタン
          Row(
            children: [
              Expanded(
                child: PolishedPrimaryButton(
                  onPressed: () => context.push('/pair/${connection.id}/chat'),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.chat, color: tokens.onPrimary, size: 20),
                      SizedBox(width: tokens.spacing.xs),
                      const Text('チャット'),
                    ],
                  ),
                ),
              ),
              SizedBox(width: tokens.spacing.md),
              Expanded(
                child: PolishedSecondaryButton(
                  onPressed: () => context.push('/pair/${connection.id}/dashboard'),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.dashboard, size: 20),
                      SizedBox(width: tokens.spacing.xs),
                      const Text('ダッシュボード'),
                    ],
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: tokens.spacing.md),

          // 進捗共有ボタン
          PolishedSecondaryButton(
            onPressed: () => _shareProgress(context, ref),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.share, size: 20),
                SizedBox(width: tokens.spacing.xs),
                const Text('進捗を共有'),
              ],
            ),
          ),

          SizedBox(height: tokens.spacing.lg),

          // 設定・管理
          Container(
            padding: EdgeInsets.all(tokens.spacing.md),
            decoration: BoxDecoration(
              color: tokens.surface,
              borderRadius: BorderRadius.circular(tokens.radius.md),
              border: Border.all(color: tokens.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '設定・管理',
                  style: tokens.typography.bodyMedium.copyWith(
                    color: tokens.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: tokens.spacing.sm),
                ListTile(
                  leading: Icon(Icons.settings, color: tokens.textSecondary),
                  title: const Text('ペア設定'),
                  trailing: Icon(Icons.chevron_right, color: tokens.textSecondary),
                  onTap: () => _showPairSettings(context, ref),
                  contentPadding: EdgeInsets.zero,
                ),
                Divider(color: tokens.border),
                ListTile(
                  leading: Icon(Icons.exit_to_app, color: tokens.error),
                  title: Text(
                    'ペアを終了',
                    style: TextStyle(color: tokens.error),
                  ),
                  trailing: Icon(Icons.chevron_right, color: tokens.error),
                  onTap: () => _showEndPairDialog(context, ref),
                  contentPadding: EdgeInsets.zero,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    MinqTheme tokens,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: EdgeInsets.all(tokens.spacing.md),
      decoration: BoxDecoration(
        color: tokens.surface,
        borderRadius: BorderRadius.circular(tokens.radius.md),
        border: Border.all(color: tokens.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              SizedBox(width: tokens.spacing.xs),
              Expanded(
                child: Text(
                  title,
                  style: tokens.typography.bodySmall.copyWith(
                    color: tokens.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: tokens.spacing.xs),
          Text(
            value,
            style: tokens.typography.h3.copyWith(
              color: tokens.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  void _shareProgress(BuildContext context, WidgetRef ref) {
    // TODO: 進捗共有画面を表示
    FeedbackMessenger.showErrorSnackBar(context, '進捗共有機能は準備中です');
  }

  void _showPairSettings(BuildContext context, WidgetRef ref) {
    // TODO: ペア設定画面を表示
    FeedbackMessenger.showErrorSnackBar(context, 'ペア設定画面は準備中です');
  }

  void _showEndPairDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ペアを終了しますか？'),
        content: const Text('この操作は取り消せません。本当にペアを終了しますか？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final userId = ref.read(uidProvider);
              if (userId == null) return;

              try {
                // TODO: Implement pair system provider
                // final pairSystem = ref.read(pairSystemProvider);
                // await pairSystem.endConnection(
                //   pairId: connection.id,
                //   userId: userId,
                //   reason: 'ユーザーによる終了',
                // );
                
                if (context.mounted) {
                  FeedbackMessenger.showErrorSnackBar(
                    context,
                    'ペアを終了しました',
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  FeedbackMessenger.showErrorSnackBar(
                    context,
                    'ペアの終了に失敗しました: $e',
                  );
                }
              }
            },
            style: TextButton.styleFrom(
              foregroundColor: tokens.error,
            ),
            child: const Text('終了'),
          ),
        ],
      ),
    );
  }

  String _getCategoryName(String category) {
    switch (category) {
      case 'fitness':
        return 'フィットネス';
      case 'learning':
        return '学習';
      case 'wellbeing':
        return 'ウェルビーイング';
      case 'productivity':
        return '生産性';
      case 'creativity':
        return '創造性';
      default:
        return 'その他';
    }
  }

  String _getDurationText(DateTime createdAt) {
    final duration = DateTime.now().difference(createdAt);
    if (duration.inDays > 0) {
      return '${duration.inDays}日間';
    } else if (duration.inHours > 0) {
      return '${duration.inHours}時間';
    } else {
      return '開始したばかり';
    }
  }
}



class _UnpairedView extends ConsumerStatefulWidget {
  const _UnpairedView({super.key});

  @override
  ConsumerState<_UnpairedView> createState() => _UnpairedViewState();
}

class _UnpairedViewState extends ConsumerState<_UnpairedView> {
  final _inviteCodeController = TextEditingController();
  String _selectedAgeRange = '18-24';
  String _selectedCategory = 'Fitness';

  Future<void> _joinWithInvite() async {
    final code = _inviteCodeController.text.trim();
    if (code.isEmpty) {
      FeedbackMessenger.showErrorSnackBar(context, '招待コードを入力してください。');
      return;
    }
    final uid = ref.read(uidProvider);
    if (uid == null) return;

    // TODO: Handle null repository gracefully
    final pairId = await ref
        .read(pairRepositoryProvider)!
        .joinByInvitation(code, uid);
    if (mounted && pairId == null) {
      FeedbackMessenger.showErrorSnackBar(context, '招待コードが無効です。');
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final l10n = AppLocalizations.of(context);
    return SafeArea(
      top: false,
      bottom: true,
      minimum: EdgeInsets.only(bottom: tokens.spacing.xl),
      child: ListView(
        padding: EdgeInsets.fromLTRB(
          tokens.spacing.xl,
          tokens.spacing.xl,
          tokens.spacing.xl,
          tokens.spacing.lg,
        ),
        children: [
          _buildHeader(tokens, l10n),
          const SizedBox(height: 32),
          _buildInviteCodeInput(tokens, l10n),
          SizedBox(height: tokens.spacing.xl),
          _buildDivider(tokens, l10n),
          SizedBox(height: tokens.spacing.xl),
          _buildRandomMatchForm(tokens, l10n),
          const SizedBox(height: 32),
          Row(
            children: [
              Expanded(
                child: PolishedPrimaryButton(
                  onPressed: () => context.push('/pair/invitation'),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.person_add, color: tokens.onPrimary, size: 20),
                      SizedBox(width: tokens.spacing.xs),
                      const Text('招待を作成'),
                    ],
                  ),
                ),
              ),
              SizedBox(width: tokens.spacing.md),
              Expanded(
                child: PolishedSecondaryButton(
                  onPressed: () => _showJoinDialog(context, ref),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.qr_code_scanner, size: 20),
                      SizedBox(width: tokens.spacing.xs),
                      const Text('参加'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(MinqTheme tokens, AppLocalizations l10n) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.groups,
              size: 40,
              color: tokens.brandPrimary,
            ),
            SizedBox(width: tokens.spacing.sm),
            Icon(Icons.add, size: 24, color: tokens.textMuted),
            SizedBox(width: tokens.spacing.sm),
            Icon(
              Icons.help_outline,
              size: 40,
              color: tokens.brandPrimary,
            ),
          ],
        ),
        SizedBox(height: tokens.spacing.lg),
        Text(
          l10n.pairPartnerHeroTitle,
          style: tokens.typography.h2.copyWith(
            color: tokens.textPrimary,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: tokens.spacing.sm),
        Text(
          l10n.pairPartnerHeroDescription,
          style: tokens.typography.body.copyWith(color: tokens.textMuted),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildInviteCodeInput(MinqTheme tokens, AppLocalizations l10n) {
    return Container(
      padding: EdgeInsets.all(tokens.spacing.lg),
      decoration: BoxDecoration(
        color: tokens.surface,
        borderRadius: tokens.cornerXLarge(),
        border: Border.all(color: tokens.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.pairInviteTitle,
            style: tokens.typography.bodyMedium.copyWith(
              color: tokens.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: tokens.spacing.sm),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _inviteCodeController,
                  decoration: InputDecoration(
                    hintText: l10n.pairInviteHint,
                    filled: true,
                    fillColor: tokens.background,
                    border: OutlineInputBorder(
                      borderRadius: tokens.cornerLarge(),
                      borderSide: BorderSide(color: tokens.border),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: tokens.spacing.lg,
                    ),
                  ),
                ),
              ),
              SizedBox(width: tokens.spacing.md),
              ElevatedButton(
                onPressed: _joinWithInvite,
                style: ElevatedButton.styleFrom(
                  backgroundColor: tokens.brandPrimary.withAlpha((255 * 0.2).round()),
                  foregroundColor: tokens.brandPrimary,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: tokens.cornerLarge(),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
                child: Text(l10n.pairInviteApply),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDivider(MinqTheme tokens, AppLocalizations l10n) {
    return Row(
      children: [
        Expanded(child: Divider(color: tokens.border, thickness: 1)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: tokens.spacing.md),
          child: Text(
            l10n.pairDividerOr,
            style: tokens.typography.bodySmall.copyWith(
              color: tokens.textMuted,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(child: Divider(color: tokens.border, thickness: 1)),
      ],
    );
  }

  Widget _buildRandomMatchForm(MinqTheme tokens, AppLocalizations l10n) {
    final ageOptions = <_DropdownOption>[
      _DropdownOption(value: '18-24', label: l10n.pairAgeOption1824),
      _DropdownOption(value: '25-34', label: l10n.pairAgeOption2534),
      _DropdownOption(value: '35-44', label: l10n.pairAgeOption3544),
      _DropdownOption(value: '45+', label: l10n.pairAgeOption45Plus),
    ];
    final categoryOptions = <_DropdownOption>[
      _DropdownOption(value: 'Fitness', label: l10n.pairGoalFitness),
      _DropdownOption(value: 'Learning', label: l10n.pairGoalLearning),
      _DropdownOption(value: 'Well-being', label: l10n.pairGoalWellbeing),
      _DropdownOption(value: 'Productivity', label: l10n.pairGoalProductivity),
    ];
    return Container(
      padding: EdgeInsets.all(tokens.spacing.lg),
      decoration: BoxDecoration(
        color: tokens.surface,
        borderRadius: tokens.cornerXLarge(),
        border: Border.all(color: tokens.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.pairRandomMatchTitle,
            style: tokens.typography.bodyMedium.copyWith(
              color: tokens.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: tokens.spacing.lg),
          _buildDropdown(
            tokens,
            l10n.pairAgeRangeLabel,
            ageOptions,
            _selectedAgeRange,
            (val) => setState(() => _selectedAgeRange = val!),
          ),
          SizedBox(height: tokens.spacing.lg),
          _buildDropdown(
            tokens,
            l10n.pairGoalCategoryLabel,
            categoryOptions,
            _selectedCategory,
            (val) => setState(() => _selectedCategory = val!),
          ),
          SizedBox(height: tokens.spacing.lg),
          Text(
            l10n.pairRandomMatchNote,
            style: tokens.typography.bodySmall.copyWith(color: tokens.textMuted),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown(
    MinqTheme tokens,
    String label,
    List<_DropdownOption> items,
    String currentValue,
    ValueChanged<String?> onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: tokens.typography.bodySmall.copyWith(
            color: tokens.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: tokens.spacing.xs),
        DropdownButtonFormField<String>(
          initialValue: currentValue,
          items: items
              .map(
                (item) => DropdownMenuItem(
                  value: item.value,
                  child: Text(item.label),
                ),
              )
              .toList(),
          onChanged: onChanged,
          decoration: InputDecoration(
            filled: true,
            fillColor: tokens.background,
            border: OutlineInputBorder(
              borderRadius: tokens.cornerLarge(),
              borderSide: BorderSide(color: tokens.border),
            ),
          ),
        ),
      ],
    );
  }
}

  void _showJoinDialog(BuildContext context, WidgetRef ref) {
    final codeController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) {
        final tokens = context.tokens;
        return AlertDialog(
          title: const Text('ペアに参加'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('招待コードを入力してください'),
              SizedBox(height: tokens.spacing.md),
              TextField(
                controller: codeController,
                decoration: const InputDecoration(
                  hintText: '招待コード',
                  border: OutlineInputBorder(),
                ),
                textCapitalization: TextCapitalization.characters,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('キャンセル'),
            ),
            TextButton(
              onPressed: () async {
                final code = codeController.text.trim();
                if (code.isEmpty) return;

                Navigator.pop(context);
                await _joinWithCode(context, ref, code);
              },
              child: const Text('参加'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _joinWithCode(BuildContext context, WidgetRef ref, String code) async {
    final userId = ref.read(uidProvider);
    if (userId == null) return;

    try {
      // TODO: Implement pair system provider
      // final pairSystem = ref.read(pairSystemProvider);
      // final connection = await pairSystem.acceptInvitation(
      //   inviteCode: code,
      //   userId: userId,
      // );

      if (context.mounted) {
        FeedbackMessenger.showErrorSnackBar(
          context,
          'ペア機能は準備中です',
        );
      }
    } catch (e) {
      if (context.mounted) {
        FeedbackMessenger.showErrorSnackBar(
          context,
          'ペアへの参加に失敗しました: $e',
        );
      }
    }
  }
}

class _DropdownOption {
  const _DropdownOption({required this.value, required this.label});

  final String value;
  final String label;
}
