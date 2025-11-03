import 'package:flutter/material.dart';
import 'package:minq/core/settings/theme_customization_service.dart';
import 'package:minq/presentation/theme/minq_theme.dart';

class ColorPickerWidget extends StatefulWidget {
  final String title;
  final Color currentColor;
  final ValueChanged<Color>? onChanged;

  const ColorPickerWidget({
    super.key,
    required this.title,
    required this.currentColor,
    this.onChanged,
  });

  @override
  State<ColorPickerWidget> createState() => _ColorPickerWidgetState();
}

class _ColorPickerWidgetState extends State<ColorPickerWidget> {
  late Color _selectedColor;

  @override
  void initState() {
    super.initState();
    _selectedColor = widget.currentColor;
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
          children: [
            // Current Color Preview
            Container(
              width: double.infinity,
              height: 60,
              decoration: BoxDecoration(
                color: _selectedColor,
                borderRadius: theme.cornerMedium(),
                border: Border.all(color: theme.border),
              ),
              child: Center(
                child: Text(
                  'プレビュー',
                  style: theme.typography.bodyMedium.copyWith(
                    color: _getContrastColor(_selectedColor),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            SizedBox(height: theme.spacing.lg),

            // Color Grid
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 5,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: ThemeCustomizationService.accentColors.length,
              itemBuilder: (context, index) {
                final color = ThemeCustomizationService.accentColors[index];
                // ignore: deprecated_member_use
                final isSelected = color.value == _selectedColor.value;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedColor = color;
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: theme.cornerSmall(),
                      border: Border.all(
                        color: isSelected ? theme.textPrimary : theme.border,
                        width: isSelected ? 3 : 1,
                      ),
                    ),
                    child:
                        isSelected
                            ? Icon(
                              Icons.check,
                              color: _getContrastColor(color),
                              size: 20,
                            )
                            : null,
                  ),
                );
              },
            ),
          ],
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
            widget.onChanged?.call(_selectedColor);
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

  Color _getContrastColor(Color color) {
    final luminance = color.computeLuminance();
    return luminance > 0.5 ? Colors.black : Colors.white;
  }
}
