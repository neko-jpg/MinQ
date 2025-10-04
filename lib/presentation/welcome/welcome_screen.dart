
import 'package:flutter/material.dart';
import 'package:minq/presentation/theme/minq_theme.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40),
                    Container(
                      width: 96,
                      height: 96,
                      decoration: BoxDecoration(
                        color: tokens.brandPrimary.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.checklist,
                        color: tokens.brandPrimary,
                        size: 56,
                      ),
                    ),
                    const SizedBox(height: 24),
                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: textTheme.headlineLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: tokens.textPrimary,
                        ),
                        children: const [
                          TextSpan(text: 'MinQ縺ｸ繧医≧縺薙◎'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '繝溘ル繧ｯ繧ｨ繧ｹ繝医→蛹ｿ蜷阪し繝昴・繝医ｒ騾壹§縺ｦ縲∵怙蟆城剞縺ｮ蜉ｪ蜉帙〒鄙呈・繧堤ｯ峨″縺ｾ縺励ｇ縺・・,
                      textAlign: TextAlign.center,
                      style: textTheme.bodyLarge?.copyWith(
                        color: tokens.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 40),
                    const _FeatureCard(
                      icon: Icons.touch_app,
                      title: '3繧ｿ繝・・縺ｧ鄙呈・蛹・,
                      description: '譁ｰ縺励＞鄙呈・繧偵◆縺｣縺・繧ｿ繝・・縺ｧ蟋九ａ繧峨ｌ縺ｾ縺吶ゅ→縺ｦ繧ゅす繝ｳ繝励Ν縺ｧ縺吶・,
                    ),
                    const SizedBox(height: 16),
                    const _FeatureCard(
                      icon: Icons.groups,
                      title: '蛹ｿ蜷阪・繧｢',
                      description: '繝代・繝医リ繝ｼ縺九ｉ縲∝諺蜷阪〒隱ｬ譏手ｲｬ莉ｻ縺ｨ繧ｵ繝昴・繝医ｒ蠕励ｉ繧後∪縺吶・,
                    ),
                    const SizedBox(height: 16),
                    const _FeatureCard(
                      icon: Icons.explore,
                      title: '繝溘ル繧ｯ繧ｨ繧ｹ繝・,
                      description: '縺ゅ↑縺溘・逶ｮ讓吶ｒ縲・＃謌先─縺ｮ縺ゅｋ蟆上＆縺ｪ繧ｯ繧ｨ繧ｹ繝医↓螟峨∴縺ｾ縺励ｇ縺・・,
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
            _BottomNavigation(textTheme: textTheme),
          ],
        ),
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: tokens.cornerLarge()),
      child: Padding(
        padding: tokens.breathingPadding,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: tokens.brandPrimary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: tokens.brandPrimary),
            ),
            SizedBox(width: tokens.spaceMD),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: tokens.titleMedium.copyWith(
                      fontWeight: FontWeight.bold,
                      color: tokens.textPrimary,
                    ),
                  ),
                  SizedBox(height: tokens.intimateSpace),
                  Text(
                    description,
                    style: tokens.bodyMedium.copyWith(
                      color: tokens.textSecondary,
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
}

class _BottomNavigation extends StatelessWidget {
  const _BottomNavigation({
    required this.textTheme,
  });

  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Padding(
      padding: const EdgeInsets.all(16.0).copyWith(top: 8),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                // TODO: Implement navigation to home screen
              },
              icon: const Icon(Icons.arrow_forward),
              label: const Text('蟋九ａ繧・),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '縺吶〒縺ｫ繧｢繧ｫ繧ｦ繝ｳ繝医ｒ縺頑戟縺｡縺ｧ縺吶°・・,
                style: textTheme.bodySmall,
              ),
              TextButton(
                onPressed: () {
                  // TODO: Implement login navigation
                },
                child: Text(
                  '繝ｭ繧ｰ繧､繝ｳ',
                  style: textTheme.bodySmall?.copyWith(
                    color: tokens.brandPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
