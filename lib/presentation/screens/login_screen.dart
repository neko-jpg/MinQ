import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:minq/data/providers.dart';
import 'package:minq/presentation/common/policy_documents.dart';
import 'package:minq/presentation/controllers/auth_controller.dart';
import 'package:minq/presentation/theme/minq_theme.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    final tokens = context.tokens;
    final colorScheme = Theme.of(context).colorScheme;

    if (authState.error != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(_describeError(authState.error!)),
              action: SnackBarAction(
                label: '閉じめE,
                textColor: tokens.primaryForeground,
                onPressed:
                    () =>
                        ref.read(authControllerProvider.notifier).clearError(),
              ),
            ),
          );
      });
    }

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: colorScheme.background,
        body: Stack(
          children: [
            Positioned.fill(child: _LoginBackground(tokens: tokens)),
            Positioned.fill(
              child: SafeArea(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: tokens.spacing.lg,
                        vertical: tokens.spacing.xl,
                      ),
                      child: _LoginCard(isLoading: authState.isLoading),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _describeError(String key) {
    return switch (key) {
      'authErrorOperationNotAllowed' => 'こ�Eサインイン方法�E現在ご利用ぁE��だけません、E,
      'authErrorWeakPassword' => 'より強力なパスワードを設定してください、E,
      'authErrorEmailAlreadyInUse' => 'こ�Eメールアドレスは既に登録されてぁE��す、E,
      'authErrorInvalidEmail' => 'メールアドレスの形式が正しくありません、E,
      'authErrorUserDisabled' => 'こ�Eアカウント�E無効化されてぁE��す、E,
      'authErrorUserNotFound' => 'アカウントが見つかりませんでした、E,
      'authErrorWrongPassword' => 'パスワードが一致しません、E,
      'authErrorAccountExistsWithDifferentCredential' => '別の方法で登録されたアカウントです、E,
      'authErrorInvalidCredential' => '認証惁E��が無効です、E,
      _ => 'サインインに失敗しました。時間をおいて再度お試しください、E,
    };
  }
}

class _LoginBackground extends StatelessWidget {
  const _LoginBackground({required this.tokens});

  final MinqTheme tokens;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [tokens.brandPrimary, tokens.accentSecondary],
        ),
      ),
      child: Align(
        alignment: Alignment.topRight,
        child: Container(
          margin: const EdgeInsets.only(top: 32, right: 32),
          width: 160,
          height: 160,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: tokens.primaryForeground.withOpacity(0.08),
          ),
        ),
      ),
    );
  }
}

class _LoginCard extends ConsumerWidget {
  const _LoginCard({required this.isLoading});

  final bool isLoading;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.tokens;
    final navigation = ref.read(navigationUseCaseProvider);

    return Card(
      elevation: 12,
      color: tokens.surface.withOpacity(0.94),
      shadowColor: tokens.textPrimary.withOpacity(0.14),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(tokens.radius.xl),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: tokens.spacing.lg,
          vertical: tokens.spacing.xl,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const _BrandHeader(),
            SizedBox(height: tokens.spacing.lg),
            Text(
              '習�Eをクエスト化して、毎日を�E険に変えよう、E,
              textAlign: TextAlign.center,
              style: tokens.typography.bodyLarge.copyWith(
                color: tokens.textSecondary,
              ),
            ),
            SizedBox(height: tokens.spacing.lg),
            _AuthButton(
              icon: Icons.g_mobiledata,
              label: 'Google で続けめE,
              onPressed: () => _signIn(ref, AuthMethod.google),
              isLoading: isLoading,
            ),
            SizedBox(height: tokens.spacing.sm),
            _AuthButton(
              icon: Icons.apple,
              label: 'Apple で続けめE,
              onPressed: () => _signIn(ref, AuthMethod.apple),
              isLoading: isLoading,
            ),
            SizedBox(height: tokens.spacing.sm),
            _AuthButton(
              icon: Icons.explore_outlined,
              label: 'ゲストモードで試ぁE,
              onPressed: () => _signIn(ref, AuthMethod.anonymous),
              isLoading: isLoading,
              style: _AuthButtonStyle.secondary,
            ),
            SizedBox(height: tokens.spacing.sm),
            _AuthButton(
              icon: Icons.mail_outline,
              label: 'メールアドレスでサインイン',
              onPressed: () => _signIn(ref, AuthMethod.email),
              isLoading: isLoading,
            ),
            SizedBox(height: tokens.spacing.xl),
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: tokens.typography.bodySmall.copyWith(
                  color: tokens.textMuted,
                ),
                children: [
                  const TextSpan(text: '続けることで、E),
                  TextSpan(
                    text: '利用規紁E,
                    style: TextStyle(color: tokens.brandPrimary),
                    recognizer:
                        TapGestureRecognizer()
                          ..onTap =
                              () =>
                                  navigation.goToPolicy(PolicyDocumentId.terms),
                  ),
                  const TextSpan(text: 'と'),
                  TextSpan(
                    text: 'プライバシーポリシー',
                    style: TextStyle(color: tokens.brandPrimary),
                    recognizer:
                        TapGestureRecognizer()
                          ..onTap =
                              () => navigation.goToPolicy(
                                PolicyDocumentId.privacy,
                              ),
                  ),
                  const TextSpan(text: 'に同意したも�Eとみなされます、E),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _signIn(WidgetRef ref, AuthMethod method) async {
    final controller = ref.read(authControllerProvider.notifier);
    final success = await controller.signIn(method);
    if (!success) return;

    final state = ref.read(authControllerProvider);
    final navigation = ref.read(navigationUseCaseProvider);

    if (state.isFirstTimeUser == true) {
      navigation.goToOnboarding();
    } else {
      navigation.goHome();
    }
  }
}

class _BrandHeader extends StatelessWidget {
  const _BrandHeader();

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Column(
      children: [
        Container(
          width: 88,
          height: 88,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [tokens.brandPrimary, tokens.accentSecondary],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Icon(
            Icons.stars_rounded,
            color: tokens.primaryForeground,
            size: 44,
          ),
        ),
        SizedBox(height: tokens.spacing.md),
        Text(
          'MinQへようこそ',
          style: tokens.typography.h3.copyWith(
            color: tokens.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

enum _AuthButtonStyle { primary, secondary }

class _AuthButton extends StatelessWidget {
  const _AuthButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    required this.isLoading,
    this.style = _AuthButtonStyle.primary,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final bool isLoading;
  final _AuthButtonStyle style;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final background =
        style == _AuthButtonStyle.primary
            ? tokens.brandPrimary
            : tokens.surface;
    final foreground =
        style == _AuthButtonStyle.primary
            ? tokens.primaryForeground
            : tokens.textPrimary;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: background,
          foregroundColor: foreground,
          minimumSize: const Size.fromHeight(50),
          elevation: style == _AuthButtonStyle.primary ? 3 : 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(tokens.radius.lg),
            side: BorderSide(
              color:
                  style == _AuthButtonStyle.primary
                      ? Colors.transparent
                      : tokens.border,
            ),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isLoading)
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(foreground),
                ),
              )
            else
              Icon(icon, size: 22),
            SizedBox(width: tokens.spacing.sm),
            Text(
              label,
              style: tokens.typography.button.copyWith(color: foreground),
            ),
          ],
        ),
      ),
    );
  }
}
