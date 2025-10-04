import 'package:flutter/material.dart';
import 'package:minq/presentation/common/feedback/feedback_manager.dart';
import 'package:minq/presentation/common/micro_interactions/micro_interactions.dart';
import 'package:minq/presentation/theme/minq_theme.dart';

/// Demo screen showcasing the micro-interaction components
/// This is for development and testing purposes
class MicroInteractionDemoScreen extends StatefulWidget {
  const MicroInteractionDemoScreen({super.key});

  @override
  State<MicroInteractionDemoScreen> createState() => _MicroInteractionDemoScreenState();
}

class _MicroInteractionDemoScreenState extends State<MicroInteractionDemoScreen> {
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
    final theme = MinqTheme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Micro-Interactions Demo'),
        backgroundColor: theme.brandPrimary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(theme.spaceLG),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Animated Checkbox Demo
            Text(
              'Animated Checkbox',
              style: theme.titleMedium,
            ),
            SizedBox(height: theme.spaceMD),
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
                SizedBox(width: theme.spaceMD),
                Text(
                  _checkboxValue ? 'Checked!' : 'Unchecked',
                  style: theme.bodyMedium,
                ),
              ],
            ),
            
            SizedBox(height: theme.spaceLG),
            
            // Pulsing Button Demo
            Text(
              'Pulsing Button',
              style: theme.titleMedium,
            ),
            SizedBox(height: theme.spaceMD),
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
                    style: theme.bodyMedium.copyWith(color: Colors.white),
                  ),
                ),
                SizedBox(width: theme.spaceMD),
                PulsingButton(
                  onPressed: () {
                    FeedbackManager.questCompleted();
                  },
                  child: Text(
                    'Test Feedback',
                    style: theme.bodyMedium.copyWith(color: Colors.white),
                  ),
                ),
              ],
            ),
            
            SizedBox(height: theme.spaceLG),
            
            // Progress Ring Demo
            Text(
              'Progress Ring',
              style: theme.titleMedium,
            ),
            SizedBox(height: theme.spaceMD),
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
                  style: theme.titleMedium,
                ),
              ),
            ),
            
            SizedBox(height: theme.spaceMD),
            
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
            
            SizedBox(height: theme.spaceLG),
            
            // Feedback Settings
            Text(
              'Feedback Settings',
              style: theme.titleMedium,
            ),
            SizedBox(height: theme.spaceMD),
            
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
            
            SizedBox(height: theme.spaceLG),
            
            // Feedback Test Buttons
            Text(
              'Test Different Feedback Types',
              style: theme.titleMedium,
            ),
            SizedBox(height: theme.spaceMD),
            
            Wrap(
              spacing: theme.spaceSM,
              runSpacing: theme.spaceSM,
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