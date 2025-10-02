import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:minq/data/providers.dart';
import 'package:minq/data/services/content_moderation_service.dart';
import 'package:minq/presentation/common/security/sensitive_content.dart';
import 'package:minq/presentation/screens/pair_screen.dart';
import 'package:minq/presentation/theme/minq_theme.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

class ProfileSettingScreen extends ConsumerWidget {
  const ProfileSettingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.tokens;
    final l10n = AppLocalizations.of(context)!;
    final userAsync = ref.watch(localUserProvider);
    final isDummyMode = ref.watch(dummyDataModeProvider);

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
        actions: [
          if (isDummyMode)
            IconButton(
              icon: const Icon(Icons.warning, color: Colors.orange),
              onPressed: () => _showDummyModeWarning(context),
              tooltip: 'ダミーデータモード',
            ),
        ],
      ),
      body: SensitiveContent(
        child: userAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(
            child: Text(
              'プロフィールの読み込みに失敗しました',
              style: tokens.bodyMedium.copyWith(color: tokens.accentError),
            ),
          ),
          data: (user) => ListView(
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
            _buildOtherSettings(context),
            const SizedBox(height: 24),
            _buildPremiumFeatures(context),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, WidgetRef ref, user) {
    final tokens = context.tokens;
    final isDummyMode = ref.watch(dummyDataModeProvider);
    
    // Generate anonymous username if not set
    final displayName = user?.displayName?.isNotEmpty == true 
        ? user!.displayName 
        : ContentModerationService.generateAnonymousUsername();
    
    final bio = user?.bio?.isNotEmpty == true 
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
                      errorBuilder: (context, error, stackTrace) => _buildDefaultAvatar(tokens, radius),
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
                  child: Icon(
                    Icons.edit,
                    color: Colors.white,
                    size: 16,
                  ),
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
      child: Icon(
        Icons.person,
        size: radius,
        color: tokens.brandPrimary,
      ),
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
}  vo
id _showDummyModeWarning(BuildContext context) {
    final tokens = context.tokens;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
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
    final tokens = context.tokens;
    final nameController = TextEditingController(text: user?.displayName ?? '');
    final bioController = TextEditingController(text: user?.bio ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
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
                final nameResult = ContentModerationService.moderateUsername(name);
                if (nameResult.isBlocked) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(nameResult.details ?? '不適切なニックネームです')),
                  );
                  return;
                }
              }
              
              if (bio.isNotEmpty) {
                final bioResult = ContentModerationService.moderateText(bio);
                if (bioResult.isBlocked) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(bioResult.details ?? '不適切な自己紹介です')),
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
      builder: (context) => AlertDialog(
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
              await ref.read(localPreferencesServiceProvider).setDummyDataMode(false);
              
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
    
    final tags = isDummyMode 
        ? ['習慣化', 'ランニング', '読書', '早起き']
        : user?.tags ?? ['習慣化'];

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
          children: tags.map((tag) => Chip(
            label: Text(tag),
            backgroundColor: tokens.brandPrimary.withOpacity(0.1),
            labelStyle: tokens.bodySmall.copyWith(color: tokens.brandPrimary),
          )).toList(),
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
                  Text('ストリーク', style: tokens.bodyMedium.copyWith(color: tokens.textMuted)),
                  const SizedBox(height: 8),
                  streakAsync.when(
                    data: (streak) => Text(
                      '$streak日',
                      style: tokens.titleLarge.copyWith(fontWeight: FontWeight.bold),
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
                  Text('今日の完了', style: tokens.bodyMedium.copyWith(color: tokens.textMuted)),
                  const SizedBox(height: 8),
                  todayCountAsync.when(
                    data: (count) => Text(
                      '$count個',
                      style: tokens.titleLarge.copyWith(fontWeight: FontWeight.bold),
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
        ListTile(
          leading: const Icon(Icons.notifications),
          title: const Text('通知設定'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            // Navigate to notification settings
          },
        ),
        ListTile(
          leading: const Icon(Icons.privacy_tip),
          title: const Text('プライバシー設定'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            // Navigate to privacy settings
          },
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
        ElevatedButton.icon(
          onPressed: () {
            // Implement SNS sharing
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('SNS共有機能は準備中です')),
            );
          },
          icon: const Icon(Icons.share),
          label: const Text('進捗を共有'),
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
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      const Icon(Icons.person_add, size: 48),
                      const SizedBox(height: 8),
                      const Text('ペアが見つかりません'),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () {
                          // Navigate to pair screen
                        },
                        child: const Text('ペアを探す'),
                      ),
                    ],
                  ),
                ),
              );
            }
            
            return Card(
              child: ListTile(
                leading: const CircleAvatar(
                  child: Icon(Icons.person),
                ),
                title: Text('ペア: ${pair.id}'),
                subtitle: const Text('一緒に頑張っています'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.chat),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.block, color: Colors.red),
                    ),
                  ],
                ),
              ),
            );
          },
          loading: () => const Card(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(child: CircularProgressIndicator()),
            ),
          ),
          error: (_, __) => const Card(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Text('ペア情報の読み込みに失敗しました'),
            ),
          ),
        ),
      ],
    );
  }
}