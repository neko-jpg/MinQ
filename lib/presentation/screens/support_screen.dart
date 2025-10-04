import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:minq/data/providers.dart';
import 'package:minq/domain/support/support_message.dart';
import 'package:minq/presentation/common/feedback/feedback_messenger.dart';
import 'package:minq/presentation/theme/minq_theme.dart';

class SupportScreen extends ConsumerStatefulWidget {
  const SupportScreen({super.key});

  @override
  ConsumerState<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends ConsumerState<SupportScreen> {
  late final TextEditingController _commentController;
  late final TextEditingController _chatController;
  int _npsScore = 8;
  bool _submitted = false;
  DateTime? _recordedAt;
  final List<SupportMessage> _messages = <SupportMessage>[];
  final bool _chatSending = false;
  late final String _conversationId;

  @override
  void initState() {
    super.initState();
    _commentController = TextEditingController();
    _chatController = TextEditingController();
    _conversationId = DateTime.now().millisecondsSinceEpoch.toString();
    _messages.add(
      const SupportMessage(
        role: 'assistant',
        content: '縺薙ｓ縺ｫ縺｡縺ｯ・｀inQ繧ｵ繝昴・繝医〒縺吶ゅ＃雉ｪ蝠上ｄ荳榊・蜷医′縺ゅｌ縺ｰ豌苓ｻｽ縺ｫ繝｡繝・そ繝ｼ繧ｸ繧帝√▲縺ｦ縺上□縺輔＞縲・,
      ),
    );
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
    _chatController.dispose();
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
          '繧ｵ繝昴・繝医→FAQ',
          style: tokens.titleMedium.copyWith(color: tokens.textPrimary),
        ),
      ),
      body: ListView(
        padding: EdgeInsets.all(tokens.spacing(5)),
        children: <Widget>[
          _buildSupportBotCard(tokens),
          SizedBox(height: tokens.spacing(5)),
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
                    questionJa: '騾夂衍縺悟ｱ翫°縺ｪ縺・→縺阪・・・,
                    questionEn: 'Notifications are missing?',
                    answerJa:
                        '遶ｯ譛ｫ縺ｮ騾夂衍險ｱ蜿ｯ縺ｨ繧｢繝励Μ蜀・・騾夂衍譎る俣繧堤｢ｺ隱阪＠縺ｦ縺上□縺輔＞縲らｫｯ譛ｫ蜀崎ｵｷ蜍輔ｄ蜀阪Ο繧ｰ繧､繝ｳ縺ｧ謾ｹ蝟・☆繧句ｴ蜷医′縺ゅｊ縺ｾ縺吶・,
                    answerEn:
                        'Please review device notification permissions and the in-app notification schedule. Restarting the device or re-signing in can help restore delivery.',
                  ),
                  const _FaqItem(
                    questionJa: '繝壹い繧貞､画峩縺励◆縺・,
                    questionEn: 'I want to change my pair',
                    answerJa:
                        'Pair逕ｻ髱｢縺ｮ繝｡繝九Η繝ｼ縺九ｉ縲悟・繝槭ャ繝√阪ｒ驕ｸ謚槭☆繧九→縲∫樟蝨ｨ縺ｮ繝壹い縺ｫ騾夂衍縺励◆荳翫〒譁ｰ縺励＞蛟呵｣懊ｒ謗｢縺励∪縺吶・,
                    answerEn:
                        'Use the 窶彝e-match窶・option from the Pair screen menu. Your current partner will be notified while we look for a new match.',
                  ),
                  const _FaqItem(
                    questionJa: '繝・・繧ｿ縺ｮ繧ｨ繧ｯ繧ｹ繝昴・繝域婿豕・,
                    questionEn: 'How can I export my data?',
                    answerJa:
                        '險ｭ螳・> 繝励Λ繧､繝舌す繝ｼ > 繝・・繧ｿ繧偵お繧ｯ繧ｹ繝昴・繝・縺九ｉ逕ｳ隲九☆繧九→縲∫匳骭ｲ繝｡繝ｼ繝ｫ縺ｸ螳牙・縺ｪ繝繧ｦ繝ｳ繝ｭ繝ｼ繝峨Μ繝ｳ繧ｯ繧帝∽ｿ｡縺励∪縺吶・,
                    answerEn:
                        'Open Settings 竊・Privacy 竊・Export My Data to request an export. A secure download link will be emailed to you.',
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
      '繧ｳ繝斐・縺励∪縺励◆: $text',
    );
  }

  Future<void> _sendChatMessage(BuildContext context) async {
    if (_chatSending) return;
    final content = _chatController.text.trim();
    if (content.isEmpty) {
      FeedbackMessenger.showInfoToast(context, '雉ｪ蝠丞・螳ｹ繧貞・蜉帙＠縺ｦ縺上□縺輔＞');
      return;
    }

    // TODO: Implement supportChatServiceProvider
    // final service = ref.read(supportChatServiceProvider);
    // if (service == null) {
      FeedbackMessenger.showInfoToast(context, '迴ｾ蝨ｨ縺ｯ繧ｵ繝昴・繝医・繝・ヨ繧偵＃蛻ｩ逕ｨ縺・◆縺縺代∪縺帙ｓ');
      return;
    // }

    // TODO: Implement support chat service
  }

  Widget _buildSupportBotCard(MinqTheme tokens) {
    // TODO: Implement supportChatServiceProvider
    const isChatAvailable = false; // ref.watch(supportChatServiceProvider) != null;
    return Card(
      elevation: 0,
      color: tokens.surface,
      shape: RoundedRectangleBorder(borderRadius: tokens.cornerLarge()),
      child: Padding(
        padding: EdgeInsets.all(tokens.spacing(4)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'GPT-4o 繧ｵ繝昴・繝医メ繝｣繝・ヨ',
              style: tokens.titleSmall.copyWith(color: tokens.textPrimary),
            ),
            SizedBox(height: tokens.spacing(3)),
            if (!isChatAvailable)
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(tokens.spacing(3)),
                margin: EdgeInsets.only(bottom: tokens.spacing(3)),
                decoration: BoxDecoration(
                  color: tokens.surfaceVariant,
                  borderRadius: tokens.cornerMedium(),
                ),
                child: Text(
                  '迴ｾ蝨ｨ縺ｯ繧ｵ繝昴・繝医・繝・ヨ縺ｸ縺ｮ謗･邯壹ｒ貅門ｙ荳ｭ縺ｧ縺吶ゅ＠縺ｰ繧峨￥縺雁ｾ・■縺上□縺輔＞縲・,
                  style: tokens.bodySmall.copyWith(color: tokens.textMuted),
                ),
              ),
            Container(
              height: 220,
              decoration: BoxDecoration(
                color: tokens.surfaceVariant,
                borderRadius: tokens.cornerMedium(),
              ),
              child: ListView.builder(
                padding: EdgeInsets.all(tokens.spacing(3)),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final message = _messages[index];
                  final isUser = message.isUser;
                  final alignment = isUser ? Alignment.centerRight : Alignment.centerLeft;
                  final bubbleColor = isUser ? tokens.brandPrimary : tokens.surface;
                  final textColor = isUser ? tokens.onPrimary : tokens.textPrimary;
                  return Align(
                    alignment: alignment,
                    child: Container(
                      margin: EdgeInsets.only(bottom: tokens.spacing(2)),
                      padding: EdgeInsets.symmetric(
                        horizontal: tokens.spacing(3),
                        vertical: tokens.spacing(2),
                      ),
                      decoration: BoxDecoration(
                        color: bubbleColor,
                        borderRadius: BorderRadius.circular(tokens.radius(3)),
                      ),
                      child: Text(
                        message.content,
                        style: tokens.bodySmall.copyWith(color: textColor),
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: tokens.spacing(3)),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _chatController,
                    minLines: 1,
                    maxLines: 3,
                    enabled: isChatAvailable && !_chatSending,
                    decoration: const InputDecoration(
                      hintText: '萓・ 騾夂衍縺悟ｱ翫°縺ｪ縺・・縺ｧ縺吶′窶ｦ',
                    ),
                  ),
                ),
                SizedBox(width: tokens.spacing(2)),
                FilledButton.icon(
                  onPressed: !_chatSending && isChatAvailable
                      ? () => _sendChatMessage(context)
                      : null,
                  icon: _chatSending
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.send),
                  label: const Text('騾∽ｿ｡'),
                ),
              ],
            ),
          ],
        ),
      ),
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
              'MinQ縺ｮ菴ｿ縺・ｿ・慍繧呈蕗縺医※縺上□縺輔＞',
              style: tokens.titleSmall.copyWith(color: tokens.textPrimary),
            ),
            SizedBox(height: tokens.spacing(2)),
            Text(
              '0 = 縺翫☆縺吶ａ縺励◆縺上↑縺・/ 10 = 縺ｨ縺ｦ繧ゅ♀縺吶☆繧√＠縺溘＞',
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
                '繧ｹ繧ｳ繧｢: $_npsScore',
                style: tokens.bodySmall.copyWith(color: tokens.textMuted),
              ),
            ),
            SizedBox(height: tokens.spacing(4)),
            TextField(
              controller: _commentController,
              minLines: 2,
              maxLines: 4,
              decoration: InputDecoration(
                labelText: '繧ｳ繝｡繝ｳ繝・(莉ｻ諢・',
                hintText: '繝壹い讖溯・繧・夂衍繧ｿ繧､繝溘Φ繧ｰ縺ｧ謾ｹ蝟・＠縺ｦ谺ｲ縺励＞轤ｹ繧呈蕗縺医※縺上□縺輔＞',
                border: OutlineInputBorder(borderRadius: tokens.cornerMedium()),
              ),
            ),
            SizedBox(height: tokens.spacing(4)),
            if (_submitted && _recordedAt != null)
              Padding(
                padding: EdgeInsets.only(bottom: tokens.spacing(2)),
                child: Text(
                  '縺ゅｊ縺後→縺・＃縺悶＞縺ｾ縺呻ｼ・${_recordedAt!.year}/${_recordedAt!.month}/${_recordedAt!.day} 縺ｫ菫晏ｭ倥＠縺ｾ縺励◆縲・,
                  style: tokens.bodySmall.copyWith(color: tokens.accentSuccess),
                ),
              ),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton(
                onPressed: () => _submitNps(tokens),
                child: Text(_submitted ? '繝輔ぅ繝ｼ繝峨ヰ繝・け繧呈峩譁ｰ縺吶ｋ' : '繝輔ぅ繝ｼ繝峨ヰ繝・け繧帝∽ｿ｡縺吶ｋ'),
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
      '縺泌鵠蜉帙≠繧翫′縺ｨ縺・＃縺悶＞縺ｾ縺呻ｼ・,
    );
  }
}

class _BatteryOptimizationCard extends StatelessWidget {
  const _BatteryOptimizationCard({required this.tokens});

  final MinqTheme tokens;

  @override
  Widget build(BuildContext context) {
    const instructions = <String>[
      'Android: 險ｭ螳・> 繧｢繝励Μ縺ｨ騾夂衍 > 迚ｹ蛻･縺ｪ繧｢繝励Μ繧｢繧ｯ繧ｻ繧ｹ > 髮ｻ豎縺ｮ譛驕ｩ蛹・縺ｧ MinQ 繧偵梧怙驕ｩ蛹悶＠縺ｪ縺・阪↓險ｭ螳壹＠縺ｦ縺上□縺輔＞縲・,
      'iOS: 險ｭ螳・> 荳闊ｬ > App縺ｮ繝舌ャ繧ｯ繧ｰ繝ｩ繧ｦ繝ｳ繝画峩譁ｰ 縺九ｉ MinQ 繧偵が繝ｳ縺ｫ縺励※騾夂衍繧堤ｶｭ謖√＠縺ｦ縺上□縺輔＞縲・,
      '縺ｩ縺ｮ遶ｯ譛ｫ縺ｧ繧ゅ∫怐髮ｻ蜉帙Δ繝ｼ繝峨′譛牙柑縺ｪ蝣ｴ蜷医・騾夂衍縺碁≦繧後ｋ縺薙→縺後≠繧翫∪縺吶ょｭｦ鄙呈凾髢薙↓蜷医ｏ縺帙※隗｣髯､縺吶ｋ縺薙→繧偵♀縺吶☆繧√＠縺ｾ縺吶・,
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
              '騾夂衍縺悟ｱ翫°縺ｪ縺・ｴ蜷医・繝√ぉ繝・け繝ｪ繧ｹ繝・,
              style: tokens.titleSmall.copyWith(color: tokens.textPrimary),
            ),
            SizedBox(height: tokens.spacing(3)),
            ...instructions.map(
              (instruction) => Padding(
                padding: EdgeInsets.only(bottom: tokens.spacing(2)),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('窶｢ ', style: tokens.bodyMedium.copyWith(color: tokens.brandPrimary)),
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
