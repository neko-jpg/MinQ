import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:minq/presentation/routing/app_router.dart';
import 'package:minq/presentation/theme/minq_theme.dart';

class OnboardingScreen extends ConsumerWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                        color: tokens.brandPrimary.withOpacity(0.1),
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
                          TextSpan(text: 'MinQへようこそ'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'ミニクエストと匿名サポートを通じて、最小限の努力で習慣を築きましょう。',
                      textAlign: TextAlign.center,
                      style: textTheme.bodyLarge?.copyWith(
                        color: tokens.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 40),
                    const _FeatureCard(
                      icon: Icons.touch_app,
                      title: '3タップで習慣化',
                      description: '新しい習慣をたった3タップで始められます。とてもシンプルです。',
                    ),
                    const SizedBox(height: 16),
                    const _FeatureCard(
                      icon: Icons.groups,
                      title: '匿名ペア',
                      description: 'パートナーから、匿名で説明責任とサポートを得られます。',
                    ),
                    const SizedBox(height: 16),
                    const _FeatureCard(
                      icon: Icons.explore,
                      title: 'ミニクエスト',
                      description: 'あなたの目標を、達成感のある小さなクエストに変えましょう。',
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
      child: Padding(
        padding: tokens.breathingPadding,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: tokens.brandPrimary.withOpacity(0.1),
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

class _BottomNavigation extends ConsumerWidget {
  const _BottomNavigation({
    required this.textTheme,
  });

  final TextTheme textTheme;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.tokens;
    return Padding(
      padding: const EdgeInsets.all(16.0).copyWith(top: 8),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => ref.read(navigationUseCaseProvider).goToLogin(),
              icon: const Icon(Icons.arrow_forward),
              label: const Text('始める'),
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
                'すでにアカウントをお持ちですか？',
                style: textTheme.bodySmall,
              ),
              TextButton(
                onPressed: () => ref.read(navigationUseCaseProvider).goToLogin(),
                child: Text(
                  'ログイン',
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