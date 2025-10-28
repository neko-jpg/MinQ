import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:minq/data/providers.dart';
import 'package:minq/presentation/common/policy_documents.dart';
import 'package:minq/presentation/controllers/auth_controller.dart';
import 'package:minq/presentation/theme/minq_tokens.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    final authController = ref.read(authControllerProvider.notifier);

    // Show error if authentication failed
    if (authState.error != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_getErrorMessage(authState.error!)),
            backgroundColor: Colors.red,
            action: SnackBarAction(
              label: '再試行',
              textColor: Colors.white,
              onPressed: () => authController.clearError(),
            ),
          ),
        );
      });
    }

    return Scaffold(
      backgroundColor: MinqTokens.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        leading: Navigator.canPop(context)
            ? const BackButton(color: MinqTokens.textPrimary)
            : null,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        bottom: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 384), // max-w-sm
            child: Padding(
              padding: EdgeInsets.all(MinqTokens.spacing(6)), // p-6
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const Spacer(),
                  Icon(
                    Icons.checklist, // material-symbols-outlined: checklist
                    color: MinqTokens.brandPrimary,
                    size: MinqTokens.spacing(15), // text-6xl
                  ),
                  SizedBox(height: MinqTokens.spacing(4)), // mt-4
                  Text(
                    'MinQ',
                    style: MinqTokens.titleLarge.copyWith(
                      color: MinqTokens.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: MinqTokens.spacing(2)), // mt-2
                  Text(
                    '1日3タップのミニクエストで習慣化を後押しします。',
                    style: MinqTokens.bodyLarge
                        .copyWith(color: MinqTokens.textSecondary),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: MinqTokens.spacing(25)), // mb-10
                  _SocialLoginButton(
                    // NOTE: Using a standard icon instead of the image from HTML
                    icon: Icons.g_mobiledata, // Placeholder for Google
                    text: 'Googleで続行する',
                    isLoading: authState.isLoading,
                    onPressed: () => _handleSignIn(ref, AuthMethod.google),
                  ),
                  SizedBox(height: MinqTokens.spacing(3)), // space-y-3
                  _SocialLoginButton(
                    icon: Icons.apple,
                    text: 'Appleで続行する',
                    isLoading: authState.isLoading,
                    onPressed: () => _handleSignIn(ref, AuthMethod.apple),
                  ),
                  SizedBox(height: MinqTokens.spacing(3)),
                  _SocialLoginButton(
                    icon: Icons.shield_outlined, // shield_person
                    text: 'ゲストとして試す',
                    isLoading: authState.isLoading,
                    onPressed: () => _handleDebugGuestSignIn(ref),
                  ),
                  SizedBox(height: MinqTokens.spacing(3)),
                  _SocialLoginButton(
                    icon: Icons.mail_outline, // mail
                    text: 'メールアドレスで続行する',
                    isLoading: authState.isLoading,
                    onPressed: () => _handleSignIn(ref, AuthMethod.email),
                  ),
                  const Spacer(),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: MinqTokens.spacing(6),
                    ), // py-6
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: MinqTokens.bodySmall.copyWith(
                          color: MinqTokens.textSecondary,
                        ),
                        children: <TextSpan>[
                          const TextSpan(text: '続行すると、MinQの'),
                          TextSpan(
                            text: '利用規約',
                            style: MinqTokens.bodySmall.copyWith(
                              color: MinqTokens.brandPrimary,
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline,
                              decorationColor: MinqTokens.brandPrimary,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () => ref
                                  .read(navigationUseCaseProvider)
                                  .goToPolicy(PolicyDocumentId.terms),
                          ),
                          const TextSpan(text: 'と'),
                          TextSpan(
                            text: 'プライバシーポリシー',
                            style: MinqTokens.bodySmall.copyWith(
                              color: MinqTokens.brandPrimary,
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline,
                              decorationColor: MinqTokens.brandPrimary,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () => ref
                                  .read(navigationUseCaseProvider)
                                  .goToPolicy(PolicyDocumentId.privacy),
                          ),
                          const TextSpan(text: 'に同意したものとみなされます。'),
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
      _navigateAfterSignIn(ref);
    }
  }

  Future<void> _handleDebugGuestSignIn(WidgetRef ref) async {
    final authController = ref.read(authControllerProvider.notifier);
    final success = await authController.startDebugGuestSession();

    if (success) {
      _navigateAfterSignIn(ref);
    }
  }

  void _navigateAfterSignIn(WidgetRef ref) {
    final navigation = ref.read(navigationUseCaseProvider);
    final authState = ref.read(authControllerProvider);

    if (authState.isFirstTimeUser == true) {
      navigation.goToOnboarding();
    } else {
      navigation.goHome();
    }
  }

  String _getErrorMessage(String errorKey) {
    switch (errorKey) {
      case 'authErrorOperationNotAllowed':
        return 'この認証方法は現在利用できません。';
      case 'authErrorWeakPassword':
        return 'パスワードが弱すぎます。';
      case 'authErrorEmailAlreadyInUse':
        return 'このメールアドレスは既に使用されています。';
      case 'authErrorInvalidEmail':
        return 'メールアドレスの形式が正しくありません。';
      case 'authErrorUserDisabled':
        return 'このアカウントは無効化されています。';
      case 'authErrorUserNotFound':
        return 'ユーザーが見つかりません。';
      case 'authErrorWrongPassword':
        return 'パスワードが正しくありません。';
      case 'authErrorAccountExistsWithDifferentCredential':
        return 'このメールアドレスは別の認証方法で登録されています。';
      case 'authErrorInvalidCredential':
        return '認証情報が無効です。';
      default:
        return '認証に失敗しました。もう一度お試しください。';
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
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: MinqTokens.surface, // card-light
        foregroundColor: MinqTokens.textSecondary, // text-slate-700
        minimumSize:
            Size(double.infinity, MinqTokens.spacing(12)), // py-3.5
        padding:
            EdgeInsets.symmetric(horizontal: MinqTokens.spacing(6)), // px-6
        shape: RoundedRectangleBorder(
          borderRadius: MinqTokens.cornerLarge(), // rounded-xl
          side: const BorderSide(color: Colors.transparent), // border-slate-300
        ),
        elevation: 1,
        shadowColor: MinqTokens.textSecondary.withAlpha(128),
      ),
      onPressed: isLoading ? null : onPressed,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          if (isLoading)
            SizedBox(
              width: MinqTokens.spacing(4),
              height: MinqTokens.spacing(4),
              child: const CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(MinqTokens.brandPrimary),
              ),
            )
          else
            Icon(icon, size: MinqTokens.spacing(4)), // w-6 h-6
          SizedBox(width: MinqTokens.spacing(3)), // gap-3
          Text(
            text,
            style: MinqTokens.bodyMedium.copyWith(
              color:
                  isLoading ? MinqTokens.textSecondary : MinqTokens.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
