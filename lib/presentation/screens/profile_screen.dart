import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:minq/presentation/common/layout/responsive_layout.dart';
import 'package:minq/presentation/common/layout/safe_scaffold.dart';
import 'package:minq/presentation/common/security/sensitive_content.dart'
    as custom;
import 'package:minq/presentation/routing/app_router.dart';
import 'package:minq/presentation/theme/minq_theme.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.tokens;

    return SafeScaffold(
      backgroundColor: tokens.background,
      appBar: AppBar(
        title: Text(
          'プロフィール',
          style: tokens.typography.h4.copyWith(color: tokens.textPrimary),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        leading: ResponsiveLayout.ensureTouchTarget(
          child: IconButton(
            icon: Icon(Icons.arrow_back, color: tokens.textPrimary),
            onPressed: () => context.pop(),
          ),
        ),
      ),
      body: custom.SensitiveContent(
        child: SafeScrollView(
          children: <Widget>[
            _buildProfileHeader(context, tokens),
            SizedBox(height: tokens.spacing.xl),
            _buildStatsRow(tokens),
            const SizedBox(height: 32),
            _buildAboutSection(tokens),
            SizedBox(height: tokens.spacing.xl),
            _buildMenu(context, tokens, ref),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, MinqTheme tokens) {
    return Column(
      children: <Widget>[
        Builder(
          builder: (context) {
            const avatarSize = 96.0;
            final pixelRatio = MediaQuery.of(context).devicePixelRatio;
            final cacheDimension = (avatarSize * pixelRatio).round();
            return ClipOval(
              child: Image.network(
                'https://i.pravatar.cc/150?img=3',
                width: avatarSize,
                height: avatarSize,
                cacheWidth: cacheDimension,
                cacheHeight: cacheDimension,
                fit: BoxFit.cover,
                filterQuality: FilterQuality.high,
              ),
            );
          },
        ),
        const SizedBox(height: 16),
        Text(
          'Ethan',
          style: tokens.typography.h4.copyWith(color: tokens.textPrimary),
        ),
        SizedBox(height: tokens.spacing.xs),
        Text(
          '@ethan_123',
          style: tokens.typography.bodySmall.copyWith(color: tokens.textMuted),
        ),
        SizedBox(height: tokens.spacing.sm),
        Text(
          '2ヶ月前に参加',
          style: tokens.typography.bodySmall.copyWith(color: tokens.textMuted),
        ),
      ],
    );
  }

  Widget _buildStatsRow(MinqTheme tokens) {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: <Widget>[
        _StatItem(label: '連続', value: '12'),
        _StatItem(label: 'ペア', value: '3'),
        _StatItem(label: 'クエスト', value: '2'),
      ],
    );
  }

  Widget _buildAboutSection(MinqTheme tokens) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: tokens.spacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            '概要',
            style: tokens.typography.h5.copyWith(color: tokens.textPrimary),
          ),
          SizedBox(height: tokens.spacing.sm),
          Text(
            '私はソフトウェアエンジニアで、コーディングとものづくりが大好きです。また、生産性向上や習慣化の大ファンでもあり、MinQを使って目標を達成できることを楽しみにしています。',
            style: tokens.typography.bodySmall.copyWith(
              color: tokens.textMuted,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenu(BuildContext context, MinqTheme tokens, WidgetRef ref) {
    final navigation = ref.read(navigationUseCaseProvider);
    
    return Column(
      children: [
        // Main Features Section
        Card(
          elevation: 0,
          color: tokens.surface,
          shape: RoundedRectangleBorder(borderRadius: tokens.cornerLarge()),
          child: Column(
            children: <Widget>[
              _buildMenuItem(
                context,
                tokens,
                title: 'プロフィールを編集',
                icon: Icons.edit_outlined,
                onTap: () => navigation.goToProfileSettings(),
              ),
              const Divider(height: 1),
              _buildMenuItem(
                context,
                tokens,
                title: 'ペア',
                subtitle: '友達と一緒に習慣を継続',
                icon: Icons.groups_outlined,
                onTap: () => navigation.goToPair(),
              ),
              const Divider(height: 1),
              _buildMenuItem(
                context,
                tokens,
                title: 'クエスト',
                subtitle: '習慣をクエストとして管理',
                icon: Icons.checklist_outlined,
                onTap: () => navigation.goToQuests(),
              ),
              const Divider(height: 1),
              _buildMenuItem(
                context,
                tokens,
                title: 'AIインサイト',
                subtitle: 'データに基づく習慣分析',
                icon: Icons.insights_outlined,
                onTap: () => navigation.goToAiInsights(),
              ),
            ],
          ),
        ),
        
        SizedBox(height: tokens.spacing.lg),
        
        // Settings Section with Hamburger Menu
        Card(
          elevation: 0,
          color: tokens.surface,
          shape: RoundedRectangleBorder(borderRadius: tokens.cornerLarge()),
          child: ExpansionTile(
            leading: Icon(Icons.menu, color: tokens.textPrimary),
            title: Text(
              '設定とその他',
              style: tokens.typography.bodyMedium.copyWith(
                color: tokens.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            children: [
              _buildMenuItem(
                context,
                tokens,
                title: '設定',
                icon: Icons.settings_outlined,
                onTap: () => navigation.goToSettings(),
                isInExpansion: true,
              ),
              _buildMenuItem(
                context,
                tokens,
                title: '通知設定',
                icon: Icons.notifications_outlined,
                onTap: () => navigation.goToNotificationSettings(),
                isInExpansion: true,
              ),
              _buildMenuItem(
                context,
                tokens,
                title: '友達招待',
                icon: Icons.person_add_outlined,
                onTap: () => navigation.goToReferral(),
                isInExpansion: true,
              ),
              _buildMenuItem(
                context,
                tokens,
                title: 'ヘルプセンター',
                icon: Icons.help_outline,
                onTap: () => navigation.goToHelpCenter(),
                isInExpansion: true,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMenuItem(
    BuildContext context,
    MinqTheme tokens, {
    required String title,
    String? subtitle,
    required IconData icon,
    required VoidCallback onTap,
    bool isInExpansion = false,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(
        horizontal: tokens.spacing.lg,
        vertical: isInExpansion ? tokens.spacing.xs : tokens.spacing.sm,
      ),
      minTileHeight: ResponsiveLayout.minTouchTarget + 12, // Ensure proper touch target
      leading: Icon(
        icon,
        color: tokens.textPrimary,
        size: 24,
      ),
      title: Text(
        title,
        style: tokens.typography.bodyMedium.copyWith(
          color: tokens.textPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: tokens.typography.bodySmall.copyWith(
                color: tokens.textMuted,
              ),
            )
          : null,
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: tokens.textMuted,
      ),
      onTap: onTap,
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Container(
      padding: EdgeInsets.symmetric(
        vertical: tokens.spacing.md,
        horizontal: tokens.spacing.xl,
      ),
      decoration: BoxDecoration(
        color: tokens.surface,
        borderRadius: tokens.cornerMedium(),
        border: Border.all(color: tokens.brandPrimary.withAlpha(46)),
        boxShadow: tokens.shadow.soft,
      ),
      child: Column(
        children: <Widget>[
          Text(
            value,
            style: tokens.typography.h5.copyWith(color: tokens.brandPrimary),
          ),
          SizedBox(height: tokens.spacing.xs),
          Text(
            label,
            style: tokens.typography.bodySmall.copyWith(color: tokens.textMuted),
          ),
        ],
      ),
    );
  }
}
