import 'package:flutter/material.dart';
import 'package:minq/presentation/theme/minq_theme.dart';

/// クエスト属性選択ウィジェチE��
/// 難易度、推定時間、場所などの属性を選抁E
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
        // 難易度選抁E
        if (onDifficultyChanged != null) ...[
          Text(
            '難易度',
            style: tokens.typography.bodyMedium.copyWith(
              fontWeight: FontWeight.bold,
              color: tokens.textPrimary,
            ),
          ),
          SizedBox(height: tokens.sm),
          _DifficultySelector(
            selected: selectedDifficulty,
            onChanged: onDifficultyChanged!,
            tokens: tokens,
          ),
          SizedBox(height: tokens.lg),
        ],

        // 推定時間選抁E
        if (onEstimatedMinutesChanged != null) ...[
          Text(
            '推定時閁E,
            style: tokens.typography.bodyMedium.copyWith(
              fontWeight: FontWeight.bold,
              color: tokens.textPrimary,
            ),
          ),
          SizedBox(height: tokens.sm),
          _DurationSelector(
            selected: estimatedMinutes,
            onChanged: onEstimatedMinutesChanged!,
            tokens: tokens,
          ),
          SizedBox(height: tokens.lg),
        ],

        // 場所選抁E
        if (onLocationChanged != null) ...[
          Text(
            '場所',
            style: tokens.typography.bodyMedium.copyWith(
              fontWeight: FontWeight.bold,
              color: tokens.textPrimary,
            ),
          ),
          SizedBox(height: tokens.sm),
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

/// 難易度選抁E
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
    {'value': 'easy', 'label': '簡十E, 'icon': '⭁E},
    {'value': 'medium', 'label': '普送E, 'icon': '⭐⭁E},
    {'value': 'hard', 'label': '難しい', 'icon': '⭐⭐⭁E},
  ];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: tokens.sm,
      children: difficulties.map((difficulty) {
        final isSelected = selected == difficulty['value'];
        return ChoiceChip(
          label: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(difficulty['icon']!),
              SizedBox(width: tokens.xs),
              Text(difficulty['label']!),
            ],
          ),
          selected: isSelected,
          onSelected: (selected) {
            onChanged(selected ? difficulty['value'] : null);
          },
          backgroundColor: tokens.surface,
          selectedColor: tokens.primary.withValues(alpha: 0.2),
        );
      }).toList(),
    );
  }
}

/// 推定時間選抁E
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
    {'value': 5, 'label': '5刁E},
    {'value': 10, 'label': '10刁E},
    {'value': 15, 'label': '15刁E},
    {'value': 30, 'label': '30刁E},
    {'value': 60, 'label': '1時間'},
  ];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: tokens.sm,
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
          selectedColor: tokens.primary.withValues(alpha: 0.2),
        );
      }).toList(),
    );
  }
}

/// 場所選抁E
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
    {'value': 'home', 'label': '自宁E, 'icon': '🏠'},
    {'value': 'gym', 'label': 'ジム', 'icon': '🏋�E�E},
    {'value': 'office', 'label': 'オフィス', 'icon': '🏢'},
    {'value': 'outdoor', 'label': '屋夁E, 'icon': '🌳'},
    {'value': 'library', 'label': '図書館', 'icon': '📚'},
  ];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: tokens.sm,
      runSpacing: tokens.sm,
      children: locations.map((location) {
        final isSelected = selected == location['value'];
        return ChoiceChip(
          label: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(location['icon']!),
              SizedBox(width: tokens.xs),
              Text(location['label']!),
            ],
          ),
          selected: isSelected,
          onSelected: (selected) {
            onChanged(selected ? location['value'] : null);
          },
          backgroundColor: tokens.surface,
          selectedColor: tokens.primary.withValues(alpha: 0.2),
        );
      }).toList(),
    );
  }
}
