import 'package:flutter/material.dart';
import 'package:minq/domain/settings/settings_category.dart';
import 'package:minq/presentation/theme/minq_theme.dart';

class SelectionWidget extends StatefulWidget {
  final String title;
  final List<SettingsOption> options;
  final dynamic currentValue;
  final ValueChanged<dynamic>? onChanged;

  const SelectionWidget({
    super.key,
    required this.title,
    required this.options,
    this.currentValue,
    this.onChanged,
  });

  @override
  State<SelectionWidget> createState() => _SelectionWidgetState();
}

class _SelectionWidgetState extends State<SelectionWidget> {
  late dynamic _selectedValue;

  @override
  void initState() {
    super.initState();
    _selectedValue = widget.currentValue;
  }

  @override
  Widget build(BuildContext context) {
    final theme = MinqTheme.of(context);

    return AlertDialog(
      title: Text(
        widget.title,
        style: theme.typography.h5.copyWith(
          color: theme.textPrimary,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children:
              widget.options.map((option) {
                final isSelected = option.value == _selectedValue;

                return InkWell(
                  onTap: () {
                    setState(() {
                      _selectedValue = option.value;
                    });
                  },
                  borderRadius: theme.cornerMedium(),
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(theme.spacing.md),
                    margin: EdgeInsets.only(bottom: theme.spacing.sm),
                    decoration: BoxDecoration(
                      color:
                          isSelected
                              ? theme.brandPrimary.withOpacity(0.1)
                              : theme.surfaceAlt,
                      borderRadius: theme.cornerMedium(),
                      border: Border.all(
                        color: isSelected ? theme.brandPrimary : theme.border,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        // Icon
                        if (option.icon != null) ...[
                          Container(
                            padding: EdgeInsets.all(theme.spacing.sm),
                            decoration: BoxDecoration(
                              color:
                                  isSelected
                                      ? theme.brandPrimary.withOpacity(0.2)
                                      : theme.surface,
                              borderRadius: theme.cornerSmall(),
                            ),
                            child: Icon(
                              option.icon,
                              size: 20,
                              color:
                                  isSelected
                                      ? theme.brandPrimary
                                      : theme.textSecondary,
                            ),
                          ),
                          SizedBox(width: theme.spacing.md),
                        ],

                        // Content
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                option.title,
                                style: theme.typography.bodyLarge.copyWith(
                                  color:
                                      isSelected
                                          ? theme.brandPrimary
                                          : theme.textPrimary,
                                  fontWeight:
                                      isSelected
                                          ? FontWeight.bold
                                          : FontWeight.w600,
                                ),
                              ),
                              if (option.subtitle != null) ...[
                                SizedBox(height: theme.spacing.xs),
                                Text(
                                  option.subtitle!,
                                  style: theme.typography.bodyMedium.copyWith(
                                    color: theme.textSecondary,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),

                        // Selection Indicator
                        if (isSelected)
                          Container(
                            padding: EdgeInsets.all(theme.spacing.xs),
                            decoration: BoxDecoration(
                              color: theme.brandPrimary,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.check,
                              size: 16,
                              color: theme.primaryForeground,
                            ),
                          )
                        else
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              border: Border.all(color: theme.border, width: 2),
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              }).toList(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            'キャンセル',
            style: theme.typography.button.copyWith(color: theme.textSecondary),
          ),
        ),
        TextButton(
          onPressed: () {
            widget.onChanged?.call(_selectedValue);
            Navigator.of(context).pop();
          },
          child: Text(
            '適用',
            style: theme.typography.button.copyWith(
              color: theme.brandPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
