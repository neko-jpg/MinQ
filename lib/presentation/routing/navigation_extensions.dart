import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

const String _kDefaultFallbackLocation = '/';

extension SafeNavigation on BuildContext {
  void safePop<T extends Object?>([
    T? result,
    String fallbackLocation = _kDefaultFallbackLocation,
  ]) {
    final NavigatorState? navigator = Navigator.maybeOf(this);
    if (navigator != null && navigator.canPop()) {
      navigator.pop<T>(result);
      return;
    }

    final GoRouter? router = GoRouter.maybeOf(this);
    if (router != null) {
      router.go(fallbackLocation);
      return;
    }

    Navigator.of(this, rootNavigator: true).maybePop(result);
  }
}
