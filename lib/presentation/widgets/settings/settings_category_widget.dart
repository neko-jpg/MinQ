import 'package:flutter/material.dart';
import 'package:minq/domain/settings/settings_category.dart';
import 'package:minq/presentation/theme/minq_theme.dart';
import 'package:minq/presentation/widgets/settings/settings_item_widget.dart';

class SettingsCategoryWidget extends StatelessWidget {
  final SettingsCategory category;
  final bool showAdvanced;

  const SettingsCategoryWidget({
    super.key,
    required this.category,
    this.showAdvanced = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = MinqTheme.of(context);

    return Card(
      elevation: 0,
      color: theme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: theme.cornerMedium(),
        side: BorderSide(
          color: theme.border,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category Header
          Container(
            padding: EdgeInsets.all(theme.spacing.md),
            decoration: BoxDecoration(
              color: category.isAdvanced 
                  ? theme.accentWarning.withOpacity(0.1)
                  : theme.surfaceAlt,
              borderRadius: BorderRadius.vertical(
                top: theme.cornerMedium().topLeft,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(theme.spacing.sm),
                  decoration: BoxDecoration(
                    color: category.isAdvanced
                        ? theme.accentWarning.withOpacity(0.2)
                        : theme.brandPrimary.withOpacity(0.1),
                    borderRadius: theme.cornerSmall(),
                  ),
                  child: Icon(
                    category.icon,
                    size: 20,
                    color: category.isAdvanced
                        ? theme.accentWarning
                        : theme.brandPrimary,
                  ),
                ),
                SizedBox(width: theme.spacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            category.title,
                            style: theme.typography.h5.copyWith(
                              color: theme.textPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (category.isAdvanced) ...[
                            SizedBox(width: theme.spacing.sm),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: theme.spacing.sm,
                                vertical: theme.spacing.xs,
                              ),
                              decoration: BoxDecoration(
                                color: theme.accentWarning.withOpacity(0.2),
                                borderRadius: theme.cornerSmall(),
                              ),
                              child: Text(
                                '高度',
                                style: theme.typography.caption.copyWith(
                                  color: theme.accentWarning,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      if (category.subtitle != null) ...[
                        SizedBox(height: theme.spacing.xs),
                        Text(
                          category.subtitle!,
                          style: theme.typography.bodySmall.copyWith(
                            color: theme.textSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Category Items
          ...category.items.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            final isLast = index == category.items.length - 1;

            return Column(
              children: [
                SettingsItemWidget(
                  item: item,
                  category: category,
                ),
                if (!isLast)
                  Divider(
                    color: theme.border,
                    height: 1,
                    indent: theme.spacing.md,
                    endIndent: theme.spacing.md,
                  ),
              ],
            );
          }),
        ],
      ),
    );
  }
}