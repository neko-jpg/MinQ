import 'package:flutter/material.dart';
import 'package:minq/presentation/screens/mood_tracking_screen.dart';
import 'package:minq/presentation/theme/minq_theme.dart';

class MoodSelectorWidget extends StatelessWidget {
  const MoodSelectorWidget({
    super.key,
    required this.moodOptions,
    required this.selectedMood,
    required this.onMoodSelected,
  });

  final Map<String, MoodData> moodOptions;
  final String selectedMood;
  final ValueChanged<String> onMoodSelected;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Card(
      elevation: 0,
      color: tokens.surface,
      shape: RoundedRectangleBorder(
        borderRadius: tokens.cornerLarge(),
        side: BorderSide(color: tokens.border),
      ),
      child: Padding(
        padding: EdgeInsets.all(tokens.spacing(4)),
        child: Column(
          children: [
            // 5段階評価の横並び
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children:
                  moodOptions.entries.map((entry) {
                    final moodKey = entry.key;
                    final moodData = entry.value;
                    final isSelected = selectedMood == moodKey;

                    return GestureDetector(
                      onTap: () => onMoodSelected(moodKey),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: EdgeInsets.all(tokens.spacing(2)),
                        decoration: BoxDecoration(
                          color:
                              isSelected
                                  ? moodData.color.withOpacity(0.2)
                                  : Colors.transparent,
                          borderRadius: tokens.cornerLarge(),
                          border:
                              isSelected
                                  ? Border.all(color: moodData.color, width: 2)
                                  : null,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            AnimatedScale(
                              scale: isSelected ? 1.2 : 1.0,
                              duration: const Duration(milliseconds: 200),
                              child: Text(
                                moodData.emoji,
                                style: const TextStyle(fontSize: 32),
                              ),
                            ),
                            SizedBox(height: tokens.spacing(1)),
                            Text(
                              moodData.label,
                              style: tokens.bodySmall.copyWith(
                                color:
                                    isSelected
                                        ? moodData.color
                                        : tokens.textMuted,
                                fontWeight:
                                    isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
            ),

            SizedBox(height: tokens.spacing(3)),

            // 選択された気分の詳細表示
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Container(
                key: ValueKey(selectedMood),
                padding: EdgeInsets.all(tokens.spacing(3)),
                decoration: BoxDecoration(
                  color: moodOptions[selectedMood]!.color.withOpacity(0.1),
                  borderRadius: tokens.cornerMedium(),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      moodOptions[selectedMood]!.emoji,
                      style: const TextStyle(fontSize: 24),
                    ),
                    SizedBox(width: tokens.spacing(2)),
                    Text(
                      moodOptions[selectedMood]!.description,
                      style: tokens.bodyMedium.copyWith(
                        color: moodOptions[selectedMood]!.color,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 気分選択用のコンパクトウィジェット
class CompactMoodSelector extends StatelessWidget {
  const CompactMoodSelector({
    super.key,
    required this.selectedMood,
    required this.onMoodSelected,
  });

  final String selectedMood;
  final ValueChanged<String> onMoodSelected;

  static const Map<String, String> _quickMoods = {
    'very_happy': '😄',
    'happy': '😊',
    'neutral': '😐',
    'sad': '😔',
    'very_sad': '😢',
  };

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: tokens.spacing(3),
        vertical: tokens.spacing(2),
      ),
      decoration: BoxDecoration(
        color: tokens.surface,
        borderRadius: tokens.cornerLarge(),
        border: Border.all(color: tokens.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children:
            _quickMoods.entries.map((entry) {
              final moodKey = entry.key;
              final emoji = entry.value;
              final isSelected = selectedMood == moodKey;

              return GestureDetector(
                onTap: () => onMoodSelected(moodKey),
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: tokens.spacing(1)),
                  padding: EdgeInsets.all(tokens.spacing(1)),
                  decoration: BoxDecoration(
                    color:
                        isSelected
                            ? tokens.brandPrimary.withOpacity(0.2)
                            : Colors.transparent,
                    borderRadius: tokens.cornerMedium(),
                  ),
                  child: Text(
                    emoji,
                    style: TextStyle(fontSize: isSelected ? 24 : 20),
                  ),
                ),
              );
            }).toList(),
      ),
    );
  }
}

/// 気分履歴表示用のウィジェット
class MoodHistoryItem extends StatelessWidget {
  const MoodHistoryItem({
    super.key,
    required this.mood,
    required this.rating,
    required this.timestamp,
    this.onTap,
  });

  final String mood;
  final int rating;
  final DateTime timestamp;
  final VoidCallback? onTap;

  static const Map<String, String> _moodEmojis = {
    'very_happy': '😄',
    'happy': '😊',
    'neutral': '😐',
    'sad': '😔',
    'very_sad': '😢',
  };

  static const Map<String, Color> _moodColors = {
    'very_happy': Color(0xFF4CAF50),
    'happy': Color(0xFF8BC34A),
    'neutral': Color(0xFFFF9800),
    'sad': Color(0xFFFF5722),
    'very_sad': Color(0xFFF44336),
  };

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final emoji = _moodEmojis[mood] ?? '😐';
    final color = _moodColors[mood] ?? tokens.textMuted;

    return Card(
      elevation: 0,
      color: tokens.surface,
      shape: RoundedRectangleBorder(
        borderRadius: tokens.cornerMedium(),
        side: BorderSide(color: tokens.border),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: tokens.cornerMedium(),
        child: Padding(
          padding: EdgeInsets.all(tokens.spacing(3)),
          child: Row(
            children: [
              // 気分アイコン
              Container(
                padding: EdgeInsets.all(tokens.spacing(2)),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: tokens.cornerMedium(),
                ),
                child: Text(emoji, style: const TextStyle(fontSize: 24)),
              ),

              SizedBox(width: tokens.spacing(3)),

              // 詳細情報
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          _getMoodLabel(mood),
                          style: tokens.bodyMedium.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(width: tokens.spacing(2)),
                        // 評価星
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: List.generate(5, (index) {
                            return Icon(
                              index < rating ? Icons.star : Icons.star_border,
                              size: 16,
                              color: index < rating ? color : tokens.textMuted,
                            );
                          }),
                        ),
                      ],
                    ),
                    SizedBox(height: tokens.spacing(1)),
                    Text(
                      _formatTime(timestamp),
                      style: tokens.bodySmall.copyWith(color: tokens.textMuted),
                    ),
                  ],
                ),
              ),

              // 矢印アイコン
              if (onTap != null)
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: tokens.textMuted,
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _getMoodLabel(String mood) {
    switch (mood) {
      case 'very_happy':
        return 'とても良い';
      case 'happy':
        return '良い';
      case 'neutral':
        return '普通';
      case 'sad':
        return '悪い';
      case 'very_sad':
        return 'とても悪い';
      default:
        return '不明';
    }
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}日前';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}時間前';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}分前';
    } else {
      return 'たった今';
    }
  }
}

/// 気分統計表示用のウィジェット
class MoodStatsWidget extends StatelessWidget {
  const MoodStatsWidget({
    super.key,
    required this.averageRating,
    required this.totalRecords,
    required this.mostFrequentMood,
    required this.period,
  });

  final double averageRating;
  final int totalRecords;
  final String mostFrequentMood;
  final String period;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Card(
      elevation: 0,
      color: tokens.surface,
      shape: RoundedRectangleBorder(
        borderRadius: tokens.cornerLarge(),
        side: BorderSide(color: tokens.border),
      ),
      child: Padding(
        padding: EdgeInsets.all(tokens.spacing(4)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$periodの統計',
              style: tokens.titleMedium.copyWith(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: tokens.spacing(3)),
            Row(
              children: [
                Expanded(
                  child: _StatItem(
                    icon: Icons.star,
                    label: '平均評価',
                    value: averageRating.toStringAsFixed(1),
                    color: tokens.brandPrimary,
                  ),
                ),
                Container(width: 1, height: 40, color: tokens.border),
                Expanded(
                  child: _StatItem(
                    icon: Icons.calendar_today,
                    label: '記録回数',
                    value: '$totalRecords回',
                    color: tokens.encouragement,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        SizedBox(height: tokens.spacing(1)),
        Text(
          value,
          style: tokens.titleLarge.copyWith(
            color: tokens.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(label, style: tokens.bodySmall.copyWith(color: tokens.textMuted)),
      ],
    );
  }
}
