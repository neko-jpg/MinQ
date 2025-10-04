import 'package:flutter/material.dart';
import 'package:minq/presentation/common/celebration/celebration_system.dart';
import 'package:minq/presentation/common/sharing/progress_share_card.dart';

/// 繧ｽ繝ｼ繧ｷ繝｣繝ｫ繧ｷ繧ｧ繧｢讖溯・縺ｮ繝・Δ逕ｻ髱｢
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
        title: const Text('繧ｽ繝ｼ繧ｷ繝｣繝ｫ繧ｷ繧ｧ繧｢ & 逾晉ｦ上す繧ｹ繝・Β'),
        backgroundColor: const Color(0xFF4ECDC4),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '騾ｲ謐怜・譛峨き繝ｼ繝・,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
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
                    content: Text('繧ｷ繧ｧ繧｢讖溯・縺悟ｮ溯｡後＆繧後∪縺励◆・・),
                    backgroundColor: Colors.green,
                  ),
                );
              },
            ),
            const SizedBox(height: 32),
            const Text(
              '逾晉ｦ乗ｼ泌・繧ｷ繧ｹ繝・Β',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildCelebrationButton(
                  '繝ｩ繝ｳ繝繝逾晉ｦ・,
                  () => CelebrationSystem.showCelebration(context),
                ),
                _buildCelebrationButton(
                  '7譌･驕疲・',
                  () => CelebrationSystem.showCelebration(
                    context,
                    config: CelebrationSystem.getStreakCelebration(7),
                  ),
                ),
                _buildCelebrationButton(
                  '30譌･驕疲・',
                  () => CelebrationSystem.showCelebration(
                    context,
                    config: CelebrationSystem.getStreakCelebration(30),
                  ),
                ),
                _buildCelebrationButton(
                  '100譌･驕疲・',
                  () => CelebrationSystem.showCelebration(
                    context,
                    config: CelebrationSystem.getStreakCelebration(100),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            const Text(
              '騾ｲ謐励ョ繝ｼ繧ｿ隱ｿ謨ｴ',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildSlider(
                      '騾｣邯夊ｨ倬鹸',
                      _currentStreak.toDouble(),
                      0,
                      100,
                      (value) => setState(() => _currentStreak = value.toInt()),
                    ),
                    _buildSlider(
                      '繝吶せ繝郁ｨ倬鹸',
                      _bestStreak.toDouble(),
                      0,
                      100,
                      (value) => setState(() => _bestStreak = value.toInt()),
                    ),
                    _buildSlider(
                      '邱上け繧ｨ繧ｹ繝・,
                      _totalQuests.toDouble(),
                      0,
                      500,
                      (value) => setState(() => _totalQuests = value.toInt()),
                    ),
                    _buildSlider(
                      '莉頑律螳御ｺ・,
                      _completedToday.toDouble(),
                      0,
                      10,
                      (value) => setState(() => _completedToday = value.toInt()),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              '繝壹い繝ｪ繝槭う繝ｳ繝繝ｼ讖溯・',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '繝ｪ繝槭う繝ｳ繝繝ｼ繝・Φ繝励Ξ繝ｼ繝井ｾ・',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildReminderExample('潮', '莉頑律縺ｮ繧ｯ繧ｨ繧ｹ繝医∽ｸ邱偵↓鬆大ｼｵ繧翫∪縺励ｇ縺・ｼ・),
                    _buildReminderExample('脂', '縺顔夢繧後＆縺ｾ縺ｧ縺励◆・∽ｻ頑律繧ゅｈ縺城大ｼｵ繧翫∪縺励◆縺ｭ'),
                    _buildReminderExample('・', '隱ｿ蟄舌・縺ｩ縺・〒縺吶°・滉ｸ邱偵↓邯咏ｶ壹＠縺ｦ縺・″縺ｾ縺励ｇ縺・),
                    _buildReminderExample('検', '縺ゅ↑縺溘↑繧峨〒縺阪∪縺呻ｼ∝ｿ懈抄縺励※縺・∪縺・),
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
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
          Text(
            emoji,
            style: const TextStyle(fontSize: 20),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}