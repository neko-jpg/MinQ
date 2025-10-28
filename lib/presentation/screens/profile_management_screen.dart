import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:minq/presentation/theme/minq_tokens.dart';

class ProfileManagementScreen extends ConsumerStatefulWidget {
  const ProfileManagementScreen({super.key});

  @override
  ConsumerState<ProfileManagementScreen> createState() =>
      _ProfileManagementScreenState();
}

class _ProfileManagementScreenState
    extends ConsumerState<ProfileManagementScreen> {
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
    return Scaffold(
      backgroundColor: MinqTokens.surface,
      appBar: AppBar(
        title: Text(
          'プロフィール管理',
          style: MinqTokens.titleMedium.copyWith(
            color: MinqTokens.textPrimary,
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
              style: MinqTokens.bodyMedium.copyWith(
                color: MinqTokens.brandPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
        backgroundColor: Color.lerp(MinqTokens.surface, Colors.transparent, 0.2),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(MinqTokens.spacing(3)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar Selection
            _ProfileSection(
              title: 'アバター',
              child: Container(
                padding: EdgeInsets.all(MinqTokens.spacing(3)),
                decoration: BoxDecoration(
                  color: MinqTokens.surface,
                  borderRadius: MinqTokens.cornerLarge(),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Column(
                  children: [
                    // Current Avatar
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: MinqTokens.brandPrimary.withAlpha(25),
                        borderRadius:
                            BorderRadius.circular(MinqTokens.spacing(10)),
                      ),
                      child: Center(
                        child: Text(
                          _selectedAvatar,
                          style: const TextStyle(fontSize: 40),
                        ),
                      ),
                    ),
                    SizedBox(height: MinqTokens.spacing(3)),
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
                                  ? MinqTokens.brandPrimary.withAlpha(50)
                                  : MinqTokens.surface,
                              borderRadius: MinqTokens.cornerMedium(),
                              border: Border.all(
                                color: isSelected
                                    ? MinqTokens.brandPrimary
                                    : Colors.grey.shade300,
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

            SizedBox(height: MinqTokens.spacing(4)),

            // Nickname
            _ProfileSection(
              title: 'ニックネーム',
              child: TextField(
                controller: _nicknameController,
                decoration: InputDecoration(
                  hintText: 'ニックネームを入力',
                  border: OutlineInputBorder(
                    borderRadius: MinqTokens.cornerLarge(),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: MinqTokens.cornerLarge(),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: MinqTokens.cornerLarge(),
                    borderSide:
                        const BorderSide(color: MinqTokens.brandPrimary, width: 2),
                  ),
                  filled: true,
                  fillColor: MinqTokens.surface,
                  contentPadding: EdgeInsets.all(MinqTokens.spacing(3)),
                ),
                style: MinqTokens.bodyMedium.copyWith(color: MinqTokens.textPrimary),
              ),
            ),

            SizedBox(height: MinqTokens.spacing(4)),

            // Goal Setting
            _ProfileSection(
              title: '目標設定',
              child: TextField(
                controller: _goalController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'あなたの目標を入力してください',
                  border: OutlineInputBorder(
                    borderRadius: MinqTokens.cornerLarge(),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: MinqTokens.cornerLarge(),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: MinqTokens.cornerLarge(),
                    borderSide:
                        const BorderSide(color: MinqTokens.brandPrimary, width: 2),
                  ),
                  filled: true,
                  fillColor: MinqTokens.surface,
                  contentPadding: EdgeInsets.all(MinqTokens.spacing(3)),
                ),
                style: MinqTokens.bodyMedium.copyWith(color: MinqTokens.textPrimary),
              ),
            ),

            SizedBox(height: MinqTokens.spacing(4)),

            // Tag Management
            _ProfileSection(
              title: '興味のあるタグ',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '最大8個まで選択できます',
                    style: MinqTokens.bodySmall.copyWith(
                      color: MinqTokens.textSecondary,
                    ),
                  ),
                  SizedBox(height: MinqTokens.spacing(3)),
                  Wrap(
                    spacing: MinqTokens.spacing(2),
                    runSpacing: MinqTokens.spacing(2),
                    children: _availableTags.map((tag) {
                      final isSelected = _selectedTags.contains(tag);
                      final canSelect = _selectedTags.length < 8 || isSelected;

                      return GestureDetector(
                        onTap: canSelect ? () => _toggleTag(tag) : null,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: MinqTokens.spacing(3),
                            vertical: MinqTokens.spacing(2),
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? MinqTokens.brandPrimary
                                : canSelect
                                    ? MinqTokens.surface
                                    : MinqTokens.textSecondary.withAlpha(50),
                            borderRadius: MinqTokens.cornerLarge(),
                            border: Border.all(
                              color: isSelected
                                  ? MinqTokens.brandPrimary
                                  : Colors.grey.shade300,
                            ),
                          ),
                          child: Text(
                            tag,
                            style: MinqTokens.bodySmall.copyWith(
                              color: isSelected
                                  ? Colors.white
                                  : canSelect
                                      ? MinqTokens.textPrimary
                                      : MinqTokens.textSecondary,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  SizedBox(height: MinqTokens.spacing(2)),
                  Text(
                    '選択中: ${_selectedTags.length}/8',
                    style: MinqTokens.bodySmall.copyWith(
                      color: MinqTokens.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: MinqTokens.spacing(6)),

            // Save Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: MinqTokens.brandPrimary,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: MinqTokens.spacing(3)),
                  shape: RoundedRectangleBorder(
                    borderRadius: MinqTokens.cornerLarge(),
                  ),
                  minimumSize: const Size(
                      double.infinity, 44), // Minimum 44pt touch target
                ),
                child: Text(
                  'プロフィールを保存',
                  style: MinqTokens.bodyMedium.copyWith(
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: MinqTokens.titleMedium.copyWith(
            color: MinqTokens.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: MinqTokens.spacing(3)),
        child,
      ],
    );
  }
}
