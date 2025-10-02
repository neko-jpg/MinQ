import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// クエスト属性選択ウィジェット
/// 難易度、推定時間、場所などの属性を選択
class QuestAttributesSelector extends StatelessWidget {
  final String? selectedDifficulty;
  final int? estimatedMinutes;
  final String? selectedLocation;
  final ValueChanged<String?>? onDifficultyChanged;
  final ValueChanged<int?>? onEstimatedMinutesChanged;
  final ValueChanged<String?>? onLocationChanged;

  const QuestAttributesSelector({
    super.key,
    this.selectedDifficulty,
    this.estimatedMinutes,
    this.selectedLocation,
    this.onDifficultyChanged,
    this.onEstimatedMinutesChanged,
    this.onLocationChanged,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 難易度選択
        if (onDifficultyChanged != null) ...[
          Text(
            '難易度',
            style: tokens.typography.body.copyWith(
              fontWeight: FontWeight.bold,
              color: tokens.textPrimary,
            ),
          ),
          SizedBox(height: tokens.spacing.sm),
          _DifficultySelector(
            selected: selectedDifficulty,
            onChanged: onDifficultyChanged!,
            tokens: tokens,
          ),
          SizedBox(height: tokens.spacing.lg),
        ],

        // 推定時間選択
        if (onEstimatedMinutesChanged != null) ...[
          Text(
            '推定時間',
            style: tokens.typography.body.copyWith(
              fontWeight: FontWeight.bold,
              color: tokens.textPrimary,
            ),
          ),
          SizedBox(height: tokens.spacing.sm),
          _DurationSelector(
            selected: estimatedMinutes,
            onChanged: onEstimatedMinutesChanged!,
            tokens: tokens,
          ),
          SizedBox(height: tokens.spacing.lg),
        ],

        // 場所選択
        if (onLocationChanged != null) ...[
          Text(
            '場所',
            style: tokens.typography.body.copyWith(
              fontWeight: FontWeight.bold,
              color: tokens.textPrimary,
            ),
          ),
          SizedBox(height: tokens.spacing.sm),
          _LocationSelector(
            selected: selectedLocation,
            onChanged: onLocationChanged!,
            tokens: tokens,
          ),
        ],
      ],
    );
  }
}

/// 難易度選択
class _DifficultySelector extends StatelessWidget {
  final String? selected;
  final ValueChanged<String?> onChanged;
  final MinqTheme tokens;

  const _DifficultySelector({
    required this.selected,
    required this.onChanged,
    required this.tokens,
  });

  static const difficulties = [
    {'value': 'easy', 'label': '簡単', 'icon': '⭐'},
    {'value': 'medium', 'label': '普通', 'icon': '⭐⭐'},
    {'value': 'hard', 'label': '難しい', 'icon': '⭐⭐⭐'},
  ];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: tokens.spacing.sm,
      children: difficulties.map((difficulty) {
        final isSelected = selected == difficulty['value'];
        return ChoiceChip(
          label: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(difficulty['icon']!),
              SizedBox(width: tokens.spacing.xs),
              Text(difficulty['label']!),
            ],
          ),
          selected: isSelected,
          onSelected: (selected) {
            onChanged(selected ? difficulty['value'] : null);
          },
          backgroundColor: tokens.surface,
          selectedColor: tokens.primary.withOpacity(0.2),
        );
      }).toList(),
    );
  }
}

/// 推定時間選択
class _DurationSelector extends StatelessWidget {
  final int? selected;
  final ValueChanged<int?> onChanged;
  final MinqTheme tokens;

  const _DurationSelector({
    required this.selected,
    required this.onChanged,
    required this.tokens,
  });

  static const durations = [
    {'value': 5, 'label': '5分'},
    {'value': 10, 'label': '10分'},
    {'value': 15, 'label': '15分'},
    {'value': 30, 'label': '30分'},
    {'value': 60, 'label': '1時間'},
  ];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: tokens.spacing.sm,
      children: durations.map((duration) {
        final value = duration['value'] as int;
        final isSelected = selected == value;
        return ChoiceChip(
          label: Text(duration['label']!),
          selected: isSelected,
          onSelected: (selected) {
            onChanged(selected ? value : null);
          },
          backgroundColor: tokens.surface,
          selectedColor: tokens.primary.withOpacity(0.2),
        );
      }).toList(),
    );
  }
}

/// 場所選択
class _LocationSelector extends StatelessWidget {
  final String? selected;
  final ValueChanged<String?> onChanged;
  final MinqTheme tokens;

  const _LocationSelector({
    required this.selected,
    required this.onChanged,
    required this.tokens,
  });

  static const locations = [
    {'value': 'home', 'label': '自宅', 'icon': '🏠'},
    {'value': 'gym', 'label': 'ジム', 'icon': '🏋️'},
    {'value': 'office', 'label': 'オフィス', 'icon': '🏢'},
    {'value': 'outdoor', 'label': '屋外', 'icon': '🌳'},
    {'value': 'library', 'label': '図書館', 'icon': '📚'},
  ];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: tokens.spacing.sm,
      runSpacing: tokens.spacing.sm,
      children: locations.map((location) {
        final isSelected = selected == location['value'];
        return ChoiceChip(
          label: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(location['icon']!),
              SizedBox(width: tokens.spacing.xs),
              Text(location['label']!),
            ],
          ),
          selected: isSelected,
          onSelected: (selected) {
            onChanged(selected ? location['value'] : null);
          },
          backgroundColor: tokens.surface,
          selectedColor: tokens.primary.withOpacity(0.2),
        );
      }).toList(),
    );
  }
}
