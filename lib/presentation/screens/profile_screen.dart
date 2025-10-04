import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:minq/presentation/common/security/sensitive_content.dart';
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
          style: tokens.titleMedium.copyWith(color: tokens.textPrimary),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: tokens.textPrimary),
          onPressed: () => context.pop(),
        ),
      ),
      body: SensitiveContent(
        child: ListView(
          padding: EdgeInsets.all(tokens.spacing(5)),
          children: <Widget>[
            _buildProfileHeader(tokens),
            SizedBox(height: tokens.spacing(6)),
            _buildStatsRow(tokens),
            SizedBox(height: tokens.spacing(8)),
            _buildAboutSection(tokens),
            SizedBox(height: tokens.spacing(6)),
            _buildMenu(context, tokens, ref),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(MinqTheme tokens) {
    return Column(
      children: <Widget>[
        Builder(
          builder: (context) {
            final avatarSize = tokens.spacing(24);
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
        SizedBox(height: tokens.spacing(4)),
        Text(
          'Ethan',
          style: tokens.titleMedium.copyWith(color: tokens.textPrimary),
        ),
        SizedBox(height: tokens.spacing(1)),
        Text(
          '@ethan_123',
          style: tokens.bodySmall.copyWith(color: tokens.textMuted),
        ),
        SizedBox(height: tokens.spacing(2)),
        Text(
          '2ヶ月前に参加',
          style: tokens.bodySmall.copyWith(color: tokens.textMuted),
        ),      ],
    );
  }

  Widget _buildStatsRow(MinqTheme tokens) {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: <Widget>[
        _StatItem(label: '連綁E, value: '12'),
        _StatItem(label: 'ペア', value: '3'),
        _StatItem(label: 'クエスチE, value: '2'),
      ],
    );
  }

  Widget _buildAboutSection(MinqTheme tokens) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: tokens.spacing(2)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            '概要E,
            style: tokens.titleSmall.copyWith(color: tokens.textPrimary),
          ),
          SizedBox(height: tokens.spacing(2)),
          Text(
            '私�Eソフトウェアエンジニアで、コーチE��ングとも�Eづくりが大好きです。また、生産性向上や習�E化�E大ファンでもあり、MinQを使って目標を達�Eできることを楽しみにしてぁE��す、E,
            style: tokens.bodySmall.copyWith(
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
              'プロフィールを編雁E,
              style: tokens.bodyMedium.copyWith(
                color: tokens.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            trailing: Icon(
              Icons.arrow_forward_ios,
              size: tokens.spacing(4),
              color: tokens.textMuted,
            ),
            onTap: () {},
          ),
          const Divider(height: 1),
          ListTile(
            title: Text(
              '設宁E,
              style: tokens.bodyMedium.copyWith(
                color: tokens.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            trailing: Icon(
              Icons.arrow_forward_ios,
              size: tokens.spacing(4),
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
        vertical: tokens.spacing(3),
        horizontal: tokens.spacing(6),
      ),
      decoration: BoxDecoration(
        color: tokens.surface,
        borderRadius: tokens.cornerMedium(),
        border: Border.all(color: tokens.brandPrimary.withValues(alpha: 0.18)),
        boxShadow: tokens.shadowSoft,
      ),
      child: Column(
        children: <Widget>[
          Text(
            value,
            style: tokens.titleSmall.copyWith(color: tokens.brandPrimary),
          ),
          SizedBox(height: tokens.spacing(1)),
          Text(
            label,
            style: tokens.bodySmall.copyWith(color: tokens.textMuted),
          ),
        ],
      ),
    );
  }
}
