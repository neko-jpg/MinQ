import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:minq/presentation/theme/minq_theme.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Scaffold(
      backgroundColor: tokens.background,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 384), // max-w-sm
            child: Padding(
              padding: EdgeInsets.all(tokens.spacing(6)), // p-6
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const Spacer(),
                  Icon(
                    Icons.checklist, // material-symbols-outlined: checklist
                    color: tokens.brandPrimary,
                    size: tokens.spacing(15), // text-6xl
                  ),
                  SizedBox(height: tokens.spacing(4)), // mt-4
                  Text(
                    'MinQ',
                    style: tokens.displaySmall.copyWith(
                      color: tokens.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: tokens.spacing(2)), // mt-2
                  Text(
                    'Build habits, one mini-quest at a time.',
                    style: tokens.bodyLarge.copyWith(color: tokens.textMuted),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: tokens.spacing(10)), // mb-10
                  _SocialLoginButton(
                    // NOTE: Using a standard icon instead of the image from HTML
                    icon: Icons.g_mobiledata, // Placeholder for Google
                    text: 'Continue with Google',
                    onPressed: () => context.go('/home'),
                  ),
                  SizedBox(height: tokens.spacing(3)), // space-y-3
                  _SocialLoginButton(
                    icon: Icons.apple,
                    text: 'Continue with Apple',
                    onPressed: () => context.go('/home'),
                  ),
                  SizedBox(height: tokens.spacing(3)),
                  _SocialLoginButton(
                    icon: Icons.shield_outlined, // shield_person
                    text: 'Continue as Guest',
                    onPressed: () => context.go('/home'),
                  ),
                  SizedBox(height: tokens.spacing(3)),
                  _SocialLoginButton(
                    icon: Icons.mail_outline, // mail
                    text: 'Continue with Email',
                    onPressed: () => context.go('/home'),
                  ),
                  const Spacer(),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: tokens.spacing(6)), // py-6
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: tokens.labelSmall.copyWith(color: tokens.textMuted),
                        children: <TextSpan>[
                          const TextSpan(text: 'By continuing, you agree to MinQ\'s '),
                          TextSpan(
                            text: 'Terms of Service',
                            style: tokens.labelSmall.copyWith(
                              color: tokens.brandPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                            recognizer: TapGestureRecognizer()..onTap = () => context.push('/policy/terms'),
                          ),
                          const TextSpan(text: ' and '),
                          TextSpan(
                            text: 'Privacy Policy',
                            style: tokens.labelSmall.copyWith(
                              color: tokens.brandPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                            recognizer: TapGestureRecognizer()..onTap = () => context.push('/policy/privacy'),
                          ),
                          const TextSpan(text: '.'),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SocialLoginButton extends StatelessWidget {
  const _SocialLoginButton({
    required this.icon,
    required this.text,
    required this.onPressed,
  });

  final IconData icon;
  final String text;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: tokens.surface, // card-light
        foregroundColor: tokens.textSecondary, // text-slate-700
        minimumSize: Size(double.infinity, tokens.spacing(13.5)), // py-3.5
        padding: EdgeInsets.symmetric(horizontal: tokens.spacing(6)), // px-6
        shape: RoundedRectangleBorder(
          borderRadius: tokens.cornerXLarge(), // rounded-xl
          side: BorderSide(color: tokens.border), // border-slate-300
        ),
        elevation: 1,
        shadowColor: tokens.border.withOpacity(0.5),
      ),
      onPressed: onPressed,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(icon, size: tokens.spacing(6)), // w-6 h-6
          SizedBox(width: tokens.spacing(3)), // gap-3
          Text(
            text,
            style: tokens.titleSmall.copyWith(
              color: tokens.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}