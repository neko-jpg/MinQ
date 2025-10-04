import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:minq/presentation/controllers/auth_controller.dart';
import 'package:minq/presentation/routing/app_router.dart';
import 'package:minq/presentation/theme/minq_theme.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.tokens;
    final authState = ref.watch(authControllerProvider);
    final authController = ref.read(authControllerProvider.notifier);

    // Show error if authentication failed
    if (authState.error != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_getErrorMessage(authState.error!)),
            backgroundColor: tokens.accentError,
            action: SnackBarAction(
              label: '再試衁E,
              textColor: Colors.white,
              onPressed: () => authController.clearError(),
            ),
          ),
        );
      });
    }

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
                    '1日3タチE�Eのミニクエストで習�E化を後押しします、E,
                    style: tokens.bodyLarge.copyWith(color: tokens.textMuted),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: tokens.spacing(10)), // mb-10
                  _SocialLoginButton(
                    // NOTE: Using a standard icon instead of the image from HTML
                    icon: Icons.g_mobiledata, // Placeholder for Google
                    text: 'Googleで続行すめE,
                    isLoading: authState.isLoading,
                    onPressed: () => _handleSignIn(ref, AuthMethod.google),
                  ),
                  SizedBox(height: tokens.spacing(3)), // space-y-3
                  _SocialLoginButton(
                    icon: Icons.apple,
                    text: 'Appleで続行すめE,
                    isLoading: authState.isLoading,
                    onPressed: () => _handleSignIn(ref, AuthMethod.apple),
                  ),
                  SizedBox(height: tokens.spacing(3)),
                  _SocialLoginButton(
                    icon: Icons.shield_outlined, // shield_person
                    text: 'ゲストとして試ぁE,
                    isLoading: authState.isLoading,
                    onPressed: () => _handleSignIn(ref, AuthMethod.anonymous),
                  ),
                  SizedBox(height: tokens.spacing(3)),
                  _SocialLoginButton(
                    icon: Icons.mail_outline, // mail
                    text: 'メールアドレスで続行すめE,
                    isLoading: authState.isLoading,
                    onPressed: () => _handleSignIn(ref, AuthMethod.email),
                  ),
                  const Spacer(),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: tokens.spacing(6)), // py-6
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: tokens.labelSmall.copyWith(color: tokens.textMuted),
                        children: <TextSpan>[
                          const TextSpan(text: '続行すると、MinQの'),
                          TextSpan(
                            text: '利用規紁E,
                            style: tokens.labelSmall.copyWith(
                              color: tokens.ensureAccessibleOnBackground(tokens.brandPrimary, tokens.background),
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline,
                              decorationColor: tokens.ensureAccessibleOnBackground(tokens.brandPrimary, tokens.background),
                            ),
                            recognizer: TapGestureRecognizer()..onTap = () => context.push('/policy/terms'),
                          ),
                          const TextSpan(text: 'と'),
                          TextSpan(
                            text: 'プライバシーポリシー',
                            style: tokens.labelSmall.copyWith(
                              color: tokens.ensureAccessibleOnBackground(tokens.brandPrimary, tokens.background),
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline,
                              decorationColor: tokens.ensureAccessibleOnBackground(tokens.brandPrimary, tokens.background),
                            ),
                            recognizer: TapGestureRecognizer()..onTap = () => context.push('/policy/privacy'),
                          ),
                          const TextSpan(text: 'に同意したも�Eとみなされます、E),
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

  Future<void> _handleSignIn(WidgetRef ref, AuthMethod method) async {
    final authController = ref.read(authControllerProvider.notifier);
    final success = await authController.signIn(method);
    
    if (success) {
      final navigation = ref.read(navigationUseCaseProvider);
      final authState = ref.read(authControllerProvider);
      
      if (authState.isFirstTimeUser) {
        // Navigate to onboarding for first-time users
        navigation.goToOnboarding();
      } else {
        // Navigate to home for returning users
        navigation.goHome();
      }
    }
  }

  String _getErrorMessage(String errorKey) {
    switch (errorKey) {
      case 'authErrorOperationNotAllowed':
        return 'こ�E認証方法�E現在利用できません、E;
      case 'authErrorWeakPassword':
        return 'パスワードが弱すぎます、E;
      case 'authErrorEmailAlreadyInUse':
        return 'こ�Eメールアドレスは既に使用されてぁE��す、E;
      case 'authErrorInvalidEmail':
        return 'メールアドレスの形式が正しくありません、E;
      case 'authErrorUserDisabled':
        return 'こ�Eアカウント�E無効化されてぁE��す、E;
      case 'authErrorUserNotFound':
        return 'ユーザーが見つかりません、E;
      case 'authErrorWrongPassword':
        return 'パスワードが正しくありません、E;
      case 'authErrorAccountExistsWithDifferentCredential':
        return 'こ�Eメールアドレスは別の認証方法で登録されてぁE��す、E;
      case 'authErrorInvalidCredential':
        return '認証惁E��が無効です、E;
      default:
        return '認証に失敗しました。もぁE��度お試しください、E;
    }
  }
}

class _SocialLoginButton extends StatelessWidget {
  const _SocialLoginButton({
    required this.icon,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
  });

  final IconData icon;
  final String text;
  final VoidCallback onPressed;
  final bool isLoading;

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
        shadowColor: tokens.border.withValues(alpha: 0.5),
      ),
      onPressed: isLoading ? null : onPressed,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          if (isLoading)
            SizedBox(
              width: tokens.spacing(6),
              height: tokens.spacing(6),
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(tokens.brandPrimary),
              ),
            )
          else
            Icon(icon, size: tokens.spacing(6)), // w-6 h-6
          SizedBox(width: tokens.spacing(3)), // gap-3
          Text(
            text,
            style: tokens.titleSmall.copyWith(
              color: isLoading ? tokens.textMuted : tokens.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}