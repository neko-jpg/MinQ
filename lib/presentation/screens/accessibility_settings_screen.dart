import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:minq/presentation/theme/minq_theme.dart';

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
          style: tokens.typeScale.h3.copyWith(
            color: tokens.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        backgroundColor: tokens.background.withAlpha((255 * 0.9).round()),
        elevation: 0,
      ),
      body: ListView(
        padding: EdgeInsets.all(tokens.spaceLG),
        children: [
          // 視覚設定
          _buildSection(
            title: '視覚設定',
            icon: Icons.visibility,
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
              ),
              _buildSwitchTile(
                title: '太字テキスト',
                subtitle: 'すべてのテキストを太字で表示',
                value: _boldText,
                onChanged: (value) => setState(() => _boldText = value),
              ),
              _buildSwitchTile(
                title: '高コントラスト',
                subtitle: '色のコントラストを強調',
                value: _highContrast,
                onChanged: (value) => setState(() => _highContrast = value),
              ),
              _buildSwitchTile(
                title: '大きなボタン',
                subtitle: 'タップしやすい大きなボタン',
                value: _largeButtons,
                onChanged: (value) => setState(() => _largeButtons = value),
              ),
            ],
          ),
          SizedBox(height: tokens.spaceXL),
          // 音声設定
          _buildSection(
            title: '音声設定',
            icon: Icons.record_voice_over,
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
              ),
            ],
          ),
          SizedBox(height: tokens.spaceXL),
          // モーション設定
          _buildSection(
            title: 'モーション設定',
            icon: Icons.animation,
            children: [
              _buildSwitchTile(
                title: 'アニメーションを減らす',
                subtitle: '画面の動きを最小限に',
                value: _reduceMotion,
                onChanged: (value) => setState(() => _reduceMotion = value),
              ),
            ],
          ),
          SizedBox(height: tokens.spaceXL),
          // UI設定
          _buildSection(
            title: 'UI設定',
            icon: Icons.dashboard_customize,
            children: [
              _buildSwitchTile(
                title: 'シンプルUI',
                subtitle: '必要最小限の機能のみ表示',
                value: _simplifiedUI,
                onChanged: (value) => setState(() => _simplifiedUI = value),
              ),
            ],
          ),
          SizedBox(height: tokens.spaceXL),
          // プレビュー
          _buildPreview(),
          SizedBox(height: tokens.spaceXL),
          // 保存ボタン
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _saveSettings,
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: tokens.spaceLG),
                shape: RoundedRectangleBorder(
                  borderRadius: tokens.cornerFull(),
                ),
              ),
              child: Text(
                '設定を保存',
                style: tokens.typeScale.bodyLarge.copyWith(
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
    required List<Widget> children,
  }) {
    final tokens = context.tokens;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: tokens.brandPrimary),
            SizedBox(width: tokens.spaceSM),
            Text(
              title,
              style: tokens.typeScale.h4.copyWith(
                color: tokens.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        SizedBox(height: tokens.spaceMD),
        ...children,
      ],
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    final tokens = context.tokens;
    return Card(
      margin: EdgeInsets.only(bottom: tokens.spaceSM),
      elevation: 0,
      color: tokens.surface,
      shape: RoundedRectangleBorder(
        borderRadius: tokens.cornerLarge(),
        side: BorderSide(color: tokens.border),
      ),
      child: SwitchListTile(
        title: Text(
          title,
          style: tokens.typeScale.bodyMedium.copyWith(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          subtitle,
          style: tokens.typeScale.caption.copyWith(
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
  }) {
    final tokens = context.tokens;
    return Card(
      margin: EdgeInsets.only(bottom: tokens.spaceSM),
      elevation: 0,
      color: tokens.surface,
      shape: RoundedRectangleBorder(
        borderRadius: tokens.cornerLarge(),
        side: BorderSide(color: tokens.border),
      ),
      child: Padding(
        padding: EdgeInsets.all(tokens.spaceMD),
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
                        style: tokens.typeScale.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: tokens.typeScale.caption.copyWith(
                          color: tokens.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: tokens.spaceSM,
                    vertical: tokens.spaceBase,
                  ),
                  decoration: BoxDecoration(
                    color: tokens.brandPrimary.withAlpha((255 * 0.1).round()),
                    borderRadius: tokens.cornerMedium(),
                  ),
                  child: Text(
                    valueLabel,
                    style: tokens.typeScale.bodyMedium.copyWith(
                      color: tokens.brandPrimary,
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

  Widget _buildPreview() {
    final tokens = context.tokens;
    return Container(
      padding: EdgeInsets.all(tokens.spaceLG),
      decoration: BoxDecoration(
        color: _highContrast ? Colors.black : tokens.surface,
        borderRadius: tokens.cornerLarge(),
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
            style: tokens.typeScale.h4.copyWith(
              color: _highContrast ? Colors.white : tokens.textPrimary,
              fontWeight: _boldText ? FontWeight.bold : FontWeight.w600,
              fontSize: tokens.typeScale.h4.fontSize! * _textScale,
            ),
          ),
          SizedBox(height: tokens.spaceMD),
          Text(
            'これは設定のプレビューです。実際の表示を確認できます。',
            style: tokens.typeScale.bodyMedium.copyWith(
              color: _highContrast ? Colors.white : tokens.textPrimary,
              fontWeight: _boldText ? FontWeight.w600 : FontWeight.normal,
              fontSize: tokens.typeScale.bodyMedium.fontSize! * _textScale,
            ),
          ),
          SizedBox(height: tokens.spaceMD),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(
                horizontal: tokens.spaceLG,
                vertical: _largeButtons ? tokens.spaceLG : tokens.spaceMD,
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
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('設定を保存しました')));
    context.pop();
  }
}
