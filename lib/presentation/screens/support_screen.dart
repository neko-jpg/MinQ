import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:minq/presentation/theme/minq_theme.dart';

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Scaffold(
      backgroundColor: tokens.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        title: Text(
          'Support & FAQ',
          style: tokens.titleMedium.copyWith(color: tokens.textPrimary),
        ),
      ),
      body: ListView(
        padding: EdgeInsets.all(tokens.spacing(5)),
        children: <Widget>[
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
                    'Contact Us',
                    style: tokens.titleSmall.copyWith(color: tokens.textPrimary),
                  ),
                  SizedBox(height: tokens.spacing(3)),
                  _SupportActionTile(
                    icon: Icons.mail_outline,
                    title: 'Email',
                    subtitle: 'support@minq.app',
                    onCopy: () => _copyToClipboard(context, 'support@minq.app'),
                  ),
                  Divider(height: tokens.spacing(6)),
                  _SupportActionTile(
                    icon: Icons.forum_outlined,
                    title: 'Feedback Form',
                    subtitle: 'https://minq.app/feedback',
                    onCopy: () =>
                        _copyToClipboard(context, 'https://minq.app/feedback'),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: tokens.spacing(5)),
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
                    'Quick Answers',
                    style: tokens.titleSmall.copyWith(color: tokens.textPrimary),
                  ),
                  SizedBox(height: tokens.spacing(3)),
                  const _FaqItem(
                    questionJa: '通知が届かないときは？',
                    questionEn: 'Notifications are missing?',
                    answerJa:
                        '端末の通知許可とアプリ内の通知時間を確認してください。端末再起動や再ログインで改善する場合があります。',
                    answerEn:
                        'Please review device notification permissions and the in-app notification schedule. Restarting the device or re-signing in can help restore delivery.',
                  ),
                  const _FaqItem(
                    questionJa: 'ペアを変更したい',
                    questionEn: 'I want to change my pair',
                    answerJa:
                        'Pair画面のメニューから「再マッチ」を選択すると、現在のペアに通知した上で新しい候補を探します。',
                    answerEn:
                        'Use the “Re-match” option from the Pair screen menu. Your current partner will be notified while we look for a new match.',
                  ),
                  const _FaqItem(
                    questionJa: 'データのエクスポート方法',
                    questionEn: 'How can I export my data?',
                    answerJa:
                        '設定 > プライバシー > データをエクスポート から申請すると、登録メールへ安全なダウンロードリンクを送信します。',
                    answerEn:
                        'Open Settings → Privacy → Export My Data to request an export. A secure download link will be emailed to you.',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _copyToClipboard(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Copied "$text"'),
      ),
    );
  }
}

class _SupportActionTile extends StatelessWidget {
  const _SupportActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onCopy,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onCopy;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Icon(icon, color: tokens.brandPrimary),
        SizedBox(width: tokens.spacing(3)),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                title,
                style: tokens.bodyMedium.copyWith(color: tokens.textPrimary),
              ),
              SizedBox(height: tokens.spacing(1)),
              SelectableText(
                subtitle,
                style: tokens.bodySmall.copyWith(color: tokens.textMuted),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: onCopy,
          icon: Icon(Icons.copy, color: tokens.textMuted),
          tooltip: 'Copy',
        ),
      ],
    );
  }
}

class _FaqItem extends StatelessWidget {
  const _FaqItem({
    required this.questionJa,
    required this.questionEn,
    required this.answerJa,
    required this.answerEn,
  });

  final String questionJa;
  final String questionEn;
  final String answerJa;
  final String answerEn;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Padding(
      padding: EdgeInsets.only(bottom: tokens.spacing(3)),
      child: ExpansionTile(
        tilePadding: EdgeInsets.zero,
        childrenPadding: EdgeInsets.only(bottom: tokens.spacing(2)),
        title: Text(
          questionJa,
          style: tokens.bodyMedium.copyWith(color: tokens.textPrimary),
        ),
        subtitle: Text(
          questionEn,
          style: tokens.labelSmall.copyWith(color: tokens.textMuted),
        ),
        shape: RoundedRectangleBorder(borderRadius: tokens.cornerMedium()),
        collapsedShape:
            RoundedRectangleBorder(borderRadius: tokens.cornerMedium()),
        children: <Widget>[
          Text(
            answerJa,
            style: tokens.bodySmall.copyWith(color: tokens.textPrimary),
          ),
          SizedBox(height: tokens.spacing(2)),
          Text(
            answerEn,
            style: tokens.bodySmall.copyWith(color: tokens.textMuted),
          ),
        ],
      ),
    );
  }
}
