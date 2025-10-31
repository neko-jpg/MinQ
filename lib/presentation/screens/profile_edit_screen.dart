import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:minq/core/profile/avatar_service.dart';
import 'package:minq/core/profile/profile_service.dart';
import 'package:minq/data/providers.dart';
import 'package:minq/domain/user/user_profile.dart';
import 'package:minq/presentation/theme/minq_theme.dart';
import 'package:minq/presentation/widgets/common/offline_indicator.dart';

/// Comprehensive profile editing screen with offline support
class ProfileEditScreen extends ConsumerStatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  ConsumerState<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends ConsumerState<ProfileEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _displayNameController = TextEditingController();
  final _handleController = TextEditingController();
  final _bioController = TextEditingController();
  
  List<String> _selectedTags = [];
  String _selectedAvatarSeed = 'seed-01';
  String _selectedPrivacy = 'public';
  bool _isSaving = false;
  bool _hasUnsavedChanges = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadProfile());
    
    // Listen for changes to track unsaved state
    _displayNameController.addListener(_onFieldChanged);
    _handleController.addListener(_onFieldChanged);
    _bioController.addListener(_onFieldChanged);
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _handleController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  void _onFieldChanged() {
    if (!_hasUnsavedChanges) {
      setState(() => _hasUnsavedChanges = true);
    }
  }

  Future<void> _loadProfile() async {
    final user = await ref.read(localUserProvider.future);
    if (!mounted || user == null) return;

    setState(() {
      _displayNameController.text = user.displayName;
      _handleController.text = user.handle ?? '';
      _bioController.text = user.bio;
      _selectedAvatarSeed = user.avatarSeed.isEmpty ? 'seed-01' : user.avatarSeed;
      _selectedTags = List.from(user.focusTags);
      _selectedPrivacy = user.privacy;
      _hasUnsavedChanges = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final networkStatus = ref.watch(networkStatusProvider);

    return PopScope(
      canPop: !_hasUnsavedChanges,
      onPopInvoked: (didPop) {
        if (!didPop && _hasUnsavedChanges) {
          _showUnsavedChangesDialog();
        }
      },
      child: Scaffold(
        backgroundColor: tokens.background,
        appBar: AppBar(
          title: Text(
            'プロフィール編集',
            style: tokens.typography.h4.copyWith(
              color: tokens.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: tokens.surface,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => _handleBackPress(),
          ),
          actions: [
            TextButton(
              onPressed: _isSaving ? null : _saveProfile,
              child: _isSaving
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(
                      '保存',
                      style: TextStyle(
                        color: _hasUnsavedChanges 
                            ? tokens.primary 
                            : tokens.textMuted,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ],
        ),
        body: Column(
          children: [
            // Offline indicator
            if (networkStatus == NetworkStatus.offline)
              const OfflineIndicator(),
            
            Expanded(
              child: Form(
                key: _formKey,
                child: ListView(
                  padding: EdgeInsets.all(tokens.spacing.lg),
                  children: [
                    // Avatar section
                    _buildAvatarSection(tokens),
                    SizedBox(height: tokens.spacing.xl),
                    
                    // Basic info section
                    _buildBasicInfoSection(tokens),
                    SizedBox(height: tokens.spacing.xl),
                    
                    // Focus tags section
                    _buildFocusTagsSection(tokens),
                    SizedBox(height: tokens.spacing.xl),
                    
                    // Privacy section
                    _buildPrivacySection(tokens),
                    SizedBox(height: tokens.spacing.xl),
                    
                    // Advanced options
                    _buildAdvancedSection(tokens),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarSection(MinqTheme tokens) {
    return _SectionCard(
      title: 'アバター',
      subtitle: 'プロフィール画像を選択してください',
      child: Column(
        children: [
          // Current avatar preview
          Center(
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: tokens.border, width: 2),
              ),
              child: ClipOval(
                child: _buildAvatarPreview(_selectedAvatarSeed, tokens),
              ),
            ),
          ),
          SizedBox(height: tokens.spacing.md),
          
          // Avatar options
          Text(
            'アバターを選択',
            style: tokens.typography.bodySmall.copyWith(
              color: tokens.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: tokens.spacing.sm),
          
          // Avatar grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 5,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: AvatarService.getPredefinedSeeds().length,
            itemBuilder: (context, index) {
              final seed = AvatarService.getPredefinedSeeds()[index];
              final isSelected = seed == _selectedAvatarSeed;
              
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedAvatarSeed = seed;
                    _hasUnsavedChanges = true;
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? tokens.primary : tokens.border,
                      width: isSelected ? 3 : 1,
                    ),
                  ),
                  child: ClipOval(
                    child: _buildAvatarPreview(seed, tokens),
                  ),
                ),
              );
            },
          ),
          
          SizedBox(height: tokens.spacing.md),
          
          // Generate random avatar button
          OutlinedButton.icon(
            onPressed: () {
              setState(() {
                _selectedAvatarSeed = AvatarService.generateRandomSeed();
                _hasUnsavedChanges = true;
              });
            },
            icon: const Icon(Icons.shuffle),
            label: const Text('ランダム生成'),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarPreview(String seed, MinqTheme tokens) {
    final displayName = _displayNameController.text.trim();
    
    return Image.network(
      AvatarService.getAvatarUrl(seed),
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        // Fallback to initials avatar
        final initials = AvatarService.getInitials(displayName.isEmpty ? 'User' : displayName);
        final color = Color(AvatarService.getInitialsColor(seed));
        
        return Container(
          color: color,
          child: Center(
            child: Text(
              initials,
              style: tokens.typography.h3.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      },
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          color: tokens.surfaceVariant,
          child: const Center(
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        );
      },
    );
  }

  Widget _buildBasicInfoSection(MinqTheme tokens) {
    return _SectionCard(
      title: '基本情報',
      subtitle: 'プロフィールの基本情報を入力してください',
      child: Column(
        children: [
          TextFormField(
            controller: _displayNameController,
            decoration: const InputDecoration(
              labelText: '表示名',
              hintText: '例: 田中太郎',
              prefixIcon: Icon(Icons.person),
            ),
            textCapitalization: TextCapitalization.words,
            validator: (value) {
              final trimmed = value?.trim() ?? '';
              if (trimmed.isEmpty) {
                return '表示名を入力してください';
              }
              if (trimmed.length < 2) {
                return '表示名は2文字以上で入力してください';
              }
              if (trimmed.length > 30) {
                return '表示名は30文字以内で入力してください';
              }
              return null;
            },
          ),
          SizedBox(height: tokens.spacing.md),
          
          TextFormField(
            controller: _handleController,
            decoration: const InputDecoration(
              labelText: 'ユーザーID（任意）',
              hintText: '例: tanaka_taro',
              prefixText: '@',
              prefixIcon: Icon(Icons.alternate_email),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) return null;
              
              final trimmed = value.trim();
              final pattern = RegExp(r'^[a-zA-Z0-9_]{3,20}$');
              if (!pattern.hasMatch(trimmed)) {
                return '3-20文字の英数字とアンダースコアのみ使用可能';
              }
              return null;
            },
          ),
          SizedBox(height: tokens.spacing.md),
          
          TextFormField(
            controller: _bioController,
            decoration: const InputDecoration(
              labelText: '自己紹介（任意）',
              hintText: '簡単な自己紹介を入力してください',
              prefixIcon: Icon(Icons.description),
            ),
            maxLines: 3,
            maxLength: 160,
            validator: (value) {
              if (value != null && value.length > 160) {
                return '自己紹介は160文字以内で入力してください';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFocusTagsSection(MinqTheme tokens) {
    final profileService = ProfileService(
      isar: ref.read(isarProvider),
      syncQueueManager: ref.read(syncQueueManagerProvider),
    );
    final availableTags = profileService.getAvailableFocusTags();

    return _SectionCard(
      title: 'フォーカスタグ',
      subtitle: '興味のある分野を最大5つまで選択してください',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '選択済み: ${_selectedTags.length}/5',
            style: tokens.typography.bodySmall.copyWith(
              color: tokens.textSecondary,
            ),
          ),
          SizedBox(height: tokens.spacing.sm),
          
          Wrap(
            spacing: tokens.spacing.sm,
            runSpacing: tokens.spacing.sm,
            children: availableTags.map((tag) {
              final isSelected = _selectedTags.contains(tag);
              final canSelect = _selectedTags.length < 5 || isSelected;
              
              return FilterChip(
                label: Text(tag),
                selected: isSelected,
                onSelected: canSelect ? (selected) {
                  setState(() {
                    if (selected) {
                      _selectedTags.add(tag);
                    } else {
                      _selectedTags.remove(tag);
                    }
                    _hasUnsavedChanges = true;
                  });
                } : null,
                backgroundColor: tokens.surface,
                selectedColor: tokens.primary.withOpacity(0.2),
                checkmarkColor: tokens.primary,
                labelStyle: TextStyle(
                  color: isSelected ? tokens.primary : tokens.textPrimary,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildPrivacySection(MinqTheme tokens) {
    return _SectionCard(
      title: 'プライバシー設定',
      subtitle: 'プロフィールの公開範囲を選択してください',
      child: Column(
        children: [
          RadioListTile<String>(
            title: const Text('公開'),
            subtitle: const Text('すべてのユーザーに公開'),
            value: 'public',
            groupValue: _selectedPrivacy,
            onChanged: (value) {
              setState(() {
                _selectedPrivacy = value!;
                _hasUnsavedChanges = true;
              });
            },
          ),
          RadioListTile<String>(
            title: const Text('フレンドのみ'),
            subtitle: const Text('ペアとフレンドにのみ公開'),
            value: 'friends',
            groupValue: _selectedPrivacy,
            onChanged: (value) {
              setState(() {
                _selectedPrivacy = value!;
                _hasUnsavedChanges = true;
              });
            },
          ),
          RadioListTile<String>(
            title: const Text('非公開'),
            subtitle: const Text('自分のみ表示'),
            value: 'private',
            groupValue: _selectedPrivacy,
            onChanged: (value) {
              setState(() {
                _selectedPrivacy = value!;
                _hasUnsavedChanges = true;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAdvancedSection(MinqTheme tokens) {
    return _SectionCard(
      title: '詳細設定',
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text('通知設定'),
            subtitle: const Text('通知の詳細設定'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // Navigate to notification settings
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('通知設定は準備中です')),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.download),
            title: const Text('データエクスポート'),
            subtitle: const Text('プロフィールデータをエクスポート'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // Export profile data
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('データエクスポート機能は準備中です')),
              );
            },
          ),
        ],
      ),
    );
  }

  void _handleBackPress() {
    if (_hasUnsavedChanges) {
      _showUnsavedChangesDialog();
    } else {
      context.pop();
    }
  }

  void _showUnsavedChangesDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('未保存の変更があります'),
        content: const Text('変更を保存せずに戻りますか？変更内容は失われます。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.pop();
            },
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('破棄して戻る'),
          ),
        ],
      ),
    );
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final uid = ref.read(uidProvider);
    if (uid == null) {
      _showErrorSnackBar('ユーザー情報を取得できませんでした');
      return;
    }

    setState(() => _isSaving = true);

    try {
      final profileService = ProfileService(
        isar: ref.read(isarProvider),
        syncQueueManager: ref.read(syncQueueManagerProvider),
      );

      final request = ProfileUpdateRequest(
        displayName: _displayNameController.text.trim(),
        handle: _handleController.text.trim(),
        bio: _bioController.text.trim(),
        avatarSeed: _selectedAvatarSeed,
        focusTags: _selectedTags,
        privacy: _selectedPrivacy,
      );

      final result = await profileService.updateProfile(uid, request);

      if (!mounted) return;

      if (result.isValid) {
        ref.invalidate(localUserProvider);
        setState(() => _hasUnsavedChanges = false);
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('プロフィールを保存しました'),
            backgroundColor: Colors.green,
          ),
        );
        
        context.pop();
      } else {
        _showValidationErrors(result.errors);
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('プロフィールの保存に失敗しました');
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  void _showValidationErrors(Map<String, String> errors) {
    final errorMessage = errors.values.join('\n');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(errorMessage),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.child,
    this.subtitle,
  });

  final String title;
  final String? subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Container(
      padding: EdgeInsets.all(tokens.spacing.lg),
      decoration: BoxDecoration(
        color: tokens.surface,
        borderRadius: BorderRadius.circular(tokens.radius.lg),
        boxShadow: tokens.shadow.soft,
        border: Border.all(color: tokens.border.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: tokens.typography.h4.copyWith(
              color: tokens.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (subtitle != null) ...[
            SizedBox(height: tokens.spacing.xs),
            Text(
              subtitle!,
              style: tokens.typography.bodySmall.copyWith(
                color: tokens.textSecondary,
              ),
            ),
          ],
          SizedBox(height: tokens.spacing.md),
          child,
        ],
      ),
    );
  }
}