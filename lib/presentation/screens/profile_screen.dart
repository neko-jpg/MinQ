import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:minq/presentation/common/security/sensitive_content.dart'
    as custom;
import 'package:minq/presentation/routing/app_router.dart';
import 'package:minq/presentation/theme/minq_theme.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.tokens;

    return Scaffold(
      backgroundColor: tokens.background,
      appBar: AppBar(
        title: Text(
          'プロフィール',
          style: tokens.typography.h4.copyWith(color: tokens.textPrimary),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: tokens.textPrimary),
          onPressed: () => context.pop(),
        ),
      ),
      body: custom.SensitiveContent(
        child: ListView(
          padding: EdgeInsets.all(tokens.spacing.lg),
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
    return Card(
      elevation: 0,
      color: tokens.surface,
      shape: RoundedRectangleBorder(borderRadius: tokens.cornerLarge()),
      child: Column(
        children: <Widget>[
          ListTile(
            title: Text(
              'プロフィールを編集',
              style: tokens.typography.bodyMedium.copyWith(
                color: tokens.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            trailing: Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: tokens.textMuted,
            ),
            onTap: () {},
          ),
          const Divider(height: 1),
          ListTile(
            title: Text(
              '設定',
              style: tokens.typography.bodyMedium.copyWith(
                color: tokens.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            trailing: Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: tokens.textMuted,
            ),
            onTap: () => ref.read(navigationUseCaseProvider).goToSettings(),
          ),
        ],
      ),
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
