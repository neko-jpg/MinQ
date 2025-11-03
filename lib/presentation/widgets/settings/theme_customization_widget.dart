import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:minq/core/settings/theme_customization_service.dart';
import 'package:minq/presentation/theme/minq_theme.dart';
import 'package:minq/presentation/widgets/settings/real_time_preview_widget.dart';

class ThemeCustomizationWidget extends ConsumerStatefulWidget {
  const ThemeCustomizationWidget({super.key});

  @override
  ConsumerState<ThemeCustomizationWidget> createState() =>
      _ThemeCustomizationWidgetState();
}

class _ThemeCustomizationWidgetState
    extends ConsumerState<ThemeCustomizationWidget> {
  ThemeMode _selectedThemeMode = ThemeMode.system;
  Color _selectedAccentColor = ThemeCustomizationService.accentColors.first;
  bool _showPreview = false;

  @override
  void initState() {
    super.initState();
    _loadCurrentSettings();
  }

  Future<void> _loadCurrentSettings() async {
    final service = ref.read(themeCustomizationServiceProvider);
    final themeMode = await service.getThemeMode();
    final accentColor = await service.getAccentColor();

    setState(() {
      _selectedThemeMode = themeMode;
      _selectedAccentColor = accentColor;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = MinqTheme.of(context);

    return Scaffold(
      backgroundColor: theme.background,
      appBar: AppBar(
        title: Text(
          'テーマカスタマイズ',
          style: theme.typography.h4.copyWith(
            color: theme.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: theme.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _showPreview ? Icons.visibility_off : Icons.visibility,
              color: theme.textSecondary,
            ),
            tooltip: _showPreview ? 'プレビューを非表示' : 'プレビューを表示',
            onPressed: () {
              setState(() {
                _showPreview = !_showPreview;
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Preview Section
          if (_showPreview) ...[
            Container(
              height: 200,
              margin: EdgeInsets.all(theme.spacing.md),
              child: RealTimePreviewWidget(
                brightness: _getBrightnessFromThemeMode(),
                accentColor: _selectedAccentColor,
              ),
            ),
            Divider(color: theme.border),
          ],

          // Customization Options
          Expanded(
            child: ListView(
              padding: EdgeInsets.all(theme.spacing.md),
              children: [
                // Theme Mode Section
                _buildSection(
                  theme,
                  'テーマモード',
                  'アプリの明るさを選択',
                  Icons.brightness_6_outlined,
                  [
                    _buildThemeModeOption(
                      theme,
                      'システム設定に従う',
                      'デバイスの設定に合わせて自動切り替え',
                      Icons.phone_android,
                      ThemeMode.system,
                    ),
                    _buildThemeModeOption(
                      theme,
                      'ライトモード',
                      '明るいテーマを使用',
                      Icons.light_mode,
                      ThemeMode.light,
                    ),
                    _buildThemeModeOption(
                      theme,
                      'ダークモード',
                      '暗いテーマを使用',
                      Icons.dark_mode,
                      ThemeMode.dark,
                    ),
                  ],
                ),

                SizedBox(height: theme.spacing.lg),

                // Accent Color Section
                _buildSection(
                  theme,
                  'アクセントカラー',
                  'アプリのメインカラーを選択',
                  Icons.color_lens_outlined,
                  [_buildColorGrid(theme)],
                ),

                SizedBox(height: theme.spacing.lg),

                // Action Buttons
                _buildActionButtons(theme),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(
    MinqTheme theme,
    String title,
    String subtitle,
    IconData icon,
    List<Widget> children,
  ) {
    return Card(
      elevation: 0,
      color: theme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: theme.cornerMedium(),
        side: BorderSide(color: theme.border),
      ),
      child: Padding(
        padding: EdgeInsets.all(theme.spacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section Header
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(theme.spacing.sm),
                  decoration: BoxDecoration(
                    color: theme.brandPrimary.withAlpha((255 * 0.1).round()),
                    borderRadius: theme.cornerSmall(),
                  ),
                  child: Icon(icon, size: 20, color: theme.brandPrimary),
                ),
                SizedBox(width: theme.spacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: theme.typography.h5.copyWith(
                          color: theme.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: theme.spacing.xs),
                      Text(
                        subtitle,
                        style: theme.typography.bodySmall.copyWith(
                          color: theme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            SizedBox(height: theme.spacing.md),

            // Section Content
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildThemeModeOption(
    MinqTheme theme,
    String title,
    String subtitle,
    IconData icon,
    ThemeMode mode,
  ) {
    final isSelected = _selectedThemeMode == mode;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedThemeMode = mode;
        });
      },
      borderRadius: theme.cornerMedium(),
      child: Container(
        padding: EdgeInsets.all(theme.spacing.md),
        margin: EdgeInsets.only(bottom: theme.spacing.sm),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? theme.brandPrimary.withAlpha((255 * 0.1).round())
                  : theme.surfaceAlt,
          borderRadius: theme.cornerMedium(),
          border: Border.all(
            color: isSelected ? theme.brandPrimary : theme.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? theme.brandPrimary : theme.textSecondary,
            ),
            SizedBox(width: theme.spacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.typography.bodyLarge.copyWith(
                      color:
                          isSelected ? theme.brandPrimary : theme.textPrimary,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: theme.spacing.xs),
                  Text(
                    subtitle,
                    style: theme.typography.bodyMedium.copyWith(
                      color: theme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected) Icon(Icons.check_circle, color: theme.brandPrimary),
          ],
        ),
      ),
    );
  }

  Widget _buildColorGrid(MinqTheme theme) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: ThemeCustomizationService.accentColors.length,
      itemBuilder: (context, index) {
        final color = ThemeCustomizationService.accentColors[index];
        // ignore: deprecated_member_use
        final isSelected = color.value == _selectedAccentColor.value;

        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedAccentColor = color;
            });
          },
          child: Container(
            decoration: BoxDecoration(
              color: color,
              borderRadius: theme.cornerMedium(),
              border: Border.all(
                color: isSelected ? theme.textPrimary : theme.border,
                width: isSelected ? 3 : 1,
              ),
              boxShadow: isSelected ? theme.shadow.soft : null,
            ),
            child:
                isSelected
                    ? Icon(
                      Icons.check,
                      color: _getContrastColor(color),
                      size: 24,
                    )
                    : null,
          ),
        );
      },
    );
  }

  Widget _buildActionButtons(MinqTheme theme) {
    return Column(
      children: [
        // Apply Button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _applyChanges,
            icon: const Icon(Icons.check),
            label: const Text('変更を適用'),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.brandPrimary,
              foregroundColor: theme.primaryForeground,
              padding: EdgeInsets.symmetric(
                horizontal: theme.spacing.lg,
                vertical: theme.spacing.md,
              ),
              shape: RoundedRectangleBorder(borderRadius: theme.cornerMedium()),
            ),
          ),
        ),

        SizedBox(height: theme.spacing.md),

        // Reset Button
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _resetToDefault,
            icon: const Icon(Icons.restore),
            label: const Text('デフォルトに戻す'),
            style: OutlinedButton.styleFrom(
              foregroundColor: theme.textSecondary,
              side: BorderSide(color: theme.border),
              padding: EdgeInsets.symmetric(
                horizontal: theme.spacing.lg,
                vertical: theme.spacing.md,
              ),
              shape: RoundedRectangleBorder(borderRadius: theme.cornerMedium()),
            ),
          ),
        ),
      ],
    );
  }

  Brightness _getBrightnessFromThemeMode() {
    switch (_selectedThemeMode) {
      case ThemeMode.light:
        return Brightness.light;
      case ThemeMode.dark:
        return Brightness.dark;
      case ThemeMode.system:
        return View.of(context).platformDispatcher.platformBrightness;
    }
  }

  Color _getContrastColor(Color color) {
    final luminance = color.computeLuminance();
    return luminance > 0.5 ? Colors.black : Colors.white;
  }

  Future<void> _applyChanges() async {
    final service = ref.read(themeCustomizationServiceProvider);

    await service.setThemeMode(_selectedThemeMode);
    await service.setAccentColor(_selectedAccentColor);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('テーマ設定を適用しました'),
          backgroundColor: _selectedAccentColor,
        ),
      );
      Navigator.of(context).pop();
    }
  }

  Future<void> _resetToDefault() async {
    final service = ref.read(themeCustomizationServiceProvider);

    await service.resetTheme();

    setState(() {
      _selectedThemeMode = ThemeMode.system;
      _selectedAccentColor = ThemeCustomizationService.accentColors.first;
    });

    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('テーマ設定をリセットしました')));
    }
  }
}
