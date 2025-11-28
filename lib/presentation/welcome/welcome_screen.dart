import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:minq/presentation/routing/app_router.dart';
import 'package:minq/presentation/theme/minq_theme.dart';

class WelcomeScreen extends ConsumerWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.tokens;
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final navigation = ref.read(navigationUseCaseProvider);

    return Scaffold(
      backgroundColor: tokens.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: tokens.textPrimary),
          tooltip: MaterialLocalizations.of(context).backButtonTooltip,
          onPressed: () {
            final navigator = Navigator.of(context);
            if (navigator.canPop()) {
              navigator.pop();
            } else {
              navigation.goToOnboarding();
            }
          },
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(tokens.spacing(6)),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: tokens.spacing(10)),
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
                    SizedBox(height: tokens.spacing(6)),
                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: textTheme.headlineLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: tokens.textPrimary,
                        ),
                        children: const [TextSpan(text: 'MinQへようこそ')],
                      ),
                    ),
                    SizedBox(height: tokens.spacing(4)),
                    Text(
                      'ミニクエストと匿名サポートを通じて、最小限の努力で習慣を築きましょう。',
                      textAlign: TextAlign.center,
                      style: textTheme.bodyLarge?.copyWith(
                        color: tokens.textSecondary,
                      ),
                    ),
                    SizedBox(height: tokens.spacing(8)),
                    const _FeatureCard(
                      icon: Icons.touch_app,
                      title: '3タップで習慣化',
                      description: '新しい習慣をたった3タップで始められます。とてもシンプルです。',
                    ),
                    SizedBox(height: tokens.spacing(4)),
                    const _FeatureCard(
                      icon: Icons.groups,
                      title: '匿名ペア',
                      description: 'パートナーから、匿名で説明責任とサポートを得られます。',
                    ),
                    SizedBox(height: tokens.spacing(4)),
                    const _FeatureCard(
                      icon: Icons.explore,
                      title: 'ミニクエスト',
                      description: 'あなたの目標を、達成感のある小さなクエストに変えましょう。',
                    ),
                    SizedBox(height: tokens.spacing(6)),
                  ],
                ),
              ),
            ),
            _BottomNavigation(
              textTheme: textTheme,
              onGetStarted: navigation.goToOnboarding,
              onLogin: navigation.goToLogin,
            ),
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
    required this.onGetStarted,
    required this.onLogin,
  });

  final TextTheme textTheme;
  final VoidCallback onGetStarted;
  final VoidCallback onLogin;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Padding(
      padding: EdgeInsets.all(
        tokens.spacing(4),
      ).copyWith(top: tokens.spacing(2)),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: onGetStarted,
              icon: const Icon(Icons.arrow_forward),
              label: const Text('始める'),
              style: FilledButton.styleFrom(
                backgroundColor: tokens.brandPrimary,
                foregroundColor: tokens.ensureAccessibleOnBackground(
                  tokens.textPrimary,
                  tokens.brandPrimary,
                ),
                padding: EdgeInsets.symmetric(vertical: tokens.spacing(3)),
                textStyle: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: tokens.cornerLarge(),
                ),
              ),
            ),
          ),
          SizedBox(height: tokens.spacing(4)),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('すでにアカウントをお持ちですか？', style: textTheme.bodySmall),
              TextButton(
                onPressed: onLogin,
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
