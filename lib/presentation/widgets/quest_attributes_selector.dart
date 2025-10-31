import 'package:flutter/material.dart';
import 'package:minq/l10n/app_localizations.dart';
import 'package:minq/presentation/theme/minq_theme.dart';

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
            AppLocalizations.of(context).difficulty,
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
            AppLocalizations.of(context).estimatedTime,
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
            AppLocalizations.of(context).location,
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

  static List<Map<String, String>> getDifficulties(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return [
      {'value': 'easy', 'label': l10n.difficultyEasy, 'icon': '⭐'},
      {'value': 'medium', 'label': l10n.difficultyMedium, 'icon': '⭐⭐'},
      {'value': 'hard', 'label': l10n.difficultyHard, 'icon': '⭐⭐⭐'},
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: tokens.spacing.sm,
      children:
          getDifficulties(context).map((difficulty) {
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
              selectedColor:
                  tokens.brandPrimary.withAlpha((255 * 0.2).round()),
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

  static List<Map<String, dynamic>> getDurations(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return [
      {'value': 5, 'label': l10n.duration5min},
      {'value': 10, 'label': l10n.duration10min},
      {'value': 15, 'label': l10n.duration15min},
      {'value': 30, 'label': l10n.duration30min},
      {'value': 60, 'label': l10n.duration1hour},
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: tokens.spacing.sm,
      children:
          getDurations(context).map((duration) {
            final value = duration['value'] as int;
            final isSelected = selected == value;
            return ChoiceChip(
              label: Text(duration['label'] as String),
              selected: isSelected,
              onSelected: (selected) {
                onChanged(selected ? value : null);
              },
              backgroundColor: tokens.surface,
              selectedColor:
                  tokens.brandPrimary.withAlpha((255 * 0.2).round()),
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

  static List<Map<String, String>> getLocations(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return [
      {'value': 'home', 'label': l10n.locationHome, 'icon': '🏠'},
      {'value': 'gym', 'label': l10n.locationGym, 'icon': '🏋️'},
      {'value': 'office', 'label': l10n.locationOffice, 'icon': '🏢'},
      {'value': 'outdoor', 'label': l10n.locationOutdoor, 'icon': '🌳'},
      {'value': 'library', 'label': l10n.locationLibrary, 'icon': '📚'},
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: tokens.spacing.sm,
      runSpacing: tokens.spacing.sm,
      children:
          getLocations(context).map((location) {
            final isSelected = selected == location['value'];
            return ChoiceChip(
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(location['icon'] as String),
                  SizedBox(width: tokens.spacing.xs),
                  Text(location['label'] as String),
                ],
              ),
              selected: isSelected,
              onSelected: (selected) {
                onChanged(selected ? location['value'] : null);
              },
              backgroundColor: tokens.surface,
              selectedColor:
                  tokens.brandPrimary.withAlpha((255 * 0.2).round()),
            );
          }).toList(),
    );
  }
}
