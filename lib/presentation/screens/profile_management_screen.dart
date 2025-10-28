import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:minq/data/providers.dart';
import 'package:minq/l10n/app_localizations.dart';
import 'package:minq/presentation/theme/minq_theme.dart';

class ProfileManagementScreen extends ConsumerStatefulWidget {
  const ProfileManagementScreen({super.key});

  @override
  ConsumerState<ProfileManagementScreen> createState() => _ProfileManagementScreenState();
}

class _ProfileManagementScreenState extends ConsumerState<ProfileManagementScreen> {
  final _nicknameController = TextEditingController();
  final _goalController = TextEditingController();
  String _selectedAvatar = '😊';
  final List<String> _availableAvatars = [
    '😊', '🌟', '💪', '🎯', '🚀', '🌱', '⚡', '🔥',
    '🎨', '📚', '🏃', '🧘', '🎵', '🌈', '💎', '🦋'
  ];

  final List<String> _selectedTags = [];
  final List<String> _availableTags = [
    '健康', '運動', '学習', '仕事', '趣味', '家族',
    '友人', '読書', '料理', '音楽', '旅行', '瞑想',
    '早起き', '節約', '掃除', '日記'
  ];

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    _goalController.dispose();
    super.dispose();
  }

  Future<void> _loadUserProfile() async {
    // TODO: Load actual user profile data
    _nicknameController.text = 'ユーザー';
    _goalController.text = '毎日の習慣を継続して、より良い自分になる';
    _selectedTags.addAll(['健康', '運動', '学習']);
  }

  Future<void> _saveProfile() async {
    if (_nicknameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ニックネームを入力してください')),
      );
      return;
    }

    // TODO: Save profile data to repository
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('プロフィールを保存しました')),
    );

    if (mounted) {
      context.pop();
    }
  }

  void _toggleTag(String tag) {
    setState(() {
      if (_selectedTags.contains(tag)) {
        _selectedTags.remove(tag);
      } else {
        _selectedTags.add(tag);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: tokens.surface,
      appBar: AppBar(
        title: Text(
          'プロフィール管理',
          style: tokens.typography.h4.copyWith(
            color: tokens.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          TextButton(
            onPressed: _saveProfile,
            child: Text(
              '保存',
              style: tokens.typography.body.copyWith(
                color: tokens.brandPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
        backgroundColor: tokens.surface.withAlpha(204),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(tokens.spacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar Selection
            _ProfileSection(
              title: 'アバター',
              child: Container(
                padding: EdgeInsets.all(tokens.spacing.md),
                decoration: BoxDecoration(
                  color: tokens.surface,
                  borderRadius: BorderRadius.circular(tokens.radius.lg),
                  border: Border.all(color: tokens.border),
                ),
                child: Column(
                  children: [
                    // Current Avatar
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: tokens.brandPrimary.withAlpha(25),
                        borderRadius: BorderRadius.circular(tokens.radius.xl),
                      ),
                      child: Center(
                        child: Text(
                          _selectedAvatar,
                          style: const TextStyle(fontSize: 40),
                        ),
                      ),
                    ),
                    SizedBox(height: tokens.spacing.md),
                    // Avatar Grid
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 8,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                      ),
                      itemCount: _availableAvatars.length,
                      itemBuilder: (context, index) {
                        final avatar = _availableAvatars[index];
                        final isSelected = avatar == _selectedAvatar;
                        return GestureDetector(
                          onTap: () => setState(() => _selectedAvatar = avatar),
                          child: Container(
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? tokens.brandPrimary.withAlpha(50)
                                  : tokens.surface,
                              borderRadius: BorderRadius.circular(tokens.radius.md),
                              border: Border.all(
                                color: isSelected
                                    ? tokens.brandPrimary
                                    : tokens.border,
                                width: isSelected ? 2 : 1,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                avatar,
                                style: const TextStyle(fontSize: 20),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: tokens.spacing.lg),

            // Nickname
            _ProfileSection(
              title: 'ニックネーム',
              child: TextField(
                controller: _nicknameController,
                decoration: InputDecoration(
                  hintText: 'ニックネームを入力',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(tokens.radius.lg),
                    borderSide: BorderSide(color: tokens.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(tokens.radius.lg),
                    borderSide: BorderSide(color: tokens.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(tokens.radius.lg),
                    borderSide: BorderSide(color: tokens.brandPrimary, width: 2),
                  ),
                  filled: true,
                  fillColor: tokens.surface,
                  contentPadding: EdgeInsets.all(tokens.spacing.md),
                ),
                style: tokens.typography.body.copyWith(color: tokens.textPrimary),
              ),
            ),

            SizedBox(height: tokens.spacing.lg),

            // Goal Setting
            _ProfileSection(
              title: '目標設定',
              child: TextField(
                controller: _goalController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'あなたの目標を入力してください',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(tokens.radius.lg),
                    borderSide: BorderSide(color: tokens.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(tokens.radius.lg),
                    borderSide: BorderSide(color: tokens.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(tokens.radius.lg),
                    borderSide: BorderSide(color: tokens.brandPrimary, width: 2),
                  ),
                  filled: true,
                  fillColor: tokens.surface,
                  contentPadding: EdgeInsets.all(tokens.spacing.md),
                ),
                style: tokens.typography.body.copyWith(color: tokens.textPrimary),
              ),
            ),

            SizedBox(height: tokens.spacing.lg),

            // Tag Management
            _ProfileSection(
              title: '興味のあるタグ',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '最大8個まで選択できます',
                    style: tokens.typography.caption.copyWith(
                      color: tokens.textMuted,
                    ),
                  ),
                  SizedBox(height: tokens.spacing.md),
                  Wrap(
                    spacing: tokens.spacing.sm,
                    runSpacing: tokens.spacing.sm,
                    children: _availableTags.map((tag) {
                      final isSelected = _selectedTags.contains(tag);
                      final canSelect = _selectedTags.length < 8 || isSelected;

                      return GestureDetector(
                        onTap: canSelect ? () => _toggleTag(tag) : null,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: tokens.spacing.md,
                            vertical: tokens.spacing.sm,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? tokens.brandPrimary
                                : canSelect
                                    ? tokens.surface
                                    : tokens.textMuted.withAlpha(50),
                            borderRadius: BorderRadius.circular(tokens.radius.xl),
                            border: Border.all(
                              color: isSelected
                                  ? tokens.brandPrimary
                                  : tokens.border,
                            ),
                          ),
                          child: Text(
                            tag,
                            style: tokens.typography.caption.copyWith(
                              color: isSelected
                                  ? Colors.white
                                  : canSelect
                                      ? tokens.textPrimary
                                      : tokens.textMuted,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  SizedBox(height: tokens.spacing.sm),
                  Text(
                    '選択中: ${_selectedTags.length}/8',
                    style: tokens.typography.caption.copyWith(
                      color: tokens.textMuted,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: tokens.spacing.xl),

            // Save Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: tokens.brandPrimary,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: tokens.spacing.md),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(tokens.radius.lg),
                  ),
                  minimumSize: const Size(double.infinity, 44), // Minimum 44pt touch target
                ),
                child: Text(
                  'プロフィールを保存',
                  style: tokens.typography.body.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileSection extends StatelessWidget {
  const _ProfileSection({
    required this.title,
    required this.child,
  });

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: tokens.typography.h4.copyWith(
            color: tokens.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: tokens.spacing.md),
        child,
      ],
    );
  }
}