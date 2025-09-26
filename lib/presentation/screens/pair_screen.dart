import 'package:flutter/material.dart';
import 'package:minq/presentation/common/minq_empty_state.dart';
import 'package:minq/presentation/common/minq_buttons.dart';
import 'package:minq/presentation/theme/minq_theme.dart';
import 'package:minq/presentation/common/minq_skeleton.dart';
import 'package:minq/data/logging/minq_logger.dart';

enum _PairSafetyAction { report, block, unpair }

class PairScreen extends StatefulWidget {
  const PairScreen({super.key});

  @override
  State<PairScreen> createState() => _PairScreenState();
}

class _PairScreenState extends State<PairScreen> {
  bool _isPaired = false;
  bool _showHelpBanner = true;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    Future<void>.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    });
  }

  void _findPartner() {
    MinqLogger.info('pair_find_partner', metadata: const {'origin': 'pair_screen'});
    setState(() => _isPaired = true);
  }

  void _unpair() {
    MinqLogger.warn('pair_unpaired', metadata: const {'origin': 'pair_screen'});
    setState(() => _isPaired = false);
  }

  Future<void> _handleSafetyAction(_PairSafetyAction action) async {
    switch (action) {
      case _PairSafetyAction.report:
        _showPartnerSafetySheet(
          title: '通報',
          description: '不適切な行動やハラスメントを報告すると、専任チームが24時間以内に確認します。',
          confirmationLabel: '通報を送信',
          onConfirmed: () {
            MinqLogger.warn('pair_report_submitted', metadata: const {'category': 'safety'});
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('通報を受け付けました。対応が完了次第お知らせします。')),
            );
          },
        );
        return;
      case _PairSafetyAction.block:
        _showPartnerSafetySheet(
          title: 'ブロック',
          description: 'ブロックすると今後このユーザーからの通知やマッチングは停止されます。必要に応じて解除も可能です。',
          confirmationLabel: 'このユーザーをブロック',
          onConfirmed: () {
            MinqLogger.warn('pair_blocked', metadata: const {'category': 'safety'});
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('ユーザーをブロックしました。設定から管理できます。')),
            );
          },
        );
        return;
      case _PairSafetyAction.unpair:
        _showPartnerSafetySheet(
          title: 'Pairを解除',
          description: 'Pairを解除すると、進行中のハイタッチ履歴は保存され、次のマッチングが可能になります。',
          confirmationLabel: 'Pairを解除する',
          onConfirmed: _unpair,
        );
        return;
    }
  }

  void _showPartnerSafetySheet({
    required String title,
    required String description,
    required String confirmationLabel,
    required VoidCallback onConfirmed,
  }) {
    final tokens = context.tokens;
    showModalBottomSheet<void>(
      context: context,
      shape: RoundedRectangleBorder(borderRadius: tokens.cornerXLarge()),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            tokens.spacing(5),
            tokens.spacing(5),
            tokens.spacing(5),
            MediaQuery.of(context).padding.bottom + tokens.spacing(5),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      title,
                      style: tokens.titleMedium.copyWith(color: tokens.textPrimary),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: tokens.textMuted),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              SizedBox(height: tokens.spacing(3)),
              Text(
                description,
                style: tokens.bodySmall.copyWith(color: tokens.textSecondary),
              ),
              SizedBox(height: tokens.spacing(5)),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).pop();
                  onConfirmed();
                },
                icon: Icon(Icons.shield_outlined, color: tokens.surface),
                label: Text(
                  confirmationLabel,
                  style: tokens.bodyMedium.copyWith(
                    color: tokens.surface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: tokens.brandPrimary,
                  minimumSize: Size.fromHeight(tokens.spacing(14)),
                  shape: RoundedRectangleBorder(
                    borderRadius: tokens.cornerLarge(),
                  ),
                ),
              ),
              SizedBox(height: tokens.spacing(4)),
              Text(
                '緊急の場合はアプリ外の適切な機関にもご連絡ください。',
                style: tokens.labelSmall.copyWith(color: tokens.textMuted),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Scaffold(
      backgroundColor: tokens.background,
      appBar: AppBar(
        title: Text(
          'Pair',
          style: tokens.titleMedium.copyWith(color: tokens.textPrimary),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        actions: <Widget>[
          if (_isPaired)
            PopupMenuButton<_PairSafetyAction>(
              tooltip: 'Pair options',
              icon: Icon(Icons.more_horiz, color: tokens.textPrimary),
              onSelected: _handleSafetyAction,
              itemBuilder: (context) => <PopupMenuEntry<_PairSafetyAction>>[
                const PopupMenuItem<_PairSafetyAction>(
                  value: _PairSafetyAction.report,
                  child: ListTile(
                    leading: Icon(Icons.flag_outlined),
                    title: Text('通報する'),
                  ),
                ),
                const PopupMenuItem<_PairSafetyAction>(
                  value: _PairSafetyAction.block,
                  child: ListTile(
                    leading: Icon(Icons.block),
                    title: Text('ブロックする'),
                  ),
                ),
                const PopupMenuItem<_PairSafetyAction>(
                  value: _PairSafetyAction.unpair,
                  child: ListTile(
                    leading: Icon(Icons.link_off),
                    title: Text('Pairを解除'),
                  ),
                ),
              ],
            ),
        ],
      ),
      body: _isLoading
          ? _PairSkeleton(tokens: tokens)
          : Column(
              children: <Widget>[
                if (_showHelpBanner)
                  Card(
                    elevation: 0,
                    margin: EdgeInsets.all(tokens.spacing(5)),
                    color: tokens.brandPrimary.withValues(alpha: 0.1),
                    shape: RoundedRectangleBorder(
                        borderRadius: tokens.cornerLarge()),
                    child: ListTile(
                      leading:
                          Icon(Icons.info_outline, color: tokens.brandPrimary),
                      title: Text(
                        _isPaired
                            ? 'PairとHigh-fiveを送り合ったり、定型メッセージで励まし合おう！'
                            : '同じ目標を持つ仲間と匿名でPairを組んで、一緒に習慣を続けよう。',
                        style: tokens.bodySmall
                            .copyWith(color: tokens.textPrimary),
                      ),
                      subtitle: Text(
                        'メニューからいつでも通報・ブロック・解除ができます。',
                        style: tokens.labelSmall
                            .copyWith(color: tokens.textMuted),
                      ),
                      trailing: IconButton(
                        icon: Icon(Icons.close, color: tokens.textPrimary),
                        onPressed: () =>
                            setState(() => _showHelpBanner = false),
                      ),
                    ),
                  ),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 400),
                    child: _isPaired
                        ? const _PairedView(key: ValueKey('paired'))
                        : _UnpairedView(
                            key: const ValueKey('unpaired'),
                            onFindPartner: _findPartner,
                          ),
                  ),
                ),
              ],
            ),
    );
  }
}

class _PairSkeleton extends StatelessWidget {
  const _PairSkeleton({required this.tokens});

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
        SizedBox(height: tokens.spacing(5)),
        MinqSkeleton(
          height: tokens.spacing(28),
          borderRadius: tokens.cornerLarge(),
        ),
        SizedBox(height: tokens.spacing(4)),
        const MinqSkeletonList(itemCount: 3, itemHeight: 72),
      ],
    );
  }
}

class _UnpairedView extends StatelessWidget {
  const _UnpairedView({super.key, required this.onFindPartner});

  final VoidCallback onFindPartner;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return ListView(
      padding: EdgeInsets.all(tokens.spacing(5)),
      children: <Widget>[
        SizedBox(height: tokens.spacing(5)),
        MinqEmptyState(
          icon: Icons.groups_outlined,
          title: 'まだPairが見つかっていません',
          message: '匿名でマッチして、お互いにハイタッチしながら習慣を続けましょう。',
          actionLabel: 'Pairを探す',
          onAction: onFindPartner,
        ),
        SizedBox(height: tokens.spacing(6)),
        Card(
          elevation: 0,
          color: tokens.surface,
          shape: RoundedRectangleBorder(borderRadius: tokens.cornerLarge()),
          child: Padding(
            padding: EdgeInsets.all(tokens.spacing(4)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'マッチするとできること',
                  style: tokens.titleSmall.copyWith(color: tokens.textPrimary),
                ),
                SizedBox(height: tokens.spacing(3)),
                _BenefitsRow(
                  icon: Icons.bolt_outlined,
                  text: 'お互いの達成を即ハイタッチで祝える',
                ),
                SizedBox(height: tokens.spacing(2)),
                _BenefitsRow(
                  icon: Icons.chat_bubble_outline,
                  text: 'テンプレメッセージで気軽に声かけ',
                ),
                SizedBox(height: tokens.spacing(2)),
                _BenefitsRow(
                  icon: Icons.lock_outline,
                  text: '匿名プロファイルで気軽に始められる',
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _BenefitsRow extends StatelessWidget {
  const _BenefitsRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Row(
      children: <Widget>[
        Icon(icon, size: tokens.spacing(6), color: tokens.brandPrimary),
        SizedBox(width: tokens.spacing(3)),
        Expanded(
          child: Text(
            text,
            style: tokens.bodySmall.copyWith(color: tokens.textPrimary),
          ),
        ),
      ],
    );
  }
}

class _PairedView extends StatelessWidget {
  const _PairedView({super.key});

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return SingleChildScrollView(
      padding: EdgeInsets.all(tokens.spacing(5)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          SizedBox(height: tokens.spacing(5)),
          CircleAvatar(
            radius: tokens.spacing(16),
            backgroundColor: tokens.brandPrimary.withValues(alpha: 0.12),
            child: Icon(
              Icons.person_off_outlined,
              size: tokens.spacing(16),
              color: tokens.brandPrimary,
            ),
          ),
          SizedBox(height: tokens.spacing(4)),
          Text(
            'Anonymous Partner',
            style: tokens.titleMedium.copyWith(color: tokens.textPrimary),
          ),
          SizedBox(height: tokens.spacing(1)),
          Text(
            'Paired for "Meditate" Quest',
            style: tokens.bodySmall.copyWith(color: tokens.textMuted),
          ),
          SizedBox(height: tokens.spacing(8)),
          _HighFiveButton(
            onPressed: () async {},
          ),
          SizedBox(height: tokens.spacing(10)),
          Text(
            'Send a quick message:',
            style: tokens.bodySmall.copyWith(color: tokens.textMuted),
          ),
          SizedBox(height: tokens.spacing(4)),
          Wrap(
            spacing: tokens.spacing(3),
            runSpacing: tokens.spacing(3),
            alignment: WrapAlignment.center,
            children: const <Widget>[
              _QuickMessageChip(text: "You're doing great!"),
              _QuickMessageChip(text: 'Keep it up!'),
              _QuickMessageChip(text: "Let's finish strong."),
              _QuickMessageChip(text: 'I completed my goal!'),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuickMessageChip extends StatelessWidget {
  const _QuickMessageChip({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return ActionChip(
      label: Text(
        text,
        style: tokens.bodySmall.copyWith(
          color: tokens.brandPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),
      onPressed: () {},
      backgroundColor: tokens.surface,
      side: BorderSide(color: tokens.brandPrimary.withValues(alpha: 0.4)),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(tokens.radiusLarge),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: tokens.spacing(3),
        vertical: tokens.spacing(2),
      ),
    );
  }
}

class _HighFiveButton extends StatefulWidget {
  const _HighFiveButton({required this.onPressed});

  final AsyncCallback onPressed;

  @override
  State<_HighFiveButton> createState() => _HighFiveButtonState();
}

class _HighFiveButtonState extends State<_HighFiveButton>
    with AsyncActionState<_HighFiveButton> {
  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        shape: const CircleBorder(),
        padding: EdgeInsets.all(tokens.spacing(10)),
        minimumSize: Size.square(tokens.spacing(28)),
        backgroundColor: tokens.brandPrimary,
        foregroundColor: tokens.surface,
        elevation: 6,
        shadowColor: tokens.brandPrimary.withValues(alpha: 0.32),
      ),
      onPressed: isProcessing
          ? null
          : () => runGuarded(() async {
                await widget.onPressed();
              }),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        transitionBuilder: (Widget child, Animation<double> animation) {
          return FadeTransition(opacity: animation, child: child);
        },
        child: isProcessing
            ? SizedBox(
                key: const ValueKey<String>('progress'),
                height: tokens.spacing(7),
                width: tokens.spacing(7),
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(tokens.surface),
                ),
              )
            : Column(
                key: const ValueKey<String>('content'),
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(Icons.back_hand_outlined, size: tokens.spacing(15)),
                  SizedBox(height: tokens.spacing(2)),
                  Text(
                    'High-five',
                    style: tokens.bodyMedium.copyWith(
                      color: tokens.surface,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
