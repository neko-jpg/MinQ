import 'package:flutter/material.dart';
import 'package:minq/presentation/theme/design_tokens.dart';
import 'package:minq/presentation/widgets/polished_ui_components.dart';
import 'package:minq/presentation/widgets/enhanced_micro_interactions.dart';
import 'package:minq/presentation/widgets/visual_hierarchy.dart';
import 'package:minq/presentation/widgets/screen_transitions.dart';

/// Showcase screen demonstrating all polished UI components and micro-interactions
/// This serves as both a demo and a reference for consistent design implementation
class PolishedShowcaseScreen extends StatefulWidget {
  const PolishedShowcaseScreen({super.key});

  @override
  State<PolishedShowcaseScreen> createState() => _PolishedShowcaseScreenState();
}

class _PolishedShowcaseScreenState extends State<PolishedShowcaseScreen> {
  bool _switchValue = false;
  double _sliderValue = 0.5;
  bool _isLoading = false;
  bool _showConfetti = false;
  bool _iconToggled = false;
  int _selectedChip = 0;

  @override
  Widget build(BuildContext context) {
    final tokens = MinqDesignTokens.of(context);

    return Scaffold(
      backgroundColor: tokens.colors.background,
      appBar: AppBar(
        title: Text(
          'Polished UI Showcase',
          style: tokens.typography.headlineSmall.copyWith(
            color: tokens.colors.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: tokens.colors.surface,
        elevation: 0,
        leading: PolishedIconButton(
          icon: Icons.arrow_back,
          onPressed: () => Navigator.of(context).pop(),
          semanticLabel: 'Go back',
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(tokens.spacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section: Buttons
            SectionHeader(
              title: 'Polished Buttons',
              subtitle: 'Enhanced buttons with micro-interactions',
              icon: Icons.touch_app,
            ),
            ContentSection(
              children: [
                Wrap(
                  spacing: tokens.spacing.md,
                  runSpacing: tokens.spacing.md,
                  children: [
                    PolishedPrimaryButton(
                      onPressed: () {
                        setState(() => _showConfetti = !_showConfetti);
                      },
                      child: const Text('Primary Button'),
                      icon: Icons.star,
                    ),
                    PolishedSecondaryButton(
                      onPressed: () {},
                      child: const Text('Secondary Button'),
                      icon: Icons.favorite,
                    ),
                    PolishedTextButton(
                      onPressed: () {},
                      child: const Text('Text Button'),
                    ),
                    InteractiveButton(
                      onPressed: () {},
                      style: ButtonStyle.primary,
                      enableGlow: true,
                      child: const Text('Interactive Button'),
                    ),
                  ],
                ),
              ],
            ),

            // Section: Interactive Elements
            SectionHeader(
              title: 'Interactive Elements',
              subtitle: 'Switches, sliders, and form controls',
              icon: Icons.tune,
            ),
            ContentSection(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: InfoHierarchy(
                        primary: 'Enable notifications',
                        secondary: 'Get notified about important updates',
                      ),
                    ),
                    PolishedSwitch(
                      value: _switchValue,
                      onChanged: (value) {
                        setState(() => _switchValue = value);
                      },
                    ),
                  ],
                ),
                SizedBox(height: tokens.spacing.lg),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Volume: ${(_sliderValue * 100).round()}%',
                      style: tokens.typography.bodyMedium.copyWith(
                        color: tokens.colors.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: tokens.spacing.sm),
                    PolishedSlider(
                      value: _sliderValue,
                      onChanged: (value) {
                        setState(() => _sliderValue = value);
                      },
                      label: '${(_sliderValue * 100).round()}%',
                    ),
                  ],
                ),
              ],
            ),

            // Section: Cards and Containers
            SectionHeader(
              title: 'Cards & Containers',
              subtitle: 'Polished cards with hover effects',
              icon: Icons.dashboard,
            ),
            ContentSection(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: PolishedCard(
                        onTap: () {},
                        child: MetricDisplay(
                          value: '42',
                          label: 'Habits Completed',
                          unit: 'total',
                          icon: Icons.check_circle,
                          accentColor: tokens.colors.success,
                          changeText: '+12%',
                          isPositive: true,
                        ),
                      ),
                    ),
                    SizedBox(width: tokens.spacing.md),
                    Expanded(
                      child: PolishedCard(
                        onTap: () {},
                        child: MetricDisplay(
                          value: '7',
                          label: 'Current Streak',
                          unit: 'days',
                          icon: Icons.local_fire_department,
                          accentColor: tokens.colors.warning,
                          changeText: '+2',
                          isPositive: true,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),

            // Section: Status Indicators
            SectionHeader(
              title: 'Status & Priority',
              subtitle: 'Visual indicators for different states',
              icon: Icons.info,
            ),
            ContentSection(
              children: [
                Wrap(
                  spacing: tokens.spacing.sm,
                  runSpacing: tokens.spacing.sm,
                  children: [
                    StatusIndicator(
                      text: 'Completed',
                      type: StatusType.success,
                    ),
                    StatusIndicator(
                      text: 'In Progress',
                      type: StatusType.info,
                    ),
                    StatusIndicator(
                      text: 'Warning',
                      type: StatusType.warning,
                    ),
                    StatusIndicator(
                      text: 'Error',
                      type: StatusType.error,
                    ),
                  ],
                ),
                SizedBox(height: tokens.spacing.md),
                Wrap(
                  spacing: tokens.spacing.sm,
                  runSpacing: tokens.spacing.sm,
                  children: [
                    PriorityIndicator(level: PriorityLevel.high),
                    PriorityIndicator(level: PriorityLevel.medium),
                    PriorityIndicator(level: PriorityLevel.low),
                  ],
                ),
              ],
            ),

            // Section: Chips and Tags
            SectionHeader(
              title: 'Chips & Tags',
              subtitle: 'Selectable and interactive chips',
              icon: Icons.label,
            ),
            ContentSection(
              children: [
                Wrap(
                  spacing: tokens.spacing.sm,
                  runSpacing: tokens.spacing.sm,
                  children: List.generate(5, (index) {
                    final labels = ['Health', 'Fitness', 'Learning', 'Work', 'Personal'];
                    final icons = [
                      Icons.health_and_safety,
                      Icons.fitness_center,
                      Icons.school,
                      Icons.work,
                      Icons.person,
                    ];
                    
                    return PolishedChip(
                      label: labels[index],
                      icon: icons[index],
                      isSelected: _selectedChip == index,
                      onTap: () {
                        setState(() => _selectedChip = index);
                      },
                    );
                  }),
                ),
              ],
            ),

            // Section: Loading States
            SectionHeader(
              title: 'Loading Animations',
              subtitle: 'Various loading indicators',
              icon: Icons.refresh,
            ),
            ContentSection(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(
                      children: [
                        const LoadingAnimation(style: LoadingStyle.dots),
                        SizedBox(height: tokens.spacing.sm),
                        Text(
                          'Dots',
                          style: tokens.typography.bodySmall.copyWith(
                            color: tokens.colors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        const LoadingAnimation(style: LoadingStyle.pulse),
                        SizedBox(height: tokens.spacing.sm),
                        Text(
                          'Pulse',
                          style: tokens.typography.bodySmall.copyWith(
                            color: tokens.colors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        const LoadingAnimation(style: LoadingStyle.wave),
                        SizedBox(height: tokens.spacing.sm),
                        Text(
                          'Wave',
                          style: tokens.typography.bodySmall.copyWith(
                            color: tokens.colors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        const LoadingAnimation(style: LoadingStyle.spinner),
                        SizedBox(height: tokens.spacing.sm),
                        Text(
                          'Spinner',
                          style: tokens.typography.bodySmall.copyWith(
                            color: tokens.colors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),

            // Section: Micro-interactions
            SectionHeader(
              title: 'Micro-interactions',
              subtitle: 'Delightful animations and feedback',
              icon: Icons.animation,
            ),
            ContentSection(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(
                      children: [
                        MorphingIcon(
                          startIcon: Icons.favorite_border,
                          endIcon: Icons.favorite,
                          isToggled: _iconToggled,
                          onTap: () {
                            setState(() => _iconToggled = !_iconToggled);
                          },
                          color: tokens.colors.error,
                          size: 32,
                        ),
                        SizedBox(height: tokens.spacing.sm),
                        Text(
                          'Morphing Icon',
                          style: tokens.typography.bodySmall.copyWith(
                            color: tokens.colors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        FloatingAnimation(
                          child: Icon(
                            Icons.cloud,
                            size: 32,
                            color: tokens.colors.primary,
                          ),
                        ),
                        SizedBox(height: tokens.spacing.sm),
                        Text(
                          'Floating',
                          style: tokens.typography.bodySmall.copyWith(
                            color: tokens.colors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        BreathingAnimation(
                          child: Icon(
                            Icons.favorite,
                            size: 32,
                            color: tokens.colors.error,
                          ),
                        ),
                        SizedBox(height: tokens.spacing.sm),
                        Text(
                          'Breathing',
                          style: tokens.typography.bodySmall.copyWith(
                            color: tokens.colors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),

            // Section: Callouts
            SectionHeader(
              title: 'Callouts & Alerts',
              subtitle: 'Important information display',
              icon: Icons.announcement,
            ),
            ContentSection(
              children: [
                CalloutBox(
                  title: 'Success!',
                  content: 'Your habit has been successfully completed. Keep up the great work!',
                  type: CalloutType.success,
                ),
                SizedBox(height: tokens.spacing.md),
                CalloutBox(
                  title: 'Reminder',
                  content: 'Don\'t forget to complete your daily meditation session.',
                  type: CalloutType.info,
                  isDismissible: true,
                  onDismiss: () {},
                ),
              ],
            ),

            // Section: Progress Indicators
            SectionHeader(
              title: 'Progress Indicators',
              subtitle: 'Enhanced progress visualization',
              icon: Icons.trending_up,
            ),
            ContentSection(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    PolishedLinearProgressIndicator(
                      value: 0.7,
                      label: 'Weekly Goal Progress',
                      showLabel: true,
                    ),
                    SizedBox(height: tokens.spacing.lg),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        PolishedProgressIndicator(
                          value: 0.3,
                          showPercentage: true,
                          size: 60,
                        ),
                        PolishedProgressIndicator(
                          value: 0.7,
                          showPercentage: true,
                          size: 60,
                          valueColor: tokens.colors.success,
                        ),
                        PolishedProgressIndicator(
                          value: 1.0,
                          showPercentage: true,
                          size: 60,
                          valueColor: tokens.colors.warning,
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),

            // Floating Action Button
            SizedBox(height: tokens.spacing.xxl),
          ],
        ),
      ),
      floatingActionButton: ParticleExplosion(
        isActive: _showConfetti,
        child: PolishedFloatingActionButton(
          onPressed: () {
            setState(() => _showConfetti = !_showConfetti);
          },
          semanticLabel: 'Toggle confetti effect',
          child: Icon(_showConfetti ? Icons.stop : Icons.celebration),
        ),
      ),
    );
  }
}

/// Demo screen for screen transitions
class TransitionDemoScreen extends StatelessWidget {
  const TransitionDemoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tokens = MinqDesignTokens.of(context);

    return Scaffold(
      backgroundColor: tokens.colors.background,
      appBar: AppBar(
        title: Text(
          'Transition Demo',
          style: tokens.typography.headlineSmall.copyWith(
            color: tokens.colors.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: tokens.colors.surface,
        elevation: 0,
      ),
      body: Padding(
        padding: EdgeInsets.all(tokens.spacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionHeader(
              title: 'Screen Transitions',
              subtitle: 'Tap buttons to see different transition effects',
              icon: Icons.animation,
            ),
            SizedBox(height: tokens.spacing.lg),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: tokens.spacing.md,
                mainAxisSpacing: tokens.spacing.md,
                children: [
                  _TransitionButton(
                    title: 'Fade',
                    icon: Icons.blur_on,
                    onTap: () => _navigateWithTransition(
                      context,
                      TransitionType.fade,
                    ),
                  ),
                  _TransitionButton(
                    title: 'Slide Right',
                    icon: Icons.arrow_forward,
                    onTap: () => _navigateWithTransition(
                      context,
                      TransitionType.slideFromRight,
                    ),
                  ),
                  _TransitionButton(
                    title: 'Scale',
                    icon: Icons.zoom_in,
                    onTap: () => _navigateWithTransition(
                      context,
                      TransitionType.scale,
                    ),
                  ),
                  _TransitionButton(
                    title: 'Morphing',
                    icon: Icons.transform,
                    onTap: () => _navigateWithTransition(
                      context,
                      TransitionType.morphing,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateWithTransition(BuildContext context, TransitionType type) {
    Navigator.of(context).push(
      PageTransition.createRoute(
        page: const PolishedShowcaseScreen(),
        type: type,
      ),
    );
  }
}

class _TransitionButton extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const _TransitionButton({
    required this.title,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = MinqDesignTokens.of(context);

    return PolishedCard(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 32,
            color: tokens.colors.primary,
          ),
          SizedBox(height: tokens.spacing.sm),
          Text(
            title,
            style: tokens.typography.titleSmall.copyWith(
              color: tokens.colors.onSurface,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}