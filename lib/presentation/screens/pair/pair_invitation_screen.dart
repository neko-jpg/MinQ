import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:minq/core/social/pair_system.dart';
import 'package:minq/data/providers.dart';
import 'package:minq/domain/pair/pair_invitation.dart';
import 'package:minq/l10n/app_localizations.dart';
import 'package:minq/presentation/common/feedback/feedback_messenger.dart';
import 'package:minq/presentation/theme/minq_theme.dart';
import 'package:minq/presentation/widgets/polished_buttons.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

/// ペア招待画面
class PairInvitationScreen extends ConsumerStatefulWidget {
  const PairInvitationScreen({super.key});

  @override
  ConsumerState<PairInvitationScreen> createState() =>
      _PairInvitationScreenState();
}

class _PairInvitationScreenState extends ConsumerState<PairInvitationScreen> {
  final _categoryController = TextEditingController(text: 'fitness');
  final _messageController = TextEditingController();
  PairInvitation? _invitation;
  bool _isLoading = false;

  @override
  void dispose() {
    _categoryController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _createInvitation() async {
    final userId = ref.read(uidProvider);
    if (userId == null) return;

    setState(() => _isLoading = true);

    try {
      final pairSystem = ref.read(pairSystemProvider);
      final invitation = await pairSystem.createInvitation(
        userId: userId,
        category: _categoryController.text.trim(),
        customMessage:
            _messageController.text.trim().isNotEmpty
                ? _messageController.text.trim()
                : null,
      );

      setState(() => _invitation = invitation);

      if (mounted) {
        FeedbackMessenger.showSuccessSnackBar(context, '招待リンクを作成しました！');
      }
    } catch (e) {
      if (mounted) {
        FeedbackMessenger.showErrorSnackBar(context, '招待リンクの作成に失敗しました: $e');
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _shareInvitation() async {
    if (_invitation == null) return;

    final l10n = AppLocalizations.of(context);
    final message = '''
${_invitation!.customMessage ?? 'MinQで一緒に習慣化しませんか？'}

招待コード: ${_invitation!.inviteCode}
リンク: ${_invitation!.webLink}

#MinQ #習慣化 #ペア機能
''';

    await Share.share(message, subject: 'MinQ ペア招待');
  }

  Future<void> _copyInviteCode() async {
    if (_invitation == null) return;

    await Clipboard.setData(ClipboardData(text: _invitation!.inviteCode));

    if (mounted) {
      FeedbackMessenger.showSuccessSnackBar(context, '招待コードをコピーしました');
    }
  }

  Future<void> _copyInviteLink() async {
    if (_invitation == null) return;

    await Clipboard.setData(ClipboardData(text: _invitation!.webLink));

    if (mounted) {
      FeedbackMessenger.showSuccessSnackBar(context, '招待リンクをコピーしました');
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: tokens.background,
      appBar: AppBar(
        title: Text(
          'ペア招待',
          style: tokens.typography.h4.copyWith(
            color: tokens.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: tokens.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: tokens.textPrimary),
          onPressed: () => context.pop(),
        ),
      ),
      body:
          _invitation == null
              ? _buildInvitationForm(tokens, l10n)
              : _buildInvitationResult(tokens, l10n),
    );
  }

  Widget _buildInvitationForm(MinqTheme tokens, AppLocalizations l10n) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(tokens.spacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ヘッダー
          Container(
            padding: EdgeInsets.all(tokens.spacing.lg),
            decoration: BoxDecoration(
              color: tokens.surface,
              borderRadius: BorderRadius.circular(tokens.radius.lg),
              border: Border.all(color: tokens.border),
            ),
            child: Column(
              children: [
                Icon(Icons.group_add, size: 48, color: tokens.primary),
                SizedBox(height: tokens.spacing.md),
                Text(
                  'ペア招待を作成',
                  style: tokens.typography.h3.copyWith(
                    color: tokens.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: tokens.spacing.sm),
                Text(
                  '友人と一緒に習慣化に取り組みましょう。\n招待リンクやQRコードを共有できます。',
                  style: tokens.typography.body.copyWith(
                    color: tokens.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          SizedBox(height: tokens.spacing.xl),

          // カテゴリ選択
          Text(
            'カテゴリ',
            style: tokens.typography.bodyMedium.copyWith(
              color: tokens.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: tokens.spacing.sm),
          DropdownButtonFormField<String>(
            initialValue: _categoryController.text,
            decoration: InputDecoration(
              filled: true,
              fillColor: tokens.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(tokens.radius.md),
                borderSide: BorderSide(color: tokens.border),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: tokens.spacing.md,
                vertical: tokens.spacing.sm,
              ),
            ),
            items: const [
              DropdownMenuItem(value: 'fitness', child: Text('🏃‍♂️ フィットネス')),
              DropdownMenuItem(value: 'learning', child: Text('📚 学習')),
              DropdownMenuItem(
                value: 'wellbeing',
                child: Text('🧘‍♀️ ウェルビーイング'),
              ),
              DropdownMenuItem(value: 'productivity', child: Text('💼 生産性')),
              DropdownMenuItem(value: 'creativity', child: Text('🎨 創造性')),
              DropdownMenuItem(value: 'general', child: Text('🌟 その他')),
            ],
            onChanged: (value) {
              if (value != null) {
                _categoryController.text = value;
              }
            },
          ),

          SizedBox(height: tokens.spacing.lg),

          // カスタムメッセージ
          Text(
            'カスタムメッセージ（任意）',
            style: tokens.typography.bodyMedium.copyWith(
              color: tokens.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: tokens.spacing.sm),
          TextField(
            controller: _messageController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: '一緒に頑張りましょう！',
              filled: true,
              fillColor: tokens.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(tokens.radius.md),
                borderSide: BorderSide(color: tokens.border),
              ),
              contentPadding: EdgeInsets.all(tokens.spacing.md),
            ),
          ),

          SizedBox(height: tokens.spacing.xl),

          // 作成ボタン
          PolishedPrimaryButton(
            onPressed: _isLoading ? null : _createInvitation,
            child:
                _isLoading
                    ? SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation(tokens.onPrimary),
                      ),
                    )
                    : const Text('招待を作成'),
          ),
        ],
      ),
    );
  }

  Widget _buildInvitationResult(MinqTheme tokens, AppLocalizations l10n) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(tokens.spacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 成功メッセージ
          Container(
            padding: EdgeInsets.all(tokens.spacing.lg),
            decoration: BoxDecoration(
              color: tokens.success.withOpacity(0.1),
              borderRadius: BorderRadius.circular(tokens.radius.lg),
              border: Border.all(color: tokens.success.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.check_circle, color: tokens.success, size: 24),
                SizedBox(width: tokens.spacing.md),
                Expanded(
                  child: Text(
                    '招待リンクを作成しました！',
                    style: tokens.typography.bodyMedium.copyWith(
                      color: tokens.success,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: tokens.spacing.xl),

          // QRコード
          Container(
            padding: EdgeInsets.all(tokens.spacing.lg),
            decoration: BoxDecoration(
              color: tokens.surface,
              borderRadius: BorderRadius.circular(tokens.radius.lg),
              border: Border.all(color: tokens.border),
            ),
            child: Column(
              children: [
                Text(
                  'QRコード',
                  style: tokens.typography.h4.copyWith(
                    color: tokens.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: tokens.spacing.lg),
                Container(
                  padding: EdgeInsets.all(tokens.spacing.md),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(tokens.radius.md),
                  ),
                  child: QrImageView(
                    data: _invitation!.deepLink,
                    version: QrVersions.auto,
                    size: 200,
                    backgroundColor: Colors.white,
                  ),
                ),
                SizedBox(height: tokens.spacing.md),
                Text(
                  'QRコードをスキャンして参加',
                  style: tokens.typography.bodySmall.copyWith(
                    color: tokens.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: tokens.spacing.lg),

          // 招待コード
          Container(
            padding: EdgeInsets.all(tokens.spacing.lg),
            decoration: BoxDecoration(
              color: tokens.surface,
              borderRadius: BorderRadius.circular(tokens.radius.lg),
              border: Border.all(color: tokens.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '招待コード',
                  style: tokens.typography.bodyMedium.copyWith(
                    color: tokens.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: tokens.spacing.sm),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.all(tokens.spacing.md),
                        decoration: BoxDecoration(
                          color: tokens.background,
                          borderRadius: BorderRadius.circular(tokens.radius.sm),
                          border: Border.all(color: tokens.border),
                        ),
                        child: Text(
                          _invitation!.inviteCode,
                          style: tokens.typography.h3.copyWith(
                            color: tokens.textPrimary,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    SizedBox(width: tokens.spacing.sm),
                    IconButton(
                      onPressed: _copyInviteCode,
                      icon: Icon(Icons.copy, color: tokens.primary),
                      style: IconButton.styleFrom(
                        backgroundColor: tokens.primary.withOpacity(0.1),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          SizedBox(height: tokens.spacing.lg),

          // 招待リンク
          Container(
            padding: EdgeInsets.all(tokens.spacing.lg),
            decoration: BoxDecoration(
              color: tokens.surface,
              borderRadius: BorderRadius.circular(tokens.radius.lg),
              border: Border.all(color: tokens.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '招待リンク',
                  style: tokens.typography.bodyMedium.copyWith(
                    color: tokens.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: tokens.spacing.sm),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.all(tokens.spacing.md),
                        decoration: BoxDecoration(
                          color: tokens.background,
                          borderRadius: BorderRadius.circular(tokens.radius.sm),
                          border: Border.all(color: tokens.border),
                        ),
                        child: Text(
                          _invitation!.webLink,
                          style: tokens.typography.bodySmall.copyWith(
                            color: tokens.textSecondary,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    SizedBox(width: tokens.spacing.sm),
                    IconButton(
                      onPressed: _copyInviteLink,
                      icon: Icon(Icons.copy, color: tokens.primary),
                      style: IconButton.styleFrom(
                        backgroundColor: tokens.primary.withOpacity(0.1),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          SizedBox(height: tokens.spacing.xl),

          // 共有ボタン
          PolishedPrimaryButton(
            onPressed: _shareInvitation,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.share, color: tokens.onPrimary),
                SizedBox(width: tokens.spacing.sm),
                const Text('招待を共有'),
              ],
            ),
          ),

          SizedBox(height: tokens.spacing.md),

          // 有効期限
          Container(
            padding: EdgeInsets.all(tokens.spacing.md),
            decoration: BoxDecoration(
              color: tokens.warning.withOpacity(0.1),
              borderRadius: BorderRadius.circular(tokens.radius.md),
              border: Border.all(color: tokens.warning.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.schedule, color: tokens.warning, size: 20),
                SizedBox(width: tokens.spacing.sm),
                Expanded(
                  child: Text(
                    '有効期限: ${_formatExpiryDate(_invitation!.expiresAt)}',
                    style: tokens.typography.bodySmall.copyWith(
                      color: tokens.warning,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatExpiryDate(DateTime date) {
    final now = DateTime.now();
    final difference = date.difference(now);

    if (difference.inDays > 0) {
      return '${difference.inDays}日後';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}時間後';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}分後';
    } else {
      return '期限切れ';
    }
  }
}
