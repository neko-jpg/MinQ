import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:minq/presentation/routing/navigation_extensions.dart';
import '../theme/app_theme.dart';

/// アクセシビリティ設定画面
/// 高齢者向けの特大UI・音声読み上げ速度などの設定
class AccessibilitySettingsScreen extends ConsumerStatefulWidget {
  const AccessibilitySettingsScreen({super.key});

  @override
  ConsumerState<AccessibilitySettingsScreen> createState() =>
      _AccessibilitySettingsScreenState();
}

class _AccessibilitySettingsScreenState
    extends ConsumerState<AccessibilitySettingsScreen> {
  double _textScale = 1.0;
  double _speechRate = 1.0;
  bool _highContrast = false;
  bool _reduceMotion = false;
  bool _boldText = false;
  bool _largeButtons = false;
  bool _simplifiedUI = false;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Scaffold(
      backgroundColor: tokens.background,
      appBar: AppBar(
        title: Text(
          'アクセシビリティ',
          style: tokens.typography.h3.copyWith(
            color: tokens.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.safePop(),
        ),
        backgroundColor: tokens.background.withOpacity(0.9),
        elevation: 0,
      ),
      body: ListView(
        padding: EdgeInsets.all(tokens.spacing.lg),
        children: [
          // 視覚設定
          _buildSection(
            title: '視覚設定',
            icon: Icons.visibility,
            tokens: tokens,
            children: [
              _buildSliderTile(
                title: 'テキストサイズ',
                subtitle: '文字の大きさを調整',
                value: _textScale,
                min: 0.8,
                max: 2.0,
                divisions: 12,
                onChanged: (value) => setState(() => _textScale = value),
                valueLabel: '${(_textScale * 100).toInt()}%',
                tokens: tokens,
              ),
              _buildSwitchTile(
                title: '太字テキスト',
                subtitle: 'すべてのテキストを太字で表示',
                value: _boldText,
                onChanged: (value) => setState(() => _boldText = value),
                tokens: tokens,
              ),
              _buildSwitchTile(
                title: '高コントラスト',
                subtitle: '色のコントラストを強調',
                value: _highContrast,
                onChanged: (value) => setState(() => _highContrast = value),
                tokens: tokens,
              ),
              _buildSwitchTile(
                title: '大きなボタン',
                subtitle: 'タップしやすい大きなボタン',
                value: _largeButtons,
                onChanged: (value) => setState(() => _largeButtons = value),
                tokens: tokens,
              ),
            ],
          ),
          SizedBox(height: tokens.spacing.xl),
          // 音声設定
          _buildSection(
            title: '音声設定',
            icon: Icons.record_voice_over,
            tokens: tokens,
            children: [
              _buildSliderTile(
                title: '読み上げ速度',
                subtitle: 'スクリーンリーダーの速度',
                value: _speechRate,
                min: 0.5,
                max: 2.0,
                divisions: 15,
                onChanged: (value) => setState(() => _speechRate = value),
                valueLabel: '${(_speechRate * 100).toInt()}%',
                tokens: tokens,
              ),
            ],
          ),
          SizedBox(height: tokens.spacing.xl),
          // モーション設定
          _buildSection(
            title: 'モーション設定',
            icon: Icons.animation,
            tokens: tokens,
            children: [
              _buildSwitchTile(
                title: 'アニメーションを減らす',
                subtitle: '画面の動きを最小限に',
                value: _reduceMotion,
                onChanged: (value) => setState(() => _reduceMotion = value),
                tokens: tokens,
              ),
            ],
          ),
          SizedBox(height: tokens.spacing.xl),
          // UI設定
          _buildSection(
            title: 'UI設定',
            icon: Icons.dashboard_customize,
            tokens: tokens,
            children: [
              _buildSwitchTile(
                title: 'シンプルUI',
                subtitle: '必要最小限の機能のみ表示',
                value: _simplifiedUI,
                onChanged: (value) => setState(() => _simplifiedUI = value),
                tokens: tokens,
              ),
            ],
          ),
          SizedBox(height: tokens.spacing.xl),
          // プレビュー
          _buildPreview(tokens),
          SizedBox(height: tokens.spacing.xl),
          // 保存ボタン
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _saveSettings,
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: tokens.spacing.lg),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(tokens.radius.full),
                ),
              ),
              child: Text(
                '設定を保存',
                style: tokens.typography.body.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required MinqTheme tokens,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: tokens.primary),
            SizedBox(width: tokens.spacing.sm),
            Text(
              title,
              style: tokens.typography.h4.copyWith(
                color: tokens.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        SizedBox(height: tokens.spacing.md),
        ...children,
      ],
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required MinqTheme tokens,
  }) {
    return Card(
      margin: EdgeInsets.only(bottom: tokens.spacing.sm),
      elevation: 0,
      color: tokens.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(tokens.radius.lg),
        side: BorderSide(color: tokens.border),
      ),
      child: SwitchListTile(
        title: Text(
          title,
          style: tokens.typography.body.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: tokens.typography.caption.copyWith(
            color: tokens.textSecondary,
          ),
        ),
        value: value,
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildSliderTile({
    required String title,
    required String subtitle,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required ValueChanged<double> onChanged,
    required String valueLabel,
    required MinqTheme tokens,
  }) {
    return Card(
      margin: EdgeInsets.only(bottom: tokens.spacing.sm),
      elevation: 0,
      color: tokens.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(tokens.radius.lg),
        side: BorderSide(color: tokens.border),
      ),
      child: Padding(
        padding: EdgeInsets.all(tokens.spacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: tokens.typography.body.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: tokens.typography.caption.copyWith(
                          color: tokens.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: tokens.spacing.sm,
                    vertical: tokens.spacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: tokens.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(tokens.radius.md),
                  ),
                  child: Text(
                    valueLabel,
                    style: tokens.typography.body.copyWith(
                      color: tokens.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            Slider(
              value: value,
              min: min,
              max: max,
              divisions: divisions,
              onChanged: onChanged,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreview(MinqTheme tokens) {
    return Container(
      padding: EdgeInsets.all(tokens.spacing.lg),
      decoration: BoxDecoration(
        color: _highContrast ? Colors.black : tokens.surface,
        borderRadius: BorderRadius.circular(tokens.radius.lg),
        border: Border.all(
          color: _highContrast ? Colors.white : tokens.border,
          width: _highContrast ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'プレビュー',
            style: tokens.typography.h4.copyWith(
              color: _highContrast ? Colors.white : tokens.textPrimary,
              fontWeight: _boldText ? FontWeight.bold : FontWeight.w600,
              fontSize: tokens.typography.h4.fontSize! * _textScale,
            ),
          ),
          SizedBox(height: tokens.spacing.md),
          Text(
            'これは設定のプレビューです。実際の表示を確認できます。',
            style: tokens.typography.body.copyWith(
              color: _highContrast ? Colors.white : tokens.textPrimary,
              fontWeight: _boldText ? FontWeight.w600 : FontWeight.normal,
              fontSize: tokens.typography.body.fontSize! * _textScale,
            ),
          ),
          SizedBox(height: tokens.spacing.md),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(
                horizontal: tokens.spacing.lg,
                vertical: _largeButtons ? tokens.spacing.lg : tokens.spacing.md,
              ),
            ),
            child: Text(
              'サンプルボタン',
              style: TextStyle(
                fontSize: 16 * _textScale,
                fontWeight: _boldText ? FontWeight.bold : FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _saveSettings() {
    // TODO: 設定を保存
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('設定を保存しました')),
    );
    context.safePop();
  }
}
