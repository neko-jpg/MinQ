import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:minq/core/animations/animation_system.dart';
import 'package:minq/l10n/l10n.dart';
import 'package:minq/presentation/theme/minq_theme.dart';

/// アニメーション設定画面（アクセシビリティ対応）
class AnimationSettingsScreen extends ConsumerStatefulWidget {
  const AnimationSettingsScreen({super.key});

  @override
  ConsumerState<AnimationSettingsScreen> createState() =>
      _AnimationSettingsScreenState();
}

class _AnimationSettingsScreenState
    extends ConsumerState<AnimationSettingsScreen> {
  final AnimationSystem _animationSystem = AnimationSystem.instance;

  bool _animationsEnabled = true;
  bool _reducedMotion = false;
  bool _hapticFeedbackEnabled = true;
  bool _soundEffectsEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  void _loadSettings() {
    setState(() {
      _animationsEnabled = _animationSystem.animationsEnabled;
      _reducedMotion = _animationSystem.reducedMotion;
      _hapticFeedbackEnabled = _animationSystem.hapticFeedbackEnabled;
      _soundEffectsEnabled = _animationSystem.soundEffectsEnabled;
    });
  }

  Future<void> _updateSettings() async {
    await _animationSystem.updateAnimationSettings(
      animationsEnabled: _animationsEnabled,
      reducedMotion: _reducedMotion,
      hapticFeedbackEnabled: _hapticFeedbackEnabled,
      soundEffectsEnabled: _soundEffectsEnabled,
    );
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.animationSettings),
        backgroundColor: tokens.surface,
        foregroundColor: tokens.textPrimary,
      ),
      body: ListView(
        padding: EdgeInsets.all(tokens.spacing.md),
        children: [
          // アニメーション設定セクション
          _buildSectionHeader(
            context,
            l10n.animationSettingsTitle,
            l10n.animationSettingsDescription,
          ),

          _buildSettingCard(
            context,
            title: l10n.enableAnimations,
            subtitle: l10n.enableAnimationsDescription,
            value: _animationsEnabled,
            onChanged: (value) {
              setState(() {
                _animationsEnabled = value;
              });
              _updateSettings();
            },
            icon: Icons.animation,
          ),

          _buildSettingCard(
            context,
            title: l10n.reducedMotion,
            subtitle: l10n.reducedMotionDescription,
            value: _reducedMotion,
            onChanged: (value) {
              setState(() {
                _reducedMotion = value;
              });
              _updateSettings();
            },
            icon: Icons.accessibility,
          ),

          SizedBox(height: tokens.spacing.lg),

          // フィードバック設定セクション
          _buildSectionHeader(
            context,
            l10n.feedbackSettings,
            l10n.feedbackSettingsDescription,
          ),

          _buildSettingCard(
            context,
            title: l10n.hapticFeedback,
            subtitle: l10n.hapticFeedbackDescription,
            value: _hapticFeedbackEnabled,
            onChanged: (value) {
              setState(() {
                _hapticFeedbackEnabled = value;
              });
              _updateSettings();

              // テスト用ハプティック
              if (value) {
                _animationSystem.playMicroInteractionHaptic();
              }
            },
            icon: Icons.vibration,
          ),

          _buildSettingCard(
            context,
            title: l10n.soundEffects,
            subtitle: l10n.soundEffectsDescription,
            value: _soundEffectsEnabled,
            onChanged: (value) {
              setState(() {
                _soundEffectsEnabled = value;
              });
              _updateSettings();
            },
            icon: Icons.volume_up,
          ),

          SizedBox(height: tokens.spacing.lg),

          // プレビューセクション
          _buildSectionHeader(
            context,
            l10n.animationPreview,
            l10n.animationPreviewDescription,
          ),

          _buildPreviewCard(context),

          SizedBox(height: tokens.spacing.xl),

          // 注意事項
          _buildInfoCard(context),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context,
    String title,
    String description,
  ) {
    final tokens = context.tokens;

    return Padding(
      padding: EdgeInsets.only(bottom: tokens.spacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: tokens.typography.h3.copyWith(
              color: tokens.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: tokens.spacing.xs),
          Text(
            description,
            style: tokens.typography.bodyMedium.copyWith(
              color: tokens.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required IconData icon,
  }) {
    final tokens = context.tokens;

    return Card(
      margin: EdgeInsets.only(bottom: tokens.spacing.sm),
      child: ListTile(
        leading: Icon(icon, color: tokens.primary),
        title: Text(
          title,
          style: tokens.typography.bodyLarge.copyWith(
            color: tokens.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: tokens.typography.bodySmall.copyWith(
            color: tokens.textSecondary,
          ),
        ),
        trailing: Switch(
          value: value,
          onChanged: onChanged,
          activeThumbColor: tokens.primary,
        ),
        onTap: () => onChanged(!value),
      ),
    );
  }

  Widget _buildPreviewCard(BuildContext context) {
    final tokens = context.tokens;
    final l10n = context.l10n;

    return Card(
      child: Padding(
        padding: EdgeInsets.all(tokens.spacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.testAnimations,
              style: tokens.typography.bodyLarge.copyWith(
                color: tokens.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: tokens.spacing.md),

            // アニメーションテストボタン
            Wrap(
              spacing: tokens.spacing.sm,
              runSpacing: tokens.spacing.sm,
              children: [
                _buildTestButton(
                  context,
                  l10n.testFadeIn,
                  Icons.fade_in,
                  () => _testFadeInAnimation(),
                ),
                _buildTestButton(
                  context,
                  l10n.testSlideIn,
                  Icons.slide_in,
                  () => _testSlideInAnimation(),
                ),
                _buildTestButton(
                  context,
                  l10n.testScale,
                  Icons.zoom_in,
                  () => _testScaleAnimation(),
                ),
                _buildTestButton(
                  context,
                  l10n.testHaptic,
                  Icons.vibration,
                  () => _animationSystem.playSuccessHaptic(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTestButton(
    BuildContext context,
    String label,
    IconData icon,
    VoidCallback onPressed,
  ) {
    final tokens = context.tokens;

    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 16),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: tokens.primary,
        foregroundColor: tokens.onPrimary,
        padding: EdgeInsets.symmetric(
          horizontal: tokens.spacing.sm,
          vertical: tokens.spacing.xs,
        ),
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context) {
    final tokens = context.tokens;
    final l10n = context.l10n;

    return Card(
      color: tokens.info.withOpacity(0.1),
      child: Padding(
        padding: EdgeInsets.all(tokens.spacing.md),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.info_outline, color: tokens.info, size: 20),
            SizedBox(width: tokens.spacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.accessibilityNote,
                    style: tokens.typography.bodyMedium.copyWith(
                      color: tokens.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: tokens.spacing.xs),
                  Text(
                    l10n.accessibilityNoteDescription,
                    style: tokens.typography.bodySmall.copyWith(
                      color: tokens.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _testFadeInAnimation() {
    showDialog(
      context: context,
      builder:
          (context) => _AnimationTestDialog(
            title: context.l10n.testFadeIn,
            child: _FadeInTestWidget(),
          ),
    );
  }

  void _testSlideInAnimation() {
    showDialog(
      context: context,
      builder:
          (context) => _AnimationTestDialog(
            title: context.l10n.testSlideIn,
            child: _SlideInTestWidget(),
          ),
    );
  }

  void _testScaleAnimation() {
    showDialog(
      context: context,
      builder:
          (context) => _AnimationTestDialog(
            title: context.l10n.testScale,
            child: _ScaleTestWidget(),
          ),
    );
  }
}

/// アニメーションテストダイアログ
class _AnimationTestDialog extends StatelessWidget {
  final String title;
  final Widget child;

  const _AnimationTestDialog({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return AlertDialog(
      title: Text(title),
      content: SizedBox(width: 200, height: 200, child: Center(child: child)),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(context.l10n.close),
        ),
      ],
    );
  }
}

/// フェードインテストウィジェット
class _FadeInTestWidget extends StatefulWidget {
  @override
  State<_FadeInTestWidget> createState() => _FadeInTestWidgetState();
}

class _FadeInTestWidgetState extends State<_FadeInTestWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: AnimationSystem.instance.getDuration(
        const Duration(milliseconds: 1000),
      ),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: AnimationSystem.instance.getCurve(Curves.easeIn),
      ),
    );

    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: context.tokens.primary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.star, color: Colors.white, size: 50),
          ),
        );
      },
    );
  }
}

/// スライドインテストウィジェット
class _SlideInTestWidget extends StatefulWidget {
  @override
  State<_SlideInTestWidget> createState() => _SlideInTestWidgetState();
}

class _SlideInTestWidgetState extends State<_SlideInTestWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: AnimationSystem.instance.getDuration(
        const Duration(milliseconds: 1000),
      ),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: AnimationSystem.instance.getCurve(Curves.easeOut),
      ),
    );

    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          color: context.tokens.secondary,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.arrow_upward, color: Colors.white, size: 50),
      ),
    );
  }
}

/// スケールテストウィジェット
class _ScaleTestWidget extends StatefulWidget {
  @override
  State<_ScaleTestWidget> createState() => _ScaleTestWidgetState();
}

class _ScaleTestWidgetState extends State<_ScaleTestWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: AnimationSystem.instance.getDuration(
        const Duration(milliseconds: 1000),
      ),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: AnimationSystem.instance.getCurve(Curves.elasticOut),
      ),
    );

    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: context.tokens.tertiary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.zoom_in, color: Colors.white, size: 50),
          ),
        );
      },
    );
  }
}
