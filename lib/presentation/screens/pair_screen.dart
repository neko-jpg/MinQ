import 'package:flutter/material.dart';
import 'package:minq/presentation/common/minq_empty_state.dart';
import 'package:minq/presentation/common/minq_buttons.dart';
import 'package:minq/presentation/theme/minq_theme.dart';

class PairScreen extends StatefulWidget {
  const PairScreen({super.key});

  @override
  State<PairScreen> createState() => _PairScreenState();
}

class _PairScreenState extends State<PairScreen> {
  bool _isPaired = false;
  bool _showHelpBanner = true;

  void _findPartner() {
    setState(() => _isPaired = true);
  }

  void _unpair() {
    setState(() => _isPaired = false);
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
            IconButton(
              icon: Icon(Icons.more_horiz, color: tokens.textPrimary),
              onPressed: _unpair,
            ),
        ],
      ),
      body: Column(
        children: <Widget>[
          if (_showHelpBanner)
            Card(
              elevation: 0,
              margin: EdgeInsets.all(tokens.spacing(5)),
              color: tokens.brandPrimary.withValues(alpha: 0.1),
              shape: RoundedRectangleBorder(
                  borderRadius: tokens.cornerLarge()),
              child: ListTile(
                leading: Icon(Icons.info_outline, color: tokens.brandPrimary),
                title: Text(
                  _isPaired
                      ? 'PairとHigh-fiveを送り合ったり、定型メッセージで励まし合おう！'
                      : '同じ目標を持つ仲間と匿名でPairを組んで、一緒に習慣を続けよう。',
                  style: tokens.bodySmall
                      .copyWith(color: tokens.textPrimary),
                ),
                trailing: IconButton(
                  icon: Icon(Icons.close, color: tokens.textPrimary),
                  onPressed: () => setState(() => _showHelpBanner = false),
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
