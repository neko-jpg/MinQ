import 'package:flutter/material.dart';
import 'package:minq/presentation/theme/minq_theme.dart';

typedef AsyncCallback = Future<void> Function();

mixin AsyncActionState<T extends StatefulWidget> on State<T> {
  bool _isProcessing = false;

  bool get isProcessing => _isProcessing;

  @protected
  Future<void> runGuarded(AsyncCallback action) async {
    if (_isProcessing) {
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      await action();
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }
}

class MinqPrimaryButton extends StatefulWidget {
  const MinqPrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.expand = true,
  });

  final String label;
  final AsyncCallback? onPressed;
  final IconData? icon;
  final bool expand;

  @override
  State<MinqPrimaryButton> createState() => _MinqPrimaryButtonState();
}

class _MinqPrimaryButtonState extends State<MinqPrimaryButton>
    with AsyncActionState<MinqPrimaryButton> {
  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final bool disabled = widget.onPressed == null || isProcessing;

    Widget buildContent() {
      if (isProcessing) {
        return SizedBox(
          key: const ValueKey<String>('progress'),
          height: tokens.spacing(6),
          width: tokens.spacing(6),
          child: CircularProgressIndicator(
            strokeWidth: 3,
            valueColor: AlwaysStoppedAnimation<Color>(tokens.surface),
          ),
        );
      }

      final bool hasIcon = widget.icon != null;
      return Row(
        key: const ValueKey<String>('label'),
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          if (hasIcon) ...<Widget>[
            Icon(widget.icon, size: tokens.spacing(6)),
            SizedBox(width: tokens.spacing(2)),
          ],
          Flexible(
            child: Text(
              widget.label,
              textAlign: TextAlign.center,
              style: tokens.titleSmall.copyWith(color: tokens.surface),
            ),
          ),
        ],
      );
    }

    final button = FilledButton(
      style: FilledButton.styleFrom(
        backgroundColor: tokens.brandPrimary,
        foregroundColor: tokens.surface,
        minimumSize: Size.fromHeight(tokens.spacing(14)),
        padding: EdgeInsets.symmetric(horizontal: tokens.spacing(6)),
        shape: RoundedRectangleBorder(borderRadius: tokens.cornerXLarge()),
        textStyle: tokens.titleSmall,
      ),
      onPressed: disabled
          ? null
          : () => runGuarded(() async {
                await widget.onPressed!();
              }),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 180),
        transitionBuilder: (Widget child, Animation<double> animation) {
          return FadeTransition(opacity: animation, child: child);
        },
        child: buildContent(),
      ),
    );

    if (widget.expand) {
      return SizedBox(width: double.infinity, child: button);
    }

    return button;
  }
}
