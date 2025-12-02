import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:minq/data/providers.dart';
import 'package:minq/data/services/content_moderation_service.dart';
import 'package:minq/presentation/common/security/sensitive_content.dart'
    as custom;
import 'package:minq/presentation/screens/pair_screen.dart';
import 'package:minq/presentation/theme/minq_theme.dart';

class ProfileSettingScreen extends ConsumerWidget {
  const ProfileSettingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.tokens;
    final userAsync = ref.watch(localUserProvider);
    final isDummyMode = ref.watch(dummyDataModeProvider);

    return Scaffold(
      backgroundColor: tokens.background,
      appBar: AppBar(
        title: Text(
          'プロフィール', // HTMLに合わせる
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
        actions: [
          if (isDummyMode)
            IconButton(
              icon: const Icon(Icons.warning, color: Colors.orange),
              onPressed: () => _showDummyModeWarning(context),
              tooltip: 'ダミーデータモード',
            ),
        ],
      ),
      body: custom.SensitiveContent(
        child: userAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error:
              (error, _) => Center(
                child: Text(
                  'プロフィールの読み込みに失敗しました',
                  style: tokens.bodyMedium.copyWith(color: tokens.accentError),
                ),
              ),
          data:
              (user) => ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  _buildProfileHeader(context, ref, user),
                  const SizedBox(height: 24),
                  _buildTags(context, ref, user),
                  const SizedBox(height: 24),
                  _buildStats(context, ref, user),
                  const SizedBox(height: 24),
                  _buildAccountSettings(context, ref, user),
                  const SizedBox(height: 24),
                  _buildSnsShare(context, ref, user),
                  const SizedBox(height: 24),
                  _buildPairInfo(context, ref, user),
                  const SizedBox(height: 24),
                  if (isDummyMode) _buildDummyDataControls(context, ref),
                  if (isDummyMode) const SizedBox(height: 24),
                  _buildOtherSettings(context, ref, user),
                  const SizedBox(height: 24),
                  _buildPremiumFeatures(context),
                  const SizedBox(height: 24),
                ],
              ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, WidgetRef ref, user) {
    final tokens = context.tokens;
    final isDummyMode = ref.watch(dummyDataModeProvider);

    // Generate anonymous username if not set
    final displayName =
        user?.displayName?.isNotEmpty == true
            ? user!.displayName
            : ContentModerationService.generateAnonymousUsername();

    final bio =
        user?.bio?.isNotEmpty == true
            ? user!.bio
            : isDummyMode
            ? '自己紹介文がここに入ります。ユーザーの簡単な説明です。'
            : '習慣化を頑張っています！';

    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            Builder(
              builder: (context) {
                const radius = 48.0;
                final pixelRatio = MediaQuery.of(context).devicePixelRatio;
                final cacheDimension = (radius * 2 * pixelRatio).round();

                // Use avatar URL if available, otherwise show default avatar
                final avatarUrl = user?.avatarUrl;

                if (avatarUrl?.isNotEmpty == true) {
                  return ClipOval(
                    child: Image.network(
                      avatarUrl!,
                      width: radius * 2,
                      height: radius * 2,
                      cacheWidth: cacheDimension,
                      cacheHeight: cacheDimension,
                      fit: BoxFit.cover,
                      filterQuality: FilterQuality.high,
                      errorBuilder:
                          (context, error, stackTrace) =>
                              _buildDefaultAvatar(tokens, radius),
                    ),
                  );
                } else {
                  return _buildDefaultAvatar(tokens, radius);
                }
              },
            ),
            GestureDetector(
              onTap: () => _editProfile(context, ref, user),
              child: Container(
                decoration: BoxDecoration(
                  color: tokens.brandPrimary,
                  shape: BoxShape.circle,
                ),
                child: const Padding(
                  padding: EdgeInsets.all(6.0),
                  child: Icon(Icons.edit, color: Colors.white, size: 16),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          displayName,
          style: tokens.titleLarge.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          bio,
          textAlign: TextAlign.center,
          style: tokens.bodyMedium.copyWith(color: tokens.textMuted),
        ),
      ],
    );
  }

  Widget _buildDefaultAvatar(MinqTheme tokens, double radius) {
    return Container(
      width: radius * 2,
      height: radius * 2,
      decoration: BoxDecoration(
        color: tokens.brandPrimary.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(Icons.person, size: radius, color: tokens.brandPrimary),
    );
  }

  void _showDummyModeWarning(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('ダミーデータモード'),
            content: const Text(
              'ダミーデータモードが有効になっています。'
              '実際のデータを使用するには、設定画面でダミーデータモードを無効にしてください。',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }

  void _editProfile(BuildContext context, WidgetRef ref, user) {
    final nameController = TextEditingController(text: user?.displayName ?? '');
    final bioController = TextEditingController(text: user?.bio ?? '');

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('プロフィール編集'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'ニックネーム',
                      hintText: '表示名を入力してください',
                    ),
                    maxLength: 20,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: bioController,
                    decoration: const InputDecoration(
                      labelText: '自己紹介',
                      hintText: '簡単な自己紹介を入力してください',
                    ),
                    maxLines: 3,
                    maxLength: 100,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('キャンセル'),
              ),
              TextButton(
                onPressed: () async {
                  final name = nameController.text.trim();
                  final bio = bioController.text.trim();

                  // Content moderation
                  if (name.isNotEmpty) {
                    final nameResult =
                        ContentModerationService.moderateUsername(name);
                    if (nameResult.isBlocked) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(nameResult.details ?? '不適切なニックネームです'),
                        ),
                      );
                      return;
                    }
                  }

                  if (bio.isNotEmpty) {
                    final bioResult = ContentModerationService.moderateText(
                      bio,
                    );
                    if (bioResult.isBlocked) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(bioResult.details ?? '不適切な自己紹介です'),
                        ),
                      );
                      return;
                    }
                  }

                  // Update user profile
                  try {
                    final userRepository = ref.read(userRepositoryProvider);
                    if (user != null) {
                      user.displayName = name.isNotEmpty ? name : null;
                      user.bio = bio.isNotEmpty ? bio : null;
                      await userRepository.saveLocalUser(user);

                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('プロフィールを更新しました')),
                      );
                    }
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('プロフィールの更新に失敗しました')),
                    );
                  }
                },
                child: const Text('保存'),
              ),
            ],
          ),
    );
  }

  Widget _buildDummyDataControls(BuildContext context, WidgetRef ref) {
    final tokens = context.tokens;

    return Card(
      color: tokens.surface,
      shape: RoundedRectangleBorder(
        borderRadius: tokens.cornerLarge(),
        side: BorderSide(color: tokens.accentWarning),
      ),
      child: Padding(
        padding: EdgeInsets.all(tokens.spacing(4)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.warning, color: tokens.accentWarning),
                SizedBox(width: tokens.spacing(2)),
                Text(
                  'ダミーデータモード',
                  style: tokens.titleSmall.copyWith(
                    color: tokens.accentWarning,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: tokens.spacing(2)),
            Text(
              'ダミーデータモードが有効になっています。実際のデータを使用するには、下のボタンを押してダミーデータを撤去してください。',
              style: tokens.bodyMedium.copyWith(color: tokens.textMuted),
            ),
            SizedBox(height: tokens.spacing(3)),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _removeDummyData(context, ref),
                icon: const Icon(Icons.cleaning_services),
                label: const Text('ダミーデータを撤去'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: tokens.accentWarning,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _removeDummyData(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('ダミーデータ撤去'),
            content: const Text(
              'ダミーデータモードを無効にして、実際のデータを使用しますか？'
              'この操作により、すべての機能が実際のデータで動作するようになります。',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('キャンセル'),
              ),
              TextButton(
                onPressed: () async {
                  // Disable dummy data mode
                  ref.read(dummyDataModeProvider.notifier).state = false;
                  await ref
                      .read(localPreferencesServiceProvider)
                      .setDummyDataMode(false);

                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('ダミーデータモードを無効にしました。実際のデータで動作します。'),
                    ),
                  );
                },
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('撤去する'),
              ),
            ],
          ),
    );
  }

  // Update other methods to accept user parameter
  Widget _buildTags(BuildContext context, WidgetRef ref, user) {
    final tokens = context.tokens;
    final isDummyMode = ref.watch(dummyDataModeProvider);

    final tags =
        isDummyMode ? ['習慣化', 'ランニング', '読書', '早起き'] : user?.tags ?? ['習慣化'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'タグ',
          style: tokens.titleMedium.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children:
              tags
                  .map(
                    (tag) => Chip(
                      label: Text(tag),
                      backgroundColor: tokens.brandPrimary.withOpacity(0.1),
                      labelStyle: tokens.bodySmall.copyWith(
                        color: tokens.brandPrimary,
                      ),
                    ),
                  )
                  .toList(),
        ),
      ],
    );
  }

  Widget _buildStats(BuildContext context, WidgetRef ref, user) {
    final tokens = context.tokens;
    final streakAsync = ref.watch(streakProvider);
    final todayCountAsync = ref.watch(todayCompletionCountProvider);

    return Row(
      children: [
        Expanded(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text(
                    'ストリーク',
                    style: tokens.bodyMedium.copyWith(color: tokens.textMuted),
                  ),
                  const SizedBox(height: 8),
                  streakAsync.when(
                    data:
                        (streak) => Text(
                          '$streak日',
                          style: tokens.titleLarge.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                    loading: () => const CircularProgressIndicator(),
                    error: (_, __) => const Text('--'),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text(
                    '今日の完了',
                    style: tokens.bodyMedium.copyWith(color: tokens.textMuted),
                  ),
                  const SizedBox(height: 8),
                  todayCountAsync.when(
                    data:
                        (count) => Text(
                          '$count個',
                          style: tokens.titleLarge.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                    loading: () => const CircularProgressIndicator(),
                    error: (_, __) => const Text('--'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAccountSettings(BuildContext context, WidgetRef ref, user) {
    final tokens = context.tokens;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'アカウント設定',
          style: tokens.titleMedium.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        const _ComingSoonTile(
          icon: Icons.notifications,
          title: '通知設定',
          description: '通知の細かなカスタマイズは現在準備中です。',
        ),
        const _ComingSoonTile(
          icon: Icons.privacy_tip,
          title: 'プライバシー設定',
          description: '公開範囲の調整機能は近日追加予定です。',
        ),
      ],
    );
  }

  Widget _buildSnsShare(BuildContext context, WidgetRef ref, user) {
    final tokens = context.tokens;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'SNS共有',
          style: tokens.titleMedium.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        const _ComingSoonPill(),
        SizedBox(height: tokens.spacing(2)),
        FilledButton.icon(
          onPressed: null,
          icon: const Icon(Icons.share),
          label: const Text('進捗を共有（準備中）'),
        ),
      ],
    );
  }

  Widget _buildPairInfo(BuildContext context, WidgetRef ref, user) {
    final tokens = context.tokens;
    final pairAsync = ref.watch(userPairProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ペア情報',
          style: tokens.titleMedium.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        pairAsync.when(
          data: (pair) {
            if (pair == null) {
              return const Card(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Icon(Icons.person_add, size: 48),
                      SizedBox(height: 8),
                      Text('ペアが見つかりません'),
                      SizedBox(height: 8),
                      _ComingSoonPill(),
                      SizedBox(height: 12),
                      FilledButton(onPressed: null, child: Text('ペアを探す（準備中）')),
                    ],
                  ),
                ),
              );
            }

            return Card(
              child: ListTile(
                leading: const CircleAvatar(child: Icon(Icons.person)),
                title: Text('ペア: ${pair.id}'),
                subtitle: const _PairStatusSubtitle(),
              ),
            );
          },
          loading:
              () => const Card(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Center(child: CircularProgressIndicator()),
                ),
              ),
          error:
              (_, __) => const Card(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text('ペア情報の読み込みに失敗しました'),
                ),
              ),
        ),
      ],
    );
  }

  Widget _buildOtherSettings(BuildContext context, WidgetRef ref, user) {
    final tokens = context.tokens;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'その他',
          style: tokens.titleMedium.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        const _ComingSoonTile(
          icon: Icons.help,
          title: 'ヘルプ',
          description: 'お問い合わせガイドは只今準備中です。',
        ),
        const _ComingSoonTile(
          icon: Icons.info,
          title: 'アプリについて',
          description: 'アプリ概要ページは近日公開予定です。',
        ),
        ListTile(
          leading: const Icon(Icons.logout),
          title: const Text('ログアウト'),
          onTap: () async {
            final confirmed = await showDialog<bool>(
              context: context,
              builder:
                  (context) => AlertDialog(
                    title: const Text('ログアウト'),
                    content: const Text('ログアウトしますか？'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: const Text('キャンセル'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        child: const Text('ログアウト'),
                      ),
                    ],
                  ),
            );

            if (confirmed == true) {
              await ref.read(authRepositoryProvider).signOut();
              if (context.mounted) {
                context.go('/');
              }
            }
          },
        ),
      ],
    );
  }

  Widget _buildPremiumFeatures(BuildContext context) {
    final tokens = context.tokens;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'プレミアム機能',
          style: tokens.titleMedium.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        const Card(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              children: [
                Icon(Icons.star, size: 48, color: Colors.amber),
                SizedBox(height: 8),
                Text('プレミアム機能は準備中です'),
                SizedBox(height: 8),
                _ComingSoonPill(),
                SizedBox(height: 12),
                FilledButton(onPressed: null, child: Text('詳細を見る（準備中）')),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTagChip(BuildContext context, String label) {
    final tokens = context.tokens;
    return Chip(
      label: Text(label),
      backgroundColor: tokens.brandPrimary.withOpacity(0.1),
      labelStyle: tokens.bodySmall.copyWith(color: tokens.brandPrimary),
      side: BorderSide.none,
    );
  }

  Widget _buildSocialButton({Color? color, bool isGradient = false}) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: isGradient ? null : color,
        gradient:
            isGradient
                ? const LinearGradient(
                  colors: [
                    Color(0xFF833AB4),
                    Color(0xFFFD1D1D),
                    Color(0xFFFCAF45),
                  ],
                )
                : null,
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.share, color: Colors.white, size: 24),
    );
  }
}

class _ComingSoonPill extends StatelessWidget {
  const _ComingSoonPill();

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: tokens.spacing(2),
        vertical: tokens.spacing(1),
      ),
      decoration: BoxDecoration(
        color: tokens.surfaceVariant,
        borderRadius: tokens.cornerFull(),
      ),
      child: Text(
        '準備中',
        style: tokens.labelSmall.copyWith(
          color: tokens.textMuted,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _ComingSoonTile extends StatelessWidget {
  const _ComingSoonTile({
    required this.icon,
    required this.title,
    this.description,
  });

  final IconData icon;
  final String title;
  final String? description;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return ListTile(
      enabled: false,
      leading: Icon(icon, color: tokens.textMuted),
      title: Text(
        title,
        style: tokens.bodyLarge.copyWith(
          color: tokens.textPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const _ComingSoonPill(),
          if (description != null) ...[
            SizedBox(height: tokens.spacing(1)),
            Text(
              description!,
              style: tokens.bodySmall.copyWith(color: tokens.textMuted),
            ),
          ],
        ],
      ),
    );
  }
}

class _PairStatusSubtitle extends StatelessWidget {
  const _PairStatusSubtitle();

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '一緒に頑張っています',
          style: tokens.bodySmall.copyWith(color: tokens.textMuted),
        ),
        SizedBox(height: tokens.spacing(2)),
        const _ComingSoonPill(),
      ],
    );
  }
}
