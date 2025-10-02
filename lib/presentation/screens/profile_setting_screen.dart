import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:minq/presentation/common/security/sensitive_content.dart';
import 'package:minq/presentation/theme/minq_theme.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

class ProfileSettingScreen extends ConsumerWidget {
  const ProfileSettingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.tokens;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: tokens.background,
      appBar: AppBar(
        title: Text(
          "プロフィール", // HTMLに合わせる
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
        backgroundColor: tokens.background.withOpacity(0.8),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: SensitiveContent(
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            _buildProfileHeader(context),
            const SizedBox(height: 24),
            _buildTags(context),
            const SizedBox(height: 24),
            _buildStats(context),
            const SizedBox(height: 24),
            _buildAccountSettings(context),
            const SizedBox(height: 24),
            _buildSnsShare(context),
            const SizedBox(height: 24),
            _buildPairInfo(context),
            const SizedBox(height: 24),
            _buildOtherSettings(context),
            const SizedBox(height: 24),
            _buildPremiumFeatures(context),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context) {
    final tokens = context.tokens;
    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            Builder(
              builder: (context) {
                const avatarUrl =
                    'https://lh3.googleusercontent.com/aida-public/AB6AXuB4vUzoYiKTiCCCXbd0O3qbfuJgpaM3LOMHFzNzTBon5Qs2emMO6ToMK7WXGiq2oHUba9VbQOd1AjxiNcvsVWZll_hLRZKHWqe6CSNf1gYrPZzNsp8kZuHTxSh29HdEWfo0_KNdRjvpNFpAabh50wZOoM-_goQOnAtriaTgG1BAO2EQlWy_U6Yj02gibaZb6ActchMxg_-f7nWNey-YIdsjPsaAb_3t8-PJjpbF486yWHtA8ywucP5c9Wlp4G1cI4DfZ-h07gieyos';
                const radius = 48.0;
                final pixelRatio = MediaQuery.of(context).devicePixelRatio;
                final cacheDimension = (radius * 2 * pixelRatio).round();
                return ClipOval(
                  child: Image.network(
                    avatarUrl,
                    width: radius * 2,
                    height: radius * 2,
                    cacheWidth: cacheDimension,
                    cacheHeight: cacheDimension,
                    fit: BoxFit.cover,
                    filterQuality: FilterQuality.high,
                  ),
                );
              },
            ),
            Container(
              decoration: BoxDecoration(
                color: tokens.brandPrimary,
                shape: BoxShape.circle,
              ),
              child: const Padding(
                padding: EdgeInsets.all(6.0),
                child: Icon(
                  Icons.edit,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          'ニックネーム',
          style: tokens.titleLarge.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          '自己紹介文がここに入ります。ユーザーの簡単な説明です。',
          textAlign: TextAlign.center,
          style: tokens.bodyMedium.copyWith(color: tokens.textMuted),
        ),
      ],
    );
  }

  Widget _buildTags(BuildContext context) {
    final tokens = context.tokens;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('タグ', style: tokens.titleMedium.copyWith(fontWeight: FontWeight.bold)),
            TextButton(
              onPressed: () {},
              child: Text('編集', style: TextStyle(color: tokens.brandPrimary)),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8.0,
          runSpacing: 8.0,
          children: [
            _buildTagChip(context, '#ゲーム'),
            _buildTagChip(context, '#映画鑑賞'),
            _buildTagChip(context, '#旅行'),
            _buildTagChip(context, '#料理'),
          ],
        ),
      ],
    );
  }

  Widget _buildTagChip(BuildContext context, String label) {
    final tokens = context.tokens;
    return Chip(
      label: Text(label, style: TextStyle(color: tokens.brandPrimary)),
      backgroundColor: tokens.brandPrimary.withOpacity(0.1),
      side: BorderSide.none,
    );
  }

  Widget _buildStats(BuildContext context) {
    final tokens = context.tokens;
    return Row(
      children: [
        Expanded(
          child: Card(
            elevation: 0,
            color: tokens.surface,
            shape: RoundedRectangleBorder(borderRadius: tokens.cornerLarge(), side: BorderSide(color: tokens.border)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text('ストリーク', style: tokens.bodyMedium.copyWith(color: tokens.textMuted)),
                  const SizedBox(height: 8),
                  Text('12日', style: tokens.titleLarge.copyWith(fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Card(
            elevation: 0,
            color: tokens.surface,
            shape: RoundedRectangleBorder(borderRadius: tokens.cornerLarge(), side: BorderSide(color: tokens.border)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text('総クエスト数', style: tokens.bodyMedium.copyWith(color: tokens.textMuted)),
                  const SizedBox(height: 8),
                  Text('85', style: tokens.titleLarge.copyWith(fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAccountSettings(BuildContext context) {
    final tokens = context.tokens;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('アカウント設定', style: tokens.titleMedium.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Card(
          elevation: 0,
          color: tokens.surface,
          shape: RoundedRectangleBorder(borderRadius: tokens.cornerLarge(), side: BorderSide(color: tokens.border)),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              ListTile(
                title: const Text('通知'),
                trailing: Icon(Icons.arrow_forward_ios, size: 16, color: tokens.textMuted),
                onTap: () {},
              ),
              const Divider(height: 1),
              ListTile(
                title: const Text('言語'),
                trailing: Icon(Icons.arrow_forward_ios, size: 16, color: tokens.textMuted),
                onTap: () {},
              ),
              const Divider(height: 1),
              ListTile(
                title: const Text('ログアウト'),
                trailing: Icon(Icons.logout, color: tokens.textMuted),
                onTap: () {},
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSnsShare(BuildContext context) {
    final tokens = context.tokens;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('SNSシェア・招待', style: tokens.titleMedium.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Card(
          elevation: 0,
          color: tokens.surface,
          shape: RoundedRectangleBorder(borderRadius: tokens.cornerLarge(), side: BorderSide(color: tokens.border)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('友達を招待して特典をゲット！', style: tokens.bodyMedium.copyWith(color: tokens.textMuted)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: tokens.background,
                          borderRadius: tokens.cornerMedium(),
                        ),
                        child: const Text('AB12-34CD-56EF', style: TextStyle(fontFamily: 'monospace')),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: tokens.brandPrimary,
                        shape: RoundedRectangleBorder(borderRadius: tokens.cornerMedium()),
                      ),
                      child: const Text('コピー'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text('SNSでシェアする', style: tokens.bodyMedium.copyWith(color: tokens.textMuted)),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    _buildSocialButton(color: const Color(0xFF1DA1F2)), // Twitter
                    const SizedBox(width: 16),
                    _buildSocialButton(color: const Color(0xFF1877F2)), // Facebook
                    const SizedBox(width: 16),
                    _buildSocialButton(isGradient: true), // Instagram
                    const SizedBox(width: 16),
                    _buildSocialButton(color: const Color(0xFF00B900)), // Line
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPairInfo(BuildContext context) {
    final tokens = context.tokens;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('ペア', style: tokens.titleMedium.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Card(
          elevation: 0,
          color: tokens.surface,
          shape: RoundedRectangleBorder(borderRadius: tokens.cornerLarge(), side: BorderSide(color: tokens.border)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Builder(
                  builder: (context) {
                    const avatarUrl =
                        'https://lh3.googleusercontent.com/aida-public/AB6AXuD2HXX6O9Ry4fdKOLT4GAgrvT0GaEd1zK6s_j9dcBB0GEJ8dzNXLkIBjEPOYeBz8O0hWfBAarj3WCLZuZBuGKxRrRkAn96bNK0Rnlrrv2kujNoJOaouDyUitLqmb4VrK0XhmtsBq13OlU-y5jRXY92iMfOk1x7Mx1feEQZw90VHDuSnDYlLsrqlFYag7kv9ftpVkqBROiTbaS82XKJVRM0ECJQIKUclpMae0LxknbxUz7o60bxB36X6b2G2ODrs4gcIUJ9X_TwSUBQ';
                    const radius = 24.0;
                    final pixelRatio = MediaQuery.of(context).devicePixelRatio;
                    final cacheDimension = (radius * 2 * pixelRatio).round();
                    return ClipOval(
                      child: Image.network(
                        avatarUrl,
                        width: radius * 2,
                        height: radius * 2,
                        cacheWidth: cacheDimension,
                        cacheHeight: cacheDimension,
                        fit: BoxFit.cover,
                        filterQuality: FilterQuality.high,
                      ),
                    );
                  },
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('ペアの名前', style: tokens.bodyLarge.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      LinearProgressIndicator(
                        value: 0.75,
                        backgroundColor: tokens.border.withOpacity(0.5),
                        valueColor: AlwaysStoppedAnimation<Color>(tokens.brandPrimary),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {},
                  icon: Icon(Icons.link_off, color: tokens.textMuted),
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.block, color: Colors.red),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOtherSettings(BuildContext context) {
    final tokens = context.tokens;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('その他', style: tokens.titleMedium.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Card(
          elevation: 0,
          color: tokens.surface,
          shape: RoundedRectangleBorder(borderRadius: tokens.cornerLarge(), side: BorderSide(color: tokens.border)),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              ListTile(
                title: const Text('年齢認証ステータス'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('認証済み', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                    const SizedBox(width: 8),
                    Icon(Icons.arrow_forward_ios, size: 16, color: tokens.textMuted),
                  ],
                ),
                onTap: () {},
              ),
              const Divider(height: 1),
              ListTile(
                title: const Text('実績/バッジコレクション'),
                trailing: Icon(Icons.arrow_forward_ios, size: 16, color: tokens.textMuted),
                onTap: () {},
              ),
              const Divider(height: 1),
              ListTile(
                title: const Text('公開範囲設定'),
                trailing: Icon(Icons.arrow_forward_ios, size: 16, color: tokens.textMuted),
                onTap: () {},
              ),
              const Divider(height: 1),
              ListTile(
                title: const Text('詳細統計'),
                trailing: Icon(Icons.arrow_forward_ios, size: 16, color: tokens.textMuted),
                onTap: () {},
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPremiumFeatures(BuildContext context) {
    final tokens = context.tokens;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('プレミアム機能', style: tokens.titleMedium.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Card(
          elevation: 0,
          color: tokens.surface,
          shape: RoundedRectangleBorder(borderRadius: tokens.cornerLarge(), side: BorderSide(color: tokens.border)),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              ListTile(
                leading: Icon(Icons.people, color: tokens.brandPrimary),
                title: const Text('複数ペア解放'),
                trailing: Icon(Icons.lock, color: Colors.amber),
                onTap: () {},
              ),
              const Divider(height: 1),
              ListTile(
                leading: Icon(Icons.palette, color: tokens.brandPrimary),
                title: const Text('カスタマイズ (テーマ・フレーム)'),
                trailing: Icon(Icons.lock, color: Colors.amber),
                onTap: () {},
              ),
              const Divider(height: 1),
              ListTile(
                leading: Icon(Icons.star, color: tokens.brandPrimary),
                title: const Text('優先マッチング'),
                trailing: Icon(Icons.lock, color: Colors.amber),
                onTap: () {},
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSocialButton({Color? color, bool isGradient = false}) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: isGradient ? null : color,
        gradient: isGradient
            ? const LinearGradient(
                colors: [Color(0xFF833AB4), Color(0xFFFD1D1D), Color(0xFFFCAF45)],
              )
            : null,
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.share, color: Colors.white, size: 24), // Placeholder icon
    );
  }
}