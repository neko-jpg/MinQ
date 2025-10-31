import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:minq/core/accessibility/accessibility_service.dart';
import 'package:minq/core/accessibility/semantic_helpers.dart';
import 'package:minq/presentation/providers/accessibility_providers.dart';
import 'package:minq/presentation/theme/minq_theme.dart';
import 'package:minq/presentation/widgets/accessibility/accessible_button.dart';

/// アクセシビリティ設定画面
/// 高齢者向けの特大UI・音声読み上げ速度などの設定
class AccessibilitySettingsScreen extends ConsumerWidget {
  const AccessibilitySettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.tokens;
    final l10n = AppLocalizations.of(context)!;
    final accessibilitySettings = ref.watch(accessibilityServiceProvider);
    final accessibilityService = ref.read(accessibilityServiceProvider.notifier);

    return Scaffold(
      backgroundColor: accessibilitySettings.highContrast 
          ? tokens.highContrastBackground 
          : tokens.background,
      appBar: AppBar(
        title: SemanticHelpers.accessibleHeader(
          child: Text(
            l10n.accessibilitySettings,
            style: tokens.typography.h3.copyWith(
              color: accessibilitySettings.highContrast 
                  ? tokens.highContrastText 
                  : tokens.textPrimary,
              fontWeight: accessibilitySettings.boldText 
                  ? FontWeight.bold 
                  : FontWeight.w700,
              fontSize: tokens.typography.h3.fontSize! * accessibilitySettings.textScale,
            ),
          ),
          semanticLabel: l10n.accessibilitySettings,
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
          tooltip: 'Go back',
        ),
        backgroundColor: accessibilitySettings.highContrast 
            ? tokens.highContrastBackground 
            : tokens.background.withAlpha((255 * 0.9).round()),
        elevation: 0,
      ),
      body: ListView(
        padding: EdgeInsets.all(tokens.spacing.lg),
        children: [
          // 視覚設定
          _buildSection(
            context: context,
            tokens: tokens,
            accessibilitySettings: accessibilitySettings,
            title: '視覚設定',
            icon: Icons.visibility,
            children: [
              _buildSliderTile(
                context: context,
                tokens: tokens,
                accessibilitySettings: accessibilitySettings,
                title: 'テキストサイズ',
                subtitle: '文字の大きさを調整',
                value: accessibilitySettings.textScale,
                min: 0.8,
                max: 2.0,
                divisions: 12,
                onChanged: (value) => accessibilityService.setTextScale(value),
                valueLabel: '${(accessibilitySettings.textScale * 100).toInt()}%',
                semanticLabel: 'テキストサイズ調整スライダー',
              ),
              _buildSwitchTile(
                context: context,
                tokens: tokens,
                accessibilitySettings: accessibilitySettings,
                title: '太字テキスト',
                subtitle: 'すべてのテキストを太字で表示',
                value: accessibilitySettings.boldText,
                onChanged: (value) => accessibilityService.setBoldText(value),
                semanticLabel: '太字テキスト設定',
              ),
              _buildSwitchTile(
                context: context,
                tokens: tokens,
                accessibilitySettings: accessibilitySettings,
                title: l10n.highContrast,
                subtitle: '色のコントラストを強調',
                value: accessibilitySettings.highContrast,
                onChanged: (value) => accessibilityService.setHighContrast(value),
                semanticLabel: '高コントラスト設定',
              ),
              _buildSwitchTile(
                context: context,
                tokens: tokens,
                accessibilitySettings: accessibilitySettings,
                title: l10n.largeText,
                subtitle: 'タップしやすい大きなボタン',
                value: accessibilitySettings.largeText,
                onChanged: (value) => accessibilityService.setLargeText(value),
                semanticLabel: '大きなテキスト設定',
              ),
            ],
          ),
          SizedBox(height: tokens.spacing.xl),
          
          // モーション設定
          _buildSection(
            context: context,
            tokens: tokens,
            accessibilitySettings: accessibilitySettings,
            title: 'モーション設定',
            icon: Icons.animation,
            children: [
              _buildSwitchTile(
                context: context,
                tokens: tokens,
                accessibilitySettings: accessibilitySettings,
                title: 'アニメーションを減らす',
                subtitle: '画面の動きを最小限に',
                value: accessibilitySettings.reduceMotion,
                onChanged: (value) => accessibilityService.setReduceMotion(value),
                semanticLabel: 'アニメーション軽減設定',
              ),
            ],
          ),
          SizedBox(height: tokens.spacing.xl),
          
          // UI設定
          _buildSection(
            context: context,
            tokens: tokens,
            accessibilitySettings: accessibilitySettings,
            title: 'UI設定',
            icon: Icons.dashboard_customize,
            children: [
              _buildSliderTile(
                context: context,
                tokens: tokens,
                accessibilitySettings: accessibilitySettings,
                title: 'ボタンサイズ',
                subtitle: 'タップしやすさを調整',
                value: accessibilitySettings.buttonScale,
                min: 0.8,
                max: 1.5,
                divisions: 7,
                onChanged: (value) => accessibilityService.setButtonScale(value),
                valueLabel: '${(accessibilitySettings.buttonScale * 100).toInt()}%',
                semanticLabel: 'ボタンサイズ調整スライダー',
              ),
              _buildSwitchTile(
                context: context,
                tokens: tokens,
                accessibilitySettings: accessibilitySettings,
                title: 'キーボードナビゲーション',
                subtitle: 'キーボードでの操作を有効化',
                value: accessibilitySettings.keyboardNavigation,
                onChanged: (value) => accessibilityService.setKeyboardNavigation(value),
                semanticLabel: 'キーボードナビゲーション設定',
              ),
              _buildSwitchTile(
                context: context,
                tokens: tokens,
                accessibilitySettings: accessibilitySettings,
                title: 'フォーカスインジケーター',
                subtitle: 'フォーカス状態を視覚的に表示',
                value: accessibilitySettings.focusIndicator,
                onChanged: (value) => accessibilityService.setFocusIndicator(value),
                semanticLabel: 'フォーカスインジケーター設定',
              ),
            ],
          ),
          SizedBox(height: tokens.spacing.xl),
          
          // スクリーンリーダー設定
          _buildSection(
            context: context,
            tokens: tokens,
            accessibilitySettings: accessibilitySettings,
            title: 'スクリーンリーダー',
            icon: Icons.accessibility_new,
            children: [
              _buildSwitchTile(
                context: context,
                tokens: tokens,
                accessibilitySettings: accessibilitySettings,
                title: 'スクリーンリーダー最適化',
                subtitle: '読み上げに最適化された表示',
                value: accessibilitySettings.screenReaderOptimized,
                onChanged: (value) => accessibilityService.setScreenReaderOptimized(value),
                semanticLabel: 'スクリーンリーダー最適化設定',
              ),
            ],
          ),
          SizedBox(height: tokens.spacing.xl),
          
          // フィードバック設定
          _buildSection(
            context: context,
            tokens: tokens,
            accessibilitySettings: accessibilitySettings,
            title: 'フィードバック',
            icon: Icons.vibration,
            children: [
              _buildSwitchTile(
                context: context,
                tokens: tokens,
                accessibilitySettings: accessibilitySettings,
                title: '触覚フィードバック',
                subtitle: 'ボタンタップ時の振動',
                value: accessibilitySettings.hapticFeedback,
                onChanged: (value) => accessibilityService.setHapticFeedback(value),
                semanticLabel: '触覚フィードバック設定',
              ),
              _buildSwitchTile(
                context: context,
                tokens: tokens,
                accessibilitySettings: accessibilitySettings,
                title: '音声フィードバック',
                subtitle: '操作時の効果音',
                value: accessibilitySettings.soundFeedback,
                onChanged: (value) => accessibilityService.setSoundFeedback(value),
                semanticLabel: '音声フィードバック設定',
              ),
            ],
          ),
          SizedBox(height: tokens.spacing.xl),
          
          // 色覚多様性設定
          _buildSection(
            context: context,
            tokens: tokens,
            accessibilitySettings: accessibilitySettings,
            title: '色覚多様性',
            icon: Icons.palette,
            children: [
              _buildColorBlindnessTile(
                context: context,
                tokens: tokens,
                accessibilitySettings: accessibilitySettings,
                onChanged: (mode) => accessibilityService.setColorBlindnessMode(mode),
              ),
            ],
          ),
          SizedBox(height: tokens.spacing.xl),
          
          // プレビュー
          _buildPreview(context, tokens, accessibilitySettings),
          SizedBox(height: tokens.spacing.xl),
          
          // 保存ボタン
          AccessibleButton(
            onPressed: () => _saveSettings(context),
            semanticLabel: '設定を保存',
            child: Text(
              '設定を保存',
              style: tokens.typography.bodyLarge.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required BuildContext context,
    required MinqTheme tokens,
    required AccessibilitySettings accessibilitySettings,
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return SemanticHelpers.accessibleHeader(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon, 
                color: accessibilitySettings.highContrast 
                    ? tokens.highContrastPrimary 
                    : tokens.brandPrimary,
              ),
              SizedBox(width: tokens.spacing.sm),
              Text(
                title,
                style: tokens.typography.h4.copyWith(
                  color: accessibilitySettings.highContrast 
                      ? tokens.highContrastText 
                      : tokens.textPrimary,
                  fontWeight: accessibilitySettings.boldText 
                      ? FontWeight.bold 
                      : FontWeight.w700,
                  fontSize: tokens.typography.h4.fontSize! * accessibilitySettings.textScale,
                ),
              ),
            ],
          ),
          SizedBox(height: tokens.spacing.md),
          ...children,
        ],
      ),
      semanticLabel: title,
    );
  }

  Widget _buildSwitchTile({
    required BuildContext context,
    required MinqTheme tokens,
    required AccessibilitySettings accessibilitySettings,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required String semanticLabel,
  }) {
    return SemanticHelpers.accessibleSwitch(
      child: Card(
        margin: EdgeInsets.only(bottom: tokens.spacing.sm),
        elevation: accessibilitySettings.highContrast ? 0 : 1,
        color: accessibilitySettings.highContrast 
            ? tokens.highContrastBackground 
            : tokens.surface,
        shape: RoundedRectangleBorder(
          borderRadius: tokens.cornerLarge(),
          side: BorderSide(
            color: accessibilitySettings.highContrast 
                ? tokens.highContrastText 
                : tokens.border,
            width: accessibilitySettings.highContrast ? 2 : 1,
          ),
        ),
        child: SwitchListTile(
          title: Text(
            title,
            style: tokens.typography.body.copyWith(
              fontWeight: accessibilitySettings.boldText 
                  ? FontWeight.bold 
                  : FontWeight.w600,
              fontSize: tokens.typography.body.fontSize! * accessibilitySettings.textScale,
              color: accessibilitySettings.highContrast 
                  ? tokens.highContrastText 
                  : tokens.textPrimary,
            ),
          ),
          subtitle: Text(
            subtitle,
            style: tokens.typography.caption.copyWith(
              color: accessibilitySettings.highContrast 
                  ? tokens.highContrastText.withOpacity(0.7) 
                  : tokens.textSecondary,
              fontSize: tokens.typography.caption.fontSize! * accessibilitySettings.textScale,
              fontWeight: accessibilitySettings.boldText 
                  ? FontWeight.w600 
                  : FontWeight.normal,
            ),
          ),
          value: value,
          onChanged: onChanged,
          activeThumbColor: accessibilitySettings.highContrast 
              ? tokens.highContrastPrimary 
              : tokens.brandPrimary,
        ),
      ),
      semanticLabel: semanticLabel,
      value: value,
      onChanged: onChanged,
      semanticHint: subtitle,
    );
  }

  Widget _buildSliderTile({
    required BuildContext context,
    required MinqTheme tokens,
    required AccessibilitySettings accessibilitySettings,
    required String title,
    required String subtitle,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required ValueChanged<double> onChanged,
    required String valueLabel,
    required String semanticLabel,
  }) {
    return SemanticHelpers.accessibleSlider(
      child: Card(
        margin: EdgeInsets.only(bottom: tokens.spacing.sm),
        elevation: accessibilitySettings.highContrast ? 0 : 1,
        color: accessibilitySettings.highContrast 
            ? tokens.highContrastBackground 
            : tokens.surface,
        shape: RoundedRectangleBorder(
          borderRadius: tokens.cornerLarge(),
          side: BorderSide(
            color: accessibilitySettings.highContrast 
                ? tokens.highContrastText 
                : tokens.border,
            width: accessibilitySettings.highContrast ? 2 : 1,
          ),
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
                            fontWeight: accessibilitySettings.boldText 
                                ? FontWeight.bold 
                                : FontWeight.w600,
                            fontSize: tokens.typography.body.fontSize! * accessibilitySettings.textScale,
                            color: accessibilitySettings.highContrast 
                                ? tokens.highContrastText 
                                : tokens.textPrimary,
                          ),
                        ),
                        Text(
                          subtitle,
                          style: tokens.typography.caption.copyWith(
                            color: accessibilitySettings.highContrast 
                                ? tokens.highContrastText.withOpacity(0.7) 
                                : tokens.textSecondary,
                            fontSize: tokens.typography.caption.fontSize! * accessibilitySettings.textScale,
                            fontWeight: accessibilitySettings.boldText 
                                ? FontWeight.w600 
                                : FontWeight.normal,
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
                      color: (accessibilitySettings.highContrast 
                          ? tokens.highContrastPrimary 
                          : tokens.brandPrimary).withAlpha((255 * 0.1).round()),
                      borderRadius: tokens.cornerMedium(),
                      border: accessibilitySettings.highContrast 
                          ? Border.all(color: tokens.highContrastText, width: 1)
                          : null,
                    ),
                    child: Text(
                      valueLabel,
                      style: tokens.typography.body.copyWith(
                        color: accessibilitySettings.highContrast 
                            ? tokens.highContrastPrimary 
                            : tokens.brandPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: tokens.typography.body.fontSize! * accessibilitySettings.textScale,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: tokens.spacing.sm),
              Slider(
                value: value,
                min: min,
                max: max,
                divisions: divisions,
                onChanged: onChanged,
                activeColor: accessibilitySettings.highContrast 
                    ? tokens.highContrastPrimary 
                    : tokens.brandPrimary,
                inactiveColor: (accessibilitySettings.highContrast 
                    ? tokens.highContrastText 
                    : tokens.textMuted).withOpacity(0.3),
              ),
            ],
          ),
        ),
      ),
      semanticLabel: semanticLabel,
      value: value,
      min: min,
      max: max,
      semanticHint: subtitle,
      valueLabel: valueLabel,
    );
  }

  Widget _buildColorBlindnessTile({
    required BuildContext context,
    required MinqTheme tokens,
    required AccessibilitySettings accessibilitySettings,
    required ValueChanged<ColorBlindnessMode> onChanged,
  }) {
    return Card(
      margin: EdgeInsets.only(bottom: tokens.spacing.sm),
      elevation: accessibilitySettings.highContrast ? 0 : 1,
      color: accessibilitySettings.highContrast 
          ? tokens.highContrastBackground 
          : tokens.surface,
      shape: RoundedRectangleBorder(
        borderRadius: tokens.cornerLarge(),
        side: BorderSide(
          color: accessibilitySettings.highContrast 
              ? tokens.highContrastText 
              : tokens.border,
          width: accessibilitySettings.highContrast ? 2 : 1,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(tokens.spacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '色覚多様性サポート',
              style: tokens.typography.body.copyWith(
                fontWeight: accessibilitySettings.boldText 
                    ? FontWeight.bold 
                    : FontWeight.w600,
                fontSize: tokens.typography.body.fontSize! * accessibilitySettings.textScale,
                color: accessibilitySettings.highContrast 
                    ? tokens.highContrastText 
                    : tokens.textPrimary,
              ),
            ),
            SizedBox(height: tokens.spacing.sm),
            DropdownButtonFormField<ColorBlindnessMode>(
              initialValue: accessibilitySettings.colorBlindnessMode,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: tokens.cornerMedium(),
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: tokens.spacing.sm,
                  vertical: tokens.spacing.xs,
                ),
              ),
              items: ColorBlindnessMode.values.map((mode) {
                return DropdownMenuItem(
                  value: mode,
                  child: Text(_getColorBlindnessModeLabel(mode)),
                );
              }).toList(),
              onChanged: (mode) {
                if (mode != null) {
                  onChanged(mode);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  String _getColorBlindnessModeLabel(ColorBlindnessMode mode) {
    switch (mode) {
      case ColorBlindnessMode.none:
        return 'なし';
      case ColorBlindnessMode.protanopia:
        return '1型色覚（赤色弱）';
      case ColorBlindnessMode.deuteranopia:
        return '2型色覚（緑色弱）';
      case ColorBlindnessMode.tritanopia:
        return '3型色覚（青色弱）';
      case ColorBlindnessMode.monochromacy:
        return '全色盲';
    }
  }

  Widget _buildPreview(
    BuildContext context,
    MinqTheme tokens,
    AccessibilitySettings accessibilitySettings,
  ) {
    return SemanticHelpers.accessibleCard(
      child: Container(
        padding: EdgeInsets.all(tokens.spacing.lg),
        decoration: BoxDecoration(
          color: accessibilitySettings.highContrast 
              ? tokens.highContrastBackground 
              : tokens.surface,
          borderRadius: tokens.cornerLarge(),
          border: Border.all(
            color: accessibilitySettings.highContrast 
                ? tokens.highContrastText 
                : tokens.border,
            width: accessibilitySettings.highContrast ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'プレビュー',
              style: tokens.typography.h4.copyWith(
                color: accessibilitySettings.highContrast 
                    ? tokens.highContrastText 
                    : tokens.textPrimary,
                fontWeight: accessibilitySettings.boldText 
                    ? FontWeight.bold 
                    : FontWeight.w600,
                fontSize: tokens.typography.h4.fontSize! * accessibilitySettings.textScale,
              ),
            ),
            SizedBox(height: tokens.spacing.md),
            Text(
              'これは設定のプレビューです。実際の表示を確認できます。',
              style: tokens.typography.body.copyWith(
                color: accessibilitySettings.highContrast 
                    ? tokens.highContrastText 
                    : tokens.textPrimary,
                fontWeight: accessibilitySettings.boldText 
                    ? FontWeight.w600 
                    : FontWeight.normal,
                fontSize: tokens.typography.body.fontSize! * accessibilitySettings.textScale,
              ),
            ),
            SizedBox(height: tokens.spacing.md),
            AccessibleButton(
              onPressed: () {},
              semanticLabel: 'サンプルボタン',
              child: Text(
                'サンプルボタン',
                style: TextStyle(
                  fontSize: 16 * accessibilitySettings.textScale,
                  fontWeight: accessibilitySettings.boldText 
                      ? FontWeight.bold 
                      : FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
      semanticLabel: 'アクセシビリティ設定プレビュー',
      semanticHint: '現在の設定での表示例',
    );
  }

  void _saveSettings(BuildContext context) {
    // Settings are automatically saved when changed
    SemanticHelpers.announceToScreenReader(
      context,
      '設定を保存しました',
    );
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('設定を保存しました'),
        backgroundColor: context.tokens.accentSuccess,
      ),
    );
    context.pop();
  }
}
