import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:minq/data/providers.dart';
import 'package:minq/presentation/common/feedback/feedback_messenger.dart';
import 'package:minq/presentation/theme/minq_theme.dart';

class SupportScreen extends ConsumerStatefulWidget {
  const SupportScreen({super.key});

  @override
  ConsumerState<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends ConsumerState<SupportScreen> {
  late final TextEditingController _commentController;
  int _npsScore = 8;
  bool _submitted = false;
  DateTime? _recordedAt;

  @override
  void initState() {
    super.initState();
    _commentController = TextEditingController();
    Future<void>.microtask(() async {
      final prefs = ref.read(localPreferencesServiceProvider);
      final response = await prefs.loadNpsResponse();
      if (!mounted || response == null) {
        return;
      }
      setState(() {
        _npsScore = response.score;
        _commentController.text = response.comment ?? '';
        _submitted = true;
        _recordedAt = response.recordedAt.toLocal();
      });
    });
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Scaffold(
      backgroundColor: tokens.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        title: Text(
          'サポートとFAQ',
          style: tokens.titleMedium.copyWith(color: tokens.textPrimary),
        ),
      ),
      body: ListView(
        padding: EdgeInsets.all(tokens.spacing(5)),
        children: <Widget>[
          _buildNpsCard(tokens),
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
          SizedBox(height: tokens.spacing(5)),
          _BatteryOptimizationCard(tokens: tokens),
        ],
      ),
    );
  }

  void _copyToClipboard(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
    FeedbackMessenger.showSuccessToast(
      context,
      'コピーしました: $text',
    );
  }

  Widget _buildNpsCard(MinqTheme tokens) {
    return Card(
      elevation: 0,
      color: tokens.surface,
      shape: RoundedRectangleBorder(borderRadius: tokens.cornerLarge()),
      child: Padding(
        padding: EdgeInsets.all(tokens.spacing(4)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'MinQの使い心地を教えてください',
              style: tokens.titleSmall.copyWith(color: tokens.textPrimary),
            ),
            SizedBox(height: tokens.spacing(2)),
            Text(
              '0 = おすすめしたくない / 10 = とてもおすすめしたい',
              style: tokens.bodySmall.copyWith(color: tokens.textMuted),
            ),
            SizedBox(height: tokens.spacing(4)),
            Slider(
              value: _npsScore.toDouble(),
              min: 0,
              max: 10,
              divisions: 10,
              activeColor: tokens.brandPrimary,
              label: _npsScore.toString(),
              onChanged: (double value) {
                setState(() => _npsScore = value.round());
              },
            ),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                'スコア: $_npsScore',
                style: tokens.bodySmall.copyWith(color: tokens.textMuted),
              ),
            ),
            SizedBox(height: tokens.spacing(4)),
            TextField(
              controller: _commentController,
              minLines: 2,
              maxLines: 4,
              decoration: InputDecoration(
                labelText: 'コメント (任意)',
                hintText: 'ペア機能や通知タイミングで改善して欲しい点を教えてください',
                border: OutlineInputBorder(borderRadius: tokens.cornerMedium()),
              ),
            ),
            SizedBox(height: tokens.spacing(4)),
            if (_submitted && _recordedAt != null)
              Padding(
                padding: EdgeInsets.only(bottom: tokens.spacing(2)),
                child: Text(
                  'ありがとうございます！ ${_recordedAt!.year}/${_recordedAt!.month}/${_recordedAt!.day} に保存しました。',
                  style: tokens.bodySmall.copyWith(color: tokens.accentSuccess),
                ),
              ),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton(
                onPressed: () => _submitNps(tokens),
                child: Text(_submitted ? 'フィードバックを更新する' : 'フィードバックを送信する'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitNps(MinqTheme tokens) async {
    final prefs = ref.read(localPreferencesServiceProvider);
    await prefs.saveNpsResponse(
      score: _npsScore,
      comment: _commentController.text,
    );
    final response = await prefs.loadNpsResponse();
    setState(() {
      _submitted = true;
      _recordedAt = response?.recordedAt.toLocal();
    });
    if (!mounted) {
      return;
    }
    FeedbackMessenger.showSuccessToast(
      context,
      'ご協力ありがとうございます！',
    );
  }
}

class _BatteryOptimizationCard extends StatelessWidget {
  const _BatteryOptimizationCard({required this.tokens});

  final MinqTheme tokens;

  @override
  Widget build(BuildContext context) {
    const instructions = <String>[
      'Android: 設定 > アプリと通知 > 特別なアプリアクセス > 電池の最適化 で MinQ を「最適化しない」に設定してください。',
      'iOS: 設定 > 一般 > Appのバックグラウンド更新 から MinQ をオンにして通知を維持してください。',
      'どの端末でも、省電力モードが有効な場合は通知が遅れることがあります。学習時間に合わせて解除することをおすすめします。',
    ];

    return Card(
      elevation: 0,
      color: tokens.surface,
      shape: RoundedRectangleBorder(borderRadius: tokens.cornerLarge()),
      child: Padding(
        padding: EdgeInsets.all(tokens.spacing(4)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              '通知が届かない場合のチェックリスト',
              style: tokens.titleSmall.copyWith(color: tokens.textPrimary),
            ),
            SizedBox(height: tokens.spacing(3)),
            ...instructions.map(
              (instruction) => Padding(
                padding: EdgeInsets.only(bottom: tokens.spacing(2)),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('• ', style: tokens.bodyMedium.copyWith(color: tokens.brandPrimary)),
                    Expanded(
                      child: Text(
                        instruction,
                        style: tokens.bodyMedium.copyWith(color: tokens.textPrimary),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
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
