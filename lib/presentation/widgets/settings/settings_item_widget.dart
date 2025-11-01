import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:minq/domain/settings/settings_category.dart';
import 'package:minq/presentation/theme/minq_theme.dart';
import 'package:minq/presentation/widgets/settings/color_picker_widget.dart';
import 'package:minq/presentation/widgets/settings/selection_widget.dart';
import 'package:minq/presentation/widgets/settings/time_picker_widget.dart';

class SettingsItemWidget extends ConsumerWidget {
  final SettingsItem item;
  final SettingsCategory category;
  final String? searchQuery;

  const SettingsItemWidget({
    super.key,
    required this.item,
    required this.category,
    this.searchQuery,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = MinqTheme.of(context);

    return InkWell(
      onTap: item.isEnabled ? _handleTap(context, ref) : null,
      child: Container(
        constraints: const BoxConstraints(minHeight: 56),
        padding: EdgeInsets.all(theme.spacing.md),
        child: Row(
          children: [
            // Icon
            if (item.icon != null) ...[
              Container(
                padding: EdgeInsets.all(theme.spacing.sm),
                decoration: BoxDecoration(
                  color:
                      item.isDangerous
                          ? theme.accentError.withOpacity(0.1)
                          : theme.brandPrimary.withOpacity(0.1),
                  borderRadius: theme.cornerSmall(),
                ),
                child: Icon(
                  item.icon,
                  size: 20,
                  color:
                      item.isDangerous ? theme.accentError : theme.brandPrimary,
                ),
              ),
              SizedBox(width: theme.spacing.md),
            ],

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTitle(theme),
                  if (item.subtitle != null) ...[
                    SizedBox(height: theme.spacing.xs),
                    _buildSubtitle(theme),
                  ],
                ],
              ),
            ),

            // Action Widget
            _buildActionWidget(context, theme, ref),
          ],
        ),
      ),
    );
  }

  Widget _buildTitle(MinqTheme theme) {
    if (searchQuery != null && searchQuery!.isNotEmpty) {
      return _buildHighlightedText(
        item.title,
        searchQuery!,
        theme.typography.bodyLarge.copyWith(
          color: item.isDangerous ? theme.accentError : theme.textPrimary,
          fontWeight: FontWeight.w600,
        ),
        theme.brandPrimary.withOpacity(0.3),
      );
    }

    return Text(
      item.title,
      style: theme.typography.bodyLarge.copyWith(
        color: item.isDangerous ? theme.accentError : theme.textPrimary,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildSubtitle(MinqTheme theme) {
    if (searchQuery != null && searchQuery!.isNotEmpty) {
      return _buildHighlightedText(
        item.subtitle!,
        searchQuery!,
        theme.typography.bodyMedium.copyWith(color: theme.textSecondary),
        theme.brandPrimary.withOpacity(0.2),
      );
    }

    return Text(
      item.subtitle!,
      style: theme.typography.bodyMedium.copyWith(color: theme.textSecondary),
    );
  }

  Widget _buildHighlightedText(
    String text,
    String query,
    TextStyle style,
    Color highlightColor,
  ) {
    if (query.isEmpty) {
      return Text(text, style: style);
    }

    final lowerText = text.toLowerCase();
    final lowerQuery = query.toLowerCase();
    final index = lowerText.indexOf(lowerQuery);

    if (index == -1) {
      return Text(text, style: style);
    }

    return RichText(
      text: TextSpan(
        style: style,
        children: [
          if (index > 0) TextSpan(text: text.substring(0, index)),
          TextSpan(
            text: text.substring(index, index + query.length),
            style: style.copyWith(
              backgroundColor: highlightColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (index + query.length < text.length)
            TextSpan(text: text.substring(index + query.length)),
        ],
      ),
    );
  }

  Widget _buildActionWidget(
    BuildContext context,
    MinqTheme theme,
    WidgetRef ref,
  ) {
    switch (item.type) {
      case SettingsItemType.toggle:
        return Switch(
          value: item.value as bool? ?? false,
          onChanged:
              item.isEnabled ? (value) => item.onChanged?.call(value) : null,
          activeThumbColor: theme.brandPrimary,
        );

      case SettingsItemType.selection:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (item.value != null)
              Text(
                _getSelectionDisplayText(),
                style: theme.typography.bodyMedium.copyWith(
                  color: theme.textSecondary,
                ),
              ),
            SizedBox(width: theme.spacing.sm),
            Icon(Icons.chevron_right, color: theme.textSecondary),
          ],
        );

      case SettingsItemType.colorPicker:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: item.value as Color? ?? theme.brandPrimary,
                borderRadius: theme.cornerSmall(),
                border: Border.all(color: theme.border),
              ),
            ),
            SizedBox(width: theme.spacing.sm),
            Icon(Icons.chevron_right, color: theme.textSecondary),
          ],
        );

      case SettingsItemType.timePicker:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (item.value != null)
              Text(
                _getTimeDisplayText(),
                style: theme.typography.bodyMedium.copyWith(
                  color: theme.textSecondary,
                ),
              ),
            SizedBox(width: theme.spacing.sm),
            Icon(Icons.chevron_right, color: theme.textSecondary),
          ],
        );

      case SettingsItemType.info:
        return Text(
          item.value?.toString() ?? '',
          style: theme.typography.bodyMedium.copyWith(
            color: theme.textSecondary,
          ),
        );

      case SettingsItemType.navigation:
      case SettingsItemType.action:
        return Icon(
          item.isDangerous ? Icons.warning_outlined : Icons.chevron_right,
          color: item.isDangerous ? theme.accentError : theme.textSecondary,
        );

      default:
        return const SizedBox.shrink();
    }
  }

  String _getSelectionDisplayText() {
    if (item.options == null || item.value == null) return '';

    final option = item.options!.firstWhere(
      (opt) => opt.value == item.value,
      orElse: () => item.options!.first,
    );

    return option.title;
  }

  String _getTimeDisplayText() {
    if (item.value is! TimeOfDay) return '';

    final time = item.value as TimeOfDay;
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  VoidCallback? _handleTap(BuildContext context, WidgetRef ref) {
    if (!item.isEnabled) return null;

    return () async {
      switch (item.type) {
        case SettingsItemType.toggle:
          final currentValue = item.value as bool? ?? false;
          item.onChanged?.call(!currentValue);
          break;

        case SettingsItemType.selection:
          if (item.options != null) {
            await _showSelectionDialog(context, ref);
          }
          break;

        case SettingsItemType.colorPicker:
          await _showColorPicker(context, ref);
          break;

        case SettingsItemType.timePicker:
          await _showTimePicker(context, ref);
          break;

        case SettingsItemType.navigation:
          if (item.route != null) {
            context.push(item.route!);
          } else {
            item.onTap?.call();
          }
          break;

        case SettingsItemType.action:
          if (item.isDangerous) {
            await _showDangerousActionDialog(context, ref);
          } else {
            item.onTap?.call();
          }
          break;

        default:
          item.onTap?.call();
          break;
      }
    };
  }

  Future<void> _showSelectionDialog(BuildContext context, WidgetRef ref) async {
    await showDialog(
      context: context,
      builder:
          (context) => SelectionWidget(
            title: item.title,
            options: item.options!,
            currentValue: item.value,
            onChanged: item.onChanged,
          ),
    );
  }

  Future<void> _showColorPicker(BuildContext context, WidgetRef ref) async {
    await showDialog(
      context: context,
      builder:
          (context) => ColorPickerWidget(
            title: item.title,
            currentColor: item.value as Color? ?? Colors.blue,
            onChanged: item.onChanged,
          ),
    );
  }

  Future<void> _showTimePicker(BuildContext context, WidgetRef ref) async {
    await showDialog(
      context: context,
      builder:
          (context) => TimePickerWidget(
            title: item.title,
            currentTime: item.value as TimeOfDay? ?? TimeOfDay.now(),
            onChanged: item.onChanged,
          ),
    );
  }

  Future<void> _showDangerousActionDialog(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final theme = MinqTheme.of(context);

    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              '確認',
              style: theme.typography.h5.copyWith(
                color: theme.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Text(
              '${item.title}を実行しますか？\nこの操作は取り消せません。',
              style: theme.typography.bodyMedium.copyWith(
                color: theme.textPrimary,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(
                  'キャンセル',
                  style: theme.typography.button.copyWith(
                    color: theme.textSecondary,
                  ),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text(
                  '実行',
                  style: theme.typography.button.copyWith(
                    color: theme.accentError,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      item.onTap?.call();
    }
  }
}
