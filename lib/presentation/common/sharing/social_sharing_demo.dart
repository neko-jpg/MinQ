import 'package:flutter/material.dart';
import 'package:minq/presentation/common/celebration/celebration_system.dart';
import 'package:minq/presentation/common/sharing/progress_share_card.dart';
import 'package:minq/presentation/theme/minq_theme.dart';

/// ソーシャルシェア機能のデモ画面
class SocialSharingDemo extends StatefulWidget {
  const SocialSharingDemo({super.key});

  @override
  State<SocialSharingDemo> createState() => _SocialSharingDemoState();
}

class _SocialSharingDemoState extends State<SocialSharingDemo> {
  int _currentStreak = 15;
  int _bestStreak = 25;
  int _totalQuests = 100;
  int _completedToday = 3;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ソーシャルシェア & 祝福システム'),
        backgroundColor: const Color(0xFF4ECDC4),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '進捗共有カード',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ProgressShareCard(
              currentStreak: _currentStreak,
              bestStreak: _bestStreak,
              totalQuests: _totalQuests,
              completedToday: _completedToday,
              onShare: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('シェア機能が実行されました！'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
            ),
            const SizedBox(height: 32),
            const Text(
              '祝福演出システム',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildCelebrationButton(
                  'ランダム祝福',
                  () => CelebrationSystem.showCelebration(context),
                ),
                _buildCelebrationButton(
                  '7日達成',
                  () {
                    final theme = Theme.of(context).extension<MinqTheme>()!;
                    CelebrationSystem.showCelebration(
                      context,
                      config: CelebrationSystem.getStreakCelebration(7, theme),
                    );
                  },
                ),
                _buildCelebrationButton(
                  '30日達成',
                  () {
                    final theme = Theme.of(context).extension<MinqTheme>()!;
                    CelebrationSystem.showCelebration(
                      context,
                      config: CelebrationSystem.getStreakCelebration(30, theme),
                    );
                  },
                ),
                _buildCelebrationButton(
                  '100日達成',
                  () {
                    final theme = Theme.of(context).extension<MinqTheme>()!;
                    CelebrationSystem.showCelebration(
                      context,
                      config: CelebrationSystem.getStreakCelebration(100, theme),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 32),
            const Text(
              '進捗データ調整',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildSlider(
                      '連続記録',
                      _currentStreak.toDouble(),
                      0,
                      100,
                      (value) => setState(() => _currentStreak = value.toInt()),
                    ),
                    _buildSlider(
                      'ベスト記録',
                      _bestStreak.toDouble(),
                      0,
                      100,
                      (value) => setState(() => _bestStreak = value.toInt()),
                    ),
                    _buildSlider(
                      '総クエスト',
                      _totalQuests.toDouble(),
                      0,
                      500,
                      (value) => setState(() => _totalQuests = value.toInt()),
                    ),
                    _buildSlider(
                      '今日完了',
                      _completedToday.toDouble(),
                      0,
                      10,
                      (value) =>
                          setState(() => _completedToday = value.toInt()),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'ペアリマインダー機能',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'リマインダーテンプレート例:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildReminderExample('💪', '今日のクエスト、一緒に頑張りましょう！'),
                    _buildReminderExample('🎉', 'お疲れさまでした！今日もよく頑張りましたね'),
                    _buildReminderExample('😊', '調子はどうですか？一緒に継続していきましょう'),
                    _buildReminderExample('🌟', 'あなたならできます！応援しています'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCelebrationButton(String label, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF4ECDC4),
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      child: Text(label),
    );
  }

  Widget _buildSlider(
    String label,
    double value,
    double min,
    double max,
    ValueChanged<double> onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label: ${value.toInt()}',
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: (max - min).toInt(),
          onChanged: onChanged,
          activeColor: const Color(0xFF4ECDC4),
        ),
      ],
    );
  }

  Widget _buildReminderExample(String emoji, String message) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 8),
          Expanded(child: Text(message, style: const TextStyle(fontSize: 14))),
        ],
      ),
    );
  }
}
