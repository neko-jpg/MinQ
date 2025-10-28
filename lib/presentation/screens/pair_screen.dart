import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:minq/data/providers.dart';
import 'package:minq/domain/pair/pair.dart';
import 'package:minq/l10n/app_localizations.dart';
import 'package:minq/presentation/common/feedback/feedback_messenger.dart';
import 'package:minq/presentation/common/minq_buttons.dart';
import 'package:minq/presentation/routing/app_router.dart';
import 'package:minq/presentation/theme/minq_theme.dart';

final userPairProvider = StreamProvider<Pair?>((ref) {
  final uid = ref.watch(uidProvider);
  if (uid == null) return Stream.value(null);
  // TODO: Handle null repository gracefully
  return ref.watch(pairRepositoryProvider)!.getPairStreamForUser(uid);
});

class PairScreen extends ConsumerWidget {
  const PairScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.tokens;
    final l10n = AppLocalizations.of(context)!;
    final pairAsync = ref.watch(userPairProvider);

    return Scaffold(
      backgroundColor: tokens.background,
      appBar: AppBar(
        title: Text(
          l10n.pairTitle,
          style: tokens.typography.h4.copyWith(
            color: tokens.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        leading: MinqIconButton(icon: Icons.close, onTap: () => context.pop()),
        backgroundColor: tokens.background.withAlpha((255 * 0.8).round()),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: pairAsync.when(
        data: (pair) => AnimatedSwitcher(
          duration: const Duration(milliseconds: 500),
          transitionBuilder: (child, animation) =>
              FadeTransition(opacity: animation, child: child),
          child: pair != null
              ? _PairedView(key: ValueKey(pair.id), pairId: pair.id)
              : const _UnpairedView(key: ValueKey('unpaired')),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text(l10n.errorGeneric)),
      ),
    );
  }
}

class _PairedView extends ConsumerWidget {
  const _PairedView({super.key, required this.pairId});

  final String pairId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.tokens;
    final l10n = AppLocalizations.of(context)!;
    // TODO: Handle null repository gracefully
    final pairStream = ref.watch(pairRepositoryProvider)!.getPairStream(pairId);

    return StreamBuilder<DocumentSnapshot>(
      stream: pairStream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final pair = Pair.fromSnapshot(snapshot.data!);

        final canHighFive = pair.lastHighfiveAt == null ||
            DateTime.now().difference(pair.lastHighfiveAt!).inHours >= 24;
        final quickMessages = <String>[
          l10n.pairQuickMessageGreat,
          l10n.pairQuickMessageKeepGoing,
          l10n.pairQuickMessageFinishStrong,
          l10n.pairQuickMessageCompletedGoal,
        ];

        return SingleChildScrollView(
          padding: EdgeInsets.all(tokens.spacing.lg),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              SizedBox(height: tokens.spacing.lg),
              CircleAvatar(
                radius: 64,
                backgroundColor: tokens.brandPrimary.withAlpha((255 * 0.12).round()),
                child: Icon(
                  Icons.person_off_outlined,
                  size: 64,
                  color: tokens.brandPrimary,
                ),
              ),
              SizedBox(height: tokens.spacing.lg),
              Text(
                l10n.pairAnonymousPartner,
                style: tokens.typography.h4.copyWith(color: tokens.textPrimary),
              ),
              SizedBox(height: tokens.spacing.xs),
              Text(
                l10n.pairPairedQuest(pair.category),
                style:
                    tokens.typography.bodySmall.copyWith(color: tokens.textMuted),
              ),
              const SizedBox(height: 32),
              MinqPrimaryButton(
                label: canHighFive
                    ? l10n.pairHighFiveAction
                    : l10n.pairHighFiveSent,
                onPressed: canHighFive
                    ? () async {
                        final uid = ref.read(uidProvider);
                        if (uid == null) return;
                        // TODO: Handle null repository gracefully
                        await ref
                            .read(pairRepositoryProvider)!
                            .sendHighFive(pairId, uid);
                      }
                    : null,
              ),
              const SizedBox(height: 40),
              Text(
                l10n.pairQuickMessagePrompt,
                style:
                    tokens.typography.bodySmall.copyWith(color: tokens.textMuted),
              ),
              SizedBox(height: tokens.spacing.lg),
              Wrap(
                spacing: tokens.spacing.md,
                runSpacing: tokens.spacing.md,
                alignment: WrapAlignment.center,
                children: quickMessages
                    .map(
                      (message) => _QuickMessageChip(
                        text: message,
                        onTap: () => _sendQuickMessage(ref, pairId, message),
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
        );
      },
    );
  }

  void _sendQuickMessage(WidgetRef ref, String pairId, String message) async {
    final uid = ref.read(uidProvider);
    if (uid == null) return;
    // TODO: Handle null repository gracefully
    await ref
        .read(pairRepositoryProvider)!
        .sendQuickMessage(pairId, uid, message);
  }
}

class _QuickMessageChip extends StatelessWidget {
  const _QuickMessageChip({required this.text, required this.onTap});

  final String text;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return ActionChip(
      label: Text(
        text,
        style: tokens.typography.bodySmall.copyWith(
          color: tokens.brandPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),
      onPressed: onTap,
      backgroundColor: tokens.surface,
      side: BorderSide(color: tokens.brandPrimary.withAlpha((255 * 0.4).round())),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(tokens.radius.lg),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: tokens.spacing.md,
        vertical: tokens.spacing.sm,
      ),
    );
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
    final l10n = AppLocalizations.of(context)!;
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
          MinqPrimaryButton(
            label: 'マッチングを開始する',
            onPressed: () async =>
                ref.read(navigationUseCaseProvider).goToPairMatching(),
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
          value: currentValue,
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

class _DropdownOption {
  const _DropdownOption({required this.value, required this.label});

  final String value;
  final String label;
}
