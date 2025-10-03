import 'package:flutter/widgets.dart';

/// Provides additional padding to avoid IME candidate windows overlapping the UI.
class ImeSafeArea extends StatelessWidget {
  const ImeSafeArea({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final viewInsets = MediaQuery.viewInsetsOf(context);
    return AnimatedPadding(
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeOut,
      padding: EdgeInsets.only(bottom: viewInsets.bottom),
      child: child,
    );
  }
}
