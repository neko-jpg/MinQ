import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:minq/data/providers.dart';
import 'package:minq/data/services/content_moderation_service.dart';
import 'package:minq/presentation/common/security/sensitive_content.dart';
import 'package:minq/presentation/screens/pair_screen.dart';
import 'package:minq/presentation/theme/minq_theme.dart';

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
          '繝励Ο繝輔ぅ繝ｼ繝ｫ', // HTML縺ｫ蜷医ｏ縺帙ｋ
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
        backgroundColor: tokens.background.withValues(alpha: 0.8),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        actions: [
          if (isDummyMode)
            IconButton(
              icon: const Icon(Icons.warning, color: Colors.orange),
              onPressed: () => _showDummyModeWarning(context),
              tooltip: '繝繝溘・繝・・繧ｿ繝｢繝ｼ繝・,
            ),
        ],
      ),
      body: SensitiveContent(
        child: userAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(
            child: Text(
              '繝励Ο繝輔ぅ繝ｼ繝ｫ縺ｮ隱ｭ縺ｿ霎ｼ縺ｿ縺ｫ螟ｱ謨励＠縺ｾ縺励◆',
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
    final displayName = user?.displayName?.isNotEmpty == true 
        ? user!.displayName 
        : ContentModerationService.generateAnonymousUsername();
    
    final bio = user?.bio?.isNotEmpty == true 
        ? user!.bio 
        : isDummyMode 
            ? '閾ｪ蟾ｱ邏ｹ莉区枚縺後％縺薙↓蜈･繧翫∪縺吶ゅΘ繝ｼ繧ｶ繝ｼ縺ｮ邁｡蜊倥↑隱ｬ譏弱〒縺吶・
            : '鄙呈・蛹悶ｒ鬆大ｼｵ縺｣縺ｦ縺・∪縺呻ｼ・;

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
        color: tokens.brandPrimary.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.person,
        size: radius,
        color: tokens.brandPrimary,
      ),
    );
  }

  void _showDummyModeWarning(BuildContext context) {
    final tokens = context.tokens;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('繝繝溘・繝・・繧ｿ繝｢繝ｼ繝・),
        content: const Text(
          '繝繝溘・繝・・繧ｿ繝｢繝ｼ繝峨′譛牙柑縺ｫ縺ｪ縺｣縺ｦ縺・∪縺吶・
          '螳滄圀縺ｮ繝・・繧ｿ繧剃ｽｿ逕ｨ縺吶ｋ縺ｫ縺ｯ縲∬ｨｭ螳夂判髱｢縺ｧ繝繝溘・繝・・繧ｿ繝｢繝ｼ繝峨ｒ辟｡蜉ｹ縺ｫ縺励※縺上□縺輔＞縲・,
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
        title: const Text('繝励Ο繝輔ぅ繝ｼ繝ｫ邱ｨ髮・),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: '繝九ャ繧ｯ繝阪・繝',
                  hintText: '陦ｨ遉ｺ蜷阪ｒ蜈･蜉帙＠縺ｦ縺上□縺輔＞',
                ),
                maxLength: 20,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: bioController,
                decoration: const InputDecoration(
                  labelText: '閾ｪ蟾ｱ邏ｹ莉・,
                  hintText: '邁｡蜊倥↑閾ｪ蟾ｱ邏ｹ莉九ｒ蜈･蜉帙＠縺ｦ縺上□縺輔＞',
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
            child: const Text('繧ｭ繝｣繝ｳ繧ｻ繝ｫ'),
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
                    SnackBar(content: Text(nameResult.details ?? '荳埼←蛻・↑繝九ャ繧ｯ繝阪・繝縺ｧ縺・)),
                  );
                  return;
                }
              }
              
              if (bio.isNotEmpty) {
                final bioResult = ContentModerationService.moderateText(bio);
                if (bioResult.isBlocked) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(bioResult.details ?? '荳埼←蛻・↑閾ｪ蟾ｱ邏ｹ莉九〒縺・)),
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
                    const SnackBar(content: Text('繝励Ο繝輔ぅ繝ｼ繝ｫ繧呈峩譁ｰ縺励∪縺励◆')),
                  );
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('繝励Ο繝輔ぅ繝ｼ繝ｫ縺ｮ譖ｴ譁ｰ縺ｫ螟ｱ謨励＠縺ｾ縺励◆')),
                );
              }
            },
            child: const Text('菫晏ｭ・),
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
                  '繝繝溘・繝・・繧ｿ繝｢繝ｼ繝・,
                  style: tokens.titleSmall.copyWith(
                    color: tokens.accentWarning,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: tokens.spacing(2)),
            Text(
              '繝繝溘・繝・・繧ｿ繝｢繝ｼ繝峨′譛牙柑縺ｫ縺ｪ縺｣縺ｦ縺・∪縺吶ょｮ滄圀縺ｮ繝・・繧ｿ繧剃ｽｿ逕ｨ縺吶ｋ縺ｫ縺ｯ縲∽ｸ九・繝懊ち繝ｳ繧呈款縺励※繝繝溘・繝・・繧ｿ繧呈彫蜴ｻ縺励※縺上□縺輔＞縲・,
              style: tokens.bodyMedium.copyWith(color: tokens.textMuted),
            ),
            SizedBox(height: tokens.spacing(3)),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _removeDummyData(context, ref),
                icon: const Icon(Icons.cleaning_services),
                label: const Text('繝繝溘・繝・・繧ｿ繧呈彫蜴ｻ'),
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
        title: const Text('繝繝溘・繝・・繧ｿ謦､蜴ｻ'),
        content: const Text(
          '繝繝溘・繝・・繧ｿ繝｢繝ｼ繝峨ｒ辟｡蜉ｹ縺ｫ縺励※縲∝ｮ滄圀縺ｮ繝・・繧ｿ繧剃ｽｿ逕ｨ縺励∪縺吶°・・
          '縺薙・謫堺ｽ懊↓繧医ｊ縲√☆縺ｹ縺ｦ縺ｮ讖溯・縺悟ｮ滄圀縺ｮ繝・・繧ｿ縺ｧ蜍穂ｽ懊☆繧九ｈ縺・↓縺ｪ繧翫∪縺吶・,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('繧ｭ繝｣繝ｳ繧ｻ繝ｫ'),
          ),
          TextButton(
            onPressed: () async {
              // Disable dummy data mode
              ref.read(dummyDataModeProvider.notifier).state = false;
              await ref.read(localPreferencesServiceProvider).setDummyDataMode(false);
              
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('繝繝溘・繝・・繧ｿ繝｢繝ｼ繝峨ｒ辟｡蜉ｹ縺ｫ縺励∪縺励◆縲ょｮ滄圀縺ｮ繝・・繧ｿ縺ｧ蜍穂ｽ懊＠縺ｾ縺吶・),
                ),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('謦､蜴ｻ縺吶ｋ'),
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
        ? ['鄙呈・蛹・, '繝ｩ繝ｳ繝九Φ繧ｰ', '隱ｭ譖ｸ', '譌ｩ襍ｷ縺・]
        : user?.tags ?? ['鄙呈・蛹・];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '繧ｿ繧ｰ',
          style: tokens.titleMedium.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: tags.map((tag) => Chip(
            label: Text(tag),
            backgroundColor: tokens.brandPrimary.withValues(alpha: 0.1),
            labelStyle: tokens.bodySmall.copyWith(color: tokens.brandPrimary),
          ),).toList(),
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
                  Text('繧ｹ繝医Μ繝ｼ繧ｯ', style: tokens.bodyMedium.copyWith(color: tokens.textMuted)),
                  const SizedBox(height: 8),
                  streakAsync.when(
                    data: (streak) => Text(
                      '$streak譌･',
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
                  Text('莉頑律縺ｮ螳御ｺ・, style: tokens.bodyMedium.copyWith(color: tokens.textMuted)),
                  const SizedBox(height: 8),
                  todayCountAsync.when(
                    data: (count) => Text(
                      '$count蛟・,
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
          '繧｢繧ｫ繧ｦ繝ｳ繝郁ｨｭ螳・,
          style: tokens.titleMedium.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ListTile(
          leading: const Icon(Icons.notifications),
          title: const Text('騾夂衍險ｭ螳・),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            // Navigate to notification settings
          },
        ),
        ListTile(
          leading: const Icon(Icons.privacy_tip),
          title: const Text('繝励Λ繧､繝舌す繝ｼ險ｭ螳・),
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
          'SNS蜈ｱ譛・,
          style: tokens.titleMedium.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ElevatedButton.icon(
          onPressed: () {
            // Implement SNS sharing
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('SNS蜈ｱ譛画ｩ溯・縺ｯ貅門ｙ荳ｭ縺ｧ縺・)),
            );
          },
          icon: const Icon(Icons.share),
          label: const Text('騾ｲ謐励ｒ蜈ｱ譛・),
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
          '繝壹い諠・ｱ',
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
                      const Text('繝壹い縺瑚ｦ九▽縺九ｊ縺ｾ縺帙ｓ'),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () {
                          // Navigate to pair screen
                        },
                        child: const Text('繝壹い繧呈爾縺・),
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
                title: Text('繝壹い: ${pair.id}'),
                subtitle: const Text('荳邱偵↓鬆大ｼｵ縺｣縺ｦ縺・∪縺・),
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
              child: Text('繝壹い諠・ｱ縺ｮ隱ｭ縺ｿ霎ｼ縺ｿ縺ｫ螟ｱ謨励＠縺ｾ縺励◆'),
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
          '縺昴・莉・,
          style: tokens.titleMedium.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ListTile(
          leading: const Icon(Icons.help),
          title: const Text('繝倥Ν繝・),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            // Navigate to help
          },
        ),
        ListTile(
          leading: const Icon(Icons.info),
          title: const Text('繧｢繝励Μ縺ｫ縺､縺・※'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            // Navigate to about
          },
        ),
        ListTile(
          leading: const Icon(Icons.logout),
          title: const Text('繝ｭ繧ｰ繧｢繧ｦ繝・),
          onTap: () async {
            final confirmed = await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('繝ｭ繧ｰ繧｢繧ｦ繝・),
                content: const Text('繝ｭ繧ｰ繧｢繧ｦ繝医＠縺ｾ縺吶°・・),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('繧ｭ繝｣繝ｳ繧ｻ繝ｫ'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: const Text('繝ｭ繧ｰ繧｢繧ｦ繝・),
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
          '繝励Ξ繝溘い繝讖溯・',
          style: tokens.titleMedium.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const Icon(Icons.star, size: 48, color: Colors.amber),
                const SizedBox(height: 8),
                const Text('繝励Ξ繝溘い繝讖溯・縺ｯ貅門ｙ荳ｭ縺ｧ縺・),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () {
                    // Navigate to premium features
                  },
                  child: const Text('隧ｳ邏ｰ繧定ｦ九ｋ'),
                ),
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
      backgroundColor: tokens.brandPrimary.withValues(alpha: 0.1),
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
        gradient: isGradient
            ? const LinearGradient(
                colors: [Color(0xFF833AB4), Color(0xFFFD1D1D), Color(0xFFFCAF45)],
              )
            : null,
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.share, color: Colors.white, size: 24),
    );
  }
}