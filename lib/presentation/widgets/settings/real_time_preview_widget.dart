import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:minq/core/settings/theme_customization_service.dart';

class RealTimePreviewWidget extends ConsumerWidget {
  final Brightness brightness;
  final Color? accentColor;

  const RealTimePreviewWidget({
    super.key,
    required this.brightness,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final service = ref.watch(themeCustomizationServiceProvider);
    final previewTheme = service.createCustomTheme(
      brightness: brightness,
      accentColor: accentColor,
    );

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: previewTheme.background,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: previewTheme.border,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            // Preview App Bar
            Container(
              height: 56,
              decoration: BoxDecoration(
                color: previewTheme.surface,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(14),
                ),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 16),
                  Icon(
                    Icons.menu,
                    color: previewTheme.textPrimary,
                    size: 20,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      'MinQ プレビュー',
                      style: previewTheme.typography.h5.copyWith(
                        color: previewTheme.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.search,
                    color: previewTheme.textSecondary,
                    size: 20,
                  ),
                  const SizedBox(width: 16),
                ],
              ),
            ),

            // Preview Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Primary Button Preview
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: previewTheme.brandPrimary,
                          foregroundColor: previewTheme.primaryForeground,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'プライマリボタン',
                          style: previewTheme.typography.button,
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Card Preview
                    Expanded(
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: previewTheme.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: previewTheme.border),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: previewTheme.brandPrimary.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    Icons.task_alt,
                                    color: previewTheme.brandPrimary,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'サンプルクエスト',
                                        style: previewTheme.typography.bodyLarge.copyWith(
                                          color: previewTheme.textPrimary,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      Text(
                                        '毎日の習慣を継続しよう',
                                        style: previewTheme.typography.bodyMedium.copyWith(
                                          color: previewTheme.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: previewTheme.accentSuccess.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    '完了',
                                    style: previewTheme.typography.caption.copyWith(
                                      color: previewTheme.accentSuccess,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 12),

                            // Progress Bar Preview
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '今週の進捗',
                                  style: previewTheme.typography.bodySmall.copyWith(
                                    color: previewTheme.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                LinearProgressIndicator(
                                  value: 0.7,
                                  backgroundColor: previewTheme.surfaceAlt,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    previewTheme.brandPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Preview Info
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: previewTheme.surfaceAlt,
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(14),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.visibility,
                    size: 16,
                    color: previewTheme.textSecondary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${brightness == Brightness.light ? 'ライト' : 'ダーク'}モードプレビュー',
                    style: previewTheme.typography.bodySmall.copyWith(
                      color: previewTheme.textSecondary,
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
}