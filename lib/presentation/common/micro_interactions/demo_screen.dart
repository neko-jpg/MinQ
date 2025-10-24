import 'package:flutter/material.dart';
import 'package:minq/presentation/common/feedback/feedback_manager.dart';
import 'package:minq/presentation/common/micro_interactions/micro_interactions.dart';
import 'package:minq/presentation/theme/minq_theme.dart';

/// Demo screen showcasing the micro-interaction components
/// This is for development and testing purposes
class MicroInteractionDemoScreen extends StatefulWidget {
  const MicroInteractionDemoScreen({super.key});

  @override
  State<MicroInteractionDemoScreen> createState() =>
      _MicroInteractionDemoScreenState();
}

class _MicroInteractionDemoScreenState
    extends State<MicroInteractionDemoScreen> {
  bool _checkboxValue = false;
  bool _isPulsing = false;
  double _progress = 0.3;

  @override
  void initState() {
    super.initState();
    // Initialize feedback managers
    FeedbackManager.initialize();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Micro-Interactions Demo'),
        backgroundColor: tokens.brandPrimary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(tokens.spacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Animated Checkbox Demo
            Text('Animated Checkbox', style: tokens.typography.h4),
            SizedBox(height: tokens.spacing.md),
            Row(
              children: [
                AnimatedCheckbox(
                  isChecked: _checkboxValue,
                  onChanged: (value) {
                    setState(() {
                      _checkboxValue = value;
                    });
                  },
                  showConfetti: true,
                ),
                SizedBox(width: tokens.spacing.md),
                Text(
                  _checkboxValue ? 'Checked!' : 'Unchecked',
                  style: tokens.typography.body,
                ),
              ],
            ),

            SizedBox(height: tokens.spacing.lg),

            // Pulsing Button Demo
            Text('Pulsing Button', style: tokens.typography.h4),
            SizedBox(height: tokens.spacing.md),
            Row(
              children: [
                PulsingButton(
                  onPressed: () {
                    setState(() {
                      _isPulsing = !_isPulsing;
                    });
                  },
                  isPulsing: _isPulsing,
                  child: Text(
                    _isPulsing ? 'Stop Pulsing' : 'Start Pulsing',
                    style: tokens.typography.body.copyWith(color: Colors.white),
                  ),
                ),
                SizedBox(width: tokens.spacing.md),
                PulsingButton(
                  onPressed: () {
                    FeedbackManager.questCompleted();
                  },
                  child: Text(
                    'Test Feedback',
                    style: tokens.typography.body.copyWith(color: Colors.white),
                  ),
                ),
              ],
            ),

            SizedBox(height: tokens.spacing.lg),

            // Progress Ring Demo
            Text('Progress Ring', style: tokens.typography.h4),
            SizedBox(height: tokens.spacing.md),
            Center(
              child: ProgressRing(
                progress: _progress,
                size: 120,
                showSparkles: true,
                onComplete: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Progress completed!'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
                child: Text(
                  '${(_progress * 100).toInt()}%',
                  style: tokens.typography.h4,
                ),
              ),
            ),

            SizedBox(height: tokens.spacing.md),

            // Progress controls
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _progress = (_progress - 0.1).clamp(0.0, 1.0);
                    });
                  },
                  child: const Text('- 10%'),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _progress = (_progress + 0.1).clamp(0.0, 1.0);
                    });
                  },
                  child: const Text('+ 10%'),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _progress = 1.0;
                    });
                  },
                  child: const Text('Complete'),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _progress = 0.0;
                    });
                  },
                  child: const Text('Reset'),
                ),
              ],
            ),

            SizedBox(height: tokens.spacing.lg),

            // Feedback Settings
            Text('Feedback Settings', style: tokens.typography.h4),
            SizedBox(height: tokens.spacing.md),

            SwitchListTile(
              title: const Text('Haptic Feedback'),
              value: FeedbackManager.isHapticEnabled,
              onChanged: (value) {
                setState(() {
                  FeedbackManager.setHapticEnabled(value);
                });
              },
            ),

            SwitchListTile(
              title: const Text('Audio Feedback'),
              value: FeedbackManager.isAudioEnabled,
              onChanged: (value) {
                setState(() {
                  FeedbackManager.setAudioEnabled(value);
                });
              },
            ),

            SizedBox(height: tokens.spacing.lg),

            // Feedback Test Buttons
            Text('Test Different Feedback Types', style: tokens.typography.h4),
            SizedBox(height: tokens.spacing.md),

            Wrap(
              spacing: tokens.spacing.sm,
              runSpacing: tokens.spacing.sm,
              children: [
                ElevatedButton(
                  onPressed: () => FeedbackManager.questCompleted(),
                  child: const Text('Quest Complete'),
                ),
                ElevatedButton(
                  onPressed: () => FeedbackManager.achievementUnlocked(),
                  child: const Text('Achievement'),
                ),
                ElevatedButton(
                  onPressed: () => FeedbackManager.streakMaintained(),
                  child: const Text('Streak'),
                ),
                ElevatedButton(
                  onPressed: () => FeedbackManager.levelUp(),
                  child: const Text('Level Up'),
                ),
                ElevatedButton(
                  onPressed: () => FeedbackManager.error(),
                  child: const Text('Error'),
                ),
                ElevatedButton(
                  onPressed: () => FeedbackManager.warning(),
                  child: const Text('Warning'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
